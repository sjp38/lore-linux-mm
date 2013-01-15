Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 766236B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:18:43 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so78438dae.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 07:18:42 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RESEND PATCH v3 1/3] mm: use zone->present_pages instead of zone->managed_pages when appreciated
Date: Tue, 15 Jan 2013 23:18:15 +0800
Message-Id: <1358263097-11038-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now we have zone->managed_pages for "pages managed by the buddy system
in the zone", so replace zone->present_pages with zone->managed_pages
if what the user really wants is number of allocatable pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
Hi Andrew,
	A patchset with 5 patches to fix up inaccurate zone->present_pages
has been sent for v3.8, but only two of those five patches have been merged
into v3.8. So resend the other three patches for v3.9. Please refer to
https://patchwork.kernel.org/patch/1819561/
for more information. Sorry for the inconvinience.
	Regards!
	Gerry
---
 mm/mempolicy.c  |    2 +-
 mm/page_alloc.c |   32 ++++++++++++++++----------------
 mm/vmscan.c     |   14 +++++++-------
 mm/vmstat.c     |    2 +-
 4 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e2df1c1..af8a121 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -168,7 +168,7 @@ static int is_valid_nodemask(const nodemask_t *nodemask)
 
 		for (k = 0; k <= policy_zone; k++) {
 			z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0)
+			if (z->managed_pages > 0)
 				return 1;
 		}
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..fed01fd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2796,7 +2796,7 @@ static unsigned int nr_free_zone_pages(int offset)
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
-		unsigned long size = zone->present_pages;
+		unsigned long size = zone->managed_pages;
 		unsigned long high = high_wmark_pages(zone);
 		if (size > high)
 			sum += size - high;
@@ -2849,7 +2849,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	val->totalram = pgdat->node_present_pages;
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
-	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].present_pages;
+	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
 	val->freehigh = zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
 			NR_FREE_PAGES);
 #else
@@ -3927,7 +3927,7 @@ static int __meminit zone_batchsize(struct zone *zone)
 	 *
 	 * OK, so we don't know how big the cache is.  So guess.
 	 */
-	batch = zone->present_pages / 1024;
+	batch = zone->managed_pages / 1024;
 	if (batch * PAGE_SIZE > 512 * 1024)
 		batch = (512 * 1024) / PAGE_SIZE;
 	batch /= 4;		/* We effectively *= 4 below */
@@ -4011,7 +4011,7 @@ static void __meminit setup_zone_pageset(struct zone *zone)
 
 		if (percpu_pagelist_fraction)
 			setup_pagelist_highmark(pcp,
-				(zone->present_pages /
+				(zone->managed_pages /
 					percpu_pagelist_fraction));
 	}
 }
@@ -5152,8 +5152,8 @@ static void calculate_totalreserve_pages(void)
 			/* we treat the high watermark as reserved pages. */
 			max += high_wmark_pages(zone);
 
-			if (max > zone->present_pages)
-				max = zone->present_pages;
+			if (max > zone->managed_pages)
+				max = zone->managed_pages;
 			reserve_pages += max;
 			/*
 			 * Lowmem reserves are not available to
@@ -5185,7 +5185,7 @@ static void setup_per_zone_lowmem_reserve(void)
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
 			struct zone *zone = pgdat->node_zones + j;
-			unsigned long present_pages = zone->present_pages;
+			unsigned long managed_pages = zone->managed_pages;
 
 			zone->lowmem_reserve[j] = 0;
 
@@ -5199,9 +5199,9 @@ static void setup_per_zone_lowmem_reserve(void)
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
@@ -5220,14 +5220,14 @@ static void __setup_per_zone_wmarks(void)
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
@@ -5241,7 +5241,7 @@ static void __setup_per_zone_wmarks(void)
 			 */
 			int min_pages;
 
-			min_pages = zone->present_pages / 1024;
+			min_pages = zone->managed_pages / 1024;
 			if (min_pages < SWAP_CLUSTER_MAX)
 				min_pages = SWAP_CLUSTER_MAX;
 			if (min_pages > 128)
@@ -5306,7 +5306,7 @@ static void __meminit calculate_zone_inactive_ratio(struct zone *zone)
 	unsigned int gb, ratio;
 
 	/* Zone size in gigabytes */
-	gb = zone->present_pages >> (30 - PAGE_SHIFT);
+	gb = zone->managed_pages >> (30 - PAGE_SHIFT);
 	if (gb)
 		ratio = int_sqrt(10 * gb);
 	else
@@ -5392,7 +5392,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_unmapped_pages = (zone->present_pages *
+		zone->min_unmapped_pages = (zone->managed_pages *
 				sysctl_min_unmapped_ratio) / 100;
 	return 0;
 }
@@ -5408,7 +5408,7 @@ int sysctl_min_slab_ratio_sysctl_handler(ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_slab_pages = (zone->present_pages *
+		zone->min_slab_pages = (zone->managed_pages *
 				sysctl_min_slab_ratio) / 100;
 	return 0;
 }
@@ -5450,7 +5450,7 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 	for_each_populated_zone(zone) {
 		for_each_possible_cpu(cpu) {
 			unsigned long  high;
-			high = zone->present_pages / percpu_pagelist_fraction;
+			high = zone->managed_pages / percpu_pagelist_fraction;
 			setup_pagelist_highmark(
 				per_cpu_ptr(zone->pageset, cpu), high);
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 196709f..56e41bf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1958,7 +1958,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 	 * a reasonable chance of completing and allocating the page
 	 */
 	balance_gap = min(low_wmark_pages(zone),
-		(zone->present_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 			KSWAPD_ZONE_BALANCE_GAP_RATIO);
 	watermark = high_wmark_pages(zone) + balance_gap + (2UL << sc->order);
 	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, 0, 0);
@@ -2473,7 +2473,7 @@ static bool zone_balanced(struct zone *zone, int order,
  */
 static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 {
-	unsigned long present_pages = 0;
+	unsigned long managed_pages = 0;
 	unsigned long balanced_pages = 0;
 	int i;
 
@@ -2484,7 +2484,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 		if (!populated_zone(zone))
 			continue;
 
-		present_pages += zone->present_pages;
+		managed_pages += zone->managed_pages;
 
 		/*
 		 * A special case here:
@@ -2494,18 +2494,18 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 		 * they must be considered balanced here as well!
 		 */
 		if (zone->all_unreclaimable) {
-			balanced_pages += zone->present_pages;
+			balanced_pages += zone->managed_pages;
 			continue;
 		}
 
 		if (zone_balanced(zone, order, 0, i))
-			balanced_pages += zone->present_pages;
+			balanced_pages += zone->managed_pages;
 		else if (!order)
 			return false;
 	}
 
 	if (order)
-		return balanced_pages >= (present_pages >> 2);
+		return balanced_pages >= (managed_pages >> 2);
 	else
 		return true;
 }
@@ -2689,7 +2689,7 @@ loop_again:
 			 * of the zone, whichever is smaller.
 			 */
 			balance_gap = min(low_wmark_pages(zone),
-				(zone->present_pages +
+				(zone->managed_pages +
 					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
 				KSWAPD_ZONE_BALANCE_GAP_RATIO);
 			/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9800306..e3475f5 100644
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
