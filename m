Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 69A386B0254
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 10:56:01 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so28071679wgk.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 07:56:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si30344756wjz.93.2015.07.13.07.55.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jul 2015 07:55:58 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 3/9] media: omap_vout: Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns()
Date: Mon, 13 Jul 2015 16:55:45 +0200
Message-Id: <1436799351-21975-4-git-send-email-jack@suse.com>
In-Reply-To: <1436799351-21975-1-git-send-email-jack@suse.com>
References: <1436799351-21975-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

From: Jan Kara <jack@suse.cz>

Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns() instead of
hand made mapping of virtual address to physical address. Also the
function leaked page reference from get_user_pages() so fix that by
properly release the reference when omap_vout_buffer_release() is
called.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/platform/omap/Kconfig     |  1 +
 drivers/media/platform/omap/omap_vout.c | 67 +++++++++++++++------------------
 2 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/drivers/media/platform/omap/Kconfig b/drivers/media/platform/omap/Kconfig
index dc2aaab54aef..217d613b0fe7 100644
--- a/drivers/media/platform/omap/Kconfig
+++ b/drivers/media/platform/omap/Kconfig
@@ -10,6 +10,7 @@ config VIDEO_OMAP2_VOUT
 	select OMAP2_DSS if HAS_IOMEM && ARCH_OMAP2PLUS
 	select OMAP2_VRFB if ARCH_OMAP2 || ARCH_OMAP3
 	select VIDEO_OMAP2_VOUT_VRFB if VIDEO_OMAP2_VOUT && OMAP2_VRFB
+	select FRAME_VECTOR
 	default n
 	---help---
 	  V4L2 Display driver support for OMAP2/3 based boards.
diff --git a/drivers/media/platform/omap/omap_vout.c b/drivers/media/platform/omap/omap_vout.c
index f09c5f17a42f..b0dad941f7cb 100644
--- a/drivers/media/platform/omap/omap_vout.c
+++ b/drivers/media/platform/omap/omap_vout.c
@@ -195,46 +195,34 @@ static int omap_vout_try_format(struct v4l2_pix_format *pix)
 }
 
 /*
- * omap_vout_uservirt_to_phys: This inline function is used to convert user
- * space virtual address to physical address.
+ * omap_vout_get_userptr: Convert user space virtual address to physical
+ * address.
  */
-static unsigned long omap_vout_uservirt_to_phys(unsigned long virtp)
+static int omap_vout_get_userptr(struct videobuf_buffer *vb, u32 virtp,
+				 u32 *physp)
 {
-	unsigned long physp = 0;
-	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
+	struct frame_vector *vec;
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
+	vec = frame_vector_create(1);
+	if (!vec)
+		return -ENOMEM;
 
-		if (res == nr_pages) {
-			physp =  __pa(page_address(&pages[0]) +
-					(virtp & ~PAGE_MASK));
-		} else {
-			printk(KERN_WARNING VOUT_NAME
-					"get_user_pages failed\n");
-			return 0;
-		}
+	ret = get_vaddr_frames(virtp, 1, true, false, vec);
+	if (ret != 1) {
+		frame_vector_destroy(vec);
+		return -EINVAL;
 	}
+	*physp = __pfn_to_phys(frame_vector_pfns(vec)[0]);
+	vb->priv = vec;
 
-	return physp;
+	return 0;
 }
 
 /*
@@ -784,11 +772,15 @@ static int omap_vout_buffer_prepare(struct videobuf_queue *q,
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
 		unsigned long addr, dma_addr;
 		unsigned long size;
@@ -837,9 +829,12 @@ static void omap_vout_buffer_release(struct videobuf_queue *q,
 	struct omap_vout_device *vout = q->priv_data;
 
 	vb->state = VIDEOBUF_NEEDS_INIT;
+	if (vb->memory == V4L2_MEMORY_USERPTR && vb->priv) {
+		struct frame_vector *vec = vb->priv;
 
-	if (V4L2_MEMORY_MMAP != vout->memory)
-		return;
+		put_vaddr_frames(vec);
+		frame_vector_destroy(vec);
+	}
 }
 
 /*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
