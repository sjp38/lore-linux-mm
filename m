Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 13705900016
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:57:24 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so5727177web.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:57:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq1si2869811wib.21.2015.03.17.04.57.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 04:57:02 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/9] media: vb2: Convert vb2_dma_sg_get_userptr() to use pinned pfns
Date: Tue, 17 Mar 2015 12:56:35 +0100
Message-Id: <1426593399-6549-6-git-send-email-jack@suse.cz>
In-Reply-To: <1426593399-6549-1-git-send-email-jack@suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-dma-sg.c | 97 +++++-------------------------
 1 file changed, 15 insertions(+), 82 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-dma-sg.c b/drivers/media/v4l2-core/videobuf2-dma-sg.c
index 71510e4f7d7c..cc82c30d02cf 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
@@ -38,6 +38,7 @@ struct vb2_dma_sg_buf {
 	struct device			*dev;
 	void				*vaddr;
 	struct page			**pages;
+	struct pinned_pfns		*pfns;
 	int				offset;
 	enum dma_data_direction		dma_dir;
 	struct sg_table			sg_table;
@@ -51,7 +52,6 @@ struct vb2_dma_sg_buf {
 	unsigned int			num_pages;
 	atomic_t			refcount;
 	struct vb2_vmarea_handler	handler;
-	struct vm_area_struct		*vma;
 
 	struct dma_buf_attachment	*db_attach;
 };
@@ -224,25 +224,17 @@ static void vb2_dma_sg_finish(void *buf_priv)
 	dma_sync_sg_for_cpu(buf->dev, sgt->sgl, sgt->nents, buf->dma_dir);
 }
 
-static inline int vma_is_io(struct vm_area_struct *vma)
-{
-	return !!(vma->vm_flags & (VM_IO | VM_PFNMAP));
-}
-
 static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 				    unsigned long size,
 				    enum dma_data_direction dma_dir)
 {
 	struct vb2_dma_sg_conf *conf = alloc_ctx;
 	struct vb2_dma_sg_buf *buf;
-	unsigned long first, last;
-	int num_pages_from_user;
-	struct vm_area_struct *vma;
 	struct sg_table *sgt;
 	DEFINE_DMA_ATTRS(attrs);
+	struct pinned_pfns *pfns;
 
 	dma_set_attr(DMA_ATTR_SKIP_CPU_SYNC, &attrs);
-
 	buf = kzalloc(sizeof *buf, GFP_KERNEL);
 	if (!buf)
 		return NULL;
@@ -253,63 +245,19 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	buf->offset = vaddr & ~PAGE_MASK;
 	buf->size = size;
 	buf->dma_sgt = &buf->sg_table;
+	pfns = vb2_create_pfnvec(vaddr, size, buf->dma_dir == DMA_FROM_DEVICE);
+	if (IS_ERR(pfns))
+		goto userptr_fail_pfnvec;
+	buf->pfns = pfns;
 
-	first = (vaddr           & PAGE_MASK) >> PAGE_SHIFT;
-	last  = ((vaddr + size - 1) & PAGE_MASK) >> PAGE_SHIFT;
-	buf->num_pages = last - first + 1;
-
-	buf->pages = kzalloc(buf->num_pages * sizeof(struct page *),
-			     GFP_KERNEL);
-	if (!buf->pages)
-		goto userptr_fail_alloc_pages;
-
-	down_read(&current->mm->mmap_sem);
-	vma = find_vma(current->mm, vaddr);
-	if (!vma) {
-		dprintk(1, "no vma for address %lu\n", vaddr);
-		goto userptr_fail_find_vma;
-	}
-
-	if (vma->vm_end < vaddr + size) {
-		dprintk(1, "vma at %lu is too small for %lu bytes\n",
-			vaddr, size);
-		goto userptr_fail_find_vma;
-	}
-
-	buf->vma = vb2_get_vma(vma);
-	if (!buf->vma) {
-		dprintk(1, "failed to copy vma\n");
-		goto userptr_fail_find_vma;
-	}
-
-	if (vma_is_io(buf->vma)) {
-		for (num_pages_from_user = 0;
-		     num_pages_from_user < buf->num_pages;
-		     ++num_pages_from_user, vaddr += PAGE_SIZE) {
-			unsigned long pfn;
-
-			if (follow_pfn(vma, vaddr, &pfn)) {
-				dprintk(1, "no page for address %lu\n", vaddr);
-				break;
-			}
-			buf->pages[num_pages_from_user] = pfn_to_page(pfn);
-		}
-	} else
-		num_pages_from_user = get_user_pages(current, current->mm,
-					     vaddr & PAGE_MASK,
-					     buf->num_pages,
-					     buf->dma_dir == DMA_FROM_DEVICE,
-					     1, /* force */
-					     buf->pages,
-					     NULL);
-	up_read(&current->mm->mmap_sem);
-
-	if (num_pages_from_user != buf->num_pages)
-		goto userptr_fail_get_user_pages;
+	if (pfns_vector_to_pages(pfns))
+		goto userptr_fail_sgtable;
+	buf->pages = pfns_vector_pages(pfns);
+	buf->num_pages = pfns_vector_count(pfns);
 
 	if (sg_alloc_table_from_pages(buf->dma_sgt, buf->pages,
 			buf->num_pages, buf->offset, size, 0))
-		goto userptr_fail_alloc_table_from_pages;
+		goto userptr_fail_sgtable;
 
 	sgt = &buf->sg_table;
 	/*
@@ -323,19 +271,9 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 
 userptr_fail_map:
 	sg_free_table(&buf->sg_table);
-userptr_fail_alloc_table_from_pages:
-userptr_fail_get_user_pages:
-	dprintk(1, "get_user_pages requested/got: %d/%d]\n",
-		buf->num_pages, num_pages_from_user);
-	if (!vma_is_io(buf->vma))
-		while (--num_pages_from_user >= 0)
-			put_page(buf->pages[num_pages_from_user]);
-	down_read(&current->mm->mmap_sem);
-	vb2_put_vma(buf->vma);
-userptr_fail_find_vma:
-	up_read(&current->mm->mmap_sem);
-	kfree(buf->pages);
-userptr_fail_alloc_pages:
+userptr_fail_sgtable:
+	vb2_destroy_pfnvec(pfns);
+userptr_fail_pfnvec:
 	kfree(buf);
 	return NULL;
 }
@@ -362,13 +300,8 @@ static void vb2_dma_sg_put_userptr(void *buf_priv)
 	while (--i >= 0) {
 		if (buf->dma_dir == DMA_FROM_DEVICE)
 			set_page_dirty_lock(buf->pages[i]);
-		if (!vma_is_io(buf->vma))
-			put_page(buf->pages[i]);
 	}
-	kfree(buf->pages);
-	down_read(&current->mm->mmap_sem);
-	vb2_put_vma(buf->vma);
-	up_read(&current->mm->mmap_sem);
+	vb2_destroy_pfnvec(buf->pfns);
 	kfree(buf);
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
