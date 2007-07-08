From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 12/12] Slab defragmentation: kmem_cache_vacate for antifrag / memory compaction
Date: Sat, 07 Jul 2007 20:05:50 -0700
Message-ID: <20070708030846.235829535@sgi.com>
References: <20070708030538.729027694@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757111AbXGHDMF@vger.kernel.org>
Content-Disposition: inline; filename=slab_defrag_kmem_cache_vacate
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com
List-Id: linux-mm.kvack.org

[only for review, untested, waiting for Mel to get around to use this to
improve memory compaction or antifragmentation]

Special function kmem_cache_vacate() to push out the objects in a
specified slab. In order to make that work we will have to handle
slab page allocations in such a way that we can determine if a slab is valid whenever we access it regardless of its time in life.

A valid slab that can be freed has PageSlab(page) and page->inuse > 0 set.
So we need to make sure in allocate_slab that page->inuse is zero before
PageSlab is set otherwise kmem_cache_vacate may operate on a slab that
has not been properly setup yet.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h |    1 
 mm/slab.c            |    9 ++++
 mm/slob.c            |    9 ++++
 mm/slub.c            |  105 +++++++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 117 insertions(+), 7 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/slab.h	2007-07-05 19:05:02.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/slab.h	2007-07-05 19:05:08.000000000 -0700
@@ -97,6 +97,7 @@ unsigned int kmem_cache_size(struct kmem
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 int kmem_cache_defrag(int node);
+int kmem_cache_vacate(struct page *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6.22-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slab.c	2007-07-05 19:00:20.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slab.c	2007-07-05 19:05:08.000000000 -0700
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
Index: linux-2.6.22-rc6-mm1/mm/slob.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slob.c	2007-07-05 19:00:20.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slob.c	2007-07-05 19:05:08.000000000 -0700
@@ -596,6 +596,15 @@ int kmem_cache_defrag(int percentage, in
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
Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-05 19:01:48.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-05 19:05:08.000000000 -0700
@@ -1041,6 +1041,7 @@ static inline int slab_pad_check(struct 
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
 static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct page *page) {}
 static inline void kmem_cache_open_debug_check(struct kmem_cache *s) {}
 #define slub_debug 0
 #endif
@@ -1106,12 +1107,11 @@ static struct page *new_slab(struct kmem
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
@@ -1129,9 +1129,18 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-	page->lockless_freelist = NULL;
-	page->inuse = 0;
-out:
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
 	if (flags & __GFP_WAIT)
 		local_irq_disable();
 	return page;
@@ -2660,6 +2669,88 @@ static unsigned long __kmem_cache_shrink
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
