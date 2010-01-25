Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1FFB96B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 07:37:56 -0500 (EST)
Date: Mon, 25 Jan 2010 23:37:46 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100125123746.GA24406@laptop>
References: <20081021082542.GA6974@wotan.suse.de>
 <20081021082735.GB6974@wotan.suse.de>
 <20081021120932.GB13348@infradead.org>
 <20081022093018.GD4359@wotan.suse.de>
 <20100119121505.GA9428@infradead.org>
 <20100125075445.GD19664@laptop>
 <20100125081750.GA20012@infradead.org>
 <20100125083309.GF19664@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125083309.GF19664@laptop>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 07:33:09PM +1100, Nick Piggin wrote:
> > Any easy way to get them?  Sorry, not uptodate on your new vmalloc
> > implementation anymore.
> 
> Let me try writing a few (tested) patches here first that I can send you.

Well is it easy to reproduce the vmap failure? Here is a better tested
patch if you can try it. It fixes a couple of bugs and does some purging
of fragmented blocks.

If it does not help, can you tell me how many CPUs in your system?

Thanks,
Nick

--

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2010-01-25 23:35:03.000000000 +1100
+++ linux-2.6/mm/vmalloc.c	2010-01-25 23:35:15.000000000 +1100
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
@@ -667,8 +673,6 @@ static bool vmap_initialized __read_most
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
-	struct list_head dirty;
-	unsigned int nr_dirty;
 };
 
 struct vmap_block {
@@ -678,10 +682,9 @@ struct vmap_block {
 	unsigned long free, dirty;
 	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
-	union {
-		struct list_head free_list;
-		struct rcu_head rcu_head;
-	};
+	struct list_head free_list;
+	struct rcu_head rcu_head;
+	struct list_head purge;
 };
 
 /* Queue of free and dirty vmap blocks, for allocation and flushing purposes */
@@ -757,7 +760,7 @@ static struct vmap_block *new_vmap_block
 	vbq = &get_cpu_var(vmap_block_queue);
 	vb->vbq = vbq;
 	spin_lock(&vbq->lock);
-	list_add(&vb->free_list, &vbq->free);
+	list_add_rcu(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_block_queue);
 
@@ -776,8 +779,6 @@ static void free_vmap_block(struct vmap_
 	struct vmap_block *tmp;
 	unsigned long vb_idx;
 
-	BUG_ON(!list_empty(&vb->free_list));
-
 	vb_idx = addr_to_vb_idx(vb->va->va_start);
 	spin_lock(&vmap_block_tree_lock);
 	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
@@ -788,12 +789,61 @@ static void free_vmap_block(struct vmap_
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
@@ -806,24 +856,38 @@ again:
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
-				list_del_init(&vb->free_list);
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
 		}
+		addr = vb->va->va_start + (i << PAGE_SHIFT);
+		BUG_ON(addr_to_vb_idx(addr) !=
+				addr_to_vb_idx(vb->va->va_start));
+		vb->free -= 1UL << order;
+		if (vb->free == 0) {
+			spin_lock(&vbq->lock);
+			list_del_rcu(&vb->free_list);
+			spin_unlock(&vbq->lock);
+		}
+		spin_unlock(&vb->lock);
+		break;
+next:
 		spin_unlock(&vb->lock);
 	}
+
+	if (purge)
+		purge_fragmented_blocks_thiscpu();
+
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
 
@@ -860,11 +924,11 @@ static void vb_free(const void *addr, un
 	BUG_ON(!vb);
 
 	spin_lock(&vb->lock);
-	bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order);
+	BUG_ON(bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order));
 
 	vb->dirty += 1UL << order;
 	if (vb->dirty == VMAP_BBMAP_BITS) {
-		BUG_ON(vb->free || !list_empty(&vb->free_list));
+		BUG_ON(vb->free);
 		spin_unlock(&vb->lock);
 		free_vmap_block(vb);
 	} else
@@ -1033,8 +1097,6 @@ void __init vmalloc_init(void)
 		vbq = &per_cpu(vmap_block_queue, i);
 		spin_lock_init(&vbq->lock);
 		INIT_LIST_HEAD(&vbq->free);
-		INIT_LIST_HEAD(&vbq->dirty);
-		vbq->nr_dirty = 0;
 	}
 
 	/* Import existing vmlist entries. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
