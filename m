Date: Mon, 16 Oct 2006 17:50:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Page allocator: Single Zone optimizations
Message-ID: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The current code in 2.6.19-rc1-mm1 already allows the configuration of a 
system with a single zone. We observed significant performance gains which 
were likely due to the reduced cache footprint (removal of the zone_table 
also contributed).

This patch continues that line of work making the zone protection logic 
optional throwing out moreVM overhead that is not needed in the single 
zone case (which hopefully in the far future most of us will be able to 
use).

Also several macros can become constant if we know that only
a single zone exists (ZONES_SHIFT == 0) which will remove more code
from the VM and avoid runtime branching.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/vmstat.c	2006-10-16 03:42:57.322493498 -0500
+++ linux-2.6.19-rc1-mm1/mm/vmstat.c	2006-10-16 19:08:27.244098681 -0500
@@ -554,7 +554,7 @@ static int zoneinfo_show(struct seq_file
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
 					zone_page_state(zone, i));
-
+#if ZONES_SHIFT > 0
 		seq_printf(m,
 			   "\n        protection: (%lu",
 			   zone->lowmem_reserve[0]);
@@ -563,6 +563,7 @@ static int zoneinfo_show(struct seq_file
 		seq_printf(m,
 			   ")"
 			   "\n  pagesets");
+#endif
 		for_each_online_cpu(i) {
 			struct per_cpu_pageset *pageset;
 			int j;
Index: linux-2.6.19-rc1-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/page_alloc.c	2006-10-16 03:43:05.976552770 -0500
+++ linux-2.6.19-rc1-mm1/mm/page_alloc.c	2006-10-16 19:32:56.838407647 -0500
@@ -59,6 +59,7 @@ int percpu_pagelist_fraction;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
 
+#if ZONES_SHIFT > 0
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
  *	1G machine -> (16M dma, 800M-16M normal, 1G-800M high)
@@ -81,6 +82,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 	 32
 #endif
 };
+#endif
 
 EXPORT_SYMBOL(totalram_pages);
 
@@ -922,8 +924,11 @@ int zone_watermark_ok(struct zone *z, in
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
-
+#if ZONES_SHIFT == 0
+	if (free_pages <= min)
+#else
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+#endif
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1429,8 +1434,6 @@ void show_free_areas(void)
 		global_page_state(NR_PAGETABLE));
 
 	for_each_zone(zone) {
-		int i;
-
 		if (!populated_zone(zone))
 			continue;
 
@@ -1457,10 +1460,15 @@ void show_free_areas(void)
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
 			);
-		printk("lowmem_reserve[]:");
-		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %lu", zone->lowmem_reserve[i]);
-		printk("\n");
+#if ZONES_SHIFT > 0
+		{
+			int i;
+			printk("lowmem_reserve[]:");
+			for (i = 0; i < MAX_NR_ZONES; i++)
+				printk(" %lu", zone->lowmem_reserve[i]);
+			printk("\n");
+		}
+#endif
 	}
 
 	for_each_zone(zone) {
@@ -2829,25 +2837,38 @@ void __init page_alloc_init(void)
  * calculate_totalreserve_pages - called when sysctl_lower_zone_reserve_ratio
  *	or min_free_kbytes changes.
  */
+static unsigned long calculate_max_lowmem_reserve(struct zone *zone,
+						enum zone_type start)
+{
+#if ZONES_SHIFT > 0
+	unsigned long max;
+	enum zone_type i;
+
+	/* Find valid and maximum lowmem_reserve in the zone */
+	for (i = start; i < MAX_NR_ZONES; i++) {
+		if (zone->lowmem_reserve[i] > max)
+			max = zone->lowmem_reserve[i];
+	}
+	return max;
+#else
+	return 0;
+#endif
+}
+
 static void calculate_totalreserve_pages(void)
 {
 	struct pglist_data *pgdat;
 	unsigned long reserve_pages = 0;
-	enum zone_type i, j;
+	enum zone_type i;
 
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			unsigned long max = 0;
-
-			/* Find valid and maximum lowmem_reserve in the zone */
-			for (j = i; j < MAX_NR_ZONES; j++) {
-				if (zone->lowmem_reserve[j] > max)
-					max = zone->lowmem_reserve[j];
-			}
+			unsigned long max;
 
 			/* we treat pages_high as reserved pages. */
-			max += zone->pages_high;
+			max = calculate_max_lowmem_reserve(zone, i) + \
+						zone->pages_high;
 
 			if (max > zone->present_pages)
 				max = zone->present_pages;
@@ -2865,6 +2886,7 @@ static void calculate_totalreserve_pages
  */
 static void setup_per_zone_lowmem_reserve(void)
 {
+#if ZONES_SHIFT > 0
 	struct pglist_data *pgdat;
 	enum zone_type j, idx;
 
@@ -2894,6 +2916,7 @@ static void setup_per_zone_lowmem_reserv
 
 	/* update totalreserve_pages */
 	calculate_totalreserve_pages();
+#endif
 }
 
 /**
@@ -3044,6 +3067,7 @@ int sysctl_min_slab_ratio_sysctl_handler
 }
 #endif
 
+#if ZONES_SHIFT > 0
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *	proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
@@ -3060,6 +3084,7 @@ int lowmem_reserve_ratio_sysctl_handler(
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
+#endif
 
 /*
  * percpu_pagelist_fraction - changes the pcp->high for each zone on each
Index: linux-2.6.19-rc1-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/kernel/sysctl.c	2006-10-16 03:42:57.340073124 -0500
+++ linux-2.6.19-rc1-mm1/kernel/sysctl.c	2006-10-16 19:08:27.368132684 -0500
@@ -900,6 +900,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	 },
 #endif
+#if ZONES_SHIFT > 0
 	{
 		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
 		.procname	= "lowmem_reserve_ratio",
@@ -909,6 +910,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &lowmem_reserve_ratio_sysctl_handler,
 		.strategy	= &sysctl_intvec,
 	},
+#endif
 	{
 		.ctl_name	= VM_DROP_PAGECACHE,
 		.procname	= "drop_caches",
Index: linux-2.6.19-rc1-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.19-rc1-mm1.orig/include/linux/mmzone.h	2006-10-16 03:43:05.966786311 -0500
+++ linux-2.6.19-rc1-mm1/include/linux/mmzone.h	2006-10-16 19:24:44.378702936 -0500
@@ -175,6 +175,7 @@ struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		free_pages;
 	unsigned long		pages_min, pages_low, pages_high;
+#if ZONES_SHIFT > 0
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
@@ -184,6 +185,7 @@ struct zone {
 	 * sysctl_lowmem_reserve_ratio sysctl changes.
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
+#endif
 
 #ifdef CONFIG_NUMA
 	int node;
@@ -420,11 +422,19 @@ unsigned long __init node_memmap_size_by
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
+#if ZONES_SHIFT > 0
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#else
+#define zone_idx(zone)		ZONE_NORMAL
+#endif
 
 static inline int populated_zone(struct zone *zone)
 {
+#if ZONES_SHIFT > 0
 	return (!!zone->present_pages);
+#else
+	return 1;
+#endif
 }
 
 static inline int is_highmem_idx(enum zone_type idx)
@@ -438,7 +448,11 @@ static inline int is_highmem_idx(enum zo
 
 static inline int is_normal_idx(enum zone_type idx)
 {
+#if ZONES_SHIFT > 0
 	return (idx == ZONE_NORMAL);
+#else
+	return 1;
+#endif
 }
 
 /**
@@ -458,7 +472,11 @@ static inline int is_highmem(struct zone
 
 static inline int is_normal(struct zone *zone)
 {
+#if ZONES_SHIFT > 0
 	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+#else
+	return 1;
+#endif
 }
 
 static inline int is_dma32(struct zone *zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
