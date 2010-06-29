Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E03026007C2
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:34:59 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 12/14] vmscan: Do not writeback pages in direct reclaim
Date: Tue, 29 Jun 2010 12:34:46 +0100
Message-Id: <1277811288-5195-13-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
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
stall for the background flusher before trying to reclaim the pages again.

Memory control groups do not have a kswapd-like thread nor do pages get
direct reclaimed from the page allocator. Instead, memory control group
pages are reclaimed when the quota is being exceeded or the group is being
shrunk. As it is not expected that the entry points into page reclaim are
deep call chains memcg is still allowed to writeback dirty pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |  158 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 108 insertions(+), 50 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index efa6ee4..d5a2e74 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -323,6 +323,56 @@ typedef enum {
 	PAGE_CLEAN,
 } pageout_t;
 
+int write_reclaim_page(struct page *page, struct address_space *mapping,
+						enum pageout_io sync_writeback)
+{
+	int res;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+		.nr_to_write = SWAP_CLUSTER_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
+		.nonblocking = 1,
+		.for_reclaim = 1,
+	};
+
+	if (!clear_page_dirty_for_io(page))
+		return PAGE_CLEAN;
+
+	SetPageReclaim(page);
+	res = mapping->a_ops->writepage(page, &wbc);
+	if (res < 0)
+		handle_write_error(mapping, page, res);
+	if (res == AOP_WRITEPAGE_ACTIVATE) {
+		ClearPageReclaim(page);
+		return PAGE_ACTIVATE;
+	}
+
+	/*
+	 * Wait on writeback if requested to. This happens when
+	 * direct reclaiming a large contiguous area and the
+	 * first attempt to free a range of pages fails.
+	 */
+	if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
+		wait_on_page_writeback(page);
+
+	if (!PageWriteback(page)) {
+		/* synchronous write or broken a_ops? */
+		ClearPageReclaim(page);
+	}
+	trace_mm_vmscan_writepage(page,
+		sync_writeback == PAGEOUT_IO_SYNC);
+	inc_zone_page_state(page, NR_VMSCAN_WRITE);
+
+	return PAGE_SUCCESS;
+}
+
+/* kswapd and memcg can writeback as they are unlikely to overflow stack */
+static inline bool reclaim_can_writeback(struct scan_control *sc)
+{
+	return current_is_kswapd() || sc->mem_cgroup != NULL;
+}
+
 /*
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
@@ -367,45 +417,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
-		int res;
-		struct writeback_control wbc = {
-			.sync_mode = WB_SYNC_NONE,
-			.nr_to_write = SWAP_CLUSTER_MAX,
-			.range_start = 0,
-			.range_end = LLONG_MAX,
-			.nonblocking = 1,
-			.for_reclaim = 1,
-		};
-
-		SetPageReclaim(page);
-		res = mapping->a_ops->writepage(page, &wbc);
-		if (res < 0)
-			handle_write_error(mapping, page, res);
-		if (res == AOP_WRITEPAGE_ACTIVATE) {
-			ClearPageReclaim(page);
-			return PAGE_ACTIVATE;
-		}
-
-		/*
-		 * Wait on writeback if requested to. This happens when
-		 * direct reclaiming a large contiguous area and the
-		 * first attempt to free a range of pages fails.
-		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
-			wait_on_page_writeback(page);
-
-		if (!PageWriteback(page)) {
-			/* synchronous write or broken a_ops? */
-			ClearPageReclaim(page);
-		}
-		trace_mm_vmscan_writepage(page,
-			sync_writeback == PAGEOUT_IO_SYNC);
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
-		return PAGE_SUCCESS;
-	}
-
-	return PAGE_CLEAN;
+	return write_reclaim_page(page, mapping, sync_writeback);
 }
 
 /*
@@ -638,6 +650,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 	pagevec_free(&freed_pvec);
 }
 
+/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
+#define MAX_SWAP_CLEAN_WAIT 50
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -645,13 +660,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback)
 {
-	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
-	int pgactivate = 0;
+	LIST_HEAD(putback_pages);
+	LIST_HEAD(dirty_pages);
+	int pgactivate;
+	int dirty_isolated = 0;
+	unsigned long nr_dirty;
 	unsigned long nr_reclaimed = 0;
 
+	pgactivate = 0;
 	cond_resched();
 
+restart_dirty:
+	nr_dirty = 0;
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -740,7 +761,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (PageDirty(page)) {
+		if (PageDirty(page))  {
+			/*
+			 * If the caller cannot writeback pages, dirty pages are
+			 * put on a separate list for cleaning by either a flusher
+			 * thread or kswapd
+			 */
+			if (!reclaim_can_writeback(sc) &&
+					dirty_isolated < MAX_SWAP_CLEAN_WAIT) {
+				list_add(&page->lru, &dirty_pages);
+				unlock_page(page);
+				nr_dirty++;
+				goto keep_dirty;
+			}
+
 			if (references == PAGEREF_RECLAIM_CLEAN)
 				goto keep_locked;
 			if (!may_enter_fs)
@@ -851,13 +885,38 @@ activate_locked:
 keep_locked:
 		unlock_page(page);
 keep:
-		list_add(&page->lru, &ret_pages);
+		list_add(&page->lru, &putback_pages);
+keep_dirty:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
+		/*
+		 * Wakeup a flusher thread to clean at least as many dirty
+		 * pages as encountered by direct reclaim. Wait on congestion
+		 * to throttle processes cleaning dirty pages
+		 */
+		wakeup_flusher_threads(nr_dirty);
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+
+		/*
+		 * As lumpy reclaim targets specific pages, wait on them
+		 * to be cleaned and try reclaim again for a time.
+		 */
+		if (sync_writeback == PAGEOUT_IO_SYNC) {
+			dirty_isolated++;
+			list_splice(&dirty_pages, page_list);
+			INIT_LIST_HEAD(&dirty_pages);
+			goto restart_dirty;
+		}
+	}
+
 	free_page_list(&free_pages);
 
-	list_splice(&ret_pages, page_list);
+	if (!list_empty(&dirty_pages))
+		list_splice(&dirty_pages, page_list);
+	list_splice(&putback_pages, page_list);
+
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -1866,10 +1925,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
@@ -1907,7 +1964,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -1936,7 +1993,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
@@ -2588,7 +2645,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
