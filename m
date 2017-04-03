Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3960B6B03A1
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:31 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x7so49432506qka.9
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:31 -0700 (PDT)
Received: from mail-qt0-f176.google.com (mail-qt0-f176.google.com. [209.85.216.176])
        by mx.google.com with ESMTPS id o47si12703339qta.170.2017.04.03.11.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:30 -0700 (PDT)
Received: by mail-qt0-f176.google.com with SMTP id n21so120795825qta.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:30 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 06/22] staging: android: ion: Call dma_map_sg for syncing and mapping
Date: Mon,  3 Apr 2017 11:57:48 -0700
Message-Id: <1491245884-15852-7-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Technically, calling dma_buf_map_attachment should return a buffer
properly dma_mapped. Add calls to dma_map_sg to begin_cpu_access to
ensure this happens. As a side effect, this lets Ion buffers take
advantage of the dma_buf sync ioctls.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c      | 151 ++++++++++++++++++++++-----------
 drivers/staging/android/ion/ion_priv.h |   1 +
 2 files changed, 103 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 7dcb8a9..6aac935 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -162,6 +162,7 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 	buffer->dev = dev;
 	buffer->size = len;
 	INIT_LIST_HEAD(&buffer->vmas);
+	INIT_LIST_HEAD(&buffer->attachments);
 	mutex_init(&buffer->lock);
 	/*
 	 * this will set up dma addresses for the sglist -- it is not
@@ -796,10 +797,6 @@ void ion_client_destroy(struct ion_client *client)
 }
 EXPORT_SYMBOL(ion_client_destroy);
 
-static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
-				       struct device *dev,
-				       enum dma_data_direction direction);
-
 static struct sg_table *dup_sg_table(struct sg_table *table)
 {
 	struct sg_table *new_table;
@@ -826,22 +823,89 @@ static struct sg_table *dup_sg_table(struct sg_table *table)
 	return new_table;
 }
 
+static void free_duped_table(struct sg_table *table)
+{
+	sg_free_table(table);
+	kfree(table);
+}
+
+struct ion_dma_buf_attachment {
+	struct device *dev;
+	struct sg_table *table;
+	struct list_head list;
+};
+
+static int ion_dma_buf_attach(struct dma_buf *dmabuf, struct device *dev,
+				struct dma_buf_attachment *attachment)
+{
+	struct ion_dma_buf_attachment *a;
+	struct sg_table *table;
+	struct ion_buffer *buffer = dmabuf->priv;
+
+	a = kzalloc(sizeof(*a), GFP_KERNEL);
+	if (!a)
+		return -ENOMEM;
+
+	table = dup_sg_table(buffer->sg_table);
+	if (IS_ERR(table)) {
+		kfree(a);
+		return -ENOMEM;
+	}
+
+	a->table = table;
+	a->dev = dev;
+	INIT_LIST_HEAD(&a->list);
+
+	attachment->priv = a;
+
+	mutex_lock(&buffer->lock);
+	list_add(&a->list, &buffer->attachments);
+	mutex_unlock(&buffer->lock);
+
+	return 0;
+}
+
+static void ion_dma_buf_detatch(struct dma_buf *dmabuf,
+				struct dma_buf_attachment *attachment)
+{
+	struct ion_dma_buf_attachment *a = attachment->priv;
+	struct ion_buffer *buffer = dmabuf->priv;
+
+	free_duped_table(a->table);
+	mutex_lock(&buffer->lock);
+	list_del(&a->list);
+	mutex_unlock(&buffer->lock);
+
+	kfree(a);
+}
+
+
 static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
 					enum dma_data_direction direction)
 {
-	struct dma_buf *dmabuf = attachment->dmabuf;
-	struct ion_buffer *buffer = dmabuf->priv;
+	struct ion_dma_buf_attachment *a = attachment->priv;
+	struct sg_table *table;
+	int ret;
+
+	table = a->table;
 
-	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
-	return dup_sg_table(buffer->sg_table);
+	if (!dma_map_sg(attachment->dev, table->sgl, table->nents,
+			direction)){
+		ret = -ENOMEM;
+		goto err;
+	}
+	return table;
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
 }
 
 void ion_pages_sync_for_device(struct device *dev, struct page *page,
@@ -865,38 +929,6 @@ struct ion_vma_list {
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
 static int ion_vm_fault(struct vm_fault *vmf)
 {
 	struct ion_buffer *buffer = vmf->vma->vm_private_data;
@@ -1014,26 +1046,45 @@ static int ion_dma_buf_begin_cpu_access(struct dma_buf *dmabuf,
 {
 	struct ion_buffer *buffer = dmabuf->priv;
 	void *vaddr;
+	struct ion_dma_buf_attachment *a;
 
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
 
+
 	mutex_lock(&buffer->lock);
-	vaddr = ion_buffer_kmap_get(buffer);
+	list_for_each_entry(a, &buffer->attachments, list) {
+		dma_sync_sg_for_cpu(a->dev, a->table->sgl, a->table->nents,
+					DMA_BIDIRECTIONAL);
+	}
 	mutex_unlock(&buffer->lock);
-	return PTR_ERR_OR_ZERO(vaddr);
+
+	return 0;
 }
 
 static int ion_dma_buf_end_cpu_access(struct dma_buf *dmabuf,
 				      enum dma_data_direction direction)
 {
 	struct ion_buffer *buffer = dmabuf->priv;
+	struct ion_dma_buf_attachment *a;
+
+	if (buffer->heap->ops->map_kernel) {
+		mutex_lock(&buffer->lock);
+		ion_buffer_kmap_put(buffer);
+		mutex_unlock(&buffer->lock);
+	}
 
 	mutex_lock(&buffer->lock);
-	ion_buffer_kmap_put(buffer);
+	list_for_each_entry(a, &buffer->attachments, list) {
+		dma_sync_sg_for_device(a->dev, a->table->sgl, a->table->nents,
+					DMA_BIDIRECTIONAL);
+	}
 	mutex_unlock(&buffer->lock);
 
 	return 0;
@@ -1044,6 +1095,8 @@ static const struct dma_buf_ops dma_buf_ops = {
 	.unmap_dma_buf = ion_unmap_dma_buf,
 	.mmap = ion_mmap,
 	.release = ion_dma_buf_release,
+	.attach = ion_dma_buf_attach,
+	.detach = ion_dma_buf_detatch,
 	.begin_cpu_access = ion_dma_buf_begin_cpu_access,
 	.end_cpu_access = ion_dma_buf_end_cpu_access,
 	.kmap_atomic = ion_dma_buf_kmap,
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index b09bc7c..297d99d 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -72,6 +72,7 @@ struct ion_buffer {
 	struct sg_table *sg_table;
 	struct page **pages;
 	struct list_head vmas;
+	struct list_head attachments;
 	/* used to track orphaned buffers */
 	int handle_count;
 	char task_comm[TASK_COMM_LEN];
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
