Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4524D6B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:18:20 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x6-v6so4957214wrl.6
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:18:20 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s7-v6si4646207wrq.151.2018.06.29.11.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:18:19 -0700 (PDT)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5TIDNej029085
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:18:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2jwsdj0318-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:18:17 -0700
From: Song Liu <songliubraving@fb.com>
Subject: [PATCH] mm: thp: passing correct vm_flags to hugepage_vma_check
Date: Fri, 29 Jun 2018 11:17:52 -0700
Message-ID: <20180629181752.792831-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Song Liu <songliubraving@fb.com>, Yang Shi <yang.shi@linux.alibaba.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>

Back in May, I sent patch similar to 02b75dc8160d:

https://patchwork.kernel.org/patch/10416233/  (v1)

This patch got positive feedback. However, I realized there is a problem,
that vma->vm_flags in khugepaged_enter_vma_merge() is stale. The separate
argument vm_flags contains the latest value. Therefore, it is
necessary to pass this vm_flags into hugepage_vma_check(). To fix this
problem,  I resent v2 and v3 of the work:

https://patchwork.kernel.org/patch/10419527/   (v2)
https://patchwork.kernel.org/patch/10433937/   (v3)

To my surprise, after I thought we all agreed on v3 of the work. Yang's
patch, which is similar to correct looking (but wrong) v1, got applied.
So we still have the issue of stale vma->vm_flags. This patch fixes this
issue. Please apply.

Fixes: 02b75dc8160d ("mm: thp: register mm for khugepaged when merging vma for shmem")
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index b2c328030aa2..38b7db1933a3 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -397,10 +397,11 @@ static inline int khugepaged_test_exit(struct mm_struct *mm)
 	return atomic_read(&mm->mm_users) == 0;
 }
 
-static bool hugepage_vma_check(struct vm_area_struct *vma)
+static bool hugepage_vma_check(struct vm_area_struct *vma,
+			       unsigned long vm_flags)
 {
-	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
-	    (vma->vm_flags & VM_NOHUGEPAGE) ||
+	if ((!(vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
+	    (vm_flags & VM_NOHUGEPAGE) ||
 	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
 		return false;
 	if (shmem_file(vma->vm_file)) {
@@ -413,7 +414,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
-	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
+	return !(vm_flags & VM_NO_KHUGEPAGED);
 }
 
 int __khugepaged_enter(struct mm_struct *mm)
@@ -458,7 +459,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 	 * khugepaged does not yet work on non-shmem files or special
 	 * mappings. And file-private shmem THP is not supported.
 	 */
-	if (!hugepage_vma_check(vma))
+	if (!hugepage_vma_check(vma, vm_flags))
 		return 0;
 
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
@@ -861,7 +862,7 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address,
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
 		return SCAN_ADDRESS_RANGE;
-	if (!hugepage_vma_check(vma))
+	if (!hugepage_vma_check(vma, vma->vm_flags))
 		return SCAN_VMA_CHECK;
 	return 0;
 }
@@ -1660,7 +1661,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 			progress++;
 			break;
 		}
-		if (!hugepage_vma_check(vma)) {
+		if (!hugepage_vma_check(vma, vma->vm_flags)) {
 skip:
 			progress++;
 			continue;
-- 
2.17.1
