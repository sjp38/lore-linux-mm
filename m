Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 281C96B014B
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:17:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/8] mm: vmscan: Stall page reclaim after a list of pages have been processed
Date: Thu, 30 May 2013 00:17:32 +0100
Message-Id: <1369869457-22570-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1369869457-22570-1-git-send-email-mgorman@suse.de>
References: <1369869457-22570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Commit "mm: vmscan: Block kswapd if it is encountering pages under writeback"
blocks page reclaim if it encounters pages under writeback marked for
immediate reclaim. It blocks while pages are still isolated from the
LRU which is unnecessary. This patch defers the blocking until after the
isolated pages have been processed and tidies up some of the comments.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 49 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 16 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 999ef0b..5b1a79c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -697,6 +697,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      enum ttu_flags ttu_flags,
 				      unsigned long *ret_nr_unqueued_dirty,
 				      unsigned long *ret_nr_writeback,
+				      unsigned long *ret_nr_immediate,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
@@ -707,6 +708,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_immediate = 0;
 
 	cond_resched();
 
@@ -773,8 +775,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -804,10 +806,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -1033,6 +1033,7 @@ keep:
 	mem_cgroup_uncharge_end();
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
 	*ret_nr_writeback += nr_writeback;
+	*ret_nr_immediate += nr_immediate;
 	return nr_reclaimed;
 }
 
@@ -1044,7 +1045,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2;
+	unsigned long ret, dummy1, dummy2, dummy3;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1057,7 +1058,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 				TTU_UNMAP|TTU_IGNORE_ACCESS,
-				&dummy1, &dummy2, true);
+				&dummy1, &dummy2, &dummy3, true);
 	list_splice(&clean_pages, page_list);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1353,6 +1354,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_taken;
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
+	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = lruvec_zone(lruvec);
@@ -1394,7 +1396,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-				&nr_unqueued_dirty, &nr_writeback, false);
+			&nr_unqueued_dirty, &nr_writeback, &nr_immediate,
+			false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1447,14 +1450,28 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	}
 
 	/*
-	 * Similarly, if many dirty pages are encountered that are not
-	 * currently being written then flag that kswapd should start
-	 * writing back pages and stall to give a chance for flushers
-	 * to catch up.
+	 * memcg will stall in page writeback so only consider forcibly
+	 * stalling for global reclaim
 	 */
-	if (global_reclaim(sc) && nr_unqueued_dirty == nr_taken) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
-		zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+	if (global_reclaim(sc)) {
+		/*
+		 * If dirty pages are scanned that are not queued for IO, it
+		 * implies that flushers are not keeping up. In this case, flag
+		 * the zone ZONE_TAIL_LRU_DIRTY and kswapd will start writing
+		 * pages from reclaim context. It will forcibly stall in the
+		 * next check.
+		 */
+		if (nr_unqueued_dirty == nr_taken)
+			zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
+
+		/*
+		 * In addition, if kswapd scans pages marked marked for
+		 * immediate reclaim and under writeback (nr_immediate), it
+		 * implies that pages are cycling through the LRU faster than
+		 * they are written so also forcibly stall.
+		 */
+		if (nr_unqueued_dirty == nr_taken || nr_immediate)
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
