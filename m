Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F1EA56B0032
	for <linux-mm@kvack.org>; Thu, 23 May 2013 05:26:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] mm: vmscan: mm: vmscan: Have kswapd writeback pages based on dirty pages encountered, not priority -fix
Date: Thu, 23 May 2013 10:26:26 +0100
Message-Id: <1369301187-24934-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1369301187-24934-1-git-send-email-mgorman@suse.de>
References: <1369301187-24934-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If a zone is marked "reclaim dirty" then kswapd starts writing back pages
but this situation is flagged too easily and flushers are not given the
opportunity to catch up. This patch causes kswapd to only start writing back
pages if all dirty pages scanned at the tail of the LRU are unqueued. If
a zone is flagged as "reclaim dirty", the reclaiming process will stall
to give flushers a chance to clean up. It also renames nr_dirty to
nr_unqueued dirty in shrink_inactive_list() to clarify.

This could be treated as a fix to the patch
mm-vmscan-have-kswapd-writeback-pages-based-on-dirty-pages-encountered-not-priority.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b1b38ad..f3315c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1316,7 +1316,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
+	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
@@ -1359,7 +1359,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-					&nr_dirty, &nr_writeback, false);
+				&nr_unqueued_dirty, &nr_writeback, false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1414,11 +1414,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	/*
 	 * Similarly, if many dirty pages are encountered that are not
 	 * currently being written then flag that kswapd should start
-	 * writing back pages.
+	 * writing back pages and stall to give a chance for flushers
+	 * to catch up.
 	 */
-	if (global_reclaim(sc) && nr_dirty &&
-			nr_dirty >= (nr_taken >> (DEF_PRIORITY - sc->priority)))
+	if (global_reclaim(sc) && nr_unqueued_dirty == nr_taken) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 		zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+	}
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
