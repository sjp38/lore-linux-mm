Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37F5E6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 04:57:31 -0400 (EDT)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LOM0004XJJPYQ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 20 Jul 2011 09:57:25 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LOM00AK7JJNYU@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 20 Jul 2011 09:57:24 +0100 (BST)
Date: Wed, 20 Jul 2011 10:57:19 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 7/8] ARM: integrate CMA with dma-mapping subsystem
In-reply-to: <1311152240-16384-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1311152240-16384-8-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1311152240-16384-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>, Russell King <linux@arm.linux.org.uk>

This patch adds support for CMA to dma-mapping subsystem for ARM
architecture. By default a global CMA area is used, but specific devices
are allowed to have their private memory areas if required (they can be
created with dma_declare_contiguous() function during board
initialization).

This patch is mainly a proof-of-concept.

Contiguous memory areas reserved for DMA are remapped with 2-level page
tables on boot. Once a buffer is requested, a low memory kernel mapping
is updated to to match requested memory access type.

TODO 1: Add support for GFP_ATOMIC allocations. They will be performed
from special memory area which is exclusive from system memory. Such
solution has been presented in "ARM: DMA: steal memory for DMA coherent
mappings" patch prepared by Russell King.

TODO 2: Implement support for contiguous memory areas that are placed
in HIGHMEM zone

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                      |    1 +
 arch/arm/include/asm/device.h         |    3 +
 arch/arm/include/asm/dma-contiguous.h |   33 +++++
 arch/arm/include/asm/mach/map.h       |    1 +
 arch/arm/mm/dma-mapping.c             |  244 +++++----------------------------
 arch/arm/mm/init.c                    |    3 +
 arch/arm/mm/mmu.c                     |   56 ++++++++-
 7 files changed, 133 insertions(+), 208 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-contiguous.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 9adc278..3cca8cc 100644
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
index d2fedb5..6ae266a 100644
--- a/arch/arm/include/asm/mach/map.h
+++ b/arch/arm/include/asm/mach/map.h
@@ -29,6 +29,7 @@ struct map_desc {
 #define MT_MEMORY_NONCACHED	11
 #define MT_MEMORY_DTCM		12
 #define MT_MEMORY_ITCM		13
+#define MT_MEMORY_DMA		14
 
 #ifdef CONFIG_MMU
 extern void iotable_init(struct map_desc *, int);
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 82a093c..ce0a981 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -17,6 +17,7 @@
 #include <linux/init.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
+#include <linux/dma-contiguous.h>
 #include <linux/highmem.h>
 
 #include <asm/memory.h>
@@ -58,10 +59,11 @@ static u64 get_coherent_dma_mask(struct device *dev)
  */
 static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
-	unsigned long order = get_order(size);
-	struct page *page, *p, *e;
+	struct page *page;
+	size_t count = size >> PAGE_SHIFT;
 	void *ptr;
 	u64 mask = get_coherent_dma_mask(dev);
+	unsigned long order = get_order(count << PAGE_SHIFT);
 
 #ifdef CONFIG_DMA_API_DEBUG
 	u64 limit = (mask + 1) & ~mask;
@@ -78,16 +80,12 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 	if (mask < 0xffffffffULL)
 		gfp |= GFP_DMA;
 
-	page = alloc_pages(gfp, order);
-	if (!page)
-		return NULL;
-
 	/*
-	 * Now split the huge page and free the excess pages
+	 * Allocate memory from contiguous area
 	 */
-	split_page(page, order);
-	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e; p++)
-		__free_page(p);
+	page = dma_alloc_from_contiguous(dev, count, order);
+	if (!page)
+		return NULL;
 
 	/*
 	 * Ensure that the allocated pages are zeroed, and that any data
@@ -104,200 +102,45 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 /*
  * Free a DMA buffer.  'size' must be page aligned.
  */
-static void __dma_free_buffer(struct page *page, size_t size)
+static void __dma_free_buffer(struct device *dev, struct page *page, size_t size)
 {
-	struct page *e = page + (size >> PAGE_SHIFT);
+	size_t count = size >> PAGE_SHIFT;
 
-	while (page < e) {
-		__free_page(page);
-		page++;
-	}
+	if (dma_release_from_contiguous(dev, page, count))
+		return;
 }
 
 #ifdef CONFIG_MMU
 /* Sanity check size */
-#if (CONSISTENT_DMA_SIZE % SZ_2M)
-#error "CONSISTENT_DMA_SIZE must be multiple of 2MiB"
-#endif
-
-#define CONSISTENT_OFFSET(x)	(((unsigned long)(x) - CONSISTENT_BASE) >> PAGE_SHIFT)
-#define CONSISTENT_PTE_INDEX(x) (((unsigned long)(x) - CONSISTENT_BASE) >> PGDIR_SHIFT)
-#define NUM_CONSISTENT_PTES (CONSISTENT_DMA_SIZE >> PGDIR_SHIFT)
-
-/*
- * These are the page tables (2MB each) covering uncached, DMA consistent allocations
- */
-static pte_t *consistent_pte[NUM_CONSISTENT_PTES];
-
-#include "vmregion.h"
-
-static struct arm_vmregion_head consistent_head = {
-	.vm_lock	= __SPIN_LOCK_UNLOCKED(&consistent_head.vm_lock),
-	.vm_list	= LIST_HEAD_INIT(consistent_head.vm_list),
-	.vm_start	= CONSISTENT_BASE,
-	.vm_end		= CONSISTENT_END,
-};
-
 #ifdef CONFIG_HUGETLB_PAGE
 #error ARM Coherent DMA allocator does not (yet) support huge TLB
 #endif
 
-/*
- * Initialise the consistent memory allocation.
- */
-static int __init consistent_init(void)
-{
-	int ret = 0;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	int i = 0;
-	u32 base = CONSISTENT_BASE;
-
-	do {
-		pgd = pgd_offset(&init_mm, base);
-
-		pud = pud_alloc(&init_mm, pgd, base);
-		if (!pud) {
-			printk(KERN_ERR "%s: no pud tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		pmd = pmd_alloc(&init_mm, pud, base);
-		if (!pmd) {
-			printk(KERN_ERR "%s: no pmd tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-		WARN_ON(!pmd_none(*pmd));
-
-		pte = pte_alloc_kernel(pmd, base);
-		if (!pte) {
-			printk(KERN_ERR "%s: no pte tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		consistent_pte[i++] = pte;
-		base += (1 << PGDIR_SHIFT);
-	} while (base < CONSISTENT_END);
-
-	return ret;
-}
-
-core_initcall(consistent_init);
-
-static void *
-__dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot)
+static int __dma_update_pte(pte_t *pte, pgtable_t token, unsigned long addr,
+			    void *data)
 {
-	struct arm_vmregion *c;
-	size_t align;
-	int bit;
-
-	if (!consistent_pte[0]) {
-		printk(KERN_ERR "%s: not initialised\n", __func__);
-		dump_stack();
-		return NULL;
-	}
-
-	/*
-	 * Align the virtual region allocation - maximum alignment is
-	 * a section size, minimum is a page size.  This helps reduce
-	 * fragmentation of the DMA space, and also prevents allocations
-	 * smaller than a section from crossing a section boundary.
-	 */
-	bit = fls(size - 1);
-	if (bit > SECTION_SHIFT)
-		bit = SECTION_SHIFT;
-	align = 1 << bit;
-
-	/*
-	 * Allocate a virtual address in the consistent mapping region.
-	 */
-	c = arm_vmregion_alloc(&consistent_head, align, size,
-			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM));
-	if (c) {
-		pte_t *pte;
-		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
-		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-
-		pte = consistent_pte[idx] + off;
-		c->vm_pages = page;
-
-		do {
-			BUG_ON(!pte_none(*pte));
-
-			set_pte_ext(pte, mk_pte(page, prot), 0);
-			page++;
-			pte++;
-			off++;
-			if (off >= PTRS_PER_PTE) {
-				off = 0;
-				pte = consistent_pte[++idx];
-			}
-		} while (size -= PAGE_SIZE);
-
-		dsb();
+	struct page *page = virt_to_page(addr);
+	pgprot_t prot = *(pgprot_t *)data;
 
-		return (void *)c->vm_start;
-	}
-	return NULL;
+	set_pte_ext(pte, mk_pte(page, prot), 0);
+	return 0;
 }
 
-static void __dma_free_remap(void *cpu_addr, size_t size)
+static int __dma_remap(struct page *page, size_t size, pgprot_t prot)
 {
-	struct arm_vmregion *c;
-	unsigned long addr;
-	pte_t *ptep;
-	int idx;
-	u32 off;
-
-	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
-	if (!c) {
-		printk(KERN_ERR "%s: trying to free invalid coherent area: %p\n",
-		       __func__, cpu_addr);
-		dump_stack();
-		return;
-	}
-
-	if ((c->vm_end - c->vm_start) != size) {
-		printk(KERN_ERR "%s: freeing wrong coherent size (%ld != %d)\n",
-		       __func__, c->vm_end - c->vm_start, size);
-		dump_stack();
-		size = c->vm_end - c->vm_start;
-	}
-
-	idx = CONSISTENT_PTE_INDEX(c->vm_start);
-	off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-	ptep = consistent_pte[idx] + off;
-	addr = c->vm_start;
-	do {
-		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
-
-		ptep++;
-		addr += PAGE_SIZE;
-		off++;
-		if (off >= PTRS_PER_PTE) {
-			off = 0;
-			ptep = consistent_pte[++idx];
-		}
-
-		if (pte_none(pte) || !pte_present(pte))
-			printk(KERN_CRIT "%s: bad page in kernel page table\n",
-			       __func__);
-	} while (size -= PAGE_SIZE);
+	unsigned long start = (unsigned long) page_address(page);
+	unsigned end = start + size;
 
-	flush_tlb_kernel_range(c->vm_start, c->vm_end);
+	apply_to_page_range(&init_mm, start, size, __dma_update_pte, &prot);
+	dsb();
+	flush_tlb_kernel_range(start, end);
 
-	arm_vmregion_free(&consistent_head, c);
+	return 0;
 }
 
 #else	/* !CONFIG_MMU */
 
-#define __dma_alloc_remap(page, size, gfp, prot)	page_address(page)
-#define __dma_free_remap(addr, size)			do { } while (0)
+#define __dma_remap(addr, size)			do { } while (0)
 
 #endif	/* CONFIG_MMU */
 
@@ -316,9 +159,9 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 		return NULL;
 
 	if (!arch_is_coherent())
-		addr = __dma_alloc_remap(page, size, gfp, prot);
-	else
-		addr = page_address(page);
+		__dma_remap(page, size, prot);
+
+	addr = page_address(page);
 
 	if (addr)
 		*handle = pfn_to_dma(dev, page_to_pfn(page));
@@ -360,27 +203,13 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 {
 	int ret = -ENXIO;
 #ifdef CONFIG_MMU
-	unsigned long user_size, kern_size;
-	struct arm_vmregion *c;
-
-	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-
-	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
-	if (c) {
-		unsigned long off = vma->vm_pgoff;
+	unsigned long pfn = page_to_pfn(virt_to_page(cpu_addr));
 
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
+	ret = remap_pfn_range(vma, vma->vm_start,
+			      pfn + vma->vm_pgoff,
+			      vma->vm_end - vma->vm_start,
+			      vma->vm_page_prot);
 #endif	/* CONFIG_MMU */
-
 	return ret;
 }
 
@@ -406,6 +235,7 @@ EXPORT_SYMBOL(dma_mmap_writecombine);
  */
 void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
 {
+	struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
 	WARN_ON(irqs_disabled());
 
 	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
@@ -414,9 +244,9 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
 	size = PAGE_ALIGN(size);
 
 	if (!arch_is_coherent())
-		__dma_free_remap(cpu_addr, size);
+		__dma_remap(page, size, pgprot_kernel);
 
-	__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
+	__dma_free_buffer(dev, page, size);
 }
 EXPORT_SYMBOL(dma_free_coherent);
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index c19571c..b2dfdeb 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -20,6 +20,7 @@
 #include <linux/gfp.h>
 #include <linux/memblock.h>
 #include <linux/sort.h>
+#include <linux/dma-contiguous.h>
 
 #include <asm/mach-types.h>
 #include <asm/prom.h>
@@ -358,6 +359,8 @@ void __init arm_memblock_init(struct meminfo *mi, struct machine_desc *mdesc)
 	if (mdesc->reserve)
 		mdesc->reserve();
 
+	dma_contiguous_reserve();
+
 	memblock_analyze();
 	memblock_dump_all();
 }
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 594d677..ece1a05 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -25,6 +25,7 @@
 #include <asm/tlb.h>
 #include <asm/highmem.h>
 #include <asm/traps.h>
+#include <asm/dma-contiguous.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -273,6 +274,11 @@ static struct mem_type mem_types[] = {
 		.prot_l1   = PMD_TYPE_TABLE,
 		.domain    = DOMAIN_KERNEL,
 	},
+	[MT_MEMORY_DMA] = {
+		.prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY,
+		.prot_l1   = PMD_TYPE_TABLE,
+		.domain    = DOMAIN_KERNEL,
+	},
 };
 
 const struct mem_type *get_mem_type(unsigned int type)
@@ -414,6 +420,7 @@ static void __init build_mem_type_table(void)
 	if (arch_is_coherent() && cpu_is_xsc3()) {
 		mem_types[MT_MEMORY].prot_sect |= PMD_SECT_S;
 		mem_types[MT_MEMORY].prot_pte |= L_PTE_SHARED;
+		mem_types[MT_MEMORY_DMA].prot_pte |= L_PTE_SHARED;
 		mem_types[MT_MEMORY_NONCACHED].prot_sect |= PMD_SECT_S;
 		mem_types[MT_MEMORY_NONCACHED].prot_pte |= L_PTE_SHARED;
 	}
@@ -443,6 +450,7 @@ static void __init build_mem_type_table(void)
 			mem_types[MT_DEVICE_CACHED].prot_pte |= L_PTE_SHARED;
 			mem_types[MT_MEMORY].prot_sect |= PMD_SECT_S;
 			mem_types[MT_MEMORY].prot_pte |= L_PTE_SHARED;
+			mem_types[MT_MEMORY_DMA].prot_pte |= L_PTE_SHARED;
 			mem_types[MT_MEMORY_NONCACHED].prot_sect |= PMD_SECT_S;
 			mem_types[MT_MEMORY_NONCACHED].prot_pte |= L_PTE_SHARED;
 		}
@@ -482,6 +490,7 @@ static void __init build_mem_type_table(void)
 	mem_types[MT_HIGH_VECTORS].prot_l1 |= ecc_mask;
 	mem_types[MT_MEMORY].prot_sect |= ecc_mask | cp->pmd;
 	mem_types[MT_MEMORY].prot_pte |= kern_pgprot;
+	mem_types[MT_MEMORY_DMA].prot_pte |= kern_pgprot;
 	mem_types[MT_MEMORY_NONCACHED].prot_sect |= ecc_mask;
 	mem_types[MT_ROM].prot_sect |= cp->pmd;
 
@@ -561,7 +570,7 @@ static void __init alloc_init_section(pud_t *pud, unsigned long addr,
 	 * L1 entries, whereas PGDs refer to a group of L1 entries making
 	 * up one logical pointer to an L2 table.
 	 */
-	if (((addr | end | phys) & ~SECTION_MASK) == 0) {
+	if (type->prot_sect && ((addr | end | phys) & ~SECTION_MASK) == 0) {
 		pmd_t *p = pmd;
 
 		if (addr & SECTION_SIZE)
@@ -1024,6 +1033,50 @@ static void __init map_lowmem(void)
 	}
 }
 
+struct dma_early_reserve
+{
+	phys_addr_t base;
+	unsigned long size;
+} dma_mmu_remap[MAX_CMA_AREAS] __initdata;
+int dma_mmu_remap_num __initdata;
+
+void __init dma_contiguous_early_fixup(phys_addr_t base, unsigned long size)
+{
+	dma_mmu_remap[dma_mmu_remap_num].base = base;
+	dma_mmu_remap[dma_mmu_remap_num].size = size;
+	dma_mmu_remap_num++;
+}
+
+static void __init dma_contiguous_remap(void)
+{
+	int i;
+	for (i=0; i < dma_mmu_remap_num; i++) {
+		phys_addr_t start = dma_mmu_remap[i].base;
+		phys_addr_t end = start + dma_mmu_remap[i].size;
+		struct map_desc map;
+		unsigned long addr;
+
+		if (end > lowmem_limit)
+			end = lowmem_limit;
+		if (start >= end)
+			return;
+
+		map.pfn = __phys_to_pfn(start);
+		map.virtual = __phys_to_virt(start);
+		map.length = end - start;
+		map.type = MT_MEMORY_DMA;
+
+		/*
+		 * Clear previous mapping
+		 */
+		for (addr = __phys_to_virt(start); addr < __phys_to_virt(end);
+		     addr += PGDIR_SIZE)
+			pmd_clear(pmd_off_k(addr));
+
+		create_mapping(&map);
+	}
+}
+
 /*
  * paging_init() sets up the page tables, initialises the zone memory
  * maps, and sets up the zero page, bad page and bad page tables.
@@ -1037,6 +1090,7 @@ void __init paging_init(struct machine_desc *mdesc)
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
