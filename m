Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 701E76B005A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 06:27:25 -0500 (EST)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH 2/4] dma-buf: Remove unneeded sanity checks
Date: Thu, 26 Jan 2012 12:27:23 +0100
Message-Id: <1327577245-20354-3-git-send-email-laurent.pinchart@ideasonboard.com>
In-Reply-To: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
References: <1327577245-20354-1-git-send-email-laurent.pinchart@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

ops, ops->map_dma_buf and ops->unmap_dma_buf are guaranteed to be
non-NULL by a check in dma_buf_export(). Remove NULL checks on those
variables in the other API functions.

Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
---
 drivers/base/dma-buf.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
index 965833ac..198edd8 100644
--- a/drivers/base/dma-buf.c
+++ b/drivers/base/dma-buf.c
@@ -185,7 +185,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 	struct dma_buf_attachment *attach;
 	int ret;
 
-	if (WARN_ON(!dmabuf || !dev || !dmabuf->ops))
+	if (WARN_ON(!dmabuf || !dev))
 		return ERR_PTR(-EINVAL);
 
 	attach = kzalloc(sizeof(struct dma_buf_attachment), GFP_KERNEL);
@@ -224,7 +224,7 @@ EXPORT_SYMBOL_GPL(dma_buf_attach);
  */
 void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment *attach)
 {
-	if (WARN_ON(!dmabuf || !attach || !dmabuf->ops))
+	if (WARN_ON(!dmabuf || !attach))
 		return;
 
 	mutex_lock(&dmabuf->lock);
@@ -255,12 +255,11 @@ struct sg_table *dma_buf_map_attachment(struct dma_buf_attachment *attach,
 
 	might_sleep();
 
-	if (WARN_ON(!attach || !attach->dmabuf || !attach->dmabuf->ops))
+	if (WARN_ON(!attach || !attach->dmabuf))
 		return ERR_PTR(-EINVAL);
 
 	mutex_lock(&attach->dmabuf->lock);
-	if (attach->dmabuf->ops->map_dma_buf)
-		sg_table = attach->dmabuf->ops->map_dma_buf(attach, direction);
+	sg_table = attach->dmabuf->ops->map_dma_buf(attach, direction);
 	mutex_unlock(&attach->dmabuf->lock);
 
 	return sg_table;
@@ -278,13 +277,11 @@ EXPORT_SYMBOL_GPL(dma_buf_map_attachment);
 void dma_buf_unmap_attachment(struct dma_buf_attachment *attach,
 				struct sg_table *sg_table)
 {
-	if (WARN_ON(!attach || !attach->dmabuf || !sg_table
-			    || !attach->dmabuf->ops))
+	if (WARN_ON(!attach || !attach->dmabuf || !sg_table))
 		return;
 
 	mutex_lock(&attach->dmabuf->lock);
-	if (attach->dmabuf->ops->unmap_dma_buf)
-		attach->dmabuf->ops->unmap_dma_buf(attach, sg_table);
+	attach->dmabuf->ops->unmap_dma_buf(attach, sg_table);
 	mutex_unlock(&attach->dmabuf->lock);
 
 }
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
