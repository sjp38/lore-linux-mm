Date: Fri, 12 Oct 2007 11:27:42 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 001/002] extract kmem_cache_shrink
In-Reply-To: <20071012112236.B99B.Y-GOTO@jp.fujitsu.com>
References: <20071012111008.B995.Y-GOTO@jp.fujitsu.com> <20071012112236.B99B.Y-GOTO@jp.fujitsu.com>
Message-Id: <20071012112648.B99F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Make kmem_cache_shrink_node() for callback routine of memory hotplug
notifier. This is just extract a part of kmem_cache_shrink().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/slub.c |  111 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 61 insertions(+), 50 deletions(-)

Index: current/mm/slub.c
===================================================================
--- current.orig/mm/slub.c	2007-10-11 20:30:45.000000000 +0900
+++ current/mm/slub.c	2007-10-11 21:58:47.000000000 +0900
@@ -2626,6 +2626,56 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static inline void __kmem_cache_shrink_node(struct kmem_cache *s, int node,
+					    struct list_head *slabs_by_inuse)
+{
+	struct kmem_cache_node *n;
+	int i;
+	struct page *page;
+	struct page *t;
+	unsigned long flags;
+
+	n = get_node(s, node);
+
+	if (!n->nr_partial)
+		return;
+
+	for (i = 0; i < s->objects; i++)
+		INIT_LIST_HEAD(slabs_by_inuse + i);
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
+	/*
+	 * Build lists indexed by the items in use in each slab.
+	 *
+	 * Note that concurrent frees may occur while we hold the
+	 * list_lock. page->inuse here is the upper limit.
+	 */
+	list_for_each_entry_safe(page, t, &n->partial, lru) {
+		if (!page->inuse && slab_trylock(page)) {
+			/*
+			 * Must hold slab lock here because slab_free
+			 * may have freed the last object and be
+			 * waiting to release the slab.
+			 */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+		} else
+			list_move(&page->lru, slabs_by_inuse + page->inuse);
+	}
+
+	/*
+	 * Rebuild the partial list with the slabs filled up most
+	 * first and the least used slabs at the end.
+	 */
+	for (i = s->objects - 1; i >= 0; i--)
+		list_splice(slabs_by_inuse + i, n->partial.prev);
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+}
+
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
@@ -2636,68 +2686,29 @@ EXPORT_SYMBOL(kfree);
  * being allocated from last increasing the chance that the last objects
  * are freed in them.
  */
-int kmem_cache_shrink(struct kmem_cache *s)
+int kmem_cache_shrink_node(struct kmem_cache *s, int node)
 {
-	int node;
-	int i;
-	struct kmem_cache_node *n;
-	struct page *page;
-	struct page *t;
 	struct list_head *slabs_by_inuse =
 		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
-	unsigned long flags;
 
 	if (!slabs_by_inuse)
 		return -ENOMEM;
 
 	flush_all(s);
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		n = get_node(s, node);
-
-		if (!n->nr_partial)
-			continue;
-
-		for (i = 0; i < s->objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
-
-		spin_lock_irqsave(&n->list_lock, flags);
-
-		/*
-		 * Build lists indexed by the items in use in each slab.
-		 *
-		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
-		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
-				list_del(&page->lru);
-				n->nr_partial--;
-				slab_unlock(page);
-				discard_slab(s, page);
-			} else {
-				list_move(&page->lru,
-				slabs_by_inuse + page->inuse);
-			}
-		}
-
-		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
-		 */
-		for (i = s->objects - 1; i >= 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
-
-		spin_unlock_irqrestore(&n->list_lock, flags);
-	}
+	if (node >= 0)
+		__kmem_cache_shrink_node(s, node, slabs_by_inuse);
+	else
+		for_each_node_state(node, N_NORMAL_MEMORY)
+			__kmem_cache_shrink_node(s, node, slabs_by_inuse);
 
 	kfree(slabs_by_inuse);
 	return 0;
 }
+
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	return kmem_cache_shrink_node(s, -1);
+}
 EXPORT_SYMBOL(kmem_cache_shrink);
 
 /********************************************************************

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
