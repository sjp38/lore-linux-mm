Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 785226B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 10:56:00 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so32138255wib.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 07:55:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hg7si13859123wib.66.2015.07.13.07.55.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jul 2015 07:55:58 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 1/9] [media] vb2: Push mmap_sem down to memops
Date: Mon, 13 Jul 2015 16:55:43 +0200
Message-Id: <1436799351-21975-2-git-send-email-jack@suse.com>
In-Reply-To: <1436799351-21975-1-git-send-email-jack@suse.com>
References: <1436799351-21975-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

From: Jan Kara <jack@suse.cz>

Currently vb2 core acquires mmap_sem just around call to
__qbuf_userptr(). However since commit f035eb4e976ef5 (videobuf2: fix
lockdep warning) it isn't necessary to acquire it so early as we no
longer have to drop queue mutex before acquiring mmap_sem. So push
acquisition of mmap_sem down into .get_userptr memop so that the
semaphore is acquired for a shorter time and it is clearer what it is
needed for.

Note that we also need mmap_sem in .put_userptr memop since that ends up
calling vb2_put_vma() which calls vma->vm_ops->close() which should be
called with mmap_sem held. However we didn't hold mmap_sem in some code
paths anyway (e.g. when called via vb2_ioctl_reqbufs() ->
__vb2_queue_free() -> vb2_dma_sg_put_userptr()) and getting mmap_sem in
put_userptr() introduces a lock inversion with queue->mmap_lock in the
above mentioned call path.

Luckily this whole locking mess will get resolved once we convert
videobuf2 core to the new mm helper which avoids the need for mmap_sem
in .put_userptr memop altogether.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-core.c       | 2 --
 drivers/media/v4l2-core/videobuf2-dma-contig.c | 5 +++++
 drivers/media/v4l2-core/videobuf2-dma-sg.c     | 4 ++++
 drivers/media/v4l2-core/videobuf2-vmalloc.c    | 4 +++-
 4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-core.c b/drivers/media/v4l2-core/videobuf2-core.c
index 93b315459098..4df6dfc47fc8 100644
--- a/drivers/media/v4l2-core/videobuf2-core.c
+++ b/drivers/media/v4l2-core/videobuf2-core.c
@@ -1675,9 +1675,7 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
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
index 94c1e6455d36..c548ce425701 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -616,6 +616,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 		goto fail_buf;
 	}
 
+	down_read(&current->mm->mmap_sem);
 	/* current->mm->mmap_sem is taken by videobuf2 core */
 	vma = find_vma(current->mm, vaddr);
 	if (!vma) {
@@ -642,6 +643,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	if (ret) {
 		unsigned long pfn;
 		if (vb2_dc_get_user_pfn(start, n_pages, vma, &pfn) == 0) {
+			up_read(&current->mm->mmap_sem);
 			buf->dma_addr = vb2_dc_pfn_to_dma(buf->dev, pfn);
 			buf->size = size;
 			kfree(pages);
@@ -651,6 +653,7 @@ static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
 		pr_err("failed to get user pages\n");
 		goto fail_vma;
 	}
+	up_read(&current->mm->mmap_sem);
 
 	sgt = kzalloc(sizeof(*sgt), GFP_KERNEL);
 	if (!sgt) {
@@ -713,10 +716,12 @@ fail_get_user_pages:
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
index 7289b81bd7b7..d2cf113d1933 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
@@ -264,6 +264,7 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 	if (!buf->pages)
 		goto userptr_fail_alloc_pages;
 
+	down_read(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, vaddr);
 	if (!vma) {
 		dprintk(1, "no vma for address %lu\n", vaddr);
@@ -302,6 +303,7 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
 					     1, /* force */
 					     buf->pages,
 					     NULL);
+	up_read(&current->mm->mmap_sem);
 
 	if (num_pages_from_user != buf->num_pages)
 		goto userptr_fail_get_user_pages;
@@ -331,8 +333,10 @@ userptr_fail_get_user_pages:
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
diff --git a/drivers/media/v4l2-core/videobuf2-vmalloc.c b/drivers/media/v4l2-core/videobuf2-vmalloc.c
index 2fe4c27f524a..63bef959623e 100644
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
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
