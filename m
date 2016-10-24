Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBB0C6B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so114617568pfg.3
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l64si13473283pfa.191.2016.10.23.21.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:27 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4SuJs079134
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2695tb260v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:23 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 0B691125805F
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:03:00 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4WLOj41156736
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:21 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WJEt020955
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:20 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
Date: Mon, 24 Oct 2016 10:01:54 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

VMAs containing coherent device memory should be marked with VM_CDM. These
VMAs need to be identified in various core kernel paths and this new flag
will help in this regard.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mm.h |  5 +++++
 mm/mempolicy.c     | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3a19185..acee4d1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -182,6 +182,11 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
+
+#ifdef CONFIG_COHERENT_DEVICE
+#define VM_CDM		0x00800000	/* Contains coherent device memory */
+#endif
+
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_ARCH_2	0x02000000
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index cb1ba01..b983cea 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -174,6 +174,47 @@ static void mpol_relative_nodemask(nodemask_t *ret, const nodemask_t *orig,
 	nodes_onto(*ret, tmp, *rel);
 }
 
+#ifdef CONFIG_COHERENT_DEVICE
+static bool nodemask_contains_cdm(nodemask_t *nodes)
+{
+	int weight, nid, i;
+	nodemask_t mask;
+
+
+	if (!nodes)
+		return false;
+
+	mask = *nodes;
+	weight = nodes_weight(mask);
+	nid = first_node(mask);
+	for (i = 0; i < weight; i++) {
+		if (isolated_cdm_node(nid))
+			return true;
+		nid = next_node(nid, mask);
+	}
+	return false;
+}
+
+static void update_coherent_vma_flag(nodemask_t *nmask,
+		struct page *page, struct vm_area_struct *vma)
+{
+	if (!page)
+		return;
+
+	if (nodemask_contains_cdm(nmask)) {
+		if (!(vma->vm_flags & VM_CDM)) {
+			if (isolated_cdm_node(page_to_nid(page)))
+				vma->vm_flags |= VM_CDM;
+		}
+	}
+}
+#else
+static void update_coherent_vma_flag(nodemask_t *nmask,
+		struct page *page, struct vm_area_struct *vma)
+{
+}
+#endif
+
 static int mpol_new_interleave(struct mempolicy *pol, const nodemask_t *nodes)
 {
 	if (nodes_empty(*nodes))
@@ -2045,6 +2086,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	zl = policy_zonelist(gfp, pol, node);
 	mpol_cond_put(pol);
 	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
+	update_coherent_vma_flag(nmask, page, vma);
+
 out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
