Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B188B6B038B
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 16:45:04 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c85so117216433qkg.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:04 -0800 (PST)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id r3si7930302qkb.62.2017.03.02.13.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 13:45:03 -0800 (PST)
Received: by mail-qk0-f179.google.com with SMTP id m67so31712091qkf.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:03 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCH 04/12] staging: android: ion: Call dma_map_sg for syncing and mapping
Date: Thu,  2 Mar 2017 13:44:36 -0800
Message-Id: <1488491084-17252-5-git-send-email-labbott@redhat.com>
In-Reply-To: <1488491084-17252-1-git-send-email-labbott@redhat.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org


Technically, calling dma_buf_map_attachment should return a buffer
properly dma_mapped. Add calls to dma_map_sg to begin_cpu_access to
ensure this happens. As a side effect, this lets Ion buffers take
advantage of the dma_buf sync ioctls.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c | 101 +++++++++++++++++++-------------------
 1 file changed, 50 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index ce4adac..a931b30 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -795,10 +795,6 @@ void ion_client_destroy(struct ion_client *client)
 }
 EXPORT_SYMBOL(ion_client_destroy);
 
-static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
-				       struct device *dev,
-				       enum dma_data_direction direction);
-
 static struct sg_table *dup_sg_table(struct sg_table *table)
 {
 	struct sg_table *new_table;
@@ -825,22 +821,43 @@ static struct sg_table *dup_sg_table(struct sg_table *table)
 	return new_table;
 }
 
+static void free_duped_table(struct sg_table *table)
+{
+	sg_free_table(table);
+	kfree(table);
+}
+
 static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
 					enum dma_data_direction direction)
 {
 	struct dma_buf *dmabuf = attachment->dmabuf;
 	struct ion_buffer *buffer = dmabuf->priv;
+	struct sg_table *table;
+	int ret;
+
+	/*
+	 * TODO: Need to sync wrt CPU or device completely owning?
+	 */
+
+	table = dup_sg_table(buffer->sg_table);
 
-	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
-	return dup_sg_table(buffer->sg_table);
+	if (!dma_map_sg(attachment->dev, table->sgl, table->nents,
+			direction)){
+		ret = -ENOMEM;
+		goto err;
+	}
+
+err:
+	free_duped_table(table);
+	return ERR_PTR(ret);
 }
 
 static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
 			      struct sg_table *table,
 			      enum dma_data_direction direction)
 {
-	sg_free_table(table);
-	kfree(table);
+	dma_unmap_sg(attachment->dev, table->sgl, table->nents, direction);
+	free_duped_table(table);
 }
 
 void ion_pages_sync_for_device(struct device *dev, struct page *page,
@@ -864,38 +881,6 @@ struct ion_vma_list {
 	struct vm_area_struct *vma;
 };
 
-static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
-				       struct device *dev,
-				       enum dma_data_direction dir)
-{
-	struct ion_vma_list *vma_list;
-	int pages = PAGE_ALIGN(buffer->size) / PAGE_SIZE;
-	int i;
-
-	pr_debug("%s: syncing for device %s\n", __func__,
-		 dev ? dev_name(dev) : "null");
-
-	if (!ion_buffer_fault_user_mappings(buffer))
-		return;
-
-	mutex_lock(&buffer->lock);
-	for (i = 0; i < pages; i++) {
-		struct page *page = buffer->pages[i];
-
-		if (ion_buffer_page_is_dirty(page))
-			ion_pages_sync_for_device(dev, ion_buffer_page(page),
-						  PAGE_SIZE, dir);
-
-		ion_buffer_page_clean(buffer->pages + i);
-	}
-	list_for_each_entry(vma_list, &buffer->vmas, list) {
-		struct vm_area_struct *vma = vma_list->vma;
-
-		zap_page_range(vma, vma->vm_start, vma->vm_end - vma->vm_start);
-	}
-	mutex_unlock(&buffer->lock);
-}
-
 static int ion_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct ion_buffer *buffer = vma->vm_private_data;
@@ -1014,16 +999,24 @@ static int ion_dma_buf_begin_cpu_access(struct dma_buf *dmabuf,
 	struct ion_buffer *buffer = dmabuf->priv;
 	void *vaddr;
 
-	if (!buffer->heap->ops->map_kernel) {
-		pr_err("%s: map kernel is not implemented by this heap.\n",
-		       __func__);
-		return -ENODEV;
+	/*
+	 * TODO: Move this elsewhere because we don't always need a vaddr
+	 */
+	if (buffer->heap->ops->map_kernel) {
+		mutex_lock(&buffer->lock);
+		vaddr = ion_buffer_kmap_get(buffer);
+		mutex_unlock(&buffer->lock);
 	}
 
-	mutex_lock(&buffer->lock);
-	vaddr = ion_buffer_kmap_get(buffer);
-	mutex_unlock(&buffer->lock);
-	return PTR_ERR_OR_ZERO(vaddr);
+	/*
+	 * Close enough right now? Flag to skip sync?
+	 */
+	if (!dma_map_sg(buffer->dev->dev.this_device, buffer->sg_table->sgl,
+			buffer->sg_table->nents,
+                        DMA_BIDIRECTIONAL))
+		return -ENOMEM;
+
+	return 0;
 }
 
 static int ion_dma_buf_end_cpu_access(struct dma_buf *dmabuf,
@@ -1031,9 +1024,15 @@ static int ion_dma_buf_end_cpu_access(struct dma_buf *dmabuf,
 {
 	struct ion_buffer *buffer = dmabuf->priv;
 
-	mutex_lock(&buffer->lock);
-	ion_buffer_kmap_put(buffer);
-	mutex_unlock(&buffer->lock);
+	if (buffer->heap->ops->map_kernel) {
+		mutex_lock(&buffer->lock);
+		ion_buffer_kmap_put(buffer);
+		mutex_unlock(&buffer->lock);
+	}
+
+	dma_unmap_sg(buffer->dev->dev.this_device, buffer->sg_table->sgl,
+			buffer->sg_table->nents,
+			DMA_BIDIRECTIONAL);
 
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
