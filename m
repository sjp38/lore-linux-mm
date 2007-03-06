Date: Tue, 6 Mar 2007 13:45:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [4/16] ZONE_MOVABLE
Message-Id: <20070306134549.174cc160.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add ZONE_MOVABLE.

This zone is only used for migratable/reclaimable pages.

zone order is
	[ZONE_DMA],
	[ZONE_DMA32],
	ZONE_NORMAL,
	[ZONE_HIGHMEM],
	[ZONE_MOVABLE],
	MAX_NR_ZONES
if highmem is configured, movable zone is not identitiy-mapped.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mmzone.h |   29 +++++++
 mm/Kconfig             |    4 +
 mm/page_alloc.c        |  180 ++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 211 insertions(+), 2 deletions(-)

Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
+++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
@@ -142,6 +142,16 @@ enum zone_type {
 	 */
 	ZONE_HIGHMEM,
 #endif
+#ifdef CONFIG_ZONE_MOVABLE
+	/*
+	 * This memory area is used only for migratable pages.
+	 * We have a chance to hot-remove memory in this zone.
+	 * Currently, anonymous memory and usual page cache etc. are included.
+	 * if HIGHMEM is configured, MOVABLE zone is treated as
+         * not-direct-mapped-memory for kernel;.
+	 */
+	ZONE_MOVABLE,
+#endif
 	MAX_NR_ZONES,
 #ifndef CONFIG_ZONE_DMA
 	ZONE_DMA,
@@ -152,6 +162,9 @@ enum zone_type {
 #ifndef CONFIG_HIGHMEM
 	ZONE_HIGHMEM,
 #endif
+#ifndef CONFIG_ZONE_MOVABLE
+	ZONE_MOVABLE,
+#endif
 	MAX_POSSIBLE_ZONES
 };
 
@@ -172,13 +185,18 @@ static inline int is_configured_zone(enu
  * Count the active zones.  Note that the use of defined(X) outside
  * #if and family is not necessarily defined so ensure we cannot use
  * it later.  Use __ZONE_COUNT to work out how many shift bits we need.
+ *
+ * Assumes ZONE_DMA32,ZONE_HIGHMEM, ZONE_MOVABLE can't be configured at
+ * the same time.
  */
 #define __ZONE_COUNT (			\
 	  defined(CONFIG_ZONE_DMA)	\
 	+ defined(CONFIG_ZONE_DMA32)	\
 	+ 1				\
 	+ defined(CONFIG_HIGHMEM)	\
+	+ defined(CONFIG_ZONE_MOVABLE) \
 )
+
 #if __ZONE_COUNT < 2
 #define ZONES_SHIFT 0
 #elif __ZONE_COUNT <= 2
@@ -513,6 +531,11 @@ static inline int populated_zone(struct 
 	return (!!zone->present_pages);
 }
 
+static inline int is_movable_dix(enum zone_type idx)
+{
+	return (idx == ZONE_MOVABLE);
+}
+
 static inline int is_highmem_idx(enum zone_type idx)
 {
 	return (idx == ZONE_HIGHMEM);
@@ -536,6 +559,12 @@ static inline int is_identity_map_idx(en
  *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
  * @zone - pointer to struct zone variable
  */
+
+static inline int is_movable(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_MOVABLE;
+}
+
 static inline int is_highmem(struct zone *zone)
 {
 	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -82,6 +82,7 @@ static char name_dma[] = "DMA";
 static char name_dma32[] = "DMA32";
 static char name_normal[] = "Normal";
 static char name_highmem[] = "Highmem";
+static char name_movable[] = "Movable";
 
 static inline void __meminit zone_variables_init(void)
 {
@@ -91,6 +92,7 @@ static inline void __meminit zone_variab
 	zone_names[ZONE_DMA32] = name_dma32;
 	zone_names[ZONE_NORMAL] = name_normal;
 	zone_names[ZONE_HIGHMEM] = name_highmem;
+	zone_names[ZONE_MOVABLE] = name_movable;
 
 	/* ZONE below NORAML has ratio 256 */
 	if (is_configured_zone(ZONE_DMA))
@@ -99,6 +101,8 @@ static inline void __meminit zone_variab
 		sysctl_lowmem_reserve_ratio[ZONE_DMA32] = 256;
 	if (is_configured_zone(ZONE_HIGHMEM))
 		sysctl_lowmem_reserve_ratio[ZONE_HIGHMEM] = 32;
+	if (is_configured_zone(ZONE_MOVABLE))
+		sysctl_lowmem_reserve_ratio[ZONE_MOVABLE] = 32;
 }
 
 int min_free_kbytes = 1024;
@@ -3065,11 +3069,17 @@ void __init free_area_init_nodes(unsigne
 	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
 	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
 	for (i = 1; i < MAX_NR_ZONES; i++) {
+		if (i == ZONE_MOVABLE)
+			continue;
 		arch_zone_lowest_possible_pfn[i] =
 			arch_zone_highest_possible_pfn[i-1];
 		arch_zone_highest_possible_pfn[i] =
 			max(max_zone_pfn[i], arch_zone_lowest_possible_pfn[i]);
 	}
+	if (is_configured_zone(ZONE_MOVABLE)) {
+		arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
+		arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
+	}
 
 	/* Print out the page size for debugging meminit problems */
 	printk(KERN_DEBUG "sizeof(struct page) = %zd\n", sizeof(struct page));
@@ -3097,6 +3107,7 @@ void __init free_area_init_nodes(unsigne
 				find_min_pfn_for_node(nid), NULL);
 	}
 }
+
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 /**
Index: devel-tree-2.6.20-mm2/mm/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/Kconfig
+++ devel-tree-2.6.20-mm2/mm/Kconfig
@@ -163,6 +163,10 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config ZONE_MOVABLE
+	bool "Create zones for MOVABLE pages"
+	depends on ARCH_POPULATES_NODE_MAP
+	depends on MIGRATION
 #
 # Adaptive file readahead
 #

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
