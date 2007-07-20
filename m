From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070720194140.16126.75148.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070720194120.16126.56046.sendpatchset@skynet.skynet.ie>
References: <20070720194120.16126.56046.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/1] Wait for page writeback when directly reclaiming contiguous areas
Date: Fri, 20 Jul 2007 20:41:33 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 vmscan.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d419e10..6531f49 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -287,7 +287,8 @@ typedef enum {
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping,
+						int sync_writeback)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -346,6 +347,15 @@ static pageout_t pageout(struct page *page, struct address_space *mapping)
 			ClearPageReclaim(page);
 			return PAGE_ACTIVATE;
 		}
+
+		/*
+		 * Wait on writeback if requested to. This happens when
+		 * direct reclaiming a large contiguous area and the
+		 * first attempt to free a ranage of pages fails
+		 */
+		if (PageWriteback(page) && sync_writeback != WB_SYNC_NONE)
+			wait_on_page_writeback(page);
+
 		if (!PageWriteback(page)) {
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
@@ -423,7 +433,8 @@ cannot_free:
  * shrink_page_list() returns the number of reclaimed pages
  */
 static unsigned long shrink_page_list(struct list_head *page_list,
-					struct scan_control *sc)
+					struct scan_control *sc,
+					int sync_writeback)
 {
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
@@ -458,8 +469,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
-		if (PageWriteback(page))
-			goto keep_locked;
+		if (PageWriteback(page)) {
+			if (sync_writeback)
+				wait_on_page_writeback(page);
+			else
+				goto keep_locked;
+		}
 
 		referenced = page_referenced(page, 1);
 		/* In active use or really unfreeable?  Activate it. */
@@ -505,7 +520,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch(pageout(page, mapping)) {
+			switch(pageout(page, mapping, sync_writeback)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
@@ -770,6 +785,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 		unsigned long nr_active;
+		int retries = 0;
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 			     &zone->inactive_list,
@@ -784,8 +800,33 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
+		/* Retry shrink list up to 5 times for costly allocations */
+		if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+			retries = 5;
+
 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc);
+		nr_freed = shrink_page_list(&page_list, sc, WB_SYNC_NONE);
+
+		/*
+		 * If we are direct reclaiming for contiguous pages and we do
+		 * not reclaim everything in the list, try again and wait
+		 * for IO to complete. This will stall high-order allocations
+		 * but that should be acceptable to the caller
+		 */
+		while (nr_freed < nr_taken && !current_is_kswapd() && retries) {
+			retries--;
+			congestion_wait(WRITE, HZ/10);
+
+			/* Reclear active flags */
+			nr_active = clear_active_flags(&page_list);
+			if (nr_active)
+				mod_zone_page_state(zone, NR_ACTIVE,
+								-nr_active);
+
+			nr_freed += shrink_page_list(&page_list, sc,
+								WB_SYNC_ALL);
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
