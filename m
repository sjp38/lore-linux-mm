Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFC3A6B000D
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:45:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so3140686pgt.6
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:45:57 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0138.outbound.protection.outlook.com. [104.47.2.138])
        by mx.google.com with ESMTPS id o2si4068393pfg.286.2018.03.15.09.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 09:45:56 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 5/6] mm/vmscan: Don't change pgdat state on base of a single LRU list state.
Date: Thu, 15 Mar 2018 19:45:52 +0300
Message-Id: <20180315164553.17856-5-aryabinin@virtuozzo.com>
In-Reply-To: <20180315164553.17856-1-aryabinin@virtuozzo.com>
References: <20180315164553.17856-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

We have separate LRU list for each memory cgroup. Memory reclaim iterates
over cgroups and calls shrink_inactive_list() every inactive LRU list.
Based on the state of a single LRU shrink_inactive_list() may flag
the whole node as dirty,congested or under writeback. This is obviously
wrong and hurtful. It's especially hurtful when we have possibly
small congested cgroup in system. Than *all* direct reclaims waste time
by sleeping in wait_iff_congested().

Sum reclaim stats across all visited LRUs on node and flag node as dirty,
congested or under writeback based on that sum. This only fixes the
problem for global reclaim case. Per-cgroup reclaim will be addressed
separately by the next patch.

This change will also affect systems with no memory cgroups. Reclaimer
now makes decision based on reclaim stats of the both anon and file LRU
lists. E.g. if the file list is in congested state and get_scan_count()
decided to reclaim some anon pages, reclaimer will start shrinking
anon without delay in wait_iff_congested() like it was before. It seems
to be a reasonable thing to do. Why waste time sleeping, before reclaiming
anon given that we going to try to reclaim it anyway?

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/vmscan.c | 131 +++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 73 insertions(+), 58 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8f6e4882e00..522b480caeb2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -61,6 +61,15 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/vmscan.h>
 
+struct reclaim_stat {
+	unsigned int nr_dirty;
+	unsigned int nr_unqueued_dirty;
+	unsigned int nr_congested;
+	unsigned int nr_writeback;
+	unsigned int nr_immediate;
+	unsigned int nr_taken;
+};
+
 struct scan_control {
 	/* How many pages shrink_list() should reclaim */
 	unsigned long nr_to_reclaim;
@@ -116,6 +125,8 @@ struct scan_control {
 
 	/* Number of pages freed so far during a call to shrink_zones() */
 	unsigned long nr_reclaimed;
+
+	struct reclaim_stat *stat;
 };
 
 #ifdef ARCH_HAS_PREFETCH
@@ -857,14 +868,6 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
-struct reclaim_stat {
-	unsigned nr_dirty;
-	unsigned nr_unqueued_dirty;
-	unsigned nr_congested;
-	unsigned nr_writeback;
-	unsigned nr_immediate;
-};
-
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -1753,23 +1756,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	mem_cgroup_uncharge_list(&page_list);
 	free_unref_page_list(&page_list);
 
-	/*
-	 * If reclaim is isolating dirty pages under writeback, it implies
-	 * that the long-lived page allocation rate is exceeding the page
-	 * laundering rate. Either the global limits are not being effective
-	 * at throttling processes due to the page distribution throughout
-	 * zones or there is heavy usage of a slow backing device. The
-	 * only option is to throttle from reclaim context which is not ideal
-	 * as there is no guarantee the dirtying process is throttled in the
-	 * same way balance_dirty_pages() manages.
-	 *
-	 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
-	 * of pages under pages flagged for immediate reclaim and stall if any
-	 * are encountered in the nr_immediate check below.
-	 */
-	if (stat.nr_writeback && stat.nr_writeback == nr_taken)
-		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
-
 	/*
 	 * If dirty pages are scanned that are not queued for IO, it
 	 * implies that flushers are not doing their job. This can
@@ -1784,41 +1770,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (stat.nr_unqueued_dirty == nr_taken)
 		wakeup_flusher_threads(WB_REASON_VMSCAN);
 
-	/*
-	 * Legacy memcg will stall in page writeback so avoid forcibly
-	 * stalling here.
-	 */
-	if (sane_reclaim(sc)) {
-		/*
-		 * Tag a node as congested if all the dirty pages scanned were
-		 * backed by a congested BDI and wait_iff_congested will stall.
-		 */
-		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
-			set_bit(PGDAT_CONGESTED, &pgdat->flags);
-
-		/* Allow kswapd to start writing pages during reclaim. */
-		if (stat.nr_unqueued_dirty == nr_taken)
-			set_bit(PGDAT_DIRTY, &pgdat->flags);
-
-		/*
-		 * If kswapd scans pages marked marked for immediate
-		 * reclaim and under writeback (nr_immediate), it implies
-		 * that pages are cycling through the LRU faster than
-		 * they are written so also forcibly stall.
-		 */
-		if (stat.nr_immediate)
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+	if (sc->stat) {
+		sc->stat->nr_dirty += stat.nr_dirty;
+		sc->stat->nr_congested += stat.nr_congested;
+		sc->stat->nr_unqueued_dirty += stat.nr_unqueued_dirty;
+		sc->stat->nr_writeback += stat.nr_writeback;
+		sc->stat->nr_immediate += stat.nr_immediate;
+		sc->stat->nr_taken += stat.nr_taken;
 	}
 
-	/*
-	 * Stall direct reclaim for IO completions if underlying BDIs and node
-	 * is congested. Allow kswapd to continue until it starts encountering
-	 * unqueued dirty pages or cycling through the LRU too quickly.
-	 */
-	if (!sc->hibernation_mode && !current_is_kswapd() &&
-	    current_may_throttle())
-		wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
-
 	return nr_reclaimed;
 }
 
@@ -2513,6 +2473,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		};
 		unsigned long node_lru_pages = 0;
 		struct mem_cgroup *memcg;
+		struct reclaim_stat stat = {};
+
+		sc->stat = &stat;
 
 		nr_reclaimed = sc->nr_reclaimed;
 		nr_scanned = sc->nr_scanned;
@@ -2579,6 +2542,58 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
+		/*
+		 * If reclaim is isolating dirty pages under writeback, it implies
+		 * that the long-lived page allocation rate is exceeding the page
+		 * laundering rate. Either the global limits are not being effective
+		 * at throttling processes due to the page distribution throughout
+		 * zones or there is heavy usage of a slow backing device. The
+		 * only option is to throttle from reclaim context which is not ideal
+		 * as there is no guarantee the dirtying process is throttled in the
+		 * same way balance_dirty_pages() manages.
+		 *
+		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will count the number
+		 * of pages under pages flagged for immediate reclaim and stall if any
+		 * are encountered in the nr_immediate check below.
+		 */
+		if (stat.nr_writeback && stat.nr_writeback == stat.nr_taken)
+			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
+
+		/*
+		 * Legacy memcg will stall in page writeback so avoid forcibly
+		 * stalling here.
+		 */
+		if (sane_reclaim(sc)) {
+			/*
+			 * Tag a node as congested if all the dirty pages scanned were
+			 * backed by a congested BDI and wait_iff_congested will stall.
+			 */
+			if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
+				set_bit(PGDAT_CONGESTED, &pgdat->flags);
+
+			/* Allow kswapd to start writing pages during reclaim. */
+			if (stat.nr_unqueued_dirty == stat.nr_taken)
+				set_bit(PGDAT_DIRTY, &pgdat->flags);
+
+			/*
+			 * If kswapd scans pages marked marked for immediate
+			 * reclaim and under writeback (nr_immediate), it implies
+			 * that pages are cycling through the LRU faster than
+			 * they are written so also forcibly stall.
+			 */
+			if (stat.nr_immediate)
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+		}
+
+		/*
+		 * Stall direct reclaim for IO completions if underlying BDIs and node
+		 * is congested. Allow kswapd to continue until it starts encountering
+		 * unqueued dirty pages or cycling through the LRU too quickly.
+		 */
+		if (!sc->hibernation_mode && !current_is_kswapd() &&
+		    current_may_throttle())
+			wait_iff_congested(pgdat, BLK_RW_ASYNC, HZ/10);
+
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
-- 
2.16.1
