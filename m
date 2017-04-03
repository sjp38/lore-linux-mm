Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 314306B03A8
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:58 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 7so49361061qtp.8
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:58 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id m82si21001qke.65.2017.04.03.11.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:57 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id n21so120807180qta.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:57 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 14/22] staging: android: ion: Stop butchering the DMA address
Date: Mon,  3 Apr 2017 11:57:56 -0700
Message-Id: <1491245884-15852-15-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Now that we have proper caching, stop setting the DMA address manually.
It should be set after properly calling dma_map.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 3d979ef5..65638f5 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -81,8 +81,7 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 {
 	struct ion_buffer *buffer;
 	struct sg_table *table;
-	struct scatterlist *sg;
-	int i, ret;
+	int ret;
 
 	buffer = kzalloc(sizeof(*buffer), GFP_KERNEL);
 	if (!buffer)
@@ -119,20 +118,6 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 	INIT_LIST_HEAD(&buffer->vmas);
 	INIT_LIST_HEAD(&buffer->attachments);
 	mutex_init(&buffer->lock);
-	/*
-	 * this will set up dma addresses for the sglist -- it is not
-	 * technically correct as per the dma api -- a specific
-	 * device isn't really taking ownership here.  However, in practice on
-	 * our systems the only dma_address space is physical addresses.
-	 * Additionally, we can't afford the overhead of invalidating every
-	 * allocation via dma_map_sg. The implicit contract here is that
-	 * memory coming from the heaps is ready for dma, ie if it has a
-	 * cached mapping that mapping has been invalidated
-	 */
-	for_each_sg(buffer->sg_table->sgl, sg, buffer->sg_table->nents, i) {
-		sg_dma_address(sg) = sg_phys(sg);
-		sg_dma_len(sg) = sg->length;
-	}
 	mutex_lock(&dev->buffer_lock);
 	ion_buffer_add(dev, buffer);
 	mutex_unlock(&dev->buffer_lock);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
