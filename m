Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8394D6B00EA
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:16:06 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M46006L14TI7350@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 14:15:18 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46005864TPC2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 14:16:02 +0100 (BST)
Date: Thu, 17 May 2012 15:13:55 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv10 05/11] ARM: dma-mapping: remove offset parameter to prepare
 for generic dma_ops
In-reply-to: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337260441-8121-6-git-send-email-m.szyprowski@samsung.com>
References: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

This patch removes the need for the offset parameter in dma bounce
functions. This is required to let dma-mapping framework on ARM
architecture to use common, generic dma_map_ops based dma-mapping
helpers.

Background and more detailed explaination:

dma_*_range_* functions are available from the early days of the dma
mapping api. They are the correct way of doing a partial syncs on the
buffer (usually used by the network device drivers). This patch changes
only the internal implementation of the dma bounce functions to let
them tunnel through dma_map_ops structure. The driver api stays
unchanged, so driver are obliged to call dma_*_range_* functions to
keep code clean and easy to understand.

The only drawback from this patch is reduced detection of the dma api
abuse. Let us consider the following code:

dma_addr = dma_map_single(dev, ptr, 64, DMA_TO_DEVICE);
dma_sync_single_range_for_cpu(dev, dma_addr+16, 0, 32, DMA_TO_DEVICE);

Without the patch such code fails, because dma bounce code is unable
to find the bounce buffer for the given dma_address. After the patch
the above sync call will be equivalent to:

dma_sync_single_range_for_cpu(dev, dma_addr, 16, 32, DMA_TO_DEVICE);

which succeeds.

I don't consider this as a real problem, because DMA API abuse should be
caught by debug_dma_* function family. This patch lets us to simplify
the internal low-level implementation without chaning the driver visible
API.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
---
 arch/arm/common/dmabounce.c        |   13 +++++--
 arch/arm/include/asm/dma-mapping.h |   67 ++++++++++++++++++------------------
 arch/arm/mm/dma-mapping.c          |    4 +--
 3 files changed, 45 insertions(+), 39 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 210ad1b..32e9cc6 100644
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
index 6a838da..eeddbe2 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -266,19 +266,17 @@ extern void __dma_unmap_page(struct device *, dma_addr_t, size_t,
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
@@ -401,6 +399,33 @@ static inline void dma_unmap_page(struct device *dev, dma_addr_t handle,
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
@@ -423,40 +448,14 @@ static inline void dma_sync_single_range_for_cpu(struct device *dev,
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
index e4ac5fc..a16993a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -660,7 +660,7 @@ void dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 	int i;
 
 	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s), 0,
+		if (!dmabounce_sync_for_cpu(dev, sg_dma_address(s),
 					    sg_dma_len(s), dir))
 			continue;
 
@@ -686,7 +686,7 @@ void dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 	int i;
 
 	for_each_sg(sg, s, nents, i) {
-		if (!dmabounce_sync_for_device(dev, sg_dma_address(s), 0,
+		if (!dmabounce_sync_for_device(dev, sg_dma_address(s),
 					sg_dma_len(s), dir))
 			continue;
 
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
