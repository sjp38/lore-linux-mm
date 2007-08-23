From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 3/6] SLUB: Move page->offset to kmem_cache_cpu->offset
Date: Wed, 22 Aug 2007 23:46:56 -0700
Message-ID: <20070823064734.314280476@sgi.com>
References: <20070823064653.081843729@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756372AbXHWGsr@vger.kernel.org>
Content-Disposition: inline; filename=0007-SLUB-Move-page-offset-to-kmem_cache_cpu-offset.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

We need the offset from the page struct during slab_alloc and slab_free. In
both cases we also reference the cacheline of the kmem_cache_cpu structure.
We can therefore move the offset field into the kmem_cache_cpu structure
freeing up 16 bits in the page struct.

Moving the offset allows an allocation from slab_alloc() without touching the
page struct in the hot path.

The only thing left in slab_free() that touches the page struct cacheline for
per cpu freeing is the checking of SlabDebug(page). The next patch deals with
that.

Use the available 16 bits to broaden page->inuse. More than 64k objects per
slab become possible and we can get rid of the checks for that limitation.

No need anymore to shrink the order of slabs if we boot with 2M sized slabs
(slub_min_order=9).

No need anymore to switch off the offset calculation for very large slabs
since the field in the kmem_cache_cpu structure is 32 bits and so the offset
field can now handle slab sizes of up to 8GB.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/mm_types.h |    5 --
 include/linux/slub_def.h |    1 
 mm/slub.c                |   80 +++++++++--------------------------------------
 3 files changed, 18 insertions(+), 68 deletions(-)

Index: linux-2.6.23-rc3-mm1/include/linux/mm_types.h
===================================================================
--- linux-2.6.23-rc3-mm1.orig/include/linux/mm_types.h	2007-08-22 17:20:13.000000000 -0700
+++ linux-2.6.23-rc3-mm1/include/linux/mm_types.h	2007-08-22 17:20:28.000000000 -0700
@@ -37,10 +37,7 @@ struct page {
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
-		struct {	/* SLUB uses */
-			short unsigned int inuse;
-			short unsigned int offset;
-		};
+		unsigned int inuse;	/* SLUB: Nr of objects */
 	};
 	union {
 	    struct {
Index: linux-2.6.23-rc3-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc3-mm1.orig/include/linux/slub_def.h	2007-08-22 17:18:56.000000000 -0700
+++ linux-2.6.23-rc3-mm1/include/linux/slub_def.h	2007-08-22 17:23:29.000000000 -0700
@@ -15,6 +15,7 @@ struct kmem_cache_cpu {
 	void **freelist;
 	struct page *page;
 	int node;
+	unsigned int offset;
 	/* Lots of wasted space */
 } ____cacheline_aligned_in_smp;
 
Index: linux-2.6.23-rc3-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc3-mm1.orig/mm/slub.c	2007-08-22 17:20:13.000000000 -0700
+++ linux-2.6.23-rc3-mm1/mm/slub.c	2007-08-22 17:23:36.000000000 -0700
@@ -207,11 +207,6 @@ static inline void ClearSlabDebug(struct
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
-/*
- * The page->inuse field is 16 bit thus we have this limitation
- */
-#define MAX_OBJECTS_PER_SLAB 65535
-
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000 /* Poison object */
 #define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
@@ -736,11 +731,6 @@ static int check_slab(struct kmem_cache 
 		slab_err(s, page, "Not a valid slab page");
 		return 0;
 	}
-	if (page->offset * sizeof(void *) != s->offset) {
-		slab_err(s, page, "Corrupted offset %lu",
-			(unsigned long)(page->offset * sizeof(void *)));
-		return 0;
-	}
 	if (page->inuse > s->objects) {
 		slab_err(s, page, "inuse %u > max %u",
 			s->name, page->inuse, s->objects);
@@ -879,8 +869,6 @@ bad:
 		slab_fix(s, "Marking all objects used");
 		page->inuse = s->objects;
 		page->freelist = NULL;
-		/* Fix up fields that may be corrupted */
-		page->offset = s->offset / sizeof(void *);
 	}
 	return 0;
 }
@@ -996,30 +984,12 @@ __setup("slub_debug", setup_slub_debug);
 static void kmem_cache_open_debug_check(struct kmem_cache *s)
 {
 	/*
-	 * The page->offset field is only 16 bit wide. This is an offset
-	 * in units of words from the beginning of an object. If the slab
-	 * size is bigger then we cannot move the free pointer behind the
-	 * object anymore.
-	 *
-	 * On 32 bit platforms the limit is 256k. On 64bit platforms
-	 * the limit is 512k.
-	 *
-	 * Debugging or ctor may create a need to move the free
-	 * pointer. Fail if this happens.
+	 * Enable debugging if selected on the kernel commandline.
 	 */
-	if (s->objsize >= 65535 * sizeof(void *)) {
-		BUG_ON(s->flags & (SLAB_RED_ZONE | SLAB_POISON |
-				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
-		BUG_ON(s->ctor);
-	}
-	else
-		/*
-		 * Enable debugging if selected on the kernel commandline.
-		 */
-		if (slub_debug && (!slub_debug_slabs ||
-		    strncmp(slub_debug_slabs, s->name,
-		    	strlen(slub_debug_slabs)) == 0))
-				s->flags |= slub_debug;
+	if (slub_debug && (!slub_debug_slabs ||
+		strncmp(slub_debug_slabs, s->name,
+		strlen(slub_debug_slabs)) == 0))
+			s->flags |= slub_debug;
 }
 #else
 static inline void setup_object_debug(struct kmem_cache *s,
@@ -1102,7 +1072,6 @@ static struct page *new_slab(struct kmem
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
-	page->offset = s->offset / sizeof(void *);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
@@ -1396,10 +1365,10 @@ static void deactivate_slab(struct kmem_
 
 		/* Retrieve object from cpu_freelist */
 		object = c->freelist;
-		c->freelist = c->freelist[page->offset];
+		c->freelist = c->freelist[c->offset];
 
 		/* And put onto the regular freelist */
-		object[page->offset] = page->freelist;
+		object[c->offset] = page->freelist;
 		page->freelist = object;
 		page->inuse--;
 	}
@@ -1495,7 +1464,7 @@ load_freelist:
 		goto debug;
 
 	object = c->page->freelist;
-	c->freelist = object[c->page->offset];
+	c->freelist = object[c->offset];
 	c->page->inuse = s->objects;
 	c->page->freelist = NULL;
 	c->node = page_to_nid(c->page);
@@ -1547,7 +1516,7 @@ debug:
 		goto another_slab;
 
 	c->page->inuse++;
-	c->page->freelist = object[c->page->offset];
+	c->page->freelist = object[c->offset];
 	slab_unlock(c->page);
 	return object;
 }
@@ -1578,7 +1547,7 @@ static void __always_inline *slab_alloc(
 
 	else {
 		object = c->freelist;
-		c->freelist = object[c->page->offset];
+		c->freelist = object[c->offset];
 	}
 	local_irq_restore(flags);
 
@@ -1611,7 +1580,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  * handling required then we can return immediately.
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-					void *x, void *addr)
+				void *x, void *addr, unsigned int offset)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1621,7 +1590,7 @@ static void __slab_free(struct kmem_cach
 	if (unlikely(SlabDebug(page)))
 		goto debug;
 checks_ok:
-	prior = object[page->offset] = page->freelist;
+	prior = object[offset] = page->freelist;
 	page->freelist = object;
 	page->inuse--;
 
@@ -1682,10 +1651,10 @@ static void __always_inline slab_free(st
 	debug_check_no_locks_freed(object, s->objsize);
 	c = get_cpu_slab(s, smp_processor_id());
 	if (likely(page == c->page && !SlabDebug(page))) {
-		object[page->offset] = c->freelist;
+		object[c->offset] = c->freelist;
 		c->freelist = object;
 	} else
-		__slab_free(s, page, x, addr);
+		__slab_free(s, page, x, addr, c->offset);
 
 	local_irq_restore(flags);
 }
@@ -1777,14 +1746,6 @@ static inline int slab_order(int size, i
 	int rem;
 	int min_order = slub_min_order;
 
-	/*
-	 * If we would create too many object per slab then reduce
-	 * the slab order even if it goes below slub_min_order.
-	 */
-	while (min_order > 0 &&
-		(PAGE_SIZE << min_order) >= MAX_OBJECTS_PER_SLAB * size)
-			min_order--;
-
 	for (order = max(min_order,
 				fls(min_objects * size - 1) - PAGE_SHIFT);
 			order <= max_order; order++) {
@@ -1799,9 +1760,6 @@ static inline int slab_order(int size, i
 		if (rem <= slab_size / fract_leftover)
 			break;
 
-		/* If the next size is too high then exit now */
-		if (slab_size * 2 >= MAX_OBJECTS_PER_SLAB * size)
-			break;
 	}
 
 	return order;
@@ -1881,6 +1839,7 @@ static void init_kmem_cache_cpu(struct k
 {
 	c->page = NULL;
 	c->freelist = NULL;
+	c->offset = s->offset / sizeof(void *);
 	c->node = 0;
 }
 
@@ -2113,14 +2072,7 @@ static int calculate_sizes(struct kmem_c
 	 */
 	s->objects = (PAGE_SIZE << s->order) / size;
 
-	/*
-	 * Verify that the number of objects is within permitted limits.
-	 * The page->inuse field is only 16 bit wide! So we cannot have
-	 * more than 64k objects per slab.
-	 */
-	if (!s->objects || s->objects > MAX_OBJECTS_PER_SLAB)
-		return 0;
-	return 1;
+	return !!s->objects;
 
 }
 

-- 
