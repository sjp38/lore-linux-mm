Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15C2F6B0392
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j127so86675824qke.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:28 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id a68si7692279qkf.6.2017.03.17.17.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:26 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id n21so75241168qta.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:26 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 08/21] staging: android: ion: Remove crufty cache support
Date: Fri, 17 Mar 2017 17:54:40 -0700
Message-Id: <1489798493-16600-9-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Now that we call dma_map in the dma_buf API callbacks there is no need
to use the existing cache APIs. Remove the sync ioctl and the existing
bad dma_sync calls. Explicit caching can be handled with the dma_buf
sync API.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/compat_ion.c        |  1 -
 drivers/staging/android/ion/ion-ioctl.c         |  6 ----
 drivers/staging/android/ion/ion.c               | 40 -------------------------
 drivers/staging/android/ion/ion_carveout_heap.c |  6 ----
 drivers/staging/android/ion/ion_chunk_heap.c    |  6 ----
 drivers/staging/android/ion/ion_page_pool.c     |  3 --
 drivers/staging/android/ion/ion_priv.h          | 13 --------
 drivers/staging/android/ion/ion_system_heap.c   |  5 ----
 drivers/staging/android/uapi/ion.h              | 10 -------
 9 files changed, 90 deletions(-)

diff --git a/drivers/staging/android/ion/compat_ion.c b/drivers/staging/android/ion/compat_ion.c
index 9a978d2..b892d3a 100644
--- a/drivers/staging/android/ion/compat_ion.c
+++ b/drivers/staging/android/ion/compat_ion.c
@@ -186,7 +186,6 @@ long compat_ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 	case ION_IOC_SHARE:
 	case ION_IOC_MAP:
 	case ION_IOC_IMPORT:
-	case ION_IOC_SYNC:
 		return filp->f_op->unlocked_ioctl(filp, cmd,
 						(unsigned long)compat_ptr(arg));
 	default:
diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 5b2e93f..e096bcd 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -51,7 +51,6 @@ static int validate_ioctl_arg(unsigned int cmd, union ion_ioctl_arg *arg)
 static unsigned int ion_ioctl_dir(unsigned int cmd)
 {
 	switch (cmd) {
-	case ION_IOC_SYNC:
 	case ION_IOC_FREE:
 	case ION_IOC_CUSTOM:
 		return _IOC_WRITE;
@@ -146,11 +145,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			data.handle.handle = handle->id;
 		break;
 	}
-	case ION_IOC_SYNC:
-	{
-		ret = ion_sync_for_device(client, data.fd.fd);
-		break;
-	}
 	case ION_IOC_CUSTOM:
 	{
 		if (!dev->custom_ioctl)
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 226ea1f..8757164 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -863,22 +863,6 @@ static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
 	dma_unmap_sg(attachment->dev, table->sgl, table->nents, direction);
 }
 
-void ion_pages_sync_for_device(struct device *dev, struct page *page,
-			       size_t size, enum dma_data_direction dir)
-{
-	struct scatterlist sg;
-
-	sg_init_table(&sg, 1);
-	sg_set_page(&sg, page, size, 0);
-	/*
-	 * This is not correct - sg_dma_address needs a dma_addr_t that is valid
-	 * for the targeted device, but this works on the currently targeted
-	 * hardware.
-	 */
-	sg_dma_address(&sg) = page_to_phys(page);
-	dma_sync_sg_for_device(dev, &sg, 1, dir);
-}
-
 static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
 {
 	struct ion_buffer *buffer = dmabuf->priv;
@@ -1097,30 +1081,6 @@ struct ion_handle *ion_import_dma_buf_fd(struct ion_client *client, int fd)
 }
 EXPORT_SYMBOL(ion_import_dma_buf_fd);
 
-int ion_sync_for_device(struct ion_client *client, int fd)
-{
-	struct dma_buf *dmabuf;
-	struct ion_buffer *buffer;
-
-	dmabuf = dma_buf_get(fd);
-	if (IS_ERR(dmabuf))
-		return PTR_ERR(dmabuf);
-
-	/* if this memory came from ion */
-	if (dmabuf->ops != &dma_buf_ops) {
-		pr_err("%s: can not sync dmabuf from another exporter\n",
-		       __func__);
-		dma_buf_put(dmabuf);
-		return -EINVAL;
-	}
-	buffer = dmabuf->priv;
-
-	dma_sync_sg_for_device(NULL, buffer->sg_table->sgl,
-			       buffer->sg_table->nents, DMA_BIDIRECTIONAL);
-	dma_buf_put(dmabuf);
-	return 0;
-}
-
 int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query)
 {
 	struct ion_device *dev = client->dev;
diff --git a/drivers/staging/android/ion/ion_carveout_heap.c b/drivers/staging/android/ion/ion_carveout_heap.c
index 9bf8e98..e0e360f 100644
--- a/drivers/staging/android/ion/ion_carveout_heap.c
+++ b/drivers/staging/android/ion/ion_carveout_heap.c
@@ -100,10 +100,6 @@ static void ion_carveout_heap_free(struct ion_buffer *buffer)
 
 	ion_heap_buffer_zero(buffer);
 
-	if (ion_buffer_cached(buffer))
-		dma_sync_sg_for_device(NULL, table->sgl, table->nents,
-				       DMA_BIDIRECTIONAL);
-
 	ion_carveout_free(heap, paddr, buffer->size);
 	sg_free_table(table);
 	kfree(table);
@@ -128,8 +124,6 @@ struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data)
 	page = pfn_to_page(PFN_DOWN(heap_data->base));
 	size = heap_data->size;
 
-	ion_pages_sync_for_device(NULL, page, size, DMA_BIDIRECTIONAL);
-
 	ret = ion_heap_pages_zero(page, size, pgprot_writecombine(PAGE_KERNEL));
 	if (ret)
 		return ERR_PTR(ret);
diff --git a/drivers/staging/android/ion/ion_chunk_heap.c b/drivers/staging/android/ion/ion_chunk_heap.c
index 8c41889..46e13f6 100644
--- a/drivers/staging/android/ion/ion_chunk_heap.c
+++ b/drivers/staging/android/ion/ion_chunk_heap.c
@@ -101,10 +101,6 @@ static void ion_chunk_heap_free(struct ion_buffer *buffer)
 
 	ion_heap_buffer_zero(buffer);
 
-	if (ion_buffer_cached(buffer))
-		dma_sync_sg_for_device(NULL, table->sgl, table->nents,
-				       DMA_BIDIRECTIONAL);
-
 	for_each_sg(table->sgl, sg, table->nents, i) {
 		gen_pool_free(chunk_heap->pool, page_to_phys(sg_page(sg)),
 			      sg->length);
@@ -132,8 +128,6 @@ struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data)
 	page = pfn_to_page(PFN_DOWN(heap_data->base));
 	size = heap_data->size;
 
-	ion_pages_sync_for_device(NULL, page, size, DMA_BIDIRECTIONAL);
-
 	ret = ion_heap_pages_zero(page, size, pgprot_writecombine(PAGE_KERNEL));
 	if (ret)
 		return ERR_PTR(ret);
diff --git a/drivers/staging/android/ion/ion_page_pool.c b/drivers/staging/android/ion/ion_page_pool.c
index aea89c1..532eda7 100644
--- a/drivers/staging/android/ion/ion_page_pool.c
+++ b/drivers/staging/android/ion/ion_page_pool.c
@@ -30,9 +30,6 @@ static void *ion_page_pool_alloc_pages(struct ion_page_pool *pool)
 
 	if (!page)
 		return NULL;
-	if (!pool->cached)
-		ion_pages_sync_for_device(NULL, page, PAGE_SIZE << pool->order,
-					  DMA_BIDIRECTIONAL);
 	return page;
 }
 
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index 297d99d..4fc7026 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -440,21 +440,8 @@ void ion_page_pool_free(struct ion_page_pool *pool, struct page *page);
 int ion_page_pool_shrink(struct ion_page_pool *pool, gfp_t gfp_mask,
 			  int nr_to_scan);
 
-/**
- * ion_pages_sync_for_device - cache flush pages for use with the specified
- *                             device
- * @dev:		the device the pages will be used with
- * @page:		the first page to be flushed
- * @size:		size in bytes of region to be flushed
- * @dir:		direction of dma transfer
- */
-void ion_pages_sync_for_device(struct device *dev, struct page *page,
-		size_t size, enum dma_data_direction dir);
-
 long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
 
-int ion_sync_for_device(struct ion_client *client, int fd);
-
 struct ion_handle *ion_handle_get_by_id_nolock(struct ion_client *client,
 						int id);
 
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index 6cb2fe7..a33331b 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -75,9 +75,6 @@ static struct page *alloc_buffer_page(struct ion_system_heap *heap,
 
 	page = ion_page_pool_alloc(pool);
 
-	if (cached)
-		ion_pages_sync_for_device(NULL, page, PAGE_SIZE << order,
-					  DMA_BIDIRECTIONAL);
 	return page;
 }
 
@@ -401,8 +398,6 @@ static int ion_system_contig_heap_allocate(struct ion_heap *heap,
 
 	buffer->sg_table = table;
 
-	ion_pages_sync_for_device(NULL, page, len, DMA_BIDIRECTIONAL);
-
 	return 0;
 
 free_table:
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index 14cd873..c3a87a5 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -207,16 +207,6 @@ struct ion_heap_query {
 #define ION_IOC_IMPORT		_IOWR(ION_IOC_MAGIC, 5, struct ion_fd_data)
 
 /**
- * DOC: ION_IOC_SYNC - syncs a shared file descriptors to memory
- *
- * Deprecated in favor of using the dma_buf api's correctly (syncing
- * will happen automatically when the buffer is mapped to a device).
- * If necessary should be used after touching a cached buffer from the cpu,
- * this will make the buffer in memory coherent.
- */
-#define ION_IOC_SYNC		_IOWR(ION_IOC_MAGIC, 7, struct ion_fd_data)
-
-/**
  * DOC: ION_IOC_CUSTOM - call architecture specific ion ioctl
  *
  * Takes the argument of the architecture specific ioctl to call and
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
