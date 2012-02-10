Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0AF1F6B1402
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:59:01 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZ6004XFY2AG180@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ600G8XY293A@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Date: Fri, 10 Feb 2012 19:58:44 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv6 7/7] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328900324-20946-8-git-send-email-m.szyprowski@samsung.com>
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This patch add a complete implementation of DMA-mapping API for
devices that have IOMMU support. All DMA-mapping calls are supported.

This patch contains some of the code kindly provided by Krishna Reddy
<vdumpa@nvidia.com> and Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                 |    8 +
 arch/arm/include/asm/device.h    |    3 +
 arch/arm/include/asm/dma-iommu.h |   34 ++
 arch/arm/mm/dma-mapping.c        |  635 +++++++++++++++++++++++++++++++++++++-
 arch/arm/mm/vmregion.h           |    2 +-
 5 files changed, 667 insertions(+), 15 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 59102fb..5d9a0b6 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -44,6 +44,14 @@ config ARM
 config ARM_HAS_SG_CHAIN
 	bool
 
+config NEED_SG_DMA_LENGTH
+	bool
+
+config ARM_DMA_USE_IOMMU
+	select NEED_SG_DMA_LENGTH
+	select ARM_HAS_SG_CHAIN
+	bool
+
 config HAVE_PWM
 	bool
 
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 6e2cb0e..b69c0d3 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -14,6 +14,9 @@ struct dev_archdata {
 #ifdef CONFIG_IOMMU_API
 	void *iommu; /* private IOMMU data */
 #endif
+#ifdef CONFIG_ARM_DMA_USE_IOMMU
+	struct dma_iommu_mapping	*mapping;
+#endif
 };
 
 struct omap_device;
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
new file mode 100644
index 0000000..799b094
--- /dev/null
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -0,0 +1,34 @@
+#ifndef ASMARM_DMA_IOMMU_H
+#define ASMARM_DMA_IOMMU_H
+
+#ifdef __KERNEL__
+
+#include <linux/mm_types.h>
+#include <linux/scatterlist.h>
+#include <linux/dma-debug.h>
+#include <linux/kmemcheck.h>
+
+struct dma_iommu_mapping {
+	/* iommu specific data */
+	struct iommu_domain	*domain;
+
+	void			*bitmap;
+	size_t			bits;
+	unsigned int		order;
+	dma_addr_t		base;
+
+	spinlock_t		lock;
+	struct kref		kref;
+};
+
+struct dma_iommu_mapping *
+arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
+			 int order);
+
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
+
+int arm_iommu_attach_device(struct device *dev,
+					struct dma_iommu_mapping *mapping);
+
+#endif /* __KERNEL__ */
+#endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 4845c09..4163691 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -19,6 +19,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/iommu.h>
 
 #include <asm/memory.h>
 #include <asm/highmem.h>
@@ -26,6 +27,7 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 #include <asm/mach/arch.h>
+#include <asm/dma-iommu.h>
 
 #include "mm.h"
 
@@ -156,6 +158,19 @@ static u64 get_coherent_dma_mask(struct device *dev)
 	return mask;
 }
 
+static void __dma_clear_buffer(struct page *page, size_t size)
+{
+	void *ptr;
+	/*
+	 * Ensure that the allocated pages are zeroed, and that any data
+	 * lurking in the kernel direct-mapped region is invalidated.
+	 */
+	ptr = page_address(page);
+	memset(ptr, 0, size);
+	dmac_flush_range(ptr, ptr + size);
+	outer_flush_range(__pa(ptr), __pa(ptr) + size);
+}
+
 /*
  * Allocate a DMA buffer for 'dev' of size 'size' using the
  * specified gfp mask.  Note that 'size' must be page aligned.
@@ -164,7 +179,6 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 {
 	unsigned long order = get_order(size);
 	struct page *page, *p, *e;
-	void *ptr;
 	u64 mask = get_coherent_dma_mask(dev);
 
 #ifdef CONFIG_DMA_API_DEBUG
@@ -193,14 +207,7 @@ static struct page *__dma_alloc_buffer(struct device *dev, size_t size, gfp_t gf
 	for (p = page + (size >> PAGE_SHIFT), e = page + (1 << order); p < e; p++)
 		__free_page(p);
 
-	/*
-	 * Ensure that the allocated pages are zeroed, and that any data
-	 * lurking in the kernel direct-mapped region is invalidated.
-	 */
-	ptr = page_address(page);
-	memset(ptr, 0, size);
-	dmac_flush_range(ptr, ptr + size);
-	outer_flush_range(__pa(ptr), __pa(ptr) + size);
+	__dma_clear_buffer(page, size);
 
 	return page;
 }
@@ -348,7 +355,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot)
 		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
 
 		pte = consistent_pte[idx] + off;
-		c->vm_pages = page;
+		c->priv = page;
 
 		do {
 			BUG_ON(!pte_none(*pte));
@@ -461,6 +468,14 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	return addr;
 }
 
+static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot)
+{
+	prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
+			    pgprot_writecombine(prot) :
+			    pgprot_dmacoherent(prot);
+	return prot;
+}
+
 /*
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
@@ -468,9 +483,7 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 		    gfp_t gfp, struct dma_attrs *attrs)
 {
-	pgprot_t prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
-			pgprot_writecombine(pgprot_kernel) :
-			pgprot_dmacoherent(pgprot_kernel);
+	pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
 	void *memory;
 
 	if (dma_alloc_from_coherent(dev, size, handle, &memory))
@@ -499,13 +512,14 @@ int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
 	if (c) {
 		unsigned long off = vma->vm_pgoff;
+		struct page *pages = c->priv;
 
 		kern_size = (c->vm_end - c->vm_start) >> PAGE_SHIFT;
 
 		if (off < kern_size &&
 		    user_size <= (kern_size - off)) {
 			ret = remap_pfn_range(vma, vma->vm_start,
-					      page_to_pfn(c->vm_pages) + off,
+					      page_to_pfn(pages) + off,
 					      user_size << PAGE_SHIFT,
 					      vma->vm_page_prot);
 		}
@@ -644,6 +658,9 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 	int i, j;
 
 	for_each_sg(sg, s, nents, i) {
+#ifdef CONFIG_NEED_SG_DMA_LENGTH
+		s->dma_length = s->length;
+#endif
 		s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
 						s->length, dir, attrs);
 		if (dma_mapping_error(dev, s->dma_address))
@@ -749,3 +766,593 @@ static int __init dma_debug_do_init(void)
 	return 0;
 }
 fs_initcall(dma_debug_do_init);
+
+#ifdef CONFIG_ARM_DMA_USE_IOMMU
+
+/* IOMMU */
+
+static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
+				      size_t size)
+{
+	unsigned int order = get_order(size);
+	unsigned int align = 0;
+	unsigned int count, start;
+	unsigned long flags;
+
+	count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
+		 (1 << mapping->order) - 1) >> mapping->order;
+
+	if (order > mapping->order)
+		align = (1 << (order - mapping->order)) - 1;
+
+	spin_lock_irqsave(&mapping->lock, flags);
+	start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits, 0,
+					   count, align);
+	if (start > mapping->bits) {
+		spin_unlock_irqrestore(&mapping->lock, flags);
+		return ~0;
+	}
+
+	bitmap_set(mapping->bitmap, start, count);
+	spin_unlock_irqrestore(&mapping->lock, flags);
+
+	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
+}
+
+static inline void __free_iova(struct dma_iommu_mapping *mapping,
+			       dma_addr_t addr, size_t size)
+{
+	unsigned int start = (addr - mapping->base) >>
+			     (mapping->order + PAGE_SHIFT);
+	unsigned int count = ((size >> PAGE_SHIFT) +
+			      (1 << mapping->order) - 1) >> mapping->order;
+	unsigned long flags;
+
+	spin_lock_irqsave(&mapping->lock, flags);
+	bitmap_clear(mapping->bitmap, start, count);
+	spin_unlock_irqrestore(&mapping->lock, flags);
+}
+
+static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
+{
+	struct page **pages;
+	int count = size >> PAGE_SHIFT;
+	int i=0;
+
+	pages = kzalloc(count * sizeof(struct page*), gfp);
+	if (!pages)
+		return NULL;
+
+	while (count) {
+		int j, order = __ffs(count);
+
+		pages[i] = alloc_pages(gfp | __GFP_NOWARN, order);
+		while (!pages[i] && order)
+			pages[i] = alloc_pages(gfp | __GFP_NOWARN, --order);
+		if (!pages[i])
+			goto error;
+
+		if (order)
+			split_page(pages[i], order);
+		j = 1 << order;
+		while (--j)
+			pages[i + j] = pages[i] + j;
+
+		__dma_clear_buffer(pages[i], PAGE_SIZE << order);
+		i += 1 << order;
+		count -= 1 << order;
+	}
+
+	return pages;
+error:
+	while (--i)
+		if (pages[i])
+			__free_pages(pages[i], 0);
+	kfree(pages);
+	return NULL;
+}
+
+static int __iommu_free_buffer(struct device *dev, struct page **pages, size_t size)
+{
+	int count = size >> PAGE_SHIFT;
+	int i;
+	for (i=0; i< count; i++)
+		if (pages[i])
+			__free_pages(pages[i], 0);
+	kfree(pages);
+	return 0;
+}
+
+static void *
+__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot)
+{
+	struct arm_vmregion *c;
+	size_t align;
+	size_t count = size >> PAGE_SHIFT;
+	int bit;
+
+	if (!consistent_pte[0]) {
+		printk(KERN_ERR "%s: not initialised\n", __func__);
+		dump_stack();
+		return NULL;
+	}
+
+	/*
+	 * Align the virtual region allocation - maximum alignment is
+	 * a section size, minimum is a page size.  This helps reduce
+	 * fragmentation of the DMA space, and also prevents allocations
+	 * smaller than a section from crossing a section boundary.
+	 */
+	bit = fls(size - 1);
+	if (bit > SECTION_SHIFT)
+		bit = SECTION_SHIFT;
+	align = 1 << bit;
+
+	/*
+	 * Allocate a virtual address in the consistent mapping region.
+	 */
+	c = arm_vmregion_alloc(&consistent_head, align, size,
+			    gfp & ~(__GFP_DMA | __GFP_HIGHMEM));
+	if (c) {
+		pte_t *pte;
+		int idx = CONSISTENT_PTE_INDEX(c->vm_start);
+		int i = 0;
+		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
+
+		pte = consistent_pte[idx] + off;
+		c->priv = pages;
+
+		do {
+			BUG_ON(!pte_none(*pte));
+
+			set_pte_ext(pte, mk_pte(pages[i], prot), 0);
+			pte++;
+			off++;
+			i++;
+			if (off >= PTRS_PER_PTE) {
+				off = 0;
+				pte = consistent_pte[++idx];
+			}
+		} while (i < count);
+
+		dsb();
+
+		return (void *)c->vm_start;
+	}
+	return NULL;
+}
+
+static dma_addr_t __iommu_create_mapping(struct device *dev, struct page **pages, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	dma_addr_t dma_addr, iova;
+	int i, ret = ~0;
+
+	dma_addr = __alloc_iova(mapping, size);
+	if (dma_addr == ~0)
+		goto fail;
+
+	iova = dma_addr;
+	for (i=0; i<count; ) {
+		unsigned int phys = page_to_phys(pages[i]);
+		int j = i + 1;
+
+		while (j < count) {
+			if (page_to_phys(pages[j]) != phys + (j - i) * PAGE_SIZE)
+				break;
+			j++;
+		}
+
+		ret = iommu_map(mapping->domain, iova, phys, (j - i) * PAGE_SIZE, 0);
+		if (ret < 0)
+			goto fail;
+		iova += (j - i) * PAGE_SIZE;
+		i = j;
+	}
+
+	return dma_addr;
+fail:
+	return ~0;
+}
+
+static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+	iova &= PAGE_MASK;
+
+	iommu_unmap(mapping->domain, iova, count * PAGE_SIZE);
+
+	__free_iova(mapping, iova, size);
+	return 0;
+}
+
+static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
+	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
+{
+	pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
+	struct page **pages;
+	void *addr = NULL;
+
+	*handle = ~0;
+	size = PAGE_ALIGN(size);
+
+	pages = __iommu_alloc_buffer(dev, size, gfp);
+	if (!pages)
+		return NULL;
+
+	*handle = __iommu_create_mapping(dev, pages, size);
+	if (*handle == ~0)
+		goto err_buffer;
+
+	addr = __iommu_alloc_remap(pages, size, gfp, prot);
+	if (!addr)
+		goto err_mapping;
+
+	return addr;
+
+err_mapping:
+	__iommu_remove_mapping(dev, *handle, size);
+err_buffer:
+	__iommu_free_buffer(dev, pages, size);
+	return NULL;
+}
+
+static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		    struct dma_attrs *attrs)
+{
+	struct arm_vmregion *c;
+
+	vma->vm_page_prot = __get_dma_pgprot(attrs, vma->vm_page_prot);
+	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
+
+	if (c) {
+		struct page **pages = c->priv;
+
+		unsigned long uaddr = vma->vm_start;
+		unsigned long usize = vma->vm_end - vma->vm_start;
+		int i = 0;
+
+		do {
+			int ret;
+
+			ret = vm_insert_page(vma, uaddr, pages[i++]);
+			if (ret) {
+				printk(KERN_ERR "Remapping memory, error: %d\n", ret);
+				return ret;
+			}
+
+			uaddr += PAGE_SIZE;
+			usize -= PAGE_SIZE;
+		} while (usize > 0);
+	}
+	return 0;
+}
+
+/*
+ * free a page as defined by the above mapping.
+ * Must not be called with IRQs disabled.
+ */
+void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+			  dma_addr_t handle, struct dma_attrs *attrs)
+{
+	struct arm_vmregion *c;
+	size = PAGE_ALIGN(size);
+
+	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
+	if (c) {
+		struct page **pages = c->priv;
+		__dma_free_remap(cpu_addr, size);
+		__iommu_remove_mapping(dev, handle, size);
+		__iommu_free_buffer(dev, pages, size);
+	}
+}
+
+static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
+			  size_t size, dma_addr_t *handle,
+			  enum dma_data_direction dir)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t iova, iova_base;
+	int ret = 0;
+	unsigned int count;
+	struct scatterlist *s;
+
+	size = PAGE_ALIGN(size);
+	*handle = ~0;
+
+	iova_base = iova = __alloc_iova(mapping, size);
+	if (iova == ~0)
+		return -ENOMEM;
+
+	for (count = 0, s = sg; count < (size >> PAGE_SHIFT); s = sg_next(s))
+	{
+		phys_addr_t phys = page_to_phys(sg_page(s));
+		unsigned int len = PAGE_ALIGN(s->offset + s->length);
+
+		if (!arch_is_coherent())
+			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
+
+		ret = iommu_map(mapping->domain, iova, phys, len, 0);
+		if (ret < 0)
+			goto fail;
+		count += len >> PAGE_SHIFT;
+		iova += len;
+	}
+	*handle = iova_base;
+
+	return 0;
+fail:
+	iommu_unmap(mapping->domain, iova_base, count * PAGE_SIZE);
+	__free_iova(mapping, iova_base, size);
+	return ret;
+}
+
+int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
+		     enum dma_data_direction dir, struct dma_attrs *attrs)
+{
+	struct scatterlist *s = sg, *dma = sg, *start = sg;
+	int i, count = 0;
+	unsigned int offset = s->offset;
+	unsigned int size = s->offset + s->length;
+	unsigned int max = dma_get_max_seg_size(dev);
+
+	s->dma_address = ~0;
+	s->dma_length = 0;
+
+	for (i = 1; i < nents; i++) {
+		s->dma_address = ~0;
+		s->dma_length = 0;
+
+		s = sg_next(s);
+
+		if (s->offset || (size & ~PAGE_MASK) || size + s->length > max) {
+			if (__map_sg_chunk(dev, start, size, &dma->dma_address,
+			    dir) < 0)
+				goto bad_mapping;
+
+			dma->dma_address += offset;
+			dma->dma_length = size - offset;
+
+			size = offset = s->offset;
+			start = s;
+			dma = sg_next(dma);
+			count += 1;
+		}
+		size += s->length;
+	}
+	if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) < 0)
+		goto bad_mapping;
+
+	dma->dma_address += offset;
+	dma->dma_length = size - offset;
+
+	return count+1;
+
+bad_mapping:
+	for_each_sg(sg, s, count, i)
+		__iommu_remove_mapping(dev, sg_dma_address(s), sg_dma_len(s));
+	return 0;
+}
+
+void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
+			enum dma_data_direction dir, struct dma_attrs *attrs)
+{
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nents, i) {
+		if (sg_dma_len(s))
+			__iommu_remove_mapping(dev, sg_dma_address(s),
+					       sg_dma_len(s));
+		if (!arch_is_coherent())
+			__dma_page_dev_to_cpu(sg_page(s), s->offset,
+					      s->length, dir);
+	}
+}
+
+
+/**
+ * dma_sync_sg_for_cpu
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @sg: list of buffers
+ * @nents: number of buffers to map (returned from dma_map_sg)
+ * @dir: DMA transfer direction (same as was passed to dma_map_sg)
+ */
+void arm_iommu_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+			int nents, enum dma_data_direction dir)
+{
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nents, i)
+		if (!arch_is_coherent())
+			__dma_page_dev_to_cpu(sg_page(s), s->offset, s->length, dir);
+
+}
+
+/**
+ * dma_sync_sg_for_device
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @sg: list of buffers
+ * @nents: number of buffers to map (returned from dma_map_sg)
+ * @dir: DMA transfer direction (same as was passed to dma_map_sg)
+ */
+void arm_iommu_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+			int nents, enum dma_data_direction dir)
+{
+	struct scatterlist *s;
+	int i;
+
+	for_each_sg(sg, s, nents, i)
+		if (!arch_is_coherent())
+			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
+}
+
+static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size, enum dma_data_direction dir,
+	     struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t dma_addr, iova;
+	unsigned int phys;
+	int ret, len = PAGE_ALIGN(size + offset);
+
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(page, offset, size, dir);
+
+	dma_addr = iova = __alloc_iova(mapping, len);
+	if (iova == ~0)
+		goto fail;
+
+	dma_addr += offset;
+	phys = page_to_phys(page);
+	ret = iommu_map(mapping->domain, iova, phys, size, 0);
+	if (ret < 0)
+		goto fail;
+
+	return dma_addr;
+fail:
+	return ~0;
+}
+
+static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t iova = handle & PAGE_MASK;
+	struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
+	int offset = handle & ~PAGE_MASK;
+
+	if (!iova)
+		return;
+
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(page, offset, size, dir);
+
+	iommu_unmap(mapping->domain, iova, size);
+	__free_iova(mapping, iova, size);
+}
+
+static void arm_iommu_sync_single_for_cpu(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t iova = handle & PAGE_MASK;
+	struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
+	unsigned int offset = handle & ~PAGE_MASK;
+
+	if (!iova)
+		return;
+
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(page, offset, size, dir);
+}
+
+static void arm_iommu_sync_single_for_device(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t iova = handle & PAGE_MASK;
+	struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
+	unsigned int offset = handle & ~PAGE_MASK;
+
+	if (!iova)
+		return;
+
+	__dma_page_cpu_to_dev(page, offset, size, dir);
+}
+
+struct dma_map_ops iommu_ops = {
+	.alloc		= arm_iommu_alloc_attrs,
+	.free		= arm_iommu_free_attrs,
+	.mmap		= arm_iommu_mmap_attrs,
+
+	.map_page		= arm_iommu_map_page,
+	.unmap_page		= arm_iommu_unmap_page,
+	.sync_single_for_cpu	= arm_iommu_sync_single_for_cpu,
+	.sync_single_for_device	= arm_iommu_sync_single_for_device,
+
+	.map_sg			= arm_iommu_map_sg,
+	.unmap_sg		= arm_iommu_unmap_sg,
+	.sync_sg_for_cpu	= arm_iommu_sync_sg_for_cpu,
+	.sync_sg_for_device	= arm_iommu_sync_sg_for_device,
+};
+
+struct dma_iommu_mapping *
+arm_iommu_create_mapping(struct bus_type *bus, dma_addr_t base, size_t size,
+			 int order)
+{
+	unsigned int count = (size >> PAGE_SHIFT) - order;
+	unsigned int bitmap_size = BITS_TO_LONGS(count) * sizeof(long);
+	struct dma_iommu_mapping *mapping;
+	int err = -ENOMEM;
+
+	mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
+	if (!mapping)
+		goto err;
+
+	mapping->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (!mapping->bitmap)
+		goto err2;
+
+	mapping->base = base;
+	mapping->bits = bitmap_size;
+	mapping->order = order;
+	spin_lock_init(&mapping->lock);
+
+	mapping->domain = iommu_domain_alloc(bus);
+	if (!mapping->domain)
+		goto err3;
+
+	kref_init(&mapping->kref);
+	return mapping;
+err3:
+	kfree(mapping->bitmap);
+err2:
+	kfree(mapping);
+err:
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL(arm_iommu_create_mapping);
+
+static void release_iommu_mapping(struct kref *kref)
+{
+	struct dma_iommu_mapping *mapping =
+		container_of(kref, struct dma_iommu_mapping, kref);
+
+	iommu_domain_free(mapping->domain);
+	kfree(mapping->bitmap);
+	kfree(mapping);
+}
+
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
+{
+	if (mapping)
+		kref_put(&mapping->kref, release_iommu_mapping);
+}
+EXPORT_SYMBOL(arm_iommu_release_mapping);
+
+int arm_iommu_attach_device(struct device *dev,
+			    struct dma_iommu_mapping *mapping)
+{
+	int err;
+
+	err = iommu_attach_device(mapping->domain, dev);
+	if (err)
+		return err;
+
+	kref_get(&mapping->kref);
+	dev->archdata.mapping = mapping;
+	set_dma_ops(dev, &iommu_ops);
+
+	printk(KERN_INFO "Attached IOMMU controller to %s device.\n", dev_name(dev));
+	return 0;
+}
+EXPORT_SYMBOL(arm_iommu_attach_device);
+
+#endif
diff --git a/arch/arm/mm/vmregion.h b/arch/arm/mm/vmregion.h
index 15e9f04..6bbc402 100644
--- a/arch/arm/mm/vmregion.h
+++ b/arch/arm/mm/vmregion.h
@@ -17,7 +17,7 @@ struct arm_vmregion {
 	struct list_head	vm_list;
 	unsigned long		vm_start;
 	unsigned long		vm_end;
-	struct page		*vm_pages;
+	void			*priv;
 	int			vm_active;
 };
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
