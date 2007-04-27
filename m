Message-Id: <20070427042908.710590847@sgi.com>
References: <20070427042655.019305162@sgi.com>
Date: Thu, 26 Apr 2007 21:27:01 -0700
From: clameter@sgi.com
Subject: [patch 06/10] SLUB: Free slabs and sort partial slab lists in kmem_cache_shrink
Content-Disposition: inline; filename=slab_shrink_cache
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

At kmem_cache_shrink check if we have any empty slabs on the partial
if so then remove them.

Also--as an anti-fragmentation measure--sort the partial slabs so that
the most fully allocated ones come first and the least allocated last.

The next allocations may fill up the nearly full slabs. Having the
least allocated slabs last gives them the maximum chance that their
remaining objects may be freed. Thus we can hopefully minimize the
partial slabs.

I think this is the best one can do in terms antifragmentation
measures. Real defragmentation (meaning moving objects out of slabs with
the least free objects to those that are almost full) can be implemted
by reverse scanning through the list produced here but that would mean
that we need to provide a callback at slab cache creation that allows
the deletion or moving of an object. This will involve slab API
changes, so defer for now.

Cc: Mel Gorman <mel@skynet.ie>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |  118 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 104 insertions(+), 14 deletions(-)

Index: linux-2.6.21-rc7-mm2/mm/slub.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/mm/slub.c	2007-04-26 20:59:01.000000000 -0700
+++ linux-2.6.21-rc7-mm2/mm/slub.c	2007-04-26 20:59:21.000000000 -0700
@@ -109,9 +109,19 @@
 /* Enable to test recovery from slab corruption on boot */
 #undef SLUB_RESILIENCY_TEST
 
-/* Mininum number of partial slabs */
+/*
+ * Mininum number of partial slabs. These will be left on the partial
+ * lists even if they are empty. kmem_cache_shrink may reclaim them.
+ */
 #define MIN_PARTIAL 2
 
+/*
+ * Maximum number of desirable partial slabs.
+ * The existence of more partial slabs makes kmem_cache_shrink
+ * sort the partial list by the number of objects in the.
+ */
+#define MAX_PARTIAL 10
+
 #define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
 /*
@@ -1915,7 +1925,7 @@ static int kmem_cache_close(struct kmem_
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		free_list(s, n, &n->partial);
+		n->nr_partial -= free_list(s, n, &n->partial);
 		if (atomic_long_read(&n->nr_slabs))
 			return 1;
 	}
@@ -2164,6 +2174,79 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+/*
+ *  kmem_cache_shrink removes empty slabs from the partial lists
+ *  and then sorts the partially allocated slabs by the number
+ *  of items in use. The slabs with the most items in use
+ *  come first. New allocations will remove these from the
+ *  partial list because they are full. The slabs with the
+ *  least items are placed last. If it happens that the objects
+ *  are freed then the page can be returned to the page allocator.
+ */
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+	int i;
+	struct kmem_cache_node *n;
+	struct page *page;
+	struct page *t;
+	struct list_head *slabs_by_inuse =
+		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
+	unsigned long flags;
+
+	if (!slabs_by_inuse)
+		return -ENOMEM;
+
+	flush_all(s);
+	for_each_online_node(node) {
+		n = get_node(s, node);
+
+		if (n->nr_partial <= MIN_PARTIAL)
+			continue;
+
+		for (i = 0; i < s->objects; i++)
+			INIT_LIST_HEAD(slabs_by_inuse + i);
+
+		spin_lock_irqsave(&n->list_lock, flags);
+
+		/*
+		 * Build lists indexed by the items in use in
+		 * each slab or free slabs if empty.
+		 *
+		 * Note that concurrent frees may occur while
+		 * we hold the list_lock. page->inuse here is
+		 * the upper limit.
+		 */
+		list_for_each_entry_safe(page, t, &n->partial, lru) {
+			if (!page->inuse) {
+				list_del(&page->lru);
+				n->nr_partial--;
+				discard_slab(s, page);
+			} else
+			if (n->nr_partial > MAX_PARTIAL)
+				list_move(&page->lru,
+					slabs_by_inuse + page->inuse);
+		}
+
+		if (n->nr_partial <= MAX_PARTIAL)
+			goto out;
+
+		/*
+		 * Rebuild the partial list with the slabs filled up
+		 * most first and the least used slabs at the end.
+		 */
+		for (i = s->objects - 1; i > 0; i--)
+			list_splice(slabs_by_inuse + i, n->partial.prev);
+
+	out:
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	kfree(slabs_by_inuse);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
 /**
  * krealloc - reallocate memory. The contents will remain unchanged.
  *
@@ -2409,17 +2492,6 @@ static struct notifier_block __cpuinitda
 
 #endif
 
-/***************************************************************
- *	Compatiblility definitions
- **************************************************************/
-
-int kmem_cache_shrink(struct kmem_cache *s)
-{
-	flush_all(s);
-	return 0;
-}
-EXPORT_SYMBOL(kmem_cache_shrink);
-
 #ifdef CONFIG_NUMA
 
 /*****************************************************************
@@ -3195,6 +3267,25 @@ static ssize_t validate_store(struct kme
 }
 SLAB_ATTR(validate);
 
+static ssize_t shrink_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+static ssize_t shrink_store(struct kmem_cache *s,
+			const char *buf, size_t length)
+{
+	if (buf[0] == '1') {
+		int rc = kmem_cache_shrink(s);
+
+		if (rc)
+			return rc;
+	} else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(shrink);
+
 static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
 {
 	if (!(s->flags & SLAB_STORE_USER))
@@ -3251,6 +3342,7 @@ static struct attribute * slab_attrs[] =
 	&poison_attr.attr,
 	&store_user_attr.attr,
 	&validate_attr.attr,
+	&shrink_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
 #ifdef CONFIG_ZONE_DMA

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
