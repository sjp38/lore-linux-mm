Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 66D656B0062
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 07:51:17 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5K00E3Z0WAVTE0@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 13 Jun 2012 20:51:07 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5K00JMG0WB4X70@mmp1.samsung.com> for linux-mm@kvack.org;
 Wed, 13 Jun 2012 20:51:06 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 3/6] common: dma-mapping: introduce dma_get_sgtable() function
Date: Wed, 13 Jun 2012 13:50:15 +0200
Message-id: <1339588218-24398-4-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
References: <1339588218-24398-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

This patch adds dma_get_sgtable() function which is required to let
drivers to share the buffers allocated by DMA-mapping subsystem. Right
now the driver gets a dma address of the allocated buffer and the kernel
virtual mapping for it. If it wants to share it with other device (= map
into its dma address space) it usually hacks around kernel virtual
addresses to get pointers to pages or assumes that both devices share
the DMA address space. Both solutions are just hacks for the special
cases, which should be avoided in the final version of buffer sharing.

To solve this issue in a generic way, a new call to DMA mapping has been
introduced - dma_get_sgtable(). It allocates a scatter-list which
describes the allocated buffer and lets the driver(s) to use it with
other device(s) by calling dma_map_sg() on it.

This patch provides a generic implementation based on virt_to_page()
call. Architectures which require more sophisticated translation might
provide their own get_sgtable() methods.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 drivers/base/dma-mapping.c               |   18 ++++++++++++++++++
 include/asm-generic/dma-mapping-common.h |   18 ++++++++++++++++++
 include/linux/dma-mapping.h              |    3 +++
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 6f3676f..49785c1 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -217,4 +217,22 @@ void dmam_release_declared_memory(struct device *dev)
 }
 EXPORT_SYMBOL(dmam_release_declared_memory);
 
+/*
+ * Create scatter-list for the already allocated DMA buffer.
+ */
+int dma_common_get_sgtable(struct device *dev, struct sg_table *sgt,
+		 void *cpu_addr, dma_addr_t handle, size_t size)
+{
+	struct page *page = virt_to_page(cpu_addr);
+	int ret;
+
+	ret = sg_alloc_table(sgt, 1, GFP_KERNEL);
+	if (unlikely(ret))
+		return ret;
+
+	sg_set_page(sgt->sgl, page, PAGE_ALIGN(size), 0);
+	return 0;
+}
+EXPORT_SYMBOL(dma_common_get_sgtable);
+
 #endif
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 2e248d8..34841c6 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -176,4 +176,22 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
 
+int
+dma_common_get_sgtable(struct device *dev, struct sg_table *sgt,
+		       void *cpu_addr, dma_addr_t dma_addr, size_t size);
+
+static inline int
+dma_get_sgtable_attrs(struct device *dev, struct sg_table *sgt, void *cpu_addr,
+		      dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->get_sgtable)
+		return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size,
+					attrs);
+	return dma_common_get_sgtable(dev, sgt, cpu_addr, dma_addr, size);
+}
+
+#define dma_get_sgtable(d, t, v, h, s) dma_get_sgtable_attrs(d, t, v, h, s, NULL)
+
 #endif
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index dfc099e..94af418 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -18,6 +18,9 @@ struct dma_map_ops {
 	int (*mmap)(struct device *, struct vm_area_struct *,
 			  void *, dma_addr_t, size_t, struct dma_attrs *attrs);
 
+	int (*get_sgtable)(struct device *dev, struct sg_table *sgt, void *,
+			   dma_addr_t, size_t, struct dma_attrs *attrs);
+
 	dma_addr_t (*map_page)(struct device *dev, struct page *page,
 			       unsigned long offset, size_t size,
 			       enum dma_data_direction dir,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
