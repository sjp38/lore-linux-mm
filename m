Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9331D6B0269
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:05:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so16666038pgc.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:05:37 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id t27si31934088pfa.146.2016.12.08.21.05.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Dec 2016 21:05:36 -0800 (PST)
Received: from epcpsbgm1new.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OHW02SNAJHBYM40@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Dec 2016 14:05:35 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] [RFC] drivers: dma-coherent: pass struct dma_attrs to
 dma_alloc_from_coherent
Date: Fri, 09 Dec 2016 14:05:29 +0900
Message-id: <1481259930-4620-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: labbott@redhat.com, sumit.semwal@linaro.org, tixy@linaro.org, prime.zeng@huawei.com, tranmanphong@gmail.com, fabio.estevam@freescale.com, ccross@android.com, rebecca@android.com, benjamin.gaignard@linaro.org, arve@android.com, riandrews@android.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

dma_alloc_from_coherent does not get struct dma_attrs information.
If dma_attrs information is passed to dma_alloc_from_coherent,
dma_alloc_from_coherent can do more jobs accodring to the information.
As a example I added DMA_ATTR_SKIP_ZEROING to skip zeroing. Accoring
to driver implementation ZEROING could be skipped or could be done later.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/base/dma-coherent.c | 6 +++++-
 include/linux/dma-mapping.h | 7 ++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index 640a7e6..428eced 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -151,6 +151,7 @@ void *dma_mark_declared_memory_occupied(struct device *dev,
  * @dma_handle:	This will be filled with the correct dma handle
  * @ret:	This pointer will be filled with the virtual address
  *		to allocated area.
+ * @attrs:	dma_attrs to pass additional information
  *
  * This function should be only called from per-arch dma_alloc_coherent()
  * to support allocation from per-device coherent memory pools.
@@ -159,7 +160,8 @@ void *dma_mark_declared_memory_occupied(struct device *dev,
  * generic memory areas, or !0 if dma_alloc_coherent should return @ret.
  */
 int dma_alloc_from_coherent(struct device *dev, ssize_t size,
-				       dma_addr_t *dma_handle, void **ret)
+				       dma_addr_t *dma_handle, void **ret,
+				       struct dma_attrs *attrs)
 {
 	struct dma_coherent_mem *mem;
 	int order = get_order(size);
@@ -190,6 +192,8 @@ int dma_alloc_from_coherent(struct device *dev, ssize_t size,
 	*ret = mem->virt_base + (pageno << PAGE_SHIFT);
 	dma_memory_map = (mem->flags & DMA_MEMORY_MAP);
 	spin_unlock_irqrestore(&mem->spinlock, flags);
+	if (dma_get_attr(DMA_ATTR_SKIP_ZEROING, attrs))
+		return 1;
 	if (dma_memory_map)
 		memset(*ret, 0, size);
 	else
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 08528af..737fd71 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -151,13 +151,14 @@ static inline int is_device_dma_capable(struct device *dev)
  * Don't use them in device drivers.
  */
 int dma_alloc_from_coherent(struct device *dev, ssize_t size,
-				       dma_addr_t *dma_handle, void **ret);
+				       dma_addr_t *dma_handle, void **ret,
+				       struct dma_attrs *attrs);
 int dma_release_from_coherent(struct device *dev, int order, void *vaddr);
 
 int dma_mmap_from_coherent(struct device *dev, struct vm_area_struct *vma,
 			    void *cpu_addr, size_t size, int *ret);
 #else
-#define dma_alloc_from_coherent(dev, size, handle, ret) (0)
+#define dma_alloc_from_coherent(dev, size, handle, ret, attrs) (0)
 #define dma_release_from_coherent(dev, order, vaddr) (0)
 #define dma_mmap_from_coherent(dev, vma, vaddr, order, ret) (0)
 #endif /* CONFIG_HAVE_GENERIC_DMA_COHERENT */
@@ -456,7 +457,7 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 
 	BUG_ON(!ops);
 
-	if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr))
+	if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr, attrs))
 		return cpu_addr;
 
 	if (!arch_dma_alloc_attrs(&dev, &flag))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
