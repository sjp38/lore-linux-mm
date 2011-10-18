Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 592B26B0035
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 13:19:47 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LT9002IOUSVLT@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 18 Oct 2011 18:19:43 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT900B4SUSU7I@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:43 +0100 (BST)
Date: Tue, 18 Oct 2011 19:19:25 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 8/8] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1318958365-19120-9-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

This patch add a complete implementation of DMA-mapping API for
devices that have IOMMU support. All DMA-mapping calls are supported.

This patch contains some of the code kindly provided by Krishna Reddy
<vdumpa@nvidia.com>.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                 |    8 +
 arch/arm/include/asm/device.h    |    4 +
 arch/arm/include/asm/dma-iommu.h |   35 +++
 arch/arm/mm/dma-mapping.c        |  606 +++++++++++++++++++++++++++++++++++++-
 arch/arm/mm/vmregion.h           |    2 +-
 5 files changed, 650 insertions(+), 5 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index f9d01e0..3caf6ec 100644
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
index d3b35d8..bd34378 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -11,6 +11,10 @@ struct dev_archdata {
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
+#ifdef CONFIG_ARM_DMA_USE_IOMMU
+	void				*iommu_priv;
+	struct dma_iommu_mapping	*mapping;
+#endif
 };
 
 struct pdev_archdata {
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
new file mode 100644
index 0000000..a038c83
--- /dev/null
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -0,0 +1,35 @@
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
+#include <asm/memory.h>
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
+struct dma_iommu_mapping *arm_iommu_create_mapping(dma_addr_t base,
+					size_t size, int order);
+
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
+
+int arm_iommu_attach_device(struct device *dev,
+					struct dma_iommu_mapping *mapping);
+
+#endif /* __KERNEL__ */
+#endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index eaa7260..f7bde4f 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -31,6 +31,9 @@
 #include <asm/mach/map.h>
 #include <asm/dma-contiguous.h>
 
+#include <linux/iommu.h>
+#include <asm/dma-iommu.h>
+
 #include "mm.h"
 
 /*
@@ -263,8 +266,10 @@ static int __init consistent_init(void)
 	unsigned long base = consistent_base;
 	unsigned long num_ptes = (CONSISTENT_END - base) >> PGDIR_SHIFT;
 
+#ifndef CONFIG_ARM_DMA_USE_IOMMU
 	if (cpu_architecture() >= CPU_ARCH_ARMv6)
 		return 0;
+#endif
 
 	consistent_pte = kmalloc(num_ptes * sizeof(pte_t), GFP_KERNEL);
 	if (!consistent_pte) {
@@ -437,7 +442,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot)
 		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
 
 		pte = consistent_pte[idx] + off;
-		c->vm_pages = page;
+		c->priv = page;
 
 		do {
 			BUG_ON(!pte_none(*pte));
@@ -686,6 +691,14 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
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
@@ -693,9 +706,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 		    gfp_t gfp, struct dma_attrs *attrs)
 {
-	pgprot_t prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
-			pgprot_writecombine(pgprot_kernel) :
-			pgprot_dmacoherent(pgprot_kernel);
+	pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);
 	void *memory;
 
 	if (dma_alloc_from_coherent(dev, size, handle, &memory))
@@ -866,6 +877,9 @@ int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 	int i, j;
 
 	for_each_sg(sg, s, nents, i) {
+#ifdef CONFIG_NEED_SG_DMA_LENGTH
+		s->dma_length = s->length;
+#endif
 		s->dma_address = ops->map_page(dev, sg_page(s), s->offset,
 						s->length, dir, attrs);
 		if (dma_mapping_error(dev, s->dma_address))
@@ -971,3 +985,587 @@ static int __init dma_debug_do_init(void)
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
+	int i;
+
+	pages = kzalloc(count * sizeof(struct page*), gfp);
+	if (!pages)
+		return NULL;
+
+	for (i=0; i<count; i++) {
+		pages[i] = alloc_page(gfp);
+		if (!pages[i])
+			goto error;
+
+		__dma_clear_buffer(pages[i], PAGE_SIZE);
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
+	if (dma_addr == 0)
+		goto fail;
+
+	iova = dma_addr;
+	for (i=0; i<count; i++) {
+		unsigned int phys = page_to_phys(pages[i]);
+		ret = iommu_map(mapping->domain, iova, phys, 0, 0);
+		if (ret < 0)
+			goto fail;
+		iova += PAGE_SIZE;
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
+	int i;
+
+	iova &= PAGE_MASK;
+
+	for (i=0; i<count; i++)
+		iommu_unmap(mapping->domain, iova + (i << PAGE_SHIFT), 0);
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
+	dma_addr_t iova;
+	int ret = 0;
+	unsigned int count, i;
+	struct scatterlist *s;
+
+	size = PAGE_ALIGN(size);
+	*handle = ~0;
+
+	iova = __alloc_iova(mapping, size);
+	if (iova == 0)
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
+		for (i = 0; i < (len >> PAGE_SHIFT); i++)
+		{
+			ret = iommu_map(mapping->domain,
+					iova + (count << PAGE_SHIFT),
+					phys + (i << PAGE_SHIFT), 0, 0);
+			if (ret < 0)
+				goto fail;
+			count++;
+		}
+	}
+	*handle = iova;
+
+	return 0;
+fail:
+	while (count--)
+		iommu_unmap(mapping->domain, iova + count * PAGE_SIZE, 0);
+	__iommu_remove_mapping(dev, iova, size);
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
+	if (iova == 0)
+		goto fail;
+
+	dma_addr += offset;
+	phys = page_to_phys(page);
+
+	while (len > 0) {
+		ret = iommu_map(mapping->domain, iova, phys, 0, 0);
+		if (ret < 0)
+			goto fail;
+		iova += PAGE_SIZE;
+		phys += PAGE_SIZE;
+		len -= PAGE_SIZE;
+	}
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
+	int offset = handle & ~PAGE_MASK, len = offset + size;
+
+	if (!iova)
+		return;
+
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(page, offset, size, dir);
+
+	while (len > 0) {
+		iommu_unmap(mapping->domain, iova, 0);
+		iova += PAGE_SIZE;
+		len -= PAGE_SIZE;
+	}
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
+struct dma_iommu_mapping *arm_iommu_create_mapping(dma_addr_t base,
+						   size_t size, int order)
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
+	mapping->domain = iommu_domain_alloc();
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
