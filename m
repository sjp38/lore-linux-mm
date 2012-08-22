Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E76DC6B0068
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 06:20:55 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 4/4] ARM: dma-mapping: dma_{alloc,free}_coherent with empty attrs
Date: Wed, 22 Aug 2012 13:20:30 +0300
Message-ID: <1345630830-9586-5-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

There's possibility that this attrs be used later to set.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/include/asm/dma-mapping.h |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index c27d855..96b67c7 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -125,8 +125,6 @@ extern int dma_supported(struct device *dev, u64 mask);
 extern void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 			   gfp_t gfp, struct dma_attrs *attrs);
 
-#define dma_alloc_coherent(d, s, h, f) dma_alloc_attrs(d, s, h, f, NULL)
-
 static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag,
 				       struct dma_attrs *attrs)
@@ -135,11 +133,21 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 	void *cpu_addr;
 	BUG_ON(!ops);
 
+	if (flag & GFP_ATOMIC)
+		dma_set_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs);
+
 	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
 	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
 	return cpu_addr;
 }
 
+static inline void *dma_alloc_coherent(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	return dma_alloc_attrs(dev, size, dma_handle, flag, &attrs);
+}
+
 /**
  * arm_dma_free - free memory allocated by arm_dma_alloc
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -157,8 +165,6 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 extern void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 			 dma_addr_t handle, struct dma_attrs *attrs);
 
-#define dma_free_coherent(d, s, c, h) dma_free_attrs(d, s, c, h, NULL)
-
 static inline void dma_free_attrs(struct device *dev, size_t size,
 				     void *cpu_addr, dma_addr_t dma_handle,
 				     struct dma_attrs *attrs)
@@ -170,6 +176,13 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
 	ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
+static inline void dma_free_coherent(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	return dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
+}
+
 /**
  * arm_dma_mmap - map a coherent DMA allocation into user space
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
