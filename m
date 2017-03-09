Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2928A6B0417
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 02:57:00 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u9so18712082wme.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 23:57:00 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id b109si7648631wrd.317.2017.03.08.23.56.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 23:56:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 45E63997FE
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 07:56:58 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due to mismatched classzone_idx
Date: Thu,  9 Mar 2017 07:56:57 +0000
Message-Id: <20170309075657.25121-4-mgorman@techsingularity.net>
In-Reply-To: <20170309075657.25121-1-mgorman@techsingularity.net>
References: <20170309075657.25121-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

kswapd is woken to reclaim a node based on a failed allocation request
from any eligible zone. Once reclaiming in balance_pgdat(), it will
continue reclaiming until there is an eligible zone available for the
zone it was woken for. kswapd tracks what zone it was recently woken for
in pgdat->kswapd_classzone_idx. If it has not been woken recently, this
zone will be 0.

However, the decision on whether to sleep is made on kswapd_classzone_idx
which is 0 without a recent wakeup request and that classzone does not
account for lowmem reserves.  This allows kswapd to sleep when a low
small zone such as ZONE_DMA is balanced for a GFP_DMA request even if
a stream of allocations cannot use that zone. While kswapd may be woken
again shortly in the near future there are two consequences -- the pgdat
bits that control congestion are cleared prematurely and direct reclaim
is more likely as kswapd slept prematurely.

This patch flips kswapd_classzone_idx to default to MAX_NR_ZONES (an invalid
index) when there has been no recent wakeups. If there are no wakeups,
it'll decide whether to sleep based on the highest possible zone available
(MAX_NR_ZONES - 1). It then becomes critical that the "pgdat balanced"
decisions during reclaim and when deciding to sleep are the same. If there is
a mismatch, kswapd can stay awake continually trying to balance tiny zones.

simoop was used to evaluate it again. Two of the preparation patches
regressed the workload so they are included as the second set of
results. Otherwise this patch looks artifically excellent

                                         4.11.0-rc1            4.11.0-rc1            4.11.0-rc1
                                            vanilla              clear-v2          keepawake-v2
Amean    p50-Read             21670074.18 (  0.00%) 19786774.76 (  8.69%) 22668332.52 ( -4.61%)
Amean    p95-Read             25456267.64 (  0.00%) 24101956.27 (  5.32%) 26738688.00 ( -5.04%)
Amean    p99-Read             29369064.73 (  0.00%) 27691872.71 (  5.71%) 30991404.52 ( -5.52%)
Amean    p50-Write                1390.30 (  0.00%)     1011.91 ( 27.22%)      924.91 ( 33.47%)
Amean    p95-Write              412901.57 (  0.00%)    34874.98 ( 91.55%)     1362.62 ( 99.67%)
Amean    p99-Write             6668722.09 (  0.00%)   575449.60 ( 91.37%)    16854.04 ( 99.75%)
Amean    p50-Allocation          78714.31 (  0.00%)    84246.26 ( -7.03%)    74729.74 (  5.06%)
Amean    p95-Allocation         175533.51 (  0.00%)   400058.43 (-127.91%)   101609.74 ( 42.11%)
Amean    p99-Allocation         247003.02 (  0.00%) 10905600.00 (-4315.17%)   125765.57 ( 49.08%)

With this patch on top, write and allocation latencies are massively
improved.  The read latencies are slightly impaired but it's worth noting
that this is mostly due to the IO scheduler and not directly related to
reclaim. The vmstats are a bit of a mix but the relevant ones are as follows;

                            4.10.0-rc7  4.10.0-rc7  4.10.0-rc7
                          mmots-20170209 clear-v1r25keepawake-v1r25
Swap Ins                             0           0           0
Swap Outs                            0         608           0
Direct pages scanned           6910672     3132699     6357298
Kswapd pages scanned          57036946    82488665    56986286
Kswapd pages reclaimed        55993488    63474329    55939113
Direct pages reclaimed         6905990     2964843     6352115
Kswapd efficiency                  98%         76%         98%
Kswapd velocity              12494.375   17597.507   12488.065
Direct efficiency                  99%         94%         99%
Direct velocity               1513.835     668.306    1393.148
Page writes by reclaim           0.000 4410243.000       0.000
Page writes file                     0     4409635           0
Page writes anon                     0         608           0
Page reclaim immediate         1036792    14175203     1042571

                            4.11.0-rc1  4.11.0-rc1  4.11.0-rc1
                               vanilla  clear-v2  keepawake-v2
Swap Ins                             0          12           0
Swap Outs                            0         838           0
Direct pages scanned           6579706     3237270     6256811
Kswapd pages scanned          61853702    79961486    54837791
Kswapd pages reclaimed        60768764    60755788    53849586
Direct pages reclaimed         6579055     2987453     6256151
Kswapd efficiency                  98%         75%         98%
Page writes by reclaim           0.000 4389496.000       0.000
Page writes file                     0     4388658           0
Page writes anon                     0         838           0
Page reclaim immediate         1073573    14473009      982507

Swap-outs are equivalent to baseline.
Direct reclaim is reduced but not eliminated. It's worth noting
	that there are two periods of direct reclaim for this workload. The
	first is when it switches from preparing the files for the actual
	test itself. It's a lot of file IO followed by a lot of allocs
	that reclaims heavily for a brief window. While direct reclaim
	is lower with clear-v2, it is due to kswapd scanning aggressively
	and trying to reclaim the world which is not the right thing to do.
	With the patches applied, there is still direct reclaim but the phase
	change from "creating work files" to starting multiple threads that
	allocate a lot of anonymous memory faster than kswapd can reclaim.
Scanning/reclaim efficiency is restored by this patch.
Page writes from reclaim context are back at 0 which is ideal.
Pages immediately reclaimed after IO completes is slightly improved but it
	is expected this will vary slightly.

On UMA, there is almost no change so this is not expected to be a universal
win.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/memory_hotplug.c |   2 +-
 mm/vmscan.c         | 118 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 66 insertions(+), 54 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 295479b792ec..edff09061e32 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1207,7 +1207,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 		/* Reset the nr_zones, order and classzone_idx before reuse */
 		pgdat->nr_zones = 0;
 		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = 0;
+		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 17b1afbce88e..6b09ed5e4bda 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3084,14 +3084,36 @@ static void age_active_anon(struct pglist_data *pgdat,
 	} while (memcg);
 }
 
-static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
+/*
+ * Returns true if there is an eligible zone balanced for the request order
+ * and classzone_idx
+ */
+static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 {
-	unsigned long mark = high_wmark_pages(zone);
+	int i;
+	unsigned long mark = -1;
+	struct zone *zone;
 
-	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
-		return false;
+	for (i = 0; i <= classzone_idx; i++) {
+		zone = pgdat->node_zones + i;
 
-	return true;
+		if (!managed_zone(zone))
+			continue;
+
+		mark = high_wmark_pages(zone);
+		if (zone_watermark_ok_safe(zone, order, mark, classzone_idx))
+			return true;
+	}
+
+	/*
+	 * If a node has no populated zone within classzone_idx, it does not
+	 * need balancing by definition. This can happen if a zone-restricted
+	 * allocation tries to wake a remote kswapd.
+	 */
+	if (mark == -1)
+		return true;
+
+	return false;
 }
 
 /* Clear pgdat state for congested, dirty or under writeback. */
@@ -3110,8 +3132,6 @@ static void clear_pgdat_congested(pg_data_t *pgdat)
  */
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
-	int i;
-
 	/*
 	 * The throttled processes are normally woken up in balance_pgdat() as
 	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
@@ -3128,16 +3148,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 	if (waitqueue_active(&pgdat->pfmemalloc_wait))
 		wake_up_all(&pgdat->pfmemalloc_wait);
 
-	for (i = 0; i <= classzone_idx; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		if (!managed_zone(zone))
-			continue;
-
-		if (zone_balanced(zone, order, classzone_idx)) {
-			clear_pgdat_congested(pgdat);
-			return true;
-		}
+	if (pgdat_balanced(pgdat, order, classzone_idx)) {
+		clear_pgdat_congested(pgdat);
+		return true;
 	}
 
 	return false;
@@ -3243,23 +3256,12 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		}
 
 		/*
-		 * Only reclaim if there are no eligible zones. Check from
-		 * high to low zone as allocations prefer higher zones.
-		 * Scanning from low to high zone would allow congestion to be
-		 * cleared during a very small window when a small low
-		 * zone was balanced even under extreme pressure when the
-		 * overall node may be congested. Note that sc.reclaim_idx
-		 * is not used as buffer_heads_over_limit may have adjusted
-		 * it.
+		 * Only reclaim if there are no eligible zones. Note that
+		 * sc.reclaim_idx is not used as buffer_heads_over_limit may
+		 * have adjusted it.
 		 */
-		for (i = classzone_idx; i >= 0; i--) {
-			zone = pgdat->node_zones + i;
-			if (!managed_zone(zone))
-				continue;
-
-			if (zone_balanced(zone, sc.order, classzone_idx))
-				goto out;
-		}
+		if (pgdat_balanced(pgdat, sc.order, classzone_idx))
+			goto out;
 
 		/*
 		 * Do some background aging of the anon list, to give
@@ -3322,6 +3324,22 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	return sc.order;
 }
 
+/*
+ * pgdat->kswapd_classzone_idx is the highest zone index that a recent
+ * allocation request woke kswapd for. When kswapd has not woken recently,
+ * the value is MAX_NR_ZONES which is not a valid index. This compares a
+ * given classzone and returns it or the highest classzone index kswapd
+ * was recently woke for.
+ */
+static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
+					   enum zone_type classzone_idx)
+{
+	if (pgdat->kswapd_classzone_idx == MAX_NR_ZONES)
+		return classzone_idx;
+
+	return max(pgdat->kswapd_classzone_idx, classzone_idx);
+}
+
 static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
 				unsigned int classzone_idx)
 {
@@ -3363,7 +3381,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
 		 * the previous request that slept prematurely.
 		 */
 		if (remaining) {
-			pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
+			pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
 			pgdat->kswapd_order = max(pgdat->kswapd_order, reclaim_order);
 		}
 
@@ -3417,7 +3435,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
  */
 static int kswapd(void *p)
 {
-	unsigned int alloc_order, reclaim_order, classzone_idx;
+	unsigned int alloc_order, reclaim_order;
+	unsigned int classzone_idx = MAX_NR_ZONES - 1;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -3447,20 +3466,23 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	pgdat->kswapd_order = alloc_order = reclaim_order = 0;
-	pgdat->kswapd_classzone_idx = classzone_idx = 0;
+	pgdat->kswapd_order = 0;
+	pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	for ( ; ; ) {
 		bool ret;
 
+		alloc_order = reclaim_order = pgdat->kswapd_order;
+		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
+
 kswapd_try_sleep:
 		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
 					classzone_idx);
 
 		/* Read the new order and classzone_idx */
 		alloc_order = reclaim_order = pgdat->kswapd_order;
-		classzone_idx = pgdat->kswapd_classzone_idx;
+		classzone_idx = kswapd_classzone_idx(pgdat, 0);
 		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = 0;
+		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 
 		ret = try_to_freeze();
 		if (kthread_should_stop())
@@ -3486,9 +3508,6 @@ static int kswapd(void *p)
 		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
-
-		alloc_order = reclaim_order = pgdat->kswapd_order;
-		classzone_idx = pgdat->kswapd_classzone_idx;
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
@@ -3504,7 +3523,6 @@ static int kswapd(void *p)
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
-	int z;
 
 	if (!managed_zone(zone))
 		return;
@@ -3512,22 +3530,16 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!cpuset_zone_allowed(zone, GFP_KERNEL | __GFP_HARDWALL))
 		return;
 	pgdat = zone->zone_pgdat;
-	pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx, classzone_idx);
+	pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
 	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 
 	/* Only wake kswapd if all zones are unbalanced */
-	for (z = 0; z <= classzone_idx; z++) {
-		zone = pgdat->node_zones + z;
-		if (!managed_zone(zone))
-			continue;
-
-		if (zone_balanced(zone, order, classzone_idx))
-			return;
-	}
+	if (pgdat_balanced(pgdat, order, classzone_idx))
+		return;
 
-	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
+	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, classzone_idx, order);
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
