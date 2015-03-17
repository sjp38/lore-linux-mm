Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 24579900016
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:57:14 -0400 (EDT)
Received: by wggv3 with SMTP id v3so6414095wgg.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:57:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id oy6si23109716wjb.128.2015.03.17.04.57.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 04:57:01 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 8/9] media: vb2: Remove unused functions
Date: Tue, 17 Mar 2015 12:56:38 +0100
Message-Id: <1426593399-6549-9-git-send-email-jack@suse.cz>
In-Reply-To: <1426593399-6549-1-git-send-email-jack@suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

Conversion to the use of pinned pfns made some functions unused. Remove
them. Also there's no need to lock mmap_sem in __buf_prepare() anymore.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-memops.c | 114 -----------------------------
 include/media/videobuf2-memops.h           |   6 --
 2 files changed, 120 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-memops.c b/drivers/media/v4l2-core/videobuf2-memops.c
index 80ade22b920c..08daaa5c4e2d 100644
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
  * vb2_create_pfnvec() - map virtual addresses to pfns
  * @start:	Virtual user address where we start mapping
  * @length:	Length of a range to map
diff --git a/include/media/videobuf2-memops.h b/include/media/videobuf2-memops.h
index 868f9c1cd92d..01b4325947f1 100644
--- a/include/media/videobuf2-memops.h
+++ b/include/media/videobuf2-memops.h
@@ -31,12 +31,6 @@ struct vb2_vmarea_handler {
 
 extern const struct vm_operations_struct vb2_common_vm_ops;
 
-int vb2_get_contig_userptr(unsigned long vaddr, unsigned long size,
-			   struct vm_area_struct **res_vma, dma_addr_t *res_pa);
-
-struct vm_area_struct *vb2_get_vma(struct vm_area_struct *vma);
-void vb2_put_vma(struct vm_area_struct *vma);
-
 struct pinned_pfns *vb2_create_pfnvec(unsigned long start, unsigned long length,
 				      bool write);
 void vb2_destroy_pfnvec(struct pinned_pfns *pfns);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
