Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EC39E6B006E
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 02:56:20 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 5/5] ARM: dma-mapping: Introduce dma_map_linear_attrs() for IOVA linear map
Date: Wed, 29 Aug 2012 09:55:35 +0300
Message-ID: <1346223335-31455-6-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: iommu@lists.linux-foundation.org, Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

Introduce a helper function, dma_map_linear(_attrs)() to create IOVA
linear map, where IOVA and kernel virtual addresses are mapped at the
same address linearly. This is useful to support legacy device drivers
which expects no IOMMU.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/include/asm/dma-mapping.h       |   13 +++++++++++++
 include/asm-generic/dma-mapping-common.h |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index f04a533..7a78dd4 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -212,6 +212,19 @@ static inline size_t dma_iova_get_free_max(struct device *dev)
 	return ops->iova_get_free_max(dev);
 }
 
+static inline dma_addr_t dma_map_linear_attrs(struct device *dev, void *va,
+				      size_t size, enum dma_data_direction dir,
+				      struct dma_attrs *attrs)
+{
+	dma_addr_t da;
+
+	da = dma_iova_alloc_at(dev, (dma_addr_t)va, size);
+	if (da == DMA_ERROR_CODE)
+		return DMA_ERROR_CODE;
+
+	return dma_map_single_at_attrs(dev, va, da, size, dir, attrs);
+}
+
 /**
  * arm_dma_mmap - map a coherent DMA allocation into user space
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index eada2d8..4564bf0 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -191,6 +191,7 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_map_single(d, a, s, r) dma_map_single_attrs(d, a, s, r, NULL)
 #define dma_map_single_at(d, a, h, s, r)		\
 	dma_map_single_at_attrs(d, a, h, s, r, NULL)
+#define dma_map_linear(d, a, s, r) dma_map_linear_attrs(d, a, s, r, NULL)
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NULL)
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
