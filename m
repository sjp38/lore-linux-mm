Message-Id: <20081009174822.740252331@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:45 +1100
From: npiggin@suse.de
Subject: [patch 6/8] mm: write_cache_pages cleanups
Content-Disposition: inline; filename=mm-wcp-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Get rid of some complex expressions from flow control statements, add a
comment, remove some duplicate code.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -900,11 +900,14 @@ int write_cache_pages(struct address_spa
 		cycled = 1; /* ignore range_cyclic tests */
 	}
 retry:
-	while (!done && (index <= end) &&
-	       (nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-					      PAGECACHE_TAG_DIRTY,
-					      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1))) {
-		unsigned i;
+	while (!done && (index <= end)) {
+		int i;
+
+		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+			      PAGECACHE_TAG_DIRTY,
+			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		if (nr_pages == 0)
+			break;
 
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
@@ -919,7 +922,16 @@ retry:
 again:
 			lock_page(page);
 
+			/*
+			 * Page truncated or invalidated. We can freely skip it
+			 * then, even for data integrity operations: the page
+			 * has disappeared concurrently, so there could be no
+			 * real expectation of this data interity operation
+			 * even if there is now a new, dirty page at the same
+			 * pagecache address.
+			 */
 			if (unlikely(page->mapping != mapping)) {
+continue_unlock:
 				unlock_page(page);
 				continue;
 			}
@@ -927,18 +939,15 @@ again:
 			if (page->index > end) {
 				/* Can't be range_cyclic: end == -1 there */
 				done = 1;
-				unlock_page(page);
-				continue;
+				goto continue_unlock;
 			}
 
 			if (wbc->sync_mode != WB_SYNC_NONE)
 				wait_on_page_writeback(page);
 
 			if (PageWriteback(page) ||
-			    !clear_page_dirty_for_io(page)) {
-				unlock_page(page);
-				continue;
-			}
+			    !clear_page_dirty_for_io(page))
+				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
@@ -952,7 +961,8 @@ again:
 				break;
 			}
 			if (wbc->sync_mode == WB_SYNC_NONE) {
-				if (--(wbc->nr_to_write) <= 0)
+				wbc->nr_to_write--;
+				if (wbc->nr_to_write <= 0)
 					done = 1;
 			}
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
