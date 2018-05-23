Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8E206B026C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:07:26 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 31-v6so1253774plf.19
        for <linux-mm@kvack.org>; Wed, 23 May 2018 10:07:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t71-v6sor5172667pgd.65.2018.05.23.10.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 10:07:24 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v3 7/9] mm/zsmalloc: update usage of zone modifiers
Date: Thu, 24 May 2018 01:07:06 +0800
Message-Id: <1527095226-5079-1-git-send-email-yehs2007@gmail.com>
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
GFP_ZONE_TABLE, Use GFP_NORMAL_UNMOVABLE() to clear bottom 4 bits of
GFP bitmaks.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 mm/zsmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 61cb05d..e250c69 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -345,7 +345,7 @@ static void destroy_cache(struct zs_pool *pool)
 static unsigned long cache_alloc_handle(struct zs_pool *pool, gfp_t gfp)
 {
 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
-			gfp & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
+			GFP_NORMAL_UNMOVABLE(gfp));
 }
 
 static void cache_free_handle(struct zs_pool *pool, unsigned long handle)
@@ -356,7 +356,7 @@ static void cache_free_handle(struct zs_pool *pool, unsigned long handle)
 static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
 {
 	return kmem_cache_alloc(pool->zspage_cachep,
-			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
+			GFP_NORMAL_UNMOVABLE(flags));
 }
 
 static void cache_free_zspage(struct zs_pool *pool, struct zspage *zspage)
-- 
1.8.3.1
