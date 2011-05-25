Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C23D46B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:35:30 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LLQ003ABQF2F6@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 25 May 2011 08:35:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LLQ00EMHQF0G5@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 25 May 2011 08:35:25 +0100 (BST)
Date: Wed, 25 May 2011 09:35:20 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC 2/2] ARM: initial proof-of-concept IOMMU mapper for DMA-mapping
In-reply-to: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1306308920-8602-3-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Add initial proof of concept implementation of DMA-mapping API for
devices that have IOMMU support. Right now only dma_alloc_coherent,
dma_free_coherent and dma_mmap_coherent functions are supported.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/Kconfig                 |    1 +
 arch/arm/include/asm/device.h    |    2 +
 arch/arm/include/asm/dma-iommu.h |   30 ++++
 arch/arm/mm/dma-mapping.c        |  326 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 359 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 377a7a5..61900f1 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -8,6 +8,8 @@ config ARM
 	select RTC_LIB
 	select SYS_SUPPORTS_APM_EMULATION
 	select GENERIC_ATOMIC64 if (CPU_V6 || !CPU_32v6K || !AEABI)
+	select GENERIC_ALLOCATOR
+	select HAVE_DMA_ATTRS
 	select HAVE_OPROFILE if (HAVE_PERF_EVENTS)
 	select HAVE_ARCH_KGDB
 	select HAVE_KPROBES if (!XIP_KERNEL && !THUMB2_KERNEL)
diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 005791a..d3ec1e9 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -11,6 +11,8 @@ struct dev_archdata {
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
+	void				*iommu_priv;
+	struct dma_iommu_mapping	*mapping;
 };
 
 struct pdev_archdata {
diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
new file mode 100644
index 0000000..c246ff3
--- /dev/null
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -0,0 +1,30 @@
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
+	/* address space data */
+	struct gen_pool		*pool;
+
+	dma_addr_t		base;
+	size_t			size;
+
+	atomic_t		ref_count;
+	struct mutex		lock;
+};
+
+int __init arm_iommu_assign_device(struct device *dev, dma_addr_t base, dma_addr_t size);
+
+#endif /* __KERNEL__ */
+#endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f8c6972..b6397c1 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -19,6 +19,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
+#include <linux/genalloc.h>
 
 #include <asm/memory.h>
 #include <asm/highmem.h>
@@ -26,6 +27,9 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 
+#include <linux/iommu.h>
+#include <asm/dma-iommu.h>
+
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
@@ -1040,3 +1044,325 @@ static int __init dma_debug_do_init(void)
 	return 0;
 }
 fs_initcall(dma_debug_do_init);
+
+
+/* IOMMU */
+
+/*
+ * Allocate a DMA buffer for 'dev' of size 'size' using the
+ * specified gfp mask.  Note that 'size' must be page aligned.
+ */
+static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
+{
+	struct page **pages;
+	int count = size >> PAGE_SHIFT;
+	void *ptr;
+	int i;
+
+	pages = kzalloc(count * sizeof(struct page*), gfp);
+	if (!pages)
+		return NULL;
+
+	printk("IOMMU: page table allocated\n");
+
+	for (i=0; i<count; i++) {
+		pages[i] = alloc_page(gfp); //alloc_pages(gfp, 0);
+
+		if (!pages[i])
+			goto error;
+
+		/*
+		 * Ensure that the allocated pages are zeroed, and that any data
+		 * lurking in the kernel direct-mapped region is invalidated.
+		 */
+		ptr = page_address(pages[i]);
+		memset(ptr, 0, PAGE_SIZE);
+		dmac_flush_range(ptr, ptr + PAGE_SIZE);
+		outer_flush_range(__pa(ptr), __pa(ptr) + PAGE_SIZE);
+	}
+	printk("IOMMU: pages allocated\n");
+	return pages;
+error:
+	printk("IOMMU: error allocating pages\n");
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
+	unsigned int count = size >> PAGE_SHIFT;
+	dma_addr_t dma_addr, iova;
+	int i, ret = 0;
+
+	printk("IOMMU: mapping %p\n", mapping);
+
+	iova = gen_pool_alloc(mapping->pool, size);
+
+	printk("IOMMU: gen_alloc res %x\n", iova);
+
+	if (iova == 0)
+		goto fail;
+
+	dma_addr = iova;
+
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
+	return 0;
+}
+
+static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	unsigned int count = size >> PAGE_SHIFT;
+	int i;
+
+	gen_pool_free(mapping->pool, iova, size);
+
+	for (i=0; i<count; i++) {
+		iommu_unmap(mapping->domain, iova, 0);
+		iova += PAGE_SIZE;
+	}
+	return 0;
+}
+
+int arm_iommu_init(struct device *dev);
+
+static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
+	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	struct page **pages;
+	void *addr = NULL;
+	pgprot_t prot;
+
+	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+		prot = pgprot_writecombine(pgprot_kernel);
+	else
+		prot = pgprot_dmacoherent(pgprot_kernel);
+
+	arm_iommu_init(dev);
+
+	mutex_lock(&mapping->lock);
+
+	*handle = ~0;
+	size = PAGE_ALIGN(size);
+
+	printk("IOMMU: requested size %d\n", size);
+
+	pages = __iommu_alloc_buffer(dev, size, gfp);
+	if (!pages)
+		return NULL;
+
+	printk("IOMMU: allocated pages: %p\n", pages);
+
+	*handle = __iommu_create_mapping(dev, pages, size);
+
+	printk("IOMMU: created iova: %08x\n", *handle);
+
+	if (!*handle)
+		goto err_buffer;
+
+	addr = __iommu_alloc_remap(pages, size, gfp, prot);
+	if (!addr)
+		goto err_iommu;
+
+	printk("IOMMU: allocated iova %08x, virt %p\n", *handle, addr);
+
+err_iommu:
+err_buffer:
+	mutex_unlock(&mapping->lock);
+	return addr;
+}
+
+static int arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		    struct dma_attrs *attrs)
+{
+	unsigned long user_size;
+	struct arm_vmregion *c;
+
+	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+	else
+		vma->vm_page_prot = pgprot_dmacoherent(vma->vm_page_prot);
+
+	printk("IOMMU: mmap virt %p, dma %08x, size %d\n", cpu_addr, dma_addr, size);
+
+	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+
+	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
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
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	struct arm_vmregion *c;
+	size = PAGE_ALIGN(size);
+
+	mutex_lock(&mapping->lock);
+	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
+	if (c) {
+		struct page **pages = c->priv;
+		__dma_free_remap(cpu_addr, size);
+		__iommu_remove_mapping(dev, handle, size);
+		__iommu_free_buffer(dev, pages, size);
+	}
+	mutex_unlock(&mapping->lock);
+}
+
+struct arm_dma_map_ops iommu_ops = {
+	.alloc_attrs = arm_iommu_alloc_attrs,
+	.free_attrs = arm_iommu_free_attrs,
+	.mmap_attrs = arm_iommu_mmap_attrs,
+};
+EXPORT_SYMBOL_GPL(iommu_ops);
+
+int arm_iommu_init(struct device *dev)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+
+	if (mapping->pool)
+		return 0;
+
+	mutex_init(&mapping->lock);
+
+	mapping->pool = gen_pool_create(16, -1);
+	if (!mapping->pool)
+		return -ENOMEM;
+
+	if (gen_pool_add(mapping->pool, mapping->base, mapping->size, -1) != 0)
+		return -ENOMEM;
+
+	mapping->domain = iommu_domain_alloc();
+	if (!mapping->domain)
+		return -ENOMEM;
+
+	if (iommu_attach_device(mapping->domain, dev) != 0)
+		return -ENOMEM;
+
+	return 0;
+}
+
+int __init arm_iommu_assign_device(struct device *dev, dma_addr_t base, dma_addr_t size)
+{
+	struct dma_iommu_mapping *mapping;
+	mapping = kzalloc(sizeof(struct dma_iommu_mapping), GFP_KERNEL);
+	if (!mapping)
+		return -ENOMEM;
+	mapping->base = base;
+	mapping->size = size;
+
+	dev->archdata.mapping = mapping;
+	set_dma_ops(dev, &iommu_ops);
+	printk(KERN_INFO "Assigned IOMMU device to %s\n", dev_name(dev));
+
+	return 0;
+}
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
