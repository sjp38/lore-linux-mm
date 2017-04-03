Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4572806DB
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:59:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k139so21966088qke.22
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:59:12 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by mx.google.com with ESMTPS id j66si12679805qkd.306.2017.04.03.11.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:59:10 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id g195so50941223qke.2
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:59:10 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 18/22] staging: android: ion: Rework heap registration/enumeration
Date: Mon,  3 Apr 2017 11:58:00 -0700
Message-Id: <1491245884-15852-19-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

The current model of Ion heap registration  is based on the outdated
model of board files. The replacement for board files (devicetree)
isn't a good replacement for what Ion wants to do. In actuality, Ion
wants to show what memory is available in the system for something else
to figure out what to use. Switch to a model where Ion creates its
device unconditionally and heaps are registed as available regions.
Currently, only system and CMA heaps are converted over to the new
model. Carveout and chunk heaps can be converted over when someone wants
to figure out how.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/Kconfig             | 25 +++++++++
 drivers/staging/android/ion/Makefile            |  7 +--
 drivers/staging/android/ion/ion.c               | 28 +++++------
 drivers/staging/android/ion/ion.h               | 40 +--------------
 drivers/staging/android/ion/ion_carveout_heap.c | 10 ----
 drivers/staging/android/ion/ion_chunk_heap.c    |  9 ----
 drivers/staging/android/ion/ion_cma_heap.c      | 24 +++++++--
 drivers/staging/android/ion/ion_heap.c          | 67 -------------------------
 drivers/staging/android/ion/ion_system_heap.c   | 38 ++++++++------
 9 files changed, 85 insertions(+), 163 deletions(-)

diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
index 15108c4..a517b2d 100644
--- a/drivers/staging/android/ion/Kconfig
+++ b/drivers/staging/android/ion/Kconfig
@@ -10,6 +10,31 @@ menuconfig ION
 	  If you're not using Android its probably safe to
 	  say N here.
 
+config ION_SYSTEM_HEAP
+	bool "Ion system heap"
+	depends on ION
+	help
+	  Choose this option to enable the Ion system heap. The system heap
+	  is backed by pages from the buddy allocator. If in doubt, say Y.
+
+config ION_CARVEOUT_HEAP
+	bool "Ion carveout heap support"
+	depends on ION
+	help
+	  Choose this option to enable carveout heaps with Ion. Carveout heaps
+	  are backed by memory reserved from the system. Allocation times are
+	  typically faster at the cost of memory not being used. Unless you
+	  know your system has these regions, you should say N here.
+
+config ION_CHUNK_HEAP
+	bool "Ion chunk heap support"
+	depends on ION
+	help
+          Choose this option to enable chunk heaps with Ion. This heap is
+	  similar in function the carveout heap but memory is broken down
+	  into smaller chunk sizes, typically corresponding to a TLB size.
+	  Unless you know your system has these regions, you should say N here.
+
 config ION_CMA_HEAP
 	bool "Ion CMA heap support"
 	depends on ION && CMA
diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index a892afa..eb7eeed 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -1,4 +1,5 @@
-obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
-			ion_page_pool.o ion_system_heap.o \
-			ion_carveout_heap.o ion_chunk_heap.o
+obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o
+obj-$(CONFIG_ION_SYSTEM_HEAP) += ion_system_heap.o ion_page_pool.o
+obj-$(CONFIG_ION_CARVEOUT_HEAP) += ion_carveout_heap.o
+obj-$(CONFIG_ION_CHUNK_HEAP) += ion_chunk_heap.o
 obj-$(CONFIG_ION_CMA_HEAP) += ion_cma_heap.o
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index e1fb865..7d40233 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -40,6 +40,9 @@
 
 #include "ion.h"
 
+static struct ion_device *internal_dev;
+static int heap_id = 0;
+
 bool ion_buffer_cached(struct ion_buffer *buffer)
 {
 	return !!(buffer->flags & ION_FLAG_CACHED);
@@ -1198,9 +1201,10 @@ static int debug_shrink_get(void *data, u64 *val)
 DEFINE_SIMPLE_ATTRIBUTE(debug_shrink_fops, debug_shrink_get,
 			debug_shrink_set, "%llu\n");
 
-void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap)
+void ion_device_add_heap(struct ion_heap *heap)
 {
 	struct dentry *debug_file;
+	struct ion_device *dev = internal_dev;
 
 	if (!heap->ops->allocate || !heap->ops->free)
 		pr_err("%s: can not add heap with invalid ops struct.\n",
@@ -1217,6 +1221,7 @@ void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap)
 
 	heap->dev = dev;
 	down_write(&dev->lock);
+	heap->id = heap_id++;
 	/*
 	 * use negative heap->id to reverse the priority -- when traversing
 	 * the list later attempt higher id numbers first
@@ -1256,14 +1261,14 @@ void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap)
 }
 EXPORT_SYMBOL(ion_device_add_heap);
 
-struct ion_device *ion_device_create(void)
+int ion_device_create(void)
 {
 	struct ion_device *idev;
 	int ret;
 
 	idev = kzalloc(sizeof(*idev), GFP_KERNEL);
 	if (!idev)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	idev->dev.minor = MISC_DYNAMIC_MINOR;
 	idev->dev.name = "ion";
@@ -1273,7 +1278,7 @@ struct ion_device *ion_device_create(void)
 	if (ret) {
 		pr_err("ion: failed to register misc device.\n");
 		kfree(idev);
-		return ERR_PTR(ret);
+		return ret;
 	}
 
 	idev->debug_root = debugfs_create_dir("ion", NULL);
@@ -1292,7 +1297,6 @@ struct ion_device *ion_device_create(void)
 		pr_err("ion: failed to create debugfs clients directory.\n");
 
 debugfs_done:
-
 	idev->buffers = RB_ROOT;
 	mutex_init(&idev->buffer_lock);
 	init_rwsem(&idev->lock);
@@ -1300,15 +1304,7 @@ struct ion_device *ion_device_create(void)
 	idev->clients = RB_ROOT;
 	ion_root_client = &idev->clients;
 	mutex_init(&debugfs_mutex);
-	return idev;
-}
-EXPORT_SYMBOL(ion_device_create);
-
-void ion_device_destroy(struct ion_device *dev)
-{
-	misc_deregister(&dev->dev);
-	debugfs_remove_recursive(dev->debug_root);
-	/* XXX need to free the heaps and clients ? */
-	kfree(dev);
+	internal_dev = idev;
+	return 0;
 }
-EXPORT_SYMBOL(ion_device_destroy);
+subsys_initcall(ion_device_create);
diff --git a/drivers/staging/android/ion/ion.h b/drivers/staging/android/ion/ion.h
index 67fcb73..27b08c8 100644
--- a/drivers/staging/android/ion/ion.h
+++ b/drivers/staging/android/ion/ion.h
@@ -280,24 +280,10 @@ bool ion_buffer_cached(struct ion_buffer *buffer);
 bool ion_buffer_fault_user_mappings(struct ion_buffer *buffer);
 
 /**
- * ion_device_create - allocates and returns an ion device
- *
- * returns a valid device or -PTR_ERR
- */
-struct ion_device *ion_device_create(void);
-
-/**
- * ion_device_destroy - free and device and it's resource
- * @dev:		the device
- */
-void ion_device_destroy(struct ion_device *dev);
-
-/**
  * ion_device_add_heap - adds a heap to the ion device
- * @dev:		the device
  * @heap:		the heap to add
  */
-void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap);
+void ion_device_add_heap(struct ion_heap *heap);
 
 /**
  * some helpers for common operations on buffers using the sg_table
@@ -390,30 +376,6 @@ size_t ion_heap_freelist_size(struct ion_heap *heap);
 
 
 /**
- * functions for creating and destroying the built in ion heaps.
- * architectures can add their own custom architecture specific
- * heaps as appropriate.
- */
-
-
-struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data);
-void ion_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused);
-void ion_system_heap_destroy(struct ion_heap *heap);
-struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *heap);
-void ion_system_contig_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data);
-void ion_carveout_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data);
-void ion_chunk_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data);
-void ion_cma_heap_destroy(struct ion_heap *heap);
-
-/**
  * functions for creating and destroying a heap pool -- allows you
  * to keep a pool of pre allocated memory to use from your heap.  Keeping
  * a pool of memory that is ready for dma, ie any cached mapping have been
diff --git a/drivers/staging/android/ion/ion_carveout_heap.c b/drivers/staging/android/ion/ion_carveout_heap.c
index 7287279..5fdc1f3 100644
--- a/drivers/staging/android/ion/ion_carveout_heap.c
+++ b/drivers/staging/android/ion/ion_carveout_heap.c
@@ -145,13 +145,3 @@ struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data)
 
 	return &carveout_heap->heap;
 }
-
-void ion_carveout_heap_destroy(struct ion_heap *heap)
-{
-	struct ion_carveout_heap *carveout_heap =
-	     container_of(heap, struct  ion_carveout_heap, heap);
-
-	gen_pool_destroy(carveout_heap->pool);
-	kfree(carveout_heap);
-	carveout_heap = NULL;
-}
diff --git a/drivers/staging/android/ion/ion_chunk_heap.c b/drivers/staging/android/ion/ion_chunk_heap.c
index 9210bfe..9c257c7 100644
--- a/drivers/staging/android/ion/ion_chunk_heap.c
+++ b/drivers/staging/android/ion/ion_chunk_heap.c
@@ -160,12 +160,3 @@ struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data)
 	return ERR_PTR(ret);
 }
 
-void ion_chunk_heap_destroy(struct ion_heap *heap)
-{
-	struct ion_chunk_heap *chunk_heap =
-	     container_of(heap, struct  ion_chunk_heap, heap);
-
-	gen_pool_destroy(chunk_heap->pool);
-	kfree(chunk_heap);
-	chunk_heap = NULL;
-}
diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index e67e78d..dc2a913 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -87,7 +87,7 @@ static struct ion_heap_ops ion_cma_ops = {
 	.unmap_kernel = ion_heap_unmap_kernel,
 };
 
-struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data)
+static struct ion_heap *__ion_cma_heap_create(struct cma *cma)
 {
 	struct ion_cma_heap *cma_heap;
 
@@ -101,14 +101,28 @@ struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data)
 	 * get device from private heaps data, later it will be
 	 * used to make the link with reserved CMA memory
 	 */
-	cma_heap->cma = data->priv;
+	cma_heap->cma = cma;
 	cma_heap->heap.type = ION_HEAP_TYPE_DMA;
 	return &cma_heap->heap;
 }
 
-void ion_cma_heap_destroy(struct ion_heap *heap)
+int __ion_add_cma_heaps(struct cma *cma, void *data)
 {
-	struct ion_cma_heap *cma_heap = to_cma_heap(heap);
+        struct ion_heap *heap;
+
+	heap = __ion_cma_heap_create(cma);
+	if (IS_ERR(heap))
+		return PTR_ERR(heap);
 
-	kfree(cma_heap);
+	heap->name = cma_get_name(cma);
+
+        ion_device_add_heap(heap);
+        return 0;
+}
+
+static int ion_add_cma_heaps(void)
+{
+	cma_for_each_area(__ion_add_cma_heaps, NULL);
+	return 0;
 }
+device_initcall(ion_add_cma_heaps);
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index acb292c..91faa7f 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -314,70 +314,3 @@ void ion_heap_init_shrinker(struct ion_heap *heap)
 	heap->shrinker.batch = 0;
 	register_shrinker(&heap->shrinker);
 }
-
-struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data)
-{
-	struct ion_heap *heap = NULL;
-
-	switch (heap_data->type) {
-	case ION_HEAP_TYPE_SYSTEM_CONTIG:
-		heap = ion_system_contig_heap_create(heap_data);
-		break;
-	case ION_HEAP_TYPE_SYSTEM:
-		heap = ion_system_heap_create(heap_data);
-		break;
-	case ION_HEAP_TYPE_CARVEOUT:
-		heap = ion_carveout_heap_create(heap_data);
-		break;
-	case ION_HEAP_TYPE_CHUNK:
-		heap = ion_chunk_heap_create(heap_data);
-		break;
-	case ION_HEAP_TYPE_DMA:
-		heap = ion_cma_heap_create(heap_data);
-		break;
-	default:
-		pr_err("%s: Invalid heap type %d\n", __func__,
-		       heap_data->type);
-		return ERR_PTR(-EINVAL);
-	}
-
-	if (IS_ERR_OR_NULL(heap)) {
-		pr_err("%s: error creating heap %s type %d base %pa size %zu\n",
-		       __func__, heap_data->name, heap_data->type,
-		       &heap_data->base, heap_data->size);
-		return ERR_PTR(-EINVAL);
-	}
-
-	heap->name = heap_data->name;
-	heap->id = heap_data->id;
-	return heap;
-}
-EXPORT_SYMBOL(ion_heap_create);
-
-void ion_heap_destroy(struct ion_heap *heap)
-{
-	if (!heap)
-		return;
-
-	switch (heap->type) {
-	case ION_HEAP_TYPE_SYSTEM_CONTIG:
-		ion_system_contig_heap_destroy(heap);
-		break;
-	case ION_HEAP_TYPE_SYSTEM:
-		ion_system_heap_destroy(heap);
-		break;
-	case ION_HEAP_TYPE_CARVEOUT:
-		ion_carveout_heap_destroy(heap);
-		break;
-	case ION_HEAP_TYPE_CHUNK:
-		ion_chunk_heap_destroy(heap);
-		break;
-	case ION_HEAP_TYPE_DMA:
-		ion_cma_heap_destroy(heap);
-		break;
-	default:
-		pr_err("%s: Invalid heap type %d\n", __func__,
-		       heap->type);
-	}
-}
-EXPORT_SYMBOL(ion_heap_destroy);
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index 4e6fe37..c50f2d9 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -320,7 +320,7 @@ static int ion_system_heap_create_pools(struct ion_page_pool **pools,
 	return -ENOMEM;
 }
 
-struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused)
+static struct ion_heap *__ion_system_heap_create(void)
 {
 	struct ion_system_heap *heap;
 
@@ -348,19 +348,19 @@ struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused)
 	return ERR_PTR(-ENOMEM);
 }
 
-void ion_system_heap_destroy(struct ion_heap *heap)
+static int ion_system_heap_create(void)
 {
-	struct ion_system_heap *sys_heap = container_of(heap,
-							struct ion_system_heap,
-							heap);
-	int i;
+	struct ion_heap *heap;
 
-	for (i = 0; i < NUM_ORDERS; i++) {
-		ion_page_pool_destroy(sys_heap->uncached_pools[i]);
-		ion_page_pool_destroy(sys_heap->cached_pools[i]);
-	}
-	kfree(sys_heap);
+	heap = __ion_system_heap_create();
+	if (IS_ERR(heap))
+		return PTR_ERR(heap);
+	heap->name = "ion_system_heap";
+
+	ion_device_add_heap(heap);
+	return 0;
 }
+device_initcall(ion_system_heap_create);
 
 static int ion_system_contig_heap_allocate(struct ion_heap *heap,
 					   struct ion_buffer *buffer,
@@ -429,7 +429,7 @@ static struct ion_heap_ops kmalloc_ops = {
 	.map_user = ion_heap_map_user,
 };
 
-struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *unused)
+static struct ion_heap *__ion_system_contig_heap_create(void)
 {
 	struct ion_heap *heap;
 
@@ -438,10 +438,20 @@ struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *unused)
 		return ERR_PTR(-ENOMEM);
 	heap->ops = &kmalloc_ops;
 	heap->type = ION_HEAP_TYPE_SYSTEM_CONTIG;
+	heap->name = "ion_system_contig_heap";
 	return heap;
 }
 
-void ion_system_contig_heap_destroy(struct ion_heap *heap)
+static int ion_system_contig_heap_create(void)
 {
-	kfree(heap);
+	struct ion_heap *heap;
+
+	heap = __ion_system_contig_heap_create();
+	if (IS_ERR(heap))
+		return PTR_ERR(heap);
+
+	ion_device_add_heap(heap);
+	return 0;
 }
+device_initcall(ion_system_contig_heap_create);
+
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
