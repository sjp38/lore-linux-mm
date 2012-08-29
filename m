Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 00D0C6B0070
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 02:56:43 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 4/5] ARM: dma-mapping: New dma_map_ops->map_page*_at* function
Date: Wed, 29 Aug 2012 09:55:34 +0300
Message-ID: <1346223335-31455-5-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: iommu@lists.linux-foundation.org, Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c                |   18 ++++++++++++++++++
 include/asm-generic/dma-mapping-common.h |   19 +++++++++++++++++++
 include/linux/dma-mapping.h              |    7 +++++++
 3 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 8ca2d1a..242289f 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1715,6 +1715,23 @@ static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page,
 	return arm_coherent_iommu_map_page(dev, page, offset, size, dir, attrs);
 }
 
+static dma_addr_t arm_iommu_map_page_at(struct device *dev, struct page *page,
+		 dma_addr_t dma_addr, unsigned long offset, size_t size,
+		 enum dma_data_direction dir, struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	int ret, len = PAGE_ALIGN(size + offset);
+
+	if (!dma_get_attr(DMA_ATTR_SKIP_CPU_SYNC, attrs))
+		__dma_page_cpu_to_dev(page, offset, size, dir);
+
+	ret = iommu_map(mapping->domain, dma_addr, page_to_phys(page), len, 0);
+	if (ret < 0)
+		return DMA_ERROR_CODE;
+
+	return dma_addr + offset;
+}
+
 /**
  * arm_coherent_iommu_unmap_page
  * @dev: valid struct device pointer
@@ -1813,6 +1830,7 @@ struct dma_map_ops iommu_ops = {
 	.get_sgtable	= arm_iommu_get_sgtable,
 
 	.map_page		= arm_iommu_map_page,
+	.map_page_at		= arm_iommu_map_page_at,
 	.unmap_page		= arm_iommu_unmap_page,
 	.sync_single_for_cpu	= arm_iommu_sync_single_for_cpu,
 	.sync_single_for_device	= arm_iommu_sync_single_for_device,
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index de8bf89..eada2d8 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -26,6 +26,23 @@ static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
 	return addr;
 }
 
+static inline dma_addr_t dma_map_single_at_attrs(struct device *dev, void *ptr,
+					      dma_addr_t handle,
+					      size_t size,
+					      enum dma_data_direction dir,
+					      struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	dma_addr_t addr;
+
+	kmemcheck_mark_initialized(ptr, size);
+	BUG_ON(!valid_dma_direction(dir));
+	addr = ops->map_page_at(dev, virt_to_page(ptr), handle,
+			     (unsigned long)ptr & ~PAGE_MASK, size,
+			     dir, attrs);
+	return addr;
+}
+
 static inline void dma_unmap_single_attrs(struct device *dev, dma_addr_t addr,
 					  size_t size,
 					  enum dma_data_direction dir,
@@ -172,6 +189,8 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 }
 
 #define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
+#define dma_map_single_at(d, a, h, s, r)		\
+	dma_map_single_at_attrs(d, a, h, s, r, NULL)
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NULL)
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 4cf4427..218bee3 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -25,6 +25,13 @@ struct dma_map_ops {
 			       unsigned long offset, size_t size,
 			       enum dma_data_direction dir,
 			       struct dma_attrs *attrs);
+
+	dma_addr_t (*map_page_at)(struct device *dev, struct page *page,
+				  dma_addr_t dma_handle,
+				  unsigned long offset, size_t size,
+				  enum dma_data_direction dir,
+				  struct dma_attrs *attrs);
+
 	void (*unmap_page)(struct device *dev, dma_addr_t dma_handle,
 			   size_t size, enum dma_data_direction dir,
 			   struct dma_attrs *attrs);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
