Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 573946B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:26:16 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so17086409pab.11
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:26:16 -0800 (PST)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id d5si744902pdp.58.2015.01.27.00.26.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 00:26:15 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so17136931pac.2
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:26:15 -0800 (PST)
From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: [RFCv3 1/2] device: add dma_params->max_segment_count
Date: Tue, 27 Jan 2015 13:55:53 +0530
Message-Id: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: linaro-kernel@lists.linaro.org, robdclark@gmail.com, daniel@ffwll.ch, m.szyprowski@samsung.com, stanislawski.tomasz@googlemail.com, robin.murphy@arm.com, Sumit Semwal <sumit.semwal@linaro.org>

From: Rob Clark <robdclark@gmail.com>

For devices which have constraints about maximum number of segments in
an sglist.  For example, a device which could only deal with contiguous
buffers would set max_segment_count to 1.

The initial motivation is for devices sharing buffers via dma-buf,
to allow the buffer exporter to know the constraints of other
devices which have attached to the buffer.  The dma_mask and fields
in 'struct device_dma_parameters' tell the exporter everything else
that is needed, except whether the importer has constraints about
maximum number of segments.

Signed-off-by: Rob Clark <robdclark@gmail.com>
 [sumits: Minor updates wrt comments]
Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
---

v3: include Robin Murphy's fix[1] for handling '0' as a value for
     max_segment_count
v2: minor updates wrt comments on the first version

[1]: http://article.gmane.org/gmane.linux.kernel.iommu/8175/

 include/linux/device.h      |  1 +
 include/linux/dma-mapping.h | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/device.h b/include/linux/device.h
index fb506738f7b7..a32f9b67315c 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -647,6 +647,7 @@ struct device_dma_parameters {
 	 * sg limitations.
 	 */
 	unsigned int max_segment_size;
+	unsigned int max_segment_count;    /* INT_MAX for unlimited */
 	unsigned long segment_boundary_mask;
 };
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index c3007cb4bfa6..d3351a36d5ec 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -154,6 +154,25 @@ static inline unsigned int dma_set_max_seg_size(struct device *dev,
 		return -EIO;
 }
 
+#define DMA_SEGMENTS_MAX_SEG_COUNT ((unsigned int) INT_MAX)
+
+static inline unsigned int dma_get_max_seg_count(struct device *dev)
+{
+	if (dev->dma_parms && dev->dma_parms->max_segment_count)
+		return dev->dma_parms->max_segment_count;
+	return DMA_SEGMENTS_MAX_SEG_COUNT;
+}
+
+static inline int dma_set_max_seg_count(struct device *dev,
+						unsigned int count)
+{
+	if (dev->dma_parms) {
+		dev->dma_parms->max_segment_count = count;
+		return 0;
+	}
+	return -EIO;
+}
+
 static inline unsigned long dma_get_seg_boundary(struct device *dev)
 {
 	return dev->dma_parms ?
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
