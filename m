Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E88790014E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 11:31:15 -0400 (EDT)
Date: Mon, 1 Aug 2011 10:30:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: free slabs without holding locks (V2)
In-Reply-To: <CAOJsxLF_BaPGx9CcYewKHs0FQdK_HfNXW5ptu2w9nAs47+GodQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1108011030000.8420@router.home>
References: <alpine.DEB.2.00.1106201612310.17524@router.home> <1310065449.21902.60.camel@jaguar> <alpine.DEB.2.00.1107131710050.4557@chino.kir.corp.google.com> <alpine.DEB.2.00.1107140919050.30512@router.home> <alpine.DEB.2.00.1107141033031.30512@router.home>
 <CAOJsxLF_BaPGx9CcYewKHs0FQdK_HfNXW5ptu2w9nAs47+GodQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Sun, 31 Jul 2011, Pekka Enberg wrote:

> I'd like to merge this patch but it doesn't apply on top of Linus'
> tree. Care to resend?

Patch rediffed against todays upstream tree.


Subject: slub: free slabs without holding locks (V2)

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
--- linux-2.6.orig/mm/slub.c	2011-08-01 10:22:37.455874973 -0500
+++ linux-2.6/mm/slub.c	2011-08-01 10:24:38.525874198 -0500
@@ -2968,13 +2968,13 @@ static void list_slab_objects(struct kme

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
@@ -2984,7 +2984,6 @@ static void free_partial(struct kmem_cac
 				"Objects remaining on kmem_cache_close()");
 		}
 	}
-	spin_unlock_irqrestore(&n->list_lock, flags);
 }

 /*
@@ -3018,6 +3017,7 @@ void kmem_cache_destroy(struct kmem_cach
 	s->refcount--;
 	if (!s->refcount) {
 		list_del(&s->list);
+		up_write(&slub_lock);
 		if (kmem_cache_close(s)) {
 			printk(KERN_ERR "SLUB %s: %s called for cache that "
 				"still has objects.\n", s->name, __func__);
@@ -3026,8 +3026,8 @@ void kmem_cache_destroy(struct kmem_cach
 		if (s->flags & SLAB_DESTROY_BY_RCU)
 			rcu_barrier();
 		sysfs_slab_remove(s);
-	}
-	up_write(&slub_lock);
+	} else
+		up_write(&slub_lock);
 }
 EXPORT_SYMBOL(kmem_cache_destroy);

@@ -3345,23 +3345,23 @@ int kmem_cache_shrink(struct kmem_cache
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
