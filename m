Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D97FA6B026A
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:19:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so83063905wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:59 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id qq8si80804174wjc.143.2017.01.04.02.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:19:58 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so90729996wmu.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:58 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/7] mm, vmscan: extract shrink_page_list reclaim counters into a struct
Date: Wed,  4 Jan 2017 11:19:40 +0100
Message-Id: <20170104101942.4860-6-mhocko@kernel.org>
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
References: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

shrink_page_list returns quite some counters back to its caller. Extract
the existing 5 into struct reclaim_stat because this makes the code
easier to follow and also allows further counters to be returned.

While we are at it, make all of them unsigned rather than unsigned long
as we do not really need full 64b for them (we never scan more than
SWAP_CLUSTER_MAX pages at once). This should reduce some stack space.

This patch shouldn't introduce any functional change.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 61 ++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 30 insertions(+), 31 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13758aaed78b..920e47a905c3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -902,6 +902,14 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+struct reclaim_stat {
+	unsigned nr_dirty;
+	unsigned nr_unqueued_dirty;
+	unsigned nr_congested;
+	unsigned nr_writeback;
+	unsigned nr_immediate;
+};
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -909,22 +917,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct pglist_data *pgdat,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
-				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_unqueued_dirty,
-				      unsigned long *ret_nr_congested,
-				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
+				      struct reclaim_stat *stat,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_reclaimed = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	unsigned nr_unqueued_dirty = 0;
+	unsigned nr_dirty = 0;
+	unsigned nr_congested = 0;
+	unsigned nr_reclaimed = 0;
+	unsigned nr_writeback = 0;
+	unsigned nr_immediate = 0;
 
 	cond_resched();
 
@@ -1266,11 +1270,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 
-	*ret_nr_dirty += nr_dirty;
-	*ret_nr_congested += nr_congested;
-	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
-	*ret_nr_writeback += nr_writeback;
-	*ret_nr_immediate += nr_immediate;
+	if (stat) {
+		stat->nr_dirty = nr_dirty;
+		stat->nr_congested = nr_congested;
+		stat->nr_unqueued_dirty = nr_unqueued_dirty;
+		stat->nr_writeback = nr_writeback;
+		stat->nr_immediate = nr_immediate;
+	}
 	return nr_reclaimed;
 }
 
@@ -1282,7 +1288,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	unsigned long ret;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1295,8 +1301,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
 	list_splice(&clean_pages, page_list);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1696,11 +1701,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	struct reclaim_stat stat = {};
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1745,9 +1746,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
-				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+				&stat, false);
 
 	spin_lock_irq(&pgdat->lru_lock);
 
@@ -1781,7 +1780,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * of pages under pages flagged for immediate reclaim and stall if any
 	 * are encountered in the nr_immediate check below.
 	 */
-	if (nr_writeback && nr_writeback == nr_taken)
+	if (stat.nr_writeback && stat.nr_writeback == nr_taken)
 		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
@@ -1793,7 +1792,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * Tag a zone as congested if all the dirty pages scanned were
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
-		if (nr_dirty && nr_dirty == nr_congested)
+		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
 			set_bit(PGDAT_CONGESTED, &pgdat->flags);
 
 		/*
@@ -1802,7 +1801,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
 		 * reclaim context.
 		 */
-		if (nr_unqueued_dirty == nr_taken)
+		if (stat.nr_unqueued_dirty == nr_taken)
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
 
 		/*
@@ -1811,7 +1810,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_immediate && current_may_throttle())
+		if (stat.nr_immediate && current_may_throttle())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
