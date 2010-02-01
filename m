Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B31956B0071
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 06:24:25 -0500 (EST)
Date: Mon, 1 Feb 2010 22:24:18 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] mm: percpu-vmap fix RCU list walking
Message-ID: <20100201112418.GJ12759@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: stable@kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>


RCU list walking of the per-cpu vmap cache was broken. It did not use RCU
primitives, and also the union of free_list and rcu_head is obviously wrong
(because free_list is indeed the list we are RCU walking).

While we are there, remove a couple of unused fields from an earlier
iteration.

These APIs aren't actually used anywhere, because of problems with the
XFS conversion. Christoph has now verified that the problems are solved
with these patches. Also it is an exported interface, so I think it will
be good to be merged now (and Christoph wants to get the XFS changes
into their local tree).

Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Tested-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Nick Piggin <npiggin@suse.de>
--
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -669,8 +669,6 @@ static bool vmap_initialized __read_most
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
-	struct list_head dirty;
-	unsigned int nr_dirty;
 };
 
 struct vmap_block {
@@ -680,10 +678,8 @@ struct vmap_block {
 	unsigned long free, dirty;
 	DECLARE_BITMAP(alloc_map, VMAP_BBMAP_BITS);
 	DECLARE_BITMAP(dirty_map, VMAP_BBMAP_BITS);
-	union {
-		struct list_head free_list;
-		struct rcu_head rcu_head;
-	};
+	struct list_head free_list;
+	struct rcu_head rcu_head;
 };
 
 /* Queue of free and dirty vmap blocks, for allocation and flushing purposes */
@@ -759,7 +755,7 @@ static struct vmap_block *new_vmap_block
 	vbq = &get_cpu_var(vmap_block_queue);
 	vb->vbq = vbq;
 	spin_lock(&vbq->lock);
-	list_add(&vb->free_list, &vbq->free);
+	list_add_rcu(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_block_queue);
 
@@ -778,8 +774,6 @@ static void free_vmap_block(struct vmap_
 	struct vmap_block *tmp;
 	unsigned long vb_idx;
 
-	BUG_ON(!list_empty(&vb->free_list));
-
 	vb_idx = addr_to_vb_idx(vb->va->va_start);
 	spin_lock(&vmap_block_tree_lock);
 	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
@@ -818,7 +812,7 @@ again:
 			vb->free -= 1UL << order;
 			if (vb->free == 0) {
 				spin_lock(&vbq->lock);
-				list_del_init(&vb->free_list);
+				list_del_rcu(&vb->free_list);
 				spin_unlock(&vbq->lock);
 			}
 			spin_unlock(&vb->lock);
@@ -862,11 +856,11 @@ static void vb_free(const void *addr, un
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
@@ -1035,8 +1029,6 @@ void __init vmalloc_init(void)
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
