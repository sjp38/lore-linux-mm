Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 585DF6B038F
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n37so79890741qtb.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:17 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id g17si7701007qta.51.2017.03.17.17.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:16 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id n21so75239784qta.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:16 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 05/21] staging: android: ion: Duplicate sg_table
Date: Fri, 17 Mar 2017 17:54:37 -0700
Message-Id: <1489798493-16600-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Ion currently returns a single sg_table on each dma_map call. This is
incorrect for later usage.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index c2adfe1..7dcb8a9 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -800,6 +800,32 @@ static void ion_buffer_sync_for_device(struct ion_buffer *buffer,
 				       struct device *dev,
 				       enum dma_data_direction direction);
 
+static struct sg_table *dup_sg_table(struct sg_table *table)
+{
+	struct sg_table *new_table;
+	int ret, i;
+	struct scatterlist *sg, *new_sg;
+
+	new_table = kzalloc(sizeof(*new_table), GFP_KERNEL);
+	if (!new_table)
+		return ERR_PTR(-ENOMEM);
+
+	ret = sg_alloc_table(new_table, table->nents, GFP_KERNEL);
+	if (ret) {
+		kfree(new_table);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	new_sg = new_table->sgl;
+	for_each_sg(table->sgl, sg, table->nents, i) {
+		memcpy(new_sg, sg, sizeof(*sg));
+		sg->dma_address = 0;
+		new_sg = sg_next(new_sg);
+	}
+
+	return new_table;
+}
+
 static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
 					enum dma_data_direction direction)
 {
@@ -807,13 +833,15 @@ static struct sg_table *ion_map_dma_buf(struct dma_buf_attachment *attachment,
 	struct ion_buffer *buffer = dmabuf->priv;
 
 	ion_buffer_sync_for_device(buffer, attachment->dev, direction);
-	return buffer->sg_table;
+	return dup_sg_table(buffer->sg_table);
 }
 
 static void ion_unmap_dma_buf(struct dma_buf_attachment *attachment,
 			      struct sg_table *table,
 			      enum dma_data_direction direction)
 {
+	sg_free_table(table);
+	kfree(table);
 }
 
 void ion_pages_sync_for_device(struct device *dev, struct page *page,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
