Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 125FA6B038C
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 16:45:08 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n127so116495811qkf.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:08 -0800 (PST)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com. [209.85.220.176])
        by mx.google.com with ESMTPS id a68si7922351qkf.6.2017.03.02.13.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 13:45:07 -0800 (PST)
Received: by mail-qk0-f176.google.com with SMTP id s186so146620601qkb.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 13:45:07 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCH 05/12] staging: android: ion: Remove page faulting support
Date: Thu,  2 Mar 2017 13:44:37 -0800
Message-Id: <1488491084-17252-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1488491084-17252-1-git-send-email-labbott@redhat.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org


The new method of syncing with dma_map means that the page faulting sync
implementation is no longer applicable. Remove it.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c | 117 --------------------------------------
 1 file changed, 117 deletions(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index a931b30..8eef1d7 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -41,37 +41,11 @@
 #include "ion_priv.h"
 #include "compat_ion.h"
 
-bool ion_buffer_fault_user_mappings(struct ion_buffer *buffer)
-{
-	return (buffer->flags & ION_FLAG_CACHED) &&
-		!(buffer->flags & ION_FLAG_CACHED_NEEDS_SYNC);
-}
-
 bool ion_buffer_cached(struct ion_buffer *buffer)
 {
 	return !!(buffer->flags & ION_FLAG_CACHED);
 }
 
-static inline struct page *ion_buffer_page(struct page *page)
-{
-	return (struct page *)((unsigned long)page & ~(1UL));
-}
-
-static inline bool ion_buffer_page_is_dirty(struct page *page)
-{
-	return !!((unsigned long)page & 1UL);
-}
-
-static inline void ion_buffer_page_dirty(struct page **page)
-{
-	*page = (struct page *)((unsigned long)(*page) | 1UL);
-}
-
-static inline void ion_buffer_page_clean(struct page **page)
-{
-	*page = (struct page *)((unsigned long)(*page) & ~(1UL));
-}
-
 /* this function should only be called while dev->lock is held */
 static void ion_buffer_add(struct ion_device *dev,
 			   struct ion_buffer *buffer)
@@ -139,25 +113,6 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 	buffer->dev = dev;
 	buffer->size = len;
 
-	if (ion_buffer_fault_user_mappings(buffer)) {
-		int num_pages = PAGE_ALIGN(buffer->size) / PAGE_SIZE;
-		struct scatterlist *sg;
-		int i, j, k = 0;
-
-		buffer->pages = vmalloc(sizeof(struct page *) * num_pages);
-		if (!buffer->pages) {
-			ret = -ENOMEM;
-			goto err1;
-		}
-
-		for_each_sg(table->sgl, sg, table->nents, i) {
-			struct page *page = sg_page(sg);
-
-			for (j = 0; j < sg->length / PAGE_SIZE; j++)
-				buffer->pages[k++] = page++;
-		}
-	}
-
 	buffer->dev = dev;
 	buffer->size = len;
 	INIT_LIST_HEAD(&buffer->vmas);
@@ -876,69 +831,6 @@ void ion_pages_sync_for_device(struct device *dev, struct page *page,
 	dma_sync_sg_for_device(dev, &sg, 1, dir);
 }
 
-struct ion_vma_list {
-	struct list_head list;
-	struct vm_area_struct *vma;
-};
-
-static int ion_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
-{
-	struct ion_buffer *buffer = vma->vm_private_data;
-	unsigned long pfn;
-	int ret;
-
-	mutex_lock(&buffer->lock);
-	ion_buffer_page_dirty(buffer->pages + vmf->pgoff);
-	BUG_ON(!buffer->pages || !buffer->pages[vmf->pgoff]);
-
-	pfn = page_to_pfn(ion_buffer_page(buffer->pages[vmf->pgoff]));
-	ret = vm_insert_pfn(vma, vmf->address, pfn);
-	mutex_unlock(&buffer->lock);
-	if (ret)
-		return VM_FAULT_ERROR;
-
-	return VM_FAULT_NOPAGE;
-}
-
-static void ion_vm_open(struct vm_area_struct *vma)
-{
-	struct ion_buffer *buffer = vma->vm_private_data;
-	struct ion_vma_list *vma_list;
-
-	vma_list = kmalloc(sizeof(*vma_list), GFP_KERNEL);
-	if (!vma_list)
-		return;
-	vma_list->vma = vma;
-	mutex_lock(&buffer->lock);
-	list_add(&vma_list->list, &buffer->vmas);
-	mutex_unlock(&buffer->lock);
-	pr_debug("%s: adding %p\n", __func__, vma);
-}
-
-static void ion_vm_close(struct vm_area_struct *vma)
-{
-	struct ion_buffer *buffer = vma->vm_private_data;
-	struct ion_vma_list *vma_list, *tmp;
-
-	pr_debug("%s\n", __func__);
-	mutex_lock(&buffer->lock);
-	list_for_each_entry_safe(vma_list, tmp, &buffer->vmas, list) {
-		if (vma_list->vma != vma)
-			continue;
-		list_del(&vma_list->list);
-		kfree(vma_list);
-		pr_debug("%s: deleting %p\n", __func__, vma);
-		break;
-	}
-	mutex_unlock(&buffer->lock);
-}
-
-static const struct vm_operations_struct ion_vma_ops = {
-	.open = ion_vm_open,
-	.close = ion_vm_close,
-	.fault = ion_vm_fault,
-};
-
 static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
 {
 	struct ion_buffer *buffer = dmabuf->priv;
@@ -950,15 +842,6 @@ static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
 		return -EINVAL;
 	}
 
-	if (ion_buffer_fault_user_mappings(buffer)) {
-		vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND |
-							VM_DONTDUMP;
-		vma->vm_private_data = buffer;
-		vma->vm_ops = &ion_vma_ops;
-		ion_vm_open(vma);
-		return 0;
-	}
-
 	if (!(buffer->flags & ION_FLAG_CACHED))
 		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
