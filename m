Date: Thu, 22 Feb 2007 14:39:12 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [RFC/PATCH] slab: free pages in a batch in drain_freelist
Message-ID: <Pine.LNX.4.64.0702221437400.14523@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Pekka Enberg <penberg@cs.helsinki.fi>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, wli@holomorphy.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

As suggested by William, free the actual pages in a batch so that we
don't keep pounding on l3->list_lock.

Cc: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/slab.c |   32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

Index: uml-2.6/mm/slab.c
===================================================================
--- uml-2.6.orig/mm/slab.c	2007-02-22 14:19:46.000000000 +0200
+++ uml-2.6/mm/slab.c	2007-02-22 14:28:01.000000000 +0200
@@ -2437,38 +2437,36 @@
  *
  * Returns the actual number of slabs released.
  */
-static int drain_freelist(struct kmem_cache *cache,
-			struct kmem_list3 *l3, int tofree)
+static int drain_freelist(struct kmem_cache *cache, struct kmem_list3 *l3,
+			  int tofree)
 {
+	struct slab *slabp, *this, *next;
+	struct list_head to_free_list;
 	struct list_head *p;
 	int nr_freed;
-	struct slab *slabp;
 
+	INIT_LIST_HEAD(&to_free_list);
 	nr_freed = 0;
-	while (nr_freed < tofree && !list_empty(&l3->slabs_free)) {
 
-		spin_lock_irq(&l3->list_lock);
+	spin_lock_irq(&l3->list_lock);
+	while (nr_freed < tofree && !list_empty(&l3->slabs_free)) {
 		p = l3->slabs_free.prev;
-		if (p == &l3->slabs_free) {
-			spin_unlock_irq(&l3->list_lock);
-			goto out;
-		}
+		if (p == &l3->slabs_free)
+			break;
 
 		slabp = list_entry(p, struct slab, list);
 #if DEBUG
 		BUG_ON(slabp->inuse);
 #endif
-		list_del(&slabp->list);
-		/*
-		 * Safe to drop the lock. The slab is no longer linked
-		 * to the cache.
-		 */
+		list_move(&slabp->list, &to_free_list);
 		l3->free_objects -= cache->num;
-		spin_unlock_irq(&l3->list_lock);
-		slab_destroy(cache, slabp);
 		nr_freed++;
 	}
-out:
+	spin_unlock_irq(&l3->list_lock);
+
+	list_for_each_entry_safe(this, next, &to_free_list, list)
+		slab_destroy(cache, this);
+
 	return nr_freed;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
