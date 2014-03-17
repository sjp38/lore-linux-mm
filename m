Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 118136B00B2
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:44 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id x48so4972419wes.38
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ko5si10578064wjc.4.2014.03.17.12.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:43 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/9] media: vb2: Teach vb2_queue_or_prepare_buf() to get pfns for user buffers
Date: Mon, 17 Mar 2014 20:49:30 +0100
Message-Id: <1395085776-8626-4-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Teach vb2_queue_or_prepare_buf() to get pfns underlying these buffers
and propagate them down to get_userptr callback. Thus each buffer
mapping method doesn't have to get pfns independently. Also this will
remove the knowledge about mmap_sem locking from videobuf2 core.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-core.c       | 121 ++++++++++++++++++++++++-
 drivers/media/v4l2-core/videobuf2-dma-contig.c |   5 +-
 drivers/media/v4l2-core/videobuf2-dma-sg.c     |   5 +-
 drivers/media/v4l2-core/videobuf2-vmalloc.c    |   5 +-
 include/media/videobuf2-core.h                 |   4 +-
 5 files changed, 128 insertions(+), 12 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-core.c b/drivers/media/v4l2-core/videobuf2-core.c
index a127925c9d61..7cec08542fb5 100644
--- a/drivers/media/v4l2-core/videobuf2-core.c
+++ b/drivers/media/v4l2-core/videobuf2-core.c
@@ -1033,7 +1033,8 @@ static void __fill_vb2_buffer(struct vb2_buffer *vb, const struct v4l2_buffer *b
 /**
  * __qbuf_userptr() - handle qbuf of a USERPTR buffer
  */
-static int __qbuf_userptr(struct vb2_buffer *vb, const struct v4l2_buffer *b)
+static int __qbuf_userptr(struct vb2_buffer *vb, const struct v4l2_buffer *b,
+			  struct pinned_pfns **ppfns)
 {
 	struct v4l2_plane planes[VIDEO_MAX_PLANES];
 	struct vb2_queue *q = vb->vb2_queue;
@@ -1075,7 +1076,7 @@ static int __qbuf_userptr(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 
 		/* Acquire each plane's memory */
 		mem_priv = call_memop(q, get_userptr, q->alloc_ctx[plane],
-				      planes[plane].m.userptr,
+				      &ppfns[plane], planes[plane].m.userptr,
 				      planes[plane].length, write);
 		if (IS_ERR_OR_NULL(mem_priv)) {
 			dprintk(1, "qbuf: failed acquiring userspace "
@@ -1247,10 +1248,116 @@ static void __enqueue_in_driver(struct vb2_buffer *vb)
 	q->ops->buf_queue(vb);
 }
 
+static struct pinned_pfns *vb2_create_one_pfnvec(struct v4l2_buffer *buf,
+				unsigned long vaddr,
+				unsigned int length)
+{
+	int ret;
+	unsigned long first, last;
+	unsigned long nr;
+	struct pinned_pfns *pfns;
+
+	first = vaddr >> PAGE_SHIFT;
+	last = (vaddr + length - 1) >> PAGE_SHIFT;
+	nr = last - first + 1;
+	pfns = pfns_vector_create(nr);
+	if (!pfns)
+		return ERR_PTR(-ENOMEM);
+	ret = get_vaddr_pfns(vaddr, nr, !V4L2_TYPE_IS_OUTPUT(buf->type), 1,
+			     pfns);
+	if (ret < 0)
+		goto out_destroy;
+	/* We accept only complete set of PFNs */
+	if (ret != nr) {
+		ret = -EFAULT;
+		goto out_release;
+	}
+	return pfns;
+out_release:
+	put_vaddr_pfns(pfns);
+out_destroy:
+	pfns_vector_destroy(pfns);
+	return ERR_PTR(ret);
+}
+
+/* Create PFN vecs for all provided user buffers. */
+static struct pinned_pfns **vb2_get_user_pfns(struct v4l2_buffer *buf,
+			    		      struct pinned_pfns **tmp_store)
+{
+	struct pinned_pfns **ppfns;
+	int count = 0;
+	int i;
+	struct pinned_pfns *ret;
+
+	if (V4L2_TYPE_IS_MULTIPLANAR(buf->type)) {
+		if (buf->length == 0)
+			return NULL;
+
+		count = buf->length;
+
+		ppfns = kzalloc(sizeof(struct pinned_pfns *) * count,
+				GFP_KERNEL);
+		if (!ppfns)
+			return ERR_PTR(-ENOMEM);
+
+		for (i = 0; i < count; i++) {
+			ret = vb2_create_one_pfnvec(buf,
+					buf->m.planes[i].m.userptr,
+					buf->m.planes[i].length);
+			if (IS_ERR(ret))
+				goto out_release;
+			ppfns[i] = ret;
+		}
+	} else {
+		count = 1;
+
+		/* Save one kmalloc for the simple case */
+		ppfns = tmp_store;
+		ppfns[0] = vb2_create_one_pfnvec(buf, buf->m.userptr,
+						 buf->length);
+		if (IS_ERR(ppfns[0]))
+			return ppfns[0];
+	}
+
+	return ppfns;
+out_release:
+	for (i = 0; i < count && ppfns[i]; i++) {
+		put_vaddr_pfns(ppfns[i]);
+		pfns_vector_destroy(ppfns[i]);
+	}
+	kfree(ppfns);
+	return ret;
+}
+
+/* Release PFN vecs the call did not consume */
+static void vb2_put_user_pfns(struct v4l2_buffer *buf,
+			      struct pinned_pfns **ppfns,
+			      struct pinned_pfns **tmp_store)
+{
+	int i;
+	int count;
+
+	if (V4L2_TYPE_IS_MULTIPLANAR(buf->type))
+		count = buf->length;
+	else
+		count = 1;
+
+	for (i = 0; i < count; i++)
+		if (ppfns[i]) {
+			put_vaddr_pfns(ppfns[i]);
+			pfns_vector_destroy(ppfns[i]);
+		}
+
+	if (ppfns != tmp_store)
+		kfree(ppfns);
+}
+
 static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 {
 	struct vb2_queue *q = vb->vb2_queue;
-	struct rw_semaphore *mmap_sem;
+	struct rw_semaphore *mmap_sem = NULL;
+	struct pinned_pfns *tmp_store;
+	struct pinned_pfns **ppfns = NULL;
 	int ret;
 
 	ret = __verify_length(vb, b);
@@ -1280,11 +1387,15 @@ static int __buf_prepare(struct vb2_buffer *vb, const struct v4l2_buffer *b)
 		 */
 		mmap_sem = &current->mm->mmap_sem;
 		call_qop(q, wait_prepare, q);
+		ppfns = vb2_get_user_pfns(b, &tmp_store);
 		down_read(mmap_sem);
 		call_qop(q, wait_finish, q);
 
-		ret = __qbuf_userptr(vb, b);
-
+		if (!IS_ERR(ppfns)) {
+			ret = __qbuf_userptr(vb, b, ppfns);
+			vb2_put_user_pfns(b, ppfns, &tmp_store);
+		} else
+			ret = PTR_ERR(ppfns);
 		up_read(mmap_sem);
 		break;
 	case V4L2_MEMORY_DMABUF:
diff --git a/drivers/media/v4l2-core/videobuf2-dma-contig.c b/drivers/media/v4l2-core/videobuf2-dma-contig.c
index 33d3871d1e13..c6378d943b89 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-contig.c
@@ -547,8 +547,9 @@ static inline dma_addr_t vb2_dc_pfn_to_dma(struct device *dev, unsigned long pfn
 }
 #endif
 
-static void *vb2_dc_get_userptr(void *alloc_ctx, unsigned long vaddr,
-	unsigned long size, int write)
+static void *vb2_dc_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
+				unsigned long vaddr, unsigned long size,
+				int write)
 {
 	struct vb2_dc_conf *conf = alloc_ctx;
 	struct vb2_dc_buf *buf;
diff --git a/drivers/media/v4l2-core/videobuf2-dma-sg.c b/drivers/media/v4l2-core/videobuf2-dma-sg.c
index c779f210d2c6..ef0b3f765d8e 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
@@ -161,8 +161,9 @@ static inline int vma_is_io(struct vm_area_struct *vma)
 	return !!(vma->vm_flags & (VM_IO | VM_PFNMAP));
 }
 
-static void *vb2_dma_sg_get_userptr(void *alloc_ctx, unsigned long vaddr,
-				    unsigned long size, int write)
+static void *vb2_dma_sg_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
+				    unsigned long vaddr, unsigned long size,
+				    int write)
 {
 	struct vb2_dma_sg_buf *buf;
 	unsigned long first, last;
diff --git a/drivers/media/v4l2-core/videobuf2-vmalloc.c b/drivers/media/v4l2-core/videobuf2-vmalloc.c
index 313d9771b2bc..ab38e054d1a0 100644
--- a/drivers/media/v4l2-core/videobuf2-vmalloc.c
+++ b/drivers/media/v4l2-core/videobuf2-vmalloc.c
@@ -69,8 +69,9 @@ static void vb2_vmalloc_put(void *buf_priv)
 	}
 }
 
-static void *vb2_vmalloc_get_userptr(void *alloc_ctx, unsigned long vaddr,
-				     unsigned long size, int write)
+static void *vb2_vmalloc_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
+				     unsigned long vaddr, unsigned long size,
+				     int write)
 {
 	struct vb2_vmalloc_buf *buf;
 	unsigned long first, last;
diff --git a/include/media/videobuf2-core.h b/include/media/videobuf2-core.h
index bef53ce555d2..98c508cae09d 100644
--- a/include/media/videobuf2-core.h
+++ b/include/media/videobuf2-core.h
@@ -85,7 +85,9 @@ struct vb2_mem_ops {
 	void		(*put)(void *buf_priv);
 	struct dma_buf *(*get_dmabuf)(void *buf_priv, unsigned long flags);
 
-	void		*(*get_userptr)(void *alloc_ctx, unsigned long vaddr,
+	void		*(*get_userptr)(void *alloc_ctx,
+					struct pinned_pfns **pfns,
+					unsigned long vaddr,
 					unsigned long size, int write);
 	void		(*put_userptr)(void *buf_priv);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
