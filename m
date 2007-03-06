Date: Tue, 6 Mar 2007 13:52:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [9/16] create movable zone at
 boot
Message-Id: <20070306135232.42a55807.kamezawa.hiroyu@jp.fujitsu.com>
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

This patch adds codes for creating movable zones.

Add 2 kernel paramers.
- kernel_core_pages=XXX[KMG]
- kernel_core_ratio=xx

When kernel_core_pages is specified, create zone(s) for not-movable pages
from lower address and make the amount of it to specified size.
Maybe good for non-NUMA environment and node-hot-remove.

When kernel_core_ratio is specified, create zone(s) for not-movable pages
on each node. The amount of not-movable-zone is calucated as

 memory_on_node * kernel_core_ratio/100.

Maybe good for NUMA environment and just want to use MOVABLE zone.

Note:
Changes to zone_spanned_pages_in_node()/absent_pages_in_node() looks ugly...
And, this boot option is just a sample. I'll change this when I find a better
way to go.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/kernel-parameters.txt |   11 ++
 include/linux/mmzone.h              |    3 
 mm/page_alloc.c                     |  198 +++++++++++++++++++++++++++++++++---
 3 files changed, 199 insertions(+), 13 deletions(-)

Index: devel-tree-2.6.20-mm2/mm/page_alloc.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/page_alloc.c
+++ devel-tree-2.6.20-mm2/mm/page_alloc.c
@@ -137,12 +137,16 @@ static unsigned long __initdata dma_rese
   int __initdata nr_nodemap_entries;
   unsigned long __initdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
   unsigned long __initdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
+  unsigned long __initdata lowest_movable_pfn[MAX_NUMNODES];
+  unsigned long kernel_core_ratio;
+  unsigned long kernel_core_pages;
 #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
   unsigned long __initdata node_boundary_start_pfn[MAX_NUMNODES];
   unsigned long __initdata node_boundary_end_pfn[MAX_NUMNODES];
 #endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
+
 #ifdef CONFIG_DEBUG_VM
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
@@ -2604,6 +2608,8 @@ void __init get_pfn_range_for_nid(unsign
  */
 unsigned long __init zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
+					unsigned long *start_pfn,
+					unsigned long *end_pfn,
 					unsigned long *ignored)
 {
 	unsigned long node_start_pfn, node_end_pfn;
@@ -2611,8 +2617,30 @@ unsigned long __init zone_spanned_pages_
 
 	/* Get the start and end of the node and zone */
 	get_pfn_range_for_nid(nid, &node_start_pfn, &node_end_pfn);
-	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
-	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	if (start_pfn)
+		*start_pfn = 0;
+	if (end_pfn)
+		*end_pfn = 0;
+	if (!is_configured_zone(ZONE_MOVABLE) ||
+		   lowest_movable_pfn[nid] == 0) {
+		/* we don't use ZONE_MOVABLE */
+		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
+		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	} else if (zone_type == ZONE_MOVABLE) {
+		zone_start_pfn = lowest_movable_pfn[nid];
+		zone_end_pfn = node_end_pfn;
+	} else {
+		/* adjust range to lowest_movable_pfn[] */
+		zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
+		zone_start_pfn = max(zone_start_pfn, node_start_pfn);
+
+		if (zone_start_pfn >= lowest_movable_pfn[nid])
+			return 0;
+		zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+		zone_end_pfn = min(zone_end_pfn, node_end_pfn);
+		if (zone_end_pfn > lowest_movable_pfn[nid])
+			zone_end_pfn = lowest_movable_pfn[nid];
+	}
 
 	/* Check that this node has pages within the zone's required range */
 	if (zone_end_pfn < node_start_pfn || zone_start_pfn > node_end_pfn)
@@ -2621,8 +2649,11 @@ unsigned long __init zone_spanned_pages_
 	/* Move the zone boundaries inside the node if necessary */
 	zone_end_pfn = min(zone_end_pfn, node_end_pfn);
 	zone_start_pfn = max(zone_start_pfn, node_start_pfn);
-
 	/* Return the spanned pages */
+	if (start_pfn)
+		*start_pfn = zone_start_pfn;
+	if (end_pfn)
+		*end_pfn = zone_end_pfn;
 	return zone_end_pfn - zone_start_pfn;
 }
 
@@ -2692,16 +2723,24 @@ unsigned long __init absent_pages_in_ran
 /* Return the number of page frames in holes in a zone on a node */
 unsigned long __init zone_absent_pages_in_node(int nid,
 					unsigned long zone_type,
+					unsigned long start,
+					unsigned long end,
 					unsigned long *ignored)
 {
 	unsigned long node_start_pfn, node_end_pfn;
 	unsigned long zone_start_pfn, zone_end_pfn;
 
 	get_pfn_range_for_nid(nid, &node_start_pfn, &node_end_pfn);
-	zone_start_pfn = max(arch_zone_lowest_possible_pfn[zone_type],
-							node_start_pfn);
-	zone_end_pfn = min(arch_zone_highest_possible_pfn[zone_type],
-							node_end_pfn);
+	if (start == 0 && end == 0) {
+		zone_start_pfn = max(arch_zone_lowest_possible_pfn[zone_type],
+								node_start_pfn);
+		zone_end_pfn = min(arch_zone_highest_possible_pfn[zone_type],
+								node_end_pfn);
+	} else {
+		/* ZONE_MOVABLE always use passed params */
+		zone_start_pfn = start;
+		zone_end_pfn = end;
+	}
 
 	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
 }
@@ -2709,13 +2748,22 @@ unsigned long __init zone_absent_pages_i
 #else
 static inline unsigned long zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
+					unsigned long *start_pfn,
+					unsigned long *end_pfn,
 					unsigned long *zones_size)
 {
+	/* this will not be used by caller*/
+	if (start_pfn)
+		*start_pfn = 0;
+	if (end_pfn)
+		*end_pfn = 0;
 	return zones_size[zone_type];
 }
 
 static inline unsigned long zone_absent_pages_in_node(int nid,
 						unsigned long zone_type,
+						unsigned long start,
+						unsigned long end,
 						unsigned long *zholes_size)
 {
 	if (!zholes_size)
@@ -2733,20 +2781,115 @@ static void __init calculate_node_totalp
 	enum zone_type i;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
-		totalpages += zone_spanned_pages_in_node(pgdat->node_id, i,
+		totalpages += zone_spanned_pages_in_node(pgdat->node_id, i, NULL, NULL,
 								zones_size);
 	pgdat->node_spanned_pages = totalpages;
 
 	realtotalpages = totalpages;
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		realtotalpages -=
-			zone_absent_pages_in_node(pgdat->node_id, i,
+			zone_absent_pages_in_node(pgdat->node_id, i, 0, 0,
 								zholes_size);
 	pgdat->node_present_pages = realtotalpages;
 	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id,
 							realtotalpages);
 }
 
+#ifdef CONFIG_ZONE_MOVABLE
+
+unsigned long calc_zone_alignment(unsigned long pfn)
+{
+#ifdef CONFIG_SPARSEMEM
+	return (pfn + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK;
+#else
+	return (pfn + MAX_ORDER_NR_PAGES - 1) & ~(MAX_ORDER_NR_PAGES - 1)
+#endif
+}
+
+
+static void alloc_core_pages_from_low(void)
+{
+	unsigned long nr_pages, start_pfn, end_pfn, pfn;
+	int i, nid;
+	long kcore_pages = kernel_core_pages;
+	for_each_online_node(nid) {
+		for_each_active_range_index_in_nid(i, nid) {
+			start_pfn = early_node_map[i].start_pfn;
+			end_pfn = early_node_map[i].end_pfn;
+			nr_pages = end_pfn - start_pfn;
+			if (nr_pages > kcore_pages) {
+				pfn = start_pfn + kcore_pages;
+				pfn = calc_zone_alignment(pfn);
+				if (pfn < end_pfn) {
+					lowest_movable_pfn[nid] = pfn;
+					kcore_pages = 0;
+					break;
+				} else {
+					kcore_pages = 0;
+				}
+			} else {
+				kcore_pages -= nr_pages;
+			}
+		}
+	}
+	return;
+}
+
+static void split_movable_pages(void)
+{
+	int i, nid;
+	unsigned long total_pages, nr_pages, start_pfn, end_pfn, pfn;
+	long core;
+	for_each_online_node(nid) {
+		lowest_movable_pfn[nid] = 0;
+		pfn = 0;
+		total_pages = 0;
+		for_each_active_range_index_in_nid(i, nid) {
+			start_pfn = early_node_map[i].start_pfn;
+			end_pfn = early_node_map[i].end_pfn;
+			total_pages += end_pfn - start_pfn;
+		}
+		core = total_pages * kernel_core_ratio/100;
+		for_each_active_range_index_in_nid(i, nid) {
+			start_pfn = early_node_map[i].start_pfn;
+			end_pfn = early_node_map[i].end_pfn;
+			nr_pages = end_pfn - start_pfn;
+			if (nr_pages > core) {
+				pfn = start_pfn + core;
+				pfn = calc_zone_alignment(pfn);
+				if (pfn < end_pfn) {
+					lowest_movable_pfn[nid] = pfn;
+					break;
+				} else {
+					core -= nr_pages;
+					if (core < 0)
+						core = 0;
+				}
+			} else {
+				core -= nr_pages;
+			}
+		}
+	}
+	return;
+}
+
+
+static void reserve_movable_pages(void)
+{
+	memset(lowest_movable_pfn, 0, MAX_NUMNODES);
+	if (kernel_core_pages) {
+		alloc_core_pages_from_low();
+	} else if (kernel_core_ratio) {
+		split_movable_pages();
+	}
+	return;
+}
+#else
+static void reserve_movable_pages(void)
+{
+	return;
+}
+#endif
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -2768,10 +2911,10 @@ static void __meminit free_area_init_cor
 	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
-		unsigned long size, realsize, memmap_pages;
+		unsigned long size, realsize, memmap_pages, start, end;
 
-		size = zone_spanned_pages_in_node(nid, j, zones_size);
-		realsize = size - zone_absent_pages_in_node(nid, j,
+		size = zone_spanned_pages_in_node(nid, j, &start, &end, zones_size);
+		realsize = size - zone_absent_pages_in_node(nid, j, start, end,
 								zholes_size);
 
 		/*
@@ -3065,6 +3208,7 @@ unsigned long __init find_max_pfn_with_a
 	return max_pfn;
 }
 
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -3127,6 +3271,8 @@ void __init free_area_init_nodes(unsigne
 
 	/* Initialise every node */
 	setup_nr_node_ids();
+	/* setup movable pages */
+	reserve_movable_pages();
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 		free_area_init_node(nid, pgdat, NULL,
@@ -3542,6 +3688,33 @@ void *__init alloc_large_system_hash(con
 	return table;
 }
 
+#ifdef CONFIG_ZONE_MOVABLE
+
+char * __init parse_kernel_core_pages(char *p)
+{
+	unsigned long long coremem;
+	if (!p)
+		return NULL;
+	coremem = memparse(p, &p);
+	kernel_core_pages = coremem >> PAGE_SHIFT;
+	return p;
+}
+
+char * __init parse_kernel_core_ratio(char *p)
+{
+	int ratio[1];
+	ratio[0] = 0;
+	if (!p)
+		return NULL;
+	p = get_options(p, 1, ratio);
+	if (ratio[0])
+		kernel_core_ratio = ratio[0];
+	if (kernel_core_ratio > 100)
+		kernel_core_ratio = 0; /* ll memory is not movable */
+	return p;
+}
+#endif /* CONFIG_ZONE_MOVABLE */
+
 #ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
 struct page *pfn_to_page(unsigned long pfn)
 {
@@ -3555,4 +3728,3 @@ EXPORT_SYMBOL(pfn_to_page);
 EXPORT_SYMBOL(page_to_pfn);
 #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
 
-
Index: devel-tree-2.6.20-mm2/Documentation/kernel-parameters.txt
===================================================================
--- devel-tree-2.6.20-mm2.orig/Documentation/kernel-parameters.txt
+++ devel-tree-2.6.20-mm2/Documentation/kernel-parameters.txt
@@ -764,6 +764,17 @@ and is between 256 and 4096 characters. 
 
 	keepinitrd	[HW,ARM]
 
+	kernel_core_pages=nn[KMG] [KNL, BOOT] divide the whole memory into
+			not-movable and movable. movable memory can be
+			used only for page cache and user data. This option
+			specifies the amount of not-movable pages, called core
+			pages. core pages are allocated from the lower address.
+
+	kernel_core_ratio=nn [KND, BOOT] specifies the amount of the core
+			pages(see kernel_core_pages) by the ratio against
+			total memory. If NUMA, core pages are allocated for
+			each node by this ratio. "0" is not allowed.
+
 	kstack=N	[IA-32,X86-64] Print N words from the kernel stack
 			in oops dumps.
 
Index: devel-tree-2.6.20-mm2/include/linux/mmzone.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/mmzone.h
+++ devel-tree-2.6.20-mm2/include/linux/mmzone.h
@@ -608,6 +608,9 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+extern char* parse_kernel_core_pages(char *cp);
+extern char*  parse_kernel_core_ratio(char *cp);
+
 #include <linux/topology.h>
 /* Returns the number of the current Node. */
 #ifndef numa_node_id

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
