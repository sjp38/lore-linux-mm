Subject: 170 nonlinear ppc64
In-Reply-To: <4173D219.3010706@shadowen.org>
Message-Id: <E1CJYcz-0000aa-TI@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 18 Oct 2004 15:36:49 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_NONLINEAR for ppc64.

Revision: $Rev$

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat 170-nonlinear-ppc64
---
 arch/ppc64/Kconfig         |   19 +++++++++++++++++--
 arch/ppc64/mm/Makefile     |    2 +-
 arch/ppc64/mm/init.c       |    8 ++++----
 arch/ppc64/mm/numa.c       |   13 +++++++++++++
 include/asm-ppc64/mmzone.h |   40 ++++++++++++++++++++++++++++++++++------
 include/asm-ppc64/page.h   |    4 +++-
 6 files changed, 72 insertions(+), 14 deletions(-)

diff -upN reference/arch/ppc64/Kconfig current/arch/ppc64/Kconfig
--- reference/arch/ppc64/Kconfig
+++ current/arch/ppc64/Kconfig
@@ -180,13 +180,28 @@ config HMT
 	bool "Hardware multithreading"
 	depends on SMP && PPC_PSERIES
 
+
+choice
+        prompt "Memory model"
+        default NONLINEAR if (PPC_PSERIES)
+        default FLATMEM
+
 config DISCONTIGMEM
-	bool "Discontiguous Memory Support"
+        bool "Discontigious Memory"
+	depends on SMP && PPC_PSERIES
+
+config NONLINEAR
+        bool "Nonlinear Memory"
 	depends on SMP && PPC_PSERIES
 
+config FLATMEM
+        bool "Flat Memory"
+
+endchoice
+
 config NUMA
 	bool "NUMA support"
-	depends on DISCONTIGMEM
+	#depends on DISCONTIGMEM
 
 config SCHED_SMT
 	bool "SMT (Hyperthreading) scheduler support"
diff -upN reference/arch/ppc64/mm/init.c current/arch/ppc64/mm/init.c
--- reference/arch/ppc64/mm/init.c
+++ current/arch/ppc64/mm/init.c
@@ -597,7 +597,7 @@ EXPORT_SYMBOL(page_is_ram);
  * Initialize the bootmem system and give it all the memory we
  * have available.
  */
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 void __init do_init_bootmem(void)
 {
 	unsigned long i;
@@ -695,7 +695,7 @@ module_init(setup_kcore);
 
 void __init mem_init(void)
 {
-#ifdef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NONLINEAR)
 	int nid;
 #endif
 	pg_data_t *pgdat;
@@ -706,7 +706,7 @@ void __init mem_init(void)
 	num_physpages = max_low_pfn;	/* RAM is assumed contiguous */
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
-#ifdef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NONLINEAR)
         for (nid = 0; nid < numnodes; nid++) {
 		if (NODE_DATA(nid)->node_spanned_pages != 0) {
 			printk("freeing bootmem node %x\n", nid);
@@ -721,7 +721,7 @@ void __init mem_init(void)
 
 	for_each_pgdat(pgdat) {
 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
-			page = pgdat->node_mem_map + i;
+			page = pfn_to_page(i);
 			if (PageReserved(page))
 				reservedpages++;
 		}
diff -upN reference/arch/ppc64/mm/Makefile current/arch/ppc64/mm/Makefile
--- reference/arch/ppc64/mm/Makefile
+++ current/arch/ppc64/mm/Makefile
@@ -6,6 +6,6 @@ EXTRA_CFLAGS += -mno-minimal-toc
 
 obj-y := fault.o init.o imalloc.o hash_utils.o hash_low.o tlb.o \
 	slb_low.o slb.o stab.o mmap.o
-obj-$(CONFIG_DISCONTIGMEM) += numa.o
+obj-$(CONFIG_NUMA) += numa.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_PPC_MULTIPLATFORM) += hash_native.o
diff -upN reference/arch/ppc64/mm/numa.c current/arch/ppc64/mm/numa.c
--- reference/arch/ppc64/mm/numa.c
+++ current/arch/ppc64/mm/numa.c
@@ -304,9 +304,13 @@ new_range:
 				size / PAGE_SIZE;
 		}
 
+		/* XXX: think this is discontig ... */
 		for (i = start ; i < (start+size); i += MEMORY_INCREMENT)
 			numa_memory_lookup_table[i >> MEMORY_INCREMENT_SHIFT] =
 				numa_domain;
+#ifdef CONFIG_NONLINEAR
+		nonlinear_add(numa_domain, start, start + size);
+#endif
 
 		ranges--;
 		if (ranges)
@@ -346,10 +350,15 @@ static void __init setup_nonnuma(void)
 	init_node_data[0].node_start_pfn = 0;
 	init_node_data[0].node_spanned_pages = lmb_end_of_DRAM() / PAGE_SIZE;
 
+	/* APW: this is discontig? */
 	for (i = 0 ; i < top_of_ram; i += MEMORY_INCREMENT)
 		numa_memory_lookup_table[i >> MEMORY_INCREMENT_SHIFT] = 0;
 
 	node0_io_hole_size = top_of_ram - total_ram;
+
+#ifdef CONFIG_NONLINEAR
+		nonlinear_add(0, 0, init_node_data[0].node_spanned_pages);
+#endif
 }
 
 static void __init dump_numa_topology(void)
@@ -567,6 +576,10 @@ void __init paging_init(void)
 	memset(zones_size, 0, sizeof(zones_size));
 	memset(zholes_size, 0, sizeof(zholes_size));
 
+#ifdef CONFIG_NONLINEAR
+	nonlinear_allocate();
+#endif
+
 	for (nid = 0; nid < numnodes; nid++) {
 		unsigned long start_pfn;
 		unsigned long end_pfn;
diff -upN reference/include/asm-ppc64/mmzone.h current/include/asm-ppc64/mmzone.h
--- reference/include/asm-ppc64/mmzone.h
+++ current/include/asm-ppc64/mmzone.h
@@ -10,9 +10,13 @@
 #include <linux/config.h>
 #include <asm/smp.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#if defined(CONFIG_DISCONTIGMEM) || defined(CONFIG_NONLINEAR)
 
 extern struct pglist_data *node_data[];
+/*
+ * Return a pointer to the node data for node n.
+ */
+#define NODE_DATA(nid)		(node_data[nid])
 
 /*
  * Following are specific to this numa platform.
@@ -27,6 +31,10 @@ extern int nr_cpus_in_node[];
 #define MEMORY_INCREMENT_SHIFT 24
 #define MEMORY_INCREMENT (1UL << MEMORY_INCREMENT_SHIFT)
 
+#endif /* !CONFIG_DISCONTIGMEM || !CONFIG_NONLINEAR */
+
+#ifdef CONFIG_DISCONTIGMEM
+
 /* NUMA debugging, will not work on a DLPAR machine */
 #undef DEBUG_NUMA
 
@@ -49,11 +57,6 @@ static inline int pa_to_nid(unsigned lon
 
 #define pfn_to_nid(pfn)		pa_to_nid((pfn) << PAGE_SHIFT)
 
-/*
- * Return a pointer to the node data for node n.
- */
-#define NODE_DATA(nid)		(node_data[nid])
-
 #define node_localnr(pfn, nid)	((pfn) - NODE_DATA(nid)->node_start_pfn)
 
 /*
@@ -91,4 +94,29 @@ static inline int pa_to_nid(unsigned lon
 #define discontigmem_pfn_valid(pfn)		((pfn) < num_physpages)
 
 #endif /* CONFIG_DISCONTIGMEM */
+
+#ifdef CONFIG_NONLINEAR
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
+#define SECTION_SIZE_BITS       24
+#define MAX_PHYSADDR_BITS       38
+#define MAX_PHYSMEM_BITS        36
+
+#define pa_to_nid(pa)							\
+({									\
+	pfn_to_nid(pa >> PAGE_SHIFT);					\
+})
+
+#endif /* CONFIG_NONLINEAR */
+
 #endif /* _ASM_MMZONE_H_ */
diff -upN reference/include/asm-ppc64/page.h current/include/asm-ppc64/page.h
--- reference/include/asm-ppc64/page.h
+++ current/include/asm-ppc64/page.h
@@ -222,7 +222,9 @@ extern int page_is_ram(unsigned long pfn
 #define page_to_pfn(page)	discontigmem_page_to_pfn(page)
 #define pfn_to_page(pfn)	discontigmem_pfn_to_page(pfn)
 #define pfn_valid(pfn)		discontigmem_pfn_valid(pfn)
-#else
+#endif
+/* XXX/APW: why is NONLINEAR not here */
+#ifdef CONFIG_FLATMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
