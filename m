Date: Sat, 17 Aug 2002 08:19:01 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: clean up free_area_init stuff
Message-ID: <2196298850.1029572341@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>, discontig-devel@lists.sourceforge.net
Cc: anton@samba.org
List-ID: <linux-mm.kvack.org>

This still seems to have a couple of bugs in it, but at least
it compiles now ;-) Any feedback would be much appreciated ...
I'll work on getting the bugs out of it ... the other discontig
arches need a little bit of cleanup still to get rid of max_mapnr.

M.

diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/alpha/mm/numa.c 2.5.31-22-free_area_init/arch/alpha/mm/numa.c
--- 2.5.31-21-bad_range/arch/alpha/mm/numa.c	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/arch/alpha/mm/numa.c	Thu Aug 15 16:29:43 2002
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
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/i386/kernel/cpu/amd.c 2.5.31-22-free_area_init/arch/i386/kernel/cpu/amd.c
--- 2.5.31-21-bad_range/arch/i386/kernel/cpu/amd.c	Sat Aug 10 18:41:55 2002
+++ 2.5.31-22-free_area_init/arch/i386/kernel/cpu/amd.c	Fri Aug 16 09:47:47 2002
@@ -25,7 +25,7 @@
 static void __init init_amd(struct cpuinfo_x86 *c)
 {
 	u32 l, h;
-	int mbytes = max_mapnr >> (20-PAGE_SHIFT);
+	int mbytes = num_physpages >> (20-PAGE_SHIFT);
 	int r;
 
 	/*
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/i386/kernel/numaq.c 2.5.31-22-free_area_init/arch/i386/kernel/numaq.c
--- 2.5.31-21-bad_range/arch/i386/kernel/numaq.c	Fri Aug 16 11:26:20 2002
+++ 2.5.31-22-free_area_init/arch/i386/kernel/numaq.c	Fri Aug 16 22:46:31 2002
@@ -80,27 +80,19 @@
  */
 int physnode_map[MAX_ELEMENTS] = { [0 ... (MAX_ELEMENTS - 1)] = -1};
 
-#define MB_TO_ELEMENT(x) (x >> ELEMENT_REPRESENTS)
-#define PA_TO_MB(pa) (pa >> 20) 	/* assumption: a physical address is in bytes */
+#define PFN_TO_ELEMENT(pfn) (pfn / PAGES_PER_ELEMENT)
+#define PA_TO_ELEMENT(pa) (PFN_TO_ELEMENT(pa >> PAGE_SHIFT))
 
-int numaqpa_to_nid(u64 pa)
+int pfn_to_nid(unsigned long pfn)
 {
-	int nid;
-	
-	nid = physnode_map[MB_TO_ELEMENT(PA_TO_MB(pa))];
+	int nid = physnode_map[PFN_TO_ELEMENT(pfn)];
 
-	/* the physical address passed in is not in the map for the system */
 	if (nid == -1)
-		BUG();
+		BUG(); /* address is not present */
 
 	return nid;
 }
 
-int numaqpfn_to_nid(unsigned long pfn)
-{
-	return numaqpa_to_nid(((u64)pfn) << PAGE_SHIFT);
-}
-
 /*
  * for each node mark the regions
  *        TOPOFMEM = hi_shrd_mem_start + hi_shrd_mem_size
@@ -130,7 +122,7 @@
 			topofmem = eq->hi_shrd_mem_start + eq->hi_shrd_mem_size;
 			while (cur < topofmem) {
 				physnode_map[cur >> 8] = nid;
-				cur += (ELEMENT_REPRESENTS - 1);
+				cur ++;
 			}
 		}
 	}
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/i386/mm/discontig.c 2.5.31-22-free_area_init/arch/i386/mm/discontig.c
--- 2.5.31-21-bad_range/arch/i386/mm/discontig.c	Fri Aug 16 11:26:20 2002
+++ 2.5.31-22-free_area_init/arch/i386/mm/discontig.c	Sat Aug 17 07:34:09 2002
@@ -282,20 +282,10 @@
 void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	unsigned long lmax_mapnr;
-	int nid;
-	
-	highmem_start_page = mem_map + NODE_DATA(0)->node_zones[ZONE_HIGHMEM].zone_start_mapnr;
+	highmem_start_page = NODE_DATA(0)->node_zones[ZONE_HIGHMEM].zone_mem_map;
 	num_physpages = highend_pfn;
 
-	for (nid = 0; nid < numnodes; nid++) {
-		lmax_mapnr = PLAT_NODE_DATA_STARTNR(nid) + PLAT_NODE_DATA_SIZE(nid);
-		if (lmax_mapnr > max_mapnr) {
-			max_mapnr = lmax_mapnr;
-		}
-	}
-	
 #else
-	max_mapnr = num_physpages = max_low_pfn;
+	num_physpages = max_low_pfn;
 #endif
 }
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/i386/mm/init.c 2.5.31-22-free_area_init/arch/i386/mm/init.c
--- 2.5.31-21-bad_range/arch/i386/mm/init.c	Fri Aug 16 11:34:33 2002
+++ 2.5.31-22-free_area_init/arch/i386/mm/init.c	Fri Aug 16 09:54:28 2002
@@ -469,7 +469,7 @@
 
 	printk("Memory: %luk/%luk available (%dk kernel code, %dk reserved, %dk data, %dk init, %ldk highmem)\n",
 		(unsigned long) nr_free_pages() << (PAGE_SHIFT-10),
-		max_mapnr << (PAGE_SHIFT-10),
+		num_physpages << (PAGE_SHIFT-10),
 		codesize >> 10,
 		reservedpages << (PAGE_SHIFT-10),
 		datasize >> 10,
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/i386/mm/pgtable.c 2.5.31-22-free_area_init/arch/i386/mm/pgtable.c
--- 2.5.31-21-bad_range/arch/i386/mm/pgtable.c	Fri Aug 16 11:34:33 2002
+++ 2.5.31-22-free_area_init/arch/i386/mm/pgtable.c	Fri Aug 16 22:48:43 2002
@@ -22,26 +22,29 @@
 
 void show_mem(void)
 {
-	int pfn, total = 0, reserved = 0;
+	int total = 0, reserved = 0;
 	int shared = 0, cached = 0;
 	int highmem = 0;
 	struct page *page;
+	pg_data_t *pgdat;
+	unsigned long i;
 
 	printk("Mem-info:\n");
 	show_free_areas();
 	printk("Free swap:       %6dkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
-	pfn = max_mapnr;
-	while (pfn-- > 0) {
-		page = pfn_to_page(pfn);
-		total++;
-		if (PageHighMem(page))
-			highmem++;
-		if (PageReserved(page))
-			reserved++;
-		else if (PageSwapCache(page))
-			cached++;
-		else if (page_count(page))
-			shared += page_count(page) - 1;
+	for_each_pgdat(pgdat) {
+		for (i = 0; i < pgdat->node_size; ++i) {
+			page = pgdat->node_mem_map + i;
+			total++;
+			if (PageHighMem(page))
+				highmem++;
+			if (PageReserved(page))
+				reserved++;
+			else if (PageSwapCache(page))
+				cached++;
+			else if (page_count(page))
+				shared += page_count(page) - 1;
+		}
 	}
 	printk("%d pages of RAM\n", total);
 	printk("%d pages of HIGHMEM\n",highmem);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/arch/mips64/sgi-ip27/ip27-memory.c 2.5.31-22-free_area_init/arch/mips64/sgi-ip27/ip27-memory.c
--- 2.5.31-21-bad_range/arch/mips64/sgi-ip27/ip27-memory.c	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/arch/mips64/sgi-ip27/ip27-memory.c	Thu Aug 15 16:48:00 2002
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
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-alpha/mmzone.h 2.5.31-22-free_area_init/include/asm-alpha/mmzone.h
--- 2.5.31-21-bad_range/include/asm-alpha/mmzone.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/asm-alpha/mmzone.h	Thu Aug 15 16:22:31 2002
@@ -46,8 +46,6 @@
 
 #define PHYSADDR_TO_NID(pa)		ALPHA_PA_TO_NID(pa)
 #define PLAT_NODE_DATA(n)		(plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 
 #if 1
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-i386/mmzone.h 2.5.31-22-free_area_init/include/asm-i386/mmzone.h
--- 2.5.31-21-bad_range/include/asm-i386/mmzone.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-22-free_area_init/include/asm-i386/mmzone.h	Sat Aug 17 07:17:13 2002
@@ -12,7 +12,6 @@
 #include <asm/numaq.h>
 #else
 #define PHYSADDR_TO_NID(pa)	(0)
-#define PFN_TO_NID(pfn)		(0)
 #ifdef CONFIG_NUMA
 #define _cpu_to_node(cpu) 0
 #endif /* CONFIG_NUMA */
@@ -49,8 +48,6 @@
 	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
 
 #define PLAT_NODE_DATA(n)		(plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(pfn, n) \
 	((pfn) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
@@ -94,8 +91,9 @@
 #define kern_addr_valid(kaddr)	test_bit(LOCAL_MAP_NR(kaddr), \
 					 NODE_DATA(KVADDR_TO_NID(kaddr))->valid_addr_bitmap)
 
-#define pfn_to_page(pfn)	(NODE_MEM_MAP(PFN_TO_NID(pfn)) + PLAT_NODE_DATA_LOCALNR(pfn, PFN_TO_NID(pfn)))
+#define pfn_to_page(pfn)	(NODE_MEM_MAP(pfn_to_nid(pfn)) + PLAT_NODE_DATA_LOCALNR(pfn, PFN_TO_NID(pfn)))
 #define page_to_pfn(page)	((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#define pfn_valid(pfn)          (pfn_to_pgdat(pfn) && (pfn < pfn_to_pgdat(pfn)->node_size))
 #endif /* CONFIG_DISCONTIGMEM */
 #endif /* _ASM_MMZONE_H_ */
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-i386/numaq.h 2.5.31-22-free_area_init/include/asm-i386/numaq.h
--- 2.5.31-21-bad_range/include/asm-i386/numaq.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-22-free_area_init/include/asm-i386/numaq.h	Sat Aug 17 07:30:58 2002
@@ -32,20 +32,19 @@
 
 /*
  * for now assume that 64Gb is max amount of RAM for whole system
- *    64Gb * 1024Mb/Gb = 65536 Mb
- *    65536 Mb / 256Mb = 256
+ *    64Gb / 4096bytes/page = 16777216 pages
  */
+#define MAX_NR_PAGES 16777216
 #define MAX_ELEMENTS 256
-#define ELEMENT_REPRESENTS 8 /* 256 Mb */
+#define PAGES_PER_ELEMENT (16777216/256)
 
-#define PHYSADDR_TO_NID(pa) numaqpa_to_nid(pa)
-#define PFN_TO_NID(pa) numaqpfn_to_nid(pa)
+#define pfn_to_pgdat(pfn) NODE_DATA(pfn_to_nid(pfn))
+#define PHYSADDR_TO_NID(pa) pfn_to_nid(pa >> PAGE_SHIFT)
 #define MAX_NUMNODES		8
 #ifdef CONFIG_NUMA
 #define _cpu_to_node(cpu) (cpu_to_logical_apicid(cpu) >> 4)
 #endif /* CONFIG_NUMA */
-extern int numaqpa_to_nid(u64);
-extern int numaqpfn_to_nid(unsigned long);
+extern int pfn_to_nid(unsigned long);
 extern void get_memcfg_numaq(void);
 #define get_memcfg_numa() get_memcfg_numaq()
 
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-i386/page.h 2.5.31-22-free_area_init/include/asm-i386/page.h
--- 2.5.31-21-bad_range/include/asm-i386/page.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-22-free_area_init/include/asm-i386/page.h	Fri Aug 16 10:09:21 2002
@@ -137,10 +137,10 @@
 #ifndef CONFIG_DISCONTIGMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))
+#define pfn_valid(pfn)		((pfn) < max_mapnr)
 #endif /* !CONFIG_DISCONTIGMEM */
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
-#define pfn_valid(pfn)		((pfn) < max_mapnr)
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | VM_EXEC | \
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-mips64/mmzone.h 2.5.31-22-free_area_init/include/asm-mips64/mmzone.h
--- 2.5.31-21-bad_range/include/asm-mips64/mmzone.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/asm-mips64/mmzone.h	Thu Aug 15 16:23:36 2002
@@ -24,7 +24,6 @@
 
 #define PHYSADDR_TO_NID(pa)		NASID_TO_COMPACT_NODEID(NASID_GET(pa))
 #define PLAT_NODE_DATA(n)		(plat_node_data[n])
-#define PLAT_NODE_DATA_STARTNR(n)    (PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)	     (PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n) \
 		(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-mips64/pgtable.h 2.5.31-22-free_area_init/include/asm-mips64/pgtable.h
--- 2.5.31-21-bad_range/include/asm-mips64/pgtable.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/asm-mips64/pgtable.h	Thu Aug 15 17:04:43 2002
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
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/asm-ppc64/mmzone.h 2.5.31-22-free_area_init/include/asm-ppc64/mmzone.h
--- 2.5.31-21-bad_range/include/asm-ppc64/mmzone.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/asm-ppc64/mmzone.h	Thu Aug 15 16:24:21 2002
@@ -24,8 +24,6 @@
 /* XXX grab this from the device tree - Anton */
 #define PHYSADDR_TO_NID(pa)		((pa) >> 36)
 #define PLAT_NODE_DATA(n)		(&plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n)	\
 	(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/linux/mm.h 2.5.31-22-free_area_init/include/linux/mm.h
--- 2.5.31-21-bad_range/include/linux/mm.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/linux/mm.h	Fri Aug 16 09:50:17 2002
@@ -15,7 +15,10 @@
 #include <linux/rbtree.h>
 #include <linux/fs.h>
 
+#ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
+#endif
+
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/include/linux/mmzone.h 2.5.31-22-free_area_init/include/linux/mmzone.h
--- 2.5.31-21-bad_range/include/linux/mmzone.h	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/include/linux/mmzone.h	Fri Aug 16 20:49:10 2002
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
@@ -158,9 +156,10 @@
  */
 struct page;
 extern void show_free_areas_core(pg_data_t *pgdat);
-extern void free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
-  unsigned long *zones_size, unsigned long paddr, unsigned long *zholes_size,
-  struct page *pmap);
+extern void calculate_totalpages (pg_data_t *pgdat, unsigned long *zones_size,
+		                unsigned long *zholes_size);
+extern void free_area_init_core(pg_data_t *pgdat, unsigned long *zones_size, 
+		unsigned long *zholes_size);
 
 extern pg_data_t contig_page_data;
 
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/kernel/ksyms.c 2.5.31-22-free_area_init/kernel/ksyms.c
--- 2.5.31-21-bad_range/kernel/ksyms.c	Sat Aug 10 18:41:17 2002
+++ 2.5.31-22-free_area_init/kernel/ksyms.c	Fri Aug 16 09:51:00 2002
@@ -112,7 +112,9 @@
 EXPORT_SYMBOL(vmalloc_to_page);
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(remap_page_range);
+#ifndef CONFIG_DISCONTIGMEM
 EXPORT_SYMBOL(max_mapnr);
+#endif
 EXPORT_SYMBOL(high_memory);
 EXPORT_SYMBOL(vmtruncate);
 EXPORT_SYMBOL(find_vma);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/mm/memory.c 2.5.31-22-free_area_init/mm/memory.c
--- 2.5.31-21-bad_range/mm/memory.c	Sat Aug 10 18:41:28 2002
+++ 2.5.31-22-free_area_init/mm/memory.c	Fri Aug 16 09:53:11 2002
@@ -53,7 +53,9 @@
 
 #include <linux/swapops.h>
 
+#ifndef CONFIG_DISCONTIGMEM
 unsigned long max_mapnr;
+#endif
 unsigned long num_physpages;
 void * high_memory;
 struct page *highmem_start_page;
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/mm/numa.c 2.5.31-22-free_area_init/mm/numa.c
--- 2.5.31-21-bad_range/mm/numa.c	Fri Aug 16 11:25:57 2002
+++ 2.5.31-22-free_area_init/mm/numa.c	Sat Aug 17 07:35:29 2002
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
+	contig_page_data.node_mem_map = pmap;
+	contig_page_data.node_id = 0;
+	contig_page_data.node_start_pfn = node_start_pfn;
+	calculate_totalpages (&contig_page_data, zones_size, zholes_size);
+	if (pmap == (struct page *)0) {
+		size = (pgdat->node_size + 1) * sizeof(struct page);
+		pmap = (struct page *) alloc_bootmem_node(pgdat, size);
+	}
+	free_area_init_core(&contig_page_data, zones_size, zholes_size);
+	mem_map = contig_page_data.node_mem_map;
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
+	free_area_init_core(pgdat, zones_size, zholes_size);
 
 	/*
 	 * Get space for the valid bitmap.
 	 */
+	size = 0;
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		size += zones_size[i];
 	size = LONG_ALIGN((size + 7) >> 3);
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-21-bad_range/mm/page_alloc.c 2.5.31-22-free_area_init/mm/page_alloc.c
--- 2.5.31-21-bad_range/mm/page_alloc.c	Fri Aug 16 13:43:20 2002
+++ 2.5.31-22-free_area_init/mm/page_alloc.c	Fri Aug 16 21:21:22 2002
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
+	printk("On node %d totalpages: %lu\n", pgdat->node_id, realtotalpages);
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
+	unsigned long local_offset;
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
+	free_area_init_node(0, &contig_page_data, NULL, zones_size, 0, NULL);
+	mem_map = contig_page_data.node_mem_map;
 }
 
 static int __init setup_mem_frac(char *str)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
