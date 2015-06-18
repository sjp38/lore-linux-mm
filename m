Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4AD6B007D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:08:59 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so61836391wic.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:08:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hn8si14193464wjb.19.2015.06.18.07.08.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 07:08:49 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/10] [media] vb2: Push mmap_sem down to memops
Date: Thu, 18 Jun 2015 16:08:31 +0200
Message-Id: <1434636520-25116-2-git-send-email-jack@suse.cz>
In-Reply-To: <1434636520-25116-1-git-send-email-jack@suse.cz>
References: <1434636520-25116-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

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
index 644dec73d220..8e660f033d3c 100644
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
index 45c708e463b9..cdcf5ad79012 100644
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
diff --git a/drivers/media/v4l2-core/videobuf2-vmalloc.c b/drivers/media/v4l2-core/videobuf2-vmalloc.c
index 657ab302a5cf..3199c379cd47 100644
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
