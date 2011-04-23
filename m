Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7DAAB8D003B
	for <linux-mm@kvack.org>; Sat, 23 Apr 2011 14:34:23 -0400 (EDT)
Subject: [PATCH] convert parisc to sparsemem (was Re: [PATCH v3] mm: make
 expand_downwards symmetrical to expand_upwards)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303507985.2590.47.camel@mulgrave.site>
References: <1303337718.2587.51.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>
	 <20110421221712.9184.A69D9226@jp.fujitsu.com>
	 <1303403847.4025.11.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211328000.5741@router.home>
	 <1303411537.9048.3583.camel@nimitz>
	 <1303507985.2590.47.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 23 Apr 2011 13:34:17 -0500
Message-ID: <1303583657.4116.11.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>

This is the preliminary conversion.  It's very nasty on parisc because
the memory allocation isn't symmetric anymore: under DISCONTIGMEM, we
push all memory into bootmem and then let free_all_bootmem() do the
magic for us; now we have to do separate initialisations for ranges
because SPARSEMEM can't do multi-range boot memory. It's also got the
horrible hack that I only use the first found range for bootmem.  I'm
not sure if this is correct (it won't be if the first found range can be
under about 50MB because we'll run out of bootmem during boot) ... we
might have to sort the ranges and use the larges, but that will involve
us in even more hackery around the bootmem reservations code.

The boot sequence got a few seconds slower because now all of the loops
over our pfn ranges actually have to skip through the holes (which takes
time for 64GB).

All in all, I've not been very impressed with SPARSEMEM over
DISCONTIGMEM.  It seems to have a lot of rough edges (necessitating
exception code) which DISCONTIGMEM just copes with.

And before you say the code is smaller, that's because I converted us to
generic show_mem().

James

---

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 69ff049..b416641 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -233,22 +233,17 @@ config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on 64BIT
 
-config ARCH_DISCONTIGMEM_ENABLE
+config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on 64BIT
 
 config ARCH_FLATMEM_ENABLE
 	def_bool y
 
-config ARCH_DISCONTIGMEM_DEFAULT
+config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 
-config NODES_SHIFT
-	int
-	default "3"
-	depends on NEED_MULTIPLE_NODES
-
 source "kernel/Kconfig.preempt"
 source "kernel/Kconfig.hz"
 source "mm/Kconfig"
diff --git a/arch/parisc/include/asm/mmzone.h b/arch/parisc/include/asm/mmzone.h
index 9608d2c..8344bcb 100644
--- a/arch/parisc/include/asm/mmzone.h
+++ b/arch/parisc/include/asm/mmzone.h
@@ -1,73 +1,11 @@
 #ifndef _PARISC_MMZONE_H
 #define _PARISC_MMZONE_H
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_SPARSEMEM
 
-#define MAX_PHYSMEM_RANGES 8 /* Fix the size for now (current known max is 3) */
-extern int npmem_ranges;
-
-struct node_map_data {
-    pg_data_t pg_data;
-};
-
-extern struct node_map_data node_data[];
-
-#define NODE_DATA(nid)          (&node_data[nid].pg_data)
-
-#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
-#define node_end_pfn(nid)						\
-({									\
-	pg_data_t *__pgdat = NODE_DATA(nid);				\
-	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;		\
-})
-
-/* We have these possible memory map layouts:
- * Astro: 0-3.75, 67.75-68, 4-64
- * zx1: 0-1, 257-260, 4-256
- * Stretch (N-class): 0-2, 4-32, 34-xxx
- */
-
-/* Since each 1GB can only belong to one region (node), we can create
- * an index table for pfn to nid lookup; each entry in pfnnid_map 
- * represents 1GB, and contains the node that the memory belongs to. */
-
-#define PFNNID_SHIFT (30 - PAGE_SHIFT)
-#define PFNNID_MAP_MAX  512     /* support 512GB */
-extern unsigned char pfnnid_map[PFNNID_MAP_MAX];
-
-#ifndef CONFIG_64BIT
-#define pfn_is_io(pfn) ((pfn & (0xf0000000UL >> PAGE_SHIFT)) == (0xf0000000UL >> PAGE_SHIFT))
+#define MAX_PHYSMEM_RANGES 	8 /* current max is 3 but future proof this */
 #else
-/* io can be 0xf0f0f0f0f0xxxxxx or 0xfffffffff0000000 */
-#define pfn_is_io(pfn) ((pfn & (0xf000000000000000UL >> PAGE_SHIFT)) == (0xf000000000000000UL >> PAGE_SHIFT))
-#endif
-
-static inline int pfn_to_nid(unsigned long pfn)
-{
-	unsigned int i;
-	unsigned char r;
-
-	if (unlikely(pfn_is_io(pfn)))
-		return 0;
-
-	i = pfn >> PFNNID_SHIFT;
-	BUG_ON(i >= sizeof(pfnnid_map) / sizeof(pfnnid_map[0]));
-	r = pfnnid_map[i];
-	BUG_ON(r == 0xff);
-
-	return (int)r;
-}
-
-static inline int pfn_valid(int pfn)
-{
-	int nid = pfn_to_nid(pfn);
-
-	if (nid >= 0)
-		return (pfn < node_end_pfn(nid));
-	return 0;
-}
-
-#else /* !CONFIG_DISCONTIGMEM */
 #define MAX_PHYSMEM_RANGES 	1 
 #endif
+
 #endif /* _PARISC_MMZONE_H */
diff --git a/arch/parisc/include/asm/page.h b/arch/parisc/include/asm/page.h
index a84cc1f..654285a 100644
--- a/arch/parisc/include/asm/page.h
+++ b/arch/parisc/include/asm/page.h
@@ -139,9 +139,9 @@ extern int npmem_ranges;
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
-#endif /* CONFIG_DISCONTIGMEM */
+#endif
 
 #ifdef CONFIG_HUGETLB_PAGE
 #define HPAGE_SHIFT		22	/* 4MB (is this fixed?) */
diff --git a/arch/parisc/kernel/parisc_ksyms.c b/arch/parisc/kernel/parisc_ksyms.c
index df65366..526122c 100644
--- a/arch/parisc/kernel/parisc_ksyms.c
+++ b/arch/parisc/kernel/parisc_ksyms.c
@@ -147,12 +147,6 @@ extern void $$dyncall(void);
 EXPORT_SYMBOL($$dyncall);
 #endif
 
-#ifdef CONFIG_DISCONTIGMEM
-#include <asm/mmzone.h>
-EXPORT_SYMBOL(node_data);
-EXPORT_SYMBOL(pfnnid_map);
-#endif
-
 #ifdef CONFIG_FUNCTION_TRACER
 extern void _mcount(void);
 EXPORT_SYMBOL(_mcount);
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 5fa1e27..69c547c 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -21,7 +21,6 @@
 #include <linux/initrd.h>
 #include <linux/swap.h>
 #include <linux/unistd.h>
-#include <linux/nodemask.h>	/* for node_online_map */
 #include <linux/pagemap.h>	/* for release_pages and page_cache_release */
 
 #include <asm/pgalloc.h>
@@ -35,11 +34,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 extern int  data_start;
 
-#ifdef CONFIG_DISCONTIGMEM
-struct node_map_data node_data[MAX_NUMNODES] __read_mostly;
-unsigned char pfnnid_map[PFNNID_MAP_MAX] __read_mostly;
-#endif
-
 static struct resource data_resource = {
 	.name	= "Kernel data",
 	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
@@ -110,7 +104,7 @@ static void __init setup_bootmem(void)
 	unsigned long bootmap_pages;
 	unsigned long bootmap_start_pfn;
 	unsigned long bootmap_pfn;
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	physmem_range_t pmem_holes[MAX_PHYSMEM_RANGES - 1];
 	int npmem_holes;
 #endif
@@ -144,7 +138,7 @@ static void __init setup_bootmem(void)
 		}
 	}
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	/*
 	 * Throw out ranges that are too far apart (controlled by
 	 * MAX_GAP).
@@ -156,7 +150,7 @@ static void __init setup_bootmem(void)
 			 pmem_ranges[i-1].pages) > MAX_GAP) {
 			npmem_ranges = i;
 			printk("Large gap in memory detected (%ld pages). "
-			       "Consider turning on CONFIG_DISCONTIGMEM\n",
+			       "Consider turning on CONFIG_SPARSEMEM\n",
 			       pmem_ranges[i].start_pfn -
 			       (pmem_ranges[i-1].start_pfn +
 			        pmem_ranges[i-1].pages));
@@ -228,7 +222,7 @@ static void __init setup_bootmem(void)
 
 	printk(KERN_INFO "Total Memory: %ld MB\n",mem_max >> 20);
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 	/* Merge the ranges, keeping track of the holes */
 
 	{
@@ -253,48 +247,29 @@ static void __init setup_bootmem(void)
 	}
 #endif
 
-	bootmap_pages = 0;
-	for (i = 0; i < npmem_ranges; i++)
-		bootmap_pages += bootmem_bootmap_pages(pmem_ranges[i].pages);
+	bootmap_pages = bootmem_bootmap_pages(pmem_ranges[0].pages);
 
 	bootmap_start_pfn = PAGE_ALIGN(__pa((unsigned long) &_end)) >> PAGE_SHIFT;
 
-#ifdef CONFIG_DISCONTIGMEM
-	for (i = 0; i < MAX_PHYSMEM_RANGES; i++) {
-		memset(NODE_DATA(i), 0, sizeof(pg_data_t));
-		NODE_DATA(i)->bdata = &bootmem_node_data[i];
-	}
-	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
-
-	for (i = 0; i < npmem_ranges; i++) {
-		node_set_state(i, N_NORMAL_MEMORY);
-		node_set_online(i);
-	}
-#endif
-
 	/*
-	 * Initialize and free the full range of memory in each range.
-	 * Note that the only writing these routines do are to the bootmap,
-	 * and we've made sure to locate the bootmap properly so that they
-	 * won't be writing over anything important.
+	 * Only initialise the first memory range to bootmem (the bootmem
+	 * allocation map can't cope with large holes)
 	 */
 
 	bootmap_pfn = bootmap_start_pfn;
 	max_pfn = 0;
-	for (i = 0; i < npmem_ranges; i++) {
+	{
 		unsigned long start_pfn;
 		unsigned long npages;
 
-		start_pfn = pmem_ranges[i].start_pfn;
-		npages = pmem_ranges[i].pages;
+		start_pfn = pmem_ranges[0].start_pfn;
+		npages = pmem_ranges[0].pages;
 
-		bootmap_size = init_bootmem_node(NODE_DATA(i),
+		bootmap_size = init_bootmem_node(NODE_DATA(0),
 						bootmap_pfn,
 						start_pfn,
 						(start_pfn + npages) );
-		free_bootmem_node(NODE_DATA(i),
-				  (start_pfn << PAGE_SHIFT),
-				  (npages << PAGE_SHIFT) );
+		free_bootmem(start_pfn << PAGE_SHIFT, npages << PAGE_SHIFT);
 		bootmap_pfn += (bootmap_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		if ((start_pfn + npages) > max_pfn)
 			max_pfn = start_pfn + npages;
@@ -323,7 +298,7 @@ static void __init setup_bootmem(void)
 			((bootmap_pfn - bootmap_start_pfn) << PAGE_SHIFT),
 			BOOTMEM_DEFAULT);
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_SPARSEMEM
 
 	/* reserve the holes */
 
@@ -369,6 +344,13 @@ static void __init setup_bootmem(void)
 		request_resource(res, &data_resource);
 	}
 	request_resource(&sysram_resources[0], &pdcdata_resource);
+
+#ifdef CONFIG_SPARSEMEM
+	for (i = 0; i < npmem_ranges; i++) {
+		memory_present(0, pmem_ranges[i].start_pfn,
+			       pmem_ranges[i].start_pfn + pmem_ranges[i].pages);
+	}
+#endif
 }
 
 static void __init map_pages(unsigned long start_vaddr,
@@ -580,7 +562,7 @@ unsigned long pcxl_dma_start __read_mostly;
 
 void __init mem_init(void)
 {
-	int codesize, reservedpages, datasize, initsize;
+	int codesize, reservedpages, datasize, initsize, i;
 
 	/* Do sanity checks on page table constants */
 	BUILD_BUG_ON(PTE_ENTRY_SIZE != sizeof(pte_t));
@@ -589,19 +571,27 @@ void __init mem_init(void)
 	BUILD_BUG_ON(PAGE_SHIFT + BITS_PER_PTE + BITS_PER_PMD + BITS_PER_PGD
 			> BITS_PER_LONG);
 
-	high_memory = __va((max_pfn << PAGE_SHIFT));
-
-#ifndef CONFIG_DISCONTIGMEM
-	max_mapnr = page_to_pfn(virt_to_page(high_memory - 1)) + 1;
 	totalram_pages += free_all_bootmem();
-#else
-	{
-		int i;
-
-		for (i = 0; i < npmem_ranges; i++)
-			totalram_pages += free_all_bootmem_node(NODE_DATA(i));
+	/* free all the ranges not in bootmem */
+	for (i = 1; i < npmem_ranges; i++) {
+		unsigned long pfn = pmem_ranges[i].start_pfn;
+		unsigned long end = pfn + pmem_ranges[i].pages;
+
+		if (end > max_pfn)
+			max_pfn = end;
+
+		for (; pfn < end; pfn++) {
+			struct page *page = pfn_to_page(pfn);
+			ClearPageReserved(page);
+			init_page_count(page);
+			__free_page(page);
+			totalram_pages++;
+		}
 	}
-#endif
+
+	max_low_pfn = max_pfn;
+	high_memory = __va((max_pfn << PAGE_SHIFT));
+	max_mapnr = page_to_pfn(virt_to_page(high_memory - 1)) + 1;
 
 	codesize = (unsigned long)_etext - (unsigned long)_text;
 	datasize = (unsigned long)_edata - (unsigned long)_etext;
@@ -610,24 +600,15 @@ void __init mem_init(void)
 	reservedpages = 0;
 {
 	unsigned long pfn;
-#ifdef CONFIG_DISCONTIGMEM
-	int i;
-
-	for (i = 0; i < npmem_ranges; i++) {
-		for (pfn = node_start_pfn(i); pfn < node_end_pfn(i); pfn++) {
-			if (PageReserved(pfn_to_page(pfn)))
-				reservedpages++;
-		}
-	}
-#else /* !CONFIG_DISCONTIGMEM */
 	for (pfn = 0; pfn < max_pfn; pfn++) {
 		/*
 		 * Only count reserved RAM pages
 		 */
+		if (!pfn_valid(pfn))
+			continue;
 		if (PageReserved(pfn_to_page(pfn)))
 			reservedpages++;
 	}
-#endif
 }
 
 #ifdef CONFIG_PA11
@@ -680,78 +661,6 @@ void __init mem_init(void)
 unsigned long *empty_zero_page __read_mostly;
 EXPORT_SYMBOL(empty_zero_page);
 
-void show_mem(unsigned int filter)
-{
-	int i,free = 0,total = 0,reserved = 0;
-	int shared = 0, cached = 0;
-
-	printk(KERN_INFO "Mem-info:\n");
-	show_free_areas();
-#ifndef CONFIG_DISCONTIGMEM
-	i = max_mapnr;
-	while (i-- > 0) {
-		total++;
-		if (PageReserved(mem_map+i))
-			reserved++;
-		else if (PageSwapCache(mem_map+i))
-			cached++;
-		else if (!page_count(&mem_map[i]))
-			free++;
-		else
-			shared += page_count(&mem_map[i]) - 1;
-	}
-#else
-	for (i = 0; i < npmem_ranges; i++) {
-		int j;
-
-		for (j = node_start_pfn(i); j < node_end_pfn(i); j++) {
-			struct page *p;
-			unsigned long flags;
-
-			pgdat_resize_lock(NODE_DATA(i), &flags);
-			p = nid_page_nr(i, j) - node_start_pfn(i);
-
-			total++;
-			if (PageReserved(p))
-				reserved++;
-			else if (PageSwapCache(p))
-				cached++;
-			else if (!page_count(p))
-				free++;
-			else
-				shared += page_count(p) - 1;
-			pgdat_resize_unlock(NODE_DATA(i), &flags);
-        	}
-	}
-#endif
-	printk(KERN_INFO "%d pages of RAM\n", total);
-	printk(KERN_INFO "%d reserved pages\n", reserved);
-	printk(KERN_INFO "%d pages shared\n", shared);
-	printk(KERN_INFO "%d pages swap cached\n", cached);
-
-
-#ifdef CONFIG_DISCONTIGMEM
-	{
-		struct zonelist *zl;
-		int i, j;
-
-		for (i = 0; i < npmem_ranges; i++) {
-			zl = node_zonelist(i, 0);
-			for (j = 0; j < MAX_NR_ZONES; j++) {
-				struct zoneref *z;
-				struct zone *zone;
-
-				printk("Zone list for zone %d on node %d: ", j, i);
-				for_each_zone_zonelist(zone, z, zl, j)
-					printk("[%d/%s] ", zone_to_nid(zone),
-								zone->name);
-				printk("\n");
-			}
-		}
-	}
-#endif
-}
-
 /*
  * pagetable_init() sets up the page tables
  *
@@ -886,6 +795,9 @@ EXPORT_SYMBOL(map_hpux_gateway_page);
 void __init paging_init(void)
 {
 	int i;
+	unsigned long zones_size[MAX_NR_ZONES] = { 0, };
+	unsigned long holes_size[MAX_NR_ZONES] = { 0, };
+	unsigned long mem_start_pfn = ~0UL, mem_end_pfn = 0, mem_size_pfn = 0;
 
 	setup_bootmem();
 	pagetable_init();
@@ -893,27 +805,31 @@ void __init paging_init(void)
 	flush_cache_all_local(); /* start with known state */
 	flush_tlb_all_local(NULL);
 
-	for (i = 0; i < npmem_ranges; i++) {
-		unsigned long zones_size[MAX_NR_ZONES] = { 0, };
-
-		zones_size[ZONE_NORMAL] = pmem_ranges[i].pages;
-
-#ifdef CONFIG_DISCONTIGMEM
-		/* Need to initialize the pfnnid_map before we can initialize
-		   the zone */
-		{
-		    int j;
-		    for (j = (pmem_ranges[i].start_pfn >> PFNNID_SHIFT);
-			 j <= ((pmem_ranges[i].start_pfn + pmem_ranges[i].pages) >> PFNNID_SHIFT);
-			 j++) {
-			pfnnid_map[j] = i;
-		    }
-		}
-#endif
+	/*
+	 *  from here, the kernel and all of the physical memory is
+	 *  fully covered with page table entries.  This is required
+	 *  because sparse_init() is very memory greedy and will fall
+	 *  off the end of the kernel initial page mapping.
+	 */
+
+	sparse_init();
 
-		free_area_init_node(i, zones_size,
-				pmem_ranges[i].start_pfn, NULL);
+	for (i = 0; i < npmem_ranges; i++) {
+		unsigned long start = pmem_ranges[i].start_pfn;
+		unsigned long size = pmem_ranges[i].pages;
+		unsigned long end = start + size;
+
+		if (mem_start_pfn > start)
+			mem_start_pfn = start;
+		if (mem_end_pfn < end)
+			mem_end_pfn = end;
+		mem_size_pfn += size;
 	}
+
+	zones_size[ZONE_NORMAL] = mem_end_pfn - mem_start_pfn;
+	holes_size[ZONE_NORMAL] = zones_size[ZONE_NORMAL] - mem_size_pfn;
+
+	free_area_init_node(0, zones_size, mem_start_pfn, holes_size);
 }
 
 #ifdef CONFIG_PA20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
