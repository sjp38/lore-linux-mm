Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC279900147
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:42 -0400 (EDT)
Message-Id: <20110902204739.694434291@linux.com>
Date: Fri, 02 Sep 2011 15:46:58 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 01/12] slub: free slabs without holding locks (V2)
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=slub_free_wo_locks
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

There are two situations in which slub holds a lock while releasing
pages:

	A. During kmem_cache_shrink()
	B. During kmem_cache_close()

For A build a list while holding the lock and then release the pages
later. In case of B we are the last remaining user of the slab so
there is no need to take the listlock.

After this patch all calls to the page allocator to free pages are
done without holding any spinlocks. kmem_cache_destroy() will still
hold the slub_lock semaphore.

V1->V2. Remove kfree. Avoid locking in free_partial.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-08-09 13:01:59.071582163 -0500
+++ linux-2.6/mm/slub.c	2011-08-09 13:05:00.051582012 -0500
@@ -2970,13 +2970,13 @@ static void list_slab_objects(struct kme
 
 /*
  * Attempt to free all partial slabs on a node.
+ * This is called from kmem_cache_close(). We must be the last thread
+ * using the cache and therefore we do not need to lock anymore.
  */
 static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 {
-	unsigned long flags;
 	struct page *page, *h;
 
-	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (!page->inuse) {
 			remove_partial(n, page);
@@ -2986,7 +2986,6 @@ static void free_partial(struct kmem_cac
 				"Objects remaining on kmem_cache_close()");
 		}
 	}
-	spin_unlock_irqrestore(&n->list_lock, flags);
 }
 
 /*
@@ -3020,6 +3019,7 @@ void kmem_cache_destroy(struct kmem_cach
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
+		up_write(&slub_lock);
 		if (kmem_cache_close(s)) {
 			printk(KERN_ERR "SLUB %s: %s called for cache that "
 				"still has objects.\n", s->name, __func__);
@@ -3028,8 +3028,8 @@ void kmem_cache_destroy(struct kmem_cach
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 		sysfs_slab_remove(s);
-	}
-	up_write(&slub_lock);
+	} else
+		up_write(&slub_lock);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
@@ -3347,23 +3347,23 @@ int kmem_cache_shrink(struct kmem_cache
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse) {
-				remove_partial(n, page);
-				discard_slab(s, page);
-			} else {
-				list_move(&page->lru,
-				slabs_by_inuse + page->inuse);
-			}
+			list_move(&page->lru, slabs_by_inuse + page->inuse);
+			if (!page->inuse)
+				n->nr_partial--;
 		}
 
 		/*
 		 * Rebuild the partial list with the slabs filled up most
 		 * first and the least used slabs at the end.
 		 */
-		for (i = objects - 1; i >= 0; i--)
+		for (i = objects - 1; i > 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
 
 		spin_unlock_irqrestore(&n->list_lock, flags);
+
+		/* Release empty slabs */
+		list_for_each_entry_safe(page, t, slabs_by_inuse, lru)
+			discard_slab(s, page);
 	}
 
 	kfree(slabs_by_inuse);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
