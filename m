Date: Tue, 17 Oct 2006 10:54:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <45347288.6040808@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Oct 2006, Nick Piggin wrote:

> I would give an ack to Kame's approach for lowmem_reserve ;)

Hmmm... One could define a constant in mmzone.h to get rid of lots of 
these ifdefs:

Single Zone Optimizations

If we only have a single zone then various macros can be optimized.

We do not need to protect higher zones, we know that zones are
always present, can remove useless data from /proc etc etc.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc1-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/vmstat.c	2006-10-17 07:27:45.419872964 -0500
+++ linux-2.6.19-rc1-mm1/mm/vmstat.c	2006-10-17 07:38:00.880502313 -0500
@@ -554,15 +554,16 @@ static int zoneinfo_show(struct seq_file
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			seq_printf(m, "\n    %-12s %lu", vmstat_text[i],
 					zone_page_state(zone, i));
-
-		seq_printf(m,
-			   "\n        protection: (%lu",
-			   zone->lowmem_reserve[0]);
-		for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
-			seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
-		seq_printf(m,
-			   ")"
-			   "\n  pagesets");
+		if (MULTI_ZONE) {
+			seq_printf(m,
+				   "\n        protection: (%lu",
+				   zone->lowmem_reserve[0]);
+			for (i = 1; i < ARRAY_SIZE(zone->lowmem_reserve); i++)
+			   seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
+			seq_printf(m,
+				   ")"
+				   "\n  pagesets");
+		}
 		for_each_online_cpu(i) {
 			struct per_cpu_pageset *pageset;
 			int j;
Index: linux-2.6.19-rc1-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/mm/page_alloc.c	2006-10-17 07:27:45.191337093 -0500
+++ linux-2.6.19-rc1-mm1/mm/page_alloc.c	2006-10-17 07:36:49.124176302 -0500
@@ -59,6 +59,7 @@ int percpu_pagelist_fraction;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
 
+#if MULTI_ZONE
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
  *	1G machine -> (16M dma, 800M-16M normal, 1G-800M high)
@@ -81,6 +82,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 	 32
 #endif
 };
+#endif
 
 EXPORT_SYMBOL(totalram_pages);
 
@@ -922,8 +924,7 @@ int zone_watermark_ok(struct zone *z, in
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
-
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + MULTI_ZONE * z->lowmem_reserve[classzone_idx])
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1429,8 +1430,6 @@ void show_free_areas(void)
 		global_page_state(NR_PAGETABLE));
 
 	for_each_zone(zone) {
-		int i;
-
 		if (!populated_zone(zone))
 			continue;
 
@@ -1457,10 +1456,14 @@ void show_free_areas(void)
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
 			);
-		printk("lowmem_reserve[]:");
-		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %lu", zone->lowmem_reserve[i]);
-		printk("\n");
+		if (MULTI_ZONE) {
+			int i;
+
+			printk("lowmem_reserve[]:");
+			for (i = 0; i < MAX_NR_ZONES; i++)
+				printk(" %lu", zone->lowmem_reserve[i]);
+			printk("\n");
+		}
 	}
 
 	for_each_zone(zone) {
@@ -2829,25 +2832,36 @@ void __init page_alloc_init(void)
  * calculate_totalreserve_pages - called when sysctl_lower_zone_reserve_ratio
  *	or min_free_kbytes changes.
  */
+static unsigned long calculate_max_lowmem_reserve(struct zone *zone,
+						enum zone_type start)
+{
+	unsigned long max;
+	enum zone_type i;
+
+	if (SINGLE_ZONE)
+		return 0;
+	/* Find valid and maximum lowmem_reserve in the zone */
+	for (i = start; i < MAX_NR_ZONES; i++) {
+		if (zone->lowmem_reserve[i] > max)
+			max = zone->lowmem_reserve[i];
+	}
+	return max;
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
@@ -2868,6 +2882,9 @@ static void setup_per_zone_lowmem_reserv
 	struct pglist_data *pgdat;
 	enum zone_type j, idx;
 
+	if (SINGLE_ZONE)
+		return 0;
+
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
 			struct zone *zone = pgdat->node_zones + j;
@@ -3044,6 +3061,7 @@ int sysctl_min_slab_ratio_sysctl_handler
 }
 #endif
 
+#if MULTI_ZONE
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *	proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
@@ -3060,6 +3078,7 @@ int lowmem_reserve_ratio_sysctl_handler(
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
+#endif
 
 /*
  * percpu_pagelist_fraction - changes the pcp->high for each zone on each
Index: linux-2.6.19-rc1-mm1/kernel/sysctl.c
===================================================================
--- linux-2.6.19-rc1-mm1.orig/kernel/sysctl.c	2006-10-17 07:27:44.692269445 -0500
+++ linux-2.6.19-rc1-mm1/kernel/sysctl.c	2006-10-17 07:38:47.977425889 -0500
@@ -900,6 +900,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	 },
 #endif
+#if MULTI_ZONE
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
--- linux-2.6.19-rc1-mm1.orig/include/linux/mmzone.h	2006-10-17 07:27:42.478206116 -0500
+++ linux-2.6.19-rc1-mm1/include/linux/mmzone.h	2006-10-17 07:34:40.134279959 -0500
@@ -171,6 +171,9 @@ enum zone_type {
 #endif
 #undef __ZONE_COUNT
 
+#define MULTI_ZONE (ZONES_SHIFT > 0)
+#define SINGLE_ZONE (ZONES_SHIFT == 0)
+
 struct zone {
 	/* Fields commonly accessed by the page allocator */
 	unsigned long		free_pages;
@@ -183,7 +186,7 @@ struct zone {
 	 * on the higher zones). This array is recalculated at runtime if the
 	 * sysctl_lowmem_reserve_ratio sysctl changes.
 	 */
-	unsigned long		lowmem_reserve[MAX_NR_ZONES];
+	unsigned long		lowmem_reserve[MAX_NR_ZONES - SINGLE_ZONE];
 
 #ifdef CONFIG_NUMA
 	int node;
@@ -420,11 +423,11 @@ unsigned long __init node_memmap_size_by
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		(MULTI_ZONE * ((zone) - (zone)->zone_pgdat->node_zones))
 
 static inline int populated_zone(struct zone *zone)
 {
-	return (!!zone->present_pages);
+	return SINGLE_ZONE || (!!zone->present_pages);
 }
 
 static inline int is_highmem_idx(enum zone_type idx)
@@ -438,7 +441,7 @@ static inline int is_highmem_idx(enum zo
 
 static inline int is_normal_idx(enum zone_type idx)
 {
-	return (idx == ZONE_NORMAL);
+	return SINGLE_ZONE || (idx == ZONE_NORMAL);
 }
 
 /**
@@ -458,7 +461,8 @@ static inline int is_highmem(struct zone
 
 static inline int is_normal(struct zone *zone)
 {
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+	return SINGLE_ZONE ||
+		zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
 }
 
 static inline int is_dma32(struct zone *zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
