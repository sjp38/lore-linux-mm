Date: Thu, 15 Aug 2002 17:10:49 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Giving free_area_init_* a rototilling
Message-ID: <2419790000.1029456649@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>
Cc: discontig-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Below is a half-finished patch .... trying to clean up the gross mess
in free_area_init for discongtimem, and get rid of all the hack
"mem_map = PAGE_OFFSET" and add map_nr's from there stuff.
It probably doesn't even compile, but I'd be interested in any feedback
on the approach. It also depends on another patch to convert the paddrs
to pfns, which I can send if you want, but I think the attatched should
be readable?

diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/arch/alpha/mm/numa.c 2.5.31-22/arch/alpha/mm/numa.c
--- 2.5.31-20/arch/alpha/mm/numa.c	Wed Aug 14 08:38:36 2002
+++ 2.5.31-22/arch/alpha/mm/numa.c	Thu Aug 15 16:29:43 2002
@@ -295,7 +295,9 @@
 			zones_size[ZONE_NORMAL] = (end_pfn - start_pfn) - dma_local_pfn;
 		}
 		free_area_init_node(nid, NODE_DATA(nid), NULL, zones_size, start_pfn, NULL);
-		lmax_mapnr = PLAT_NODE_DATA_STARTNR(nid) + PLAT_NODE_DATA_SIZE(nid);
+		/* THIS IS EVIL. Stop using mapnr for discontigmem */
+		lmax_mapnr = PLAT_NODE_DATA(n)->node_mem_map - mem_map 
+			+ PLAT_NODE_DATA_SIZE(nid);
 		if (lmax_mapnr > max_mapnr) {
 			max_mapnr = lmax_mapnr;
 			DBGDCONT("Grow max_mapnr to %ld\n", max_mapnr);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/arch/mips64/sgi-ip27/ip27-memory.c 2.5.31-22/arch/mips64/sgi-ip27/ip27-memory.c
--- 2.5.31-20/arch/mips64/sgi-ip27/ip27-memory.c	Wed Aug 14 08:38:36 2002
+++ 2.5.31-22/arch/mips64/sgi-ip27/ip27-memory.c	Thu Aug 15 16:48:00 2002
@@ -234,6 +234,7 @@
 	cnodeid_t node;
 	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
 	int i;
+	unsigned long lmax_mapnr;
 
 	/* Initialize the entire pgd.  */
 	pgd_init((unsigned long)swapper_pg_dir);
@@ -254,10 +255,11 @@
 		zones_size[ZONE_DMA] = end_pfn + 1 - start_pfn;
 		free_area_init_node(node, NODE_DATA(node), 0, zones_size, 
 						start_pfn, 0);
-		if ((PLAT_NODE_DATA_STARTNR(node) + 
-					PLAT_NODE_DATA_SIZE(node)) > pagenr)
-			pagenr = PLAT_NODE_DATA_STARTNR(node) +
-					PLAT_NODE_DATA_SIZE(node);
+		/* THIS IS EVIL. Stop using mapnr for discontigmem */
+		lmax_mapnr = PLAT_NODE_DATA(n)->node_mem_map - mem_map +
+			PLAT_NODE_DATA_SIZE(node);
+		if (lmax_mapnr > pagenr)
+			pagenr = lmax_mapnr;
 	}
 }
 
@@ -271,7 +273,6 @@
 	unsigned long codesize, datasize, initsize;
 	int slot, numslots;
 	struct page *pg, *pslot;
-	pfn_t pgnr;
 
 	num_physpages = numpages;	/* memory already sized by szmem */
 	max_mapnr = pagenr;		/* already found during paging_init */
@@ -293,7 +294,6 @@
 		 * We need to manually do the other slots.
 		 */
 		pg = NODE_DATA(nid)->node_mem_map + slot_getsize(nid, 0);
-		pgnr = PLAT_NODE_DATA_STARTNR(nid) + slot_getsize(nid, 0);
 		numslots = node_getlastslot(nid);
 		for (slot = 1; slot <= numslots; slot++) {
 			pslot = NODE_DATA(nid)->node_mem_map + 
@@ -304,7 +304,7 @@
 			 * free up the pages that hold the memmap entries.
 			 */
 			while (pg < pslot) {
-				pg++; pgnr++;
+				pg++;
 			}
 
 			/*
@@ -312,8 +312,8 @@
 			 */
 			pslot += slot_getsize(nid, slot);
 			while (pg < pslot) {
-				if (!page_is_ram(pgnr))
-					continue;
+				/* if (!page_is_ram(pgnr)) continue; */
+				/* commented out until page_is_ram works */
 				ClearPageReserved(pg);
 				atomic_set(&pg->count, 1);
 				__free_page(pg);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/asm-alpha/mmzone.h 2.5.31-22/include/asm-alpha/mmzone.h
--- 2.5.31-20/include/asm-alpha/mmzone.h	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/include/asm-alpha/mmzone.h	Thu Aug 15 16:22:31 2002
@@ -46,8 +46,6 @@
 
 #define PHYSADDR_TO_NID(pa)		ALPHA_PA_TO_NID(pa)
 #define PLAT_NODE_DATA(n)		(plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 
 #if 1
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/asm-i386/mmzone.h 2.5.31-22/include/asm-i386/mmzone.h
--- 2.5.31-20/include/asm-i386/mmzone.h	Wed Aug 14 08:46:05 2002
+++ 2.5.31-22/include/asm-i386/mmzone.h	Thu Aug 15 16:23:03 2002
@@ -49,8 +49,6 @@
 	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
 
 #define PLAT_NODE_DATA(n)		(plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(pfn, n) \
 	((pfn) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/asm-mips64/mmzone.h 2.5.31-22/include/asm-mips64/mmzone.h
--- 2.5.31-20/include/asm-mips64/mmzone.h	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/include/asm-mips64/mmzone.h	Thu Aug 15 16:23:36 2002
@@ -24,7 +24,6 @@
 
 #define PHYSADDR_TO_NID(pa)		NASID_TO_COMPACT_NODEID(NASID_GET(pa))
 #define PLAT_NODE_DATA(n)		(plat_node_data[n])
-#define PLAT_NODE_DATA_STARTNR(n)    (PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)	     (PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n) \
 		(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/asm-mips64/pgtable.h 2.5.31-22/include/asm-mips64/pgtable.h
--- 2.5.31-20/include/asm-mips64/pgtable.h	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/include/asm-mips64/pgtable.h	Thu Aug 15 17:04:43 2002
@@ -373,10 +373,10 @@
 #ifndef CONFIG_DISCONTIGMEM
 #define pte_page(x)		(mem_map+(unsigned long)((pte_val(x) >> PAGE_SHIFT)))
 #else
-#define mips64_pte_pagenr(x) \
-	(PLAT_NODE_DATA_STARTNR(PHYSADDR_TO_NID(pte_val(x))) + \
-	PLAT_NODE_DATA_LOCALNR(pte_val(x), PHYSADDR_TO_NID(pte_val(x))))
-#define pte_page(x)		(mem_map+mips64_pte_pagenr(x))
+
+#define pte_page(x) ( NODE_MEM_MAP(PHYSADDR_TO_NID(pte_val(x))) +
+	PLAT_NODE_DATA_LOCALNR(pte_val(x), PHYSADDR_TO_NID(pte_val(x))) )
+				  
 #endif
 
 /*
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/asm-ppc64/mmzone.h 2.5.31-22/include/asm-ppc64/mmzone.h
--- 2.5.31-20/include/asm-ppc64/mmzone.h	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/include/asm-ppc64/mmzone.h	Thu Aug 15 16:24:21 2002
@@ -24,8 +24,6 @@
 /* XXX grab this from the device tree - Anton */
 #define PHYSADDR_TO_NID(pa)		((pa) >> 36)
 #define PLAT_NODE_DATA(n)		(&plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n)	\
 	(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/include/linux/mmzone.h 2.5.31-22/include/linux/mmzone.h
--- 2.5.31-20/include/linux/mmzone.h	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/include/linux/mmzone.h	Thu Aug 15 15:42:25 2002
@@ -83,7 +83,6 @@
 	struct page		*zone_mem_map;
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
-	unsigned long		zone_start_mapnr;
 
 	/*
 	 * rarely used fields:
@@ -134,7 +133,6 @@
 	unsigned long *valid_addr_bitmap;
 	struct bootmem_data *bdata;
 	unsigned long node_start_pfn;
-	unsigned long node_start_mapnr;
 	unsigned long node_size;
 	int node_id;
 	struct pglist_data *pgdat_next;
@@ -158,7 +156,9 @@
  */
 struct page;
 extern void show_free_areas_core(pg_data_t *pgdat);
-extern void free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
+extern void calculate_totalpages (pg_data_t *pgdat, unsigned long *zones_size,
+		                unsigned long *zholes_size);
+extern void free_area_init_core(int nid, pg_data_t *pgdat,
   unsigned long *zones_size, unsigned long paddr, unsigned long *zholes_size,
   struct page *pmap);
 
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/mm/numa.c 2.5.31-22/mm/numa.c
--- 2.5.31-20/mm/numa.c	Wed Aug 14 08:38:37 2002
+++ 2.5.31-22/mm/numa.c	Thu Aug 15 16:00:12 2002
@@ -22,11 +22,21 @@
  * Should be invoked with paramters (0, 0, unsigned long *[], start_paddr).
  */
 void __init free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
-	unsigned long *zones_size, unsigned long zone_start_pfn, 
+	unsigned long *zones_size, unsigned long node_start_pfn, 
 	unsigned long *zholes_size)
 {
-	free_area_init_core(0, &contig_page_data, &mem_map, zones_size, 
-				zone_start_pfn, zholes_size, pmap);
+	unsigned long size;
+
+	contig_page_data->node_mem_map = pmap;
+	contig_page_data->node_id = 0;
+	contig_page_data->node_start_pfn = node_start_pfn;
+	calculate_totalpages (&contig_page_data, zones_size, zholes_size);
+	if (pmap == (struct page *)0) {
+		size = (pgdat->node_size + 1) * sizeof(struct page);
+		pmap = (struct page *) alloc_bootmem_node(pgdat, size);
+	}
+	free_area_init_core(&contig_page_data, zones_size, zholes_size);
+	mem_map = contig_page_data->node_mem_map;
 }
 
 #endif /* !CONFIG_DISCONTIGMEM */
@@ -48,22 +58,26 @@
  * Nodes can be initialized parallely, in no particular order.
  */
 void __init free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
-	unsigned long *zones_size, unsigned long zone_start_pfn, 
+	unsigned long *zones_size, unsigned long node_start_pfn, 
 	unsigned long *zholes_size)
 {
-	int i, size = 0;
-	struct page *discard;
-
-	if (mem_map == NULL)
-		mem_map = (struct page *)PAGE_OFFSET;
+	int i;
+	unsigned long size;
 
-	free_area_init_core(nid, pgdat, &discard, zones_size, zone_start_pfn,
-					zholes_size, pmap);
 	pgdat->node_id = nid;
+	pgdat->node_mem_map = pmap;
+	pgdat->node_start_pfn = node_start_pfn;
+	calculate_totalpages (pgdat, zones_size, zholes_size);
+	if (pmap == (struct page *)0) {
+		size = (pgdat->node_size + 1) * sizeof(struct page); 
+		pmap = (struct page *) alloc_bootmem_node(pgdat, size);
+	}
+	free_area_init_core(pgdat, zones_size, zone_start_pfn);
 
 	/*
 	 * Get space for the valid bitmap.
 	 */
+	size = 0;
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		size += zones_size[i];
 	size = LONG_ALIGN((size + 7) >> 3);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-20/mm/page_alloc.c 2.5.31-22/mm/page_alloc.c
--- 2.5.31-20/mm/page_alloc.c	Wed Aug 14 22:33:34 2002
+++ 2.5.31-22/mm/page_alloc.c	Thu Aug 15 16:14:50 2002
@@ -47,9 +47,9 @@
  */
 static inline int bad_range(zone_t *zone, struct page *page)
 {
-	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->size)
+	if (page_to_pfn(page) >= zone->zone_start_mapnr + zone->size)
 		return 1;
-	if (page_to_pfn(page) < zone->zone_start_pfn)
+	if (page_to_pfn(page) < zone->zone_start_mapnr)
 		return 1;
 	if (zone != page_zone(page))
 		return 1;
@@ -707,6 +707,25 @@
 	} 
 }
 
+void __init calculate_totalpages (pg_data_t *pgdat, unsigned long *zones_size,
+	unsigned long *zholes_size)
+{
+	unsigned long realtotalpages, totalpages = 0;
+	int i;
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		unsigned long size = zones_size[i];
+		totalpages += size;
+	}
+	pgdat->node_size = totalpages;
+
+	realtotalpages = totalpages;
+	if (zholes_size)
+		for (i = 0; i < MAX_NR_ZONES; i++)
+			realtotalpages -= zholes_size[i];
+	printk("On node %d totalpages: %lu\n", nid, realtotalpages);
+}
+
 /*
  * Helper functions to size the waitqueue hash table.
  * Essentially these want to choose hash table sizes sufficiently
@@ -757,47 +776,18 @@
  *   - mark all memory queues empty
  *   - clear the memory bitmaps
  */
-void __init free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
-	unsigned long *zones_size, unsigned long zone_start_pfn, 
-	unsigned long *zholes_size, struct page *lmem_map)
+void __init free_area_init_core(pg_data_t *pgdat,
+	unsigned long *zones_size, unsigned long *zholes_size)
 {
 	unsigned long i, j;
-	unsigned long map_size;
-	unsigned long totalpages, offset, realtotalpages;
+	unsigned long local_offset, zone_start_paddr;
 	const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
-
-	totalpages = 0;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		unsigned long size = zones_size[i];
-		totalpages += size;
-	}
-	realtotalpages = totalpages;
-	if (zholes_size)
-		for (i = 0; i < MAX_NR_ZONES; i++)
-			realtotalpages -= zholes_size[i];
-			
-	printk("On node %d totalpages: %lu\n", nid, realtotalpages);
-
-	/*
-	 * Some architectures (with lots of mem and discontinous memory
-	 * maps) have to search for a good mem_map area:
-	 * For discontigmem, the conceptual mem map array starts from 
-	 * PAGE_OFFSET, we need to align the actual array onto a mem map 
-	 * boundary, so that MAP_NR works.
-	 */
-	map_size = (totalpages + 1)*sizeof(struct page);
-	if (lmem_map == (struct page *)0) {
-		lmem_map = (struct page *) alloc_bootmem_node(pgdat, map_size);
-		lmem_map = (struct page *)(PAGE_OFFSET + 
-			MAP_ALIGN((unsigned long)lmem_map - PAGE_OFFSET));
-	}
-	*gmap = pgdat->node_mem_map = lmem_map;
-	pgdat->node_size = totalpages;
-	pgdat->node_start_pfn = zone_start_pfn;
-	pgdat->node_start_mapnr = (lmem_map - mem_map);
+	int nid = pgdat->node_id;
+	struct page *lmem_map = pgdat->node_mem_map;
+	unsigned long zone_start_pfn = pgdat->node_start_pfn;
+	
 	pgdat->nr_zones = 0;
-
-	offset = lmem_map - mem_map;	
+	local_offset = 0;                /* offset within lmem_map */
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		zone_t *zone = pgdat->node_zones + j;
 		unsigned long mask;
@@ -843,8 +833,7 @@
 		zone->pages_low = mask*2;
 		zone->pages_high = mask*3;
 
-		zone->zone_mem_map = mem_map + offset;
-		zone->zone_start_mapnr = offset;
+		zone->zone_mem_map = lmem_map + local_offset;
 		zone->zone_start_pfn = zone_start_pfn;
 
 		if ((zone_start_pfn) & (zone_required_alignment-1))
@@ -856,7 +845,7 @@
 		 * done. Non-atomic initialization, single-pass.
 		 */
 		for (i = 0; i < size; i++) {
-			struct page *page = mem_map + offset + i;
+			struct page *page = lmem_map + local_offset + i;
 			set_page_zone(page, nid * MAX_NR_ZONES + j);
 			set_page_count(page, 0);
 			SetPageReserved(page);
@@ -870,7 +859,7 @@
 			zone_start_pfn++;
 		}
 
-		offset += size;
+		local_offset += size;
 		for (i = 0; ; i++) {
 			unsigned long bitmap_size;
 
@@ -914,7 +903,8 @@
 
 void __init free_area_init(unsigned long *zones_size)
 {
-	free_area_init_core(0, &contig_page_data, &mem_map, zones_size, 0, 0, 0);
+	free_area_init_node(0, &contig_page_data, pmap, zones_size, 0, 0, 0);
+	mem_map = contig_page_data->node_mem_map;
 }
 
 static int __init setup_mem_frac(char *str)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
