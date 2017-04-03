Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB8386B03A1
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d62so49734751qkf.13
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:27 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id o20si12706540qtf.76.2017.04.03.11.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:27 -0700 (PDT)
Received: by mail-qk0-f169.google.com with SMTP id h67so24174284qke.0
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:26 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 05/22] staging: android: ion: Duplicate sg_table
Date: Mon,  3 Apr 2017 11:57:47 -0700
Message-Id: <1491245884-15852-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
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
