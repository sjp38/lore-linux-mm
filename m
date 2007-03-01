From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100842.30048.51713.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
References: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/8] Create the ZONE_MOVABLE zone
Date: Thu,  1 Mar 2007 10:08:42 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch creates an additional zone, ZONE_MOVABLE.  This zone is only
usable by allocations which specify both __GFP_HIGHMEM and __GFP_MOVABLE.
Hot-added memory continues to be placed in their existing destination as
there is no mechanism to redirect them to a specific zone.


Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/gfp.h    |    3 
 include/linux/mm.h     |    1 
 include/linux/mmzone.h |   19 +++
 include/linux/vmstat.h |    5 
 mm/highmem.c           |    7 +
 mm/page_alloc.c        |  229 +++++++++++++++++++++++++++++++++++++++++++-
 mm/vmstat.c            |    2 
 7 files changed, 256 insertions(+), 10 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/include/linux/gfp.h linux-2.6.20-mm2-002_create_movable_zone/include/linux/gfp.h
--- linux-2.6.20-mm2-001_mark_highmovable/include/linux/gfp.h	2007-02-19 09:08:29.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/include/linux/gfp.h	2007-02-19 09:10:58.000000000 +0000
@@ -101,6 +101,9 @@ static inline enum zone_type gfp_zone(gf
 	if (flags & __GFP_DMA32)
 		return ZONE_DMA32;
 #endif
+	if ((flags & (__GFP_HIGHMEM | __GFP_MOVABLE)) ==
+			(__GFP_HIGHMEM | __GFP_MOVABLE))
+		return ZONE_MOVABLE;
 #ifdef CONFIG_HIGHMEM
 	if (flags & __GFP_HIGHMEM)
 		return ZONE_HIGHMEM;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/include/linux/mm.h linux-2.6.20-mm2-002_create_movable_zone/include/linux/mm.h
--- linux-2.6.20-mm2-001_mark_highmovable/include/linux/mm.h	2007-02-19 01:22:30.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/include/linux/mm.h	2007-02-19 09:10:58.000000000 +0000
@@ -977,6 +977,7 @@ extern unsigned long find_max_pfn_with_a
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
 extern void sparse_memory_present_with_active_regions(int nid);
+extern int cmdline_parse_kernelcore(char *p);
 #ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
 extern int early_pfn_to_nid(unsigned long pfn);
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/include/linux/mmzone.h linux-2.6.20-mm2-002_create_movable_zone/include/linux/mmzone.h
--- linux-2.6.20-mm2-001_mark_highmovable/include/linux/mmzone.h	2007-02-19 01:22:30.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/include/linux/mmzone.h	2007-02-19 09:10:58.000000000 +0000
@@ -142,6 +142,7 @@ enum zone_type {
 	 */
 	ZONE_HIGHMEM,
 #endif
+	ZONE_MOVABLE,
 	MAX_NR_ZONES
 };
 
@@ -163,6 +164,7 @@ enum zone_type {
 	+ defined(CONFIG_ZONE_DMA32)	\
 	+ 1				\
 	+ defined(CONFIG_HIGHMEM)	\
+	+ 1				\
 )
 #if __ZONE_COUNT < 2
 #define ZONES_SHIFT 0
@@ -498,10 +500,21 @@ static inline int populated_zone(struct 
 	return (!!zone->present_pages);
 }
 
+extern int movable_zone;
+static inline int zone_movable_is_highmem(void)
+{
+#ifdef CONFIG_HIGHMEM
+	return movable_zone == ZONE_HIGHMEM;
+#else
+	return 0;
+#endif
+}
+
 static inline int is_highmem_idx(enum zone_type idx)
 {
 #ifdef CONFIG_HIGHMEM
-	return (idx == ZONE_HIGHMEM);
+	return (idx == ZONE_HIGHMEM ||
+		(idx == ZONE_MOVABLE && zone_movable_is_highmem()));
 #else
 	return 0;
 #endif
@@ -521,7 +534,9 @@ static inline int is_normal_idx(enum zon
 static inline int is_highmem(struct zone *zone)
 {
 #ifdef CONFIG_HIGHMEM
-	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
+	int zone_idx = zone - zone->zone_pgdat->node_zones;
+	return zone_idx == ZONE_HIGHMEM ||
+		(zone_idx == ZONE_MOVABLE && zone_movable_is_highmem());
 #else
 	return 0;
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/include/linux/vmstat.h linux-2.6.20-mm2-002_create_movable_zone/include/linux/vmstat.h
--- linux-2.6.20-mm2-001_mark_highmovable/include/linux/vmstat.h	2007-02-19 01:22:32.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/include/linux/vmstat.h	2007-02-19 09:10:58.000000000 +0000
@@ -25,7 +25,7 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx)
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
@@ -172,7 +172,8 @@ static inline unsigned long node_page_st
 #ifdef CONFIG_HIGHMEM
 		zone_page_state(&zones[ZONE_HIGHMEM], item) +
 #endif
-		zone_page_state(&zones[ZONE_NORMAL], item);
+		zone_page_state(&zones[ZONE_NORMAL], item) +
+		zone_page_state(&zones[ZONE_MOVABLE], item);
 }
 
 extern void zone_statistics(struct zonelist *, struct zone *);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/mm/highmem.c linux-2.6.20-mm2-002_create_movable_zone/mm/highmem.c
--- linux-2.6.20-mm2-001_mark_highmovable/mm/highmem.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/mm/highmem.c	2007-02-19 09:10:58.000000000 +0000
@@ -46,9 +46,14 @@ unsigned int nr_free_highpages (void)
 	pg_data_t *pgdat;
 	unsigned int pages = 0;
 
-	for_each_online_pgdat(pgdat)
+	for_each_online_pgdat(pgdat) {
 		pages += zone_page_state(&pgdat->node_zones[ZONE_HIGHMEM],
 			NR_FREE_PAGES);
+		if (zone_movable_is_highmem())
+			pages += zone_page_state(
+					&pgdat->node_zones[ZONE_MOVABLE],
+					NR_FREE_PAGES);
+	}
 
 	return pages;
 }
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/mm/page_alloc.c linux-2.6.20-mm2-002_create_movable_zone/mm/page_alloc.c
--- linux-2.6.20-mm2-001_mark_highmovable/mm/page_alloc.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/mm/page_alloc.c	2007-02-19 09:10:58.000000000 +0000
@@ -80,8 +80,9 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_Z
 	 256,
 #endif
 #ifdef CONFIG_HIGHMEM
-	 32
+	 32,
 #endif
+	 32,
 };
 
 EXPORT_SYMBOL(totalram_pages);
@@ -95,8 +96,9 @@ static char * const zone_names[MAX_NR_ZO
 #endif
 	 "Normal",
 #ifdef CONFIG_HIGHMEM
-	 "HighMem"
+	 "HighMem",
 #endif
+	 "Movable",
 };
 
 int min_free_kbytes = 1024;
@@ -134,6 +136,12 @@ static unsigned long __initdata dma_rese
   unsigned long __initdata node_boundary_start_pfn[MAX_NUMNODES];
   unsigned long __initdata node_boundary_end_pfn[MAX_NUMNODES];
 #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
+  unsigned long __initdata required_kernelcore;
+  unsigned long __initdata zone_movable_pfn[MAX_NUMNODES];
+
+  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
+  int movable_zone;
+  EXPORT_SYMBOL(movable_zone);
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 #ifdef CONFIG_DEBUG_VM
@@ -1578,7 +1586,7 @@ unsigned int nr_free_buffer_pages(void)
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER));
+	return nr_free_zone_pages(gfp_zone(GFP_HIGH_MOVABLE));
 }
 
 /*
@@ -2567,6 +2575,63 @@ void __init get_pfn_range_for_nid(unsign
 }
 
 /*
+ * This finds a zone that can be used for ZONE_MOVABLE pages. The
+ * assumption is made that zones within a node are ordered in monotonic
+ * increasing memory addresses so that the "highest" populated zone is used
+ */
+void __init find_usable_zone_for_movable(void)
+{
+	int zone_index;
+	for (zone_index = MAX_NR_ZONES - 1; zone_index >= 0; zone_index--) {
+		if (zone_index == ZONE_MOVABLE)
+			continue;
+
+		if (arch_zone_highest_possible_pfn[zone_index] >
+				arch_zone_lowest_possible_pfn[zone_index])
+			break;
+	}
+
+	VM_BUG_ON(zone_index == -1);
+	movable_zone = zone_index;
+}
+
+/*
+ * The zone ranges provided by the architecture do not include ZONE_MOVABLE
+ * because it is sized independant of architecture. Unlike the other zones,
+ * the starting point for ZONE_MOVABLE is not fixed. It may be different
+ * in each node depending on the size of each node and how evenly kernelcore
+ * is distributed. This helper function adjusts the zone ranges
+ * provided by the architecture for a given node by using the end of the
+ * highest usable zone for ZONE_MOVABLE. This preserves the assumption that
+ * zones within a node are in order of monotonic increases memory addresses
+ */
+void __init adjust_zone_range_for_zone_movable(int nid,
+					unsigned long zone_type,
+					unsigned long node_start_pfn,
+					unsigned long node_end_pfn,
+					unsigned long *zone_start_pfn,
+					unsigned long *zone_end_pfn)
+{
+	/* Only adjust if ZONE_MOVABLE is on this node */
+	if (zone_movable_pfn[nid]) {
+		/* Size ZONE_MOVABLE */
+		if (zone_type == ZONE_MOVABLE) {
+			*zone_start_pfn = zone_movable_pfn[nid];
+			*zone_end_pfn = min(node_end_pfn,
+				arch_zone_highest_possible_pfn[movable_zone]);
+
+		/* Adjust for ZONE_MOVABLE starting within this range */
+		} else if (*zone_start_pfn < zone_movable_pfn[nid] &&
+				*zone_end_pfn > zone_movable_pfn[nid]) {
+			*zone_end_pfn = zone_movable_pfn[nid];
+
+		/* Check if this whole range is within ZONE_MOVABLE */
+		} else if (*zone_start_pfn >= zone_movable_pfn[nid])
+			*zone_start_pfn = *zone_end_pfn;
+	}
+}
+
+/*
  * Return the number of pages a zone spans in a node, including holes
  * present_pages = zone_spanned_pages_in_node() - zone_absent_pages_in_node()
  */
@@ -2581,6 +2646,9 @@ unsigned long __init zone_spanned_pages_
 	get_pfn_range_for_nid(nid, &node_start_pfn, &node_end_pfn);
 	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
 	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	adjust_zone_range_for_zone_movable(nid, zone_type,
+				node_start_pfn, node_end_pfn,
+				&zone_start_pfn, &zone_end_pfn);
 
 	/* Check that this node has pages within the zone's required range */
 	if (zone_end_pfn < node_start_pfn || zone_start_pfn > node_end_pfn)
@@ -2671,6 +2739,9 @@ unsigned long __init zone_absent_pages_i
 	zone_end_pfn = min(arch_zone_highest_possible_pfn[zone_type],
 							node_end_pfn);
 
+	adjust_zone_range_for_zone_movable(nid, zone_type,
+			node_start_pfn, node_end_pfn,
+			&zone_start_pfn, &zone_end_pfn);
 	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
 }
 
@@ -3031,6 +3102,117 @@ unsigned long __init find_max_pfn_with_a
 	return max_pfn;
 }
 
+/*
+ * Find the PFN the Movable zone begins in each node. Kernel memory
+ * is spread evenly between nodes as long as the nodes have enough
+ * memory. When they don't, some nodes will have more kernelcore than
+ * others
+ */
+void __init find_zone_movable_pfns_for_nodes(unsigned long *movable_pfn)
+{
+	int i, nid;
+	unsigned long usable_startpfn;
+	unsigned long kernelcore_node, kernelcore_remaining;
+	int usable_nodes = num_online_nodes();
+
+	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
+	if (!required_kernelcore)
+		return;
+
+	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
+	find_usable_zone_for_movable();
+	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
+
+restart:
+	/* Spread kernelcore memory as evenly as possible throughout nodes */
+	kernelcore_node = required_kernelcore / usable_nodes;
+	for_each_online_node(nid) {
+		/*
+		 * Recalculate kernelcore_node if the division per node
+		 * now exceeds what is necessary to satisfy the requested
+		 * amount of memory for the kernel
+		 */
+		if (required_kernelcore < kernelcore_node)
+			kernelcore_node = required_kernelcore / usable_nodes;
+
+		/*
+		 * As the map is walked, we track how much memory is usable
+		 * by the kernel using kernelcore_remaining. When it is
+		 * 0, the rest of the node is usable by ZONE_MOVABLE
+		 */
+		kernelcore_remaining = kernelcore_node;
+
+		/* Go through each range of PFNs within this node */
+		for_each_active_range_index_in_nid(i, nid) {
+			unsigned long start_pfn, end_pfn;
+			unsigned long size_pages;
+
+			start_pfn = max(early_node_map[i].start_pfn,
+						zone_movable_pfn[nid]);
+			end_pfn = early_node_map[i].end_pfn;
+			if (start_pfn >= end_pfn)
+				continue;
+
+			/* Account for what is only usable for kernelcore */
+			if (start_pfn < usable_startpfn) {
+				unsigned long kernel_pages;
+				kernel_pages = min(end_pfn, usable_startpfn)
+								- start_pfn;
+
+				kernelcore_remaining -= min(kernel_pages,
+							kernelcore_remaining);
+				required_kernelcore -= min(kernel_pages,
+							required_kernelcore);
+
+				/* Continue if range is now fully accounted */
+				if (end_pfn <= usable_startpfn) {
+
+					/*
+					 * Push zone_movable_pfn to the end so
+					 * that if we have to rebalance
+					 * kernelcore across nodes, we will
+					 * not double account here
+					 */
+					zone_movable_pfn[nid] = end_pfn;
+					continue;
+				}
+				start_pfn = usable_startpfn;
+			}
+
+			/*
+			 * The usable PFN range for ZONE_MOVABLE is from
+			 * start_pfn->end_pfn. Calculate size_pages as the
+			 * number of pages used as kernelcore
+			 */
+			size_pages = end_pfn - start_pfn;
+			if (size_pages > kernelcore_remaining)
+				size_pages = kernelcore_remaining;
+			zone_movable_pfn[nid] = start_pfn + size_pages;
+
+			/*
+			 * Some kernelcore has been met, update counts and
+			 * break if the kernelcore for this node has been
+			 * satisified
+			 */
+			required_kernelcore -= min(required_kernelcore,
+								size_pages);
+			kernelcore_remaining -= size_pages;
+			if (!kernelcore_remaining)
+				break;
+		}
+	}
+
+	/*
+	 * If there is still required_kernelcore, we do another pass with one
+	 * less node in the count. This will push zone_movable_pfn[nid] further
+	 * along on the nodes that still have memory until kernelcore is
+	 * satisified
+	 */
+	usable_nodes--;
+	if (usable_nodes && required_kernelcore > usable_nodes)
+		goto restart;
+}
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -3060,22 +3242,42 @@ void __init free_area_init_nodes(unsigne
 	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
 	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
 	for (i = 1; i < MAX_NR_ZONES; i++) {
+		if (i == ZONE_MOVABLE)
+			continue;
+
 		arch_zone_lowest_possible_pfn[i] =
 			arch_zone_highest_possible_pfn[i-1];
 		arch_zone_highest_possible_pfn[i] =
 			max(max_zone_pfn[i], arch_zone_lowest_possible_pfn[i]);
 	}
+	arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
+	arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
 
 	/* Print out the page size for debugging meminit problems */
 	printk(KERN_DEBUG "sizeof(struct page) = %zd\n", sizeof(struct page));
 
+	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
+	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
+	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
+
 	/* Print out the zone ranges */
 	printk("Zone PFN ranges:\n");
-	for (i = 0; i < MAX_NR_ZONES; i++)
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		if (i == ZONE_MOVABLE)
+			continue;
+
 		printk("  %-8s %8lu -> %8lu\n",
 				zone_names[i],
 				arch_zone_lowest_possible_pfn[i],
 				arch_zone_highest_possible_pfn[i]);
+	}
+
+	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
+	printk("Movable zone start PFN for each node\n");
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		if (zone_movable_pfn[i])
+			printk("  Node %d: %lu\n", i, zone_movable_pfn[i]);
+	}
 
 	/* Print out the early_node_map[] */
 	printk("early_node_map[%d] active PFN ranges\n", nr_nodemap_entries);
@@ -3092,6 +3294,25 @@ void __init free_area_init_nodes(unsigne
 				find_min_pfn_for_node(nid), NULL);
 	}
 }
+
+/*
+ * kernelcore=size sets the amount of memory for use for allocations that
+ * cannot be reclaimed or migrated.
+ */
+int __init cmdline_parse_kernelcore(char *p)
+{
+	unsigned long long coremem;
+	if (!p)
+		return -EINVAL;
+
+	coremem = memparse(p, &p);
+	required_kernelcore = coremem >> PAGE_SHIFT;
+
+	/* Paranoid check that UL is enough for required_kernelcore */
+	WARN_ON((coremem >> PAGE_SHIFT) > ULONG_MAX);
+
+	return 0;
+}
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 /**
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_mark_highmovable/mm/vmstat.c linux-2.6.20-mm2-002_create_movable_zone/mm/vmstat.c
--- linux-2.6.20-mm2-001_mark_highmovable/mm/vmstat.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_create_movable_zone/mm/vmstat.c	2007-02-19 09:10:58.000000000 +0000
@@ -427,7 +427,7 @@ const struct seq_operations fragmentatio
 #endif
 
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx)
+					TEXT_FOR_HIGHMEM(xx) xx "_movable",
 
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
