Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 27F446B005A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:27:28 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH 4/4] dma-buf: Move code out of mutex-protected section in dma_buf_attach()
Date: Thu, 26 Jan 2012 12:27:25 +0100
Message-Id: <1327577245-20354-5-git-send-email-laurent.pinchart@ideasonboard.com>
In-Reply-To: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

Some fields can be set without mutex protection. Initialize them before
locking the mutex.

Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
---
 drivers/base/dma-buf.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
index 97450a5..8afe2dd 100644
--- a/drivers/base/dma-buf.c
+++ b/drivers/base/dma-buf.c
@@ -192,10 +192,11 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 	if (attach == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	mutex_lock(&dmabuf->lock);
-
 	attach->dev = dev;
 	attach->dmabuf = dmabuf;
+
+	mutex_lock(&dmabuf->lock);
+
 	if (dmabuf->ops->attach) {
 		ret = dmabuf->ops->attach(dmabuf, dev, attach);
 		if (ret)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
