Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C66576B0037
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 21:38:28 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y13so12438756pdi.37
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:38:28 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id bx17si306334pdb.153.2014.09.03.18.38.25
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 18:38:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 3/3] zram: add swap_get_free hint
Date: Thu,  4 Sep 2014 10:39:46 +0900
Message-Id: <1409794786-10951-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1409794786-10951-1-git-send-email-minchan@kernel.org>
References: <1409794786-10951-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, Minchan Kim <minchan@kernel.org>

This patch implement SWAP_GET_FREE handler in zram so that VM can
know how many zram has freeable space.
VM can use it to stop anonymous reclaiming once zram is full.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 88661d62e46a..8e22b20aa2db 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -951,6 +951,22 @@ static int zram_slot_free_notify(struct block_device *bdev,
 	return 0;
 }
 
+static int zram_get_free_pages(struct block_device *bdev, long *free)
+{
+	struct zram *zram;
+	struct zram_meta *meta;
+
+	zram = bdev->bd_disk->private_data;
+	meta = zram->meta;
+
+	if (!zram->limit_pages)
+		return 1;
+
+	*free = zram->limit_pages - zs_get_total_pages(meta->mem_pool);
+
+	return 0;
+}
+
 static int zram_swap_hint(struct block_device *bdev,
 				unsigned int hint, void *arg)
 {
@@ -958,6 +974,8 @@ static int zram_swap_hint(struct block_device *bdev,
 
 	if (hint == SWAP_SLOT_FREE)
 		ret = zram_slot_free_notify(bdev, (unsigned long)arg);
+	else if (hint == SWAP_GET_FREE)
+		ret = zram_get_free_pages(bdev, arg);
 
 	return ret;
 }
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
