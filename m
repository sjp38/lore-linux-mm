Message-Id: <20081009174822.952978460@suse.de>
References: <20081009155039.139856823@suse.de>
Date: Fri, 10 Oct 2008 02:50:47 +1100
From: npiggin@suse.de
Subject: [patch 8/8] mm: write_cache_pages terminate quickly
Content-Disposition: inline; filename=mm-wcp-terminate-quickly.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Terminate the write_cache_pages loop upon encountering the first page past
end, without locking the page. Pages cannot have their index change when we
have a reference on them (truncate, eg truncate_inode_pages_range performs
the same check without the page lock).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -913,12 +913,18 @@ retry:
 			struct page *page = pvec.pages[i];
 
 			/*
-			 * At this point we hold neither mapping->tree_lock nor
-			 * lock on the page itself: the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or even
-			 * swizzled back from swapper_space to tmpfs file
-			 * mapping
+			 * At this point, the page may be truncated or
+			 * invalidated (changing page->mapping to NULL), or
+			 * even swizzled back from swapper_space to tmpfs file
+			 * mapping. However, page->index will not change
+			 * because we have a reference on the page.
 			 */
+			if (page->index > end) {
+				/* Can't be range_cyclic: end == -1 there */
+				done = 1;
+				break;
+			}
+
 again:
 			lock_page(page);
 
@@ -936,12 +942,6 @@ continue_unlock:
 				continue;
 			}
 
-			if (page->index > end) {
-				/* Can't be range_cyclic: end == -1 there */
-				done = 1;
-				goto continue_unlock;
-			}
-
 			if (!PageDirty(page)) {
 				/* someone wrote it for us */
 				goto continue_unlock;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
