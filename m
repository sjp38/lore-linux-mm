Date: Fri, 4 May 2007 20:28:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Support concurrent local and remote frees and allocs on a slab.
Message-ID: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

About 5-10% performance gain on netperf.

[Maybe put this patch at the end of the merge queue? Works fine here but
this is a significant change that may impact stability]

What we do is use the last free field in the page struct (the private
field that was freed up through the compound page flag rework) to setup a
separate per cpu freelist. From that one we can allocate without taking the
slab lock because we checkout the complete list of free objects when we
first touch the slab and then mark the slab as completely allocated.
If we have a cpu_freelist then we can also free to that list if we run on
that processor without taking the slab lock.

This allows even concurrent allocations and frees on the same slab using
two mutually exclusive freelists. Allocs and frees from the processor
owning the per cpu slab will bypass the slab lock using the cpu_freelist.
Remove frees will use the slab lock to synchronize and use the freelist
for marking items as free. So local allocs and frees may run concurrently
with remote frees without synchronization.

If the allocator is running out of its per cpu freelist then it will consult
the per slab freelist (which requires the slab lock) and reload the
cpu_freelist if there are objects that were remotely freed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    5 ++-
 mm/slub.c                |   67 ++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 59 insertions(+), 13 deletions(-)

Index: slub/include/linux/mm_types.h
===================================================================
--- slub.orig/include/linux/mm_types.h	2007-05-04 20:09:26.000000000 -0700
+++ slub/include/linux/mm_types.h	2007-05-04 20:09:33.000000000 -0700
@@ -50,9 +50,12 @@ struct page {
 	    spinlock_t ptl;
 #endif
 	    struct {			/* SLUB uses */
-		struct page *first_page;	/* Compound pages */
+	    	void **cpu_freelist;		/* Per cpu freelist */
 		struct kmem_cache *slab;	/* Pointer to slab */
 	    };
+	    struct {
+		struct page *first_page;	/* Compound pages */
+	    };
 	};
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-04 20:09:26.000000000 -0700
+++ slub/mm/slub.c	2007-05-04 20:14:04.000000000 -0700
@@ -81,10 +81,13 @@
  * PageActive 		The slab is used as a cpu cache. Allocations
  * 			may be performed from the slab. The slab is not
  * 			on any slab list and cannot be moved onto one.
+ * 			The cpu slab may have a cpu_freelist in order
+ * 			to optimize allocations and frees on a particular
+ * 			cpu.
  *
  * PageError		Slab requires special handling due to debug
  * 			options set. This moves	slab handling out of
- * 			the fast path.
+ * 			the fast path and disables cpu_freelists.
  */
 
 /*
@@ -857,6 +860,7 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
+	page->cpu_freelist = NULL;
 	page->inuse = 0;
 out:
 	if (flags & __GFP_WAIT)
@@ -1121,6 +1125,23 @@ static void putback_slab(struct kmem_cac
  */
 static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
 {
+	/*
+	 * Merge cpu freelist into freelist. Typically we get here
+	 * because both freelists are empty. So this is unlikely
+	 * to occur.
+	 */
+	while (unlikely(page->cpu_freelist)) {
+		void **object;
+
+		/* Retrieve object from cpu_freelist */
+		object = page->cpu_freelist;
+		page->cpu_freelist = page->cpu_freelist[page->offset];
+
+		/* And put onto the regular freelist */
+		object[page->offset] = page->freelist;
+		page->freelist = object;
+		page->inuse--;
+	}
 	s->cpu_slab[cpu] = NULL;
 	ClearPageActive(page);
 
@@ -1190,22 +1211,33 @@ static void *slab_alloc(struct kmem_cach
 	local_irq_save(flags);
 	cpu = smp_processor_id();
 	page = s->cpu_slab[cpu];
-	if (!page)
+	if (unlikely(!page))
 		goto new_slab;
 
-	slab_lock(page);
-	if (unlikely(node != -1 && page_to_nid(page) != node))
+	if (unlikely(node != -1 && page_to_nid(page) != node)) {
+		slab_lock(page);
 		goto another_slab;
+	}
+
+	if (likely(page->cpu_freelist)) {
+		object = page->cpu_freelist;
+		page->cpu_freelist = object[page->offset];
+		local_irq_restore(flags);
+		return object;
+	}
+
+	slab_lock(page);
 redo:
-	object = page->freelist;
-	if (unlikely(!object))
+	if (!page->freelist)
 		goto another_slab;
-	if (unlikely(PageError(page)))
+	if (PageError(page))
 		goto debug;
 
-have_object:
-	page->inuse++;
-	page->freelist = object[page->offset];
+	/* Reload the cpu freelist while allocating the next object */
+	object = page->freelist;
+	page->cpu_freelist = object[page->offset];
+	page->freelist = NULL;
+	page->inuse = s->objects;
 	slab_unlock(page);
 	local_irq_restore(flags);
 	return object;
@@ -1215,7 +1247,7 @@ another_slab:
 
 new_slab:
 	page = get_partial(s, gfpflags, node);
-	if (likely(page)) {
+	if (page) {
 have_slab:
 		s->cpu_slab[cpu] = page;
 		SetPageActive(page);
@@ -1251,6 +1283,7 @@ have_slab:
 	local_irq_restore(flags);
 	return NULL;
 debug:
+	object = page->freelist;
 	if (!alloc_object_checks(s, page, object))
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
@@ -1261,8 +1294,12 @@ debug:
 			page->freelist);
 		dump_stack();
 	}
+	page->freelist = object[page->offset];
+	page->inuse++;
 	init_object(s, object, 1);
-	goto have_object;
+	slab_unlock(page);
+	local_irq_restore(flags);
+	return object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
@@ -1293,6 +1330,12 @@ static void slab_free(struct kmem_cache 
 	unsigned long flags;
 
 	local_irq_save(flags);
+	if (page == s->cpu_slab[smp_processor_id()] && !PageError(page)) {
+		object[page->offset] = page->cpu_freelist;
+		page->cpu_freelist = object;
+		local_irq_restore(flags);
+		return;
+	}
 	slab_lock(page);
 
 	if (unlikely(PageError(page)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
