Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 37E7E6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 21:27:56 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b57so1108544eek.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 18:27:54 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 7 Feb 2013 11:27:54 +0900
Message-ID: <CAOAMb1AZaXHiW47MbstoVaDVEbVaSC+fqcZoSM0EXC5RpH7nHw@mail.gmail.com>
Subject: [PATCH] vmalloc: Remove alloc_map from vmap_block.
From: Chanho Min <chanho.min@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Cong Wang <amwang@redhat.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is no reason to maintain alloc_map in the vmap_block.
The use of alloc_map may require heavy bitmap operation sometimes.
In the worst-case, We need 1024 for-loops to find 1 free bit and
thus cause overhead. vmap_block is fragmented unnecessarily by
2 order alignment as well.

Instead we can map by using vb->free in order. When It is freed,
Its corresponding bit will be set in the dirty_map and all
free/purge operations are carried out in the dirty_map.
vmap_block is not fragmented sporadically anymore and thus
purge_fragmented_blocks_thiscpu in the vb_alloc can be removed.

Signed-off-by: Chanho Min <chanho.min@lge.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmalloc.c |   23 +----------------------
 1 file changed, 1 insertion(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5123a16..4fd3555 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -744,7 +744,6 @@ struct vmap_block {
 	struct vmap_area *va;
 	struct vmap_block_queue *vbq;
 	unsigned long free, dirty;
-	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
 	struct list_head free_list;
 	struct rcu_head rcu_head;
@@ -810,7 +809,6 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 	vb->va = va;
 	vb->free = VMAP_BBMAP_BITS;
 	vb->dirty = 0;
-	bitmap_zero(vb->alloc_map, VMAP_BBMAP_BITS);
 	bitmap_zero(vb->dirty_map, VMAP_BBMAP_BITS);
 	INIT_LIST_HEAD(&vb->free_list);

@@ -863,7 +861,6 @@ static void purge_fragmented_blocks(int cpu)
 		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty !=
VMAP_BBMAP_BITS) {
 			vb->free = 0; /* prevent further allocs after releasing lock */
 			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
-			bitmap_fill(vb->alloc_map, VMAP_BBMAP_BITS);
 			bitmap_fill(vb->dirty_map, VMAP_BBMAP_BITS);
 			spin_lock(&vbq->lock);
 			list_del_rcu(&vb->free_list);
@@ -881,11 +878,6 @@ static void purge_fragmented_blocks(int cpu)
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
@@ -900,7 +892,6 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 	struct vmap_block *vb;
 	unsigned long addr = 0;
 	unsigned int order;
-	int purge = 0;

 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
@@ -924,17 +915,8 @@ again:
 		if (vb->free < 1UL << order)
 			goto next;

-		i = bitmap_find_free_region(vb->alloc_map,
-						VMAP_BBMAP_BITS, order);
+		i = VMAP_BBMAP_BITS - vb->free;

-		if (i < 0) {
-			if (vb->free + vb->dirty == VMAP_BBMAP_BITS) {
-				/* fragmented and no outstanding allocations */
-				BUG_ON(vb->dirty != VMAP_BBMAP_BITS);
-				purge = 1;
-			}
-			goto next;
-		}
 		addr = vb->va->va_start + (i << PAGE_SHIFT);
 		BUG_ON(addr_to_vb_idx(addr) !=
 				addr_to_vb_idx(vb->va->va_start));
@@ -950,9 +932,6 @@ next:
 		spin_unlock(&vb->lock);
 	}

-	if (purge)
-		purge_fragmented_blocks_thiscpu();
-
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
