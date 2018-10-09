Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C00A6B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:25:28 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v7-v6so954310plo.23
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:25:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g5-v6si20814694pgf.565.2018.10.09.06.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:25:26 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/33] powerpc: use mm zones more sensibly
Date: Tue,  9 Oct 2018 15:24:28 +0200
Message-Id: <20181009132500.17643-2-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Powerpc has somewhat odd usage where ZONE_DMA is used for all memory on
common 64-bit configfs, and ZONE_DMA32 is used for 31-bit schemes.

Move to a scheme closer to what other architectures use (and I dare to
say the intent of the system):

 - ZONE_DMA: optionally for memory < 31-bit
 - ZONE_NORMAL: everything addressable by the kernel
 - ZONE_HIGHMEM: memory > 32-bit for 32-bit kernels

Also provide information on how ZONE_DMA is used by defining
ARCH_ZONE_DMA_BITS.

Contains various fixes from Benjamin Herrenschmidt.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig                          |  6 +--
 arch/powerpc/include/asm/page.h               |  2 +
 arch/powerpc/include/asm/pgtable.h            |  1 -
 arch/powerpc/kernel/dma-swiotlb.c             |  6 +--
 arch/powerpc/kernel/dma.c                     |  7 +--
 arch/powerpc/mm/mem.c                         | 50 +++++++------------
 arch/powerpc/platforms/85xx/corenet_generic.c | 10 ----
 arch/powerpc/platforms/85xx/qemu_e500.c       |  9 ----
 include/linux/mmzone.h                        |  2 +-
 9 files changed, 24 insertions(+), 69 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index a80669209155..06996df07cad 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -380,7 +380,7 @@ config PPC_ADV_DEBUG_DAC_RANGE
 	depends on PPC_ADV_DEBUG_REGS && 44x
 	default y
 
-config ZONE_DMA32
+config ZONE_DMA
 	bool
 	default y if PPC64
 
@@ -879,10 +879,6 @@ config ISA
 	  have an IBM RS/6000 or pSeries machine, say Y.  If you have an
 	  embedded board, consult your board documentation.
 
-config ZONE_DMA
-	bool
-	default y
-
 config GENERIC_ISA_DMA
 	bool
 	depends on ISA_DMA_API
diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index f6a1265face2..fc8c9ac0c6be 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -354,4 +354,6 @@ typedef struct page *pgtable_t;
 #endif /* __ASSEMBLY__ */
 #include <asm/slice.h>
 
+#define ARCH_ZONE_DMA_BITS 31
+
 #endif /* _ASM_POWERPC_PAGE_H */
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 14c79a7dc855..9bafb38e959e 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -37,7 +37,6 @@ extern unsigned long empty_zero_page[];
 
 extern pgd_t swapper_pg_dir[];
 
-void limit_zone_pfn(enum zone_type zone, unsigned long max_pfn);
 int dma_pfn_limit_to_zone(u64 pfn_limit);
 extern void paging_init(void);
 
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 88f3963ca30f..93a4622563c6 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -108,12 +108,8 @@ int __init swiotlb_setup_bus_notifier(void)
 
 void __init swiotlb_detect_4g(void)
 {
-	if ((memblock_end_of_DRAM() - 1) > 0xffffffff) {
+	if ((memblock_end_of_DRAM() - 1) > 0xffffffff)
 		ppc_swiotlb_enable = 1;
-#ifdef CONFIG_ZONE_DMA32
-		limit_zone_pfn(ZONE_DMA32, (1ULL << 32) >> PAGE_SHIFT);
-#endif
-	}
 }
 
 static int __init check_swiotlb_enabled(void)
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index dbfc7056d7df..6551685a4ed0 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -50,7 +50,7 @@ static int dma_nommu_dma_supported(struct device *dev, u64 mask)
 		return 1;
 
 #ifdef CONFIG_FSL_SOC
-	/* Freescale gets another chance via ZONE_DMA/ZONE_DMA32, however
+	/* Freescale gets another chance via ZONE_DMA, however
 	 * that will have to be refined if/when they support iommus
 	 */
 	return 1;
@@ -94,13 +94,10 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 	}
 
 	switch (zone) {
+#ifdef CONFIG_ZONE_DMA
 	case ZONE_DMA:
 		flag |= GFP_DMA;
 		break;
-#ifdef CONFIG_ZONE_DMA32
-	case ZONE_DMA32:
-		flag |= GFP_DMA32;
-		break;
 #endif
 	};
 #endif /* CONFIG_FSL_SOC */
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5c8530d0c611..8bff7e893bde 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -69,15 +69,12 @@ pte_t *kmap_pte;
 EXPORT_SYMBOL(kmap_pte);
 pgprot_t kmap_prot;
 EXPORT_SYMBOL(kmap_prot);
-#define TOP_ZONE ZONE_HIGHMEM
 
 static inline pte_t *virt_to_kpte(unsigned long vaddr)
 {
 	return pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr),
 			vaddr), vaddr), vaddr);
 }
-#else
-#define TOP_ZONE ZONE_NORMAL
 #endif
 
 int page_is_ram(unsigned long pfn)
@@ -246,35 +243,19 @@ static int __init mark_nonram_nosave(void)
 }
 #endif
 
-static bool zone_limits_final;
-
-/*
- * The memory zones past TOP_ZONE are managed by generic mm code.
- * These should be set to zero since that's what every other
- * architecture does.
- */
-static unsigned long max_zone_pfns[MAX_NR_ZONES] = {
-	[0            ... TOP_ZONE        ] = ~0UL,
-	[TOP_ZONE + 1 ... MAX_NR_ZONES - 1] = 0
-};
-
 /*
- * Restrict the specified zone and all more restrictive zones
- * to be below the specified pfn.  May not be called after
- * paging_init().
+ * Zones usage:
+ *
+ * We setup ZONE_DMA to be 31-bits on all platforms and ZONE_NORMAL to be
+ * everything else. GFP_DMA32 page allocations automatically fall back to
+ * ZONE_DMA.
+ *
+ * By using 31-bit unconditionally, we can exploit ARCH_ZONE_DMA_BITS to
+ * inform the generic DMA mapping code.  32-bit only devices (if not handled
+ * by an IOMMU anyway) will take a first dip into ZONE_NORMAL and get
+ * otherwise served by ZONE_DMA.
  */
-void __init limit_zone_pfn(enum zone_type zone, unsigned long pfn_limit)
-{
-	int i;
-
-	if (WARN_ON(zone_limits_final))
-		return;
-
-	for (i = zone; i >= 0; i--) {
-		if (max_zone_pfns[i] > pfn_limit)
-			max_zone_pfns[i] = pfn_limit;
-	}
-}
+static unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 /*
  * Find the least restrictive zone that is entirely below the
@@ -324,11 +305,14 @@ void __init paging_init(void)
 	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
 	       (long int)((top_of_ram - total_ram) >> 20));
 
+#ifdef CONFIG_ZONE_DMA
+	max_zone_pfns[ZONE_DMA]	= min(max_low_pfn, 0x7fffffffUL >> PAGE_SHIFT);
+#endif
+	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 #ifdef CONFIG_HIGHMEM
-	limit_zone_pfn(ZONE_NORMAL, lowmem_end_addr >> PAGE_SHIFT);
+	max_zone_pfns[ZONE_HIGHMEM] = max_pfn
 #endif
-	limit_zone_pfn(TOP_ZONE, top_of_ram >> PAGE_SHIFT);
-	zone_limits_final = true;
+
 	free_area_init_nodes(max_zone_pfns);
 
 	mark_nonram_nosave();
diff --git a/arch/powerpc/platforms/85xx/corenet_generic.c b/arch/powerpc/platforms/85xx/corenet_generic.c
index ac191a7a1337..b0dac307bebf 100644
--- a/arch/powerpc/platforms/85xx/corenet_generic.c
+++ b/arch/powerpc/platforms/85xx/corenet_generic.c
@@ -68,16 +68,6 @@ void __init corenet_gen_setup_arch(void)
 
 	swiotlb_detect_4g();
 
-#if defined(CONFIG_FSL_PCI) && defined(CONFIG_ZONE_DMA32)
-	/*
-	 * Inbound windows don't cover the full lower 4 GiB
-	 * due to conflicts with PCICSRBAR and outbound windows,
-	 * so limit the DMA32 zone to 2 GiB, to allow consistent
-	 * allocations to succeed.
-	 */
-	limit_zone_pfn(ZONE_DMA32, 1UL << (31 - PAGE_SHIFT));
-#endif
-
 	pr_info("%s board\n", ppc_md.name);
 
 	mpc85xx_qe_init();
diff --git a/arch/powerpc/platforms/85xx/qemu_e500.c b/arch/powerpc/platforms/85xx/qemu_e500.c
index b63a8548366f..27631c607f3d 100644
--- a/arch/powerpc/platforms/85xx/qemu_e500.c
+++ b/arch/powerpc/platforms/85xx/qemu_e500.c
@@ -45,15 +45,6 @@ static void __init qemu_e500_setup_arch(void)
 
 	fsl_pci_assign_primary();
 	swiotlb_detect_4g();
-#if defined(CONFIG_FSL_PCI) && defined(CONFIG_ZONE_DMA32)
-	/*
-	 * Inbound windows don't cover the full lower 4 GiB
-	 * due to conflicts with PCICSRBAR and outbound windows,
-	 * so limit the DMA32 zone to 2 GiB, to allow consistent
-	 * allocations to succeed.
-	 */
-	limit_zone_pfn(ZONE_DMA32, 1UL << (31 - PAGE_SHIFT));
-#endif
 	mpc85xx_smp_init();
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1e22d96734e0..68970340df1c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -312,7 +312,7 @@ enum zone_type {
 	 * Architecture		Limit
 	 * ---------------------------
 	 * parisc, ia64, sparc	<4G
-	 * s390			<2G
+	 * s390, powerpc	<2G
 	 * arm			Various
 	 * alpha		Unlimited or 0-16MB.
 	 *
-- 
2.19.0
