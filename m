Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E7A936B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:57:01 -0400 (EDT)
Received: by wixw10 with SMTP id w10so8862549wix.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:57:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yq1si23089249wjc.153.2015.03.17.04.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 04:56:59 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 3/9] media: omap_vout: Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns()
Date: Tue, 17 Mar 2015 12:56:33 +0100
Message-Id: <1426593399-6549-4-git-send-email-jack@suse.cz>
In-Reply-To: <1426593399-6549-1-git-send-email-jack@suse.cz>
References: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

Convert omap_vout_uservirt_to_phys() to use get_vaddr_pfns() instead of
hand made mapping of virtual address to physical address. Also the
function leaked page reference from get_user_pages() so fix that by
properly release the reference when omap_vout_buffer_release() is
called.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/platform/omap/omap_vout.c | 67 +++++++++++++++------------------
 1 file changed, 31 insertions(+), 36 deletions(-)

diff --git a/drivers/media/platform/omap/omap_vout.c b/drivers/media/platform/omap/omap_vout.c
index ba2d8f973d58..e7d342bb71dd 100644
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
@@ -788,11 +776,15 @@ static int omap_vout_buffer_prepare(struct videobuf_queue *q,
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
@@ -841,9 +833,12 @@ static void omap_vout_buffer_release(struct videobuf_queue *q,
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
