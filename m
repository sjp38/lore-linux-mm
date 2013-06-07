Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A60DA6B0037
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 05:56:18 -0400 (EDT)
Message-ID: <51B1AD9D.2010803@cn.fujitsu.com>
Date: Fri, 07 Jun 2013 17:53:33 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm, vmalloc: Remove dead code in vb_alloc
References: <51B1AD2F.4030702@cn.fujitsu.com>
In-Reply-To: <51B1AD2F.4030702@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

Space in a vmap block that was once allocated is considered dirty and
not made available for allocation again before the whole block is
recycled. The result is that free space within a vmap block is always
contiguous.

So if a vmap block has enough free space for allocation, the allocation
is impossible to fail. Thus, the fragmented block purging was never invoked
from vb_alloc(). So remove this dead code.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d365724..b8abcba 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -910,7 +910,6 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 	struct vmap_block *vb;
 	unsigned long addr = 0;
 	unsigned int order;
-	int purge = 0;
 
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
@@ -934,17 +933,7 @@ again:
 		if (vb->free < 1UL << order)
 			goto next;
 
-		i = bitmap_find_free_region(vb->alloc_map,
-						VMAP_BBMAP_BITS, order);
-
-		if (i < 0) {
-			if (vb->free + vb->dirty == VMAP_BBMAP_BITS) {
-				/* fragmented and no outstanding allocations */
-				BUG_ON(vb->dirty != VMAP_BBMAP_BITS);
-				purge = 1;
-			}
-			goto next;
-		}
+		i = VMAP_BBMAP_BITS - vb->free;
 		addr = vb->va->va_start + (i << PAGE_SHIFT);
 		BUG_ON(addr_to_vb_idx(addr) !=
 				addr_to_vb_idx(vb->va->va_start));
@@ -960,9 +949,6 @@ next:
 		spin_unlock(&vb->lock);
 	}
 
-	if (purge)
-		purge_fragmented_blocks_thiscpu();
-
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
