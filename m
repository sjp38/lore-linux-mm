Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2BCCE6B0081
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:24:59 -0400 (EDT)
Received: by obhx4 with SMTP id x4so5179850obh.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 09:24:58 -0700 (PDT)
From: Rob Clark <rob.clark@linaro.org>
Subject: [PATCH 2/2] dma-buf: add helpers for attacher dma-parms
Date: Thu, 19 Jul 2012 11:23:34 -0500
Message-Id: <1342715014-5316-3-git-send-email-rob.clark@linaro.org>
In-Reply-To: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
References: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: patches@linaro.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, t.stanislaws@samsung.com, sumit.semwal@ti.com, maarten.lankhorst@canonical.com, Rob Clark <rob@ti.com>

From: Rob Clark <rob@ti.com>

Add some helpers to iterate through all attachers and get the most
restrictive segment size/count/boundary.

Signed-off-by: Rob Clark <rob@ti.com>
---
 drivers/base/dma-buf.c  |   63 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dma-buf.h |   19 ++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/drivers/base/dma-buf.c b/drivers/base/dma-buf.c
index 24e88fe..757ee20 100644
--- a/drivers/base/dma-buf.c
+++ b/drivers/base/dma-buf.c
@@ -192,6 +192,69 @@ void dma_buf_put(struct dma_buf *dmabuf)
 EXPORT_SYMBOL_GPL(dma_buf_put);
 
 /**
+ * dma_buf_max_seg_size - helper for exporters to get the minimum of
+ * all attached device's max segment size
+ */
+unsigned int dma_buf_max_seg_size(struct dma_buf *dmabuf)
+{
+	struct dma_buf_attachment *attach;
+	unsigned int max = (unsigned int)-1;
+
+	if (WARN_ON(!dmabuf))
+		return 0;
+
+	mutex_lock(&dmabuf->lock);
+	list_for_each_entry(attach, &dmabuf->attachments, node)
+		max = min(max, dma_get_max_seg_size(attach->dev));
+	mutex_unlock(&dmabuf->lock);
+
+	return max;
+}
+EXPORT_SYMBOL_GPL(dma_buf_max_seg_size);
+
+/**
+ * dma_buf_max_seg_count - helper for exporters to get the minimum of
+ * all attached device's max segment count
+ */
+unsigned int dma_buf_max_seg_count(struct dma_buf *dmabuf)
+{
+	struct dma_buf_attachment *attach;
+	unsigned int max = (unsigned int)-1;
+
+	if (WARN_ON(!dmabuf))
+		return 0;
+
+	mutex_lock(&dmabuf->lock);
+	list_for_each_entry(attach, &dmabuf->attachments, node)
+		max = min(max, dma_get_max_seg_count(attach->dev));
+	mutex_unlock(&dmabuf->lock);
+
+	return max;
+}
+EXPORT_SYMBOL_GPL(dma_buf_max_seg_count);
+
+/**
+ * dma_buf_get_seg_boundary - helper for exporters to get the most
+ * restrictive segment alignment of all the attached devices
+ */
+unsigned int dma_buf_get_seg_boundary(struct dma_buf *dmabuf)
+{
+	struct dma_buf_attachment *attach;
+	unsigned int mask = (unsigned int)-1;
+
+	if (WARN_ON(!dmabuf))
+		return 0;
+
+	mutex_lock(&dmabuf->lock);
+	list_for_each_entry(attach, &dmabuf->attachments, node)
+		mask &= dma_get_seg_boundary(attach->dev);
+	mutex_unlock(&dmabuf->lock);
+
+	return mask;
+}
+EXPORT_SYMBOL_GPL(dma_buf_get_seg_boundary);
+
+/**
  * dma_buf_attach - Add the device to dma_buf's attachments list; optionally,
  * calls attach() of dma_buf_ops to allow device-specific attach functionality
  * @dmabuf:	[in]	buffer to attach device to.
diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
index eb48f38..9533b9b 100644
--- a/include/linux/dma-buf.h
+++ b/include/linux/dma-buf.h
@@ -167,6 +167,10 @@ int dma_buf_fd(struct dma_buf *dmabuf, int flags);
 struct dma_buf *dma_buf_get(int fd);
 void dma_buf_put(struct dma_buf *dmabuf);
 
+unsigned int dma_buf_max_seg_size(struct dma_buf *dmabuf);
+unsigned int dma_buf_max_seg_count(struct dma_buf *dmabuf);
+unsigned int dma_buf_get_seg_boundary(struct dma_buf *dmabuf);
+
 struct sg_table *dma_buf_map_attachment(struct dma_buf_attachment *,
 					enum dma_data_direction);
 void dma_buf_unmap_attachment(struct dma_buf_attachment *, struct sg_table *,
@@ -220,6 +224,21 @@ static inline void dma_buf_put(struct dma_buf *dmabuf)
 	return;
 }
 
+static inline unsigned int dma_buf_max_seg_size(struct dma_buf *dmabuf)
+{
+	return 0;
+}
+
+static inline unsigned int dma_buf_max_seg_count(struct dma_buf *dmabuf)
+{
+	return 0;
+}
+
+static inline unsigned int dma_buf_get_seg_boundary(struct dma_buf *dmabuf)
+{
+	return 0;
+}
+
 static inline struct sg_table *dma_buf_map_attachment(
 	struct dma_buf_attachment *attach, enum dma_data_direction write)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
