Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 499CF6B016B
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 17:09:38 -0400 (EDT)
Received: by mail-vx0-f176.google.com with SMTP id 3so3824580vxh.35
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 14:09:34 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 Jul 2011 16:09:34 -0500
Message-ID: <CAB-zwWjb+2ExjNDB3OtHmRmgaHMnO-VgEe9VZk_wU=ryrq_AGw@mail.gmail.com>
Subject: [RFC] ARM: dma_map|unmap_sg plus iommu
From: "Ramirez Luna, Omar" <omar.ramirez@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joerg Roedel <joro@8bytes.org>, Arnd Bergmann <arnd@arndb.de>, Ohad Ben-Cohen <ohad@wizery.com>

Hi,

I know it is very early but here it is a tryout of the dma_map_sg and
dma_unmap_sg with iommu, I made it to roughly understand what is needed to
remove drivers/omap-iovmm.c (which is a virtual memory manager
implementation on top of omap iommu driver).

This patch is placed on top of Marek Szyprowsk initial work:

ARM: DMA-mapping & IOMMU integration
http://thread.gmane.org/gmane.linux.kernel.mm/63727/

It was tested on an OMAP zoom3 platform and tidspbridge driver. The patch
is used to map user space buffers to dsp's iommu, get_user_pages is used to
form the sg list that will be passed to dma_map_sg.

While at it, I bumped into some issues that I would like to get some
feedback or know if they are being considered:

1. There is no way to keep track of what virtual address are being mapped
in the scatterlist, which we need to propagate to the dsp, in order that it
knows where does the buffers start and end on its virtual address space.
I ended up adding an iov_address to scatterlist which if accepted should be
toggled/affected by the selection of CONFIG_IOMMU_API.

2. tidspbridge driver sometimes needs to map a physical address into a
fixed virtual address (i.e. the start of a firmware section is expected to
be at dsp va 0x20000000), there is no straight forward way to do this with
the dma api given that it only expects to receive a cpu_addr, a sg or a
page, by adding iov_address I could pass phys and iov addresses in a sg
and overcome this limitation, but, these addresses belong to:

  2a. Shared memory between ARM and DSP: this memory is allocated through
      memblock API which takes it out of kernel control to be later
      ioremap'd and iommu map'd to the dsp (this because a non-cacheable
      requirement), so, these physical addresses doesn't have a linear
      virtual address translation, which is what dma api expects.
  2b. Bus addresses: of dsp peripherals which are also ioremap'd and
      affected by the same thing.

  So: kmemcheck_mark_initialized(sg_virt(s), s->length);

  sg_virt might be returning a wrong virtual address, which is different to
  what ioremap returns.

I leave the code below and appreciate any comments or feedback

Regards,

Omar

---
 arch/arm/mm/dma-mapping.c         |   68 +++++++++++++++++++++++++++++++++++++
 drivers/iommu/omap-iommu.c        |    9 ++++-
 include/asm-generic/scatterlist.h |    3 ++
 3 files changed, 79 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index b6397c1..2cc4853 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1318,10 +1318,78 @@ void arm_iommu_free_attrs(struct device *dev,
size_t size, void *cpu_addr,
 	mutex_unlock(&mapping->lock);
 }

+int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents,
+					enum dma_data_direction dir)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	struct scatterlist *s;
+	dma_addr_t iova;
+	size_t size = 0;
+	int i, j;
+
+	BUG_ON(!valid_dma_direction(dir));
+
+	/* XXX do not assume al ents of PAGE_SIZE */
+	size = nents * PAGE_SIZE;
+	iova = gen_pool_alloc(mapping->pool, size);
+	if (iova == 0)
+		return 0;
+
+	for_each_sg(sg, s, nents, i) {
+		int ret;
+		unsigned int phys = page_to_phys(sg_page(s));
+
+		/* XXX Add arch flags */
+		ret = iommu_map(mapping->domain, iova, phys, 0, 0);
+		if (ret < 0)
+			goto bad_mapping;
+
+		s->iov_address = iova;
+		iova += PAGE_SIZE;
+
+		/* XXX do something on error to clean iommu map*/
+		s->dma_address = __dma_map_page(dev, sg_page(s), s->offset,
+						s->length, dir);
+		if (dma_mapping_error(dev, s->dma_address))
+			goto bad_mapping;
+	}
+	debug_dma_map_sg(dev, sg, nents, nents, dir);
+	return nents;
+
+ bad_mapping:
+	for_each_sg(sg, s, i, j)
+		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
+	return 0;
+
+}
+
+void arm_iommu_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
+					enum dma_data_direction dir)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t iova = sg_iov_address(sg);
+	struct scatterlist *s;
+	size_t size = 0;
+	int i;
+
+	debug_dma_unmap_sg(dev, sg, nents, dir);
+
+	for_each_sg(sg, s, nents, i) {
+		__dma_unmap_page(dev, sg_dma_address(s), sg_dma_len(s), dir);
+		iommu_unmap(mapping->domain, sg_iov_address(s), 0);
+	}
+
+	size = nents * PAGE_SIZE;
+	gen_pool_free(mapping->pool, iova, size);
+}
+
+
 struct arm_dma_map_ops iommu_ops = {
 	.alloc_attrs = arm_iommu_alloc_attrs,
 	.free_attrs = arm_iommu_free_attrs,
 	.mmap_attrs = arm_iommu_mmap_attrs,
+	.map_sg = arm_iommu_map_sg,
+	.unmap_sg = arm_iommu_unmap_sg,
 };
 EXPORT_SYMBOL_GPL(iommu_ops);

diff --git a/drivers/iommu/omap-iommu.c b/drivers/iommu/omap-iommu.c
index 9b21b80..6b2a3e1 100644
--- a/drivers/iommu/omap-iommu.c
+++ b/drivers/iommu/omap-iommu.c
@@ -22,6 +22,7 @@
 #include <linux/mutex.h>

 #include <asm/cacheflush.h>
+#include <asm/dma-iommu.h>

 #include <plat/iommu.h>
 #include <plat/iopgtable.h>
@@ -879,9 +880,15 @@ EXPORT_SYMBOL_GPL(iommu_set_da_range);
  */
 struct device *omap_find_iommu_device(const char *name)
 {
-	return driver_find_device(&omap_iommu_driver.driver, NULL,
+	struct device *dev;
+
+	dev = driver_find_device(&omap_iommu_driver.driver, NULL,
 				(void *)name,
 				device_match_by_alias);
+
+	arm_iommu_assign_device(dev, 0x204f0000, 0x304f0000);
+
+	return dev;
 }
 EXPORT_SYMBOL_GPL(omap_find_iommu_device);

diff --git a/include/asm-generic/scatterlist.h
b/include/asm-generic/scatterlist.h
index 5de0735..831d626 100644
--- a/include/asm-generic/scatterlist.h
+++ b/include/asm-generic/scatterlist.h
@@ -11,6 +11,7 @@ struct scatterlist {
 	unsigned int	offset;
 	unsigned int	length;
 	dma_addr_t	dma_address;
+	dma_addr_t	iov_address;
 #ifdef CONFIG_NEED_SG_DMA_LENGTH
 	unsigned int	dma_length;
 #endif
@@ -25,6 +26,8 @@ struct scatterlist {
  */
 #define sg_dma_address(sg)	((sg)->dma_address)

+#define sg_iov_address(sg)      ((sg)->iov_address)
+
 #ifdef CONFIG_NEED_SG_DMA_LENGTH
 #define sg_dma_len(sg)		((sg)->dma_length)
 #else
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
