Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 307A36B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 02:07:01 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t24so9724703pfe.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 23:07:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor2868073pgn.268.2018.03.05.23.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 23:06:59 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCHv2 2/2] zram: drop max_zpage_size and use zs_huge_class_size()
Date: Tue,  6 Mar 2018 16:06:39 +0900
Message-Id: <20180306070639.7389-3-sergey.senozhatsky@gmail.com>
In-Reply-To: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
References: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

This patch removes ZRAM's enforced "huge object" value and uses
zsmalloc huge-class watermark instead, which makes more sense.

TEST
- I used a 1G zram device, LZO compression back-end, original
  data set size was 444MB. Looking at zsmalloc classes stats the
  test ended up to be pretty fair.

BASE ZRAM/ZSMALLOC
=====================
zram mm_stat

498978816 191482495 199831552        0 199831552    15634        0

zsmalloc classes

 class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable
...
   151  2448           0            0          1240       1240        744                3        0
   168  2720           0            0          4200       4200       2800                2        0
   190  3072           0            0         10100      10100       7575                3        0
   202  3264           0            0           380        380        304                4        0
   254  4096           0            0         10620      10620      10620                1        0

 Total                 7           46        106982     106187      48787                         0

PATCHED ZRAM/ZSMALLOC
=====================

zram mm_stat

498978816 182579184 194248704        0 194248704    15628        0

zsmalloc classes

 class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage freeable
...
   151  2448           0            0          1240       1240        744                3        0
   168  2720           0            0          4200       4200       2800                2        0
   190  3072           0            0         10100      10100       7575                3        0
   202  3264           0            0          7180       7180       5744                4        0
   254  4096           0            0          3820       3820       3820                1        0

 Total                 8           45        106959     106193      47424                         0

As we can see, we reduced the number of objects stored in class-4096,
because a huge number of objects which we previously forcibly stored
in class-4096 now stored in non-huge class-3264. This results in lower
memory consumption:
 - zsmalloc now uses 47424 physical pages, which is less than 48787
   pages zsmalloc used before.

 - objects that we store in class-3264 share zspages. That's why overall
   the number of pages that both class-4096 and class-3264 consumed went
   down from 10924 to 9564.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c |  9 ++++++++-
 drivers/block/zram/zram_drv.h | 16 ----------------
 2 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 85110e7931e5..1b8082e6d2f5 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -44,6 +44,11 @@ static const char *default_compressor = "lzo";
 
 /* Module params (documentation at end) */
 static unsigned int num_devices = 1;
+/*
+ * Pages that compress to sizes equals or greater than this are stored
+ * uncompressed in memory.
+ */
+static size_t huge_class_size;
 
 static void zram_free_page(struct zram *zram, size_t index);
 
@@ -786,6 +791,8 @@ static bool zram_meta_alloc(struct zram *zram, u64 disksize)
 		return false;
 	}
 
+	if (!huge_class_size)
+		huge_class_size = zs_huge_class_size();
 	return true;
 }
 
@@ -965,7 +972,7 @@ static int __zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
 		return ret;
 	}
 
-	if (unlikely(comp_len > max_zpage_size)) {
+	if (unlikely(comp_len >= huge_class_size)) {
 		if (zram_wb_enabled(zram) && allow_wb) {
 			zcomp_stream_put(zram->comp);
 			ret = write_to_bdev(zram, bvec, index, bio, &element);
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 31762db861e3..d71c8000a964 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -21,22 +21,6 @@
 
 #include "zcomp.h"
 
-/*-- Configurable parameters */
-
-/*
- * Pages that compress to size greater than this are stored
- * uncompressed in memory.
- */
-static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
-
-/*
- * NOTE: max_zpage_size must be less than or equal to:
- *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
- * always return failure.
- */
-
-/*-- End of configurable params */
-
 #define SECTOR_SHIFT		9
 #define SECTORS_PER_PAGE_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
 #define SECTORS_PER_PAGE	(1 << SECTORS_PER_PAGE_SHIFT)
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
