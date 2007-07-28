From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] Wait for page writeback when directly reclaiming contiguous areas
References: <exportbomb.1185662485@pinky>
Message-ID: <ffcc80382e464d7a11a5194e1d327e96@pinky>
Date: Sat, 28 Jul 2007 23:52:30 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>

Lumpy reclaim works by selecting a lead page from the LRU list and then
selecting pages for reclaim from the order-aligned area of pages. In the
situation were all pages in that region are inactive and not referenced by
any process over time, it works well.

In the situation where there is even light load on the system, the pages may
not free quickly. Out of a area of 1024 pages, maybe only 950 of them are
freed when the allocation attempt occurs because lumpy reclaim returned early.
This patch alters the behaviour of direct reclaim for large contiguous blocks.

The first attempt to call shrink_page_list() is asynchronous but if it
fails, the pages are submitted a second time and the calling process waits
for the IO to complete. It'll retry up to 5 times for the pages to be
fully freed. This may stall allocators waiting for contiguous memory but
that should be expected behaviour for high-order users. It is preferable
behaviour to potentially queueing unnecessary areas for IO. Note that kswapd
will not stall in this fashion.

[apw@shadowen.org: update to version 2]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Changelog:

Changes in V2:
 - remove retry loop
 - fix up active accounting (count deactivate events correctly)
 - use our own sync/async flag type
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99ec7fa..1c21714 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -271,6 +271,12 @@ static void handle_write_error(struct address_space *mapping,
 	unlock_page(page);
 }
 
+/* Request for sync pageout. */
+typedef enum {
+	PAGEOUT_IO_ASYNC,
+	PAGEOUT_IO_SYNC,
+} pageout_io_t;
+
 /* possible outcome of pageout() */
 typedef enum {
 	/* failed to write page out, page is locked */
@@ -287,7 +293,8 @@ typedef enum {
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping,
+						pageout_io_t sync_writeback)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -346,6 +353,15 @@ static pageout_t pageout(struct page *page, struct address_space *mapping)
 			ClearPageReclaim(page);
 			return PAGE_ACTIVATE;
 		}
+
+		/*
+		 * Wait on writeback if requested to. This happens when
+		 * direct reclaiming a large contiguous area and the
+		 * first attempt to free a ranage of pages fails
+		 */
+		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+			wait_on_page_writeback(page);
+
 		if (!PageWriteback(page)) {
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
@@ -423,7 +439,8 @@ cannot_free:
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-					struct scan_control *sc)
+					struct scan_control *sc,
+					pageout_io_t sync_writeback)
 {
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
@@ -458,8 +475,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		if (PageWriteback(page))
-			goto keep_locked;
+		if (PageWriteback(page)) {
+			if (sync_writeback == PAGEOUT_IO_SYNC)
+				wait_on_page_writeback(page);
+			else
+				goto keep_locked;
+		}
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
@@ -505,7 +526,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch(pageout(page, mapping)) {
+			switch (pageout(page, mapping, sync_writeback)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
@@ -786,7 +807,29 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc);
+		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+
+		/*
+		 * If we are direct reclaiming for contiguous pages and we do
+		 * not reclaim everything in the list, try again and wait
+		 * for IO to complete. This will stall high-order allocations
+		 * but that should be acceptable to the caller
+		 */
+		if (nr_freed < nr_taken && !current_is_kswapd() &&
+					sc->order > PAGE_ALLOC_COSTLY_ORDER) {
+			congestion_wait(WRITE, HZ/10);
+
+			/*
+			 * The attempt at page out may have made some
+			 * of the pages active, mark them inactive again.
+			 */
+			nr_active = clear_active_flags(&page_list);
+			count_vm_events(PGDEACTIVATE, nr_active);
+
+			nr_freed += shrink_page_list(&page_list, sc,
+							PAGEOUT_IO_SYNC);
+		}
+
 		nr_reclaimed += nr_freed;
 		local_irq_disable();
 		if (current_is_kswapd()) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
