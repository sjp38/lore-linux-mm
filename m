Message-Id: <20080416113719.539500813@skyscraper.fehenstaub.lan>
References: <20080416113629.947746497@skyscraper.fehenstaub.lan>
Date: Wed, 16 Apr 2008 13:36:34 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC][patch 5/5] mm: Move bootmem descriptors definition to a single place
Content-Disposition: inline; filename=0005-bootmem-Move-bootmem-descriptors-definition-to-a-si.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Richard Henderson <rth@twiddle.net>, Russell King <rmk@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>, Hirokazu Takata <takata@linux-m32r.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@parisc-linux.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>
List-ID: <linux-mm.kvack.org>

There are a lot of places that define either a single bootmem
descriptor or an array of them.  Use only one central array with
MAX_NUMNODES items instead.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Richard Henderson <rth@twiddle.net>
CC: Russell King <rmk@arm.linux.org.uk>
CC: Tony Luck <tony.luck@intel.com>
CC: Hirokazu Takata <takata@linux-m32r.org>
CC: Geert Uytterhoeven <geert@linux-m68k.org>
CC: Ralf Baechle <ralf@linux-mips.org>
CC: Kyle McMartin <kyle@parisc-linux.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Paul Mundt <lethal@linux-sh.org>
---
 arch/alpha/mm/numa.c             |    8 ++++----
 arch/arm/mm/discontig.c          |   34 ++++++++++++++++------------------
 arch/ia64/mm/discontig.c         |   11 +++++------
 arch/m32r/mm/discontig.c         |    4 +---
 arch/m68k/mm/init.c              |    4 +---
 arch/mips/sgi-ip27/ip27-memory.c |    3 +--
 arch/parisc/mm/init.c            |    3 +--
 arch/powerpc/mm/numa.c           |    3 +--
 arch/sh/mm/numa.c                |    5 ++---
 arch/x86/mm/discontig_32.c       |    3 +--
 arch/x86/mm/numa_64.c            |    4 +---
 include/linux/bootmem.h          |    2 ++
 mm/bootmem.c                     |    2 ++
 mm/page_alloc.c                  |    4 +---
 14 files changed, 39 insertions(+), 51 deletions(-)

Index: tree-linus/arch/alpha/mm/numa.c
===================================================================
--- tree-linus.orig/arch/alpha/mm/numa.c
+++ tree-linus/arch/alpha/mm/numa.c
@@ -19,7 +19,6 @@
 #include <asm/pgalloc.h>
 
 pg_data_t node_data[MAX_NUMNODES];
-bootmem_data_t node_bdata[MAX_NUMNODES];
 EXPORT_SYMBOL(node_data);
 
 #undef DEBUG_DISCONTIG
@@ -141,7 +140,7 @@ setup_memory_node(int nid, void *kernel_
 		printk(" not enough mem to reserve NODE_DATA");
 		return;
 	}
-	NODE_DATA(nid)->bdata = &node_bdata[nid];
+	NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
 
 	printk(" Detected node memory:   start %8lu, end %8lu\n",
 	       node_min_pfn, node_max_pfn);
@@ -304,8 +303,9 @@ void __init paging_init(void)
 	dma_local_pfn = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 
 	for_each_online_node(nid) {
-		unsigned long start_pfn = node_bdata[nid].node_boot_start >> PAGE_SHIFT;
-		unsigned long end_pfn = node_bdata[nid].node_low_pfn;
+		bootmem_data_t *bdata = &bootmem_node_data[nid];
+		unsigned long start_pfn = bdata->node_boot_start >> PAGE_SHIFT;
+		unsigned long end_pfn = bdata->node_low_pfn;
 
 		if (dma_local_pfn >= end_pfn - start_pfn)
 			zones_size[ZONE_DMA] = end_pfn - start_pfn;
Index: tree-linus/arch/arm/mm/discontig.c
===================================================================
--- tree-linus.orig/arch/arm/mm/discontig.c
+++ tree-linus/arch/arm/mm/discontig.c
@@ -21,26 +21,24 @@
  * Our node_data structure for discontiguous memory.
  */
 
-static bootmem_data_t node_bootmem_data[MAX_NUMNODES];
-
 pg_data_t discontig_node_data[MAX_NUMNODES] = {
-  { .bdata = &node_bootmem_data[0] },
-  { .bdata = &node_bootmem_data[1] },
-  { .bdata = &node_bootmem_data[2] },
-  { .bdata = &node_bootmem_data[3] },
+  { .bdata = &bootmem_node_data[0] },
+  { .bdata = &bootmem_node_data[1] },
+  { .bdata = &bootmem_node_data[2] },
+  { .bdata = &bootmem_node_data[3] },
 #if MAX_NUMNODES == 16
-  { .bdata = &node_bootmem_data[4] },
-  { .bdata = &node_bootmem_data[5] },
-  { .bdata = &node_bootmem_data[6] },
-  { .bdata = &node_bootmem_data[7] },
-  { .bdata = &node_bootmem_data[8] },
-  { .bdata = &node_bootmem_data[9] },
-  { .bdata = &node_bootmem_data[10] },
-  { .bdata = &node_bootmem_data[11] },
-  { .bdata = &node_bootmem_data[12] },
-  { .bdata = &node_bootmem_data[13] },
-  { .bdata = &node_bootmem_data[14] },
-  { .bdata = &node_bootmem_data[15] },
+  { .bdata = &bootmem_node_data[4] },
+  { .bdata = &bootmem_node_data[5] },
+  { .bdata = &bootmem_node_data[6] },
+  { .bdata = &bootmem_node_data[7] },
+  { .bdata = &bootmem_node_data[8] },
+  { .bdata = &bootmem_node_data[9] },
+  { .bdata = &bootmem_node_data[10] },
+  { .bdata = &bootmem_node_data[11] },
+  { .bdata = &bootmem_node_data[12] },
+  { .bdata = &bootmem_node_data[13] },
+  { .bdata = &bootmem_node_data[14] },
+  { .bdata = &bootmem_node_data[15] },
 #endif
 };
 
Index: tree-linus/arch/ia64/mm/discontig.c
===================================================================
--- tree-linus.orig/arch/ia64/mm/discontig.c
+++ tree-linus/arch/ia64/mm/discontig.c
@@ -36,7 +36,6 @@ struct early_node_data {
 	struct ia64_node_data *node_data;
 	unsigned long pernode_addr;
 	unsigned long pernode_size;
-	struct bootmem_data bootmem_data;
 	unsigned long num_physpages;
 #ifdef CONFIG_ZONE_DMA
 	unsigned long num_dma_physpages;
@@ -76,7 +75,7 @@ static int __init build_node_maps(unsign
 				  int node)
 {
 	unsigned long cstart, epfn, end = start + len;
-	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
+	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	epfn = GRANULEROUNDUP(end) >> PAGE_SHIFT;
 	cstart = GRANULEROUNDDOWN(start);
@@ -166,7 +165,7 @@ static void __init fill_pernode(int node
 {
 	void *cpu_data;
 	int cpus = early_nr_cpus_node(node);
-	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
+	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	mem_data[node].pernode_addr = pernode;
 	mem_data[node].pernode_size = pernodesize;
@@ -223,7 +222,7 @@ static int __init find_pernode_space(uns
 {
 	unsigned long epfn;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
+	struct bootmem_data *bdp = &bootmem_node_data[node];
 
 	epfn = (start + len) >> PAGE_SHIFT;
 
@@ -439,7 +438,7 @@ void __init find_memory(void)
 	efi_memmap_walk(find_max_min_low_pfn, NULL);
 
 	for_each_online_node(node)
-		if (mem_data[node].bootmem_data.node_low_pfn) {
+		if (bootmem_node_data[node].node_low_pfn) {
 			node_clear(node, memory_less_mask);
 			mem_data[node].min_pfn = ~0UL;
 		}
@@ -459,7 +458,7 @@ void __init find_memory(void)
 		else if (node_isset(node, memory_less_mask))
 			continue;
 
-		bdp = &mem_data[node].bootmem_data;
+		bdp = &bootmem_node_data[node];
 		pernode = mem_data[node].pernode_addr;
 		pernodesize = mem_data[node].pernode_size;
 		map = pernode + pernodesize;
Index: tree-linus/arch/m32r/mm/discontig.c
===================================================================
--- tree-linus.orig/arch/m32r/mm/discontig.c
+++ tree-linus/arch/m32r/mm/discontig.c
@@ -20,7 +20,6 @@ extern char _end[];
 
 struct pglist_data *node_data[MAX_NUMNODES];
 EXPORT_SYMBOL(node_data);
-static bootmem_data_t node_bdata[MAX_NUMNODES] __initdata;
 
 pg_data_t m32r_node_data[MAX_NUMNODES];
 
@@ -81,7 +80,7 @@ unsigned long __init setup_memory(void)
 	for_each_online_node(nid) {
 		mp = &mem_prof[nid];
 		NODE_DATA(nid)=(pg_data_t *)&m32r_node_data[nid];
-		NODE_DATA(nid)->bdata = &node_bdata[nid];
+		NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
 		min_pfn = mp->start_pfn;
 		max_pfn = mp->start_pfn + mp->pages;
 		bootmap_size = init_bootmem_node(NODE_DATA(nid), mp->free_pfn,
@@ -163,4 +162,3 @@ unsigned long __init zone_sizes_init(voi
 
 	return holes;
 }
-
Index: tree-linus/arch/m68k/mm/init.c
===================================================================
--- tree-linus.orig/arch/m68k/mm/init.c
+++ tree-linus/arch/m68k/mm/init.c
@@ -32,8 +32,6 @@
 
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
-static bootmem_data_t __initdata bootmem_data[MAX_NUMNODES];
-
 pg_data_t pg_data_map[MAX_NUMNODES];
 EXPORT_SYMBOL(pg_data_map);
 
@@ -58,7 +56,7 @@ void __init m68k_setup_node(int node)
 		pg_data_table[i] = pg_data_map + node;
 	}
 #endif
-	pg_data_map[node].bdata = bootmem_data + node;
+	pg_data_map[node].bdata = bootmem_node_data + node;
 	node_set_online(node);
 }
 
Index: tree-linus/arch/mips/sgi-ip27/ip27-memory.c
===================================================================
--- tree-linus.orig/arch/mips/sgi-ip27/ip27-memory.c
+++ tree-linus/arch/mips/sgi-ip27/ip27-memory.c
@@ -37,7 +37,6 @@
 
 static short __initdata slot_lastfilled_cache[MAX_COMPACT_NODES];
 static unsigned short __initdata slot_psize_cache[MAX_COMPACT_NODES][MAX_MEM_SLOTS];
-static struct bootmem_data __initdata plat_node_bdata[MAX_COMPACT_NODES];
 
 struct node_data *__node_data[MAX_COMPACT_NODES];
 
@@ -453,7 +452,7 @@ static void __init node_mem_init(cnodeid
 	__node_data[node] = __va(slot_freepfn << PAGE_SHIFT);
 
 	pd = NODE_DATA(node);
-	pd->bdata = &plat_node_bdata[node];
+	pd->bdata = &bootmem_node_data[node];
 
 	cpus_clear(hub_data(node)->h_cpus);
 
Index: tree-linus/arch/parisc/mm/init.c
===================================================================
--- tree-linus.orig/arch/parisc/mm/init.c
+++ tree-linus/arch/parisc/mm/init.c
@@ -36,7 +36,6 @@ extern int  data_start;
 
 #ifdef CONFIG_DISCONTIGMEM
 struct node_map_data node_data[MAX_NUMNODES] __read_mostly;
-bootmem_data_t bmem_data[MAX_NUMNODES] __read_mostly;
 unsigned char pfnnid_map[PFNNID_MAP_MAX] __read_mostly;
 #endif
 
@@ -262,7 +261,7 @@ static void __init setup_bootmem(void)
 #ifdef CONFIG_DISCONTIGMEM
 	for (i = 0; i < MAX_PHYSMEM_RANGES; i++) {
 		memset(NODE_DATA(i), 0, sizeof(pg_data_t));
-		NODE_DATA(i)->bdata = &bmem_data[i];
+		NODE_DATA(i)->bdata = &bootmem_node_data[i];
 	}
 	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
 
Index: tree-linus/arch/powerpc/mm/numa.c
===================================================================
--- tree-linus.orig/arch/powerpc/mm/numa.c
+++ tree-linus/arch/powerpc/mm/numa.c
@@ -37,7 +37,6 @@ EXPORT_SYMBOL(numa_cpu_lookup_table);
 EXPORT_SYMBOL(numa_cpumask_lookup_table);
 EXPORT_SYMBOL(node_data);
 
-static bootmem_data_t __initdata plat_node_bdata[MAX_NUMNODES];
 static int min_common_depth;
 static int n_mem_addr_cells, n_mem_size_cells;
 
@@ -683,7 +682,7 @@ void __init do_init_bootmem(void)
   		dbg("node %d\n", nid);
 		dbg("NODE_DATA() = %p\n", NODE_DATA(nid));
 
-		NODE_DATA(nid)->bdata = &plat_node_bdata[nid];
+		NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
 		NODE_DATA(nid)->node_start_pfn = start_pfn;
 		NODE_DATA(nid)->node_spanned_pages = end_pfn - start_pfn;
 
Index: tree-linus/arch/sh/mm/numa.c
===================================================================
--- tree-linus.orig/arch/sh/mm/numa.c
+++ tree-linus/arch/sh/mm/numa.c
@@ -14,7 +14,6 @@
 #include <linux/pfn.h>
 #include <asm/sections.h>
 
-static bootmem_data_t plat_node_bdata[MAX_NUMNODES];
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL_GPL(node_data);
 
@@ -35,7 +34,7 @@ void __init setup_memory(void)
 	NODE_DATA(0) = pfn_to_kaddr(free_pfn);
 	memset(NODE_DATA(0), 0, sizeof(struct pglist_data));
 	free_pfn += PFN_UP(sizeof(struct pglist_data));
-	NODE_DATA(0)->bdata = &plat_node_bdata[0];
+	NODE_DATA(0)->bdata = &bootmem_node_data[0];
 
 	/* Set up node 0 */
 	setup_bootmem_allocator(free_pfn);
@@ -66,7 +65,7 @@ void __init setup_bootmem_node(int nid, 
 	free_pfn += PFN_UP(sizeof(struct pglist_data));
 	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
 
-	NODE_DATA(nid)->bdata = &plat_node_bdata[nid];
+	NODE_DATA(nid)->bdata = &bootmem_node_data[nid];
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
 	NODE_DATA(nid)->node_spanned_pages = end_pfn - start_pfn;
 
Index: tree-linus/arch/x86/mm/discontig_32.c
===================================================================
--- tree-linus.orig/arch/x86/mm/discontig_32.c
+++ tree-linus/arch/x86/mm/discontig_32.c
@@ -41,7 +41,6 @@
 
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
-static bootmem_data_t node0_bdata;
 
 /*
  * numa interface - we expect the numa architecture specific code to have
@@ -382,7 +381,7 @@ unsigned long __init setup_memory(void)
 		find_max_pfn_node(nid);
 
 	memset(NODE_DATA(0), 0, sizeof(struct pglist_data));
-	NODE_DATA(0)->bdata = &node0_bdata;
+	NODE_DATA(0)->bdata = &bootmem_node_data[0];
 	setup_bootmem_allocator();
 	return max_low_pfn;
 }
Index: tree-linus/arch/x86/mm/numa_64.c
===================================================================
--- tree-linus.orig/arch/x86/mm/numa_64.c
+++ tree-linus/arch/x86/mm/numa_64.c
@@ -27,8 +27,6 @@
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
 
-bootmem_data_t plat_node_bdata[MAX_NUMNODES];
-
 struct memnode memnode;
 
 int x86_cpu_to_node_map_init[NR_CPUS] = {
@@ -206,7 +204,7 @@ void __init setup_node_bootmem(int nodei
 		nodedata_phys + pgdat_size - 1);
 
 	memset(NODE_DATA(nodeid), 0, sizeof(pg_data_t));
-	NODE_DATA(nodeid)->bdata = &plat_node_bdata[nodeid];
+	NODE_DATA(nodeid)->bdata = &bootmem_node_data[nodeid];
 	NODE_DATA(nodeid)->node_start_pfn = start_pfn;
 	NODE_DATA(nodeid)->node_spanned_pages = end_pfn - start_pfn;
 
Index: tree-linus/include/linux/bootmem.h
===================================================================
--- tree-linus.orig/include/linux/bootmem.h
+++ tree-linus/include/linux/bootmem.h
@@ -38,6 +38,8 @@ typedef struct bootmem_data {
 	struct list_head list;
 } bootmem_data_t;
 
+extern bootmem_data_t bootmem_node_data[];
+
 extern unsigned long bootmem_bootmap_pages(unsigned long);
 extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
 extern void free_bootmem(unsigned long addr, unsigned long size);
Index: tree-linus/mm/bootmem.c
===================================================================
--- tree-linus.orig/mm/bootmem.c
+++ tree-linus/mm/bootmem.c
@@ -19,6 +19,8 @@
 
 #include "internal.h"
 
+bootmem_data_t bootmem_node_data[MAX_NUMNODES] __initdata;
+
 /*
  * Access to this subsystem has to be serialized externally. (this is
  * true for the boot process anyway)
Index: tree-linus/mm/page_alloc.c
===================================================================
--- tree-linus.orig/mm/page_alloc.c
+++ tree-linus/mm/page_alloc.c
@@ -3960,9 +3960,7 @@ void __init set_dma_reserve(unsigned lon
 }
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
-static bootmem_data_t contig_bootmem_data;
-struct pglist_data contig_page_data = { .bdata = &contig_bootmem_data };
-
+struct pglist_data contig_page_data = { .bdata = &bootmem_node_data[0] };
 EXPORT_SYMBOL(contig_page_data);
 #endif
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
