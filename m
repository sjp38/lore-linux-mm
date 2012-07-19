Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 9D90B6B0071
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 12:24:50 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id d16so2137205qcs.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 09:24:50 -0700 (PDT)
From: Rob Clark <rob.clark@linaro.org>
Subject: [PATCH 1/2] device: add dma_params->max_segment_count
Date: Thu, 19 Jul 2012 11:23:33 -0500
Message-Id: <1342715014-5316-2-git-send-email-rob.clark@linaro.org>
In-Reply-To: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
References: <1342715014-5316-1-git-send-email-rob.clark@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org
Cc: patches@linaro.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, daniel@ffwll.ch, t.stanislaws@samsung.com, sumit.semwal@ti.com, maarten.lankhorst@canonical.com, Rob Clark <rob@ti.com>

From: Rob Clark <rob@ti.com>

For devices which have constraints about maximum number of segments
in an sglist.  For example, a device which could only deal with
contiguous buffers would set max_segment_count to 1.

The initial motivation is for devices sharing buffers via dma-buf,
to allow the buffer exporter to know the constraints of other
devices which have attached to the buffer.  The dma_mask and fields
in 'struct device_dma_parameters' tell the exporter everything else
that is needed, except whether the importer has constraints about
maximum number of segments.

Signed-off-by: Rob Clark <rob@ti.com>
---
 include/linux/device.h      |    1 +
 include/linux/dma-mapping.h |   16 ++++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/device.h b/include/linux/device.h
index 161d962..3813735 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -568,6 +568,7 @@ struct device_dma_parameters {
 	 * sg limitations.
 	 */
 	unsigned int max_segment_size;
+	unsigned int max_segment_count;    /* zero for unlimited */
 	unsigned long segment_boundary_mask;
 };
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index dfc099e..f380f79 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -111,6 +111,22 @@ static inline unsigned int dma_set_max_seg_size(struct device *dev,
 		return -EIO;
 }
 
+static inline unsigned int dma_get_max_seg_count(struct device *dev)
+{
+	return dev->dma_parms ? dev->dma_parms->max_segment_count : 0;
+}
+
+static inline int dma_set_max_seg_count(struct device *dev,
+						unsigned int count)
+{
+	if (dev->dma_parms) {
+		dev->dma_parms->max_segment_count = count;
+		return 0;
+	} else
+		return -EIO;
+}
+
+
 static inline unsigned long dma_get_seg_boundary(struct device *dev)
 {
 	return dev->dma_parms ?
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
