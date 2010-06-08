Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 11B066B01C8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:02:33 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/6] vmscan: Do not writeback pages in direct reclaim
Date: Tue,  8 Jun 2010 10:02:25 +0100
Message-Id: <1275987745-21708-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When memory is under enough pressure, a process may enter direct
reclaim to free pages in the same manner kswapd does. If a dirty page is
encountered during the scan, this page is written to backing storage using
mapping->writepage. This can result in very deep call stacks, particularly
if the target storage or filesystem are complex. It has already been observed
on XFS that the stack overflows but the problem is not XFS-specific.

This patch prevents direct reclaim writing back pages by not setting
may_writepage in scan_control. Instead, dirty pages are placed back on the
LRU lists for either background writing by the BDI threads or kswapd. If
in direct lumpy reclaim and dirty pages are encountered, the process will
kick the background flushter threads before trying again.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   69 ++++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 50 insertions(+), 19 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b2eb2a6..3565610 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -725,6 +725,9 @@ writeout:
 	list_splice(&ret_pages, page_list);
 }
 
+/* Direct lumpy reclaim waits up to a second for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 10
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -734,10 +737,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 {
 	LIST_HEAD(putback_pages);
 	LIST_HEAD(dirty_pages);
-	struct list_head *ret_list = page_list;
 	struct pagevec freed_pvec;
 	int pgactivate;
-	bool cleaned = false;
+	int cleaned = 0;
+	unsigned long nr_dirty;
 	unsigned long nr_reclaimed = 0;
 
 	pgactivate = 0;
@@ -746,6 +749,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	pagevec_init(&freed_pvec, 1);
 
 restart_dirty:
+	nr_dirty = 0;
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -837,12 +841,17 @@ restart_dirty:
 		if (PageDirty(page))  {
 			/*
 			 * On the first pass, dirty pages are put on a separate
-			 * list. IO is then queued based on ranges of pages for
-			 * each unique mapping in the list
+			 * list. If kswapd, IO is then queued based on ranges of
+			 * pages for each unique mapping in the list. Direct
+			 * reclaimers put the dirty pages back on the list for
+			 * cleaning by kswapd
 			 */
-			if (!cleaned) {
-				/* Keep locked for clean_page_list */
+			if (cleaned < MAX_SWAP_CLEAN_WAIT) {
+				/* Keep locked for kswapd to call clean_page_list */
+				if (!current_is_kswapd())
+					unlock_page(page);
 				list_add(&page->lru, &dirty_pages);
+				nr_dirty++;
 				goto keep_dirty;
 			}
 
@@ -959,15 +968,38 @@ keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
-	if (!cleaned && !list_empty(&dirty_pages)) {
-		clean_page_list(&dirty_pages, sc);
-		page_list = &dirty_pages;
-		cleaned = true;
-		goto restart_dirty;
+	if (cleaned < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
+		/*
+		 * Only kswapd cleans pages. Direct reclaimers entering the filesystem
+		 * potentially splices two expensive call-chains and busts the stack
+		 * so instead they go to sleep to give background cleaning a chance
+		 */
+		list_splice(&dirty_pages, page_list);
+		INIT_LIST_HEAD(&dirty_pages);
+		if (current_is_kswapd()) {
+			cleaned = MAX_SWAP_CLEAN_WAIT;
+			clean_page_list(page_list, sc);
+			goto restart_dirty;
+		} else {
+			cleaned++;
+			/*
+			 * If lumpy reclaiming, kick the background flusher and wait
+			 * for the pages to be cleaned
+			 *
+		 	 * XXX: kswapd won't find these isolated pages but the
+		 	 * 	background flusher does not prioritise pages. It'd
+		 	 * 	be nice to prioritise a list of pages somehow
+		 	 */
+			if (sync_writeback == PAGEOUT_IO_SYNC) {
+				wakeup_flusher_threads(nr_dirty);
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				goto restart_dirty;
+			}
+		}
 	}
-	BUG_ON(!list_empty(&dirty_pages));
 
-	list_splice(&putback_pages, ret_list);
+	list_splice(&dirty_pages, page_list);
+	list_splice(&putback_pages, page_list);
 	if (pagevec_count(&freed_pvec))
 		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -1988,10 +2020,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
-		if (total_scanned > writeback_threshold) {
+		if (total_scanned > writeback_threshold)
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
-			sc->may_writepage = 1;
-		}
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
@@ -2040,7 +2070,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -2069,7 +2099,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
@@ -2743,7 +2773,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
-		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
+		.may_writepage = (current_is_kswapd() &&
+					(zone_reclaim_mode & RECLAIM_WRITE)),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
