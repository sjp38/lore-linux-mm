Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 436396B0022
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:35:30 -0400 (EDT)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LLQ000BHQF2YZ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 25 May 2011 08:35:27 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LLQ003PYQF1K7@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 25 May 2011 08:35:25 +0100 (BST)
Date: Wed, 25 May 2011 09:35:19 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC 1/2] ARM: Move dma related inlines into arm_dma_ops methods
In-reply-to: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1306308920-8602-2-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

This is initial step in ARM DMA-mapping redesign. All calls have
been moved into separate methods from arm_dma_ops structure that
can be set separately for particular device's.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/include/asm/device.h      |    1 +
 arch/arm/include/asm/dma-mapping.h |  653 +++++++++++++-----------------------
 arch/arm/mm/dma-mapping.c          |  491 ++++++++++++++++++++++++----
 arch/arm/mm/vmregion.h             |    2 +-
 include/linux/dma-attrs.h          |    1 +
 5 files changed, 674 insertions(+), 474 deletions(-)

diff --git a/arch/arm/include/asm/device.h b/arch/arm/include/asm/device.h
index 9f390ce..005791a 100644
--- a/arch/arm/include/asm/device.h
+++ b/arch/arm/include/asm/device.h
@@ -7,6 +7,7 @@
 #define ASMARM_DEVICE_H
 
 struct dev_archdata {
+	struct arm_dma_map_ops	*dma_ops;
 #ifdef CONFIG_DMABOUNCE
 	struct dmabounce_device_info *dmabounce;
 #endif
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 4fff837..42f4625 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -6,155 +6,219 @@
 #include <linux/mm_types.h>
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
+#include <linux/kmemcheck.h>
 
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
-#ifdef __arch_page_to_dma
-#error Please update to __arch_pfn_to_dma
-#endif
-
-/*
- * dma_to_pfn/pfn_to_dma/dma_to_virt/virt_to_dma are architecture private
- * functions used internally by the DMA-mapping API to provide DMA
- * addresses. They must not be used by drivers.
- */
-#ifndef __arch_pfn_to_dma
-static inline dma_addr_t pfn_to_dma(struct device *dev, unsigned long pfn)
+#define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
+
+struct arm_dma_map_ops {
+	void *(*alloc_attrs)(struct device *, size_t, dma_addr_t *, gfp_t,
+		struct dma_attrs *attrs);
+	void (*free_attrs)(struct device *, size_t, void *, dma_addr_t,
+		struct dma_attrs *attrs);
+	int (*mmap_attrs)(struct device *, struct vm_area_struct *,
+                void *, dma_addr_t, size_t, struct dma_attrs *attrs);
+
+	/* map single and map page might be merged together */
+	dma_addr_t (*map_single)(struct device *dev, void *cpu_addr,
+                size_t size, enum dma_data_direction dir);
+	void (*unmap_single)(struct device *dev, dma_addr_t handle,
+                size_t size, enum dma_data_direction dir);
+	dma_addr_t (*map_page)(struct device *dev, struct page *page,
+             unsigned long offset, size_t size, enum dma_data_direction dir);
+	void (*unmap_page)(struct device *dev, dma_addr_t handle,
+                size_t size, enum dma_data_direction dir);
+
+	int (*map_sg)(struct device *, struct scatterlist *, int,
+                enum dma_data_direction);
+	void (*unmap_sg)(struct device *, struct scatterlist *, int,
+                enum dma_data_direction);
+
+	void (*sync_single_for_device)(struct device *dev,
+                dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir);
+	void (*sync_single_for_cpu)(struct device *dev,
+                dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir);
+
+	void (*sync_sg_for_cpu)(struct device *, struct scatterlist *, int,
+                enum dma_data_direction);
+	void (*sync_sg_for_device)(struct device *, struct scatterlist *, int,
+                enum dma_data_direction);
+
+};
+
+extern struct arm_dma_map_ops dma_ops;
+
+static inline struct arm_dma_map_ops *get_dma_ops(struct device *dev)
 {
-	return (dma_addr_t)__pfn_to_bus(pfn);
+	if (dev->archdata.dma_ops)
+		return dev->archdata.dma_ops;
+	return &dma_ops;
 }
 
-static inline unsigned long dma_to_pfn(struct device *dev, dma_addr_t addr)
+static inline void set_dma_ops(struct device *dev, struct arm_dma_map_ops *ops)
 {
-	return __bus_to_pfn(addr);
+	dev->archdata.dma_ops = ops;
 }
 
-static inline void *dma_to_virt(struct device *dev, dma_addr_t addr)
-{
-	return (void *)__bus_to_virt(addr);
-}
+/********************************/
 
-static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
+static inline void *dma_alloc_coherent(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag)
 {
-	return (dma_addr_t)__virt_to_bus((unsigned long)(addr));
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+
+	BUG_ON(!ops);
+
+	cpu_addr = ops->alloc_attrs(dev, size, dma_handle, flag, NULL);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
+	return cpu_addr;
 }
-#else
-static inline dma_addr_t pfn_to_dma(struct device *dev, unsigned long pfn)
+
+static inline void dma_free_coherent(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle)
 {
-	return __arch_pfn_to_dma(dev, pfn);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!ops);
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free_attrs(dev, size, cpu_addr, dma_handle, NULL);
 }
 
-static inline unsigned long dma_to_pfn(struct device *dev, dma_addr_t addr)
+static inline void *dma_alloc_writecombine(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag)
 {
-	return __arch_dma_to_pfn(dev, addr);
+	DEFINE_DMA_ATTRS(attrs);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	BUG_ON(!ops);
+
+	cpu_addr = ops->alloc_attrs(dev, size, dma_handle, flag, &attrs);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
+	return cpu_addr;
 }
 
-static inline void *dma_to_virt(struct device *dev, dma_addr_t addr)
+static inline void dma_free_writecombine(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle)
 {
-	return __arch_dma_to_virt(dev, addr);
+	DEFINE_DMA_ATTRS(attrs);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+
+	BUG_ON(!ops);
+
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
 }
 
-static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
+static inline dma_addr_t dma_map_single(struct device *dev, void *ptr,
+					      size_t size,
+					      enum dma_data_direction dir)
 {
-	return __arch_virt_to_dma(dev, addr);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	dma_addr_t addr;
+
+	kmemcheck_mark_initialized(ptr, size);
+	BUG_ON(!valid_dma_direction(dir));
+	addr = ops->map_single(dev, ptr, size, dir);
+	debug_dma_map_page(dev, virt_to_page(ptr),
+			   (unsigned long)ptr & ~PAGE_MASK, size,
+			   dir, addr, true);
+	return addr;
 }
-#endif
 
-/*
- * The DMA API is built upon the notion of "buffer ownership".  A buffer
- * is either exclusively owned by the CPU (and therefore may be accessed
- * by it) or exclusively owned by the DMA device.  These helper functions
- * represent the transitions between these two ownership states.
- *
- * Note, however, that on later ARMs, this notion does not work due to
- * speculative prefetches.  We model our approach on the assumption that
- * the CPU does do speculative prefetches, which means we clean caches
- * before transfers and delay cache invalidation until transfer completion.
- *
- * Private support functions: these are not part of the API and are
- * liable to change.  Drivers must not use these.
- */
-static inline void __dma_single_cpu_to_dev(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
+static inline void dma_unmap_single(struct device *dev, dma_addr_t addr,
+					  size_t size,
+					  enum dma_data_direction dir)
 {
-	extern void ___dma_single_cpu_to_dev(const void *, size_t,
-		enum dma_data_direction);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
-	if (!arch_is_coherent())
-		___dma_single_cpu_to_dev(kaddr, size, dir);
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->unmap_single)
+		ops->unmap_single(dev, addr, size, dir);
+	debug_dma_unmap_page(dev, addr, size, dir, true);
 }
 
-static inline void __dma_single_dev_to_cpu(const void *kaddr, size_t size,
-	enum dma_data_direction dir)
+static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
+				      size_t offset, size_t size,
+				      enum dma_data_direction dir)
 {
-	extern void ___dma_single_dev_to_cpu(const void *, size_t,
-		enum dma_data_direction);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	dma_addr_t addr;
+
+	kmemcheck_mark_initialized(page_address(page) + offset, size);
+	BUG_ON(!valid_dma_direction(dir));
+	addr = ops->map_page(dev, page, offset, size, dir);
+	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
 
-	if (!arch_is_coherent())
-		___dma_single_dev_to_cpu(kaddr, size, dir);
+	return addr;
 }
 
-static inline void __dma_page_cpu_to_dev(struct page *page, unsigned long off,
-	size_t size, enum dma_data_direction dir)
+static inline void dma_unmap_page(struct device *dev, dma_addr_t addr,
+				  size_t size, enum dma_data_direction dir)
 {
-	extern void ___dma_page_cpu_to_dev(struct page *, unsigned long,
-		size_t, enum dma_data_direction);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
-	if (!arch_is_coherent())
-		___dma_page_cpu_to_dev(page, off, size, dir);
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->unmap_page)
+		ops->unmap_page(dev, addr, size, dir);
+	debug_dma_unmap_page(dev, addr, size, dir, false);
 }
 
-static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
-	size_t size, enum dma_data_direction dir)
+static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
+					   size_t size,
+					   enum dma_data_direction dir)
 {
-	extern void ___dma_page_dev_to_cpu(struct page *, unsigned long,
-		size_t, enum dma_data_direction);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
-	if (!arch_is_coherent())
-		___dma_page_dev_to_cpu(page, off, size, dir);
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_cpu)
+		ops->sync_single_for_cpu(dev, addr, 0, size, dir);
+	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
 }
 
-/*
- * Return whether the given device DMA address mask can be supported
- * properly.  For example, if your device can only drive the low 24-bits
- * during bus mastering, then you would pass 0x00ffffff as the mask
- * to this function.
- *
- * FIXME: This should really be a platform specific issue - we should
- * return false if GFP_DMA allocations may not satisfy the supplied 'mask'.
- */
-static inline int dma_supported(struct device *dev, u64 mask)
+static inline void dma_sync_single_for_device(struct device *dev,
+					      dma_addr_t addr, size_t size,
+					      enum dma_data_direction dir)
 {
-	if (mask < ISA_DMA_THRESHOLD)
-		return 0;
-	return 1;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_device)
+		ops->sync_single_for_device(dev, addr, 0, size, dir);
+	debug_dma_sync_single_for_device(dev, addr, size, dir);
 }
 
-static inline int dma_set_mask(struct device *dev, u64 dma_mask)
+static inline void dma_sync_single_range_for_cpu(struct device *dev, dma_addr_t addr,
+					   unsigned long offset, size_t size,
+					   enum dma_data_direction dir)
 {
-#ifdef CONFIG_DMABOUNCE
-	if (dev->archdata.dmabounce) {
-		if (dma_mask >= ISA_DMA_THRESHOLD)
-			return 0;
-		else
-			return -EIO;
-	}
-#endif
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
-	*dev->dma_mask = dma_mask;
-
-	return 0;
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_cpu)
+		ops->sync_single_for_cpu(dev, addr, offset, size, dir);
+	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
 }
 
-/*
- * DMA errors are defined by all-bits-set in the DMA address.
- */
-static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+static inline void dma_sync_single_range_for_device(struct device *dev,
+					      dma_addr_t addr,
+					      unsigned long offset, size_t size,
+					      enum dma_data_direction dir)
 {
-	return dma_addr == ~0;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_single_for_device)
+		ops->sync_single_for_device(dev, addr, offset, size, dir);
+	debug_dma_sync_single_for_device(dev, addr, size, dir);
 }
 
 /*
@@ -172,358 +236,117 @@ static inline void dma_free_noncoherent(struct device *dev, size_t size,
 {
 }
 
-/**
- * dma_alloc_coherent - allocate consistent memory for DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @size: required memory size
- * @handle: bus-specific DMA address
- *
- * Allocate some uncached, unbuffered memory for a device for
- * performing DMA.  This function allocates pages, and will
- * return the CPU-viewed address, and sets @handle to be the
- * device-viewed address.
- */
-extern void *dma_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
-
-/**
- * dma_free_coherent - free memory allocated by dma_alloc_coherent
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @size: size of memory originally requested in dma_alloc_coherent
- * @cpu_addr: CPU-view address returned from dma_alloc_coherent
- * @handle: device-view address returned from dma_alloc_coherent
- *
- * Free (and unmap) a DMA buffer previously allocated by
- * dma_alloc_coherent().
- *
- * References to memory and mappings associated with cpu_addr/handle
- * during and after this call executing are illegal.
- */
-extern void dma_free_coherent(struct device *, size_t, void *, dma_addr_t);
-
-/**
- * dma_mmap_coherent - map a coherent DMA allocation into user space
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @vma: vm_area_struct describing requested user mapping
- * @cpu_addr: kernel CPU-view address returned from dma_alloc_coherent
- * @handle: device-view address returned from dma_alloc_coherent
- * @size: size of memory originally requested in dma_alloc_coherent
- *
- * Map a coherent DMA buffer previously allocated by dma_alloc_coherent
- * into user space.  The coherent DMA buffer must not be freed by the
- * driver until the user space mapping has been released.
- */
-int dma_mmap_coherent(struct device *, struct vm_area_struct *,
-		void *, dma_addr_t, size_t);
-
-
-/**
- * dma_alloc_writecombine - allocate writecombining memory for DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @size: required memory size
- * @handle: bus-specific DMA address
- *
- * Allocate some uncached, buffered memory for a device for
- * performing DMA.  This function allocates pages, and will
- * return the CPU-viewed address, and sets @handle to be the
- * device-viewed address.
- */
-extern void *dma_alloc_writecombine(struct device *, size_t, dma_addr_t *,
-		gfp_t);
-
-#define dma_free_writecombine(dev,size,cpu_addr,handle) \
-	dma_free_coherent(dev,size,cpu_addr,handle)
-
-int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
-		void *, dma_addr_t, size_t);
-
-
-#ifdef CONFIG_DMABOUNCE
-/*
- * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
- * and utilize bounce buffers as needed to work around limited DMA windows.
- *
- * On the SA-1111, a bug limits DMA to only certain regions of RAM.
- * On the IXP425, the PCI inbound window is 64MB (256MB total RAM)
- * On some ADI engineering systems, PCI inbound window is 32MB (12MB total RAM)
- *
- * The following are helper functions used by the dmabounce subystem
- *
- */
-
-/**
- * dmabounce_register_dev
- *
- * @dev: valid struct device pointer
- * @small_buf_size: size of buffers to use with small buffer pool
- * @large_buf_size: size of buffers to use with large buffer pool (can be 0)
- *
- * This function should be called by low-level platform code to register
- * a device as requireing DMA buffer bouncing. The function will allocate
- * appropriate DMA pools for the device.
- *
- */
-extern int dmabounce_register_dev(struct device *, unsigned long,
-		unsigned long);
-
-/**
- * dmabounce_unregister_dev
- *
- * @dev: valid struct device pointer
- *
- * This function should be called by low-level platform code when device
- * that was previously registered with dmabounce_register_dev is removed
- * from the system.
- *
- */
-extern void dmabounce_unregister_dev(struct device *);
-
-/**
- * dma_needs_bounce
- *
- * @dev: valid struct device pointer
- * @dma_handle: dma_handle of unbounced buffer
- * @size: size of region being mapped
- *
- * Platforms that utilize the dmabounce mechanism must implement
- * this function.
- *
- * The dmabounce routines call this function whenever a dma-mapping
- * is requested to determine whether a given buffer needs to be bounced
- * or not. The function must return 0 if the buffer is OK for
- * DMA access and 1 if the buffer needs to be bounced.
- *
- */
-extern int dma_needs_bounce(struct device*, dma_addr_t, size_t);
-
-/*
- * The DMA API, implemented by dmabounce.c.  See below for descriptions.
- */
-extern dma_addr_t __dma_map_single(struct device *, void *, size_t,
-		enum dma_data_direction);
-extern void __dma_unmap_single(struct device *, dma_addr_t, size_t,
-		enum dma_data_direction);
-extern dma_addr_t __dma_map_page(struct device *, struct page *,
-		unsigned long, size_t, enum dma_data_direction);
-extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
-		enum dma_data_direction);
-
-/*
- * Private functions
- */
-int dmabounce_sync_for_cpu(struct device *, dma_addr_t, unsigned long,
-		size_t, enum dma_data_direction);
-int dmabounce_sync_for_device(struct device *, dma_addr_t, unsigned long,
-		size_t, enum dma_data_direction);
-#else
-static inline int dmabounce_sync_for_cpu(struct device *d, dma_addr_t addr,
-	unsigned long offset, size_t size, enum dma_data_direction dir)
+static inline int dma_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
+		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
 {
-	return 1;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	return ops->mmap_attrs(dev, vma, cpu_addr, dma_addr, size, NULL);
 }
 
-static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
-	unsigned long offset, size_t size, enum dma_data_direction dir)
+static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
+		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
 {
-	return 1;
+	DEFINE_DMA_ATTRS(attrs);
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	return ops->mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);
 }
 
-
-static inline dma_addr_t __dma_map_single(struct device *dev, void *cpu_addr,
-		size_t size, enum dma_data_direction dir)
+static inline int dma_map_sg(struct device *dev, struct scatterlist *sg,
+				   int nents, enum dma_data_direction dir)
 {
-	__dma_single_cpu_to_dev(cpu_addr, size, dir);
-	return virt_to_dma(dev, cpu_addr);
-}
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+	int i, ents;
+	struct scatterlist *s;
 
-static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
-	     unsigned long offset, size_t size, enum dma_data_direction dir)
-{
-	__dma_page_cpu_to_dev(page, offset, size, dir);
-	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
-}
+	for_each_sg(sg, s, nents, i)
+		kmemcheck_mark_initialized(sg_virt(s), s->length);
+	BUG_ON(!valid_dma_direction(dir));
+	ents = ops->map_sg(dev, sg, nents, dir);
+	debug_dma_map_sg(dev, sg, nents, ents, dir);
 
-static inline void __dma_unmap_single(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
+	return ents;
 }
 
-static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
+static inline void dma_unmap_sg(struct device *dev, struct scatterlist *sg,
+				      int nents, enum dma_data_direction dir)
 {
-	__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
-		handle & ~PAGE_MASK, size, dir);
-}
-#endif /* CONFIG_DMABOUNCE */
-
-/**
- * dma_map_single - map a single buffer for streaming DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @cpu_addr: CPU direct mapped address of buffer
- * @size: size of buffer to map
- * @dir: DMA transfer direction
- *
- * Ensure that any data held in the cache is appropriately discarded
- * or written back.
- *
- * The device owns this memory once this call has completed.  The CPU
- * can regain ownership by calling dma_unmap_single() or
- * dma_sync_single_for_cpu().
- */
-static inline dma_addr_t dma_map_single(struct device *dev, void *cpu_addr,
-		size_t size, enum dma_data_direction dir)
-{
-	dma_addr_t addr;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(dir));
-
-	addr = __dma_map_single(dev, cpu_addr, size, dir);
-	debug_dma_map_page(dev, virt_to_page(cpu_addr),
-			(unsigned long)cpu_addr & ~PAGE_MASK, size,
-			dir, addr, true);
-
-	return addr;
+	debug_dma_unmap_sg(dev, sg, nents, dir);
+	if (ops->unmap_sg)
+		ops->unmap_sg(dev, sg, nents, dir);
 }
 
-/**
- * dma_map_page - map a portion of a page for streaming DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @page: page that buffer resides in
- * @offset: offset into page for start of buffer
- * @size: size of buffer to map
- * @dir: DMA transfer direction
- *
- * Ensure that any data held in the cache is appropriately discarded
- * or written back.
- *
- * The device owns this memory once this call has completed.  The CPU
- * can regain ownership by calling dma_unmap_page().
- */
-static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
-	     unsigned long offset, size_t size, enum dma_data_direction dir)
+static inline void
+dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+		    int nelems, enum dma_data_direction dir)
 {
-	dma_addr_t addr;
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
 
 	BUG_ON(!valid_dma_direction(dir));
-
-	addr = __dma_map_page(dev, page, offset, size, dir);
-	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
-
-	return addr;
+	if (ops->sync_sg_for_cpu)
+		ops->sync_sg_for_cpu(dev, sg, nelems, dir);
+	debug_dma_sync_sg_for_cpu(dev, sg, nelems, dir);
 }
 
-/**
- * dma_unmap_single - unmap a single buffer previously mapped
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_single)
- * @dir: DMA transfer direction (same as passed to dma_map_single)
- *
- * Unmap a single streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_single() call.
- * All other usages are undefined.
- *
- * After this call, reads by the CPU to the buffer are guaranteed to see
- * whatever the device wrote there.
- */
-static inline void dma_unmap_single(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
+static inline void
+dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+		       int nelems, enum dma_data_direction dir)
 {
-	debug_dma_unmap_page(dev, handle, size, dir, true);
-	__dma_unmap_single(dev, handle, size, dir);
-}
+	struct arm_dma_map_ops *ops = get_dma_ops(dev);
+
+	BUG_ON(!valid_dma_direction(dir));
+	if (ops->sync_sg_for_device)
+		ops->sync_sg_for_device(dev, sg, nelems, dir);
+	debug_dma_sync_sg_for_device(dev, sg, nelems, dir);
 
-/**
- * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @size: size of buffer (same as passed to dma_map_page)
- * @dir: DMA transfer direction (same as passed to dma_map_page)
- *
- * Unmap a page streaming mode DMA translation.  The handle and size
- * must match what was provided in the previous dma_map_page() call.
- * All other usages are undefined.
- *
- * After this call, reads by the CPU to the buffer are guaranteed to see
- * whatever the device wrote there.
- */
-static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
-		size_t size, enum dma_data_direction dir)
-{
-	debug_dma_unmap_page(dev, handle, size, dir, false);
-	__dma_unmap_page(dev, handle, size, dir);
 }
 
-/**
- * dma_sync_single_range_for_cpu
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @handle: DMA address of buffer
- * @offset: offset of region to start sync
- * @size: size of region to sync
- * @dir: DMA transfer direction (same as passed to dma_map_single)
- *
- * Make physical memory consistent for a single streaming mode DMA
- * translation after a transfer.
+/********************************/
+
+/*
+ * Return whether the given device DMA address mask can be supported
+ * properly.  For example, if your device can only drive the low 24-bits
+ * during bus mastering, then you would pass 0x00ffffff as the mask
+ * to this function.
  *
- * If you perform a dma_map_single() but wish to interrogate the
- * buffer using the cpu, yet do not wish to teardown the PCI dma
- * mapping, you must call this function before doing so.  At the
- * next point you give the PCI dma address back to the card, you
- * must first the perform a dma_sync_for_device, and then the
- * device again owns the buffer.
+ * FIXME: This should really be a platform specific issue - we should
+ * return false if GFP_DMA allocations may not satisfy the supplied 'mask'.
  */
-static inline void dma_sync_single_range_for_cpu(struct device *dev,
-		dma_addr_t handle, unsigned long offset, size_t size,
-		enum dma_data_direction dir)
+static inline int dma_supported(struct device *dev, u64 mask)
 {
-	BUG_ON(!valid_dma_direction(dir));
-
-	debug_dma_sync_single_for_cpu(dev, handle + offset, size, dir);
-
-	if (!dmabounce_sync_for_cpu(dev, handle, offset, size, dir))
-		return;
-
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle) + offset, size, dir);
+	if (mask < ISA_DMA_THRESHOLD)
+		return 0;
+	return 1;
 }
 
-static inline void dma_sync_single_range_for_device(struct device *dev,
-		dma_addr_t handle, unsigned long offset, size_t size,
-		enum dma_data_direction dir)
+static inline int dma_set_mask(struct device *dev, u64 dma_mask)
 {
-	BUG_ON(!valid_dma_direction(dir));
-
-	debug_dma_sync_single_for_device(dev, handle + offset, size, dir);
-
-	if (!dmabounce_sync_for_device(dev, handle, offset, size, dir))
-		return;
-
-	__dma_single_cpu_to_dev(dma_to_virt(dev, handle) + offset, size, dir);
-}
+#ifdef CONFIG_DMABOUNCE
+	if (dev->archdata.dmabounce) {
+		if (dma_mask >= ISA_DMA_THRESHOLD)
+			return 0;
+		else
+			return -EIO;
+	}
+#endif
+	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
+		return -EIO;
 
-static inline void dma_sync_single_for_cpu(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_cpu(dev, handle, 0, size, dir);
-}
+	*dev->dma_mask = dma_mask;
 
-static inline void dma_sync_single_for_device(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_device(dev, handle, 0, size, dir);
+	return 0;
 }
 
 /*
- * The scatter list versions of the above methods.
+ * DMA errors are defined by all-bits-set in the DMA address.
  */
-extern int dma_map_sg(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-extern void dma_unmap_sg(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-extern void dma_sync_sg_for_cpu(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-extern void dma_sync_sg_for_device(struct device *, struct scatterlist *, int,
-		enum dma_data_direction);
-
+static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr == ~0;
+}
 
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 82a093c..f8c6972 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -18,6 +18,7 @@
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
 #include <linux/highmem.h>
+#include <linux/slab.h>
 
 #include <asm/memory.h>
 #include <asm/highmem.h>
@@ -25,6 +26,389 @@
 #include <asm/tlbflush.h>
 #include <asm/sizes.h>
 
+#ifdef __arch_page_to_dma
+#error Please update to __arch_pfn_to_dma
+#endif
+
+/*
+ * dma_to_pfn/pfn_to_dma/dma_to_virt/virt_to_dma are architecture private
+ * functions used internally by the DMA-mapping API to provide DMA
+ * addresses. They must not be used by drivers.
+ */
+#ifndef __arch_pfn_to_dma
+static inline dma_addr_t pfn_to_dma(struct device *dev, unsigned long pfn)
+{
+	return (dma_addr_t)__pfn_to_bus(pfn);
+}
+
+static inline unsigned long dma_to_pfn(struct device *dev, dma_addr_t addr)
+{
+	return __bus_to_pfn(addr);
+}
+
+static inline void *dma_to_virt(struct device *dev, dma_addr_t addr)
+{
+	return (void *)__bus_to_virt(addr);
+}
+
+static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
+{
+	return (dma_addr_t)__virt_to_bus((unsigned long)(addr));
+}
+#else
+static inline dma_addr_t pfn_to_dma(struct device *dev, unsigned long pfn)
+{
+	return __arch_pfn_to_dma(dev, pfn);
+}
+
+static inline unsigned long dma_to_pfn(struct device *dev, dma_addr_t addr)
+{
+	return __arch_dma_to_pfn(dev, addr);
+}
+
+static inline void *dma_to_virt(struct device *dev, dma_addr_t addr)
+{
+	return __arch_dma_to_virt(dev, addr);
+}
+
+static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
+{
+	return __arch_virt_to_dma(dev, addr);
+}
+#endif
+
+/*
+ * The DMA API is built upon the notion of "buffer ownership".  A buffer
+ * is either exclusively owned by the CPU (and therefore may be accessed
+ * by it) or exclusively owned by the DMA device.  These helper functions
+ * represent the transitions between these two ownership states.
+ *
+ * Note, however, that on later ARMs, this notion does not work due to
+ * speculative prefetches.  We model our approach on the assumption that
+ * the CPU does do speculative prefetches, which means we clean caches
+ * before transfers and delay cache invalidation until transfer completion.
+ *
+ * Private support functions: these are not part of the API and are
+ * liable to change.  Drivers must not use these.
+ */
+static inline void __dma_single_cpu_to_dev(const void *kaddr, size_t size,
+	enum dma_data_direction dir)
+{
+	extern void ___dma_single_cpu_to_dev(const void *, size_t,
+		enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_single_cpu_to_dev(kaddr, size, dir);
+}
+
+static inline void __dma_single_dev_to_cpu(const void *kaddr, size_t size,
+	enum dma_data_direction dir)
+{
+	extern void ___dma_single_dev_to_cpu(const void *, size_t,
+		enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_single_dev_to_cpu(kaddr, size, dir);
+}
+
+static inline void __dma_page_cpu_to_dev(struct page *page, unsigned long off,
+	size_t size, enum dma_data_direction dir)
+{
+	extern void ___dma_page_cpu_to_dev(struct page *, unsigned long,
+		size_t, enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_page_cpu_to_dev(page, off, size, dir);
+}
+
+static inline void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
+	size_t size, enum dma_data_direction dir)
+{
+	extern void ___dma_page_dev_to_cpu(struct page *, unsigned long,
+		size_t, enum dma_data_direction);
+
+	if (!arch_is_coherent())
+		___dma_page_dev_to_cpu(page, off, size, dir);
+}
+
+
+#ifdef CONFIG_DMABOUNCE
+/*
+ * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
+ * and utilize bounce buffers as needed to work around limited DMA windows.
+ *
+ * On the SA-1111, a bug limits DMA to only certain regions of RAM.
+ * On the IXP425, the PCI inbound window is 64MB (256MB total RAM)
+ * On some ADI engineering systems, PCI inbound window is 32MB (12MB total RAM)
+ *
+ * The following are helper functions used by the dmabounce subystem
+ *
+ */
+
+/**
+ * dmabounce_register_dev
+ *
+ * @dev: valid struct device pointer
+ * @small_buf_size: size of buffers to use with small buffer pool
+ * @large_buf_size: size of buffers to use with large buffer pool (can be 0)
+ *
+ * This function should be called by low-level platform code to register
+ * a device as requireing DMA buffer bouncing. The function will allocate
+ * appropriate DMA pools for the device.
+ *
+ */
+extern int dmabounce_register_dev(struct device *, unsigned long,
+		unsigned long);
+
+/**
+ * dmabounce_unregister_dev
+ *
+ * @dev: valid struct device pointer
+ *
+ * This function should be called by low-level platform code when device
+ * that was previously registered with dmabounce_register_dev is removed
+ * from the system.
+ *
+ */
+extern void dmabounce_unregister_dev(struct device *);
+
+/**
+ * dma_needs_bounce
+ *
+ * @dev: valid struct device pointer
+ * @dma_handle: dma_handle of unbounced buffer
+ * @size: size of region being mapped
+ *
+ * Platforms that utilize the dmabounce mechanism must implement
+ * this function.
+ *
+ * The dmabounce routines call this function whenever a dma-mapping
+ * is requested to determine whether a given buffer needs to be bounced
+ * or not. The function must return 0 if the buffer is OK for
+ * DMA access and 1 if the buffer needs to be bounced.
+ *
+ */
+extern int dma_needs_bounce(struct device*, dma_addr_t, size_t);
+
+/*
+ * The DMA API, implemented by dmabounce.c.  See below for descriptions.
+ */
+extern dma_addr_t __dma_map_single(struct device *, void *, size_t,
+		enum dma_data_direction);
+extern void __dma_unmap_single(struct device *, dma_addr_t, size_t,
+		enum dma_data_direction);
+extern dma_addr_t __dma_map_page(struct device *, struct page *,
+		unsigned long, size_t, enum dma_data_direction);
+extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
+		enum dma_data_direction);
+
+/*
+ * Private functions
+ */
+int dmabounce_sync_for_cpu(struct device *, dma_addr_t, unsigned long,
+		size_t, enum dma_data_direction);
+int dmabounce_sync_for_device(struct device *, dma_addr_t, unsigned long,
+		size_t, enum dma_data_direction);
+#else
+static inline int dmabounce_sync_for_cpu(struct device *d, dma_addr_t addr,
+	unsigned long offset, size_t size, enum dma_data_direction dir)
+{
+	return 1;
+}
+
+static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
+	unsigned long offset, size_t size, enum dma_data_direction dir)
+{
+	return 1;
+}
+
+
+static inline dma_addr_t __dma_map_single(struct device *dev, void *cpu_addr,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_single_cpu_to_dev(cpu_addr, size, dir);
+	return virt_to_dma(dev, cpu_addr);
+}
+
+static inline dma_addr_t __dma_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size, enum dma_data_direction dir)
+{
+	__dma_page_cpu_to_dev(page, offset, size, dir);
+	return pfn_to_dma(dev, page_to_pfn(page)) + offset;
+}
+
+static inline void __dma_unmap_single(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
+}
+
+static inline void __dma_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir)
+{
+	__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
+		handle & ~PAGE_MASK, size, dir);
+}
+#endif /* CONFIG_DMABOUNCE */
+
+/**
+ * dma_map_single - map a single buffer for streaming DMA
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @cpu_addr: CPU direct mapped address of buffer
+ * @size: size of buffer to map
+ * @dir: DMA transfer direction
+ *
+ * Ensure that any data held in the cache is appropriately discarded
+ * or written back.
+ *
+ * The device owns this memory once this call has completed.  The CPU
+ * can regain ownership by calling dma_unmap_single() or
+ * dma_sync_single_for_cpu().
+ */
+static inline dma_addr_t arm_dma_map_single(struct device *dev, void *cpu_addr,
+		size_t size, enum dma_data_direction dir)
+{
+	dma_addr_t addr;
+
+	BUG_ON(!valid_dma_direction(dir));
+
+	addr = __dma_map_single(dev, cpu_addr, size, dir);
+	debug_dma_map_page(dev, virt_to_page(cpu_addr),
+			(unsigned long)cpu_addr & ~PAGE_MASK, size,
+			dir, addr, true);
+
+	return addr;
+}
+
+/**
+ * dma_map_page - map a portion of a page for streaming DMA
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @page: page that buffer resides in
+ * @offset: offset into page for start of buffer
+ * @size: size of buffer to map
+ * @dir: DMA transfer direction
+ *
+ * Ensure that any data held in the cache is appropriately discarded
+ * or written back.
+ *
+ * The device owns this memory once this call has completed.  The CPU
+ * can regain ownership by calling dma_unmap_page().
+ */
+static inline dma_addr_t arm_dma_map_page(struct device *dev, struct page *page,
+	     unsigned long offset, size_t size, enum dma_data_direction dir)
+{
+	dma_addr_t addr;
+
+	BUG_ON(!valid_dma_direction(dir));
+
+	addr = __dma_map_page(dev, page, offset, size, dir);
+	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
+
+	return addr;
+}
+
+/**
+ * dma_unmap_single - unmap a single buffer previously mapped
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @handle: DMA address of buffer
+ * @size: size of buffer (same as passed to dma_map_single)
+ * @dir: DMA transfer direction (same as passed to dma_map_single)
+ *
+ * Unmap a single streaming mode DMA translation.  The handle and size
+ * must match what was provided in the previous dma_map_single() call.
+ * All other usages are undefined.
+ *
+ * After this call, reads by the CPU to the buffer are guaranteed to see
+ * whatever the device wrote there.
+ */
+static inline void arm_dma_unmap_single(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir)
+{
+	debug_dma_unmap_page(dev, handle, size, dir, true);
+	__dma_unmap_single(dev, handle, size, dir);
+}
+
+/**
+ * dma_unmap_page - unmap a buffer previously mapped through dma_map_page()
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @handle: DMA address of buffer
+ * @size: size of buffer (same as passed to dma_map_page)
+ * @dir: DMA transfer direction (same as passed to dma_map_page)
+ *
+ * Unmap a page streaming mode DMA translation.  The handle and size
+ * must match what was provided in the previous dma_map_page() call.
+ * All other usages are undefined.
+ *
+ * After this call, reads by the CPU to the buffer are guaranteed to see
+ * whatever the device wrote there.
+ */
+static inline void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir)
+{
+	debug_dma_unmap_page(dev, handle, size, dir, false);
+	__dma_unmap_page(dev, handle, size, dir);
+}
+
+/**
+ * dma_sync_single_range_for_cpu
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @handle: DMA address of buffer
+ * @offset: offset of region to start sync
+ * @size: size of region to sync
+ * @dir: DMA transfer direction (same as passed to dma_map_single)
+ *
+ * Make physical memory consistent for a single streaming mode DMA
+ * translation after a transfer.
+ *
+ * If you perform a dma_map_single() but wish to interrogate the
+ * buffer using the cpu, yet do not wish to teardown the PCI dma
+ * mapping, you must call this function before doing so.  At the
+ * next point you give the PCI dma address back to the card, you
+ * must first the perform a dma_sync_for_device, and then the
+ * device again owns the buffer.
+ */
+static inline void arm_dma_sync_single_range_for_cpu(struct device *dev,
+		dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
+{
+	BUG_ON(!valid_dma_direction(dir));
+
+	debug_dma_sync_single_for_cpu(dev, handle + offset, size, dir);
+
+	if (!dmabounce_sync_for_cpu(dev, handle, offset, size, dir))
+		return;
+
+	__dma_single_dev_to_cpu(dma_to_virt(dev, handle) + offset, size, dir);
+}
+
+static inline void arm_dma_sync_single_range_for_device(struct device *dev,
+		dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
+{
+	BUG_ON(!valid_dma_direction(dir));
+
+	debug_dma_sync_single_for_device(dev, handle + offset, size, dir);
+
+	if (!dmabounce_sync_for_device(dev, handle, offset, size, dir))
+		return;
+
+	__dma_single_cpu_to_dev(dma_to_virt(dev, handle) + offset, size, dir);
+}
+
+static inline void arm_dma_sync_single_for_cpu(struct device *dev,
+		dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
+{
+	dma_sync_single_range_for_cpu(dev, handle, offset, size, dir);
+}
+
+static inline void arm_dma_sync_single_for_device(struct device *dev,
+		dma_addr_t handle, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
+{
+	dma_sync_single_range_for_device(dev, handle, offset, size, dir);
+}
+
 static u64 get_coherent_dma_mask(struct device *dev)
 {
 	u64 mask = ISA_DMA_THRESHOLD;
@@ -224,7 +608,7 @@ __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot)
 		u32 off = CONSISTENT_OFFSET(c->vm_start) & (PTRS_PER_PTE-1);
 
 		pte = consistent_pte[idx] + off;
-		c->vm_pages = page;
+		c->priv = page;
 
 		do {
 			BUG_ON(!pte_none(*pte));
@@ -330,39 +714,36 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
  */
-void *
-dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp)
+void *arm_dma_alloc_attrs(struct device *dev, size_t size, dma_addr_t *handle,
+			  gfp_t gfp, struct dma_attrs *attrs)
 {
 	void *memory;
 
-	if (dma_alloc_from_coherent(dev, size, handle, &memory))
-		return memory;
-
-	return __dma_alloc(dev, size, handle, gfp,
-			   pgprot_dmacoherent(pgprot_kernel));
-}
-EXPORT_SYMBOL(dma_alloc_coherent);
-
-/*
- * Allocate a writecombining region, in much the same way as
- * dma_alloc_coherent above.
- */
-void *
-dma_alloc_writecombine(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp)
-{
-	return __dma_alloc(dev, size, handle, gfp,
+	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs)) {
+		return __dma_alloc(dev, size, handle, gfp,
 			   pgprot_writecombine(pgprot_kernel));
+	} else {
+		if (dma_alloc_from_coherent(dev, size, handle, &memory))
+			return memory;
+		return __dma_alloc(dev, size, handle, gfp,
+			   pgprot_dmacoherent(pgprot_kernel));
+	}
 }
-EXPORT_SYMBOL(dma_alloc_writecombine);
 
-static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
-		    void *cpu_addr, dma_addr_t dma_addr, size_t size)
+static int arm_dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		    struct dma_attrs *attrs)
 {
-	int ret = -ENXIO;
-#ifdef CONFIG_MMU
 	unsigned long user_size, kern_size;
 	struct arm_vmregion *c;
+	int ret = -ENXIO;
+
+	if (dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs))
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+	else
+		vma->vm_page_prot = pgprot_dmacoherent(vma->vm_page_prot);
 
+#ifdef CONFIG_MMU
 	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 
 	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
@@ -373,8 +754,9 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 
 		if (off < kern_size &&
 		    user_size <= (kern_size - off)) {
+			struct page *vm_pages = c->priv;
 			ret = remap_pfn_range(vma, vma->vm_start,
-					      page_to_pfn(c->vm_pages) + off,
+					      page_to_pfn(vm_pages) + off,
 					      user_size << PAGE_SHIFT,
 					      vma->vm_page_prot);
 		}
@@ -384,27 +766,12 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 	return ret;
 }
 
-int dma_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
-		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
-{
-	vma->vm_page_prot = pgprot_dmacoherent(vma->vm_page_prot);
-	return dma_mmap(dev, vma, cpu_addr, dma_addr, size);
-}
-EXPORT_SYMBOL(dma_mmap_coherent);
-
-int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
-			  void *cpu_addr, dma_addr_t dma_addr, size_t size)
-{
-	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
-	return dma_mmap(dev, vma, cpu_addr, dma_addr, size);
-}
-EXPORT_SYMBOL(dma_mmap_writecombine);
-
 /*
  * free a page as defined by the above mapping.
  * Must not be called with IRQs disabled.
  */
-void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
+void arm_dma_free_attrs(struct device *dev, size_t size, void *cpu_addr,
+			dma_addr_t handle, struct dma_attrs *attrs)
 {
 	WARN_ON(irqs_disabled());
 
@@ -418,7 +785,6 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
 
 	__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
 }
-EXPORT_SYMBOL(dma_free_coherent);
 
 /*
  * Make an area consistent for devices.
@@ -443,7 +809,6 @@ void ___dma_single_cpu_to_dev(const void *kaddr, size_t size,
 	}
 	/* FIXME: non-speculating: flush on bidirectional mappings? */
 }
-EXPORT_SYMBOL(___dma_single_cpu_to_dev);
 
 void ___dma_single_dev_to_cpu(const void *kaddr, size_t size,
 	enum dma_data_direction dir)
@@ -459,7 +824,6 @@ void ___dma_single_dev_to_cpu(const void *kaddr, size_t size,
 
 	dmac_unmap_area(kaddr, size, dir);
 }
-EXPORT_SYMBOL(___dma_single_dev_to_cpu);
 
 static void dma_cache_maint_page(struct page *page, unsigned long offset,
 	size_t size, enum dma_data_direction dir,
@@ -520,7 +884,6 @@ void ___dma_page_cpu_to_dev(struct page *page, unsigned long off,
 	}
 	/* FIXME: non-speculating: flush on bidirectional mappings? */
 }
-EXPORT_SYMBOL(___dma_page_cpu_to_dev);
 
 void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	size_t size, enum dma_data_direction dir)
@@ -540,10 +903,9 @@ void ___dma_page_dev_to_cpu(struct page *page, unsigned long off,
 	if (dir != DMA_TO_DEVICE && off == 0 && size >= PAGE_SIZE)
 		set_bit(PG_dcache_clean, &page->flags);
 }
-EXPORT_SYMBOL(___dma_page_dev_to_cpu);
 
 /**
- * dma_map_sg - map a set of SG buffers for streaming mode DMA
+ * arm_dma_map_sg - map a set of SG buffers for streaming mode DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @sg: list of buffers
  * @nents: number of buffers to map
@@ -558,7 +920,7 @@ EXPORT_SYMBOL(___dma_page_dev_to_cpu);
  * Device ownership issues as mentioned for dma_map_single are the same
  * here.
  */
-int dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
+static int arm_dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 		enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -580,10 +942,9 @@ int dma_map_sg(struct device *dev, struct scatterlist *sg, int nents,
 		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
 	return 0;
 }
-EXPORT_SYMBOL(dma_map_sg);
 
 /**
- * dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
+ * arm_dma_unmap_sg - unmap a set of SG buffers mapped by dma_map_sg
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @sg: list of buffers
  * @nents: number of buffers to unmap (same as was passed to dma_map_sg)
@@ -592,7 +953,7 @@ EXPORT_SYMBOL(dma_map_sg);
  * Unmap a set of streaming mode DMA translations.  Again, CPU access
  * rules concerning calls here are the same as for dma_unmap_single().
  */
-void dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
+static void arm_dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
 		enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -603,7 +964,6 @@ void dma_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
 	for_each_sg(sg, s, nents, i)
 		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
 }
-EXPORT_SYMBOL(dma_unmap_sg);
 
 /**
  * dma_sync_sg_for_cpu
@@ -612,7 +972,7 @@ EXPORT_SYMBOL(dma_unmap_sg);
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
+static void arm_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -629,16 +989,15 @@ void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 
 	debug_dma_sync_sg_for_cpu(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_cpu);
 
 /**
- * dma_sync_sg_for_device
+ * arm_dma_sync_sg_for_device
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @sg: list of buffers
  * @nents: number of buffers to map (returned from dma_map_sg)
  * @dir: DMA transfer direction (same as was passed to dma_map_sg)
  */
-void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
+static void arm_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 			int nents, enum dma_data_direction dir)
 {
 	struct scatterlist *s;
@@ -655,7 +1014,23 @@ void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 
 	debug_dma_sync_sg_for_device(dev, sg, nents, dir);
 }
-EXPORT_SYMBOL(dma_sync_sg_for_device);
+
+struct arm_dma_map_ops dma_ops = {
+	.alloc_attrs = arm_dma_alloc_attrs,
+	.free_attrs = arm_dma_free_attrs,
+	.map_single = arm_dma_map_single,
+	.unmap_single = arm_dma_unmap_single,
+	.map_page = arm_dma_map_page,
+	.unmap_page = arm_dma_unmap_page,
+	.map_sg = arm_dma_map_sg,
+	.unmap_sg = arm_dma_unmap_sg,
+	.sync_single_for_device = arm_dma_sync_single_for_device,
+	.sync_single_for_cpu = arm_dma_sync_single_for_cpu,
+	.sync_sg_for_cpu = arm_dma_sync_sg_for_cpu,
+	.sync_sg_for_device = arm_dma_sync_sg_for_device,
+	.mmap_attrs = arm_dma_mmap_attrs,
+};
+EXPORT_SYMBOL_GPL(dma_ops);
 
 #define PREALLOC_DMA_DEBUG_ENTRIES	4096
 
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
 
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index 71ad34e..ada61e1 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -13,6 +13,7 @@
 enum dma_attr {
 	DMA_ATTR_WRITE_BARRIER,
 	DMA_ATTR_WEAK_ORDERING,
+	DMA_ATTR_WRITE_COMBINE,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
