Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 126CD6B0009
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 02:17:22 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kl14so492504pab.4
        for <linux-mm@kvack.org>; Sun, 03 Feb 2013 23:17:21 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 3/3] mm: accelerate munlock() treatment of THP pages
Date: Sun,  3 Feb 2013 23:17:12 -0800
Message-Id: <1359962232-20811-4-git-send-email-walken@google.com>
In-Reply-To: <1359962232-20811-1-git-send-email-walken@google.com>
References: <1359962232-20811-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

munlock_vma_pages_range() was always incrementing addresses by PAGE_SIZE
at a time. When munlocking THP pages (or the huge zero page), this resulted
in taking the mm->page_table_lock 512 times in a row.

We can do better by making use of the page_mask returned by follow_page_mask
(for the huge zero page case), or the size of the page munlock_vma_page()
operated on (for the true THP page case).

Note - I am sending this as RFC only for now as I can't currently put
my finger on what if anything prevents split_huge_page() from operating
concurrently on the same page as munlock_vma_page(), which would mess
up our NR_MLOCK statistics. Is this a latent bug or is there a subtle
point I missed here ?

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/internal.h |  2 +-
 mm/mlock.c    | 32 +++++++++++++++++++++-----------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 1c0c4cc0fcf7..8562de0a5197 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -195,7 +195,7 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
  * must be called with vma's mmap_sem held for read or write, and page locked.
  */
 extern void mlock_vma_page(struct page *page);
-extern void munlock_vma_page(struct page *page);
+extern unsigned int munlock_vma_page(struct page *page);
 
 /*
  * Clear the page's PageMlocked().  This can be useful in a situation where
diff --git a/mm/mlock.c b/mm/mlock.c
index 6baaf4b0e591..486702edee35 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -102,13 +102,14 @@ void mlock_vma_page(struct page *page)
  * can't isolate the page, we leave it for putback_lru_page() and vmscan
  * [page_referenced()/try_to_unmap()] to deal with.
  */
-void munlock_vma_page(struct page *page)
+unsigned int munlock_vma_page(struct page *page)
 {
+	unsigned int nr_pages = hpage_nr_pages(page);
+
 	BUG_ON(!PageLocked(page));
 
 	if (TestClearPageMlocked(page)) {
-		mod_zone_page_state(page_zone(page), NR_MLOCK,
-				    -hpage_nr_pages(page));
+		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		if (!isolate_lru_page(page)) {
 			int ret = SWAP_AGAIN;
 
@@ -141,6 +142,8 @@ void munlock_vma_page(struct page *page)
 				count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 		}
 	}
+
+	return nr_pages;
 }
 
 /**
@@ -159,7 +162,6 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long addr = start;
 	unsigned long nr_pages = (end - start) / PAGE_SIZE;
 	int gup_flags;
 
@@ -185,7 +187,7 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
 		gup_flags |= FOLL_FORCE;
 
-	return __get_user_pages(current, mm, addr, nr_pages, gup_flags,
+	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
 				NULL, NULL, nonblocking);
 }
 
@@ -222,13 +224,12 @@ static int __mlock_posix_error_return(long retval)
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
-	unsigned long addr;
-
-	lru_add_drain();
 	vma->vm_flags &= ~VM_LOCKED;
 
-	for (addr = start; addr < end; addr += PAGE_SIZE) {
+	while (start < end) {
 		struct page *page;
+		unsigned int page_mask, page_increm;
+
 		/*
 		 * Although FOLL_DUMP is intended for get_dump_page(),
 		 * it just so happens that its special treatment of the
@@ -236,13 +237,22 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		 * suits munlock very well (and if somehow an abnormal page
 		 * has sneaked into the range, we won't oops here: great).
 		 */
-		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
+		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
+					&page_mask);
 		if (page && !IS_ERR(page)) {
 			lock_page(page);
-			munlock_vma_page(page);
+			lru_add_drain();
+			/*
+			 * Any THP page found by follow_page_mask() may have
+			 * gotten split before reaching munlock_vma_page(),
+			 * so we need to recompute the page_mask here.
+			 */
+			page_mask = munlock_vma_page(page);
 			unlock_page(page);
 			put_page(page);
 		}
+		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+		start += page_increm * PAGE_SIZE;
 		cond_resched();
 	}
 }
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
