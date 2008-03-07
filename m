From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [8/13] Enable the mask allocator for x86
Message-Id: <20080307090718.A609E1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:18 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- Disable old ZONE_DMA
No fixed size ZONE_DMA now anymore. All existing users of __GFP_DMA rely 
on the compat call to the maskable allocator in alloc/free_pages
- Call maskable allocator initialization functions at boot
- Add TRAD_DMA_MASK for the compat functions 
- Remove dma_reserve call

Signed-off-by: Andi Kleen <ak@suse.de>

---
 arch/x86/Kconfig           |    4 ++--
 arch/x86/kernel/setup_32.c |    3 +--
 arch/x86/kernel/setup_64.c |    1 +
 arch/x86/mm/discontig_32.c |    2 --
 arch/x86/mm/init_32.c      |    2 ++
 arch/x86/mm/init_64.c      |    9 ++-------
 arch/x86/mm/numa_64.c      |    1 -
 include/asm-x86/dma.h      |    2 ++
 8 files changed, 10 insertions(+), 14 deletions(-)

Index: linux/arch/x86/kernel/setup_64.c
===================================================================
--- linux.orig/arch/x86/kernel/setup_64.c
+++ linux/arch/x86/kernel/setup_64.c
@@ -425,6 +425,7 @@ void __init setup_arch(char **cmdline_p)
 	}
 #endif
 	reserve_crashkernel();
+	init_mask_zone(__pa(MAX_DMA_ADDRESS));
 	paging_init();
 	map_vsyscall();
 
Index: linux/arch/x86/kernel/setup_32.c
===================================================================
--- linux.orig/arch/x86/kernel/setup_32.c
+++ linux/arch/x86/kernel/setup_32.c
@@ -438,8 +438,6 @@ void __init zone_sizes_init(void)
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-	max_zone_pfns[ZONE_DMA] =
-		virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 #ifdef CONFIG_HIGHMEM
 	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
@@ -811,6 +809,7 @@ void __init setup_arch(char **cmdline_p)
 	 * NOTE: at this point the bootmem allocator is fully available.
 	 */
 
+	init_mask_zone(__pa(MAX_DMA_ADDRESS));
 #ifdef CONFIG_BLK_DEV_INITRD
 	relocate_initrd();
 #endif
Index: linux/arch/x86/mm/init_64.c
===================================================================
--- linux.orig/arch/x86/mm/init_64.c
+++ linux/arch/x86/mm/init_64.c
@@ -50,8 +50,6 @@
 const struct dma_mapping_ops *dma_ops;
 EXPORT_SYMBOL(dma_ops);
 
-static unsigned long dma_reserve __initdata;
-
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 /*
@@ -451,7 +449,6 @@ void __init paging_init(void)
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-	max_zone_pfns[ZONE_DMA] = MAX_DMA_PFN;
 	max_zone_pfns[ZONE_DMA32] = MAX_DMA32_PFN;
 	max_zone_pfns[ZONE_NORMAL] = end_pfn;
 
@@ -514,6 +511,8 @@ void __init mem_init(void)
 
 	pci_iommu_alloc();
 
+	prepare_mask_zone();
+
 	/* clear_bss() already clear the empty_zero_page */
 
 	reservedpages = 0;
@@ -671,10 +670,6 @@ void __init reserve_bootmem_generic(unsi
 #else
 	reserve_bootmem(phys, len, BOOTMEM_DEFAULT);
 #endif
-	if (phys+len <= MAX_DMA_PFN*PAGE_SIZE) {
-		dma_reserve += len / PAGE_SIZE;
-		set_dma_reserve(dma_reserve);
-	}
 }
 
 int kern_addr_valid(unsigned long addr)
Index: linux/arch/x86/mm/numa_64.c
===================================================================
--- linux.orig/arch/x86/mm/numa_64.c
+++ linux/arch/x86/mm/numa_64.c
@@ -575,7 +575,6 @@ void __init paging_init(void)
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-	max_zone_pfns[ZONE_DMA] = MAX_DMA_PFN;
 	max_zone_pfns[ZONE_DMA32] = MAX_DMA32_PFN;
 	max_zone_pfns[ZONE_NORMAL] = end_pfn;
 
Index: linux/arch/x86/Kconfig
===================================================================
--- linux.orig/arch/x86/Kconfig
+++ linux/arch/x86/Kconfig
@@ -63,8 +63,8 @@ config FAST_CMPXCHG_LOCAL
 config MMU
 	def_bool y
 
-config ZONE_DMA
-	def_bool y
+config MASK_ALLOC
+       def_bool y
 
 config QUICKLIST
 	def_bool X86_32
Index: linux/arch/x86/mm/discontig_32.c
===================================================================
--- linux.orig/arch/x86/mm/discontig_32.c
+++ linux/arch/x86/mm/discontig_32.c
@@ -400,8 +400,6 @@ void __init zone_sizes_init(void)
 	int nid;
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
-	max_zone_pfns[ZONE_DMA] =
-		virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 #ifdef CONFIG_HIGHMEM
 	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
Index: linux/include/asm-x86/dma.h
===================================================================
--- linux.orig/include/asm-x86/dma.h
+++ linux/include/asm-x86/dma.h
@@ -316,4 +316,6 @@ extern int isa_dma_bridge_buggy;
 #define isa_dma_bridge_buggy	(0)
 #endif
 
+#define TRAD_DMA_MASK 0xffffff /* 16MB, 24bit */
+
 #endif /* _ASM_X86_DMA_H */
Index: linux/arch/x86/mm/init_32.c
===================================================================
--- linux.orig/arch/x86/mm/init_32.c
+++ linux/arch/x86/mm/init_32.c
@@ -571,6 +571,8 @@ void __init mem_init(void)
 	int codesize, reservedpages, datasize, initsize;
 	int tmp, bad_ppro;
 
+	prepare_mask_zone();
+
 #ifdef CONFIG_FLATMEM
 	BUG_ON(!mem_map);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
