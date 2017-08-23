Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E14F280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:28:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p8so1468261wrf.6
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 01:28:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o20si862059wrf.294.2017.08.23.01.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 01:28:52 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7N8Sl72118956
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:28:51 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ch4qj5b9v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 04:28:50 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Aug 2017 18:28:44 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7N8SgRN39976980
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 18:28:42 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7N8SXLG018701
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 18:28:33 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/page_fault: Remove reduntant check for write access
Date: Wed, 23 Aug 2017 13:58:39 +0530
Message-Id: <20170823082839.1812-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

Flags argument has been copied into vmf.flags and it does not
seem to have changed in between. Hence a single write access
check can be used for both PUD and PMD.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/memory.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index fe2fba2..c62236d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3802,6 +3802,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		.pgoff = linear_page_index(vma, address),
 		.gfp_mask = __get_fault_gfp_mask(vma),
 	};
+	unsigned int dirty = flags & FAULT_FLAG_WRITE;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
@@ -3824,7 +3825,6 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 		barrier();
 		if (pud_trans_huge(orig_pud) || pud_devmap(orig_pud)) {
-			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
 			/* NUMA case for anonymous PUDs would go here */
 
@@ -3854,8 +3854,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-			if ((vmf.flags & FAULT_FLAG_WRITE) &&
-					!pmd_write(orig_pmd)) {
+			if (dirty && !pmd_write(orig_pmd)) {
 				ret = wp_huge_pmd(&vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
