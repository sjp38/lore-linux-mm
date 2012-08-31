Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9C9D96B007B
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 18:22:15 -0400 (EDT)
From: Lukas Czerner <lczerner@redhat.com>
Subject: [PATCH 06/15 v2] mm: teach truncate_inode_pages_range() to handle non page aligned ranges
Date: Fri, 31 Aug 2012 18:21:42 -0400
Message-Id: <1346451711-1931-7-git-send-email-lczerner@redhat.com>
In-Reply-To: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org, Lukas Czerner <lczerner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

This commit changes truncate_inode_pages_range() so it can handle non
page aligned regions of the truncate. Currently we can hit BUG_ON when
the end of the range is not page aligned, but we can handle unaligned
start of the range.

Being able to handle non page aligned regions of the page can help file
system punch_hole implementations and save some work, because once we're
holding the page we might as well deal with it right away.

In order for this to work correctly, called must register
invalidatepage_range address space operation, or rely solely on the
block_invalidatepage_range. That said it will BUG_ON() if caller
implements invalidatepage(), does not implement invalidatepage_range()
and use truncate_inode_pages_range() with unaligned end of the range.

This was based on the code provided by Hugh Dickins with some small
changes to make use of do_invalidatepage_range().

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/truncate.c |   77 +++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index b22efdf..0db1551 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -81,14 +81,6 @@ void do_invalidatepage_range(struct page *page, unsigned int offset,
 #endif
 }
 
-static inline void truncate_partial_page(struct page *page, unsigned partial)
-{
-	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
-	cleancache_invalidate_page(page->mapping, page);
-	if (page_has_private(page))
-		do_invalidatepage(page, partial);
-}
-
 /*
  * This cancels just the dirty bit on the kernel page itself, it
  * does NOT actually remove dirty bits on any mmap's that may be
@@ -222,8 +214,8 @@ int invalidate_inode_page(struct page *page)
  * @lend: offset to which to truncate
  *
  * Truncate the page cache, removing the pages that are between
- * specified offsets (and zeroing out partial page
- * (if lstart is not page aligned)).
+ * specified offsets (and zeroing out partial pages
+ * if lstart or lend + 1 is not page aligned).
  *
  * Truncate takes two passes - the first pass is nonblocking.  It will not
  * block on page locks and it will not block on writeback.  The second pass
@@ -234,35 +226,44 @@ int invalidate_inode_page(struct page *page)
  * We pass down the cache-hot hint to the page freeing code.  Even if the
  * mapping is large, it is probably the case that the final pages are the most
  * recently touched, and freeing happens in ascending file offset order.
+ *
+ * Note that it is able to handle cases where lend + 1 is not page aligned.
+ * However in order for this to work caller have to register
+ * invalidatepage_range address space operation or rely solely on
+ * block_invalidatepage_range(). That said, do_invalidatepage_range() will
+ * BUG_ON() if caller implements invalidatapage(), does not implement
+ * invalidatepage_range() and uses truncate_inode_pages_range() with lend + 1
+ * unaligned to the page cache size.
  */
 void truncate_inode_pages_range(struct address_space *mapping,
 				loff_t lstart, loff_t lend)
 {
-	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
-	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
+	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
+	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
+	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
 	struct pagevec pvec;
 	pgoff_t index;
-	pgoff_t end;
 	int i;
 
 	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0)
 		return;
 
-	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
-	end = (lend >> PAGE_CACHE_SHIFT);
+	if (lend == -1)
+		end = -1;	/* unsigned, so actually very big */
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	while (index < end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
 			index = page->index;
-			if (index > end)
+			if (index >= end)
 				break;
 
 			if (!trylock_page(page))
@@ -281,27 +282,51 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		index++;
 	}
 
-	if (partial) {
+	if (partial_start) {
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
+			unsigned int top = PAGE_CACHE_SIZE;
+			if (start > end) {
+				top = partial_end;
+				partial_end = 0;
+			}
+			wait_on_page_writeback(page);
+			zero_user_segment(page, partial_start, top);
+			cleancache_invalidate_page(mapping, page);
+			if (page_has_private(page))
+				do_invalidatepage_range(page, partial_start,
+							top - partial_start);
+			unlock_page(page);
+			page_cache_release(page);
+		}
+	}
+	if (partial_end) {
+		struct page *page = find_lock_page(mapping, end);
+		if (page) {
 			wait_on_page_writeback(page);
-			truncate_partial_page(page, partial);
+			zero_user_segment(page, 0, partial_end);
+			cleancache_invalidate_page(mapping, page);
+			if (page_has_private(page))
+				do_invalidatepage_range(page, 0,
+							partial_end);
 			unlock_page(page);
 			page_cache_release(page);
 		}
 	}
+	if (start >= end)
+		return;
 
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
 		if (!pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
 			if (index == start)
 				break;
 			index = start;
 			continue;
 		}
-		if (index == start && pvec.pages[0]->index > end) {
+		if (index == start && pvec.pages[0]->index >= end) {
 			pagevec_release(&pvec);
 			break;
 		}
@@ -311,7 +336,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 			/* We rely upon deletion not changing page->index */
 			index = page->index;
-			if (index > end)
+			if (index >= end)
 				break;
 
 			lock_page(page);
@@ -656,10 +681,8 @@ void truncate_pagecache_range(struct inode *inode, loff_t lstart, loff_t lend)
 	 * This rounding is currently just for example: unmap_mapping_range
 	 * expands its hole outwards, whereas we want it to contract the hole
 	 * inwards.  However, existing callers of truncate_pagecache_range are
-	 * doing their own page rounding first; and truncate_inode_pages_range
-	 * currently BUGs if lend is not pagealigned-1 (it handles partial
-	 * page at start of hole, but not partial page at end of hole).  Note
-	 * unmap_mapping_range allows holelen 0 for all, and we allow lend -1.
+	 * doing their own page rounding first.  Note that unmap_mapping_range
+	 * allows holelen 0 for all, and we allow lend -1 for end of file.
 	 */
 
 	/*
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
