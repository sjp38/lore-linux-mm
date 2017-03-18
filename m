Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA5426B038E
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:14 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j30so80169861qta.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:14 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by mx.google.com with ESMTPS id e88si7679930qtd.187.2017.03.17.17.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:13 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id p64so77328573qke.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:13 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 04/21] staging: android: ion: Remove alignment from allocation field
Date: Fri, 17 Mar 2017 17:54:36 -0700
Message-Id: <1489798493-16600-5-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


The align field was supposed to be used to specify the alignment of
the allocation. Nobody actually does anything with it except to check
if the alignment specified is out of bounds. Since this has no effect
on the actual allocation, just remove it.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion-ioctl.c         |  1 -
 drivers/staging/android/ion/ion.c               | 14 ++++++--------
 drivers/staging/android/ion/ion.h               |  5 +----
 drivers/staging/android/ion/ion_carveout_heap.c | 10 +++-------
 drivers/staging/android/ion/ion_chunk_heap.c    |  9 +++------
 drivers/staging/android/ion/ion_cma_heap.c      |  5 +----
 drivers/staging/android/ion/ion_priv.h          |  2 +-
 drivers/staging/android/ion/ion_system_heap.c   |  9 +--------
 8 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 9ff815a..5b2e93f 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -95,7 +95,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		struct ion_handle *handle;
 
 		handle = ion_alloc(client, data.allocation.len,
-						data.allocation.align,
 						data.allocation.heap_id_mask,
 						data.allocation.flags);
 		if (IS_ERR(handle))
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index f45115f..c2adfe1 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -103,7 +103,6 @@ static void ion_buffer_add(struct ion_device *dev,
 static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 					    struct ion_device *dev,
 					    unsigned long len,
-					    unsigned long align,
 					    unsigned long flags)
 {
 	struct ion_buffer *buffer;
@@ -119,15 +118,14 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 	buffer->flags = flags;
 	kref_init(&buffer->ref);
 
-	ret = heap->ops->allocate(heap, buffer, len, align, flags);
+	ret = heap->ops->allocate(heap, buffer, len, flags);
 
 	if (ret) {
 		if (!(heap->flags & ION_HEAP_FLAG_DEFER_FREE))
 			goto err2;
 
 		ion_heap_freelist_drain(heap, 0);
-		ret = heap->ops->allocate(heap, buffer, len, align,
-					  flags);
+		ret = heap->ops->allocate(heap, buffer, len, flags);
 		if (ret)
 			goto err2;
 	}
@@ -401,7 +399,7 @@ static int ion_handle_add(struct ion_client *client, struct ion_handle *handle)
 }
 
 struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
-			     size_t align, unsigned int heap_id_mask,
+			     unsigned int heap_id_mask,
 			     unsigned int flags)
 {
 	struct ion_handle *handle;
@@ -410,8 +408,8 @@ struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
 	struct ion_heap *heap;
 	int ret;
 
-	pr_debug("%s: len %zu align %zu heap_id_mask %u flags %x\n", __func__,
-		 len, align, heap_id_mask, flags);
+	pr_debug("%s: len %zu heap_id_mask %u flags %x\n", __func__,
+		 len, heap_id_mask, flags);
 	/*
 	 * traverse the list of heaps available in this system in priority
 	 * order.  If the heap type is supported by the client, and matches the
@@ -428,7 +426,7 @@ struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
 		/* if the caller didn't specify this heap id */
 		if (!((1 << heap->id) & heap_id_mask))
 			continue;
-		buffer = ion_buffer_create(heap, dev, len, align, flags);
+		buffer = ion_buffer_create(heap, dev, len, flags);
 		if (!IS_ERR(buffer))
 			break;
 	}
diff --git a/drivers/staging/android/ion/ion.h b/drivers/staging/android/ion/ion.h
index 93dafb4..3b4bff5 100644
--- a/drivers/staging/android/ion/ion.h
+++ b/drivers/staging/android/ion/ion.h
@@ -45,7 +45,6 @@ struct ion_buffer;
  * @name:	used for debug purposes
  * @base:	base address of heap in physical memory if applicable
  * @size:	size of the heap in bytes if applicable
- * @align:	required alignment in physical memory if applicable
  * @priv:	private info passed from the board file
  *
  * Provided by the board file.
@@ -93,8 +92,6 @@ void ion_client_destroy(struct ion_client *client);
  * ion_alloc - allocate ion memory
  * @client:		the client
  * @len:		size of the allocation
- * @align:		requested allocation alignment, lots of hardware blocks
- *			have alignment requirements of some kind
  * @heap_id_mask:	mask of heaps to allocate from, if multiple bits are set
  *			heaps will be tried in order from highest to lowest
  *			id
@@ -106,7 +103,7 @@ void ion_client_destroy(struct ion_client *client);
  * an opaque handle to it.
  */
 struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
-			     size_t align, unsigned int heap_id_mask,
+			     unsigned int heap_id_mask,
 			     unsigned int flags);
 
 /**
diff --git a/drivers/staging/android/ion/ion_carveout_heap.c b/drivers/staging/android/ion/ion_carveout_heap.c
index a8ea973..9bf8e98 100644
--- a/drivers/staging/android/ion/ion_carveout_heap.c
+++ b/drivers/staging/android/ion/ion_carveout_heap.c
@@ -34,8 +34,7 @@ struct ion_carveout_heap {
 };
 
 static ion_phys_addr_t ion_carveout_allocate(struct ion_heap *heap,
-					     unsigned long size,
-					     unsigned long align)
+					     unsigned long size)
 {
 	struct ion_carveout_heap *carveout_heap =
 		container_of(heap, struct ion_carveout_heap, heap);
@@ -60,16 +59,13 @@ static void ion_carveout_free(struct ion_heap *heap, ion_phys_addr_t addr,
 
 static int ion_carveout_heap_allocate(struct ion_heap *heap,
 				      struct ion_buffer *buffer,
-				      unsigned long size, unsigned long align,
+				      unsigned long size,
 				      unsigned long flags)
 {
 	struct sg_table *table;
 	ion_phys_addr_t paddr;
 	int ret;
 
-	if (align > PAGE_SIZE)
-		return -EINVAL;
-
 	table = kmalloc(sizeof(*table), GFP_KERNEL);
 	if (!table)
 		return -ENOMEM;
@@ -77,7 +73,7 @@ static int ion_carveout_heap_allocate(struct ion_heap *heap,
 	if (ret)
 		goto err_free;
 
-	paddr = ion_carveout_allocate(heap, size, align);
+	paddr = ion_carveout_allocate(heap, size);
 	if (paddr == ION_CARVEOUT_ALLOCATE_FAIL) {
 		ret = -ENOMEM;
 		goto err_free_table;
diff --git a/drivers/staging/android/ion/ion_chunk_heap.c b/drivers/staging/android/ion/ion_chunk_heap.c
index 70495dc..8c41889 100644
--- a/drivers/staging/android/ion/ion_chunk_heap.c
+++ b/drivers/staging/android/ion/ion_chunk_heap.c
@@ -35,7 +35,7 @@ struct ion_chunk_heap {
 
 static int ion_chunk_heap_allocate(struct ion_heap *heap,
 				   struct ion_buffer *buffer,
-				   unsigned long size, unsigned long align,
+				   unsigned long size,
 				   unsigned long flags)
 {
 	struct ion_chunk_heap *chunk_heap =
@@ -46,9 +46,6 @@ static int ion_chunk_heap_allocate(struct ion_heap *heap,
 	unsigned long num_chunks;
 	unsigned long allocated_size;
 
-	if (align > chunk_heap->chunk_size)
-		return -EINVAL;
-
 	allocated_size = ALIGN(size, chunk_heap->chunk_size);
 	num_chunks = allocated_size / chunk_heap->chunk_size;
 
@@ -160,8 +157,8 @@ struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data)
 	chunk_heap->heap.ops = &chunk_heap_ops;
 	chunk_heap->heap.type = ION_HEAP_TYPE_CHUNK;
 	chunk_heap->heap.flags = ION_HEAP_FLAG_DEFER_FREE;
-	pr_debug("%s: base %lu size %zu align %ld\n", __func__,
-		 chunk_heap->base, heap_data->size, heap_data->align);
+	pr_debug("%s: base %lu size %zu \n", __func__,
+		 chunk_heap->base, heap_data->size);
 
 	return &chunk_heap->heap;
 
diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index 6c40685..d562fd7 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -40,7 +40,7 @@ struct ion_cma_buffer_info {
 
 /* ION CMA heap operations functions */
 static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
-			    unsigned long len, unsigned long align,
+			    unsigned long len,
 			    unsigned long flags)
 {
 	struct ion_cma_heap *cma_heap = to_cma_heap(heap);
@@ -52,9 +52,6 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
 	if (buffer->flags & ION_FLAG_CACHED)
 		return -EINVAL;
 
-	if (align > PAGE_SIZE)
-		return -EINVAL;
-
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return -ENOMEM;
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index 46d3ff5..b09bc7c 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -172,7 +172,7 @@ struct ion_handle {
 struct ion_heap_ops {
 	int (*allocate)(struct ion_heap *heap,
 			struct ion_buffer *buffer, unsigned long len,
-			unsigned long align, unsigned long flags);
+			unsigned long flags);
 	void (*free)(struct ion_buffer *buffer);
 	void * (*map_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
 	void (*unmap_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index 3ebbb75..6cb2fe7 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -129,7 +129,7 @@ static struct page *alloc_largest_available(struct ion_system_heap *heap,
 
 static int ion_system_heap_allocate(struct ion_heap *heap,
 				    struct ion_buffer *buffer,
-				    unsigned long size, unsigned long align,
+				    unsigned long size,
 				    unsigned long flags)
 {
 	struct ion_system_heap *sys_heap = container_of(heap,
@@ -143,9 +143,6 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
 	unsigned long size_remaining = PAGE_ALIGN(size);
 	unsigned int max_order = orders[0];
 
-	if (align > PAGE_SIZE)
-		return -EINVAL;
-
 	if (size / PAGE_SIZE > totalram_pages / 2)
 		return -ENOMEM;
 
@@ -372,7 +369,6 @@ void ion_system_heap_destroy(struct ion_heap *heap)
 static int ion_system_contig_heap_allocate(struct ion_heap *heap,
 					   struct ion_buffer *buffer,
 					   unsigned long len,
-					   unsigned long align,
 					   unsigned long flags)
 {
 	int order = get_order(len);
@@ -381,9 +377,6 @@ static int ion_system_contig_heap_allocate(struct ion_heap *heap,
 	unsigned long i;
 	int ret;
 
-	if (align > (PAGE_SIZE << order))
-		return -EINVAL;
-
 	page = alloc_pages(low_order_gfp_flags, order);
 	if (!page)
 		return -ENOMEM;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
