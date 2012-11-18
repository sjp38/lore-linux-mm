Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id EFFE76B0068
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 11:09:36 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3069609pad.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 08:09:36 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFT PATCH v1 2/5] mm: replace zone->present_pages with zone->managed_pages if appreciated
Date: Mon, 19 Nov 2012 00:07:27 +0800
Message-Id: <1353254850-27336-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
 <1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now we have zone->managed_pages for "pages managed by the buddy system
in the zone", so replace zone->present_pages with zone->managed_pages
if what the user really wants is number of pages managed by the buddy
system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/mempolicy.c  |    2 +-
 mm/page_alloc.c |   32 ++++++++++++++++----------------
 mm/vmscan.c     |   16 ++++++++--------
 mm/vmstat.c     |    2 +-
 4 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d04a8a5..8367070 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -147,7 +147,7 @@ static int is_valid_nodemask(const nodemask_t *nodemask)
 
 		for (k = 0; k <= policy_zone; k++) {
 			z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0)
+			if (z->managed_pages > 0)
 				return 1;
 		}
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a41ee64..fe1cf48 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2791,7 +2791,7 @@ static unsigned int nr_free_zone_pages(int offset)
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
-		unsigned long size = zone->present_pages;
+		unsigned long size = zone->managed_pages;
 		unsigned long high = high_wmark_pages(zone);
 		if (size > high)
 			sum += size - high;
@@ -2844,7 +2844,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	val->totalram = pgdat->node_present_pages;
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
-	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
+	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
 	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
 			NR_FREE_PAGES);
 #else
@@ -3883,7 +3883,7 @@ static int __meminit zone_batchsize(struct zone *zone)
 	 *
 	 * OK, so we don't know how big the cache is.  So guess.
 	 */
-	batch = zone->present_pages / 1024;
+	batch = zone->managed_pages / 1024;
 	if (batch * PAGE_SIZE > 512 * 1024)
 		batch = (512 * 1024) / PAGE_SIZE;
 	batch /= 4;		/* We effectively *= 4 below */
@@ -3967,7 +3967,7 @@ static void __meminit setup_zone_pageset(struct zone *zone)
 
 		if (percpu_pagelist_fraction)
 			setup_pagelist_highmark(pcp,
-				(zone->present_pages /
+				(zone->managed_pages /
 					percpu_pagelist_fraction));
 	}
 }
@@ -5077,8 +5077,8 @@ static void calculate_totalreserve_pages(void)
 			/* we treat the high watermark as reserved pages. */
 			max += high_wmark_pages(zone);
 
-			if (max > zone->present_pages)
-				max = zone->present_pages;
+			if (max > zone->managed_pages)
+				max = zone->managed_pages;
 			reserve_pages += max;
 			/*
 			 * Lowmem reserves are not available to
@@ -5110,7 +5110,7 @@ static void setup_per_zone_lowmem_reserve(void)
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
 			struct zone *zone = pgdat->node_zones + j;
-			unsigned long present_pages = zone->present_pages;
+			unsigned long managed_pages = zone->managed_pages;
 
 			zone->lowmem_reserve[j] = 0;
 
@@ -5124,9 +5124,9 @@ static void setup_per_zone_lowmem_reserve(void)
 					sysctl_lowmem_reserve_ratio[idx] = 1;
 
 				lower_zone = pgdat->node_zones + idx;
-				lower_zone->lowmem_reserve[j] = present_pages /
+				lower_zone->lowmem_reserve[j] = managed_pages /
 					sysctl_lowmem_reserve_ratio[idx];
-				present_pages += lower_zone->present_pages;
+				managed_pages += lower_zone->managed_pages;
 			}
 		}
 	}
@@ -5145,14 +5145,14 @@ static void __setup_per_zone_wmarks(void)
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
 		if (!is_highmem(zone))
-			lowmem_pages += zone->present_pages;
+			lowmem_pages += zone->managed_pages;
 	}
 
 	for_each_zone(zone) {
 		u64 tmp;
 
 		spin_lock_irqsave(&zone->lock, flags);
-		tmp = (u64)pages_min * zone->present_pages;
+		tmp = (u64)pages_min * zone->managed_pages;
 		do_div(tmp, lowmem_pages);
 		if (is_highmem(zone)) {
 			/*
@@ -5166,7 +5166,7 @@ static void __setup_per_zone_wmarks(void)
 			 */
 			int min_pages;
 
-			min_pages = zone->present_pages / 1024;
+			min_pages = zone->managed_pages / 1024;
 			if (min_pages < SWAP_CLUSTER_MAX)
 				min_pages = SWAP_CLUSTER_MAX;
 			if (min_pages > 128)
@@ -5235,7 +5235,7 @@ static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
 	unsigned int gb, ratio;
 
 	/* Zone size in gigabytes */
-	gb = zone->present_pages >> (30 - PAGE_SHIFT);
+	gb = zone->managed_pages >> (30 - PAGE_SHIFT);
 	if (gb)
 		ratio = int_sqrt(10 * gb);
 	else
@@ -5321,7 +5321,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_unmapped_pages = (zone->present_pages *
+		zone->min_unmapped_pages = (zone->managed_pages *
 				sysctl_min_unmapped_ratio) / 100;
 	return 0;
 }
@@ -5337,7 +5337,7 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_slab_pages = (zone->present_pages *
+		zone->min_slab_pages = (zone->managed_pages *
 				sysctl_min_slab_ratio) / 100;
 	return 0;
 }
@@ -5379,7 +5379,7 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	for_each_populated_zone(zone) {
 		for_each_possible_cpu(cpu) {
 			unsigned long  high;
-			high = zone->present_pages / percpu_pagelist_fraction;
+			high = zone->managed_pages / percpu_pagelist_fraction;
 			setup_pagelist_highmark(
 				per_cpu_ptr(zone->pageset, cpu), high);
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48550c6..7240e89 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1935,7 +1935,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 	 * a reasonable chance of completing and allocating the page
 	 */
 	balance_gap = min(low_wmark_pages(zone),
-		(zone->present_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 			KSWAPD_ZONE_BALANCE_GAP_RATIO);
 	watermark = high_wmark_pages(zone) + balance_gap + (2UL << sc->order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
@@ -2416,14 +2416,14 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 						int classzone_idx)
 {
-	unsigned long present_pages = 0;
+	unsigned long managed_pages = 0;
 	int i;
 
 	for (i = 0; i <= classzone_idx; i++)
-		present_pages += pgdat->node_zones[i].present_pages;
+		managed_pages += pgdat->node_zones[i].managed_pages;
 
 	/* A special case here: if zone has no page, we think it's balanced */
-	return balanced_pages >= (present_pages >> 2);
+	return balanced_pages >= (managed_pages >> 2);
 }
 
 /*
@@ -2471,7 +2471,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 		 * is to sleep
 		 */
 		if (zone->all_unreclaimable) {
-			balanced += zone->present_pages;
+			balanced += zone->managed_pages;
 			continue;
 		}
 
@@ -2479,7 +2479,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 							i, 0))
 			all_zones_ok = false;
 		else
-			balanced += zone->present_pages;
+			balanced += zone->managed_pages;
 	}
 
 	/*
@@ -2645,7 +2645,7 @@ loop_again:
 			 * of the zone, whichever is smaller.
 			 */
 			balance_gap = min(low_wmark_pages(zone),
-				(zone->present_pages +
+				(zone->managed_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
 			/*
@@ -2712,7 +2712,7 @@ loop_again:
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
 				if (i <= *classzone_idx)
-					balanced += zone->present_pages;
+					balanced += zone->managed_pages;
 			}
 
 		}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e47d31c..b2925d1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -142,7 +142,7 @@ int calculate_normal_threshold(struct zone *zone)
 	 * 125		1024		10	16-32 GB	9
 	 */
 
-	mem = zone->present_pages >> (27 - PAGE_SHIFT);
+	mem = zone->managed_pages >> (27 - PAGE_SHIFT);
 
 	threshold = 2 * fls(num_online_cpus()) * (1 + fls(mem));
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
