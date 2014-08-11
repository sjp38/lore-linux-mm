Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 05D2D6B0039
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 19:40:42 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so10637894iec.31
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 16:40:42 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id s2si21892848igg.15.2014.08.11.16.40.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Aug 2014 16:40:41 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv7 3/5] common: dma-mapping: Introduce common remapping functions
Date: Mon, 11 Aug 2014 16:40:29 -0700
Message-Id: <1407800431-21566-4-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>
References: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Riley <davidriley@chromium.org>, linux-arm-kernel@lists.infradead.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>


For architectures without coherent DMA, memory for DMA may
need to be remapped with coherent attributes. Factor out
the the remapping code from arm and put it in a
common location to reduce code duplication.

As part of this, the arm APIs are now migrated away from
ioremap_page_range to the common APIs which use map_vm_area for remapping.
This should be an equivalent change and using map_vm_area is more
correct as ioremap_page_range is intended to bring in io addresses
into the cpu space and not regular kernel managed memory.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 arch/arm/mm/dma-mapping.c                | 57 +++++---------------------
 drivers/base/dma-mapping.c               | 68 ++++++++++++++++++++++++++++++++
 include/asm-generic/dma-mapping-common.h |  9 +++++
 3 files changed, 86 insertions(+), 48 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 4c88935..f5190ac 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -297,37 +297,19 @@ static void *
 __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
 	const void *caller)
 {
-	struct vm_struct *area;
-	unsigned long addr;
-
 	/*
 	 * DMA allocation can be mapped to user space, so lets
 	 * set VM_USERMAP flags too.
 	 */
-	area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
-				  caller);
-	if (!area)
-		return NULL;
-	addr = (unsigned long)area->addr;
-	area->phys_addr = __pfn_to_phys(page_to_pfn(page));
-
-	if (ioremap_page_range(addr, addr + size, area->phys_addr, prot)) {
-		vunmap((void *)addr);
-		return NULL;
-	}
-	return (void *)addr;
+	return dma_common_contiguous_remap(page, size,
+			VM_ARM_DMA_CONSISTENT | VM_USERMAP,
+			prot, caller);
 }
 
 static void __dma_free_remap(void *cpu_addr, size_t size)
 {
-	unsigned int flags = VM_ARM_DMA_CONSISTENT | VM_USERMAP;
-	struct vm_struct *area = find_vm_area(cpu_addr);
-	if (!area || (area->flags & flags) != flags) {
-		WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
-		return;
-	}
-	unmap_kernel_range((unsigned long)cpu_addr, size);
-	vunmap(cpu_addr);
+	dma_common_free_remap(cpu_addr, size,
+			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
 }
 
 #define DEFAULT_DMA_COHERENT_POOL_SIZE	SZ_256K
@@ -1261,29 +1243,8 @@ static void *
 __iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgprot_t prot,
 		    const void *caller)
 {
-	unsigned int i, nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	struct vm_struct *area;
-	unsigned long p;
-
-	area = get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_USERMAP,
-				  caller);
-	if (!area)
-		return NULL;
-
-	area->pages = pages;
-	area->nr_pages = nr_pages;
-	p = (unsigned long)area->addr;
-
-	for (i = 0; i < nr_pages; i++) {
-		phys_addr_t phys = __pfn_to_phys(page_to_pfn(pages[i]));
-		if (ioremap_page_range(p, p + PAGE_SIZE, phys, prot))
-			goto err;
-		p += PAGE_SIZE;
-	}
-	return area->addr;
-err:
-	unmap_kernel_range((unsigned long)area->addr, size);
-	vunmap(area->addr);
+	return dma_common_pages_remap(pages, size,
+			VM_ARM_DMA_CONSISTENT | VM_USERMAP, prot, caller);
 	return NULL;
 }
 
@@ -1491,8 +1452,8 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 	}
 
 	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs)) {
-		unmap_kernel_range((unsigned long)cpu_addr, size);
-		vunmap(cpu_addr);
+		dma_common_free_remap(cpu_addr, size,
+			VM_ARM_DMA_CONSISTENT | VM_USERMAP);
 	}
 
 	__iommu_remove_mapping(dev, handle, size);
diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 6cd08e1..1bc46df 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -10,6 +10,8 @@
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <asm-generic/dma-coherent.h>
 
 /*
@@ -267,3 +269,69 @@ int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 	return ret;
 }
 EXPORT_SYMBOL(dma_common_mmap);
+
+/*
+ * remaps an allocated contiguous region into another vm_area.
+ * Cannot be used in non-sleeping contexts
+ */
+
+void *dma_common_contiguous_remap(struct page *page, size_t size,
+			unsigned long vm_flags,
+			pgprot_t prot, const void *caller)
+{
+	int i;
+	struct page **pages;
+	void *ptr;
+	unsigned long pfn;
+
+	pages = kmalloc(sizeof(struct page *) << get_order(size), GFP_KERNEL);
+	if (!pages)
+		return NULL;
+
+	for (i = 0, pfn = page_to_pfn(page); i < (size >> PAGE_SHIFT); i++)
+		pages[i] = pfn_to_page(pfn + i);
+
+	ptr = dma_common_pages_remap(pages, size, vm_flags, prot, caller);
+
+	kfree(pages);
+
+	return ptr;
+}
+
+/*
+ * remaps an array of PAGE_SIZE pages into another vm_area
+ * Cannot be used in non-sleeping contexts
+ */
+void *dma_common_pages_remap(struct page **pages, size_t size,
+			unsigned long vm_flags, pgprot_t prot,
+			const void *caller)
+{
+	struct vm_struct *area;
+
+	area = get_vm_area_caller(size, vm_flags, caller);
+	if (!area)
+		return NULL;
+
+	if (map_vm_area(area, prot, pages)) {
+		vunmap(area->addr);
+		return NULL;
+	}
+
+	return area->addr;
+}
+
+/*
+ * unmaps a range previously mapped by dma_common_*_remap
+ */
+void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags)
+{
+	struct vm_struct *area = find_vm_area(cpu_addr);
+
+	if (!area || (area->flags & vm_flags) != vm_flags) {
+		WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
+		return;
+	}
+
+	unmap_kernel_range((unsigned long)cpu_addr, size);
+	vunmap(cpu_addr);
+}
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index de8bf89..a9fd248 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -179,6 +179,15 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 			   void *cpu_addr, dma_addr_t dma_addr, size_t size);
 
+void *dma_common_contiguous_remap(struct page *page, size_t size,
+			unsigned long vm_flags,
+			pgprot_t prot, const void *caller);
+
+void *dma_common_pages_remap(struct page **pages, size_t size,
+			unsigned long vm_flags, pgprot_t prot,
+			const void *caller);
+void dma_common_free_remap(void *cpu_addr, size_t size, unsigned long vm_flags);
+
 /**
  * dma_mmap_attrs - map a coherent DMA allocation into user space
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
