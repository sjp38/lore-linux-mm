From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073308.10631.24247.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 07/07] i386: numa emulation on pc
Date: Fri, 30 Sep 2005 16:33:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Isaku Yamahata <yamahata@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds NUMA emulation for i386 on top of the fixes for sparsemem and
discontigmem. NUMA emulation already exists for x86_64, and this patch adds
the same feature using the same config option CONFIG_NUMA_EMU. The kernel
command line option used is also the same as for x86_64.

Pass "numa=fake=N" to the kernel where N is the number of nodes to emulate.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 arch/i386/Kconfig           |   20 +++++++-
 arch/i386/kernel/setup.c    |   34 +++++++++-----
 arch/i386/mm/numa.c         |  100 ++++++++++++++++++++++++++++++++++++++++++++ include/asm-i386/mmzone.h   |    7 +++
 include/asm-i386/numnodes.h |    2
 5 files changed, 145 insertions(+), 18 deletions(-)

--- from-0009/arch/i386/Kconfig
+++ to-work/arch/i386/Kconfig	2005-09-30 13:31:13.000000000 +0900
@@ -134,7 +134,7 @@ endchoice
 config ACPI_SRAT
 	bool
 	default y
-	depends on NUMA && (X86_SUMMIT || X86_GENERICARCH)
+	depends on NUMA && (X86_SUMMIT || X86_GENERICARCH || NUMA_EMU)
 
 config X86_SUMMIT_NUMA
 	bool
@@ -756,12 +756,21 @@ config X86_PAE
 	depends on HIGHMEM64G
 	default y
 
+config NUMA_EMU
+	bool "Numa Memory Nodes Emulation"
+	depends on X86_PC
+	default n
+	help
+	  Enable NUMA emulation. A regular single-node PC machine will be
+	  split into virtual nodes when booted with "numa=fake=N", where
+	  N is the number of nodes.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
-	depends on SMP && HIGHMEM64G && (X86_NUMAQ || X86_GENERICARCH || (X86_SUMMIT && ACPI))
+	depends on (NUMA_EMU && ACPI && HIGHMEM) || (SMP && HIGHMEM64G && (X86_NUMAQ || X86_GENERICARCH || (X86_SUMMIT && ACPI)))
 	default n if X86_PC
-	default y if (X86_NUMAQ || X86_SUMMIT)
+	default y if (X86_NUMAQ || X86_SUMMIT || NUMA_EMU)
 
 # Need comments to help the hapless user trying to turn on NUMA support
 comment "NUMA (NUMA-Q) requires SMP, 64GB highmem support"
@@ -770,6 +779,9 @@ comment "NUMA (NUMA-Q) requires SMP, 64G
 comment "NUMA (Summit) requires SMP, 64GB highmem support, ACPI"
 	depends on X86_SUMMIT && (!HIGHMEM64G || !ACPI)
 
+comment "NUMA (Emulation on PC) requires highmem support and ACPI"
+	depends on X86_PC && (!HIGHMEM || !ACPI)
+
 config HAVE_ARCH_BOOTMEM_NODE
 	bool
 	depends on NUMA
@@ -916,7 +928,7 @@ config IRQBALANCE
 # Summit needs it only when NUMA is on
 config BOOT_IOREMAP
 	bool
-	depends on (((X86_SUMMIT || X86_GENERICARCH) && NUMA) || (X86 && EFI))
+	depends on (((X86_SUMMIT || X86_GENERICARCH || NUMA_EMU) && NUMA) || (X86 && EFI))
 	default y
 
 config REGPARM
--- from-0008/arch/i386/kernel/setup.c
+++ to-work/arch/i386/kernel/setup.c	2005-09-28 17:49:53.000000000 +0900
@@ -931,6 +931,13 @@ static void __init parse_cmdline_early (
 			elfcorehdr_addr = memparse(from+11, &from);
 #endif
 
+#ifdef CONFIG_NUMA_EMU
+		// virtual numa setup
+		else if (!memcmp(from, "numa=", 5)) {
+			extern void numa_setup(char*, char**);
+			numa_setup(from+5, &from);
+		}
+#endif
 		/*
 		 * highmem=size forces highmem to be exactly 'size' bytes.
 		 * This works even on boxes that have no highmem otherwise.
@@ -1211,26 +1218,22 @@ static inline unsigned long  nid_size_pa
 {
 	return node_end_pfn[nid] - node_start_pfn[nid];
 }
-static inline int nid_starts_in_highmem(int nid)
-{
-	return node_start_pfn[nid] >= max_low_pfn;
-}
-
 void __init nid_zone_sizes_init(int nid)
 {
 	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
-	unsigned long max_dma;
+	unsigned long max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
 	unsigned long start = node_start_pfn[nid];
 	unsigned long end = node_end_pfn[nid];
 
 	if (node_has_online_mem(nid)){
-		if (nid_starts_in_highmem(nid)) {
-			zones_size[ZONE_HIGHMEM] = nid_size_pages(nid);
-		} else {
-			max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
-			zones_size[ZONE_DMA] = max_dma;
-			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
-			zones_size[ZONE_HIGHMEM] = end - max_low_pfn;
+		if (start < max_dma) {
+			zones_size[ZONE_DMA] = min(end, max_dma) - start;
+		}
+		if (start < max_low_pfn && max_dma < end) {
+			zones_size[ZONE_NORMAL] = min(end, max_low_pfn) - max(start, max_dma);
+		}
+		if (max_low_pfn <= end) {
+			zones_size[ZONE_HIGHMEM] = end - max(start, max_low_pfn);
 		}
 	}
 
@@ -1270,7 +1273,12 @@ void __init setup_bootmem_allocator(void
 	/*
 	 * Initialize the boot-time allocator (with low memory only):
 	 */
+#ifdef CONFIG_NUMA_EMU
+	bootmap_size = init_bootmem(max(min_low_pfn, node_start_pfn[0]),
+				    min(max_low_pfn, node_end_pfn[0]));
+#else
 	bootmap_size = init_bootmem(min_low_pfn, max_low_pfn);
+#endif
 
 	register_bootmem_low_pages(max_low_pfn);
 
--- from-0006/arch/i386/mm/numa.c
+++ to-work/arch/i386/mm/numa.c	2005-09-28 17:49:53.000000000 +0900
@@ -165,3 +165,103 @@ int early_pfn_to_nid(unsigned long pfn)
 
 	return 0;
 }
+
+#ifdef CONFIG_NUMA_EMU
+int numa_fake __initdata = 0;
+
+extern unsigned long node_start_pfn[MAX_NUMNODES] __read_mostly;
+extern unsigned long node_end_pfn[MAX_NUMNODES] __read_mostly;
+
+int
+get_memcfg_numa_emu(void)
+{
+	unsigned long node_size;
+	unsigned long shift;
+	int i;
+	
+	if (numa_fake == 0)
+		return 0;
+	node_size = max_pfn / numa_fake;
+	if (node_size == 0)
+		return 0;
+	
+	printk("NUMA - single node, flat memory mode, broken into %d nodes\n",
+	       numa_fake);
+	shift = 1;
+	while ((1 << shift) < node_size) {
+		shift++;
+	}
+	node_size = 1 << shift;
+	if (node_size * PAGE_SIZE < (1UL << SECTION_SIZE_BITS)) {
+		printk("node_size %ld is too small.(it must be >= %ld)\n",
+		       node_size * PAGE_SIZE, (1UL << SECTION_SIZE_BITS));
+		printk("consider descreas # of nodes "
+		       "(or decreas SECTIONS_SIZE_BITS %d)\n",
+		       SECTION_SIZE_BITS);
+		printk("kernel will panic!\n");
+		// Don't panic here.
+		// Here even early printk is not enabled so that
+		// this message won't be showed if we panic right here.
+		// Let the kernel go, print this message and then panic.
+	}
+	printk("block size %ld shift %ld\n", node_size, shift);
+
+        nodes_clear(node_online_map);
+	for (i = 0; i < numa_fake; i++) {
+		unsigned long size;
+		unsigned long pfn;
+		node_start_pfn[i] = node_size * i;
+		node_end_pfn[i] = min(node_start_pfn[i] + node_size, max_pfn);
+
+		node_remap_size[i] = node_memmap_size_bytes(i,
+							    node_start_pfn[i],
+							    node_end_pfn[i]);
+
+		//XXX see calculate_numa_remap_pages()
+		size = node_remap_size[i] + sizeof(pg_data_t);
+		size = (size + PMD_SIZE - 1) / PMD_SIZE;
+		size = size * PTRS_PER_PTE;
+		for (pfn = node_end_pfn[i] - size;
+		     pfn < node_end_pfn[i]; pfn++)
+			if (!page_is_ram(pfn))
+				break;
+		if (pfn != node_end_pfn[i])
+			size = 0;
+		if (node_end_pfn[i] & (PTRS_PER_PTE - 1)) {
+			size += node_end_pfn[i] & (PTRS_PER_PTE - 1);
+		}
+		
+		if (node_start_pfn[i] + size >= node_end_pfn[i]) {
+			printk("last memory segment %d has too few pages "
+			       "%ld = %ld - %ld\n",
+			       i, 
+			       node_end_pfn[i] - node_start_pfn[i],
+			       node_start_pfn[i],
+			       node_end_pfn[i]);
+			node_start_pfn[i] = 0;
+			node_end_pfn[i] = 0;
+			node_remap_size[i] = 0;
+			break;
+		} else {
+			node_set_online(i);
+			memory_present(i, node_start_pfn[i], node_end_pfn[i]);
+		}
+	}
+	printk("total %d blocks, max %ld\n", i, max_pfn);
+	return 1;
+}
+#endif
+
+void __init
+numa_setup(char* opt, char** retptr)
+{
+#ifdef CONFIG_NUMA_EMU
+	if (!memcmp(opt, "fake=", 5) && (*(opt + 5))) {
+		numa_fake = simple_strtoul(opt + 5, retptr, 0);
+		numa_fake = min(numa_fake, MAX_NUMNODES);
+		printk("fake numa nodes = %d/%d\n", numa_fake, MAX_NUMNODES);
+	} else {
+		*retptr = opt;
+	}
+#endif
+}
--- from-0009/include/asm-i386/mmzone.h
+++ to-work/include/asm-i386/mmzone.h	2005-09-30 13:53:35.000000000 +0900
@@ -18,6 +18,9 @@ extern struct pglist_data *node_data[];
 	#include <asm/srat.h>
 #endif
 
+#ifdef CONFIG_NUMA_EMU
+extern int get_memcfg_numa_emu(void);
+#endif
 extern int get_memcfg_numa_flat(void );
 /*
  * This allows any one NUMA architecture to be compiled
@@ -33,6 +36,10 @@ static inline void get_memcfg_numa(void)
 	if (get_memcfg_from_srat())
 		return;
 #endif
+#ifdef CONFIG_NUMA_EMU
+	if (get_memcfg_numa_emu())
+		return;
+#endif
 
 	get_memcfg_numa_flat();
 }
--- from-0001/include/asm-i386/numnodes.h
+++ to-work/include/asm-i386/numnodes.h	2005-09-28 17:49:53.000000000 +0900
@@ -8,7 +8,7 @@
 /* Max 16 Nodes */
 #define NODES_SHIFT	4
 
-#elif defined(CONFIG_ACPI_SRAT)
+#elif defined(CONFIG_ACPI_SRAT) || defined(CONFIG_NUMA_EMU)
 
 /* Max 8 Nodes */
 #define NODES_SHIFT	3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
