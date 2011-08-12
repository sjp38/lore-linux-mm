Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CDB4F6B016A
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 06:58:40 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from spt2.w1.samsung.com ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LPT006ELAHOON60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 12 Aug 2011 11:58:37 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LPT005EQAHNQL@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 12 Aug 2011 11:58:36 +0100 (BST)
Date: Fri, 12 Aug 2011 12:58:30 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 8/9] ARM: integrate CMA with DMA-mapping subsystem
In-reply-to: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1313146711-1767-9-git-send-email-m.szyprowski@samsung.com>
References: <1313146711-1767-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

This patch adds support for CMA to dma-mapping subsystem for ARM
architecture. By default a global CMA area is used, but specific devices
are allowed to have their private memory areas if required (they can be
created with dma_declare_contiguous() function during board
initialization).

Contiguous memory areas reserved for DMA are remapped with 2-level page
tables on boot. Once a buffer is requested, a low memory kernel mapping
is updated to to match requested memory access type.

GFP_ATOMIC allocations are performed from special memory area which is
exclusive from system memory to avoid remapping page attributes what might
be not allowed in atomic context on some systems. If CMA has been disabled
then all DMA allocations are performed from this area.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                      |    1 +
 arch/arm/include/asm/device.h         |    3 +
 arch/arm/include/asm/dma-contiguous.h |   33 +++++++
 arch/arm/include/asm/mach/map.h       |    5 +-
 arch/arm/mm/dma-mapping.c             |  169 +++++++++++++++++++++++++--------
 arch/arm/mm/init.c                    |    5 +-
 arch/arm/mm/mm.h                      |    3 +
 arch/arm/mm/mmu.c                     |   29 ++++--
 8 files changed, 196 insertions(+), 52 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-contiguous.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 2c71a8f..20fa729 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -3,6 +3,7 @@ config ARM
 	default y
 	select HAVE_AOUT
 	select HAVE_DMA_API_DEBUG
+	select HAVE_DMA_CONTIGUOUS
 	select HAVE_IDE
 	select HAVE_MEMBLOCK
 	select RTC_LIB
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 9f390ce..942913e 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -10,6 +10,9 @@ struct dev_archdata {
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
+#ifdef CONFIG_CMA
+	struct cma *cma_area;
+#endif
 };
 
 struct pdev_archdata {
diff --git a/arch/arm/include/asm/dma-contiguous.h b/arch/arm/include/asm/dma-contiguous.h
new file mode 100644
index 0000000..99bf7c8
--- /dev/null
+++ b/arch/arm/include/asm/dma-contiguous.h
@@ -0,0 +1,33 @@
+#ifndef ASMARM_DMA_CONTIGUOUS_H
+#define ASMARM_DMA_CONTIGUOUS_H
+
+#ifdef __KERNEL__
+
+#include <linux/device.h>
+#include <linux/dma-contiguous.h>
+
+#ifdef CONFIG_CMA
+
+#define MAX_CMA_AREAS	(8)
+
+void dma_contiguous_early_fixup(phys_addr_t base, unsigned long size);
+
+static inline struct cma *get_dev_cma_area(struct device *dev)
+{
+	if (dev->archdata.cma_area)
+		return dev->archdata.cma_area;
+	return dma_contiguous_default_area;
+}
+
+static inline void set_dev_cma_area(struct device *dev, struct cma *cma)
+{
+	dev->archdata.cma_area = cma;
+}
+
+#else
+
+#define MAX_CMA_AREAS	(0)
+
+#endif
+#endif
+#endif
diff --git a/arch/arm/include/asm/mach/map.h b/arch/arm/include/asm/mach/map.h
index 3845215..5982a83 100644
--- a/arch/arm/include/asm/mach/map.h
+++ b/arch/arm/include/asm/mach/map.h
@@ -29,8 +29,9 @@ struct map_desc {
 #define MT_MEMORY_NONCACHED	11
 #define MT_MEMORY_DTCM		12
 #define MT_MEMORY_ITCM		13
-#define MT_DMA_COHERENT		14
-#define MT_WC_COHERENT		15
+#define MT_MEMORY_DMA_READY	14
+#define MT_DMA_COHERENT		15
+#define MT_WC_COHERENT		16
 
 #ifdef CONFIG_MMU
 extern void iotable_init(struct map_desc *, int);
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index b643262..63175d1 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -17,6 +17,7 @@
 #include <linux/init.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
+#include <linux/dma-contiguous.h>
 #include <linux/highmem.h>
 #include <linux/memblock.h>
 
@@ -26,6 +27,7 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 #include <asm/mach/map.h>
+#include <asm/dma-contiguous.h>
 
 #include "mm.h"
 
@@ -56,6 +58,24 @@ static u64 get_coherent_dma_mask(struct device *dev)
 	return mask;
 }
 
+static struct page *__dma_alloc_system_pages(size_t count, gfp_t gfp,
+					     unsigned long order)
+{
+	struct page *page, *p, *e;
+
+	page = alloc_pages(gfp, order);
+	if (!page)
+		return NULL;
+
+	/*
+	 * Now split the huge page and free the excess pages
+	 */
+	split_page(page, order);
+	for (p = page + count, e = page + (1 << order); p < e; p++)
+		__free_page(p);
+	return page;
+}
+
 /*
  * Allocate a DMA buffer for 'dev' of size 'size' using the
  * specified gfp mask.  Note that 'size' must be page aligned.
@@ -63,7 +83,8 @@ static u64 get_coherent_dma_mask(struct device *dev)
 static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
 	unsigned long order = get_order(size);
-	struct page *page, *p, *e;
+	size_t count = size >> PAGE_SHIFT;
+	struct page *page;
 	void *ptr;
 	u64 mask = get_coherent_dma_mask(dev);
 
@@ -82,16 +103,16 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 	if (mask < 0xffffffffULL)
 		gfp |= GFP_DMA;
 
-	page = alloc_pages(gfp, order);
-	if (!page)
-		return NULL;
-
 	/*
-	 * Now split the huge page and free the excess pages
+	 * Allocate contiguous memory
 	 */
-	split_page(page, order);
-	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e; p++)
-		__free_page(p);
+	if (cma_available())
+		page = dma_alloc_from_contiguous(dev, count, order);
+	else
+		page = __dma_alloc_system_pages(count, gfp, order);
+
+	if (!page)
+		return NULL;
 
 	/*
 	 * Ensure that the allocated pages are zeroed, and that any data
@@ -108,7 +129,7 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 /*
  * Free a DMA buffer.  'size' must be page aligned.
  */
-static void __dma_free_buffer(struct page *page, size_t size)
+static void __dma_free_system_buffer(struct page *page, size_t size)
 {
 	struct page *e = page + (size >> PAGE_SHIFT);
 
@@ -136,6 +157,7 @@ struct dma_coherent_area {
 	struct arm_vmregion_head vm;
 	unsigned long pfn;
 	unsigned int type;
+	pgprot_t prot;
 	const char *name;
 };
 
@@ -232,6 +254,55 @@ void __init dma_coherent_mapping(void)
 	}
 
 	iotable_init(map, nr);
+	coherent_dma_area->prot = pgprot_dmacoherent(pgprot_kernel);
+	coherent_wc_area->prot = pgprot_writecombine(pgprot_kernel);
+}
+
+struct dma_contiguous_early_reserve {
+	phys_addr_t base;
+	unsigned long size;
+};
+
+static struct dma_contiguous_early_reserve
+dma_mmu_remap[MAX_CMA_AREAS] __initdata;
+
+static int dma_mmu_remap_num __initdata;
+
+void __init dma_contiguous_early_fixup(phys_addr_t base, unsigned long size)
+{
+	dma_mmu_remap[dma_mmu_remap_num].base = base;
+	dma_mmu_remap[dma_mmu_remap_num].size = size;
+	dma_mmu_remap_num++;
+}
+
+void __init dma_contiguous_remap(void)
+{
+	int i;
+	for (i = 0; i < dma_mmu_remap_num; i++) {
+		phys_addr_t start = dma_mmu_remap[i].base;
+		phys_addr_t end = start + dma_mmu_remap[i].size;
+		struct map_desc map;
+		unsigned long addr;
+
+		if (end > arm_lowmem_limit)
+			end = arm_lowmem_limit;
+		if (start >= end)
+			return;
+
+		map.pfn = __phys_to_pfn(start);
+		map.virtual = __phys_to_virt(start);
+		map.length = end - start;
+		map.type = MT_MEMORY_DMA_READY;
+
+		/*
+		 * Clear previous low-memory mapping
+		 */
+		for (addr = __phys_to_virt(start); addr < __phys_to_virt(end);
+		     addr += PGDIR_SIZE)
+			pmd_clear(pmd_off_k(addr));
+
+		iotable_init(&map, 1);
+	}
 }
 
 static void *dma_alloc_area(size_t size, unsigned long *pfn, gfp_t gfp,
@@ -289,10 +360,34 @@ static void dma_free_area(void *cpu_addr, size_t size, struct dma_coherent_area
 
 #define nommu() (0)
 
+static int __dma_update_pte(pte_t *pte, pgtable_t token, unsigned long addr,
+			    void *data)
+{
+	struct page *page = virt_to_page(addr);
+	pgprot_t prot = *(pgprot_t *)data;
+
+	set_pte_ext(pte, mk_pte(page, prot), 0);
+	return 0;
+}
+
+static void dma_remap_area(struct page *page, size_t size, pgprot_t prot)
+{
+	unsigned long start = (unsigned long) page_address(page);
+	unsigned end = start + size;
+
+	if (arch_is_coherent())
+		return;
+
+	apply_to_page_range(&init_mm, start, size, __dma_update_pte, &prot);
+	dsb();
+	flush_tlb_kernel_range(start, end);
+}
+
 #else	/* !CONFIG_MMU */
 
 #define dma_alloc_area(size, pfn, gfp, area)	({ *(pfn) = 0; NULL })
 #define dma_free_area(addr, size, area)		do { } while (0)
+#define dma_remap_area(page, size, prot)	do { } while (0)
 
 #define nommu()	(1)
 #define coherent_wc_area NULL
@@ -308,19 +403,27 @@ static void *
 __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	    struct dma_coherent_area *area)
 {
-	unsigned long pfn;
-	void *ret;
+	unsigned long pfn = 0;
+	void *ret = NULL;
 
 	*handle = ~0;
 	size = PAGE_ALIGN(size);
 
-	if (arch_is_coherent() || nommu()) {
+	if (arch_is_coherent() || nommu() ||
+	   (cma_available() && !(gfp & GFP_ATOMIC))) {
+		/*
+		 * Allocate from system or CMA pages
+		 */
 		struct page *page = __dma_alloc_buffer(dev, size, gfp);
 		if (!page)
 			return NULL;
+		dma_remap_area(page, size, area->prot);
 		pfn = page_to_pfn(page);
 		ret = page_address(page);
 	} else {
+		/*
+		 * Allocate from reserved DMA coherent/wc area
+		 */
 		ret = dma_alloc_area(size, &pfn, gfp, area);
 	}
 
@@ -333,12 +436,19 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 static void __dma_free(struct device *dev, size_t size, void *cpu_addr,
 	dma_addr_t handle, struct dma_coherent_area *area)
 {
+	struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
 	size = PAGE_ALIGN(size);
 
 	if (arch_is_coherent() || nommu()) {
-		__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
-	} else {
+		WARN_ON(irqs_disabled());
+		__dma_free_system_buffer(page, size);
+	} else if ((unsigned long)cpu_addr >= area->vm.vm_start &&
+		   (unsigned long)cpu_addr < area->vm.vm_end) {
 		dma_free_area(cpu_addr, size, area);
+	} else {
+		WARN_ON(irqs_disabled());
+		dma_remap_area(page, size, pgprot_kernel);
+		dma_release_from_contiguous(dev, page, size >> PAGE_SHIFT);
 	}
 }
 
@@ -375,27 +485,12 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 {
 	int ret = -ENXIO;
 #ifdef CONFIG_MMU
-	unsigned long user_size, kern_size;
-	struct arm_vmregion *c;
-
-	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-
-	c = arm_vmregion_find(&area->vm, (unsigned long)cpu_addr);
-	if (c) {
-		unsigned long off = vma->vm_pgoff;
-
-		kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
-
-		if (off < kern_size &&
-		    user_size <= (kern_size - off)) {
-			ret = remap_pfn_range(vma, vma->vm_start,
-					      page_to_pfn(c->vm_pages) + off,
-					      user_size << PAGE_SHIFT,
-					      vma->vm_page_prot);
-		}
-	}
+	unsigned long pfn = dma_to_pfn(dev, dma_addr);
+	ret = remap_pfn_range(vma, vma->vm_start,
+			      pfn + vma->vm_pgoff,
+			      vma->vm_end - vma->vm_start,
+			      vma->vm_page_prot);
 #endif	/* CONFIG_MMU */
-
 	return ret;
 }
 
@@ -421,8 +516,6 @@ EXPORT_SYMBOL(dma_mmap_writecombine);
  */
 void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
 {
-	WARN_ON(irqs_disabled());
-
 	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
 		return;
 
@@ -433,8 +526,6 @@ EXPORT_SYMBOL(dma_free_coherent);
 void dma_free_writecombine(struct device *dev, size_t size, void *cpu_addr,
 	dma_addr_t handle)
 {
-	WARN_ON(irqs_disabled());
-
 	__dma_free(dev, size, cpu_addr, handle, coherent_wc_area);
 }
 EXPORT_SYMBOL(dma_free_writecombine);
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 77076a6..0f2dbb8 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -20,6 +20,7 @@
 #include <linux/gfp.h>
 #include <linux/memblock.h>
 #include <linux/sort.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm/mach-types.h>
 #include <asm/prom.h>
@@ -365,12 +366,14 @@ void __init arm_memblock_init(struct meminfo *mi, struct machine_desc *mdesc)
 
 	arm_mm_memblock_reserve();
 	arm_dt_memblock_reserve();
-	dma_coherent_reserve();
 
 	/* reserve any platform specific memblock areas */
 	if (mdesc->reserve)
 		mdesc->reserve();
 
+	dma_coherent_reserve();
+	dma_contiguous_reserve();
+
 	memblock_analyze();
 	memblock_dump_all();
 }
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index 3abaa2c..46101be 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -29,7 +29,10 @@ extern u32 arm_dma_limit;
 #define arm_dma_limit ((u32)~0)
 #endif
 
+extern phys_addr_t arm_lowmem_limit;
+
 void __init bootmem_init(void);
 void arm_mm_memblock_reserve(void);
 void dma_coherent_reserve(void);
 void dma_coherent_mapping(void);
+void dma_contiguous_remap(void);
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 027f118..9dc18d4 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -273,6 +273,11 @@ static struct mem_type mem_types[] = {
 		.prot_l1   = PMD_TYPE_TABLE,
 		.domain    = DOMAIN_KERNEL,
 	},
+	[MT_MEMORY_DMA_READY] = {
+		.prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY,
+		.prot_l1   = PMD_TYPE_TABLE,
+		.domain    = DOMAIN_KERNEL,
+	},
 	[MT_DMA_COHERENT] = {
 		.prot_sect	= PMD_TYPE_SECT | PMD_SECT_AP_WRITE |
 				  PMD_SECT_S,
@@ -425,6 +430,7 @@ static void __init build_mem_type_table(void)
 	if (arch_is_coherent() && cpu_is_xsc3()) {
 		mem_types[MT_MEMORY].prot_sect |= PMD_SECT_S;
 		mem_types[MT_MEMORY].prot_pte |= L_PTE_SHARED;
+		mem_types[MT_MEMORY_DMA_READY].prot_pte |= L_PTE_SHARED;
 		mem_types[MT_MEMORY_NONCACHED].prot_sect |= PMD_SECT_S;
 		mem_types[MT_MEMORY_NONCACHED].prot_pte |= L_PTE_SHARED;
 	}
@@ -454,6 +460,7 @@ static void __init build_mem_type_table(void)
 			mem_types[MT_DEVICE_CACHED].prot_pte |= L_PTE_SHARED;
 			mem_types[MT_MEMORY].prot_sect |= PMD_SECT_S;
 			mem_types[MT_MEMORY].prot_pte |= L_PTE_SHARED;
+			mem_types[MT_MEMORY_DMA_READY].prot_pte |= L_PTE_SHARED;
 			mem_types[MT_MEMORY_NONCACHED].prot_sect |= PMD_SECT_S;
 			mem_types[MT_MEMORY_NONCACHED].prot_pte |= L_PTE_SHARED;
 		}
@@ -504,6 +511,7 @@ static void __init build_mem_type_table(void)
 	mem_types[MT_HIGH_VECTORS].prot_l1 |= ecc_mask;
 	mem_types[MT_MEMORY].prot_sect |= ecc_mask | cp->pmd;
 	mem_types[MT_MEMORY].prot_pte |= kern_pgprot;
+	mem_types[MT_MEMORY_DMA_READY].prot_pte |= kern_pgprot;
 	mem_types[MT_MEMORY_NONCACHED].prot_sect |= ecc_mask;
 	mem_types[MT_ROM].prot_sect |= cp->pmd;
 
@@ -583,7 +591,7 @@ static void __init alloc_init_section(pud_t *pud, unsigned long addr,
 	 * L1 entries, whereas PGDs refer to a group of L1 entries making
 	 * up one logical pointer to an L2 table.
 	 */
-	if (((addr | end | phys) & ~SECTION_MASK) == 0) {
+	if (type->prot_sect && ((addr | end | phys) & ~SECTION_MASK) == 0) {
 		pmd_t *p = pmd;
 
 		if (addr & SECTION_SIZE)
@@ -779,7 +787,7 @@ static int __init early_vmalloc(char *arg)
 }
 early_param("vmalloc", early_vmalloc);
 
-static phys_addr_t lowmem_limit __initdata = 0;
+phys_addr_t arm_lowmem_limit __initdata = 0;
 
 void __init sanity_check_meminfo(void)
 {
@@ -848,8 +856,8 @@ void __init sanity_check_meminfo(void)
 			bank->size = newsize;
 		}
 #endif
-		if (!bank->highmem && bank->start + bank->size > lowmem_limit)
-			lowmem_limit = bank->start + bank->size;
+		if (!bank->highmem && bank->start + bank->size > arm_lowmem_limit)
+			arm_lowmem_limit = bank->start + bank->size;
 
 		j++;
 	}
@@ -874,7 +882,7 @@ void __init sanity_check_meminfo(void)
 	}
 #endif
 	meminfo.nr_banks = j;
-	memblock_set_current_limit(lowmem_limit);
+	memblock_set_current_limit(arm_lowmem_limit);
 }
 
 static inline void prepare_page_table(void)
@@ -899,8 +907,8 @@ static inline void prepare_page_table(void)
 	 * Find the end of the first block of lowmem.
 	 */
 	end = memblock.memory.regions[0].base + memblock.memory.regions[0].size;
-	if (end >= lowmem_limit)
-		end = lowmem_limit;
+	if (end >= arm_lowmem_limit)
+		end = arm_lowmem_limit;
 
 	/*
 	 * Clear out all the kernel space mappings, except for the first
@@ -1034,8 +1042,8 @@ static void __init map_lowmem(void)
 		phys_addr_t end = start + reg->size;
 		struct map_desc map;
 
-		if (end > lowmem_limit)
-			end = lowmem_limit;
+		if (end > arm_lowmem_limit)
+			end = arm_lowmem_limit;
 		if (start >= end)
 			break;
 
@@ -1056,11 +1064,12 @@ void __init paging_init(struct machine_desc *mdesc)
 {
 	void *zero_page;
 
-	memblock_set_current_limit(lowmem_limit);
+	memblock_set_current_limit(arm_lowmem_limit);
 
 	build_mem_type_table();
 	prepare_page_table();
 	map_lowmem();
+	dma_contiguous_remap();
 	devicemaps_init(mdesc);
 	kmap_init();
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
