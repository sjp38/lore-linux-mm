Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44982680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:22:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so13922550wmu.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:22:52 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id z67si6982231wmb.101.2017.02.15.01.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 01:22:50 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id D1C1F1C1BD4
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 09:22:49 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/3] mm, vmscan: Prevent kswapd sleeping prematurely due to mismatched classzone_idx
Date: Wed, 15 Feb 2017 09:22:47 +0000
Message-Id: <20170215092247.15989-4-mgorman@techsingularity.net>
In-Reply-To: <20170215092247.15989-1-mgorman@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

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

simoop was used to evaluate it again. Two of the preparation patches regressed
the workload so they are included as the second set of results. Otherwise
this patch looks artifically excellent

                                         4.10.0-rc7            4.10.0-rc7            4.10.0-rc7
                                     mmots-20170209           clear-v1r25       keepawake-v1r25
Amean    p50-Read             22325202.49 (  0.00%) 19491134.58 ( 12.69%) 22092755.48 (  1.04%)
Amean    p95-Read             26102988.80 (  0.00%) 24294195.20 (  6.93%) 26101849.04 (  0.00%)
Amean    p99-Read             30935176.53 (  0.00%) 30397053.16 (  1.74%) 29746220.52 (  3.84%)
Amean    p50-Write                 976.44 (  0.00%)     1077.22 (-10.32%)      952.73 (  2.43%)
Amean    p95-Write               15471.29 (  0.00%)    36419.56 (-135.40%)     3140.27 ( 79.70%)
Amean    p99-Write               35108.62 (  0.00%)   102000.36 (-190.53%)     8843.73 ( 74.81%)
Amean    p50-Allocation          76382.61 (  0.00%)    87485.22 (-14.54%)    76349.22 (  0.04%)
Amean    p95-Allocation         127777.39 (  0.00%)   204588.52 (-60.11%)   108630.26 ( 14.98%)
Amean    p99-Allocation         187937.39 (  0.00%)   631657.74 (-236.10%)   139094.26 ( 25.99%)

With this patch on top, all the latencies relative to the baseline are
improved, particularly write latencies. The read latencies are still high
for the number of threads but it's worth noting that this is mostly due
to the IO scheduler and not directly related to reclaim. The vmstats are
a bit of a mix but the relevant ones are as follows;

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

Swap-outs are equivalent to baseline
Direct reclaim is reduced but not eliminated. It's worth noting
	that there are two periods of direct reclaim for this workload. The
	first is when it switches from preparing the files for the actual
	test itself. It's a lot of file IO followed by a lot of allocs
	that reclaims heavily for a brief window. After that, direct
	reclaim is intermittent when the workload spawns a number of
	threads periodically to do work. kswapd simply cannot wake and
	reclaim fast enough between the low and min watermarks. It could
	be mitigated using vm.watermark_scale_factor but not through
	special tricks in kswapd.
Page writes from reclaim context are at 0 which is the ideal
Pages immediately reclaimed after IO completes is back at the baseline

On UMA, there is almost no change so this is not expected to be a universal
win.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/memory_hotplug.c |   2 +-
 mm/vmscan.c         | 118 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 66 insertions(+), 54 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 11581f4cfbb4..481aebc91782 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1209,7 +1209,7 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 		/* Reset the nr_zones, order and classzone_idx before reuse */
 		pgdat->nr_zones = 0;
 		pgdat->kswapd_order = 0;
-		pgdat->kswapd_classzone_idx = 0;
+		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
 	}
 
 	/* we can use NODE_DATA(nid) from here */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b47b430ca7ea..3bd1ddee09cd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3090,14 +3090,36 @@ static void age_active_anon(struct pglist_data *pgdat,
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
@@ -3116,8 +3138,6 @@ static void clear_pgdat_congested(pg_data_t *pgdat)
  */
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
-	int i;
-
 	/*
 	 * The throttled processes are normally woken up in balance_pgdat() as
 	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
@@ -3134,16 +3154,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
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
@@ -3249,23 +3262,12 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
@@ -3328,6 +3330,22 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
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
