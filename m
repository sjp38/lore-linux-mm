Subject: [3/7] 080 alloc_remap i386
In-Reply-To: <1098973549.shadowen.org
Message-Id: <E1CNBE6-0006bd-0j@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Thu, 28 Oct 2004 15:26:06 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Introduce a new allocator for the NUMA the scares remap space.

Revision: $Rev$

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat 080-alloc_remap-i386
---
 arch/i386/mm/discontig.c  |   55 ++++++++++++++++++++++++++++++++++++++++------
 include/asm-i386/mmzone.h |    2 +
 mm/page_alloc.c           |   35 ++++++++++++++++++++++++++---
 3 files changed, 83 insertions(+), 9 deletions(-)

diff -upN reference/arch/i386/mm/discontig.c current/arch/i386/mm/discontig.c
--- reference/arch/i386/mm/discontig.c
+++ current/arch/i386/mm/discontig.c
@@ -81,6 +81,9 @@ unsigned long node_remap_offset[MAX_NUMN
 void *node_remap_start_vaddr[MAX_NUMNODES];
 void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
 
+void *node_remap_end_vaddr[MAX_NUMNODES];
+void *node_remap_alloc_vaddr[MAX_NUMNODES];
+
 /*
  * FLAT - support for basic PC memory model with discontig enabled, essentially
  *        a single node with all available processors in it with a flat
@@ -136,13 +139,36 @@ static void __init allocate_pgdat(int ni
 	}
 }
 
+void *alloc_remap(int nid, unsigned long size)
+{
+	void *allocation = node_remap_alloc_vaddr[nid];
+
+	printk(KERN_WARNING "APW: alloc_remap(%d, %08lx)\n", nid, size);
+
+	size = ALIGN(size, L1_CACHE_BYTES);
+
+	if (!allocation)
+	return 0;
+	if ((allocation + size) >= node_remap_end_vaddr[nid])
+		return 0;
+
+	node_remap_alloc_vaddr[nid] += size;
+
+	memset(allocation, 0, size);
+
+	printk(KERN_WARNING "APW: alloc_remap(%d, %08lx) = %p\n", nid, size,
+			allocation);
+
+	return allocation;
+}
+
 void __init remap_numa_kva(void)
 {
 	void *vaddr;
 	unsigned long pfn;
 	int node;
 
-	for (node = 1; node < numnodes; ++node) {
+	for (node = 0; node < numnodes; ++node) {
 		for (pfn=0; pfn < node_remap_size[node]; pfn += PTRS_PER_PTE) {
 			vaddr = node_remap_start_vaddr[node]+(pfn<<PAGE_SHIFT);
 			set_pmd_pfn((ulong) vaddr, 
@@ -152,15 +178,21 @@ void __init remap_numa_kva(void)
 	}
 }
 
+/* APW/XXX: not here .. */
+unsigned long zone_bitmap_calculate(unsigned long nr_pages);
 static unsigned long calculate_numa_remap_pages(void)
 {
 	int nid;
 	unsigned long size, reserve_pages = 0;
 
-	for (nid = 1; nid < numnodes; nid++) {
+	for (nid = 0; nid < numnodes; nid++) {
 		/* calculate the size of the mem_map needed in bytes */
 		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
 			* sizeof(struct page) + sizeof(pg_data_t);
+
+		/* Allow for the bitmaps. */
+		size += zone_bitmap_calculate(node_end_pfn[nid] - node_start_pfn[nid] + 1);
+
 		/* convert size to large (pmd size) pages, rounding up */
 		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
 		/* now the roundup is correct, convert to PAGE_SIZE pages */
@@ -168,8 +200,8 @@ static unsigned long calculate_numa_rema
 		printk("Reserving %ld pages of KVA for lmem_map of node %d\n",
 				size, nid);
 		node_remap_size[nid] = size;
-		reserve_pages += size;
 		node_remap_offset[nid] = reserve_pages;
+		reserve_pages += size;
 		printk("Shrinking node %d from %ld pages to %ld pages\n",
 			nid, node_end_pfn[nid], node_end_pfn[nid] - size);
 		node_end_pfn[nid] -= size;
@@ -236,12 +268,18 @@ unsigned long __init setup_memory(void)
 			(ulong) pfn_to_kaddr(max_low_pfn));
 	for (nid = 0; nid < numnodes; nid++) {
 		node_remap_start_vaddr[nid] = pfn_to_kaddr(
-			(highstart_pfn + reserve_pages) - node_remap_offset[nid]);
+			highstart_pfn + node_remap_offset[nid]);
+		/* Init the node remap allocator */
+		node_remap_end_vaddr[nid] = node_remap_start_vaddr[nid] +
+			(node_remap_size[nid] * PAGE_SIZE);
+		node_remap_alloc_vaddr[nid] = node_remap_start_vaddr[nid] +
+			ALIGN(sizeof(pg_data_t), PAGE_SIZE);
+
 		allocate_pgdat(nid);
 		printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
 			(ulong) node_remap_start_vaddr[nid],
-			(ulong) pfn_to_kaddr(highstart_pfn + reserve_pages
-			    - node_remap_offset[nid] + node_remap_size[nid]));
+			(ulong) pfn_to_kaddr(highstart_pfn 
+			    + node_remap_offset[nid] + node_remap_size[nid]));
 	}
 	printk("High memory starts at vaddr %08lx\n",
 			(ulong) pfn_to_kaddr(highstart_pfn));
@@ -307,6 +345,10 @@ void __init zone_sizes_init(void)
 		 * normal bootmem allocator, but other nodes come from the
 		 * remapped KVA area - mbligh
 		 */
+			free_area_init_node(nid, NODE_DATA(nid),
+					zones_size, start, zholes_size);
+
+#if 0
 		if (!nid)
 			free_area_init_node(nid, NODE_DATA(nid),
 					zones_size, start, zholes_size);
@@ -319,6 +361,7 @@ void __init zone_sizes_init(void)
 			free_area_init_node(nid, NODE_DATA(nid), zones_size,
 				start, zholes_size);
 		}
+#endif
 	}
 	return;
 }
diff -upN reference/include/asm-i386/mmzone.h current/include/asm-i386/mmzone.h
--- reference/include/asm-i386/mmzone.h
+++ current/include/asm-i386/mmzone.h
@@ -16,6 +16,8 @@
 	#else	/* summit or generic arch */
 		#include <asm/srat.h>
 	#endif
+	#define HAVE_ARCH_ALLOC_REMAP	1
+
 #else /* !CONFIG_NUMA */
 	#define get_memcfg_numa get_memcfg_numa_flat
 	#define get_zholes_size(n) (0)
diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c
+++ current/mm/page_alloc.c
@@ -94,6 +94,9 @@ static void bad_page(const char *functio
 	page->mapping = NULL;
 }
 
+/* APW/XXX: not here. */
+void *alloc_remap(int nid, unsigned long size);
+
 #ifndef CONFIG_HUGETLB_PAGE
 #define prep_compound_page(page, order) do { } while (0)
 #define destroy_compound_page(page, order) do { } while (0)
@@ -1442,11 +1445,23 @@ unsigned long pages_to_bitmap_size(unsig
 	return bitmap_size;
 }
 
+unsigned long zone_bitmap_calculate(unsigned long nr_pages)
+{
+	unsigned long overall_size = 0;
+	int order;
+
+	for (order = 0; order < MAX_ORDER - 1; order++)
+		overall_size += pages_to_bitmap_size(order, nr_pages);
+	
+	return overall_size;
+}
+
 void zone_init_free_lists(struct pglist_data *pgdat, struct zone *zone, unsigned long size)
 {
 	int order;
 	for (order = 0; ; order++) {
 		unsigned long bitmap_size;
+		unsigned long *map;
 
 		INIT_LIST_HEAD(&zone->free_area[order].free_list);
 		if (order == MAX_ORDER-1) {
@@ -1455,8 +1470,15 @@ void zone_init_free_lists(struct pglist_
 		}
 
 		bitmap_size = pages_to_bitmap_size(order, size);
-		zone->free_area[order].map =
-		  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
+
+#ifdef HAVE_ARCH_ALLOC_REMAP
+		map = (unsigned long *) alloc_remap(pgdat->node_id,
+			bitmap_size);
+		if (!map) 
+#endif
+			map = (unsigned long *) alloc_bootmem_node(pgdat,
+				bitmap_size);
+		zone->free_area[order].map = map;
 	}
 }
 
@@ -1581,9 +1603,16 @@ static void __init free_area_init_core(s
 void __init node_alloc_mem_map(struct pglist_data *pgdat)
 {
 	unsigned long size;
+	void *map;
 
 	size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
-	pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
+
+#ifdef HAVE_ARCH_ALLOC_REMAP
+	map = (unsigned long *) alloc_remap(pgdat->node_id, size);
+	if (!map)
+#endif
+		map = alloc_bootmem_node(pgdat, size);
+	pgdat->node_mem_map = map;
 #ifndef CONFIG_DISCONTIGMEM
 	mem_map = contig_page_data.node_mem_map;
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
