Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 5EC886B00E9
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:44:24 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M4600544BQCHY70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 16:44:36 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46001DNBPOD2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 16:44:20 +0100 (BST)
Date: Thu, 17 May 2012 17:44:00 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 updated] ARM: dma-mapping: remove custom consistent dma region
Message-id: <1337269440-10225-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

This patch changes dma-mapping subsystem to use generic vmalloc areas
for all consistent dma allocations. This increases the total size limit
of the consistent allocations and removes platform hacks and a lot of
duplicated code.

Atomic allocations are served from special pool preallocated on boot,
becasue vmalloc areas cannot be reliably created in atomic context.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---

Hello,

This is an updated version of the patch posted in the following thread:
http://www.spinics.net/lists/kernel/msg1342885.html

This one has been rebased onto the ARM DMA-mapping redesign patches and
includes a part for IOMMU-aware ARM DMA-mapping implementation. The ARM
DMA-mapping redesign patches are available in the following thread:
http://www.spinics.net/lists/arm-kernel/msg175729.html

Best regards
Marek Szyprowski
Samsung Poland R&D Center

---
 Documentation/kernel-parameters.txt |    4 +
 arch/arm/include/asm/dma-mapping.h  |    2 +-
 arch/arm/mm/dma-mapping.c           |  497 ++++++++++++++++-------------------
 3 files changed, 228 insertions(+), 275 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index c1601e5..ba58f50 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -515,6 +515,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			a hypervisor.
 			Default: yes
 
+	coherent_pool=nn[KMG]	[ARM,KNL]
+			Sets the size of memory pool for coherent, atomic dma
+			allocations.
+
 	code_bytes	[X86] How many bytes of object code to print
 			in an oops report.
 			Range: 0 - 8192
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index bbef15d..80777d87 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -226,7 +226,7 @@ static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struc
  * DMA region above it's default value of 2MB. It must be called before the
  * memory allocator is initialised, i.e. before any core_initcall.
  */
-extern void __init init_consistent_dma_size(unsigned long size);
+static inline void init_consistent_dma_size(unsigned long size) { }
 
 /*
  * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 3ac4760..2e98403 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -20,6 +20,7 @@
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/iommu.h>
+#include <linux/io.h>
 #include <linux/vmalloc.h>
 
 #include <asm/memory.h>
@@ -228,204 +229,170 @@ static void __dma_free_buffer(struct page *page, size_t size)
 }
 
 #ifdef CONFIG_MMU
-
-#define CONSISTENT_OFFSET(x)	(((unsigned long)(x) - consistent_base) >> PAGE_SHIFT)
-#define CONSISTENT_PTE_INDEX(x) (((unsigned long)(x) - consistent_base) >> PMD_SHIFT)
-
-/*
- * These are the page tables (2MB each) covering uncached, DMA consistent allocations
- */
-static pte_t **consistent_pte;
-
-#define DEFAULT_CONSISTENT_DMA_SIZE SZ_2M
-
-unsigned long consistent_base = CONSISTENT_END - DEFAULT_CONSISTENT_DMA_SIZE;
-
-void __init init_consistent_dma_size(unsigned long size)
-{
-	unsigned long base = CONSISTENT_END - ALIGN(size, SZ_2M);
-
-	BUG_ON(consistent_pte); /* Check we're called before DMA region init */
-	BUG_ON(base < VMALLOC_END);
-
-	/* Grow region to accommodate specified size  */
-	if (base < consistent_base)
-		consistent_base = base;
-}
-
-#include "vmregion.h"
-
-static struct arm_vmregion_head consistent_head = {
-	.vm_lock	= __SPIN_LOCK_UNLOCKED(&consistent_head.vm_lock),
-	.vm_list	= LIST_HEAD_INIT(consistent_head.vm_list),
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
-	unsigned long base = consistent_base;
-	unsigned long num_ptes = (CONSISTENT_END - base) >> PMD_SHIFT;
-
-	consistent_pte = kmalloc(num_ptes * sizeof(pte_t), GFP_KERNEL);
-	if (!consistent_pte) {
-		pr_err("%s: no memory\n", __func__);
-		return -ENOMEM;
-	}
-
-	pr_debug("DMA memory: 0x%08lx - 0x%08lx:\n", base, CONSISTENT_END);
-	consistent_head.vm_start = base;
-
-	do {
-		pgd = pgd_offset(&init_mm, base);
-
-		pud = pud_alloc(&init_mm, pgd, base);
-		if (!pud) {
-			pr_err("%s: no pud tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		pmd = pmd_alloc(&init_mm, pud, base);
-		if (!pmd) {
-			pr_err("%s: no pmd tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-		WARN_ON(!pmd_none(*pmd));
-
-		pte = pte_alloc_kernel(pmd, base);
-		if (!pte) {
-			pr_err("%s: no pte tables\n", __func__);
-			ret = -ENOMEM;
-			break;
-		}
-
-		consistent_pte[i++] = pte;
-		base += PMD_SIZE;
-	} while (base < CONSISTENT_END);
-
-	return ret;
-}
-
-core_initcall(consistent_init);
-
 static void *
 __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
 	const void *caller)
 {
-	struct arm_vmregion *c;
-	size_t align;
-	int bit;
+	struct vm_struct *area;
+	unsigned long addr;
 
-	if (!consistent_pte) {
-		pr_err("%s: not initialised\n", __func__);
+	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
+	if (!area)
+		return NULL;
+	addr = (unsigned long)area->addr;
+	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
+
+	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
+		vunmap((void *)addr);
+		return NULL;
+	}
+	return (void *)addr;
+}
+
+static void __dma_free_remap(void *cpu_addr, size_t size)
+{
+	struct vm_struct *area;
+
+	read_lock(&vmlist_lock);
+	area = find_vm_area(cpu_addr);
+	if (!area) {
+		pr_err("%s: trying to free invalid coherent area: %p\n",
+		       __func__, cpu_addr);
+		dump_stack();
+		read_unlock(&vmlist_lock);
+		return;
+	}
+	unmap_kernel_range((unsigned long)cpu_addr, size);
+	read_unlock(&vmlist_lock);
+	vunmap(cpu_addr);
+}
+
+struct dma_pool {
+	size_t size;
+	spinlock_t lock;
+	unsigned long *bitmap;
+	unsigned long count;
+	void *vaddr;
+	struct page *page;
+};
+
+static struct dma_pool atomic_pool = {
+	.size = SZ_256K,
+};
+
+static int __init early_coherent_pool(char *p)
+{
+	atomic_pool.size = memparse(p, &p);
+	return 0;
+}
+early_param("coherent_pool", early_coherent_pool);
+
+/*
+ * Initialise the coherent pool for atomic allocations.
+ */
+static int __init atomic_pool_init(void)
+{
+	struct dma_pool *pool = &atomic_pool;
+	pgprot_t prot = pgprot_dmacoherent(pgprot_kernel);
+	unsigned long count = pool->size >> PAGE_SHIFT;
+	gfp_t gfp = GFP_KERNEL | GFP_DMA;
+	unsigned long *bitmap;
+	struct page *page;
+	void *ptr;
+	int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
+
+	bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!bitmap)
+		goto no_bitmap;
+
+	page = __dma_alloc_buffer(NULL, pool->size, gfp);
+	if (!page)
+		goto no_page;
+
+	ptr = __dma_alloc_remap(page, pool->size, gfp, prot, NULL);
+	if (ptr) {
+		spin_lock_init(&pool->lock);
+		pool->vaddr = ptr;
+		pool->page = page;
+		pool->bitmap = bitmap;
+		pool->count = count;
+		pr_info("DMA: preallocated %u KiB pool for atomic coherent allocations\n",
+		       (unsigned)pool->size / 1024);
+		return 0;
+	}
+
+	__dma_free_buffer(page, pool->size);
+no_page:
+	kfree(bitmap);
+no_bitmap:
+	pr_err("DMA: failed to allocate %u KiB pool for atomic coherent allocation\n",
+	       (unsigned)pool->size / 1024);
+	return -ENOMEM;
+}
+core_initcall(atomic_pool_init);
+
+static void *__alloc_from_pool(size_t size, struct page **ret_page)
+{
+	struct dma_pool *pool = &atomic_pool;
+	unsigned int count = size >> PAGE_SHIFT;
+	unsigned int pageno;
+	unsigned long flags;
+	void *ptr = NULL;
+	size_t align;
+
+	if (!pool->vaddr) {
+		pr_err("%s: coherent pool not initialised!\n", __func__);
 		dump_stack();
 		return NULL;
 	}
 
 	/*
-	 * Align the virtual region allocation - maximum alignment is
-	 * a section size, minimum is a page size.  This helps reduce
-	 * fragmentation of the DMA space, and also prevents allocations
-	 * smaller than a section from crossing a section boundary.
+	 * Align the region allocation - allocations from pool are rather
+	 * small, so align them to their order in pages, minimum is a page
+	 * size. This helps reduce fragmentation of the DMA space.
 	 */
-	bit = fls(size - 1);
-	if (bit > SECTION_SHIFT)
-		bit = SECTION_SHIFT;
-	align = 1 << bit;
+	align = PAGE_SIZE << get_order(size);
 
-	/*
-	 * Allocate a virtual address in the consistent mapping region.
-	 */
-	c = arm_vmregion_alloc(&consistent_head, align, size,
-			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM), caller);
-	if (c) {
-		pte_t *pte;
-		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
-		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-
-		pte = consistent_pte[idx] + off;
-		c->priv = page;
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
-
-		return (void *)c->vm_start;
+	spin_lock_irqsave(&pool->lock, flags);
+	pageno = bitmap_find_next_zero_area(pool->bitmap, pool->count,
+					    0, count, (1 << align) - 1);
+	if (pageno < pool->count) {
+		bitmap_set(pool->bitmap, pageno, count);
+		ptr = pool->vaddr + PAGE_SIZE * pageno;
+		*ret_page = pool->page + pageno;
 	}
-	return NULL;
+	spin_unlock_irqrestore(&pool->lock, flags);
+
+	return ptr;
 }
 
-static void __dma_free_remap(void *cpu_addr, size_t size)
+static int __free_from_pool(void *start, size_t size)
 {
-	struct arm_vmregion *c;
-	unsigned long addr;
-	pte_t *ptep;
-	int idx;
-	u32 off;
+	struct dma_pool *pool = &atomic_pool;
+	unsigned long pageno, count;
+	unsigned long flags;
 
-	c = arm_vmregion_find_remove(&consistent_head, (unsigned long)cpu_addr);
-	if (!c) {
-		pr_err("%s: trying to free invalid coherent area: %p\n",
-		       __func__, cpu_addr);
+	if (start < pool->vaddr || start > pool->vaddr + pool->size)
+		return 0;
+
+	if (start + size > pool->vaddr + pool->size) {
+		pr_err("%s: freeing wrong coherent size from pool\n", __func__);
 		dump_stack();
-		return;
+		return 0;
 	}
 
-	if ((c->vm_end - c->vm_start) != size) {
-		pr_err("%s: freeing wrong coherent size (%ld != %d)\n",
-		       __func__, c->vm_end - c->vm_start, size);
-		dump_stack();
-		size = c->vm_end - c->vm_start;
-	}
+	pageno = (start - pool->vaddr) >> PAGE_SHIFT;
+	count = size >> PAGE_SHIFT;
 
-	idx = CONSISTENT_PTE_INDEX(c->vm_start);
-	off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-	ptep = consistent_pte[idx] + off;
-	addr = c->vm_start;
-	do {
-		pte_t pte = ptep_get_and_clear(&init_mm, addr, ptep);
+	spin_lock_irqsave(&pool->lock, flags);
+	bitmap_clear(pool->bitmap, pageno, count);
+	spin_unlock_irqrestore(&pool->lock, flags);
 
-		ptep++;
-		addr += PAGE_SIZE;
-		off++;
-		if (off >= PTRS_PER_PTE) {
-			off = 0;
-			ptep = consistent_pte[++idx];
-		}
-
-		if (pte_none(pte) || !pte_present(pte))
-			pr_crit("%s: bad page in kernel page table\n",
-				__func__);
-	} while (size -= PAGE_SIZE);
-
-	flush_tlb_kernel_range(c->vm_start, c->vm_end);
-
-	arm_vmregion_free(&consistent_head, c);
+	return 1;
 }
 
 static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot)
@@ -441,6 +408,8 @@ static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot)
 #define __dma_alloc_remap(page, size, gfp, prot, c)	page_address(page)
 #define __dma_free_remap(addr, size)			do { } while (0)
 #define __get_dma_pgprot(attrs, prot)	__pgprot(0)
+#define __alloc_from_pool(size, ret_page)		NULL
+#define __free_from_pool(addr, size)			0
 
 #endif	/* CONFIG_MMU */
 
@@ -463,6 +432,16 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	*handle = DMA_ERROR_CODE;
 	size = PAGE_ALIGN(size);
 
+	/*
+	 * Atomic allocations need special handling
+	 */
+	if (gfp & GFP_ATOMIC && !arch_is_coherent()) {
+		addr = __alloc_from_pool(size, &page);
+		if (addr)
+			*handle = pfn_to_dma(dev, page_to_pfn(page));
+		return addr;
+	}
+
 	page = __dma_alloc_buffer(dev, size, gfp);
 	if (!page)
 		return NULL;
@@ -506,30 +485,21 @@ int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 {
 	int ret = -ENXIO;
 #ifdef CONFIG_MMU
-	unsigned long user_size, kern_size;
-	struct arm_vmregion *c;
+	unsigned long user_count = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	unsigned long pfn = dma_to_pfn(dev, dma_addr);
+	unsigned long off = vma->vm_pgoff;
 
 	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
 
 	if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
 		return ret;
 
-	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-
-	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
-	if (c) {
-		unsigned long off = vma->vm_pgoff;
-		struct page *pages = c->priv;
-
-		kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
-
-		if (off < kern_size &&
-		    user_size <= (kern_size - off)) {
-			ret = remap_pfn_range(vma, vma->vm_start,
-					      page_to_pfn(pages) + off,
-					      user_size << PAGE_SHIFT,
-					      vma->vm_page_prot);
-		}
+	if (off < count && user_count <= (count - off)) {
+		ret = remap_pfn_range(vma, vma->vm_start,
+				      pfn + off,
+				      user_count << PAGE_SHIFT,
+				      vma->vm_page_prot);
 	}
 #endif	/* CONFIG_MMU */
 
@@ -543,13 +513,16 @@ int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 		  dma_addr_t handle, struct dma_attrs *attrs)
 {
-	WARN_ON(irqs_disabled());
-
 	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
 		return;
 
 	size = PAGE_ALIGN(size);
 
+	if (__free_from_pool(cpu_addr, size))
+			return;
+
+	WARN_ON(irqs_disabled());
+
 	if (!arch_is_coherent())
 		__dma_free_remap(cpu_addr, size);
 
@@ -769,9 +742,6 @@ static int arm_dma_set_mask(struct device *dev, u64 dma_mask)
 
 static int __init dma_debug_do_init(void)
 {
-#ifdef CONFIG_MMU
-	arm_vmregion_create_proc("dma-mappings", &consistent_head);
-#endif
 	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
 	return 0;
 }
@@ -888,61 +858,30 @@ static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t s
  * Create a CPU mapping for a specified pages
  */
 static void *
-__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot)
+__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot,
+		    const void *caller)
 {
-	struct arm_vmregion *c;
-	size_t align;
-	size_t count = size >> PAGE_SHIFT;
-	int bit;
+	unsigned int i, count = size >> PAGE_SHIFT;
+	struct vm_struct *area;
+	unsigned long p;
 
-	if (!consistent_pte[0]) {
-		pr_err("%s: not initialised\n", __func__);
-		dump_stack();
+	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
+	if (!area)
 		return NULL;
+
+	area->pages = pages;
+	p = (unsigned long)area->addr;
+
+	for (i = 0; i < count; i++) {
+		phys_addr_t phys = __pfn_to_phys(page_to_pfn(pages[i]));
+		if (ioremap_page_range(p, p + PAGE_SIZE, phys, prot))
+			goto err;
+		p += PAGE_SIZE;
 	}
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
-			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM), NULL);
-	if (c) {
-		pte_t *pte;
-		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
-		int i = 0;
-		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
-
-		pte = consistent_pte[idx] + off;
-		c->priv = pages;
-
-		do {
-			BUG_ON(!pte_none(*pte));
-
-			set_pte_ext(pte, mk_pte(pages[i], prot), 0);
-			pte++;
-			off++;
-			i++;
-			if (off >= PTRS_PER_PTE) {
-				off = 0;
-				pte = consistent_pte[++idx];
-			}
-		} while (i < count);
-
-		dsb();
-
-		return (void *)c->vm_start;
-	}
+	return area->addr;
+err:
+	unmap_kernel_range((unsigned long)area->addr, size);
+	vunmap(area->addr);
 	return NULL;
 }
 
@@ -1001,6 +940,17 @@ static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t si
 	return 0;
 }
 
+static struct page **__iommu_get_pages(void *cpu_addr)
+{
+	struct vm_struct *area;
+	read_lock(&vmlist_lock);
+	area = find_vm_area(cpu_addr);
+	read_unlock(&vmlist_lock);
+	if (area)
+		return area->pages;
+	return NULL;
+}
+
 static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
 {
@@ -1019,7 +969,8 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	if (*handle == DMA_ERROR_CODE)
 		goto err_buffer;
 
-	addr = __iommu_alloc_remap(pages, size, gfp, prot);
+	addr = __iommu_alloc_remap(pages, size, gfp, prot,
+				   __builtin_return_address(0));
 	if (!addr)
 		goto err_mapping;
 
@@ -1036,31 +987,25 @@ static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    struct dma_attrs *attrs)
 {
-	struct arm_vmregion *c;
+	unsigned long uaddr = vma->vm_start;
+	unsigned long usize = vma->vm_end - vma->vm_start;
+	struct page **pages = __iommu_get_pages(cpu_addr);
 
 	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
-	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
 
-	if (c) {
-		struct page **pages = c->priv;
+	if (!pages)
+		return -ENXIO;
 
-		unsigned long uaddr = vma->vm_start;
-		unsigned long usize = vma->vm_end - vma->vm_start;
-		int i = 0;
+	do {
+		int ret = vm_insert_page(vma, uaddr, *pages++);
+		if (ret) {
+			pr_err("Remapping memory failed: %d\n", ret);
+			return ret;
+		}
+		uaddr += PAGE_SIZE;
+		usize -= PAGE_SIZE;
+	} while (usize > 0);
 
-		do {
-			int ret;
-
-			ret = vm_insert_page(vma, uaddr, pages[i++]);
-			if (ret) {
-				pr_err("Remapping memory, error: %d\n", ret);
-				return ret;
-			}
-
-			uaddr += PAGE_SIZE;
-			usize -= PAGE_SIZE;
-		} while (usize > 0);
-	}
 	return 0;
 }
 
@@ -1071,16 +1016,20 @@ static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
 void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 			  dma_addr_t handle, struct dma_attrs *attrs)
 {
-	struct arm_vmregion *c;
+	struct page **pages = __iommu_get_pages(cpu_addr);
 	size = PAGE_ALIGN(size);
 
-	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
-	if (c) {
-		struct page **pages = c->priv;
-		__dma_free_remap(cpu_addr, size);
-		__iommu_remove_mapping(dev, handle, size);
-		__iommu_free_buffer(dev, pages, size);
+	if (!pages) {
+		pr_err("%s: trying to free invalid coherent area: %p\n",
+		       __func__, cpu_addr);
+		dump_stack();
+		return;
 	}
+
+	unmap_kernel_range((unsigned long)cpu_addr, size);
+	vunmap(cpu_addr);
+	__iommu_remove_mapping(dev, handle, size);
+	__iommu_free_buffer(dev, pages, size);
 }
 
 /*
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
