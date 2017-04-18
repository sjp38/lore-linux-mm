Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 766EF6B03A5
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:29:15 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j29so269779qtj.19
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 11:29:15 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id o84si2909413qkl.198.2017.04.18.11.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 11:27:31 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id d131so1120069qkc.3
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 11:27:30 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 03/12] staging: android: ion: Use CMA APIs directly
Date: Tue, 18 Apr 2017 11:27:05 -0700
Message-Id: <1492540034-5466-4-git-send-email-labbott@redhat.com>
In-Reply-To: <1492540034-5466-1-git-send-email-labbott@redhat.com>
References: <1492540034-5466-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

When CMA was first introduced, its primary use was for DMA allocation
and the only way to get CMA memory was to call dma_alloc_coherent. This
put Ion in an awkward position since there was no device structure
readily available and setting one up messed up the coherency model.
These days, CMA can be allocated directly from the APIs. Switch to using
this model to avoid needing a dummy device. This also mitigates some of
the caching problems (e.g. dma_alloc_coherent only returning uncached
memory).

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v4: Put some #ifdef around CMA heap functions. This is ugly but gets removed
a few patches later.
---
 drivers/staging/android/ion/Kconfig        |  7 +++
 drivers/staging/android/ion/Makefile       |  3 +-
 drivers/staging/android/ion/ion_cma_heap.c | 97 ++++++++----------------------
 drivers/staging/android/ion/ion_heap.c     |  4 ++
 4 files changed, 39 insertions(+), 72 deletions(-)

diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
index 206c4de..15108c4 100644
--- a/drivers/staging/android/ion/Kconfig
+++ b/drivers/staging/android/ion/Kconfig
@@ -10,3 +10,10 @@ menuconfig ION
 	  If you're not using Android its probably safe to
 	  say N here.
 
+config ION_CMA_HEAP
+	bool "Ion CMA heap support"
+	depends on ION && CMA
+	help
+	  Choose this option to enable CMA heaps with Ion. This heap is backed
+	  by the Contiguous Memory Allocator (CMA). If your system has these
+	  regions, you should say Y here.
diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index 26672a0..66d0c4a 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
 			ion_page_pool.o ion_system_heap.o \
-			ion_carveout_heap.o ion_chunk_heap.o ion_cma_heap.o
+			ion_carveout_heap.o ion_chunk_heap.o
+obj-$(CONFIG_ION_CMA_HEAP) += ion_cma_heap.o
 ifdef CONFIG_COMPAT
 obj-$(CONFIG_ION) += compat_ion.o
 endif
diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index d562fd7..f3e0f59 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -19,24 +19,19 @@
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/err.h>
-#include <linux/dma-mapping.h>
+#include <linux/cma.h>
+#include <linux/scatterlist.h>
 
 #include "ion.h"
 #include "ion_priv.h"
 
 struct ion_cma_heap {
 	struct ion_heap heap;
-	struct device *dev;
+	struct cma *cma;
 };
 
 #define to_cma_heap(x) container_of(x, struct ion_cma_heap, heap)
 
-struct ion_cma_buffer_info {
-	void *cpu_addr;
-	dma_addr_t handle;
-	struct sg_table *table;
-};
-
 
 /* ION CMA heap operations functions */
 static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
@@ -44,93 +39,53 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
 			    unsigned long flags)
 {
 	struct ion_cma_heap *cma_heap = to_cma_heap(heap);
-	struct device *dev = cma_heap->dev;
-	struct ion_cma_buffer_info *info;
-
-	dev_dbg(dev, "Request buffer allocation len %ld\n", len);
-
-	if (buffer->flags & ION_FLAG_CACHED)
-		return -EINVAL;
+	struct sg_table *table;
+	struct page *pages;
+	int ret;
 
-	info = kzalloc(sizeof(*info), GFP_KERNEL);
-	if (!info)
+	pages = cma_alloc(cma_heap->cma, len, 0, GFP_KERNEL);
+	if (!pages)
 		return -ENOMEM;
 
-	info->cpu_addr = dma_alloc_coherent(dev, len, &(info->handle),
-						GFP_HIGHUSER | __GFP_ZERO);
-
-	if (!info->cpu_addr) {
-		dev_err(dev, "Fail to allocate buffer\n");
+	table = kmalloc(sizeof(struct sg_table), GFP_KERNEL);
+	if (!table)
 		goto err;
-	}
 
-	info->table = kmalloc(sizeof(*info->table), GFP_KERNEL);
-	if (!info->table)
+	ret = sg_alloc_table(table, 1, GFP_KERNEL);
+	if (ret)
 		goto free_mem;
 
-	if (dma_get_sgtable(dev, info->table, info->cpu_addr, info->handle,
-			    len))
-		goto free_table;
-	/* keep this for memory release */
-	buffer->priv_virt = info;
-	buffer->sg_table = info->table;
-	dev_dbg(dev, "Allocate buffer %p\n", buffer);
+	sg_set_page(table->sgl, pages, len, 0);
+
+	buffer->priv_virt = pages;
+	buffer->sg_table = table;
 	return 0;
 
-free_table:
-	kfree(info->table);
 free_mem:
-	dma_free_coherent(dev, len, info->cpu_addr, info->handle);
+	kfree(table);
 err:
-	kfree(info);
+	cma_release(cma_heap->cma, pages, buffer->size);
 	return -ENOMEM;
 }
 
 static void ion_cma_free(struct ion_buffer *buffer)
 {
 	struct ion_cma_heap *cma_heap = to_cma_heap(buffer->heap);
-	struct device *dev = cma_heap->dev;
-	struct ion_cma_buffer_info *info = buffer->priv_virt;
+	struct page *pages = buffer->priv_virt;
 
-	dev_dbg(dev, "Release buffer %p\n", buffer);
 	/* release memory */
-	dma_free_coherent(dev, buffer->size, info->cpu_addr, info->handle);
+	cma_release(cma_heap->cma, pages, buffer->size);
 	/* release sg table */
-	sg_free_table(info->table);
-	kfree(info->table);
-	kfree(info);
-}
-
-static int ion_cma_mmap(struct ion_heap *mapper, struct ion_buffer *buffer,
-			struct vm_area_struct *vma)
-{
-	struct ion_cma_heap *cma_heap = to_cma_heap(buffer->heap);
-	struct device *dev = cma_heap->dev;
-	struct ion_cma_buffer_info *info = buffer->priv_virt;
-
-	return dma_mmap_coherent(dev, vma, info->cpu_addr, info->handle,
-				 buffer->size);
-}
-
-static void *ion_cma_map_kernel(struct ion_heap *heap,
-				struct ion_buffer *buffer)
-{
-	struct ion_cma_buffer_info *info = buffer->priv_virt;
-	/* kernel memory mapping has been done at allocation time */
-	return info->cpu_addr;
-}
-
-static void ion_cma_unmap_kernel(struct ion_heap *heap,
-				 struct ion_buffer *buffer)
-{
+	sg_free_table(buffer->sg_table);
+	kfree(buffer->sg_table);
 }
 
 static struct ion_heap_ops ion_cma_ops = {
 	.allocate = ion_cma_allocate,
 	.free = ion_cma_free,
-	.map_user = ion_cma_mmap,
-	.map_kernel = ion_cma_map_kernel,
-	.unmap_kernel = ion_cma_unmap_kernel,
+	.map_user = ion_heap_map_user,
+	.map_kernel = ion_heap_map_kernel,
+	.unmap_kernel = ion_heap_unmap_kernel,
 };
 
 struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data)
@@ -147,7 +102,7 @@ struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data)
 	 * get device from private heaps data, later it will be
 	 * used to make the link with reserved CMA memory
 	 */
-	cma_heap->dev = data->priv;
+	cma_heap->cma = data->priv;
 	cma_heap->heap.type = ION_HEAP_TYPE_DMA;
 	return &cma_heap->heap;
 }
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index c69d0bd..66f8fc5 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -333,9 +333,11 @@ struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data)
 	case ION_HEAP_TYPE_CHUNK:
 		heap = ion_chunk_heap_create(heap_data);
 		break;
+#ifdef CONFIG_ION_CMA_HEAP
 	case ION_HEAP_TYPE_DMA:
 		heap = ion_cma_heap_create(heap_data);
 		break;
+#endif
 	default:
 		pr_err("%s: Invalid heap type %d\n", __func__,
 		       heap_data->type);
@@ -373,9 +375,11 @@ void ion_heap_destroy(struct ion_heap *heap)
 	case ION_HEAP_TYPE_CHUNK:
 		ion_chunk_heap_destroy(heap);
 		break;
+#ifdef CONFIG_ION_CMA_HEAP
 	case ION_HEAP_TYPE_DMA:
 		ion_cma_heap_destroy(heap);
 		break;
+#endif
 	default:
 		pr_err("%s: Invalid heap type %d\n", __func__,
 		       heap->type);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
