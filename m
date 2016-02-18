Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 335B96B0254
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 22:01:41 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e127so22595223pfe.3
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:41 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id kk8si6101807pab.26.2016.02.17.19.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 19:01:40 -0800 (PST)
Received: by mail-pa0-x235.google.com with SMTP id ho8so22799957pac.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:01:40 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [RFC PATCH 2/3] zram: use zs_get_huge_class_size_watermark()
Date: Thu, 18 Feb 2016 12:02:35 +0900
Message-Id: <1455764556-13979-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

zram should stop enforcing its own 'bad' object size watermark,
and start using zs_get_huge_class_size_watermark(). zsmalloc
really knows better.

Drop `max_zpage_size' and use zs_get_huge_class_size_watermark()
instead.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c | 2 +-
 drivers/block/zram/zram_drv.h | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 46055db..2621564 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -714,7 +714,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		goto out;
 	}
 	src = zstrm->buffer;
-	if (unlikely(clen > max_zpage_size)) {
+	if (unlikely(clen > zs_get_huge_class_size_watermark())) {
 		clen = PAGE_SIZE;
 		if (is_partial_io(bvec))
 			src = uncmem;
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 8e92339..8879161 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -23,12 +23,6 @@
 /*-- Configurable parameters */
 
 /*
- * Pages that compress to size greater than this are stored
- * uncompressed in memory.
- */
-static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
-
-/*
  * NOTE: max_zpage_size must be less than or equal to:
  *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
  * always return failure.
-- 
2.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
