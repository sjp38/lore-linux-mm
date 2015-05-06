Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 21FE26B0074
	for <linux-mm@kvack.org>; Wed,  6 May 2015 03:28:28 -0400 (EDT)
Received: by wizk4 with SMTP id k4so190706882wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:28:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si20675wjs.183.2015.05.06.00.28.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 00:28:25 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/9] [media] vb2: Push mmap_sem down to memops
Date: Wed,  6 May 2015 09:28:08 +0200
Message-Id: <1430897296-5469-2-git-send-email-jack@suse.cz>
In-Reply-To: <1430897296-5469-1-git-send-email-jack@suse.cz>
References: <1430897296-5469-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, dri-devel@lists.freedesktop.org, Pawel Osciak <pawel@osciak.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, mgorman@suse.de, Marek Szyprowski <m.szyprowski@samsung.com>, linux-samsung-soc@vger.kernel.org, Jan Kara <jack@suse.cz>

Currently vb2 core acquires mmap_sem just around call to
__qbuf_userptr(). However since commit f035eb4e976ef5 (videobuf2: fix
lockdep warning) it isn't necessary to acquire it so early as we no
longer have to drop queue mutex before acquiring mmap_sem. So push
acquisition of mmap_sem down into .get_userptr and .put_userptr memops
so that the semaphore is acquired for a shorter time and it is clearer
what it is needed for.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-core.c       | 2 --
 drivers/media/v4l2-core/videobuf2-dma-contig.c | 7 +++++++
 drivers/media/v4l2-core/videobuf2-dma-sg.c     | 6 ++++++
 drivers/media/v4l2-core/videobuf2-vmalloc.c    | 6 +++++-
 4 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-core.c b/drivers/media/v4l2-core/videobuf2-core.c
index 66ada01c796c..20cdbc0900ea 100644
--- a/drivers/media/v4l2-core/videobuf2-core.c
+++ b/drivers/media/v4l2-core/videobuf2-core.c
@@ -1657,9 +1657,7 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 		ret = __qbuf_mmap(vb, b);
 		break;
 	case V4L2_MEMORY_USERPTR:
-		down_read(&current->mm->mmap_sem);
 		ret = __qbuf_userptr(vb, b);
-		up_read(&current->mm->mmap_sem);
 		break;
 	case V4L2_MEMORY_DMABUF:
 		ret = __qbuf_dmabuf(vb, b);
diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index 644dec73d220..620c4aa78881 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -532,7 +532,9 @@ static void vb2_dc_put_userptr(void *buf_priv)
 		sg_free_table(sgt);
 		kfree(sgt);
 	}
+	down_read(&current->mm->mmap_sem);
 	vb2_put_vma(buf->vma);
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 }
 
@@ -616,6 +618,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 		goto fail_buf;
 	}
 
+	down_read(&current->mm->mmap_sem);
 	/* current->mm->mmap_sem is taken by videobuf2 core */
 	vma = find_vma(current->mm, vaddr);
 	if (!vma) {
@@ -642,6 +645,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	if (ret) {
 		unsigned long pfn;
 		if (vb2_dc_get_user_pfn(start, n_pages, vma, &pfn) == 0) {
+			up_read(&current->mm->mmap_sem);
 			buf->dma_addr = vb2_dc_pfn_to_dma(buf->dev, pfn);
 			buf->size = size;
 			kfree(pages);
@@ -651,6 +655,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 		pr_err("failed to get user pages\n");
 		goto fail_vma;
 	}
+	up_read(&current->mm->mmap_sem);
 
 	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
 	if (!sgt) {
@@ -713,10 +718,12 @@ fail_get_user_pages:
 		while (n_pages)
 			put_page(pages[--n_pages]);
 
+	down_read(&current->mm->mmap_sem);
 fail_vma:
 	vb2_put_vma(buf->vma);
 
 fail_pages:
+	up_read(&current->mm->mmap_sem);
 	kfree(pages); /* kfree is NULL-proof */
 
 fail_buf:
diff --git a/drivers/media/v4l2-core/videobuf2-dma-sg.c b/drivers/media/v4l2-core/videobuf2-dma-sg.c
index 45c708e463b9..afd4b514affc 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
@@ -263,6 +263,7 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	if (!buf->pages)
 		goto userptr_fail_alloc_pages;
 
+	down_read(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, vaddr);
 	if (!vma) {
 		dprintk(1, "no vma for address %lu\n", vaddr);
@@ -301,6 +302,7 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 					     1, /* force */
 					     buf->pages,
 					     NULL);
+	up_read(&current->mm->mmap_sem);
 
 	if (num_pages_from_user != buf->num_pages)
 		goto userptr_fail_get_user_pages;
@@ -328,8 +330,10 @@ userptr_fail_get_user_pages:
 	if (!vma_is_io(buf->vma))
 		while (--num_pages_from_user >= 0)
 			put_page(buf->pages[num_pages_from_user]);
+	down_read(&current->mm->mmap_sem);
 	vb2_put_vma(buf->vma);
 userptr_fail_find_vma:
+	up_read(&current->mm->mmap_sem);
 	kfree(buf->pages);
 userptr_fail_alloc_pages:
 	kfree(buf);
@@ -362,7 +366,9 @@ static void vb2_dma_sg_put_userptr(void *buf_priv)
 			put_page(buf->pages[i]);
 	}
 	kfree(buf->pages);
+	down_read(&current->mm->mmap_sem);
 	vb2_put_vma(buf->vma);
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 }
 
diff --git a/drivers/media/v4l2-core/videobuf2-vmalloc.c b/drivers/media/v4l2-core/videobuf2-vmalloc.c
index 657ab302a5cf..0ba40be21ebd 100644
--- a/drivers/media/v4l2-core/videobuf2-vmalloc.c
+++ b/drivers/media/v4l2-core/videobuf2-vmalloc.c
@@ -89,7 +89,7 @@ static void *vb2_vmalloc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	offset = vaddr & ~PAGE_MASK;
 	buf->size = size;
 
-
+	down_read(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, vaddr);
 	if (vma && (vma->vm_flags & VM_PFNMAP) && (vma->vm_pgoff)) {
 		if (vb2_get_contig_userptr(vaddr, size, &vma, &physp))
@@ -121,6 +121,7 @@ static void *vb2_vmalloc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 		if (!buf->vaddr)
 			goto fail_get_user_pages;
 	}
+	up_read(&current->mm->mmap_sem);
 
 	buf->vaddr += offset;
 	return buf;
@@ -133,6 +134,7 @@ fail_get_user_pages:
 	kfree(buf->pages);
 
 fail_pages_array_alloc:
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 
 	return NULL;
@@ -144,6 +146,7 @@ static void vb2_vmalloc_put_userptr(void *buf_priv)
 	unsigned long vaddr = (unsigned long)buf->vaddr & PAGE_MASK;
 	unsigned int i;
 
+	down_read(&current->mm->mmap_sem);
 	if (buf->pages) {
 		if (vaddr)
 			vm_unmap_ram((void *)vaddr, buf->n_pages);
@@ -157,6 +160,7 @@ static void vb2_vmalloc_put_userptr(void *buf_priv)
 		vb2_put_vma(buf->vma);
 		iounmap((__force void __iomem *)buf->vaddr);
 	}
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
