Date: Mon, 23 Oct 2006 16:08:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061018123840.a67e6a44.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Single Zone Optimizations V2

V1->V2 Use a config variable setup im mm/KConfig

If we only have a single zone then various macros can be optimized.
We do not need to protect higher zones, we know that zones are
always present, can remove useless data from /proc etc etc. Various
code paths become unnecessary with a single zone setup.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc2-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/vmstat.c	2006-10-23 17:51:51.816819354 -0500
+++ linux-2.6.19-rc2-mm2/mm/vmstat.c	2006-10-23 17:52:35.777558863 -0500
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
+		if (CONFIG_MULTI_ZONE) {
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
Index: linux-2.6.19-rc2-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/page_alloc.c	2006-10-23 17:51:51.824632513 -0500
+++ linux-2.6.19-rc2-mm2/mm/page_alloc.c	2006-10-23 17:52:35.819554594 -0500
@@ -60,6 +60,7 @@ int percpu_pagelist_fraction;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
 
+#if CONFIG_MULTI_ZONE
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
  *	1G machine -> (16M dma, 800M-16M normal, 1G-800M high)
@@ -82,6 +83,7 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 	 32
 #endif
 };
+#endif
 
 EXPORT_SYMBOL(totalram_pages);
 
@@ -923,8 +925,8 @@ int zone_watermark_ok(struct zone *z, in
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
-
-	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + CONFIG_MULTI_ZONE *
+				z->lowmem_reserve[classzone_idx])
 		return 0;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -1581,8 +1583,6 @@ void show_free_areas(void)
 		global_page_state(NR_PAGETABLE));
 
 	for_each_zone(zone) {
-		int i;
-
 		if (!populated_zone(zone))
 			continue;
 
@@ -1609,10 +1609,14 @@ void show_free_areas(void)
 			zone->pages_scanned,
 			(zone->all_unreclaimable ? "yes" : "no")
 			);
-		printk("lowmem_reserve[]:");
-		for (i = 0; i < MAX_NR_ZONES; i++)
-			printk(" %lu", zone->lowmem_reserve[i]);
-		printk("\n");
+		if (CONFIG_MULTI_ZONE) {
+			int i;
+
+			printk("lowmem_reserve[]:");
+			for (i = 0; i < MAX_NR_ZONES; i++)
+				printk(" %lu", zone->lowmem_reserve[i]);
+			printk("\n");
+		}
 	}
 
 	for_each_zone(zone) {
@@ -3011,25 +3015,37 @@ void __init page_alloc_init(void)
  * calculate_totalreserve_pages - called when sysctl_lower_zone_reserve_ratio
  *	or min_free_kbytes changes.
  */
+static unsigned long calculate_max_lowmem_reserve(struct zone *zone,
+						enum zone_type start)
+{
+	unsigned long max;
+	enum zone_type i;
+
+	if (!CONFIG_MULTI_ZONE)
+		return 0;
+
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
@@ -3050,6 +3066,9 @@ static void setup_per_zone_lowmem_reserv
 	struct pglist_data *pgdat;
 	enum zone_type j, idx;
 
+	if (!CONFIG_MULTI_ZONE)
+		return 0;
+
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
 			struct zone *zone = pgdat->node_zones + j;
@@ -3226,6 +3245,7 @@ int sysctl_min_slab_ratio_sysctl_handler
 }
 #endif
 
+#if CONFIG_MULTI_ZONE
 /*
  * lowmem_reserve_ratio_sysctl_handler - just a wrapper around
  *	proc_dointvec() so that we can call setup_per_zone_lowmem_reserve()
@@ -3242,6 +3262,7 @@ int lowmem_reserve_ratio_sysctl_handler(
 	setup_per_zone_lowmem_reserve();
 	return 0;
 }
+#endif
 
 /*
  * percpu_pagelist_fraction - changes the pcp->high for each zone on each
Index: linux-2.6.19-rc2-mm2/kernel/sysctl.c
===================================================================
--- linux-2.6.19-rc2-mm2.orig/kernel/sysctl.c	2006-10-23 17:51:51.852955214 -0500
+++ linux-2.6.19-rc2-mm2/kernel/sysctl.c	2006-10-23 17:52:35.863503614 -0500
@@ -904,6 +904,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &proc_dointvec,
 	 },
 #endif
+#if CONFIG_MULTI_ZONE
 	{
 		.ctl_name	= VM_LOWMEM_RESERVE_RATIO,
 		.procname	= "lowmem_reserve_ratio",
@@ -913,6 +914,7 @@ static ctl_table vm_table[] = {
 		.proc_handler	= &lowmem_reserve_ratio_sysctl_handler,
 		.strategy	= &sysctl_intvec,
 	},
+#endif
 	{
 		.ctl_name	= VM_DROP_PAGECACHE,
 		.procname	= "drop_caches",
Index: linux-2.6.19-rc2-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.19-rc2-mm2.orig/include/linux/mmzone.h	2006-10-23 17:51:51.879324626 -0500
+++ linux-2.6.19-rc2-mm2/include/linux/mmzone.h	2006-10-23 17:52:35.882059867 -0500
@@ -491,11 +491,12 @@ unsigned long __init node_memmap_size_by
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)	(CONFIG_MULTI_ZONE * \
+			((zone) - (zone)->zone_pgdat->node_zones))
 
 static inline int populated_zone(struct zone *zone)
 {
-	return (!!zone->present_pages);
+	return !CONFIG_MULTI_ZONE || (!!zone->present_pages);
 }
 
 static inline int is_highmem_idx(enum zone_type idx)
@@ -509,7 +510,7 @@ static inline int is_highmem_idx(enum zo
 
 static inline int is_normal_idx(enum zone_type idx)
 {
-	return (idx == ZONE_NORMAL);
+	return !CONFIG_MULTI_ZONE || (idx == ZONE_NORMAL);
 }
 
 /**
@@ -529,7 +530,8 @@ static inline int is_highmem(struct zone
 
 static inline int is_normal(struct zone *zone)
 {
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
+	return !CONFIG_MULTI_ZONE ||
+		zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
 }
 
 static inline int is_dma32(struct zone *zone)
Index: linux-2.6.19-rc2-mm2/mm/Kconfig
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/Kconfig	2006-10-23 17:52:25.537437185 -0500
+++ linux-2.6.19-rc2-mm2/mm/Kconfig	2006-10-23 17:52:35.890849671 -0500
@@ -248,3 +248,7 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config MULTI_ZONE
+	int
+	default "1"
+	default "0" if !ZONE_DMA && !ZONE_DMA32 && !HIGHMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
