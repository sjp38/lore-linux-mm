Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id CF59E6B0095
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:43 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 38/39] thp: vma_adjust_trans_huge(): adjust file-backed VMA too
Date: Sun, 12 May 2013 04:23:35 +0300
Message-Id: <1368321816-17719-39-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Since we're going to have huge pages in page cache, we need to call
adjust file-backed VMA, which potentially can contain huge pages.

For now we call it for all VMAs.

Probably later we will need to introduce a flag to indicate that the VMA
has huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |   11 +----------
 mm/huge_memory.c        |    2 +-
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b20334a..f4d6626 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -139,7 +139,7 @@ extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
-extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
+extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
@@ -155,15 +155,6 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
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
index d7c9df5..9c3815b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2783,7 +2783,7 @@ static void split_huge_page_address(struct mm_struct *mm,
 	split_huge_page_pmd_mm(mm, address, pmd);
 }
 
-void __vma_adjust_trans_huge(struct vm_area_struct *vma,
+void vma_adjust_trans_huge(struct vm_area_struct *vma,
 			     unsigned long start,
 			     unsigned long end,
 			     long adjust_next)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
