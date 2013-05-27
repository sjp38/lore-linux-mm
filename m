Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D67246B00FE
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:03:06 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: vmscan: Stall page reclaim after a list of pages have been processed
Date: Mon, 27 May 2013 14:02:57 +0100
Message-Id: <1369659778-6772-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1369659778-6772-1-git-send-email-mgorman@suse.de>
References: <1369659778-6772-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Commit "mm: vmscan: Block kswapd if it is encountering pages under
writeback" blocks page reclaim if it encounters pages under writeback
marked for immediate reclaim. It blocks while pages are still isolated
from the LRU which is necessary. This patch defers the blocking until
after the isolated pages have been processed.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index be8e445..f576bcc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -699,6 +699,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_unqueued_dirty,
 				      unsigned long *ret_nr_writeback,
+				      unsigned long *ret_nr_immediate,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
@@ -709,6 +710,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_immediate = 0;
 
 	cond_resched();
 
@@ -770,8 +772,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 *    IO can complete. Waiting on the page itself risks an
 		 *    indefinite stall if it is impossible to writeback the
 		 *    page due to IO error or disconnected storage so instead
-		 *    block for HZ/10 or until some IO completes then clear the
-		 *    ZONE_WRITEBACK flag to recheck if the condition exists.
+		 *    note that the LRU is being scanned too quickly and the
+		 *    caller can stall after page list has been processed.
 		 *
 		 * 2) Global reclaim encounters a page, memcg encounters a
 		 *    page that is not marked for immediate reclaim or
@@ -801,10 +803,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
 			    zone_is_reclaim_writeback(zone)) {
-				unlock_page(page);
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
-				zone_clear_flag(zone, ZONE_WRITEBACK);
-				goto keep;
+				nr_immediate++;
+				goto keep_locked;
 
 			/* Case 2 above */
 			} else if (global_reclaim(sc) ||
@@ -1030,6 +1030,7 @@ keep:
 	mem_cgroup_uncharge_end();
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
 	*ret_nr_writeback += nr_writeback;
+	*ret_nr_immediate += nr_immediate;
 	return nr_reclaimed;
 }
 
@@ -1041,7 +1042,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2;
+	unsigned long ret, dummy1, dummy2, dummy3;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1054,7 +1055,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 				TTU_UNMAP|TTU_IGNORE_ACCESS,
-				&dummy1, &dummy2, true);
+				&dummy1, &dummy2, &dummy3, true);
 	list_splice(&clean_pages, page_list);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1350,6 +1351,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_taken;
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = lruvec_zone(lruvec);
@@ -1391,7 +1393,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-				&nr_unqueued_dirty, &nr_writeback, false);
+			&nr_unqueued_dirty, &nr_writeback, &nr_immediate, false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1444,14 +1446,21 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	}
 
 	/*
-	 * Similarly, if many dirty pages are encountered that are not
-	 * currently being written then flag that kswapd should start
-	 * writing back pages and stall to give a chance for flushers
-	 * to catch up.
+	 * Similarly, if pages marked for immediate reclaim and under writeback
+	 * are encountered it implies that pages are cycling through the LRU
+	 * faster than they can be written. If dirty pages are encountered that
+	 * are not queued for IO, it implies that flushers are not keeping up.
+	 * In this case, be more aggressive about stalling and start writing
+	 * pages from reclaim context if necessary.
 	 */
-	if (global_reclaim(sc) && nr_unqueued_dirty == nr_taken) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
-		zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+	if (global_reclaim(sc)) {
+		if (nr_unqueued_dirty == nr_taken || nr_immediate) {
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+			zone_clear_flag(zone, ZONE_WRITEBACK);
+		}
+
+		if (nr_unqueued_dirty == nr_taken)
+			zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
 	}
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
