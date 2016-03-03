Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC096B0259
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 09:48:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bj10so16037401pad.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:34 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id tt9si16242330pab.239.2016.03.03.06.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 06:48:33 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id fy10so15923146pac.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 06:48:33 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v3 4/5] zram: use zs_huge_object()
Date: Thu,  3 Mar 2016 23:46:02 +0900
Message-Id: <1457016363-11339-5-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

zram should stop enforcing its own 'bad' object size watermark,
and start using zs_huge_object(). zsmalloc really knows better.

Drop `max_zpage_size' and use zs_huge_object() instead.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c | 2 +-
 drivers/block/zram/zram_drv.h | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 46055db..bb81b1b 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -714,7 +714,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		goto out;
 	}
 	src = zstrm->buffer;
-	if (unlikely(clen > max_zpage_size)) {
+	if (unlikely(zs_huge_object(clen))) {
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
2.8.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
