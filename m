Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 75D126B0037
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:01 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1104728pab.12
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:01 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/26] omap3isp: Make isp_video_buffer_prepare_user() use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:46 +0200
Message-Id: <1380724087-13927-6-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org

CC: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
CC: linux-media@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/media/platform/omap3isp/ispqueue.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/media/platform/omap3isp/ispqueue.c b/drivers/media/platform/omap3isp/ispqueue.c
index e15f01342058..bed380395e6c 100644
--- a/drivers/media/platform/omap3isp/ispqueue.c
+++ b/drivers/media/platform/omap3isp/ispqueue.c
@@ -331,13 +331,9 @@ static int isp_video_buffer_prepare_user(struct isp_video_buffer *buf)
 	if (buf->pages == NULL)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm, data & PAGE_MASK,
-			     buf->npages,
-			     buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE, 0,
-			     buf->pages, NULL);
-	up_read(&current->mm->mmap_sem);
-
+	ret = get_user_pages_fast(data & PAGE_MASK, buf->npages,
+				  buf->vbuf.type == V4L2_BUF_TYPE_VIDEO_CAPTURE,
+				  buf->pages);
 	if (ret != buf->npages) {
 		buf->npages = ret < 0 ? 0 : ret;
 		isp_video_buffer_cleanup(buf);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
