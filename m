Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B0A16B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 11:35:08 -0400 (EDT)
Date: Thu, 14 Jul 2011 10:35:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: slub: free slabs without holding locks (V2)
In-Reply-To: <alpine.DEB.2.00.1107140919050.30512@router.home>
Message-ID: <alpine.DEB.2.00.1107141033031.30512@router.home>
References: <alpine.DEB.2.00.1106201612310.17524@router.home> <1310065449.21902.60.camel@jaguar> <alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com> <alpine.DEB.2.00.1107140919050.30512@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

There are two situations in which slub holds a lock while releasing
pages:

	A. During kmem_cache_shrink()
	B. During kmem_cache_close()

For A build a list while holding the lock and then release the pages
later. In case of B we are the last remaining user of the slab so
there is no need to take the listlock.

After this patch all calls to the page allocator to free pages are
done without holding any locks.

V1->V2. Remove kfree. Avoid locking in free_partial. Drop slub_lock
too.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-07-14 09:41:03.587673788 -0500
+++ linux-2.6/mm/slub.c	2011-07-14 10:32:04.997654187 -0500
@@ -2652,13 +2652,13 @@ static void list_slab_objects(struct kme

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
 			__remove_partial(n, page);
@@ -2668,7 +2668,6 @@ static void free_partial(struct kmem_cac
 				"Objects remaining on kmem_cache_close()");
 		}
 	}
-	spin_unlock_irqrestore(&n->list_lock, flags);
 }

 /*
@@ -2702,6 +2701,7 @@ void kmem_cache_destroy(struct kmem_cach
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
+		up_write(&slub_lock);
 		if (kmem_cache_close(s)) {
 			printk(KERN_ERR "SLUB %s: %s called for cache that "
 				"still has objects.\n", s->name, __func__);
@@ -2710,8 +2710,8 @@ void kmem_cache_destroy(struct kmem_cach
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 		sysfs_slab_remove(s);
-	}
-	up_write(&slub_lock);
+	} else
+		up_write(&slub_lock);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);

@@ -2993,29 +2993,23 @@ int kmem_cache_shrink(struct kmem_cache
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
-				__remove_partial(n, page);
-				slab_unlock(page);
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
