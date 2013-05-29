Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B894A6B010B
	for <linux-mm@kvack.org>; Wed, 29 May 2013 19:17:47 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/8] mm: vmscan: Move direct reclaim wait_iff_congested into shrink_list
Date: Thu, 30 May 2013 00:17:34 +0100
Message-Id: <1369869457-22570-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1369869457-22570-1-git-send-email-mgorman@suse.de>
References: <1369869457-22570-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

shrink_inactive_list makes decisions on whether to stall based on the
number of dirty pages encountered. The wait_iff_congested() call in
shrink_page_list does no such thing and it's arbitrary.

This patch moves the decision on whether to set ZONE_CONGESTED and the
wait_iff_congested call into shrink_page_list. This keeps all the
decisions on whether to stall or not in the one place.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 62 ++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5f80d01..4898daf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -695,7 +695,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
+				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_unqueued_dirty,
+				      unsigned long *ret_nr_congested,
 				      unsigned long *ret_nr_writeback,
 				      unsigned long *ret_nr_immediate,
 				      bool force_reclaim)
@@ -1017,20 +1019,13 @@ keep:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
-	/*
-	 * Tag a zone as congested if all the dirty pages encountered were
-	 * backed by a congested BDI. In this case, reclaimers should just
-	 * back off and wait for congestion to clear because further reclaim
-	 * will encounter the same problem
-	 */
-	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
-		zone_set_flag(zone, ZONE_CONGESTED);
-
 	free_hot_cold_page_list(&free_pages, 1);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 	mem_cgroup_uncharge_end();
+	*ret_nr_dirty += nr_dirty;
+	*ret_nr_congested += nr_congested;
 	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
 	*ret_nr_writeback += nr_writeback;
 	*ret_nr_immediate += nr_immediate;
@@ -1045,7 +1040,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3;
+	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1057,8 +1052,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
-				TTU_UNMAP|TTU_IGNORE_ACCESS,
-				&dummy1, &dummy2, &dummy3, true);
+			TTU_UNMAP|TTU_IGNORE_ACCESS,
+			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
 	list_splice(&clean_pages, page_list);
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1352,6 +1347,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
+	unsigned long nr_dirty = 0;
+	unsigned long nr_congested = 0;
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
@@ -1396,8 +1393,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-			&nr_unqueued_dirty, &nr_writeback, &nr_immediate,
-			false);
+				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
+				&nr_writeback, &nr_immediate,
+				false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1431,7 +1429,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * same way balance_dirty_pages() manages.
 	 *
 	 * This scales the number of dirty pages that must be under writeback
-	 * before throttling depending on priority. It is a simple backoff
+	 * before a zone gets flagged ZONE_WRITEBACK. It is a simple backoff
 	 * function that has the most effect in the range DEF_PRIORITY to
 	 * DEF_PRIORITY-2 which is the priority reclaim is considered to be
 	 * in trouble and reclaim is considered to be in trouble.
@@ -1442,12 +1440,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * ...
 	 * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
 	 *                     isolated page is PageWriteback
+	 *
+	 * Once a zone is flagged ZONE_WRITEBACK, kswapd will count the number
+	 * of pages under pages flagged for immediate reclaim and stall if any
+	 * are encountered in the nr_immediate check below.
 	 */
 	if (nr_writeback && nr_writeback >=
-			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
+			(nr_taken >> (DEF_PRIORITY - sc->priority)))
 		zone_set_flag(zone, ZONE_WRITEBACK);
-		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
-	}
 
 	/*
 	 * memcg will stall in page writeback so only consider forcibly
@@ -1455,6 +1455,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 */
 	if (global_reclaim(sc)) {
 		/*
+		 * Tag a zone as congested if all the dirty pages scanned were
+		 * backed by a congested BDI and wait_iff_congested will stall.
+		 */
+		if (nr_dirty && nr_dirty == nr_congested)
+			zone_set_flag(zone, ZONE_CONGESTED);
+
+		/*
 		 * If dirty pages are scanned that are not queued for IO, it
 		 * implies that flushers are not keeping up. In this case, flag
 		 * the zone ZONE_TAIL_LRU_DIRTY and kswapd will start writing
@@ -1474,6 +1481,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
+	/*
+	 * Stall direct reclaim for IO completions if underlying BDIs or zone
+	 * is congested. Allow kswapd to continue until it starts encountering
+	 * unqueued dirty pages or cycling through the LRU too quickly.
+	 */
+	if (!sc->hibernation_mode && !current_is_kswapd())
+		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
@@ -2374,17 +2389,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 						WB_REASON_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
-
-		/* Take a nap, wait for some writeback to complete */
-		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    sc->priority < DEF_PRIORITY - 2) {
-			struct zone *preferred_zone;
-
-			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
-						&cpuset_current_mems_allowed,
-						&preferred_zone);
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
-		}
 	} while (--sc->priority >= 0);
 
 out:
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
