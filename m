Message-Id: <20070618095918.636873785@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:59:00 -0700
From: clameter@sgi.com
Subject: [patch 22/26] SLUB: kmem_cache_vacate to support page allocator memory defragmentation 
Content-Disposition: inline; filename=slab_defrag_kmem_cache_vacate
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Special function kmem_cache_vacate() to push out the objects in a
specified slab. In order to make that work we will have to handle
slab page allocations in such a way that we can determine if a slab is valid whenever we access it regardless of its time in life.

A valid slab that can be freed has PageSlab(page) and page->inuse > 0 set.
So we need to make sure in allocate_slab that page->inuse is zero before
PageSlab is set otherwise kmem_cache_vacate may operate on a slab that
has not been properly setup yet.

There is currently no in kernel user. The hope is that Mel's defragmentation
method can at some point use this functionality to make slabs movable
so that the reclaimable type of pages may not be necessary anymore.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h |    1 
 mm/slab.c            |    9 ++++
 mm/slob.c            |    9 ++++
 mm/slub.c            |  109 ++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 119 insertions(+), 9 deletions(-)

Index: linux-2.6.22-rc4-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slab.h	2007-06-17 18:12:29.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slab.h	2007-06-17 18:12:37.000000000 -0700
@@ -98,6 +98,7 @@ unsigned int kmem_cache_size(struct kmem
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 int kmem_cache_defrag(int percentage, int node);
+int kmem_cache_vacate(struct page *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-17 18:12:22.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-17 18:12:37.000000000 -0700
@@ -2523,6 +2523,15 @@ int kmem_cache_defrag(int percent, int n
 	return 0;
 }
 
+/*
+ * SLAB does not support slab defragmentation
+ */
+int kmem_cache_vacate(struct page *page)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_vacate);
+
 /**
  * kmem_cache_destroy - delete a cache
  * @cachep: the cache to destroy
Index: linux-2.6.22-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slob.c	2007-06-17 18:12:22.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slob.c	2007-06-17 18:12:37.000000000 -0700
@@ -558,6 +558,15 @@ int kmem_cache_defrag(int percentage, in
 	return 0;
 }
 
+/*
+ * SLOB does not support slab defragmentation
+ */
+int kmem_cache_vacate(struct page *page)
+{
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_vacate);
+
 int kmem_ptr_validate(struct kmem_cache *a, const void *b)
 {
 	return 0;
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:22.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:37.000000000 -0700
@@ -1038,6 +1038,7 @@ static inline int slab_pad_check(struct 
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
 static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct page *page) {}
 static inline void kmem_cache_open_debug_check(struct kmem_cache *s) {}
 #define slub_debug 0
 #endif
@@ -1103,12 +1104,11 @@ static struct page *new_slab(struct kmem
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+
+	page->inuse = 0;
+	page->lockless_freelist = NULL;
 	page->offset = s->offset / sizeof(void *);
 	page->slab = s;
-	page->flags |= 1 << PG_slab;
-	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
-			SLAB_STORE_USER | SLAB_TRACE))
-		SetSlabDebug(page);
 
 	start = page_address(page);
 	end = start + s->objects * s->size;
@@ -1126,11 +1126,20 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-	page->lockless_freelist = NULL;
-	page->inuse = 0;
-out:
-	if (flags & __GFP_WAIT)
-		local_irq_disable();
+
+	/*
+	 * page->inuse must be 0 when PageSlab(page) becomes
+	 * true so that defrag knows that this slab is not in use.
+	 */
+	smp_wmb();
+	__SetPageSlab(page);
+	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
+			SLAB_STORE_USER | SLAB_TRACE))
+		SetSlabDebug(page);
+
+ out:
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
 	return page;
 }
 
@@ -2654,6 +2663,88 @@ static unsigned long __kmem_cache_shrink
 }
 
 /*
+ * Get a page off a list and freeze it. Must be holding slab lock.
+ */
+static void freeze_from_list(struct kmem_cache *s, struct page *page)
+{
+	if (page->inuse < s->objects)
+		remove_partial(s, page);
+	else if (s->flags & SLAB_STORE_USER)
+		remove_full(s, page);
+	SetSlabFrozen(page);
+}
+
+/*
+ * Attempt to free objects in a page. Return 1 if succesful.
+ */
+int kmem_cache_vacate(struct page *page)
+{
+	unsigned long flags;
+	struct kmem_cache *s;
+	int vacated = 0;
+	void **vector = NULL;
+
+	/*
+	 * Get a reference to the page. Return if its freed or being freed.
+	 * This is necessary to make sure that the page does not vanish
+	 * from under us before we are able to check the result.
+	 */
+	if (!get_page_unless_zero(page))
+		return 0;
+
+	if (!PageSlab(page))
+		goto out;
+
+	s = page->slab;
+	if (!s)
+		goto out;
+
+	vector = kmalloc(s->objects * sizeof(void *), GFP_KERNEL);
+	if (!vector)
+		goto out2;
+
+	local_irq_save(flags);
+	/*
+	 * The implicit memory barrier in slab_lock guarantees that page->inuse
+	 * is loaded after PageSlab(page) has been established to be true.
+	 * Only revelant for a  newly created slab.
+	 */
+	slab_lock(page);
+
+	/*
+	 * We may now have locked a page that may be in various stages of
+	 * being freed. If the PageSlab bit is off then we have already
+	 * reached the page allocator. If page->inuse is zero then we are
+	 * in SLUB but freeing or allocating the page.
+	 * page->inuse is never modified without the slab lock held.
+	 *
+	 * Also abort if the page happens to be already frozen. If its
+	 * frozen then a concurrent vacate may be in progress.
+	 */
+	if (!PageSlab(page) || SlabFrozen(page) || !page->inuse)
+		goto out_locked;
+
+	/*
+	 * We are holding a lock on a slab page and all operations on the
+	 * slab are blocking.
+	 */
+	if (!s->ops->get || !s->ops->kick)
+		goto out_locked;
+	freeze_from_list(s, page);
+	vacated = __kmem_cache_vacate(s, page, flags, vector);
+out:
+	kfree(vector);
+out2:
+	put_page(page);
+	return vacated == 0;
+out_locked:
+	slab_unlock(page);
+	local_irq_restore(flags);
+	goto out;
+
+}
+
+/*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
  * most items in use come first. New allocations will then fill those up

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
