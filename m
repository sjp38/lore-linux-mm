Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCB56B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 16:50:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id v66so18627246wrc.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:50:19 -0800 (PST)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id j34si5778376wre.209.2017.02.27.13.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 13:50:18 -0800 (PST)
Received: by mail-wr0-x242.google.com with SMTP id q39so11982606wrb.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:50:18 -0800 (PST)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH RESEND] drm/via: use get_user_pages_unlocked()
Date: Mon, 27 Feb 2017 21:50:08 +0000
Message-Id: <20170227215008.21457-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 1a3ad769f8c8..98aae9809249 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -238,13 +238,9 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
 	if (NULL == vsg->pages)
 		return -ENOMEM;
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages((unsigned long)xfer->mem_addr,
-			     vsg->num_pages,
-			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
-			     vsg->pages, NULL);
-
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_unlocked((unsigned long)xfer->mem_addr,
+			vsg->num_pages, vsg->pages,
+			(vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
