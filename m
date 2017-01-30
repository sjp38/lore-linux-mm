Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8E566B0278
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:41 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so440971750pgi.1
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u22si11352076plj.6.2017.01.29.19.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:41 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YKqj002765
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:40 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 288rb77mft-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:40 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:38 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 45AC02BB0057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:36 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cSc239059654
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:36 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3c35B021213
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:04 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 11/12] mm: Tag VMA with VM_CDM flag during page fault
Date: Mon, 30 Jan 2017 09:05:52 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-12-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Mark the corresponding VMA with VM_CDM flag if the allocated page happens
to be from a CDM node. This can be expensive from performance stand point.
There are multiple checks to avoid an expensive page_to_nid lookup but it
can be optimized further.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6089c711..78e095b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -174,6 +174,29 @@ static void mpol_relative_nodemask(nodemask_t *ret, const nodemask_t *orig,
 	nodes_onto(*ret, tmp, *rel);
 }
 
+#ifdef CONFIG_COHERENT_DEVICE
+static void mark_vma_cdm(nodemask_t *nmask,
+		struct page *page, struct vm_area_struct *vma)
+{
+	if (!page)
+		return;
+
+	if (vma->vm_flags & VM_CDM)
+		return;
+
+	if (nmask && !nodemask_has_cdm(*nmask))
+		return;
+
+	if (is_cdm_node(page_to_nid(page)))
+		vma->vm_flags |= VM_CDM;
+}
+#else
+static void mark_vma_cdm(nodemask_t *nmask,
+		struct page *page, struct vm_area_struct *vma)
+{
+}
+#endif
+
 static int mpol_new_interleave(struct mempolicy *pol, const nodemask_t *nodes)
 {
 	if (nodes_empty(*nodes))
@@ -2039,6 +2062,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	nmask = policy_nodemask(gfp, pol);
 	zl = policy_zonelist(gfp, pol, node);
 	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
+	mark_vma_cdm(nmask, page, vma);
 	mpol_cond_put(pol);
 out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
