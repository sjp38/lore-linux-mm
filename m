Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB9056B0071
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:11:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG3BdWm027537
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:11:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6630D45DE53
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:11:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 415AB45DE51
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:11:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D6521DB8041
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:11:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B0FB31DB8040
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:11:38 +0900 (JST)
Date: Wed, 16 Dec 2009 12:08:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 8/11] mm accessor for video
Message-Id: <20091216120834.0a7376a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Replacing mmap_sem with mm_accessor functions.
for driver/media/video

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/media/video/davinci/vpif_capture.c |    4 ++--
 drivers/media/video/davinci/vpif_display.c |    5 +++--
 drivers/media/video/ivtv/ivtv-udma.c       |    4 ++--
 drivers/media/video/ivtv/ivtv-yuv.c        |    4 ++--
 drivers/media/video/videobuf-core.c        |    4 ++--
 drivers/media/video/videobuf-dma-contig.c  |    4 ++--
 drivers/media/video/videobuf-dma-sg.c      |    4 ++--
 7 files changed, 15 insertions(+), 14 deletions(-)

Index: mmotm-mm-accessor/drivers/media/video/davinci/vpif_capture.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/davinci/vpif_capture.c
+++ mmotm-mm-accessor/drivers/media/video/davinci/vpif_capture.c
@@ -122,11 +122,11 @@ static inline u32 vpif_uservirt_to_phys(
 		int res, nr_pages = 1;
 			struct page *pages;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 
 		res = get_user_pages(current, current->mm,
 				     virtp, nr_pages, 1, 0, &pages, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (res == nr_pages)
 			physp = __pa(page_address(&pages[0]) +
Index: mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-udma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/ivtv/ivtv-udma.c
+++ mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-udma.c
@@ -124,10 +124,10 @@ int ivtv_udma_setup(struct ivtv *itv, un
 	}
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	err = get_user_pages(current, current->mm,
 			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
Index: mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-yuv.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/ivtv/ivtv-yuv.c
+++ mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-yuv.c
@@ -75,10 +75,10 @@ static int ivtv_yuv_prep_user_dma(struct
 	ivtv_udma_get_page_info (&uv_dma, (unsigned long)args->uv_source, 360 * uv_decode_height);
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	y_pages = get_user_pages(current, current->mm, y_dma.uaddr, y_dma.page_count, 0, 1, &dma->map[0], NULL);
 	uv_pages = get_user_pages(current, current->mm, uv_dma.uaddr, uv_dma.page_count, 0, 1, &dma->map[y_pages], NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	dma->page_count = y_dma.page_count + uv_dma.page_count;
 
Index: mmotm-mm-accessor/drivers/media/video/videobuf-core.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-core.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-core.c
@@ -485,7 +485,7 @@ int videobuf_qbuf(struct videobuf_queue 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 
 	mutex_lock(&q->vb_lock);
 	retval = -EBUSY;
@@ -575,7 +575,7 @@ int videobuf_qbuf(struct videobuf_queue 
 	mutex_unlock(&q->vb_lock);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 	return retval;
 }
Index: mmotm-mm-accessor/drivers/media/video/videobuf-dma-contig.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-dma-contig.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-dma-contig.c
@@ -147,7 +147,7 @@ static int videobuf_dma_contig_user_get(
 	mem->is_userptr = 0;
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -182,7 +182,7 @@ static int videobuf_dma_contig_user_get(
 		mem->is_userptr = 1;
 
  out_up:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/drivers/media/video/videobuf-dma-sg.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-dma-sg.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-dma-sg.c
@@ -179,9 +179,9 @@ int videobuf_dma_init_user(struct videob
 			   unsigned long data, unsigned long size)
 {
 	int ret;
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/drivers/media/video/davinci/vpif_display.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/davinci/vpif_display.c
+++ mmotm-mm-accessor/drivers/media/video/davinci/vpif_display.c
@@ -116,11 +116,12 @@ static u32 vpif_uservirt_to_phys(u32 vir
 		/* otherwise, use get_user_pages() for general userland pages */
 		int res, nr_pages = 1;
 		struct page *pages;
-		down_read(&current->mm->mmap_sem);
+
+		mm_read_lock(current->mm);
 
 		res = get_user_pages(current, current->mm,
 				     virtp, nr_pages, 1, 0, &pages, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (res == nr_pages) {
 			physp = __pa(page_address(&pages[0]) +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
