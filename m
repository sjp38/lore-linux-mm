Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 3D0DC6B13FB
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:59:00 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZ6004VWY29SW80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:57 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ6006O3Y28XO@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:57 +0000 (GMT)
Date: Fri, 10 Feb 2012 19:58:38 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv6 1/7] ARM: dma-mapping: remove offset parameter to prepare for
 generic dma_ops
In-reply-to: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328900324-20946-2-git-send-email-m.szyprowski@samsung.com>
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This patch removes the need for offset parameter in dma bounce
functions. This is required to let dma-mapping framework on ARM
architecture use common, generic dma-mapping helpers.

Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/common/dmabounce.c        |   13 +++++--
 arch/arm/include/asm/dma-mapping.h |   67 +++++++++++++++++------------------
 arch/arm/mm/dma-mapping.c          |    4 +-
 3 files changed, 45 insertions(+), 39 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 595ecd29..46b4b8d 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -173,7 +173,8 @@ find_safe_buffer(struct dmabounce_device_info *device_info, dma_addr_t safe_dma_
 	read_lock_irqsave(&device_info->lock, flags);
 
 	list_for_each_entry(b, &device_info->safe_buffers, node)
-		if (b->safe_dma_addr == safe_dma_addr) {
+		if (b->safe_dma_addr <= safe_dma_addr &&
+		    b->safe_dma_addr + b->size > safe_dma_addr) {
 			rb = b;
 			break;
 		}
@@ -362,9 +363,10 @@ void __dma_unmap_page(struct device *dev, dma_addr_t dma_addr, size_t size,
 EXPORT_SYMBOL(__dma_unmap_page);
 
 int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
-		unsigned long off, size_t sz, enum dma_data_direction dir)
+		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
+	unsigned long off;
 
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
@@ -373,6 +375,8 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 	if (!buf)
 		return 1;
 
+	off = addr - buf->safe_dma_addr;
+
 	BUG_ON(buf->direction != dir);
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
@@ -391,9 +395,10 @@ int dmabounce_sync_for_cpu(struct device *dev, dma_addr_t addr,
 EXPORT_SYMBOL(dmabounce_sync_for_cpu);
 
 int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
-		unsigned long off, size_t sz, enum dma_data_direction dir)
+		size_t sz, enum dma_data_direction dir)
 {
 	struct safe_buffer *buf;
+	unsigned long off;
 
 	dev_dbg(dev, "%s(dma=%#x,off=%#lx,sz=%zx,dir=%x)\n",
 		__func__, addr, off, sz, dir);
@@ -402,6 +407,8 @@ int dmabounce_sync_for_device(struct device *dev, dma_addr_t addr,
 	if (!buf)
 		return 1;
 
+	off = addr - buf->safe_dma_addr;
+
 	BUG_ON(buf->direction != dir);
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index cb3b7c9..6bc056c 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -264,19 +264,17 @@ extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
 /*
  * Private functions
  */
-int dmabounce_sync_for_cpu(struct device *, dma_addr_t, unsigned long,
-		size_t, enum dma_data_direction);
-int dmabounce_sync_for_device(struct device *, dma_addr_t, unsigned long,
-		size_t, enum dma_data_direction);
+int dmabounce_sync_for_cpu(struct device *, dma_addr_t, size_t, enum dma_data_direction);
+int dmabounce_sync_for_device(struct device *, dma_addr_t, size_t, enum dma_data_direction);
 #else
 static inline int dmabounce_sync_for_cpu(struct device *d, dma_addr_t addr,
-	unsigned long offset, size_t size, enum dma_data_direction dir)
+	size_t size, enum dma_data_direction dir)
 {
 	return 1;
 }
 
 static inline int dmabounce_sync_for_device(struct device *d, dma_addr_t addr,
-	unsigned long offset, size_t size, enum dma_data_direction dir)
+	size_t size, enum dma_data_direction dir)
 {
 	return 1;
 }
@@ -399,6 +397,33 @@ static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
 	__dma_unmap_page(dev, handle, size, dir);
 }
 
+
+static inline void dma_sync_single_for_cpu(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	BUG_ON(!valid_dma_direction(dir));
+
+	debug_dma_sync_single_for_cpu(dev, handle, size, dir);
+
+	if (!dmabounce_sync_for_cpu(dev, handle, size, dir))
+		return;
+
+	__dma_single_dev_to_cpu(dma_to_virt(dev, handle), size, dir);
+}
+
+static inline void dma_sync_single_for_device(struct device *dev,
+		dma_addr_t handle, size_t size, enum dma_data_direction dir)
+{
+	BUG_ON(!valid_dma_direction(dir));
+
+	debug_dma_sync_single_for_device(dev, handle, size, dir);
+
+	if (!dmabounce_sync_for_device(dev, handle, size, dir))
+		return;
+
+	__dma_single_cpu_to_dev(dma_to_virt(dev, handle), size, dir);
+}
+
 /**
  * dma_sync_single_range_for_cpu
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
@@ -421,40 +446,14 @@ static inline void dma_sync_single_range_for_cpu(struct device *dev,
 		dma_addr_t handle, unsigned long offset, size_t size,
 		enum dma_data_direction dir)
 {
-	BUG_ON(!valid_dma_direction(dir));
-
-	debug_dma_sync_single_for_cpu(dev, handle + offset, size, dir);
-
-	if (!dmabounce_sync_for_cpu(dev, handle, offset, size, dir))
-		return;
-
-	__dma_single_dev_to_cpu(dma_to_virt(dev, handle) + offset, size, dir);
+	dma_sync_single_for_cpu(dev, handle + offset, size, dir);
 }
 
 static inline void dma_sync_single_range_for_device(struct device *dev,
 		dma_addr_t handle, unsigned long offset, size_t size,
 		enum dma_data_direction dir)
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
-
-static inline void dma_sync_single_for_cpu(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_cpu(dev, handle, 0, size, dir);
-}
-
-static inline void dma_sync_single_for_device(struct device *dev,
-		dma_addr_t handle, size_t size, enum dma_data_direction dir)
-{
-	dma_sync_single_range_for_device(dev, handle, 0, size, dir);
+	dma_sync_single_for_device(dev, handle + offset, size, dir);
 }
 
 /*
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 1aa664a..a5ab8bf 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -654,7 +654,7 @@ void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 	int i;
 
 	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s), 0,
+		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s),
 					    sg_dma_len(s), dir))
 			continue;
 
@@ -680,7 +680,7 @@ void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 	int i;
 
 	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_device(dev, sg_dma_address(s), 0,
+		if (!dmabounce_sync_for_device(dev, sg_dma_address(s),
 					sg_dma_len(s), dir))
 			continue;
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
