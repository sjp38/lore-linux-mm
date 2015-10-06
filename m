Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BFCC382F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:24:54 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so156830639wic.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:24:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw10si22310002wib.123.2015.10.06.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 3/7] drm: Convert via driver to use get_user_pages_fast()
Date: Tue,  6 Oct 2015 11:24:26 +0200
Message-Id: <1444123470-4932-4-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org

From: Jan Kara <jack@suse.cz>

CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/gpu/drm/via/via_dmablit.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index d0cbd5ecd7f0..d71add236e62 100644
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
