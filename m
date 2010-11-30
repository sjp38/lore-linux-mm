Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3DA6B0089
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 12:15:44 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any suitable zone is balanced
Date: Tue, 30 Nov 2010 17:15:37 +0000
Message-Id: <1291137339-6323-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1291137339-6323-1-git-send-email-mel@csn.ul.ie>
References: <1291137339-6323-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When the allocator enters its slow path, kswapd is woken up to balance the
node. It continues working until all zones within the node are balanced. For
order-0 allocations, this makes perfect sense but for higher orders it can
have unintended side-effects. If the zone sizes are imbalanced, kswapd
may reclaim heavily on a smaller zone discarding an excessive number of
pages. The user-visible behaviour is that kswapd is awake and reclaiming
even though plenty of pages are free from a suitable zone.

This patch alters the "balance" logic to stop kswapd if any suitable zone
becomes balanced to reduce the number of pages it reclaims from other zones.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    3 ++-
 mm/page_alloc.c        |    2 +-
 mm/vmscan.c            |   48 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 39c24eb..25fe08d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -645,6 +645,7 @@ typedef struct pglist_data {
 	wait_queue_head_t kswapd_wait;
 	struct task_struct *kswapd;
 	int kswapd_max_order;
+	enum zone_type high_zoneidx;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
@@ -660,7 +661,7 @@ typedef struct pglist_data {
 
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(void *data);
-void wakeup_kswapd(struct zone *zone, int order);
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type high_zoneidx);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
 enum memmap_context {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07a6544..344b597 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1921,7 +1921,7 @@ void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
 	struct zone *zone;
 
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
-		wakeup_kswapd(zone, order);
+		wakeup_kswapd(zone, order, high_zoneidx);
 }
 
 static inline int
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d31d7ce..67e4283 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2165,11 +2165,14 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
  * interoperates with the page allocator fallback scheme to ensure that aging
  * of pages is balanced across the zones.
  */
-static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
+static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
+							int high_zoneidx)
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
+				if (i <= high_zoneidx)
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
@@ -2361,6 +2366,22 @@ out:
 		goto loop_again;
 	}
 
+	/* kswapd should always balance all zones for order-0 */
+	if (order && !all_zones_ok) {
+		order = sc.order = 0;
+		goto loop_again;
+	}
+
+	/*
+	 * As kswapd could be going to sleep, unconditionally mark all
+	 * zones as uncongested as kswapd is the only mechanism which
+	 * clears congestion flags
+	 */
+	for (i = 0; i <= end_zone; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+		zone_clear_flag(zone, ZONE_CONGESTED);
+	}
+
 	return sc.nr_reclaimed;
 }
 
@@ -2380,6 +2401,7 @@ out:
 static int kswapd(void *p)
 {
 	unsigned long order;
+	int zone_highidx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
@@ -2410,19 +2432,24 @@ static int kswapd(void *p)
 	set_freezable();
 
 	order = 0;
+	zone_highidx = MAX_NR_ZONES;
 	for ( ; ; ) {
 		unsigned long new_order;
+		int new_zone_highidx;
 		int ret;
 
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order = pgdat->kswapd_max_order;
+		new_zone_highidx = pgdat->high_zoneidx;
 		pgdat->kswapd_max_order = 0;
-		if (order < new_order) {
+		pgdat->high_zoneidx = MAX_NR_ZONES;
+		if (order < new_order || new_zone_highidx < zone_highidx) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
-			 * allocation
+			 * allocation or an order at a higher zone
 			 */
 			order = new_order;
+			zone_highidx = new_zone_highidx;
 		} else {
 			if (!freezing(current) && !kthread_should_stop()) {
 				long remaining = 0;
@@ -2451,6 +2478,7 @@ static int kswapd(void *p)
 			}
 
 			order = pgdat->kswapd_max_order;
+			zone_highidx = pgdat->high_zoneidx;
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
@@ -2464,7 +2492,7 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balance_pgdat(pgdat, order);
+			balance_pgdat(pgdat, order, zone_highidx);
 		}
 	}
 	return 0;
@@ -2473,7 +2501,7 @@ static int kswapd(void *p)
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */
-void wakeup_kswapd(struct zone *zone, int order)
+void wakeup_kswapd(struct zone *zone, int order, enum zone_type high_zoneidx)
 {
 	pg_data_t *pgdat;
 
@@ -2483,8 +2511,10 @@ void wakeup_kswapd(struct zone *zone, int order)
 	pgdat = zone->zone_pgdat;
 	if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
 		return;
-	if (pgdat->kswapd_max_order < order)
+	if (pgdat->kswapd_max_order < order) {
 		pgdat->kswapd_max_order = order;
+		pgdat->high_zoneidx = min(pgdat->high_zoneidx, high_zoneidx);
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
