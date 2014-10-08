Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA306B0085
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:51 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so6873309pdj.40
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id so2si18193516pab.132.2014.10.08.06.25.48
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:49 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 1/7] thp: vma_adjust_trans_huge(): adjust file-backed VMA too
Date: Wed,  8 Oct 2014 09:25:23 -0400
Message-Id: <1412774729-23956-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, willy@linux.intel.com

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Since we're going to have huge pages in page cache, we need to call
adjust file-backed VMA, which potentially can contain huge pages.

For now we call it for all VMAs.

Probably later we will need to introduce a flag to indicate that the VMA
has huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 include/linux/huge_mm.h | 11 +----------
 mm/huge_memory.c        |  2 +-
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 63579cb..c4e050d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -122,7 +122,7 @@ extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
-extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
+extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
@@ -138,15 +138,6 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 	else
 		return 0;
 }
-static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
-					 unsigned long start,
-					 unsigned long end,
-					 long adjust_next)
-{
-	if (!vma->anon_vma || vma->vm_ops)
-		return;
-	__vma_adjust_trans_huge(vma, start, end, adjust_next);
-}
 static inline int hpage_nr_pages(struct page *page)
 {
 	if (unlikely(PageTransHuge(page)))
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d9a21d06..2a56ddd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2940,7 +2940,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 	split_huge_page_pmd_mm(mm, address, pmd);
 }
 
-void __vma_adjust_trans_huge(struct vm_area_struct *vma,
+void vma_adjust_trans_huge(struct vm_area_struct *vma,
 			     unsigned long start,
 			     unsigned long end,
 			     long adjust_next)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
