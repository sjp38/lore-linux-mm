Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A9DDD6B006E
	for <linux-mm@kvack.org>; Tue,  5 May 2015 12:01:31 -0400 (EDT)
Received: by widdi4 with SMTP id di4so152595418wid.0
        for <linux-mm@kvack.org>; Tue, 05 May 2015 09:01:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk5si17707008wib.21.2015.05.05.09.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 May 2015 09:01:23 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 7/9] media: vb2: Convert vb2_dc_get_userptr() to use frame vector
Date: Tue,  5 May 2015 18:01:16 +0200
Message-Id: <1430841678-11117-8-git-send-email-jack@suse.cz>
In-Reply-To: <1430841678-11117-1-git-send-email-jack@suse.cz>
References: <1430841678-11117-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, Jan Kara <jack@suse.cz>

Convert vb2_dc_get_userptr() to use frame vector infrastructure. When we
are doing that there's no need to allocate page array and some code can
be simplified.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-dma-contig.c | 214 ++++---------------------
 1 file changed, 34 insertions(+), 180 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index 620c4aa78881..e6cea452302b 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -32,15 +32,13 @@ struct vb2_dc_buf {
 	dma_addr_t			dma_addr;
 	enum dma_data_direction		dma_dir;
 	struct sg_table			*dma_sgt;
+	struct frame_vector		*vec;
 
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
@@ -429,92 +409,12 @@ static struct dma_buf *vb2_dc_get_dmabuf(void *buf_priv, unsigned long flags)
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
-	int n_pages, struct vm_area_struct *vma,
-	enum dma_data_direction dma_dir)
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
-			n_pages, dma_dir == DMA_FROM_DEVICE, 1, pages, NULL);
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
-
 static void vb2_dc_put_userptr(void *buf_priv)
 {
 	struct vb2_dc_buf *buf = buf_priv;
 	struct sg_table *sgt = buf->dma_sgt;
+	int i;
+	struct page **pages;
 
 	if (sgt) {
 		DEFINE_DMA_ATTRS(attrs);
@@ -526,15 +426,15 @@ static void vb2_dc_put_userptr(void *buf_priv)
 		 */
 		dma_unmap_sg_attrs(buf->dev, sgt->sgl, sgt->orig_nents,
 				   buf->dma_dir, &attrs);
-		if (!vma_is_io(buf->vma))
-			vb2_dc_sgt_foreach_page(sgt, vb2_dc_put_dirty_page);
-
+		pages = frame_vector_pages(buf->vec);
+		/* sgt should exist only if vector contains pages... */
+		BUG_ON(IS_ERR(pages));
+		for (i = 0; i < frame_vector_count(buf->vec); i++)
+			set_page_dirty_lock(pages[i]);
 		sg_free_table(sgt);
 		kfree(sgt);
 	}
-	down_read(&current->mm->mmap_sem);
-	vb2_put_vma(buf->vma);
-	up_read(&current->mm->mmap_sem);
+	vb2_destroy_framevec(buf->vec);
 	kfree(buf);
 }
 
@@ -574,13 +474,10 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 {
 	struct vb2_dc_conf *conf = alloc_ctx;
 	struct vb2_dc_buf *buf;
-	unsigned long start;
-	unsigned long end;
+	struct frame_vector *vec;
 	unsigned long offset;
-	struct page **pages;
-	int n_pages;
+	int n_pages, i;
 	int ret = 0;
-	struct vm_area_struct *vma;
 	struct sg_table *sgt;
 	unsigned long contig_size;
 	unsigned long dma_align = dma_get_cache_alignment();
@@ -606,75 +503,43 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	buf->dev = conf->dev;
 	buf->dma_dir = dma_dir;
 
-	start = vaddr & PAGE_MASK;
 	offset = vaddr & ~PAGE_MASK;
-	end = PAGE_ALIGN(vaddr + size);
-	n_pages = (end - start) >> PAGE_SHIFT;
-
-	pages = kmalloc(n_pages * sizeof(pages[0]), GFP_KERNEL);
-	if (!pages) {
-		ret = -ENOMEM;
-		pr_err("failed to allocate pages table\n");
+	vec = vb2_create_framevec(vaddr, size, dma_dir == DMA_FROM_DEVICE);
+	if (IS_ERR(vec)) {
+		ret = PTR_ERR(vec);
 		goto fail_buf;
 	}
+	buf->vec = vec;
+	n_pages = frame_vector_count(vec);
+	ret = frame_vector_to_pages(vec);
+	if (ret < 0) {
+		unsigned long *nums = frame_vector_pfns(vec);
 
-	down_read(&current->mm->mmap_sem);
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
-
-	buf->vma = vb2_get_vma(vma);
-	if (!buf->vma) {
-		pr_err("failed to copy vma\n");
-		ret = -ENOMEM;
-		goto fail_pages;
-	}
-
-	/* extract page list from userspace mapping */
-	ret = vb2_dc_get_user_pages(start, pages, n_pages, vma, dma_dir);
-	if (ret) {
-		unsigned long pfn;
-		if (vb2_dc_get_user_pfn(start, n_pages, vma, &pfn) == 0) {
-			up_read(&current->mm->mmap_sem);
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
+		 * contiguous and use direct mapping
+		 */
+		for (i = 1; i < n_pages; i++)
+			if (nums[i-1] + 1 != nums[i])
+				goto fail_pfnvec;
+		buf->dma_addr = vb2_dc_pfn_to_dma(buf->dev, nums[0]);
+		goto out;
 	}
-	up_read(&current->mm->mmap_sem);
 
 	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
 	if (!sgt) {
 		pr_err("failed to allocate sg table\n");
 		ret = -ENOMEM;
-		goto fail_get_user_pages;
+		goto fail_pfnvec;
 	}
 
-	ret = sg_alloc_table_from_pages(sgt, pages, n_pages,
+	ret = sg_alloc_table_from_pages(sgt, frame_vector_pages(vec), n_pages,
 		offset, size, GFP_KERNEL);
 	if (ret) {
 		pr_err("failed to initialize sg table\n");
 		goto fail_sgt;
 	}
 
-	/* pages are no longer needed */
-	kfree(pages);
-	pages = NULL;
-
 	/*
 	 * No need to sync to the device, this will happen later when the
 	 * prepare() memop is called.
@@ -696,8 +561,9 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	}
 
 	buf->dma_addr = sg_dma_address(sgt->sgl);
-	buf->size = size;
 	buf->dma_sgt = sgt;
+out:
+	buf->size = size;
 
 	return buf;
 
@@ -706,25 +572,13 @@ fail_map_sg:
 			   buf->dma_dir, &attrs);
 
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
-	down_read(&current->mm->mmap_sem);
-fail_vma:
-	vb2_put_vma(buf->vma);
-
-fail_pages:
-	up_read(&current->mm->mmap_sem);
-	kfree(pages); /* kfree is NULL-proof */
+fail_pfnvec:
+	vb2_destroy_framevec(vec);
 
 fail_buf:
 	kfree(buf);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
