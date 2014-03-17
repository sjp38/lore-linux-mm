Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id BA3E46B00B8
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:46 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hn9so2731557wib.4
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si5959645wix.60.2014.03.17.12.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 7/9] media: vb2: Remove unused functions
Date: Mon, 17 Mar 2014 20:49:34 +0100
Message-Id: <1395085776-8626-8-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Conversion to the use of pinned pfns made some functions unused. Remove
them. Also there's no need to lock mmap_sem in __buf_prepare() anymore.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-core.c   |   8 +-
 drivers/media/v4l2-core/videobuf2-memops.c | 114 -----------------------------
 include/media/videobuf2-memops.h           |   7 --
 3 files changed, 2 insertions(+), 127 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-core.c b/drivers/media/v4l2-core/videobuf2-core.c
index 7cec08542fb5..b77dfb3076e8 100644
--- a/drivers/media/v4l2-core/videobuf2-core.c
+++ b/drivers/media/v4l2-core/videobuf2-core.c
@@ -1355,7 +1355,6 @@ static void vb2_put_user_pfns(struct v4l2_buffer *buf,
 static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 {
 	struct vb2_queue *q = vb->vb2_queue;
-	struct rw_semaphore *mmap_sem = NULL;
 	struct pinned_pfns *tmp_store;
 	struct pinned_pfns **ppfns = NULL;
 	int ret;
@@ -1374,8 +1373,8 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 		break;
 	case V4L2_MEMORY_USERPTR:
 		/*
-		 * In case of user pointer buffers vb2 allocators need to get
-		 * direct access to userspace pages. This requires getting
+		 * In case of user pointer buffers vb2_get_user_pfns() needs to
+		 * get direct access to userspace pages. This requires getting
 		 * the mmap semaphore for read access in the current process
 		 * structure. The same semaphore is taken before calling mmap
 		 * operation, while both qbuf/prepare_buf and mmap are called
@@ -1385,10 +1384,8 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 		 * the videobuf2 core releases the driver's lock, takes
 		 * mmap_sem and then takes the driver's lock again.
 		 */
-		mmap_sem = &current->mm->mmap_sem;
 		call_qop(q, wait_prepare, q);
 		ppfns = vb2_get_user_pfns(b, &tmp_store);
-		down_read(mmap_sem);
 		call_qop(q, wait_finish, q);
 
 		if (!IS_ERR(ppfns)) {
@@ -1396,7 +1393,6 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 			vb2_put_user_pfns(b, ppfns, &tmp_store);
 		} else
 			ret = PTR_ERR(ppfns);
-		up_read(mmap_sem);
 		break;
 	case V4L2_MEMORY_DMABUF:
 		ret = __qbuf_dmabuf(vb, b);
diff --git a/drivers/media/v4l2-core/videobuf2-memops.c b/drivers/media/v4l2-core/videobuf2-memops.c
index 81c1ad8b2cf1..9b44e9af69ba 100644
--- a/drivers/media/v4l2-core/videobuf2-memops.c
+++ b/drivers/media/v4l2-core/videobuf2-memops.c
@@ -23,120 +23,6 @@
 #include <media/videobuf2-memops.h>
 
 /**
- * vb2_get_vma() - acquire and lock the virtual memory area
- * @vma:	given virtual memory area
- *
- * This function attempts to acquire an area mapped in the userspace for
- * the duration of a hardware operation. The area is "locked" by performing
- * the same set of operation that are done when process calls fork() and
- * memory areas are duplicated.
- *
- * Returns a copy of a virtual memory region on success or NULL.
- */
-struct vm_area_struct *vb2_get_vma(struct vm_area_struct *vma)
-{
-	struct vm_area_struct *vma_copy;
-
-	vma_copy = kmalloc(sizeof(*vma_copy), GFP_KERNEL);
-	if (vma_copy == NULL)
-		return NULL;
-
-	if (vma->vm_ops && vma->vm_ops->open)
-		vma->vm_ops->open(vma);
-
-	if (vma->vm_file)
-		get_file(vma->vm_file);
-
-	memcpy(vma_copy, vma, sizeof(*vma));
-
-	vma_copy->vm_mm = NULL;
-	vma_copy->vm_next = NULL;
-	vma_copy->vm_prev = NULL;
-
-	return vma_copy;
-}
-EXPORT_SYMBOL_GPL(vb2_get_vma);
-
-/**
- * vb2_put_userptr() - release a userspace virtual memory area
- * @vma:	virtual memory region associated with the area to be released
- *
- * This function releases the previously acquired memory area after a hardware
- * operation.
- */
-void vb2_put_vma(struct vm_area_struct *vma)
-{
-	if (!vma)
-		return;
-
-	if (vma->vm_ops && vma->vm_ops->close)
-		vma->vm_ops->close(vma);
-
-	if (vma->vm_file)
-		fput(vma->vm_file);
-
-	kfree(vma);
-}
-EXPORT_SYMBOL_GPL(vb2_put_vma);
-
-/**
- * vb2_get_contig_userptr() - lock physically contiguous userspace mapped memory
- * @vaddr:	starting virtual address of the area to be verified
- * @size:	size of the area
- * @res_paddr:	will return physical address for the given vaddr
- * @res_vma:	will return locked copy of struct vm_area for the given area
- *
- * This function will go through memory area of size @size mapped at @vaddr and
- * verify that the underlying physical pages are contiguous. If they are
- * contiguous the virtual memory area is locked and a @res_vma is filled with
- * the copy and @res_pa set to the physical address of the buffer.
- *
- * Returns 0 on success.
- */
-int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
-			   struct vm_area_struct **res_vma, dma_addr_t *res_pa)
-{
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
-	unsigned long offset, start, end;
-	unsigned long this_pfn, prev_pfn;
-	dma_addr_t pa = 0;
-
-	start = vaddr;
-	offset = start & ~PAGE_MASK;
-	end = start + size;
-
-	vma = find_vma(mm, start);
-
-	if (vma == NULL || vma->vm_end < end)
-		return -EFAULT;
-
-	for (prev_pfn = 0; start < end; start += PAGE_SIZE) {
-		int ret = follow_pfn(vma, start, &this_pfn);
-		if (ret)
-			return ret;
-
-		if (prev_pfn == 0)
-			pa = this_pfn << PAGE_SHIFT;
-		else if (this_pfn != prev_pfn + 1)
-			return -EFAULT;
-
-		prev_pfn = this_pfn;
-	}
-
-	/*
-	 * Memory is contigous, lock vma and return to the caller
-	 */
-	*res_vma = vb2_get_vma(vma);
-	if (*res_vma == NULL)
-		return -ENOMEM;
-
-	*res_pa = pa + offset;
-	return 0;
-}
-EXPORT_SYMBOL_GPL(vb2_get_contig_userptr);
-
-/**
  * vb2_common_vm_open() - increase refcount of the vma
  * @vma:	virtual memory region for the mapping
  *
diff --git a/include/media/videobuf2-memops.h b/include/media/videobuf2-memops.h
index f05444ca8c0c..efab6dc53b52 100644
--- a/include/media/videobuf2-memops.h
+++ b/include/media/videobuf2-memops.h
@@ -30,11 +30,4 @@ struct vb2_vmarea_handler {
 
 extern const struct vm_operations_struct vb2_common_vm_ops;
 
-int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
-			   struct vm_area_struct **res_vma, dma_addr_t *res_pa);
-
-struct vm_area_struct *vb2_get_vma(struct vm_area_struct *vma);
-void vb2_put_vma(struct vm_area_struct *vma);
-
-
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
