Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 747DA900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:17:29 -0400 (EDT)
Date: Thu, 14 Apr 2011 17:16:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm/vmalloc: remove block allocation bitmap
Message-ID: <20110414211656.GB1700@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Space in a vmap block that was once allocated is considered dirty and
not made available for allocation again before the whole block is
recycled.

The result is that free space within a vmap block is always contiguous
and the allocation bitmap can be replaced by remembering the offset of
free space in the block.

The fragmented block purging was never invoked from vb_alloc() either,
as it skips blocks that do not have enough free space for the
allocation in the first place.  According to the above, it is
impossible for a block to have enough free space and still fail the
allocation.  Thus, this dead code is removed.  Partially consumed
blocks will be reclaimed anyway when an attempt is made to allocate a
new vmap block altogether and no free space is found.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/vmalloc.c |   39 +++++++++------------------------------
 1 files changed, 9 insertions(+), 30 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5d8666b..5393248 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -682,7 +682,7 @@ struct vmap_block {
 	struct vmap_area *va;
 	struct vmap_block_queue *vbq;
 	unsigned long free, dirty;
-	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
+	unsigned long free_offset;
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
 	struct list_head free_list;
 	struct rcu_head rcu_head;
@@ -748,7 +748,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	vb->va = va;
 	vb->free = VMAP_BBMAP_BITS;
 	vb->dirty = 0;
-	bitmap_zero(vb->alloc_map, VMAP_BBMAP_BITS);
+	vb->free_offset = 0;
 	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
 	INIT_LIST_HEAD(&vb->free_list);
 
@@ -808,7 +808,7 @@ static void purge_fragmented_blocks(int cpu)
 		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
 			vb->free = 0; /* prevent further allocs after releasing lock */
 			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
-			bitmap_fill(vb->alloc_map, VMAP_BBMAP_BITS);
+			vb->free_offset = VMAP_BBMAP_BITS;
 			bitmap_fill(vb->dirty_map, VMAP_BBMAP_BITS);
 			spin_lock(&vbq->lock);
 			list_del_rcu(&vb->free_list);
@@ -826,11 +826,6 @@ static void purge_fragmented_blocks(int cpu)
 	}
 }
 
-static void purge_fragmented_blocks_thiscpu(void)
-{
-	purge_fragmented_blocks(smp_processor_id());
-}
-
 static void purge_fragmented_blocks_allcpus(void)
 {
 	int cpu;
@@ -845,7 +840,6 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 	struct vmap_block *vb;
 	unsigned long addr = 0;
 	unsigned int order;
-	int purge = 0;
 
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
@@ -855,41 +849,26 @@ again:
 	rcu_read_lock();
 	vbq = &get_cpu_var(vmap_block_queue);
 	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
-		int i;
-
 		spin_lock(&vb->lock);
-		if (vb->free < 1UL << order)
-			goto next;
-
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
+		if (vb->free < 1UL << order) {
+			spin_unlock(&vb->lock);
+			continue;
 		}
-		addr = vb->va->va_start + (i << PAGE_SHIFT);
+		addr = vb->va->va_start + (vb->free_offset << PAGE_SHIFT);
 		BUG_ON(addr_to_vb_idx(addr) !=
 				addr_to_vb_idx(vb->va->va_start));
 		vb->free -= 1UL << order;
+		vb->free_offset += 1UL << order;
 		if (vb->free == 0) {
+			BUG_ON(vb->free_offset != VMAP_BBMAP_BITS);
 			spin_lock(&vbq->lock);
 			list_del_rcu(&vb->free_list);
 			spin_unlock(&vbq->lock);
 		}
 		spin_unlock(&vb->lock);
 		break;
-next:
-		spin_unlock(&vb->lock);
 	}
 
-	if (purge)
-		purge_fragmented_blocks_thiscpu();
-
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
