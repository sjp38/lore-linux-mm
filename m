Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7706B004A
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 06:45:36 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any suitable zone is balanced
Date: Fri,  3 Dec 2010 11:45:30 +0000
Message-Id: <1291376734-30202-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
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
---
 include/linux/mmzone.h |    3 +-
 mm/page_alloc.c        |    8 ++++--
 mm/vmscan.c            |   55 +++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 54 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..7177f51 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -645,6 +645,7 @@ typedef struct pglist_data {
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
+	enum zone_type classzone_idx;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
@@ -660,7 +661,7 @@ typedef struct pglist_data {
 
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(void *data);
-void wakeup_kswapd(struct zone *zone, int order);
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
 enum memmap_context {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e409270..82e3499 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1915,13 +1915,14 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 
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
@@ -1998,7 +1999,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	wake_all_kswapd(order, zonelist, high_zoneidx);
+	wake_all_kswapd(order, zonelist, high_zoneidx,
+						zone_idx(preferred_zone));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d31d7ce..d070d19 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2165,11 +2165,14 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
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
@@ -2192,7 +2195,6 @@ loop_again:
 	count_vm_event(PAGEOUTRUN);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
@@ -2201,6 +2203,7 @@ loop_again:
 			disable_swap_token();
 
 		all_zones_ok = 1;
+		any_zone_ok = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2310,10 +2313,12 @@ loop_again:
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
@@ -2336,7 +2341,7 @@ loop_again:
 			break;
 	}
 out:
-	if (!all_zones_ok) {
+	if (!(all_zones_ok || (order && any_zone_ok))) {
 		cond_resched();
 
 		try_to_freeze();
@@ -2361,6 +2366,31 @@ out:
 		goto loop_again;
 	}
 
+	/*
+	 * If kswapd was reclaiming at a higher order, it has the option of
+	 * sleeping without all zones being balanced. Before it does, it must
+	 * ensure that the watermarks for order-0 on *all* zones are met and
+	 * that the congestion flags are cleared
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
+			zone_clear_flag(zone, ZONE_CONGESTED);
+			if (!zone_watermark_ok(zone, order,
+					high_wmark_pages(zone), 0, 0)) {
+				order = sc.order = 0;
+				goto loop_again;
+			}
+		}
+	}
+
 	return sc.nr_reclaimed;
 }
 
@@ -2380,6 +2410,7 @@ out:
 static int kswapd(void *p)
 {
 	unsigned long order;
+	int classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
@@ -2410,19 +2441,24 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = 0;
+	classzone_idx = MAX_NR_ZONES - 1;
 	for ( ; ; ) {
 		unsigned long new_order;
+		int new_classzone_idx;
 		int ret;
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
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
 			if (!freezing(current) && !kthread_should_stop()) {
 				long remaining = 0;
@@ -2451,6 +2487,7 @@ static int kswapd(void *p)
 			}
 
 			order = pgdat->kswapd_max_order;
+			classzone_idx = pgdat->classzone_idx;
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
@@ -2473,7 +2510,7 @@ static int kswapd(void *p)
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */
-void wakeup_kswapd(struct zone *zone, int order)
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
 
@@ -2483,8 +2520,10 @@ void wakeup_kswapd(struct zone *zone, int order)
 	pgdat = zone->zone_pgdat;
 	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
 		return;
-	if (pgdat->kswapd_max_order < order)
+	if (pgdat->kswapd_max_order < order) {
 		pgdat->kswapd_max_order = order;
+		pgdat->classzone_idx = min(pgdat->classzone_idx, classzone_idx);
+	}
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 		return;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
