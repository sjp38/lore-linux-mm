Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CF4526B0260
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:29:56 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id p65so112531209wmp.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:29:56 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id y200si11634296wmc.16.2016.03.31.05.29.50
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 05:29:50 -0700 (PDT)
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH 4/4] mtd: provide helper to prepare buffers for DMA operations
Date: Thu, 31 Mar 2016 14:29:44 +0200
Message-Id: <1459427384-21374-5-git-send-email-boris.brezillon@free-electrons.com>
In-Reply-To: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>
Cc: Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Some NAND controller drivers are making use of DMA to transfer data from
the controller to the buffer passed by the MTD user.
Provide a generic mtd_map/unmap_buf() implementation to avoid open coded
(and sometime erroneous) implementations.

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 drivers/mtd/mtdcore.c   | 66 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mtd/mtd.h | 25 +++++++++++++++++++
 2 files changed, 91 insertions(+)

diff --git a/drivers/mtd/mtdcore.c b/drivers/mtd/mtdcore.c
index 3096251..4c20f33 100644
--- a/drivers/mtd/mtdcore.c
+++ b/drivers/mtd/mtdcore.c
@@ -1253,6 +1253,72 @@ void *mtd_kmalloc_up_to(const struct mtd_info *mtd, size_t *size)
 }
 EXPORT_SYMBOL_GPL(mtd_kmalloc_up_to);
 
+#ifdef CONFIG_HAS_DMA
+/**
+ * mtd_map_buf - create an SG table and prepare it for DMA operations
+ *
+ * @mtd: mtd device description object pointer
+ * @dev: device handling the DMA operation
+ * @buf: buf used to create the SG table
+ * @len: length of buf
+ * @constraints: optional constraints to take into account when creating
+ *		 the SG table. Can be NULL if no specific constraints
+ *		 are required.
+ * @dir: direction of the DMA operation
+ *
+ * This function should be used when an MTD driver wants to do DMA operations
+ * on a buffer passed by the MTD layer. This functions takes care of
+ * vmallocated buffer constraints, and return and sg_table that you can safely
+ * use.
+ */
+int mtd_map_buf(struct mtd_info *mtd, struct device *dev,
+		struct sg_table *sgt, const void *buf, size_t len,
+		const struct sg_constraints *constraints,
+		enum dma_data_direction dir)
+{
+	int ret;
+
+	ret = sg_alloc_table_from_buf(sgt, buf, len, constraints, GFP_KERNEL);
+	if (ret)
+		return ret;
+
+	ret = dma_map_sg(dev, sgt->sgl, sgt->nents, dir);
+	if (!ret)
+		ret = -ENOMEM;
+
+	if (ret < 0) {
+		sg_free_table(sgt);
+		return ret;
+	}
+
+	sgt->nents = ret;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mtd_map_buf);
+
+/**
+ * mtd_unmap_buf - unmap an SG table and release its resources
+ *
+ * @mtd: mtd device description object pointer
+ * @dev: device handling the DMA operation
+ * @sgt: SG table
+ * @dir: direction of the DMA operation
+ *
+ * This function unmaps a previously mapped SG table and release SG table
+ * resources. Should be called when your DMA operation is done.
+ */
+void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
+		   struct sg_table *sgt, enum dma_data_direction dir)
+{
+	if (sgt->orig_nents) {
+		dma_unmap_sg(dev, sgt->sgl, sgt->orig_nents, dir);
+		sg_free_table(sgt);
+	}
+}
+EXPORT_SYMBOL_GPL(mtd_unmap_buf);
+#endif /* !CONFIG_HAS_DMA */
+
 #ifdef CONFIG_PROC_FS
 
 /*====================================================================*/
diff --git a/include/linux/mtd/mtd.h b/include/linux/mtd/mtd.h
index 7712721..15cff85 100644
--- a/include/linux/mtd/mtd.h
+++ b/include/linux/mtd/mtd.h
@@ -24,6 +24,7 @@
 #include <linux/uio.h>
 #include <linux/notifier.h>
 #include <linux/device.h>
+#include <linux/dma-mapping.h>
 
 #include <mtd/mtd-abi.h>
 
@@ -410,6 +411,30 @@ extern void register_mtd_user (struct mtd_notifier *new);
 extern int unregister_mtd_user (struct mtd_notifier *old);
 void *mtd_kmalloc_up_to(const struct mtd_info *mtd, size_t *size);
 
+#ifdef CONFIG_HAS_DMA
+int mtd_map_buf(struct mtd_info *mtd, struct device *dev,
+		struct sg_table *sgt, const void *buf, size_t len,
+		const struct sg_constraints *constraints,
+		enum dma_data_direction dir);
+void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
+		   struct sg_table *sgt, enum dma_data_direction dir);
+#else
+static inline int mtd_map_buf(struct mtd_info *mtd, struct device *dev,
+			      struct sg_table *sgt, const void *buf,
+			      size_t len,
+			      const struct sg_constraints *constraints
+			      enum dma_data_direction dir)
+{
+	return -ENOTSUPP;
+}
+
+static void mtd_unmap_buf(struct mtd_info *mtd, struct device *dev,
+			  struct sg_table *sgt, enum dma_data_direction dir)
+{
+	return -ENOTSUPP;
+}
+#endif
+
 void mtd_erase_callback(struct erase_info *instr);
 
 static inline int mtd_is_bitflip(int err) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
