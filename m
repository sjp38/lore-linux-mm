Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C41DC90013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:47:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/7] mm: vmscan: Throttle reclaim if encountering too many dirty pages under writeback
Date: Wed, 10 Aug 2011 11:47:19 +0100
Message-Id: <1312973240-32576-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1312973240-32576-1-git-send-email-mgorman@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

Workloads that are allocating frequently and writing files place a
large number of dirty pages on the LRU. With use-once logic, it is
possible for them to reach the end of the LRU quickly requiring the
reclaimer to scan more to find clean pages. Ordinarily, processes that
are dirtying memory will get throttled by dirty balancing but this
is a global heuristic and does not take into account that LRUs are
maintained on a per-zone basis. This can lead to a situation whereby
reclaim is scanning heavily, skipping over a large number of pages
under writeback and recycling them around the LRU consuming CPU.

This patch checks how many of the number of pages isolated from the
LRU were dirty and under writeback. If a percentage of them under
writeback, the process will be throttled if a backing device or the
zone is congested. Note that this applies whether it is anonymous or
file-backed pages that are under writeback meaning that swapping is
potentially throttled. This is intentional due to the fact if the
swap device is congested, scanning more pages and dispatching more
IO is not going to help matters.

The percentage that must be in writeback depends on the priority. At
default priority, all of them must be dirty. At DEF_PRIORITY-1, 50%
of them must be, DEF_PRIORITY-2, 25% etc. i.e. as pressure increases
the greater the likelihood the process will get throttled to allow
the flusher threads to make some progress.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/vmscan.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d7c696..b0437f2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -711,7 +711,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
-				      int priority)
+				      int priority,
+				      unsigned long *ret_nr_dirty,
+				      unsigned long *ret_nr_writeback)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -719,6 +721,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long nr_writeback = 0;
 
 	cond_resched();
 
@@ -755,6 +758,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page)) {
+			nr_writeback++;
 			/*
 			 * Synchronous reclaim cannot queue pages for
 			 * writeback due to the possibility of stack overflow
@@ -960,6 +964,8 @@ keep_lumpy:
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
+	*ret_nr_dirty += nr_dirty;
+	*ret_nr_writeback += nr_writeback;
 	return nr_reclaimed;
 }
 
@@ -1409,6 +1415,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty = 0;
+	unsigned long nr_writeback = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1457,12 +1465,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, priority);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc, priority,
+						&nr_dirty, &nr_writeback);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, zone, sc, priority);
+		nr_reclaimed += shrink_page_list(&page_list, zone, sc,
+					priority, &nr_dirty, &nr_writeback);
 	}
 
 	local_irq_disable();
@@ -1472,6 +1482,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
+	/*
+	 * If we have encountered a high number of dirty pages under writeback
+	 * then we are reaching the end of the LRU too quickly and global
+	 * limits are not enough to throttle processes due to the page
+	 * distribution throughout zones. Scale the number of dirty pages that
+	 * must be under writeback before being throttled to priority.
+	 */
+	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
+		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
