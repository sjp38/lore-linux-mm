Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 93CD16B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:00 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so944746pbc.23
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:00 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 04/26] drm: Convert via driver to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:45 +0200
Message-Id: <1380724087-13927-5-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org

CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/gpu/drm/via/via_dmablit.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 8b0f25904e6d..7e3766667d78 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -238,14 +238,10 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	vsg->pages = vzalloc(sizeof(struct page *) * vsg->num_pages);
 	if (NULL == vsg->pages)
 		return -ENOMEM;
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm,
-			     (unsigned long)xfer->mem_addr,
-			     vsg->num_pages,
-			     (vsg->direction == DMA_FROM_DEVICE),
-			     0, vsg->pages, NULL);
-
-	up_read(&current->mm->mmap_sem);
+	ret = get_user_pages_fast((unsigned long)xfer->mem_addr,
+				  vsg->num_pages,
+				  (vsg->direction == DMA_FROM_DEVICE),
+				  vsg->pages);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
