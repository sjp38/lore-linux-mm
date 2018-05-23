Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 890A36B026C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:16:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t2-v6so693372pgo.0
        for <linux-mm@kvack.org>; Wed, 23 May 2018 10:16:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor8220497pfh.53.2018.05.23.10.16.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 10:16:37 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v3 5/9] drivers/block/zram/zram_drv: update usage of zone modifiers
Date: Thu, 24 May 2018 01:16:29 +0800
Message-Id: <1527095789-5668-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Christoph Hellwig <hch@infradead.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MOVABLE to replace (__GFP_HIGHMEM | __GFP_MOVABLE).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.

__GFP_ZONE_MOVABLE contains encoded ZONE_MOVABLE and __GFP_MOVABLE flag.

With GFP_ZONE_TABLE, __GFP_HIGHMEM ORing __GFP_MOVABLE means gfp_zone
should return ZONE_MOVABLE. In order to keep that compatible with
GFP_ZONE_TABLE, replace (__GFP_HIGHMEM | __GFP_MOVABLE) with
__GFP_ZONE_MOVABLE.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 drivers/block/zram/zram_drv.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 0f3fadd..1bb5ca8 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -1004,14 +1004,12 @@ static int __zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
 		handle = zs_malloc(zram->mem_pool, comp_len,
 				__GFP_KSWAPD_RECLAIM |
 				__GFP_NOWARN |
-				__GFP_HIGHMEM |
-				__GFP_MOVABLE);
+				__GFP_ZONE_MOVABLE);
 	if (!handle) {
 		zcomp_stream_put(zram->comp);
 		atomic64_inc(&zram->stats.writestall);
 		handle = zs_malloc(zram->mem_pool, comp_len,
-				GFP_NOIO | __GFP_HIGHMEM |
-				__GFP_MOVABLE);
+				GFP_NOIO | __GFP_ZONE_MOVABLE);
 		if (handle)
 			goto compress_again;
 		return -ENOMEM;
-- 
1.8.3.1
