Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 12D5B6B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:36:18 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id 4so122511701pfd.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:36:18 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b14si830588pat.152.2016.03.20.23.30.16
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:17 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 18/18] zram: use __GFP_MOVABLE for memory allocation
Date: Mon, 21 Mar 2016 15:31:07 +0900
Message-Id: <1458541867-27380-19-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

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
 drivers/block/zram/zram_drv.c | 3 ++-
 mm/zsmalloc.c                 | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 46055dbc4095..da8298b9f05e 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -517,7 +517,8 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
 		goto out_error;
 	}
 
-	meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO | __GFP_HIGHMEM);
+	meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO|__GFP_HIGHMEM
+						|__GFP_MOVABLE);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto out_error;
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 35bafa0bc3f1..8557da6dbaf2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -308,7 +308,7 @@ static void destroy_handle_cache(struct zs_pool *pool)
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
-		pool->flags & ~__GFP_HIGHMEM);
+		pool->flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
 }
 
 static void free_handle(struct zs_pool *pool, unsigned long handle)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
