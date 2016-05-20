Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4726828E2
	for <linux-mm@kvack.org>; Fri, 20 May 2016 10:24:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id g83so49868203oib.0
        for <linux-mm@kvack.org>; Fri, 20 May 2016 07:24:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b126si5377907itc.73.2016.05.20.07.24.25
        for <linux-mm@kvack.org>;
        Fri, 20 May 2016 07:24:26 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 12/12] zram: use __GFP_MOVABLE for memory allocation
Date: Fri, 20 May 2016 23:23:45 +0900
Message-Id: <1463754225-31311-13-git-send-email-minchan@kernel.org>
In-Reply-To: <1463754225-31311-1-git-send-email-minchan@kernel.org>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Zsmalloc is ready for page migration so zram can use __GFP_MOVABLE
from now on.

I did test to see how it helps to make higher order pages.
Test scenario is as follows.

KVM guest, 1G memory, ext4 formated zram block device,

for i in `seq 1 8`;
do
        dd if=/dev/vda1 of=mnt/test$i.txt bs=128M count=1 &
done

wait `pidof dd`

for i in `seq 1 2 8`;
do
        rm -rf mnt/test$i.txt
done
fstrim -v mnt

echo "init"
cat /proc/buddyinfo

echo "compaction"
echo 1 > /proc/sys/vm/compact_memory
cat /proc/buddyinfo

old:

init
Node 0, zone      DMA    208    120     51     41     11      0      0      0      0      0      0
Node 0, zone    DMA32  16380  13777   9184   3805    789     54      3      0      0      0      0
compaction
Node 0, zone      DMA    132     82     40     39     16      2      1      0      0      0      0
Node 0, zone    DMA32   5219   5526   4969   3455   1831    677    139     15      0      0      0

new:

init
Node 0, zone      DMA    379    115     97     19      2      0      0      0      0      0      0
Node 0, zone    DMA32  18891  16774  10862   3947    637     21      0      0      0      0      0
compaction  1
Node 0, zone      DMA    214     66     87     29     10      3      0      0      0      0      0
Node 0, zone    DMA32   1612   3139   3154   2469   1745    990    384     94      7      0      0

As you can see, compaction made so many high-order pages. Yay!

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 8fcad8b761f1..ccf1bddd09ca 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -732,7 +732,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		handle = zs_malloc(meta->mem_pool, clen,
 				__GFP_KSWAPD_RECLAIM |
 				__GFP_NOWARN |
-				__GFP_HIGHMEM);
+				__GFP_HIGHMEM |
+				__GFP_MOVABLE);
 	if (!handle) {
 		zcomp_strm_release(zram->comp, zstrm);
 		zstrm = NULL;
@@ -740,7 +741,8 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		atomic64_inc(&zram->stats.writestall);
 
 		handle = zs_malloc(meta->mem_pool, clen,
-				GFP_NOIO | __GFP_HIGHMEM);
+				GFP_NOIO | __GFP_HIGHMEM |
+				__GFP_MOVABLE);
 		if (handle)
 			goto compress_again;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
