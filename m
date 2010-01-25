Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC1506B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 03:30:26 -0500 (EST)
Date: Mon, 25 Jan 2010 19:30:20 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] xfs: use scalable vmap API
Message-ID: <20100125083020.GE19664@laptop>
References: <20081021082542.GA6974@wotan.suse.de>
 <20081021082735.GB6974@wotan.suse.de>
 <20081021120932.GB13348@infradead.org>
 <20081022093018.GD4359@wotan.suse.de>
 <20100119121505.GA9428@infradead.org>
 <20100125075445.GD19664@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125075445.GD19664@laptop>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 06:54:45PM +1100, Nick Piggin wrote:
> When the vmap allocation fails, it would be good to basically see the
> alloc_map and dirty_map for each of the vmap_blocks. This is going to be
> a lot of information. Basically for all blocks with
> free+dirty == VMAP_BBMAP_BITS are ones that could be released and you
> could try the alloc again.

Something like this (untested) is what I'm thinking of. I'll try the XFS
patch again and get something testable over here.

There are RCU bugs in the vmap block list I noticed too which I will
split out and submit seperately.
--
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -509,6 +509,9 @@ static unsigned long lazy_max_pages(void
 
 static atomic_t vmap_lazy_nr = ATOMIC_INIT(0);
 
+/* for per-CPU blocks */
+static void purge_fragmented_blocks(void);
+
 /*
  * Purges all lazily-freed vmap areas.
  *
@@ -539,6 +542,8 @@ static void __purge_vmap_area_lazy(unsig
 	} else
 		spin_lock(&purge_lock);
 
+	purge_fragmented_blocks();
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(va, &vmap_area_list, list) {
 		if (va->flags & VM_LAZY_FREE) {
@@ -669,8 +674,6 @@ static bool vmap_initialized __read_most
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
-	struct list_head dirty;
-	unsigned int nr_dirty;
 };
 
 struct vmap_block {
@@ -680,10 +683,9 @@ struct vmap_block {
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
@@ -759,7 +761,7 @@ static struct vmap_block *new_vmap_block
 	vbq = &get_cpu_var(vmap_block_queue);
 	vb->vbq = vbq;
 	spin_lock(&vbq->lock);
-	list_add(&vb->free_list, &vbq->free);
+	list_add_rcu(&vb->free_list, &vbq->free);
 	spin_unlock(&vbq->lock);
 	put_cpu_var(vmap_block_queue);
 
@@ -808,23 +810,27 @@ again:
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
-			}
-			spin_unlock(&vb->lock);
-			break;
+		if (i < 0)
+			goto next;
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
 	put_cpu_var(vmap_block_queue);
 	rcu_read_unlock();
@@ -873,6 +879,43 @@ static void vb_free(const void *addr, un
 		spin_unlock(&vb->lock);
 }
 
+static void purge_fragmented_blocks(void)
+{
+	LIST_HEAD(purge);
+	int cpu;
+	struct vmap_block *vb;
+	struct vmap_block *n_vb;
+
+	for_each_possible_cpu(cpu) {
+		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
+
+		rcu_read_lock();
+		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
+
+			if (vb->free + vb->dirty != VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS)
+				continue;
+
+			spin_lock(&vb->lock);
+			if (vb->free + vb->dirty == VMAP_BBMAP_BITS && vb->dirty != VMAP_BBMAP_BITS) {
+				vb->free = 0; /* prevent further allocs after releasing lock */
+				vb->dirty = VMAP_BBMAP_BITS; /* prevent purging it again */
+				spin_lock(&vbq->lock);
+				list_del_rcu(&vb->free_list);
+				spin_unlock(&vbq->lock);
+				spin_unlock(&vb->lock);
+				list_add_tail(&vb->purge, &purge);
+			} else
+				spin_unlock(&vb->lock);
+		}
+		rcu_read_unlock();
+	}
+
+	list_for_each_entry_safe(vb, n_vb, &purge, purge) {
+		list_del(&vb->purge);
+		free_vmap_block(vb);
+	}
+}
+
 /**
  * vm_unmap_aliases - unmap outstanding lazy aliases in the vmap layer
  *
@@ -1035,8 +1078,6 @@ void __init vmalloc_init(void)
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
