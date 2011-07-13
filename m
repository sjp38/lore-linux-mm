Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0953E9000C2
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 10:31:35 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mm: vmscan: Throttle reclaim if encountering too many dirty pages under writeback
Date: Wed, 13 Jul 2011 15:31:25 +0100
Message-Id: <1310567487-15367-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1310567487-15367-1-git-send-email-mgorman@suse.de>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
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
LRU were dirty. If a percentage of them are dirty, the process will be
throttled if a blocking device is congested or the zone being scanned
is marked congested. The percentage that must be dirty depends on
the priority. At default priority, all of them must be dirty. At
DEF_PRIORITY-1, 50% of them must be dirty, DEF_PRIORITY-2, 25%
etc. i.e.  as pressure increases the greater the likelihood the process
will get throttled to allow the flusher threads to make some progress.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    1 +
 mm/vmscan.c            |   23 ++++++++++++++++++++---
 mm/vmstat.c            |    1 +
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b70a0c0..c4508a2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -101,6 +101,7 @@ enum zone_stat_item {
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_WRITE_SKIP,
+	NR_VMSCAN_THROTTLED,
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e272951..9826086 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -720,7 +720,8 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
-				      int priority)
+				      int priority,
+				      unsigned long *ret_nr_dirty)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
@@ -971,6 +972,7 @@ keep_lumpy:
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
+	*ret_nr_dirty += nr_dirty;
 	return nr_reclaimed;
 }
 
@@ -1420,6 +1422,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	unsigned long nr_dirty = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1468,12 +1471,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	spin_unlock_irq(&zone->lru_lock);
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, priority);
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
+							priority, &nr_dirty);
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
 		set_reclaim_mode(priority, sc, true);
-		nr_reclaimed += shrink_page_list(&page_list, zone, sc, priority);
+		nr_reclaimed += shrink_page_list(&page_list, zone, sc,
+							priority, &nr_dirty);
 	}
 
 	local_irq_disable();
@@ -1483,6 +1488,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
+	/*
+	 * If we have encountered a high number of dirty pages then they
+	 * are reaching the end of the LRU too quickly and global limits are
+	 * not enough to throttle processes due to the page distribution
+	 * throughout zones. Scale the number of dirty pages that must be
+	 * dirty before being throttled to priority.
+	 */
+	if (nr_dirty && nr_dirty >= (nr_taken >> (DEF_PRIORITY-priority))) {
+		inc_zone_state(zone, NR_VMSCAN_THROTTLED);
+		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+	}
+
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd109f3..59ee17c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -703,6 +703,7 @@ const char * const vmstat_text[] = {
 	"nr_bounce",
 	"nr_vmscan_write",
 	"nr_vmscan_write_skip",
+	"nr_vmscan_throttled",
 	"nr_writeback_temp",
 	"nr_isolated_anon",
 	"nr_isolated_file",
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
