Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7E66B00B5
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:46 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id bs8so1861775wib.17
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si10558759wjq.66.2014.03.17.12.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/9] media: vb2: Convert vb2_dc_get_userptr() to use pfns vector
Date: Mon, 17 Mar 2014 20:49:33 +0100
Message-Id: <1395085776-8626-7-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Convert vb2_dc_get_userptr() to use passed vector of pfns. When we are
doing that there's no need to allocate page array and some code can be
simplified.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-dma-contig.c | 203 ++++---------------------
 1 file changed, 30 insertions(+), 173 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index c6378d943b89..d445b62a51cf 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -32,15 +32,13 @@ struct vb2_dc_buf {
 	dma_addr_t			dma_addr;
 	enum dma_data_direction		dma_dir;
 	struct sg_table			*dma_sgt;
+	struct pinned_pfns		*pfns;
 
 	/* MMAP related */
 	struct vb2_vmarea_handler	handler;
 	atomic_t			refcount;
 	struct sg_table			*sgt_base;
 
-	/* USERPTR related */
-	struct vm_area_struct		*vma;
-
 	/* DMABUF related */
 	struct dma_buf_attachment	*db_attach;
 };
@@ -49,24 +47,6 @@ struct vb2_dc_buf {
 /*        scatterlist table functions        */
 /*********************************************/
 
-
-static void vb2_dc_sgt_foreach_page(struct sg_table *sgt,
-	void (*cb)(struct page *pg))
-{
-	struct scatterlist *s;
-	unsigned int i;
-
-	for_each_sg(sgt->sgl, s, sgt->orig_nents, i) {
-		struct page *page = sg_page(s);
-		unsigned int n_pages = PAGE_ALIGN(s->offset + s->length)
-			>> PAGE_SHIFT;
-		unsigned int j;
-
-		for (j = 0; j < n_pages; ++j, ++page)
-			cb(page);
-	}
-}
-
 static unsigned long vb2_dc_get_contiguous_size(struct sg_table *sgt)
 {
 	struct scatterlist *s;
@@ -418,101 +398,24 @@ static struct dma_buf *vb2_dc_get_dmabuf(void *buf_priv, unsigned long flags)
 /*       callbacks for USERPTR buffers       */
 /*********************************************/
 
-static inline int vma_is_io(struct vm_area_struct *vma)
-{
-	return !!(vma->vm_flags & (VM_IO | VM_PFNMAP));
-}
-
-static int vb2_dc_get_user_pfn(unsigned long start, int n_pages,
-	struct vm_area_struct *vma, unsigned long *res)
-{
-	unsigned long pfn, start_pfn, prev_pfn;
-	unsigned int i;
-	int ret;
-
-	if (!vma_is_io(vma))
-		return -EFAULT;
-
-	ret = follow_pfn(vma, start, &pfn);
-	if (ret)
-		return ret;
-
-	start_pfn = pfn;
-	start += PAGE_SIZE;
-
-	for (i = 1; i < n_pages; ++i, start += PAGE_SIZE) {
-		prev_pfn = pfn;
-		ret = follow_pfn(vma, start, &pfn);
-
-		if (ret) {
-			pr_err("no page for address %lu\n", start);
-			return ret;
-		}
-		if (pfn != prev_pfn + 1)
-			return -EINVAL;
-	}
-
-	*res = start_pfn;
-	return 0;
-}
-
-static int vb2_dc_get_user_pages(unsigned long start, struct page **pages,
-	int n_pages, struct vm_area_struct *vma, int write)
-{
-	if (vma_is_io(vma)) {
-		unsigned int i;
-
-		for (i = 0; i < n_pages; ++i, start += PAGE_SIZE) {
-			unsigned long pfn;
-			int ret = follow_pfn(vma, start, &pfn);
-
-			if (!pfn_valid(pfn))
-				return -EINVAL;
-
-			if (ret) {
-				pr_err("no page for address %lu\n", start);
-				return ret;
-			}
-			pages[i] = pfn_to_page(pfn);
-		}
-	} else {
-		int n;
-
-		n = get_user_pages(current, current->mm, start & PAGE_MASK,
-			n_pages, write, 1, pages, NULL);
-		/* negative error means that no page was pinned */
-		n = max(n, 0);
-		if (n != n_pages) {
-			pr_err("got only %d of %d user pages\n", n, n_pages);
-			while (n)
-				put_page(pages[--n]);
-			return -EFAULT;
-		}
-	}
-
-	return 0;
-}
-
-static void vb2_dc_put_dirty_page(struct page *page)
-{
-	set_page_dirty_lock(page);
-	put_page(page);
-}
 
 static void vb2_dc_put_userptr(void *buf_priv)
 {
 	struct vb2_dc_buf *buf = buf_priv;
 	struct sg_table *sgt = buf->dma_sgt;
+	int i;
+	struct page **pages;
 
 	if (sgt) {
 		dma_unmap_sg(buf->dev, sgt->sgl, sgt->orig_nents, buf->dma_dir);
-		if (!vma_is_io(buf->vma))
-			vb2_dc_sgt_foreach_page(sgt, vb2_dc_put_dirty_page);
-
+		pages = pfns_vector_pages(buf->pfns);
+		for (i = 0; i < pfns_vector_count(buf->pfns); i++)
+			set_page_dirty_lock(pages[i]);
 		sg_free_table(sgt);
 		kfree(sgt);
 	}
-	vb2_put_vma(buf->vma);
+	put_vaddr_pfns(buf->pfns);
+	pfns_vector_destroy(buf->pfns);
 	kfree(buf);
 }
 
@@ -553,13 +456,10 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
 {
 	struct vb2_dc_conf *conf = alloc_ctx;
 	struct vb2_dc_buf *buf;
-	unsigned long start;
-	unsigned long end;
+	struct pinned_pfns *pfns = *ppfn;
 	unsigned long offset;
-	struct page **pages;
-	int n_pages;
+	int n_pages, i;
 	int ret = 0;
-	struct vm_area_struct *vma;
 	struct sg_table *sgt;
 	unsigned long contig_size;
 	unsigned long dma_align = dma_get_cache_alignment();
@@ -582,72 +482,38 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
 	buf->dev = conf->dev;
 	buf->dma_dir = write ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 
-	start = vaddr & PAGE_MASK;
 	offset = vaddr & ~PAGE_MASK;
-	end = PAGE_ALIGN(vaddr + size);
-	n_pages = (end - start) >> PAGE_SHIFT;
-
-	pages = kmalloc(n_pages * sizeof(pages[0]), GFP_KERNEL);
-	if (!pages) {
-		ret = -ENOMEM;
-		pr_err("failed to allocate pages table\n");
-		goto fail_buf;
-	}
-
-	/* current->mm->mmap_sem is taken by videobuf2 core */
-	vma = find_vma(current->mm, vaddr);
-	if (!vma) {
-		pr_err("no vma for address %lu\n", vaddr);
-		ret = -EFAULT;
-		goto fail_pages;
-	}
-
-	if (vma->vm_end < vaddr + size) {
-		pr_err("vma at %lu is too small for %lu bytes\n", vaddr, size);
-		ret = -EFAULT;
-		goto fail_pages;
-	}
+	n_pages = pfns_vector_count(pfns);
 
-	buf->vma = vb2_get_vma(vma);
-	if (!buf->vma) {
-		pr_err("failed to copy vma\n");
-		ret = -ENOMEM;
-		goto fail_pages;
-	}
+	ret = pfns_vector_to_pages(pfns);
+	if (ret < 0) {
+		unsigned long *nums = pfns_vector_pfns(pfns);
 
-	/* extract page list from userspace mapping */
-	ret = vb2_dc_get_user_pages(start, pages, n_pages, vma, write);
-	if (ret) {
-		unsigned long pfn;
-		if (vb2_dc_get_user_pfn(start, n_pages, vma, &pfn) == 0) {
-			buf->dma_addr = vb2_dc_pfn_to_dma(buf->dev, pfn);
-			buf->size = size;
-			kfree(pages);
-			return buf;
-		}
-
-		pr_err("failed to get user pages\n");
-		goto fail_vma;
+		/*
+		 * Failed to convert to pages... Check the memory is physically
+ 		 * contiguous and use direct mapping
+		 */
+		for (i = 1; i < n_pages; i++)
+			if (nums[i-1] + 1 != nums[i])
+				goto fail_buf;
+		buf->dma_addr = vb2_dc_pfn_to_dma(buf->dev, nums[0]);
+		goto out;
 	}
 
 	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
 	if (!sgt) {
 		pr_err("failed to allocate sg table\n");
 		ret = -ENOMEM;
-		goto fail_get_user_pages;
+		goto fail_buf;
 	}
 
-	ret = sg_alloc_table_from_pages(sgt, pages, n_pages,
+	ret = sg_alloc_table_from_pages(sgt, pfns_vector_pages(pfns), n_pages,
 		offset, size, GFP_KERNEL);
 	if (ret) {
 		pr_err("failed to initialize sg table\n");
 		goto fail_sgt;
 	}
 
-	/* pages are no longer needed */
-	kfree(pages);
-	pages = NULL;
-
 	sgt->nents = dma_map_sg(buf->dev, sgt->sgl, sgt->orig_nents,
 		buf->dma_dir);
 	if (sgt->nents <= 0) {
@@ -665,8 +531,12 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
 	}
 
 	buf->dma_addr = sg_dma_address(sgt->sgl);
-	buf->size = size;
 	buf->dma_sgt = sgt;
+out:
+	buf->size = size;
+	buf->pfns = pfns;
+	/* Clear *ppfn so that the caller doesn't free the pfn vector */
+	*ppfn = NULL;
 
 	return buf;
 
@@ -674,24 +544,11 @@ fail_map_sg:
 	dma_unmap_sg(buf->dev, sgt->sgl, sgt->orig_nents, buf->dma_dir);
 
 fail_sgt_init:
-	if (!vma_is_io(buf->vma))
-		vb2_dc_sgt_foreach_page(sgt, put_page);
 	sg_free_table(sgt);
 
 fail_sgt:
 	kfree(sgt);
 
-fail_get_user_pages:
-	if (pages && !vma_is_io(buf->vma))
-		while (n_pages)
-			put_page(pages[--n_pages]);
-
-fail_vma:
-	vb2_put_vma(buf->vma);
-
-fail_pages:
-	kfree(pages); /* kfree is NULL-proof */
-
 fail_buf:
 	kfree(buf);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
