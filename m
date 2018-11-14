Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFF16B029B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:53 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a24-v6so12594378pfn.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r199-v6si30882915pfr.105.2018.11.14.00.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:51 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 31/34] powerpc/dma: use generic direct and swiotlb ops
Date: Wed, 14 Nov 2018 09:23:11 +0100
Message-Id: <20181114082314.8965-32-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

 - The ppc32 case of dma_nommu_dma_supported already was a no-op, and the
   64-bit case came to the same conclusion as dma_direct_supported, so
   replace it with the generic version.

 - supports CMA

 - Note that the cache maintainance in the existing code is a bit odd
   as it implements both the sync_to_device and sync_to_cpu callouts,
   but never flushes caches when unmapping.  This patch keeps both
   directions arounds, which will lead to more flushing than the previous
   implementation.  Someone more familar with the required CPUs should
   eventually take a look and optimize the cache flush handling if needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig                   |   1 +
 arch/powerpc/include/asm/dma-mapping.h |  41 -----
 arch/powerpc/include/asm/pgtable.h     |   1 -
 arch/powerpc/include/asm/swiotlb.h     |   2 -
 arch/powerpc/kernel/Makefile           |   2 +-
 arch/powerpc/kernel/dma-iommu.c        |  13 +-
 arch/powerpc/kernel/dma-swiotlb.c      |  24 +--
 arch/powerpc/kernel/dma.c              | 202 -------------------------
 arch/powerpc/kernel/pci-common.c       |   2 +-
 arch/powerpc/kernel/setup-common.c     |   2 +-
 arch/powerpc/mm/dma-noncoherent.c      |  35 +++--
 arch/powerpc/mm/mem.c                  |  22 ---
 arch/powerpc/platforms/44x/warp.c      |   2 +-
 arch/powerpc/platforms/Kconfig.cputype |   2 +
 arch/powerpc/platforms/cell/iommu.c    |   4 +-
 arch/powerpc/platforms/pasemi/iommu.c  |   2 +-
 arch/powerpc/platforms/pasemi/setup.c  |   2 +-
 arch/powerpc/platforms/pseries/vio.c   |   7 +
 arch/powerpc/sysdev/fsl_pci.c          |   2 +-
 drivers/misc/cxl/vphb.c                |   2 +-
 20 files changed, 50 insertions(+), 320 deletions(-)
 delete mode 100644 arch/powerpc/kernel/dma.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 4f03997ad54a..e200cdf92290 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -155,6 +155,7 @@ config PPC
 	select CLONE_BACKWARDS
 	select DCACHE_WORD_ACCESS		if PPC64 && CPU_LITTLE_ENDIAN
 	select DYNAMIC_FTRACE			if FUNCTION_TRACER
+	select DMA_DIRECT_OPS
 	select EDAC_ATOMIC_SCRUB
 	select EDAC_SUPPORT
 	select GENERIC_ATOMIC64			if PPC32
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index f19c486e7b3f..93e57e28be28 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -18,46 +18,6 @@
 #include <asm/io.h>
 #include <asm/swiotlb.h>
 
-/* Some dma direct funcs must be visible for use in other dma_ops */
-extern void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-					 dma_addr_t *dma_handle, gfp_t flag,
-					 unsigned long attrs);
-extern void __dma_nommu_free_coherent(struct device *dev, size_t size,
-				       void *vaddr, dma_addr_t dma_handle,
-				       unsigned long attrs);
-int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
-		int nents, enum dma_data_direction direction,
-		unsigned long attrs);
-dma_addr_t dma_nommu_map_page(struct device *dev, struct page *page,
-		unsigned long offset, size_t size,
-		enum dma_data_direction dir, unsigned long attrs);
-int dma_nommu_dma_supported(struct device *dev, u64 mask);
-u64 dma_nommu_get_required_mask(struct device *dev);
-
-#ifdef CONFIG_NOT_COHERENT_CACHE
-/*
- * DMA-consistent mapping functions for PowerPCs that don't support
- * cache snooping.  These allocate/free a region of uncached mapped
- * memory space for use with DMA devices.  Alternatively, you could
- * allocate the space "normally" and use the cache management functions
- * to ensure it is consistent.
- */
-struct device;
-extern void __dma_sync(void *vaddr, size_t size, int direction);
-extern void __dma_sync_page(struct page *page, unsigned long offset,
-				 size_t size, int direction);
-extern unsigned long __dma_get_coherent_pfn(unsigned long cpu_addr);
-
-#else /* ! CONFIG_NOT_COHERENT_CACHE */
-/*
- * Cache coherent cores.
- */
-
-#define __dma_sync(addr, size, rw)		((void)0)
-#define __dma_sync_page(pg, off, sz, rw)	((void)0)
-
-#endif /* ! CONFIG_NOT_COHERENT_CACHE */
-
 static inline unsigned long device_to_mask(struct device *dev)
 {
 	if (dev->dma_mask && *dev->dma_mask)
@@ -72,7 +32,6 @@ static inline unsigned long device_to_mask(struct device *dev)
 #ifdef CONFIG_PPC64
 extern const struct dma_map_ops dma_iommu_ops;
 #endif
-extern const struct dma_map_ops dma_nommu_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 8af32ce93c7f..70979b860761 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -66,7 +66,6 @@ extern unsigned long empty_zero_page[];
 
 extern pgd_t swapper_pg_dir[];
 
-int dma_pfn_limit_to_zone(u64 pfn_limit);
 extern void paging_init(void);
 
 /*
diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
index 26a0f12b835b..b7ff218109b3 100644
--- a/arch/powerpc/include/asm/swiotlb.h
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -13,8 +13,6 @@
 
 #include <linux/swiotlb.h>
 
-extern const struct dma_map_ops powerpc_swiotlb_dma_ops;
-
 extern unsigned int ppc_swiotlb_enable;
 int __init swiotlb_setup_bus_notifier(void);
 
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 53d4b8d5b54d..d9e01cc3ae84 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -36,7 +36,7 @@ obj-y				:= cputable.o ptrace.o syscalls.o \
 				   process.o systbl.o idle.o \
 				   signal.o sysfs.o cacheinfo.o time.o \
 				   prom.o traps.o setup-common.o \
-				   udbg.o misc.o io.o dma.o misc_$(BITS).o \
+				   udbg.o misc.o io.o misc_$(BITS).o \
 				   of_platform.o prom_parse.o
 obj-$(CONFIG_PPC64)		+= setup_64.o sys_ppc32.o \
 				   signal_64.o ptrace32.o \
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index 5b15e53ee43d..0224925c5628 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -21,7 +21,7 @@
 static inline bool dma_iommu_alloc_bypass(struct device *dev)
 {
 	return dev->archdata.iommu_bypass && !iommu_fixed_is_weak &&
-		dma_nommu_dma_supported(dev, dev->coherent_dma_mask);
+		dma_direct_supported(dev, dev->coherent_dma_mask);
 }
 
 static inline bool dma_iommu_map_bypass(struct device *dev,
@@ -40,8 +40,7 @@ static void *dma_iommu_alloc_coherent(struct device *dev, size_t size,
 				      unsigned long attrs)
 {
 	if (dma_iommu_alloc_bypass(dev))
-		return __dma_nommu_alloc_coherent(dev, size, dma_handle, flag,
-				attrs);
+		return dma_direct_alloc(dev, size, dma_handle, flag, attrs);
 	return iommu_alloc_coherent(dev, get_iommu_table_base(dev), size,
 				    dma_handle, dev->coherent_dma_mask, flag,
 				    dev_to_node(dev));
@@ -52,7 +51,7 @@ static void dma_iommu_free_coherent(struct device *dev, size_t size,
 				    unsigned long attrs)
 {
 	if (dma_iommu_alloc_bypass(dev))
-		__dma_nommu_free_coherent(dev, size, vaddr, dma_handle, attrs);
+		dma_direct_free(dev, size, vaddr, dma_handle, attrs);
 	else
 		iommu_free_coherent(get_iommu_table_base(dev), size, vaddr,
 				dma_handle);
@@ -69,7 +68,7 @@ static dma_addr_t dma_iommu_map_page(struct device *dev, struct page *page,
 				     unsigned long attrs)
 {
 	if (dma_iommu_map_bypass(dev, attrs))
-		return dma_nommu_map_page(dev, page, offset, size, direction,
+		return dma_direct_map_page(dev, page, offset, size, direction,
 				attrs);
 	return iommu_map_page(dev, get_iommu_table_base(dev), page, offset,
 			      size, device_to_mask(dev), direction, attrs);
@@ -91,7 +90,7 @@ static int dma_iommu_map_sg(struct device *dev, struct scatterlist *sglist,
 			    unsigned long attrs)
 {
 	if (dma_iommu_map_bypass(dev, attrs))
-		return dma_nommu_map_sg(dev, sglist, nelems, direction, attrs);
+		return dma_direct_map_sg(dev, sglist, nelems, direction, attrs);
 	return ppc_iommu_map_sg(dev, get_iommu_table_base(dev), sglist, nelems,
 				device_to_mask(dev), direction, attrs);
 }
@@ -152,7 +151,7 @@ u64 dma_iommu_get_required_mask(struct device *dev)
 		return 0;
 
 	if (dev_is_pci(dev)) {
-		u64 bypass_mask = dma_nommu_get_required_mask(dev);
+		u64 bypass_mask = dma_direct_get_required_mask(dev);
 
 		if (dma_iommu_bypass_supported(dev, bypass_mask))
 			return bypass_mask;
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 03df252ff5fb..bded4127791a 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -32,28 +32,6 @@ EXPORT_SYMBOL(arch_dma_set_mask);
 
 unsigned int ppc_swiotlb_enable;
 
-/*
- * At the moment, all platforms that use this code only require
- * swiotlb to be used if we're operating on HIGHMEM.  Since
- * we don't ever call anything other than map_sg, unmap_sg,
- * map_page, and unmap_page on highmem, use normal dma_ops
- * for everything else.
- */
-const struct dma_map_ops powerpc_swiotlb_dma_ops = {
-	.alloc = __dma_nommu_alloc_coherent,
-	.free = __dma_nommu_free_coherent,
-	.map_sg = swiotlb_map_sg_attrs,
-	.unmap_sg = swiotlb_unmap_sg_attrs,
-	.dma_supported = swiotlb_dma_supported,
-	.map_page = swiotlb_map_page,
-	.unmap_page = swiotlb_unmap_page,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.mapping_error = dma_direct_mapping_error,
-};
-
 static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
 				  unsigned long action, void *data)
 {
@@ -65,7 +43,7 @@ static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
 
 	/* May need to bounce if the device can't address all of DRAM */
 	if ((dma_get_mask(dev) + 1) < memblock_end_of_DRAM())
-		set_dma_ops(dev, &powerpc_swiotlb_dma_ops);
+		set_dma_ops(dev, &swiotlb_dma_ops);
 
 	return NOTIFY_DONE;
 }
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
deleted file mode 100644
index a6590aa77181..000000000000
--- a/arch/powerpc/kernel/dma.c
+++ /dev/null
@@ -1,202 +0,0 @@
-/*
- * Copyright (C) 2006 Benjamin Herrenschmidt, IBM Corporation
- *
- * Provide default implementations of the DMA mapping callbacks for
- * directly mapped busses.
- */
-
-#include <linux/device.h>
-#include <linux/dma-direct.h>
-#include <linux/dma-debug.h>
-#include <linux/gfp.h>
-#include <linux/memblock.h>
-#include <linux/export.h>
-#include <linux/pci.h>
-#include <asm/vio.h>
-#include <asm/bug.h>
-#include <asm/machdep.h>
-#include <asm/swiotlb.h>
-#include <asm/iommu.h>
-
-/*
- * Generic direct DMA implementation
- *
- * This implementation supports a per-device offset that can be applied if
- * the address at which memory is visible to devices is not 0. Platform code
- * can set archdata.dma_data to an unsigned long holding the offset. By
- * default the offset is PCI_DRAM_OFFSET.
- */
-
-static u64 __maybe_unused get_pfn_limit(struct device *dev)
-{
-	u64 pfn = (dev->coherent_dma_mask >> PAGE_SHIFT) + 1;
-
-#ifdef CONFIG_SWIOTLB
-	if (dev->bus_dma_mask && dev->dma_ops == &powerpc_swiotlb_dma_ops)
-		pfn = min_t(u64, pfn, dev->bus_dma_mask >> PAGE_SHIFT);
-#endif
-
-	return pfn;
-}
-
-int dma_nommu_dma_supported(struct device *dev, u64 mask)
-{
-#ifdef CONFIG_PPC64
-	u64 limit = phys_to_dma(dev, (memblock_end_of_DRAM() - 1));
-
-	/* Limit fits in the mask, we are good */
-	if (mask >= limit)
-		return 1;
-
-#ifdef CONFIG_FSL_SOC
-	/* Freescale gets another chance via ZONE_DMA, however
-	 * that will have to be refined if/when they support iommus
-	 */
-	return 1;
-#endif
-	/* Sorry ... */
-	return 0;
-#else
-	return 1;
-#endif
-}
-
-#ifndef CONFIG_NOT_COHERENT_CACHE
-void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-				  dma_addr_t *dma_handle, gfp_t flag,
-				  unsigned long attrs)
-{
-	void *ret;
-	struct page *page;
-	int node = dev_to_node(dev);
-#ifdef CONFIG_FSL_SOC
-	u64 pfn = get_pfn_limit(dev);
-	int zone;
-
-	/*
-	 * This code should be OK on other platforms, but we have drivers that
-	 * don't set coherent_dma_mask. As a workaround we just ifdef it. This
-	 * whole routine needs some serious cleanup.
-	 */
-
-	zone = dma_pfn_limit_to_zone(pfn);
-	if (zone < 0) {
-		dev_err(dev, "%s: No suitable zone for pfn %#llx\n",
-			__func__, pfn);
-		return NULL;
-	}
-
-	switch (zone) {
-#ifdef CONFIG_ZONE_DMA
-	case ZONE_DMA:
-		flag |= GFP_DMA;
-		break;
-#endif
-	};
-#endif /* CONFIG_FSL_SOC */
-
-	page = alloc_pages_node(node, flag, get_order(size));
-	if (page == NULL)
-		return NULL;
-	ret = page_address(page);
-	memset(ret, 0, size);
-	*dma_handle = phys_to_dma(dev,__pa(ret));
-
-	return ret;
-}
-
-void __dma_nommu_free_coherent(struct device *dev, size_t size,
-				void *vaddr, dma_addr_t dma_handle,
-				unsigned long attrs)
-{
-	free_pages((unsigned long)vaddr, get_order(size));
-}
-#endif /* !CONFIG_NOT_COHERENT_CACHE */
-
-int dma_nommu_map_sg(struct device *dev, struct scatterlist *sgl,
-		int nents, enum dma_data_direction direction,
-		unsigned long attrs)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nents, i) {
-		sg->dma_address = phys_to_dma(dev, sg_phys(sg));
-		sg->dma_length = sg->length;
-
-		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
-			continue;
-
-		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
-	}
-
-	return nents;
-}
-
-u64 dma_nommu_get_required_mask(struct device *dev)
-{
-	u64 end, mask;
-
-	end = memblock_end_of_DRAM() + get_dma_offset(dev);
-
-	mask = 1ULL << (fls64(end) - 1);
-	mask += mask - 1;
-
-	return mask;
-}
-
-dma_addr_t dma_nommu_map_page(struct device *dev, struct page *page,
-		unsigned long offset, size_t size,
-		enum dma_data_direction dir, unsigned long attrs)
-{
-	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
-		__dma_sync_page(page, offset, size, dir);
-
-	return phys_to_dma(dev, page_to_phys(page)) + offset;
-}
-
-#ifdef CONFIG_NOT_COHERENT_CACHE
-static inline void dma_nommu_sync_sg(struct device *dev,
-		struct scatterlist *sgl, int nents,
-		enum dma_data_direction direction)
-{
-	struct scatterlist *sg;
-	int i;
-
-	for_each_sg(sgl, sg, nents, i)
-		__dma_sync_page(sg_page(sg), sg->offset, sg->length, direction);
-}
-
-static inline void dma_nommu_sync_single(struct device *dev,
-					  dma_addr_t dma_handle, size_t size,
-					  enum dma_data_direction direction)
-{
-	__dma_sync(bus_to_virt(dma_handle), size, direction);
-}
-#endif
-
-const struct dma_map_ops dma_nommu_ops = {
-	.alloc				= __dma_nommu_alloc_coherent,
-	.free				= __dma_nommu_free_coherent,
-	.map_sg				= dma_nommu_map_sg,
-	.dma_supported			= dma_nommu_dma_supported,
-	.map_page			= dma_nommu_map_page,
-#ifdef CONFIG_NOT_COHERENT_CACHE
-	.sync_single_for_cpu 		= dma_nommu_sync_single,
-	.sync_single_for_device 	= dma_nommu_sync_single,
-	.sync_sg_for_cpu 		= dma_nommu_sync_sg,
-	.sync_sg_for_device 		= dma_nommu_sync_sg,
-#endif
-};
-EXPORT_SYMBOL(dma_nommu_ops);
-
-static int __init dma_init(void)
-{
-#ifdef CONFIG_IBMVIO
-	dma_debug_add_bus(&vio_bus_type);
-#endif
-
-       return 0;
-}
-fs_initcall(dma_init);
-
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index a84707680525..661b937f31ed 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -62,7 +62,7 @@ resource_size_t isa_mem_base;
 EXPORT_SYMBOL(isa_mem_base);
 
 
-static const struct dma_map_ops *pci_dma_ops = &dma_nommu_ops;
+static const struct dma_map_ops *pci_dma_ops = &dma_direct_ops;
 
 void set_pci_dma_ops(const struct dma_map_ops *dma_ops)
 {
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 93ee3703b42f..104228c0e980 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -791,7 +791,7 @@ void arch_setup_pdev_archdata(struct platform_device *pdev)
 {
 	pdev->archdata.dma_mask = DMA_BIT_MASK(32);
 	pdev->dev.dma_mask = &pdev->archdata.dma_mask;
- 	set_dma_ops(&pdev->dev, &dma_nommu_ops);
+	set_dma_ops(&pdev->dev, &dma_direct_ops);
 }
 
 static __init void print_system_info(void)
diff --git a/arch/powerpc/mm/dma-noncoherent.c b/arch/powerpc/mm/dma-noncoherent.c
index ee95da19c82d..b5d2658c26af 100644
--- a/arch/powerpc/mm/dma-noncoherent.c
+++ b/arch/powerpc/mm/dma-noncoherent.c
@@ -152,8 +152,8 @@ static struct ppc_vm_region *ppc_vm_region_find(struct ppc_vm_region *head, unsi
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
  */
-void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
-		dma_addr_t *dma_handle, gfp_t gfp, unsigned long attrs)
+void *arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
+		gfp_t gfp, unsigned long attrs)
 {
 	struct page *page;
 	struct ppc_vm_region *c;
@@ -254,7 +254,7 @@ void *__dma_nommu_alloc_coherent(struct device *dev, size_t size,
 /*
  * free a page as defined by the above mapping.
  */
-void __dma_nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
+void arch_dma_free(struct device *dev, size_t size, void *vaddr,
 		dma_addr_t dma_handle, unsigned long attrs)
 {
 	struct ppc_vm_region *c;
@@ -314,7 +314,7 @@ void __dma_nommu_free_coherent(struct device *dev, size_t size, void *vaddr,
 /*
  * make an area consistent.
  */
-void __dma_sync(void *vaddr, size_t size, int direction)
+static void __dma_sync(void *vaddr, size_t size, int direction)
 {
 	unsigned long start = (unsigned long)vaddr;
 	unsigned long end   = start + size;
@@ -340,7 +340,6 @@ void __dma_sync(void *vaddr, size_t size, int direction)
 		break;
 	}
 }
-EXPORT_SYMBOL(__dma_sync);
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -387,21 +386,33 @@ static inline void __dma_sync_page_highmem(struct page *page,
  * __dma_sync_page makes memory consistent. identical to __dma_sync, but
  * takes a struct page instead of a virtual address
  */
-void __dma_sync_page(struct page *page, unsigned long offset,
-	size_t size, int direction)
+static void __dma_sync_page(phys_addr_t paddr, size_t size, int dir)
 {
+	struct page *page = pfn_to_page(paddr >> PAGE_SHIFT);
+	unsigned offset = paddr & ~PAGE_MASK;
+
 #ifdef CONFIG_HIGHMEM
-	__dma_sync_page_highmem(page, offset, size, direction);
+	__dma_sync_page_highmem(page, offset, size, dir);
 #else
 	unsigned long start = (unsigned long)page_address(page) + offset;
-	__dma_sync((void *)start, size, direction);
+	__dma_sync((void *)start, size, dir);
 #endif
 }
-EXPORT_SYMBOL(__dma_sync_page);
+
+void arch_sync_dma_for_device(struct device *dev, phys_addr_t paddr,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_sync_page(paddr, size, dir);
+}
+
+void arch_sync_dma_for_cpu(struct device *dev, phys_addr_t paddr,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_sync_page(paddr, size, dir);
+}
 
 /*
- * Return the PFN for a given cpu virtual address returned by
- * __dma_nommu_alloc_coherent.
+ * Return the PFN for a given cpu virtual address returned by arch_dma_alloc.
  */
 long arch_dma_coherent_to_pfn(struct device *dev, void *vaddr,
 		dma_addr_t dma_addr)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c0b676c3a5ba..9a00f470434c 100644
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
@@ -260,25 +257,6 @@ static int __init mark_nonram_nosave(void)
  */
 static unsigned long max_zone_pfns[MAX_NR_ZONES];
 
-/*
- * Find the least restrictive zone that is entirely below the
- * specified pfn limit.  Returns < 0 if no suitable zone is found.
- *
- * pfn_limit must be u64 because it can exceed 32 bits even on 32-bit
- * systems -- the DMA limit can be higher than any possible real pfn.
- */
-int dma_pfn_limit_to_zone(u64 pfn_limit)
-{
-	int i;
-
-	for (i = TOP_ZONE; i >= 0; i--) {
-		if (max_zone_pfns[i] <= pfn_limit)
-			return i;
-	}
-
-	return -EPERM;
-}
-
 /*
  * paging_init() sets up the page tables - in fact we've already done this.
  */
diff --git a/arch/powerpc/platforms/44x/warp.c b/arch/powerpc/platforms/44x/warp.c
index 7e4f8ca19ce8..c0e6fb270d59 100644
--- a/arch/powerpc/platforms/44x/warp.c
+++ b/arch/powerpc/platforms/44x/warp.c
@@ -47,7 +47,7 @@ static int __init warp_probe(void)
 	if (!of_machine_is_compatible("pika,warp"))
 		return 0;
 
-	/* For __dma_nommu_alloc_coherent */
+	/* For arch_dma_alloc */
 	ISA_DMA_THRESHOLD = ~0L;
 
 	return 1;
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 5fdfc1a6435c..d0ececddd62b 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -415,6 +415,8 @@ config NOT_COHERENT_CACHE
 	depends on 4xx || PPC_8xx || E200 || PPC_MPC512x || \
 		GAMECUBE_COMMON || AMIGAONE
 	select ARCH_HAS_DMA_COHERENT_TO_PFN
+	select ARCH_HAS_SYNC_DMA_FOR_DEVICE
+	select ARCH_HAS_SYNC_DMA_FOR_CPU
 	default n if PPC_47x
 	default y
 
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 93c7e4aef571..75fd2ee57e26 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -601,7 +601,7 @@ static int cell_of_bus_notify(struct notifier_block *nb, unsigned long action,
 	if (cell_iommu_enabled)
 		dev->dma_ops = &dma_iommu_ops;
 	else
-		dev->dma_ops = &dma_nommu_ops;
+		dev->dma_ops = &dma_direct_ops;
 	cell_dma_dev_setup(dev);
 	return 0;
 }
@@ -727,7 +727,7 @@ static int __init cell_iommu_init_disabled(void)
 	unsigned long base = 0, size;
 
 	/* When no iommu is present, we use direct DMA ops */
-	set_pci_dma_ops(&dma_nommu_ops);
+	set_pci_dma_ops(&dma_direct_ops);
 
 	/* First make sure all IOC translation is turned off */
 	cell_disable_iommus();
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index f2971522fb4a..4466ac61bce6 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -186,7 +186,7 @@ static void pci_dma_dev_setup_pasemi(struct pci_dev *dev)
 	 */
 	if (dev->vendor == 0x1959 && dev->device == 0xa007 &&
 	    !firmware_has_feature(FW_FEATURE_LPAR)) {
-		dev->dev.dma_ops = &dma_nommu_ops;
+		dev->dev.dma_ops = &dma_direct_ops;
 		/*
 		 * Set the coherent DMA mask to prevent the iommu
 		 * being used unnecessarily
diff --git a/arch/powerpc/platforms/pasemi/setup.c b/arch/powerpc/platforms/pasemi/setup.c
index 9a6eb04cca83..afb44e3dd8d2 100644
--- a/arch/powerpc/platforms/pasemi/setup.c
+++ b/arch/powerpc/platforms/pasemi/setup.c
@@ -362,7 +362,7 @@ static int pcmcia_notify(struct notifier_block *nb, unsigned long action,
 		return 0;
 
 	/* We use the direct ops for localbus */
-	dev->dma_ops = &dma_nommu_ops;
+	dev->dma_ops = &dma_direct_ops;
 
 	return 0;
 }
diff --git a/arch/powerpc/platforms/pseries/vio.c b/arch/powerpc/platforms/pseries/vio.c
index 63dbc4cfe60d..eabb5620d354 100644
--- a/arch/powerpc/platforms/pseries/vio.c
+++ b/arch/powerpc/platforms/pseries/vio.c
@@ -1703,3 +1703,10 @@ int vio_disable_interrupts(struct vio_dev *dev)
 }
 EXPORT_SYMBOL(vio_disable_interrupts);
 #endif /* CONFIG_PPC_PSERIES */
+
+static int __init vio_init(void)
+{
+	dma_debug_add_bus(&vio_bus_type);
+	return 0;
+}
+fs_initcall(vio_init);
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index cb91a3d113d1..081ed84c3f4c 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -126,7 +126,7 @@ static void setup_swiotlb_ops(struct pci_controller *hose)
 {
 	if (ppc_swiotlb_enable) {
 		hose->controller_ops.dma_dev_setup = pci_dma_dev_setup_swiotlb;
-		set_pci_dma_ops(&powerpc_swiotlb_dma_ops);
+		set_pci_dma_ops(&swiotlb_dma_ops);
 	}
 }
 #else
diff --git a/drivers/misc/cxl/vphb.c b/drivers/misc/cxl/vphb.c
index 49da2f744bbf..f4c0e9d2affe 100644
--- a/drivers/misc/cxl/vphb.c
+++ b/drivers/misc/cxl/vphb.c
@@ -43,7 +43,7 @@ static bool cxl_pci_enable_device_hook(struct pci_dev *dev)
 		return false;
 	}
 
-	set_dma_ops(&dev->dev, &dma_nommu_ops);
+	set_dma_ops(&dev->dev, &dma_direct_ops);
 	set_dma_offset(&dev->dev, PAGE_OFFSET);
 
 	/*
-- 
2.19.1
