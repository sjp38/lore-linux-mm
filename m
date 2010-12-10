Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B04576B0096
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 10:46:33 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/6] mm: kswapd: Stop high-order balancing when any suitable zone is balanced
Date: Fri, 10 Dec 2010 15:46:20 +0000
Message-Id: <1291995985-5913-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
References: <1291995985-5913-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When the allocator enters its slow path, kswapd is woken up to balance the
node. It continues working until all zones within the node are balanced. For
order-0 allocations, this makes perfect sense but for higher orders it can
have unintended side-effects. If the zone sizes are imbalanced, kswapd may
reclaim heavily within a smaller zone discarding an excessive number of
pages. The user-visible behaviour is that kswapd is awake and reclaiming
even though plenty of pages are free from a suitable zone.

This patch alters the "balance" logic for high-order reclaim allowing kswapd
to stop if any suitable zone becomes balanced to reduce the number of pages
it reclaims from other zones. kswapd still tries to ensure that order-0
watermarks for all zones are met before sleeping.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mmzone.h |    3 +-
 mm/page_alloc.c        |    8 +++--
 mm/vmscan.c            |   68 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 66 insertions(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4890662..dad3612 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -639,6 +639,7 @@ typedef struct pglist_data {
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
+	enum zone_type classzone_idx;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
@@ -654,7 +655,7 @@ typedef struct pglist_data {
 
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(void *data);
-void wakeup_kswapd(struct zone *zone, int order);
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
 bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1845a97..1497fe8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1936,13 +1936,14 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 
 static inline
 void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
-						enum zone_type high_zoneidx)
+						enum zone_type high_zoneidx,
+						enum zone_type classzone_idx)
 {
 	struct zoneref *z;
 	struct zone *zone;
 
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		wakeup_kswapd(zone, order);
+		wakeup_kswapd(zone, order, classzone_idx);
 }
 
 static inline int
@@ -2020,7 +2021,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	wake_all_kswapd(order, zonelist, high_zoneidx);
+	wake_all_kswapd(order, zonelist, high_zoneidx,
+						zone_idx(preferred_zone));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 42a4859..625dfba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2239,11 +2239,14 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
+							int classzone_idx)
 {
 	int all_zones_ok;
+	int any_zone_ok;
 	int priority;
 	int i;
+	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
@@ -2266,7 +2269,6 @@ loop_again:
 	count_vm_event(PAGEOUTRUN);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
@@ -2275,6 +2277,7 @@ loop_again:
 			disable_swap_token();
 
 		all_zones_ok = 1;
+		any_zone_ok = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2393,10 +2396,12 @@ loop_again:
 				 * spectulatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
+				if (i <= classzone_idx)
+					any_zone_ok = 1;
 			}
 
 		}
-		if (all_zones_ok)
+		if (all_zones_ok || (order && any_zone_ok))
 			break;		/* kswapd: all done */
 		/*
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
@@ -2419,7 +2424,13 @@ loop_again:
 			break;
 	}
 out:
-	if (!all_zones_ok) {
+
+	/*
+	 * order-0: All zones must meet high watermark for a balanced node
+	 * high-order: Any zone below pgdats classzone_idx must meet the high
+	 *             watermark for a balanced node
+	 */
+	if (!(all_zones_ok || (order && any_zone_ok))) {
 		cond_resched();
 
 		try_to_freeze();
@@ -2444,6 +2455,36 @@ out:
 		goto loop_again;
 	}
 
+	/*
+	 * If kswapd was reclaiming at a higher order, it has the option of
+	 * sleeping without all zones being balanced. Before it does, it must
+	 * ensure that the watermarks for order-0 on *all* zones are met and
+	 * that the congestion flags are cleared. The congestion flag must
+	 * be cleared as kswapd is the only mechanism that clears the flag
+	 * and it is potentially going to sleep here.
+	 */
+	if (order) {
+		for (i = 0; i <= end_zone; i++) {
+			struct zone *zone = pgdat->node_zones + i;
+
+			if (!populated_zone(zone))
+				continue;
+
+			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+				continue;
+
+			/* Confirm the zone is balanced for order-0 */
+			if (!zone_watermark_ok(zone, 0,
+					high_wmark_pages(zone), 0, 0)) {
+				order = sc.order = 0;
+				goto loop_again;
+			}
+
+			/* If balanced, clear the congested flag */
+			zone_clear_flag(zone, ZONE_CONGESTED);
+		}
+	}
+
 	return sc.nr_reclaimed;
 }
 
@@ -2507,6 +2548,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 static int kswapd(void *p)
 {
 	unsigned long order;
+	int classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -2537,21 +2579,27 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = 0;
+	classzone_idx = MAX_NR_ZONES - 1;
 	for ( ; ; ) {
 		unsigned long new_order;
+		int new_classzone_idx;
 		int ret;
 
 		new_order = pgdat->kswapd_max_order;
+		new_classzone_idx = pgdat->classzone_idx;
 		pgdat->kswapd_max_order = 0;
-		if (order < new_order) {
+		pgdat->classzone_idx = MAX_NR_ZONES - 1;
+		if (order < new_order || classzone_idx > new_classzone_idx) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
-			 * allocation
+			 * allocation or has tigher zone constraints
 			 */
 			order = new_order;
+			classzone_idx = new_classzone_idx;
 		} else {
 			kswapd_try_to_sleep(pgdat, order);
 			order = pgdat->kswapd_max_order;
+			classzone_idx = pgdat->classzone_idx;
 		}
 
 		ret = try_to_freeze();
@@ -2564,7 +2612,7 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balance_pgdat(pgdat, order);
+			balance_pgdat(pgdat, order, classzone_idx);
 		}
 	}
 	return 0;
@@ -2573,7 +2621,7 @@ static int kswapd(void *p)
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */
-void wakeup_kswapd(struct zone *zone, int order)
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
 
@@ -2583,8 +2631,10 @@ void wakeup_kswapd(struct zone *zone, int order)
 	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 		return;
 	pgdat = zone->zone_pgdat;
-	if (pgdat->kswapd_max_order < order)
+	if (pgdat->kswapd_max_order < order) {
 		pgdat->kswapd_max_order = order;
+		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
+	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
