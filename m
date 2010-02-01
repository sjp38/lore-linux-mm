Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBB76B007B
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 06:26:03 -0500 (EST)
Date: Mon, 1 Feb 2010 22:25:57 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] mm: purge fragmented percpu vmap blocks
Message-ID: <20100201112557.GK12759@laptop>
References: <20100201112418.GJ12759@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100201112418.GJ12759@laptop>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: stable@kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>


Improve handling of fragmented per-CPU vmaps. We previously don't free up
per-CPU maps until all its addresses have been used and freed. So fragmented
blocks could fill up vmalloc space even if they actually had no active
vmap regions within them.

Add some logic to allow all CPUs to have these blocks purged in the case of
failure to allocate a new vm area, and also put some logic to trim such
blocks of a current CPU if we hit them in the allocation path (so as to
avoid a large build up of them).

Christoph reported some vmap allocation failures when using the per CPU
vmap APIs in XFS, which cannot be reproduced after this patch and the
previous bug fix. 

Cc: linux-mm@kvack.org
Cc: stable@kernel.org
Tested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>
--
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -509,6 +509,9 @@ static unsigned long lazy_max_pages(void
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
 
+/* for per-CPU blocks */
+static void purge_fragmented_blocks_allcpus(void);
+
 /*
  * Purges all lazily-freed vmap areas.
  *
@@ -539,6 +542,9 @@ static void __purge_vmap_area_lazy(unsig
 	} else
 		spin_lock(&purge_lock);
 
+	if (sync)
+		purge_fragmented_blocks_allcpus();
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(va, &vmap_area_list, list) {
 		if (va->flags & VM_LAZY_FREE) {
@@ -680,6 +686,7 @@ struct vmap_block {
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
 	struct list_head free_list;
 	struct rcu_head rcu_head;
+	struct list_head purge;
 };
 
 /* Queue of free and dirty vmap blocks, for allocation and flushing purposes */
@@ -784,12 +791,61 @@ static void free_vmap_block(struct vmap_
 	call_rcu(&vb->rcu_head, rcu_free_vb);
 }
 
+static void purge_fragmented_blocks(int cpu)
+{
+	LIST_HEAD(purge);
+	struct vmap_block *vb;
+	struct vmap_block *n_vb;
+	struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+
+		if (!(vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS))
+			continue;
+
+		spin_lock(&vb->lock);
+		if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
+			vb->free = 0; /* prevent further allocs after releasing lock */
+			vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
+			bitmap_fill(vb->alloc_map, VMAP_BBMAP_BITS);
+			bitmap_fill(vb->dirty_map, VMAP_BBMAP_BITS);
+			spin_lock(&vbq->lock);
+			list_del_rcu(&vb->free_list);
+			spin_unlock(&vbq->lock);
+			spin_unlock(&vb->lock);
+			list_add_tail(&vb->purge, &purge);
+		} else
+			spin_unlock(&vb->lock);
+	}
+	rcu_read_unlock();
+
+	list_for_each_entry_safe(vb, n_vb, &purge, purge) {
+		list_del(&vb->purge);
+		free_vmap_block(vb);
+	}
+}
+
+static void purge_fragmented_blocks_thiscpu(void)
+{
+	purge_fragmented_blocks(smp_processor_id());
+}
+
+static void purge_fragmented_blocks_allcpus(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		purge_fragmented_blocks(cpu);
+}
+
 static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 {
 	struct vmap_block_queue *vbq;
 	struct vmap_block *vb;
 	unsigned long addr = 0;
 	unsigned int order;
+	int purge = 0;
 
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
@@ -802,24 +858,38 @@ again:
 		int i;
 
 		spin_lock(&vb->lock);
+		if (vb->free < 1UL << order)
+			goto next;
+
 		i = bitmap_find_free_region(vb->alloc_map,
 						VMAP_BBMAP_BITS, order);
 
-		if (i >= 0) {
-			addr = vb->va->va_start + (i << PAGE_SHIFT);
-			BUG_ON(addr_to_vb_idx(addr) !=
-					addr_to_vb_idx(vb->va->va_start));
-			vb->free -= 1UL << order;
-			if (vb->free == 0) {
-				spin_lock(&vbq->lock);
-				list_del_rcu(&vb->free_list);
-				spin_unlock(&vbq->lock);
+		if (i < 0) {
+			if (vb->free + vb->dirty == VMAP_BBMAP_BITS) {
+				/* fragmented and no outstanding allocations */
+				BUG_ON(vb->dirty != VMAP_BBMAP_BITS);
+				purge = 1;
 			}
-			spin_unlock(&vb->lock);
-			break;
+			goto next;
+		}
+		addr = vb->va->va_start + (i << PAGE_SHIFT);
+		BUG_ON(addr_to_vb_idx(addr) !=
+				addr_to_vb_idx(vb->va->va_start));
+		vb->free -= 1UL << order;
+		if (vb->free == 0) {
+			spin_lock(&vbq->lock);
+			list_del_rcu(&vb->free_list);
+			spin_unlock(&vbq->lock);
 		}
 		spin_unlock(&vb->lock);
+		break;
+next:
+		spin_unlock(&vb->lock);
 	}
+
+	if (purge)
+		purge_fragmented_blocks_thiscpu();
+
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
