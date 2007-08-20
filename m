Message-Id: <20070820215316.287244006@sgi.com>
References: <20070820215040.937296148@sgi.com>
Date: Mon, 20 Aug 2007 14:50:42 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 2/7] Move checks from pageout() to shrink_page_list
Content-Disposition: inline; filename=move_checks_to_shrink_page_list
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

This is necessary because we soon will do other things than calling
pageout() from shrink_page_list().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |   90 ++++++++++++++++++++++++++++++------------------------------
 1 file changed, 45 insertions(+), 45 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-19 21:39:55.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-19 21:47:56.000000000 -0700
@@ -273,8 +273,6 @@ static void handle_write_error(struct ad
 
 /* possible outcome of pageout() */
 typedef enum {
-	/* failed to write page out, page is locked */
-	PAGE_KEEP,
 	/* move page to the active list, page is locked */
 	PAGE_ACTIVATE,
 	/* page has been sent to the disk successfully, page is unlocked */
@@ -289,44 +287,6 @@ typedef enum {
  */
 static pageout_t pageout(struct page *page, struct address_space *mapping)
 {
-	/*
-	 * If the page is dirty, only perform writeback if that write
-	 * will be non-blocking.  To prevent this allocation from being
-	 * stalled by pagecache activity.  But note that there may be
-	 * stalls if we need to run get_block().  We could test
-	 * PagePrivate for that.
-	 *
-	 * If this process is currently in generic_file_write() against
-	 * this page's queue, we can perform writeback even if that
-	 * will block.
-	 *
-	 * If the page is swapcache, write it back even if that would
-	 * block, for some throttling. This happens by accident, because
-	 * swap_backing_dev_info is bust: it doesn't reflect the
-	 * congestion state of the swapdevs.  Easy to fix, if needed.
-	 * See swapfile.c:page_queue_congested().
-	 */
-	if (!is_page_cache_freeable(page))
-		return PAGE_KEEP;
-	if (!mapping) {
-		/*
-		 * Some data journaling orphaned pages can have
-		 * page->mapping == NULL while being dirty with clean buffers.
-		 */
-		if (PagePrivate(page)) {
-			if (try_to_free_buffers(page)) {
-				ClearPageDirty(page);
-				printk("%s: orphaned page\n", __FUNCTION__);
-				return PAGE_CLEAN;
-			}
-		}
-		return PAGE_KEEP;
-	}
-	if (mapping->a_ops->writepage == NULL)
-		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(mapping->backing_dev_info))
-		return PAGE_KEEP;
-
 	if (clear_page_dirty_for_io(page)) {
 		int res;
 		struct writeback_control wbc = {
@@ -504,18 +464,58 @@ static unsigned long shrink_page_list(st
 			if (!sc->may_writepage)
 				goto keep_locked;
 
+			/*
+			 * If the page is dirty, only perform writeback if
+			 * that write will be non-blocking.  To prevent this
+			 * allocation from being stalled by pagecache
+			 * activity.  But note that there may be stalls if
+			 * we need to run get_block().  We could test
+			 * PagePrivate for that.
+			 *
+			 * If this process is currently in
+			 * generic_file_write() against this page's queue,
+			 * we can perform writeback even if that will block.
+			 *
+			 * If the page is swapcache, write it back even if
+			 * that would block, for some throttling. This happens
+			 * by accident, because swap_backing_dev_info is bust:
+			 * it doesn't reflect the congestion state of the
+			 * swapdevs.  Easy to fix, if needed.
+			 * See swapfile.c:page_queue_congested().
+			 */
+			if (!is_page_cache_freeable(page))
+				goto keep_locked;
+			if (!mapping) {
+				/*
+				 * Some data journaling orphaned pages can
+				 * have page->mapping == NULL while being
+				 * dirty with clean buffers.
+				 */
+				if (PagePrivate(page)) {
+					if (try_to_free_buffers(page)) {
+						ClearPageDirty(page);
+						printk("%s: orphaned page\n",
+								__FUNCTION__);
+						goto release_page;
+					}
+				}
+				goto keep_locked;
+			}
+			if (mapping->a_ops->writepage == NULL)
+				goto activate_locked;
+			if (!may_write_to_queue(mapping->backing_dev_info))
+				goto keep_locked;
+
 			/* Page is dirty, try to write it out here */
 			switch(pageout(page, mapping)) {
-			case PAGE_KEEP:
-				goto keep_locked;
 			case PAGE_ACTIVATE:
 				goto activate_locked;
 			case PAGE_SUCCESS:
 				if (PageWriteback(page) || PageDirty(page))
 					goto keep;
 				/*
-				 * A synchronous write - probably a ramdisk.  Go
-				 * ahead and try to reclaim the page.
+				 * A synchronous write - probably a ramdisk.
+				 * Go ahead and try to reclaim the page.
 				 */
 				if (TestSetPageLocked(page))
 					goto keep;
@@ -526,7 +526,7 @@ static unsigned long shrink_page_list(st
 				; /* try to free the page below */
 			}
 		}
-
+release_page:
 		/*
 		 * If the page has buffers, try to free the buffer mappings
 		 * associated with this page. If we succeed we try to free

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
