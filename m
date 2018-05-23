Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Huaisheng Ye <yehs2007@163.com>
Subject: [RFC PATCH v3 4/9] fs/btrfs/extent_io: update usage of zone modifiers
Date: Wed, 23 May 2018 22:57:49 +0800
Message-Id: <1527087474-93986-5-git-send-email-yehs2007@163.com>
In-Reply-To: <1527087474-93986-1-git-send-email-yehs2007@163.com>
References: <1527087474-93986-1-git-send-email-yehs2007@163.com>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

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
