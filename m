Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04CB76B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 16:45:12 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id a189so116364867qkc.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:11 -0800 (PST)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id n41si7904821qtf.240.2017.03.02.13.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 13:45:11 -0800 (PST)
Received: by mail-qk0-f171.google.com with SMTP id n127so147104859qkf.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:11 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCH 06/12] staging: android: ion: Remove crufty cache support
Date: Thu,  2 Mar 2017 13:44:38 -0800
Message-Id: <1488491084-17252-7-git-send-email-labbott@redhat.com>
In-Reply-To: <1488491084-17252-1-git-send-email-labbott@redhat.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org



Now that we call dma_map in the dma_buf API callbacks there is no need
to use the existing cache APIs. Remove the sync ioctl and the existing
bad dma_sync calls. Explicit caching can be handled with the dma_buf
sync API.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion-ioctl.c         |  5 ----
 drivers/staging/android/ion/ion.c               | 40 -------------------------
 drivers/staging/android/ion/ion_carveout_heap.c |  6 ----
 drivers/staging/android/ion/ion_chunk_heap.c    |  6 ----
 drivers/staging/android/ion/ion_page_pool.c     |  3 --
 drivers/staging/android/ion/ion_system_heap.c   |  5 ----
 6 files changed, 65 deletions(-)

diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 5b2e93f..f820d77 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -146,11 +146,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
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
index 8eef1d7..c3c316f 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -815,22 +815,6 @@ static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
 	free_duped_table(table);
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
@@ -1042,30 +1026,6 @@ struct ion_handle *ion_import_dma_buf_fd(struct ion_client *client, int fd)
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
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
