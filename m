Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 350436B026C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 12:57:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q71-v6so3571898pgq.17
        for <linux-mm@kvack.org>; Wed, 23 May 2018 09:57:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor4665634pgr.94.2018.05.23.09.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 09:57:28 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v3 4/9] fs/btrfs/extent_io: update usage of zone modifiers
Date: Thu, 24 May 2018 00:57:19 +0800
Message-Id: <1527094639-4562-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, Christoph Hellwig <hch@infradead.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA32 | __GFP_HIGHMEM).

In function alloc_extent_state, it is obvious that __GFP_DMA is not
the expecting zone type.

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
each others by OR.

Use GFP_NORMAL() to clear bottom 3 bits of GFP bitmaks.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: David Sterba <dsterba@suse.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 fs/btrfs/extent_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index e99b329..f41fc61 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -220,7 +220,7 @@ static struct extent_state *alloc_extent_state(gfp_t mask)
 	 * The given mask might be not appropriate for the slab allocator,
 	 * drop the unsupported bits
 	 */
-	mask &= ~(__GFP_DMA32|__GFP_HIGHMEM);
+	mask = GFP_NORMAL(mask);
 	state = kmem_cache_alloc(extent_state_cache, mask);
 	if (!state)
 		return state;
-- 
1.8.3.1
