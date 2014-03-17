Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id B6ECA6B00B7
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:45 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so5057908wes.15
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dr11si7815352wid.3.2014.03.17.12.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:43 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/9] media: omap_vout: Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns()
Date: Mon, 17 Mar 2014 20:49:29 +0100
Message-Id: <1395085776-8626-3-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns() instead of
hand made mapping of virtual address to physical address. Also the
function leaked page reference from get_user_pages() so fix that by
properly release the reference when omap_vout_buffer_release() is
called.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/platform/omap/omap_vout.c | 63 +++++++++++++++------------------
 1 file changed, 29 insertions(+), 34 deletions(-)

diff --git a/drivers/media/platform/omap/omap_vout.c b/drivers/media/platform/omap/omap_vout.c
index dfd0a21a0658..8c5803e4ce15 100644
--- a/drivers/media/platform/omap/omap_vout.c
+++ b/drivers/media/platform/omap/omap_vout.c
@@ -199,43 +199,31 @@ static int omap_vout_try_format(struct v4l2_pix_format *pix)
  * omap_vout_uservirt_to_phys: This inline function is used to convert user
  * space virtual address to physical address.
  */
-static u32 omap_vout_uservirt_to_phys(u32 virtp)
+static int omap_vout_get_userptr(struct videobuf_buffer *vb, u32 virtp,
+				 u32 *physp)
 {
-	unsigned long physp = 0;
-	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
+	struct pinned_pfns *pfns;
+	int ret;
 
 	/* For kernel direct-mapped memory, take the easy way */
-	if (virtp >= PAGE_OFFSET)
-		return virt_to_phys((void *) virtp);
-
-	down_read(&current->mm->mmap_sem);
-	vma = find_vma(mm, virtp);
-	if (vma && (vma->vm_flags & VM_IO) && vma->vm_pgoff) {
-		/* this will catch, kernel-allocated, mmaped-to-usermode
-		   addresses */
-		physp = (vma->vm_pgoff << PAGE_SHIFT) + (virtp - vma->vm_start);
-		up_read(&current->mm->mmap_sem);
-	} else {
-		/* otherwise, use get_user_pages() for general userland pages */
-		int res, nr_pages = 1;
-		struct page *pages;
+	if (virtp >= PAGE_OFFSET) {
+		*physp = virt_to_phys((void *)virtp);
+		return 0;
+	}
 
-		res = get_user_pages(current, current->mm, virtp, nr_pages, 1,
-				0, &pages, NULL);
-		up_read(&current->mm->mmap_sem);
+	pfns = pfns_vector_create(1);
+	if (!pfns)
+		return -ENOMEM;
 
-		if (res == nr_pages) {
-			physp =  __pa(page_address(&pages[0]) +
-					(virtp & ~PAGE_MASK));
-		} else {
-			printk(KERN_WARNING VOUT_NAME
-					"get_user_pages failed\n");
-			return 0;
-		}
+	ret = get_vaddr_pfns(virtp, 1, 1, 0, pfns);
+	if (ret != 1) {
+		pfns_vector_destroy(pfns);
+		return -EINVAL;
 	}
+	*physp = __pfn_to_phys(pfns_vector_pfns(pfns)[0]);
+	vb->priv = pfns;
 
-	return physp;
+	return 0;
 }
 
 /*
@@ -790,11 +778,15 @@ static int omap_vout_buffer_prepare(struct videobuf_queue *q,
 	 * address of the buffer
 	 */
 	if (V4L2_MEMORY_USERPTR == vb->memory) {
+		int ret;
+
 		if (0 == vb->baddr)
 			return -EINVAL;
 		/* Physical address */
-		vout->queued_buf_addr[vb->i] = (u8 *)
-			omap_vout_uservirt_to_phys(vb->baddr);
+		ret = omap_vout_get_userptr(vb, vb->baddr,
+				(u32 *)&vout->queued_buf_addr[vb->i]);
+		if (ret < 0)
+			return ret;
 	} else {
 		u32 addr, dma_addr;
 		unsigned long size;
@@ -843,9 +835,12 @@ static void omap_vout_buffer_release(struct videobuf_queue *q,
 	struct omap_vout_device *vout = q->priv_data;
 
 	vb->state = VIDEOBUF_NEEDS_INIT;
+	if (vb->memory == V4L2_MEMORY_USERPTR && vb->priv) {
+		struct pinned_pfns *pfns = vb->priv;
 
-	if (V4L2_MEMORY_MMAP != vout->memory)
-		return;
+		put_vaddr_pfns(pfns);
+		pfns_vector_destroy(pfns);
+	}
 }
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
