Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A664B6B0279
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so65335716wmt.7
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i22si14824535wrc.81.2017.01.29.19.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:50 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YSET082664
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:49 -0500
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289he1j46h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:48 -0500
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:45 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 7594B2BB0055
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:42 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cYjn8716496
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:42 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3cAOf021364
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:10 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during mbind(MPOL_BIND)
Date: Mon, 30 Jan 2017 09:05:53 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Mark all the applicable VMAs with VM_CDM explicitly during mbind(MPOL_BIND)
call if the user provided nodemask has a CDM node.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 78e095b..4482140 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -175,6 +175,16 @@ static void mpol_relative_nodemask(nodemask_t *ret, const nodemask_t *orig,
 }
 
 #ifdef CONFIG_COHERENT_DEVICE
+static inline void set_vm_cdm(struct vm_area_struct *vma)
+{
+	vma->vm_flags |= VM_CDM;
+}
+
+static inline void clr_vm_cdm(struct vm_area_struct *vma)
+{
+	vma->vm_flags &= ~VM_CDM;
+}
+
 static void mark_vma_cdm(nodemask_t *nmask,
 		struct page *page, struct vm_area_struct *vma)
 {
@@ -191,6 +201,9 @@ static void mark_vma_cdm(nodemask_t *nmask,
 		vma->vm_flags |= VM_CDM;
 }
 #else
+static inline void set_vm_cdm(struct vm_area_struct *vma) { }
+static inline void clr_vm_cdm(struct vm_area_struct *vma) { }
+
 static void mark_vma_cdm(nodemask_t *nmask,
 		struct page *page, struct vm_area_struct *vma)
 {
@@ -770,6 +783,10 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 		vmstart = max(start, vma->vm_start);
 		vmend   = min(end, vma->vm_end);
 
+		if ((new_pol->mode == MPOL_BIND)
+			&& nodemask_has_cdm(new_pol->v.nodes))
+			set_vm_cdm(vma);
+
 		if (mpol_equal(vma_policy(vma), new_pol))
 			continue;
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
