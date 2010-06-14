Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2E56B01D9
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:23:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 12/12] vmscan: Do not writeback pages in direct reclaim
Date: Mon, 14 Jun 2010 12:17:53 +0100
Message-Id: <1276514273-27693-13-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
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

Memory control groups do not have a kswapd-like thread nor do pages get
direct reclaimed from the page allocator. Instead, memory control group
pages are reclaimed when the quota is being exceeded or the group is being
shrunk. As it is not expected that the entry points into page reclaim are
deep call chains memcg is still allowed to writeback dirty pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   76 ++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 57 insertions(+), 19 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4856a2a..574e816 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -372,6 +372,12 @@ int write_reclaim_page(struct page *page, struct address_space *mapping,
 	return PAGE_SUCCESS;
 }
 
+/* kswapd and memcg can writeback as they are unlikely to overflow stack */
+static inline bool reclaim_can_writeback(struct scan_control *sc)
+{
+	return current_is_kswapd() || sc->mem_cgroup != NULL;
+}
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
@@ -701,6 +707,9 @@ static noinline_for_stack void clean_page_list(struct list_head *page_list,
 	list_splice(&ret_pages, page_list);
 }
 
+/* Direct lumpy reclaim waits up to a second for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 10
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -711,15 +720,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	LIST_HEAD(free_pages);
 	LIST_HEAD(putback_pages);
 	LIST_HEAD(dirty_pages);
-	struct list_head *ret_list = page_list;
 	int pgactivate;
-	bool cleaned = false;
+	int cleaned = 0;
+	unsigned long nr_dirty;
 	unsigned long nr_reclaimed = 0;
 
 	pgactivate = 0;
 	cond_resched();
 
 restart_dirty:
+	nr_dirty = 0;
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -811,12 +821,17 @@ restart_dirty:
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
+				if (!reclaim_can_writeback(sc))
+					unlock_page(page);
 				list_add(&page->lru, &dirty_pages);
+				nr_dirty++;
 				goto keep_dirty;
 			}
 
@@ -935,17 +950,41 @@ keep_dirty:
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
+		if (reclaim_can_writeback(sc)) {
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
 
 	free_page_list(&free_pages);
 
-	list_splice(&putback_pages, ret_list);
+	list_splice(&dirty_pages, page_list);
+	list_splice(&putback_pages, page_list);
+
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1954,10 +1993,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
@@ -1995,7 +2032,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -2024,7 +2061,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
@@ -2676,7 +2713,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
