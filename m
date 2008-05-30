Message-Id: <20080530194740.043865776@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Date: Fri, 30 May 2008 21:42:34 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 14/14] bootmem: replace node_boot_start in struct bootmem_data
Content-Disposition: inline; filename=bootmem-replace-node_boot_start.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Almost all users of this field need a PFN instead of a physical
address, so replace node_boot_start with node_min_pfn.

Signed-off-by: Johannes Weiner <hannes@saeureba.de>
CC: linux-arch@vger.kernel.org
---

 arch/alpha/mm/numa.c     |    2 +-
 arch/arm/plat-omap/fb.c  |    4 +---
 arch/avr32/mm/init.c     |    3 +--
 arch/ia64/mm/discontig.c |   19 ++++++++++---------
 arch/m32r/mm/discontig.c |    3 +--
 arch/m32r/mm/init.c      |    4 +---
 arch/mn10300/mm/init.c   |    6 +++---
 arch/sh/mm/init.c        |    2 +-
 arch/sh64/mm/init.c      |    3 +--
 include/linux/bootmem.h  |    2 +-
 mm/bootmem.c             |   42 +++++++++++++++++++++---------------------
 11 files changed, 42 insertions(+), 48 deletions(-)

--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -304,7 +304,7 @@ void __init paging_init(void)
 
 	for_each_online_node(nid) {
 		bootmem_data_t *bdata = &bootmem_node_data[nid];
-		unsigned long start_pfn = bdata->node_boot_start >> PAGE_SHIFT;
+		unsigned long start_pfn = bdata->node_min_pfn;
 		unsigned long end_pfn = bdata->node_low_pfn;
 
 		if (dma_local_pfn >= end_pfn - start_pfn)
--- a/arch/arm/plat-omap/fb.c
+++ b/arch/arm/plat-omap/fb.c
@@ -182,7 +182,7 @@ void __init omapfb_reserve_sdram(void)
 		return;
 
 	bdata = NODE_DATA(0)->bdata;
-	sdram_start = bdata->node_boot_start;
+	sdram_start = bdata->node_min_pfn << PAGE_SHIFT;
 	sdram_size = (bdata->node_low_pfn << PAGE_SHIFT) - sdram_start;
 	reserved = 0;
 	for (i = 0; ; i++) {
@@ -340,5 +340,3 @@ unsigned long omapfb_reserve_sram(unsign
 
 
 #endif
-
-
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -125,8 +125,7 @@ void __init paging_init(void)
 		unsigned long zones_size[MAX_NR_ZONES];
 		unsigned long low, start_pfn;
 
-		start_pfn = pgdat->bdata->node_boot_start;
-		start_pfn >>= PAGE_SHIFT;
+		start_pfn = pgdat->bdata->node_min_pfn;
 		low = pgdat->bdata->node_low_pfn;
 
 		memset(zones_size, 0, sizeof(zones_size));
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -74,17 +74,17 @@ pg_data_t *pgdat_list[MAX_NUMNODES];
 static int __init build_node_maps(unsigned long start, unsigned long len,
 				  int node)
 {
-	unsigned long cstart, epfn, end = start + len;
+	unsigned long spfn, epfn, end = start + len;
 	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	epfn = GRANULEROUNDUP(end) >> PAGE_SHIFT;
-	cstart = GRANULEROUNDDOWN(start);
+	spfn = GRANULEROUNDDOWN(start) >> PAGE_SHIFT;
 
 	if (!bdp->node_low_pfn) {
-		bdp->node_boot_start = cstart;
+		bdp->node_min_pfn = spfn;
 		bdp->node_low_pfn = epfn;
 	} else {
-		bdp->node_boot_start = min(cstart, bdp->node_boot_start);
+		bdp->node_min_pfn = min(spfn, bdp->node_min_pfn);
 		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
 	}
 
@@ -221,20 +221,21 @@ static void __init fill_pernode(int node
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn;
+	unsigned long spfn, epfn;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
 	struct bootmem_data *bdp = &bootmem_node_data[node];
 
+	spfn = start >> PAGE_SHIFT;
 	epfn = (start + len) >> PAGE_SHIFT;
 
-	pages = bdp->node_low_pfn - (bdp->node_boot_start >> PAGE_SHIFT);
+	pages = bdp->node_low_pfn - bdp->node_min_pfn;
 	mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
 
 	/*
 	 * Make sure this memory falls within this node's usable memory
 	 * since we may have thrown some away in build_maps().
 	 */
-	if (start < bdp->node_boot_start || epfn > bdp->node_low_pfn)
+	if (spfn < bdp->node_min_pfn || epfn > bdp->node_low_pfn)
 		return 0;
 
 	/* Don't setup this node's local space twice... */
@@ -296,7 +297,7 @@ static void __init reserve_pernode_space
 		bdp = pdp->bdata;
 
 		/* First the bootmem_map itself */
-		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
+		pages = bdp->node_low_pfn - bdp->node_min_pfn;
 		size = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
 		base = __pa(bdp->node_bootmem_map);
 		reserve_bootmem_node(pdp, base, size, BOOTMEM_DEFAULT);
@@ -466,7 +467,7 @@ void __init find_memory(void)
 
 		init_bootmem_node(pgdat_list[node],
 				  map>>PAGE_SHIFT,
-				  bdp->node_boot_start>>PAGE_SHIFT,
+				  bdp->node_min_pfn,
 				  bdp->node_low_pfn);
 	}
 
--- a/arch/m32r/mm/discontig.c
+++ b/arch/m32r/mm/discontig.c
@@ -123,8 +123,7 @@ unsigned long __init setup_memory(void)
 	return max_low_pfn;
 }
 
-#define START_PFN(nid)	\
-	(NODE_DATA(nid)->bdata->node_boot_start >> PAGE_SHIFT)
+#define START_PFN(nid)		(NODE_DATA(nid)->bdata->node_min_pfn)
 #define MAX_LOW_PFN(nid)	(NODE_DATA(nid)->bdata->node_low_pfn)
 
 unsigned long __init zone_sizes_init(void)
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -93,8 +93,7 @@ void free_initrd_mem(unsigned long, unsi
 #endif
 
 /* It'd be good if these lines were in the standard header file. */
-#define START_PFN(nid)	\
-	(NODE_DATA(nid)->bdata->node_boot_start >> PAGE_SHIFT)
+#define START_PFN(nid)		(NODE_DATA(nid)->bdata->node_min_pfn)
 #define MAX_LOW_PFN(nid)	(NODE_DATA(nid)->bdata->node_low_pfn)
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -252,4 +251,3 @@ void free_initrd_mem(unsigned long start
 	printk (KERN_INFO "Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
 }
 #endif
-
--- a/arch/mn10300/mm/init.c
+++ b/arch/mn10300/mm/init.c
@@ -67,8 +67,8 @@ void __init paging_init(void)
 
 	/* declare the sizes of the RAM zones (only use the normal zone) */
 	zones_size[ZONE_NORMAL] =
-		(contig_page_data.bdata->node_low_pfn) -
-		(contig_page_data.bdata->node_boot_start >> PAGE_SHIFT);
+		contig_page_data.bdata->node_low_pfn -
+		contig_page_data.bdata->node_min_pfn;
 
 	/* pass the memory from the bootmem allocator to the main allocator */
 	free_area_init(zones_size);
@@ -87,7 +87,7 @@ void __init mem_init(void)
 	if (!mem_map)
 		BUG();
 
-#define START_PFN	(contig_page_data.bdata->node_boot_start >> PAGE_SHIFT)
+#define START_PFN	(contig_page_data.bdata->node_min_pfn)
 #define MAX_LOW_PFN	(contig_page_data.bdata->node_low_pfn)
 
 	max_mapnr = num_physpages = MAX_LOW_PFN - START_PFN;
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -191,7 +191,7 @@ void __init paging_init(void)
 		pg_data_t *pgdat = NODE_DATA(nid);
 		unsigned long low, start_pfn;
 
-		start_pfn = pgdat->bdata->node_boot_start >> PAGE_SHIFT;
+		start_pfn = pgdat->bdata->node_min_pfn;
 		low = pgdat->bdata->node_low_pfn;
 
 		if (max_zone_pfns[ZONE_NORMAL] < low)
--- a/arch/sh64/mm/init.c
+++ b/arch/sh64/mm/init.c
@@ -58,7 +58,7 @@ extern char _text, _etext, _edata, __bss
 extern char __init_begin, __init_end;
 
 /* It'd be good if these lines were in the standard header file. */
-#define START_PFN	(NODE_DATA(0)->bdata->node_boot_start >> PAGE_SHIFT)
+#define START_PFN	(NODE_DATA(0)->bdata->node_min_pfn)
 #define MAX_LOW_PFN	(NODE_DATA(0)->bdata->node_low_pfn)
 
 
@@ -190,4 +190,3 @@ void free_initrd_mem(unsigned long start
 	printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
 }
 #endif
-
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -28,7 +28,7 @@ extern unsigned long saved_max_pfn;
  * memory pages (including holes) on the node.
  */
 typedef struct bootmem_data {
-	unsigned long node_boot_start;
+	unsigned long node_min_pfn;
 	unsigned long node_low_pfn;
 	void *node_bootmem_map;
 	unsigned long last_offset;
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -80,7 +80,7 @@ static void __init link_bootmem(bootmem_
 		bootmem_data_t *ent;
 
 		ent = list_entry(iter, bootmem_data_t, list);
-		if (bdata->node_boot_start < ent->node_boot_start)
+		if (bdata->node_min_pfn < ent->node_min_pfn)
 			break;
 	}
 	list_add_tail(&bdata->list, iter);
@@ -96,7 +96,7 @@ static unsigned long __init init_bootmem
 
 	mminit_validate_memmodel_limits(&start, &end);
 	bdata->node_bootmem_map = phys_to_virt(PFN_PHYS(mapstart));
-	bdata->node_boot_start = PFN_PHYS(start);
+	bdata->node_min_pfn = start;
 	bdata->node_low_pfn = end;
 	link_bootmem(bdata);
 
@@ -151,7 +151,7 @@ static unsigned long __init free_all_boo
 	if (!bdata->node_bootmem_map)
 		return 0;
 
-	start = PFN_DOWN(bdata->node_boot_start);
+	start = bdata->node_min_pfn;
 	end = bdata->node_low_pfn;
 
 	/*
@@ -167,7 +167,7 @@ static unsigned long __init free_all_boo
 		unsigned long *map, idx, vec;
 
 		map = bdata->node_bootmem_map;
-		idx = start - PFN_DOWN(bdata->node_boot_start);
+		idx = start - bdata->node_min_pfn;
 		vec = ~map[idx / BITS_PER_LONG];
 
 		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
@@ -192,7 +192,7 @@ static unsigned long __init free_all_boo
 	}
 
 	page = virt_to_page(bdata->node_bootmem_map);
-	pages = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
+	pages = bdata->node_low_pfn - bdata->node_min_pfn;
 	pages = bootmem_bootmap_pages(pages);
 	count += pages;
 	while (pages--)
@@ -231,10 +231,10 @@ static void __init __free(bootmem_data_t
 	unsigned long idx, start;
 
 	bdebug("nid=%d start=%lx end=%lx\n", bdata - bootmem_node_data,
-		sidx + PFN_DOWN(bdata->node_boot_start),
-		eidx + PFN_DOWN(bdata->node_boot_start));
+		sidx + bdata->node_min_pfn,
+		eidx + bdata->node_min_pfn);
 
-	start = bdata->node_boot_start + PFN_PHYS(sidx);
+	start = PFN_PHYS(bdata->node_min_pfn + sidx);
 	if (bdata->last_success > start)
 		bdata->last_success = start;
 
@@ -251,8 +251,8 @@ static int __init __reserve(bootmem_data
 
 	bdebug("nid=%d start=%lx end=%lx flags=%x\n",
 		bdata - bootmem_node_data,
-		sidx + PFN_DOWN(bdata->node_boot_start),
-		eidx + PFN_DOWN(bdata->node_boot_start),
+		sidx + bdata->node_min_pfn,
+		eidx + bdata->node_min_pfn,
 		flags);
 
 	for (idx = sidx; idx < eidx; idx++)
@@ -262,7 +262,7 @@ static int __init __reserve(bootmem_data
 				return -EBUSY;
 			}
 			bdebug("silent double reserve of PFN %lx\n",
-				idx + PFN_DOWN(bdata->node_boot_start));
+				idx + bdata->node_min_pfn);
 		}
 	return 0;
 }
@@ -276,11 +276,11 @@ static int __init mark_bootmem_node(boot
 	bdebug("nid=%d start=%lx end=%lx reserve=%d flags=%x\n",
 		bdata - bootmem_node_data, start, end, reserve, flags);
 
-	BUG_ON(start < PFN_DOWN(bdata->node_boot_start));
+	BUG_ON(start < bdata->node_min_pfn);
 	BUG_ON(end > bdata->node_low_pfn);
 
-	sidx = start - PFN_DOWN(bdata->node_boot_start);
-	eidx = end - PFN_DOWN(bdata->node_boot_start);
+	sidx = start - bdata->node_min_pfn;
+	eidx = end - bdata->node_min_pfn;
 
 	if (reserve)
 		return __reserve(bdata, sidx, eidx, flags);
@@ -300,7 +300,7 @@ static int __init mark_bootmem(unsigned 
 		int err;
 		unsigned long max;
 
-		if (pos < PFN_DOWN(bdata->node_boot_start)) {
+		if (pos < bdata->node_min_pfn) {
 			BUG_ON(pos != start);
 			continue;
 		}
@@ -419,7 +419,7 @@ static void * __init alloc_bootmem_core(
 		bdata - bootmem_node_data, size, PAGE_ALIGN(size) >> PAGE_SHIFT,
 		align, goal, limit);
 
-	min = PFN_DOWN(bdata->node_boot_start);
+	min = bdata->node_min_pfn;
 	max = bdata->node_low_pfn;
 
 	goal >>= PAGE_SHIFT;
@@ -442,8 +442,8 @@ static void * __init alloc_bootmem_core(
 		start = goal = ALIGN(bdata->last_success, step);
 	}
 
-	max -= PFN_DOWN(bdata->node_boot_start);
-	start -= PFN_DOWN(bdata->node_boot_start);
+	max -= bdata->node_min_pfn;
+	start -= bdata->node_min_pfn;
 
 	while (1) {
 		int merge;
@@ -483,7 +483,7 @@ find_block:
 				PFN_UP(new_end), BOOTMEM_EXCLUSIVE))
 			BUG();
 
-		region = phys_to_virt(bdata->node_boot_start + new_start);
+		region = phys_to_virt(PFN_PHYS(bdata->node_min_pfn) + new_start);
 		memset(region, 0, size);
 		return region;
 	}
@@ -501,9 +501,9 @@ restart:
 	list_for_each_entry(bdata, &bdata_list, list) {
 		void *region;
 
-		if (goal && goal < bdata->node_boot_start)
+		if (goal && goal < PFN_PHYS(bdata->node_min_pfn))
 			continue;
-		if (limit && limit < bdata->node_boot_start)
+		if (limit && limit < PFN_PHYS(bdata->node_min_pfn))
 			continue;
 
 		region = alloc_bootmem_core(bdata, size, align, goal, limit);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
