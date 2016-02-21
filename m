Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 40C236B0253
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 08:30:05 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so77544365pfb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:05 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id i10si21920599pat.47.2016.02.21.05.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 05:30:04 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id fy10so76086096pac.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 05:30:04 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Date: Sun, 21 Feb 2016 22:27:53 +0900
Message-Id: <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

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
