Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 055B46B00B5
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:45 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so2732886wib.14
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fs5si5961704wic.40.2014.03.17.12.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:43 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/9] media: vb2: Convert vb2_dma_sg_get_userptr() to use pinned pfns
Date: Mon, 17 Mar 2014 20:49:31 +0100
Message-Id: <1395085776-8626-5-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/v4l2-core/videobuf2-dma-sg.c | 85 ++++++------------------------
 1 file changed, 15 insertions(+), 70 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf2-dma-sg.c b/drivers/media/v4l2-core/videobuf2-dma-sg.c
index ef0b3f765d8e..a37ee0fa84d3 100644
--- a/drivers/media/v4l2-core/videobuf2-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf2-dma-sg.c
@@ -33,6 +33,7 @@ module_param(debug, int, 0644);
 struct vb2_dma_sg_buf {
 	void				*vaddr;
 	struct page			**pages;
+	struct pinned_pfns		*pfns;
 	int				write;
 	int				offset;
 	struct sg_table			sg_table;
@@ -166,9 +167,10 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
 				    int write)
 {
 	struct vb2_dma_sg_buf *buf;
-	unsigned long first, last;
-	int num_pages_from_user;
-	struct vm_area_struct *vma;
+	struct pinned_pfns *pfns = *ppfn;
+
+	if (pfns_vector_to_pages(pfns))
+		return NULL;
 
 	buf = kzalloc(sizeof *buf, GFP_KERNEL);
 	if (!buf)
@@ -178,75 +180,20 @@ static void *vb2_dma_sg_get_userptr(void *alloc_ctx, struct pinned_pfns **ppfn,
 	buf->write = write;
 	buf->offset = vaddr & ~PAGE_MASK;
 	buf->size = size;
-
-	first = (vaddr           & PAGE_MASK) >> PAGE_SHIFT;
-	last  = ((vaddr + size - 1) & PAGE_MASK) >> PAGE_SHIFT;
-	buf->num_pages = last - first + 1;
-
-	buf->pages = kzalloc(buf->num_pages * sizeof(struct page *),
-			     GFP_KERNEL);
-	if (!buf->pages)
-		goto userptr_fail_alloc_pages;
-
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
-			if (follow_pfn(buf->vma, vaddr, &pfn)) {
-				dprintk(1, "no page for address %lu\n", vaddr);
-				break;
-			}
-			buf->pages[num_pages_from_user] = pfn_to_page(pfn);
-		}
-	} else
-		num_pages_from_user = get_user_pages(current, current->mm,
-					     vaddr & PAGE_MASK,
-					     buf->num_pages,
-					     write,
-					     1, /* force */
-					     buf->pages,
-					     NULL);
-
-	if (num_pages_from_user != buf->num_pages)
-		goto userptr_fail_get_user_pages;
+	buf->pages = pfns_vector_pages(pfns);
+	buf->num_pages = pfns_vector_count(pfns);
 
 	if (sg_alloc_table_from_pages(&buf->sg_table, buf->pages,
 			buf->num_pages, buf->offset, size, 0))
-		goto userptr_fail_alloc_table_from_pages;
+		goto fail;
+
+	buf->pfns = pfns;
+	/* Clear *ppfn so that the caller doesn't free the vector */
+	*ppfn = NULL;
 
 	return buf;
 
-userptr_fail_alloc_table_from_pages:
-userptr_fail_get_user_pages:
-	dprintk(1, "get_user_pages requested/got: %d/%d]\n",
-		buf->num_pages, num_pages_from_user);
-	if (!vma_is_io(buf->vma))
-		while (--num_pages_from_user >= 0)
-			put_page(buf->pages[num_pages_from_user]);
-	vb2_put_vma(buf->vma);
-userptr_fail_find_vma:
-	kfree(buf->pages);
-userptr_fail_alloc_pages:
+fail:
 	kfree(buf);
 	return NULL;
 }
@@ -268,11 +215,9 @@ static void vb2_dma_sg_put_userptr(void *buf_priv)
 	while (--i >= 0) {
 		if (buf->write)
 			set_page_dirty_lock(buf->pages[i]);
-		if (!vma_is_io(buf->vma))
-			put_page(buf->pages[i]);
 	}
-	kfree(buf->pages);
-	vb2_put_vma(buf->vma);
+	put_vaddr_pfns(buf->pfns);
+	pfns_vector_destroy(buf->pfns);
 	kfree(buf);
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
