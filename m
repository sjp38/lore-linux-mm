Message-Id: <20070504221708.596112123@sgi.com>
References: <20070504221555.642061626@sgi.com>
Date: Fri, 04 May 2007 15:15:57 -0700
From: clameter@sgi.com
Subject: [RFC 2/3] SLUB: Implement targeted reclaim and partial list defragmentation
Content-Disposition: inline; filename=reclaim_callback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Targeted reclaim allows to target a single slab for reclaim. This is done by
calling

kmem_cache_vacate(slab, page);

It will return 1 on success, 0 if the operation failed.

The vacate functionality is also used for slab shrinking. During the shrink
operation SLUB will generate a list sorted by the number of objects in use.

We extract pages off that list that are only filled less than a quarter. These
objects are then processed using kmem_cache_vacate.

In order for a slabcache to support this functionality two functions must
be defined via slab_operations.

get_reference(void *)

Must obtain a reference to the object if it has not been freed yet. It is up
to the slabcache to resolve the race. SLUB guarantees that the objects is
still allocated. However, another thread may be blocked in slab_free
attempting to free the same object. It may succeed as soon as
get_reference() returns to the slab allocator.

get_reference() processing must recognize this situation (i.e. check refcount
for zero) and fail in such a sitation (no problem since the object will
be freed as soon we drop the slab lock before doing kick calls).

No slab operations may be performed in get_reference(). The slab lock
for the page with the object is taken. Any slab operations may lead to
a deadlock.

2. kick_object(void *)

After SLUB has established references to the remaining objects in a slab it
will drop all locks and then use kick_object on each of the objects for which
we obtained a reference. The existence of the objects is guaranteed by
virtue of the earlier obtained reference. The callback may perform any
slab operation since no locks are held at the time of call.

The callback should remove the object from the slab in some way. This may
be accomplished by reclaiming the object and then running kmem_cache_free()
or reallocating it and then running kmem_cache_free(). Reallocation
is advantageous at this point because it will then allocate from the partial
slabs with the most objects because we have just finished slab shrinking.

NOTE: This patch is for conceptual review. I'd appreciate any feedback
especially on the locking approach taken here. It will be critical to
resolve the locking issue for this approach to become feasable.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h |    3 
 mm/slub.c            |  159 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 154 insertions(+), 8 deletions(-)

Index: slub/include/linux/slab.h
===================================================================
--- slub.orig/include/linux/slab.h	2007-05-04 13:32:34.000000000 -0700
+++ slub/include/linux/slab.h	2007-05-04 13:32:50.000000000 -0700
@@ -42,6 +42,8 @@ struct slab_ops {
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
 	/* FIXME: Remove all destructors ? */
 	void (*dtor)(void *, struct kmem_cache *, unsigned long);
+	int (*get_reference)(void *);
+	void (*kick_object)(void *);
 };
 
 struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
@@ -54,6 +56,7 @@ void kmem_cache_free(struct kmem_cache *
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
+int kmem_cache_vacate(struct page *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-04 13:32:34.000000000 -0700
+++ slub/mm/slub.c	2007-05-04 13:56:25.000000000 -0700
@@ -173,7 +173,7 @@ static struct notifier_block slab_notifi
 static enum {
 	DOWN,		/* No slab functionality available */
 	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
-	UP,		/* Everything works */
+	UP,		/* Everything works but does not show up in sysfs */
 	SYSFS		/* Sysfs up */
 } slab_state = DOWN;
 
@@ -211,6 +211,8 @@ static inline struct kmem_cache_node *ge
 
 struct slab_ops default_slab_ops = {
 	NULL,
+	NULL,
+	NULL,
 	NULL
 };
 
@@ -839,13 +841,10 @@ static struct page *new_slab(struct kmem
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+
 	page->offset = s->offset / sizeof(void *);
 	page->slab = s;
-	page->flags |= 1 << PG_slab;
-	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
-			SLAB_STORE_USER | SLAB_TRACE))
-		page->flags |= 1 << PG_error;
-
+	page->inuse = 0;
 	start = page_address(page);
 	end = start + s->objects * s->size;
 
@@ -862,7 +861,17 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-	page->inuse = 0;
+
+	/*
+	 * pages->inuse must be visible when PageSlab(page) becomes
+	 * true for targeted reclaim
+	 */
+	smp_wmb();
+	page->flags |= 1 << PG_slab;
+	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
+			SLAB_STORE_USER | SLAB_TRACE))
+		page->flags |= 1 << PG_error;
+
 out:
 	if (flags & __GFP_WAIT)
 		local_irq_disable();
@@ -2124,6 +2133,111 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
 /*
+ * Vacate all objects in the given slab. Slab must be locked.
+ *
+ * Will drop and regain and drop the slab lock.
+ * Slab must be marked PageActive() to avoid concurrent slab_free from
+ * remove the slab from the lists. At the end the slab will either
+ * be freed or have been returned to the partial lists.
+ *
+ * Return error code or number of remaining objects
+ */
+static int __kmem_cache_vacate(struct kmem_cache *s, struct page *page)
+{
+	void *p;
+	void *addr = page_address(page);
+	unsigned long map[BITS_TO_LONGS(s->objects)];
+	int leftover;
+
+	if (!page->inuse)
+		return 0;
+
+	/* Determine free objects */
+	bitmap_zero(map, s->objects);
+	for(p = page->freelist; p; p = get_freepointer(s, p))
+		set_bit((p - addr) / s->size, map);
+
+	/*
+	 * Get a refcount for all used objects. If that fails then
+	 * no KICK callback can be performed.
+	 */
+	for(p = addr; p < addr + s->objects * s->size; p += s->size)
+		if (!test_bit((p - addr) / s->size, map))
+			if (!s->slab_ops->get_reference(p))
+				set_bit((p - addr) / s->size, map);
+
+	/* Got all the references we need. Now we can drop the slab lock */
+	slab_unlock(page);
+
+	/* Perform the KICK callbacks to remove the objects */
+	for(p = addr; p < addr + s->objects * s->size; p += s->size)
+		if (!test_bit((p - addr) / s->size, map))
+			s->slab_ops->kick_object(p);
+
+	slab_lock(page);
+	leftover = page->inuse;
+	ClearPageActive(page);
+	putback_slab(s, page);
+	return leftover;
+}
+
+/*
+ * Remove a page from the lists. Must be holding slab lock.
+ */
+static void remove_from_lists(struct kmem_cache *s, struct page *page)
+{
+	if (page->inuse < s->objects)
+		remove_partial(s, page);
+	else if (s->flags & SLAB_STORE_USER)
+		remove_full(s, page);
+}
+
+/*
+ * Attempt to free objects in a page. Return 1 when succesful.
+ */
+int kmem_cache_vacate(struct page *page)
+{
+	struct kmem_cache *s;
+	int rc = 0;
+
+	/* Get a reference to the page. Return if its freed or being freed */
+	if (!get_page_unless_zero(page))
+		return 0;
+
+	/* Check that this is truly a slab page */
+	if (!PageSlab(page))
+		goto out;
+
+	slab_lock(page);
+
+	/*
+	 * We may now have locked a page that is in various stages of being
+	 * freed. If the PageSlab bit is off then we have already reached
+	 * the page allocator. If page->inuse is zero then we are
+	 * in SLUB but freeing or allocating the page.
+	 * page->inuse is never modified without the slab lock held.
+	 *
+	 * Also abort if the page happens to be a per cpu slab
+	 */
+	if (!PageSlab(page) || PageActive(page) || !page->inuse) {
+		slab_unlock(page);
+		goto out;
+	}
+
+	/*
+	 * We are holding a lock on a slab page that is not in the
+	 * process of being allocated or freed.
+	 */
+	s = page->slab;
+	remove_from_lists(s, page);
+	SetPageActive(page);
+	rc = __kmem_cache_vacate(s, page) == 0;
+out:
+	put_page(page);
+	return rc;
+}
+
+/*
  *  kmem_cache_shrink removes empty slabs from the partial lists
  *  and then sorts the partially allocated slabs by the number
  *  of items in use. The slabs with the most items in use
@@ -2137,11 +2251,12 @@ int kmem_cache_shrink(struct kmem_cache 
 	int node;
 	int i;
 	struct kmem_cache_node *n;
-	struct page *page;
+	struct page *page, *page2;
 	struct page *t;
 	struct list_head *slabs_by_inuse =
 		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
 	unsigned long flags;
+	LIST_HEAD(zaplist);
 
 	if (!slabs_by_inuse)
 		return -ENOMEM;
@@ -2194,8 +2309,36 @@ int kmem_cache_shrink(struct kmem_cache 
 		for (i = s->objects - 1; i >= 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
 
+		if (!s->slab_ops->get_reference || !s->slab_ops->kick_object)
+			goto out;
+
+		/* Take objects with just a few objects off the tail */
+		while (n->nr_partial > MAX_PARTIAL) {
+			page = container_of(n->partial.prev, struct page, lru);
+
+			/*
+			 * We are holding the list_lock so we can only
+			 * trylock the slab
+			 */
+			if (!slab_trylock(page))
+				break;
+
+			if (page->inuse > s->objects / 4)
+				break;
+
+			list_move(&page->lru, &zaplist);
+			n->nr_partial--;
+			SetPageActive(page);
+			slab_unlock(page);
+		}
 	out:
 		spin_unlock_irqrestore(&n->list_lock, flags);
+
+		/* Now we can free objects in the slabs on the zaplist */
+		list_for_each_entry_safe(page, page2, &zaplist, lru) {
+			slab_lock(page);
+			__kmem_cache_vacate(s, page);
+		}
 	}
 
 	kfree(slabs_by_inuse);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
