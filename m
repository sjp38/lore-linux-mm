Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82CA66B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 16:03:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w1-v6so3062060pgr.7
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 13:03:46 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id w1-v6si6696934pgr.489.2018.06.22.13.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 13:03:44 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH] mm: thp: register mm for khugepaged when merging vma for shmem
Date: Sat, 23 Jun 2018 04:03:11 +0800
Message-Id: <1529697791-6950-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When merging anonymous page vma, if the size of vma can fit in at least
one hugepage, the mm will be registered for khugepaged for collapsing
THP in the future.

But, it skips shmem vma. Doing so for shmem too, but not file-private
mapping, when merging vma in order to increase the odd to collapse
hugepage by khugepaged.

hugepage_vma_check() sounds like a good fit to do the check. And, moved
the definition of it before khugepaged_enter_vma_merge() to suppress
build error.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
v2 --> v3:
* Use hugepage_vma_check() do the check per Kirill's comment

v1 --> v2:
* Exclude file-private mapping per Kirill's comment

 mm/khugepaged.c | 53 ++++++++++++++++++++++++++---------------------------
 1 file changed, 26 insertions(+), 27 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..22da712 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -397,6 +397,25 @@ static inline int khugepaged_test_exit(struct mm_struct *mm)
 	return atomic_read(&mm->mm_users) == 0;
 }
 
+static bool hugepage_vma_check(struct vm_area_struct *vma)
+{
+	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
+	    (vma->vm_flags & VM_NOHUGEPAGE) ||
+	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
+		return false;
+	if (shmem_file(vma->vm_file)) {
+		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
+			return false;
+		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
+				HPAGE_PMD_NR);
+	}
+	if (!vma->anon_vma || vma->vm_ops)
+		return false;
+	if (is_vma_temporary_stack(vma))
+		return false;
+	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
+}
+
 int __khugepaged_enter(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
@@ -434,15 +453,14 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 			       unsigned long vm_flags)
 {
 	unsigned long hstart, hend;
-	if (!vma->anon_vma)
-		/*
-		 * Not yet faulted in so we will register later in the
-		 * page fault if needed.
-		 */
-		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
-		/* khugepaged not yet working on file or special mappings */
+
+	/*
+	 * khugepaged does not yet work on non-shmem files or special
+	 * mappings. And file-private shmem THP is not supported.
+	 */
+	if (!hugepage_vma_check(vma))
 		return 0;
+
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -819,25 +837,6 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 #endif
 
-static bool hugepage_vma_check(struct vm_area_struct *vma)
-{
-	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
-	    (vma->vm_flags & VM_NOHUGEPAGE) ||
-	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
-		return false;
-	if (shmem_file(vma->vm_file)) {
-		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
-			return false;
-		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
-				HPAGE_PMD_NR);
-	}
-	if (!vma->anon_vma || vma->vm_ops)
-		return false;
-	if (is_vma_temporary_stack(vma))
-		return false;
-	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
-}
-
 /*
  * If mmap_sem temporarily dropped, revalidate vma
  * before taking mmap_sem.
-- 
1.8.3.1
