Subject: 160 nonlinear i386
In-Reply-To: <4173D219.3010706@shadowen.org>
Message-Id: <E1CJYcZ-0000aS-5g@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 18 Oct 2004 15:36:23 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_NONLINEAR for i386

Revision: $Rev$

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat 160-nonlinear-i386
---
 arch/i386/Kconfig          |   22 ++++++---
 arch/i386/kernel/numaq.c   |    5 ++
 arch/i386/kernel/setup.c   |    7 ++
 arch/i386/kernel/srat.c    |    5 ++
 arch/i386/mm/Makefile      |    2 
 arch/i386/mm/discontig.c   |   97 +++++++++++++++++++++++----------------
 arch/i386/mm/init.c        |   19 ++++---
 include/asm-i386/mmzone.h  |  110 ++++++++++++++++++++++++++++++++++-----------
 include/asm-i386/page.h    |    4 -
 include/asm-i386/pgtable.h |    4 -
 10 files changed, 189 insertions(+), 86 deletions(-)

diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/Kconfig current/arch/i386/Kconfig
--- reference/arch/i386/Kconfig
+++ current/arch/i386/Kconfig
@@ -68,7 +68,7 @@ config X86_VOYAGER
 
 config X86_NUMAQ
 	bool "NUMAQ (IBM/Sequent)"
-	select DISCONTIGMEM
+	#select DISCONTIGMEM
 	select NUMA
 	help
 	  This option is used for getting Linux to run on a (IBM/Sequent) NUMA
@@ -738,16 +738,28 @@ comment "NUMA (NUMA-Q) requires SMP, 64G
 comment "NUMA (Summit) requires SMP, 64GB highmem support, ACPI"
 	depends on X86_SUMMIT && (!HIGHMEM64G || !ACPI)
 
-config DISCONTIGMEM
-	bool
-	depends on NUMA
-	default y
 
 config HAVE_ARCH_BOOTMEM_NODE
 	bool
 	depends on NUMA
 	default y
 
+choice
+	prompt "Memory model"
+	default NONLINEAR if (X86_NUMAQ || X86_SUMMIT)
+	default FLATMEM
+
+config DISCONTIGMEM
+	bool "Discontigious Memory"
+
+config NONLINEAR
+	bool "Nonlinear Memory"
+
+config FLATMEM
+	bool "Flat Memory"
+
+endchoice
+
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
 	depends on HIGHMEM4G || HIGHMEM64G
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/kernel/numaq.c current/arch/i386/kernel/numaq.c
--- reference/arch/i386/kernel/numaq.c
+++ current/arch/i386/kernel/numaq.c
@@ -60,6 +60,11 @@ static void __init smp_dump_qct(void)
 				eq->hi_shrd_mem_start - eq->priv_mem_size);
 			node_end_pfn[node] = MB_TO_PAGES(
 				eq->hi_shrd_mem_start + eq->hi_shrd_mem_size);
+#ifdef CONFIG_NONLINEAR
+			nonlinear_add(node, node_start_pfn[node],
+				node_end_pfn[node]);
+#endif
+
 		}
 	}
 }
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/kernel/setup.c current/arch/i386/kernel/setup.c
--- reference/arch/i386/kernel/setup.c
+++ current/arch/i386/kernel/setup.c
@@ -39,6 +39,7 @@
 #include <linux/efi.h>
 #include <linux/init.h>
 #include <linux/edd.h>
+#include <linux/mmzone.h>
 #include <video/edid.h>
 #include <asm/e820.h>
 #include <asm/mpspec.h>
@@ -1014,7 +1015,7 @@ static void __init reserve_ebda_region(v
 		reserve_bootmem(addr, PAGE_SIZE);	
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 void __init setup_bootmem_allocator(void);
 static unsigned long __init setup_memory(void)
 {
@@ -1042,7 +1043,9 @@ static unsigned long __init setup_memory
 	setup_bootmem_allocator();
 	return max_low_pfn;
 }
-#endif /* !CONFIG_DISCONTIGMEM */
+#else
+unsigned long __init setup_memory(void);
+#endif /* CONFIG_FLATMEM */
 
 void __init setup_bootmem_allocator(void)
 {
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/kernel/srat.c current/arch/i386/kernel/srat.c
--- reference/arch/i386/kernel/srat.c
+++ current/arch/i386/kernel/srat.c
@@ -261,6 +261,11 @@ static int __init acpi20_parse_srat(stru
 		       j, node_memory_chunk[j].nid,
 		       node_memory_chunk[j].start_pfn,
 		       node_memory_chunk[j].end_pfn);
+#ifdef CONFIG_NONLINEAR
+		 nonlinear_add(node_memory_chunk[j].nid,
+				 node_memory_chunk[j].start_pfn,
+				 node_memory_chunk[j].end_pfn);
+#endif /* CONFIG_NONLINEAR */
 	}
  
 	/*calculate node_start_pfn/node_end_pfn arrays*/
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/mm/discontig.c current/arch/i386/mm/discontig.c
--- reference/arch/i386/mm/discontig.c
+++ current/arch/i386/mm/discontig.c
@@ -33,20 +33,19 @@
 #include <asm/mmzone.h>
 #include <bios_ebda.h>
 
-struct pglist_data *node_data[MAX_NUMNODES];
-bootmem_data_t node0_bdata;
-
 /*
  * numa interface - we expect the numa architecture specfic code to have
  *                  populated the following initialisation.
  *
  * 1) numnodes         - the total number of nodes configured in the system
- * 2) physnode_map     - the mapping between a pfn and owning node
- * 3) node_start_pfn   - the starting page frame number for a node
+ * 2) node_start_pfn   - the starting page frame number for a node
  * 3) node_end_pfn     - the ending page fram number for a node
  */
 
+#ifdef CONFIG_DISCONTIGMEM
 /*
+ * 4) physnode_map     - the mapping between a pfn and owning node
+ *
  * physnode_map keeps track of the physical memory layout of a generic
  * numa node on a 256Mb break (each element of the array will
  * represent 256Mb of memory and will be marked by the node id.  so,
@@ -58,6 +57,10 @@ bootmem_data_t node0_bdata;
  *     physnode_map[8- ] = -1;
  */
 s8 physnode_map[MAX_ELEMENTS] = { [0 ... (MAX_ELEMENTS - 1)] = -1};
+#endif
+
+struct pglist_data *node_data[MAX_NUMNODES];
+bootmem_data_t node0_bdata;
 
 unsigned long node_start_pfn[MAX_NUMNODES];
 unsigned long node_end_pfn[MAX_NUMNODES];
@@ -186,9 +189,14 @@ static unsigned long calculate_numa_rema
 	unsigned long size, reserve_pages = 0;
 
 	for (nid = 0; nid < numnodes; nid++) {
+#ifdef CONFIG_DISCONTIGMEM
 		/* calculate the size of the mem_map needed in bytes */
 		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
 			* sizeof(struct page) + sizeof(pg_data_t);
+#endif
+#ifdef CONFIG_NONLINEAR
+		size = nonlinear_calculate(nid) + sizeof(pg_data_t);
+#endif
 
 		/* Allow for the bitmaps. */
 		size += zone_bitmap_calculate(node_end_pfn[nid] - node_start_pfn[nid] + 1);
@@ -217,7 +225,7 @@ unsigned long __init setup_memory(void)
 {
 	int nid;
 	unsigned long system_start_pfn, system_max_low_pfn;
-	unsigned long reserve_pages, pfn;
+	unsigned long reserve_pages;
 
 	/*
 	 * When mapping a NUMA machine we allocate the node_mem_map arrays
@@ -228,8 +236,11 @@ unsigned long __init setup_memory(void)
 	 */
 	get_memcfg_numa();
 
+#ifdef CONFIG_DISCONTIGMEM
 	/* Fill in the physnode_map */
 	for (nid = 0; nid < numnodes; nid++) {
+		unsigned long pfn;
+
 		printk("Node: %d, start_pfn: %ld, end_pfn: %ld\n",
 				nid, node_start_pfn[nid], node_end_pfn[nid]);
 		printk("  Setting physnode_map array to node %d for pfns:\n  ",
@@ -241,6 +252,7 @@ unsigned long __init setup_memory(void)
 		}
 		printk("\n");
 	}
+#endif
 
 	reserve_pages = calculate_numa_remap_pages();
 
@@ -340,13 +352,9 @@ void __init zone_sizes_init(void)
 			}
 		}
 		zholes_size = get_zholes_size(nid);
-		/*
-		 * We let the lmem_map for node 0 be allocated from the
-		 * normal bootmem allocator, but other nodes come from the
-		 * remapped KVA area - mbligh
-		 */
-			free_area_init_node(nid, NODE_DATA(nid),
-					zones_size, start, zholes_size);
+
+		free_area_init_node(nid, NODE_DATA(nid),
+				zones_size, start, zholes_size);
 
 #if 0
 		if (!nid)
@@ -369,39 +377,48 @@ void __init zone_sizes_init(void)
 void __init set_highmem_pages_init(int bad_ppro) 
 {
 #ifdef CONFIG_HIGHMEM
-	struct zone *zone;
-
-	for_each_zone(zone) {
-		unsigned long node_pfn, node_high_size, zone_start_pfn;
-		struct page * zone_mem_map;
-		
-		if (!is_highmem(zone))
-			continue;
-
-		printk("Initializing %s for node %d\n", zone->name,
-			zone->zone_pgdat->node_id);
-
-		node_high_size = zone->spanned_pages;
-		zone_mem_map = zone->zone_mem_map;
-		zone_start_pfn = zone->zone_start_pfn;
-
-		for (node_pfn = 0; node_pfn < node_high_size; node_pfn++) {
-			one_highpage_init((struct page *)(zone_mem_map + node_pfn),
-					  zone_start_pfn + node_pfn, bad_ppro);
-		}
-	}
-	totalram_pages += totalhigh_pages;
+  	struct zone *zone;
+	struct page *page;
+  
+  	for_each_zone(zone) {
+		unsigned long node_pfn, zone_start_pfn, zone_end_pfn;
+
+  		if (!is_highmem(zone))
+  			continue;
+  
+  		zone_start_pfn = zone->zone_start_pfn;
+		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
+
+		printk("Initializing %s for node %d (%08lx:%08lx)\n",
+				zone->name, zone->zone_pgdat->node_id,
+				zone_start_pfn, zone_end_pfn);
+  
+		/*
+		 * Makes use of the guarentee that *_mem_map will be
+		 * contigious in sections aligned at MAX_ORDER.
+		 */
+		page = pfn_to_page(zone_start_pfn);
+		/* APW/XXX: pfn_valid!!!! */
+		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++, page++) {
+			if ((node_pfn & ((1 << MAX_ORDER) - 1)) == 0) {
+				if (!pfn_valid(node_pfn)) {
+					node_pfn += (1 << MAX_ORDER) - 1;
+					continue;
+ 				}
+				page = pfn_to_page(node_pfn);
+			}
+			one_highpage_init(page, node_pfn, bad_ppro);
+  		}
+  	}
+  	totalram_pages += totalhigh_pages;
 #endif
 }
 
 void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-	struct zone *high0 = &NODE_DATA(0)->node_zones[ZONE_HIGHMEM];
-	if (high0->spanned_pages > 0)
-	      	highmem_start_page = high0->zone_mem_map;
-	else
-		highmem_start_page = pfn_to_page(max_low_pfn+1); 
+	highmem_start_page = pfn_to_page(highstart_pfn);
+	/* highmem_start_page = pfn_to_page(max_low_pfn+1); XXX/APW */
 	num_physpages = highend_pfn;
 #else
 	num_physpages = max_low_pfn;
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/mm/init.c current/arch/i386/mm/init.c
--- reference/arch/i386/mm/init.c
+++ current/arch/i386/mm/init.c
@@ -274,7 +274,7 @@ void __init one_highpage_init(struct pag
 		SetPageReserved(page);
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 void __init set_highmem_pages_init(int bad_ppro) 
 {
 	int pfn;
@@ -284,7 +284,7 @@ void __init set_highmem_pages_init(int b
 }
 #else
 extern void set_highmem_pages_init(int);
-#endif /* !CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 #else
 #define kmap_init() do { } while (0)
@@ -295,7 +295,7 @@ extern void set_highmem_pages_init(int);
 unsigned long long __PAGE_KERNEL = _PAGE_KERNEL;
 unsigned long long __PAGE_KERNEL_EXEC = _PAGE_KERNEL_EXEC;
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 #define remap_numa_kva() do {} while (0)
 #else
 extern void __init remap_numa_kva(void);
@@ -388,7 +388,7 @@ void zap_low_mappings (void)
 	flush_tlb_all();
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 void __init zone_sizes_init(void)
 {
 	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
@@ -411,7 +411,7 @@ void __init zone_sizes_init(void)
 }
 #else
 extern void zone_sizes_init(void);
-#endif /* !CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 static int disable_nx __initdata = 0;
 u64 __supported_pte_mask = ~_PAGE_NX;
@@ -516,6 +516,9 @@ void __init paging_init(void)
 	__flush_tlb_all();
 
 	kmap_init();
+#ifdef CONFIG_NONLINEAR
+	nonlinear_allocate();
+#endif
 	zone_sizes_init();
 }
 
@@ -545,7 +548,7 @@ void __init test_wp_bit(void)
 	}
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 static void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
@@ -559,7 +562,7 @@ static void __init set_max_mapnr_init(vo
 #else
 #define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
 extern void set_max_mapnr_init(void);
-#endif /* !CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 static struct kcore_list kcore_mem, kcore_vmalloc; 
 
@@ -570,7 +573,7 @@ void __init mem_init(void)
 	int tmp;
 	int bad_ppro;
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	if (!mem_map)
 		BUG();
 #endif
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/arch/i386/mm/Makefile current/arch/i386/mm/Makefile
--- reference/arch/i386/mm/Makefile
+++ current/arch/i386/mm/Makefile
@@ -4,7 +4,7 @@
 
 obj-y	:= init.o pgtable.o fault.o ioremap.o extable.o pageattr.o mmap.o
 
-obj-$(CONFIG_DISCONTIGMEM)	+= discontig.o
+obj-$(CONFIG_NUMA) += discontig.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_HIGHMEM) += highmem.o
 obj-$(CONFIG_BOOT_IOREMAP) += boot_ioremap.o
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/asm-i386/mmzone.h current/include/asm-i386/mmzone.h
--- reference/include/asm-i386/mmzone.h
+++ current/include/asm-i386/mmzone.h
@@ -8,6 +8,34 @@
 
 #include <asm/smp.h>
 
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NONLINEAR)
+extern struct pglist_data *node_data[];
+#define NODE_DATA(nid)          (node_data[nid])
+
+/*
+ * Following are macros that are specific to this numa platform.
+ */
+#define reserve_bootmem(addr, size) \
+	reserve_bootmem_node(NODE_DATA(0), (addr), (size))
+#define alloc_bootmem(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, 0)
+#define alloc_bootmem_pages(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+#define alloc_bootmem_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_pages_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+
+#define node_localnr(pfn, nid)		((pfn) - node_data[nid]->node_start_pfn)
+
+#endif /* !CONFIG_DISCONTIGMEM || !CONFIG_NONLINEAR */
+
 #ifdef CONFIG_DISCONTIGMEM
 
 #ifdef CONFIG_NUMA
@@ -23,9 +51,6 @@
 	#define get_zholes_size(n) (0)
 #endif /* CONFIG_NUMA */
 
-extern struct pglist_data *node_data[];
-#define NODE_DATA(nid)		(node_data[nid])
-
 /*
  * generic node memory support, the following assumptions apply:
  *
@@ -57,28 +82,6 @@ static inline struct pglist_data *pfn_to
 
 
 /*
- * Following are macros that are specific to this numa platform.
- */
-#define reserve_bootmem(addr, size) \
-	reserve_bootmem_node(NODE_DATA(0), (addr), (size))
-#define alloc_bootmem(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, 0)
-#define alloc_bootmem_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low_pages(x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
-#define alloc_bootmem_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
-#define alloc_bootmem_low_pages_node(ignore, x) \
-	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
-
-#define node_localnr(pfn, nid)		((pfn) - node_data[nid]->node_start_pfn)
-
-/*
  * Following are macros that each numa implmentation must define.
  */
 
@@ -91,7 +94,7 @@ static inline struct pglist_data *pfn_to
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid)						\
 ({									\
-	pg_data_t *__pgdat = NODE_DATA(nid);				\
+	struct pglist_data *__pgdat = NODE_DATA(nid);			\
 	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;		\
 })
 
@@ -153,4 +156,59 @@ static inline void get_memcfg_numa(void)
 }
 
 #endif /* CONFIG_DISCONTIGMEM */
+
+
+#ifdef CONFIG_NONLINEAR
+
+#ifdef CONFIG_NUMA
+	#ifdef CONFIG_X86_NUMAQ
+		#include <asm/numaq.h>
+	#else	/* summit or generic arch */
+		#include <asm/srat.h>
+	#endif
+#else /* !CONFIG_NUMA */
+	#define get_memcfg_numa get_memcfg_numa_flat
+	#define get_zholes_size(n) (0)
+#endif /* CONFIG_NUMA */
+
+
+/* generic non-linear memory support:
+ *
+ * 1) we will not split memory into more chunks than will fit into the
+ *    flags field of the struct page
+ */
+
+/*
+ * SECTION_SIZE_BITS            2^N: how big each section will be
+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
+ */
+#define SECTION_SIZE_BITS       30
+#define MAX_PHYSADDR_BITS       36
+#define MAX_PHYSMEM_BITS        36
+
+extern int get_memcfg_numa_flat(void );
+/*
+ * This allows any one NUMA architecture to be compiled
+ * for, and still fall back to the flat function if it
+ * fails.
+ */
+static inline void get_memcfg_numa(void)
+{
+#ifdef CONFIG_X86_NUMAQ
+	if (get_memcfg_numaq())
+		return;
+#elif CONFIG_ACPI_SRAT
+	if (get_memcfg_from_srat())
+		return;
+#endif
+
+	get_memcfg_numa_flat();
+}
+
+/* XXX: FIXME -- wli */
+#define kern_addr_valid(kaddr)  (0)
+
+#endif /* CONFIG_NONLINEAR */
+
 #endif /* _ASM_MMZONE_H_ */
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/asm-i386/page.h current/include/asm-i386/page.h
--- reference/include/asm-i386/page.h
+++ current/include/asm-i386/page.h
@@ -133,11 +133,11 @@ extern int sysctl_legacy_va_layout;
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
 #define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
-#endif /* !CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
diff -X /home/apw/brief/lib/vdiff.excl -rupN reference/include/asm-i386/pgtable.h current/include/asm-i386/pgtable.h
--- reference/include/asm-i386/pgtable.h
+++ current/include/asm-i386/pgtable.h
@@ -400,9 +400,9 @@ extern pte_t *lookup_address(unsigned lo
 
 #endif /* !__ASSEMBLY__ */
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 #define kern_addr_valid(addr)	(1)
-#endif /* !CONFIG_DISCONTIGMEM */
+#endif /* CONFIG_FLATMEM */
 
 #define io_remap_page_range remap_page_range
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
