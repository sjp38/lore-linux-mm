Message-Id: <20080216004632.588581391@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:30 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/17] SLUB: Add get() and kick() methods
Content-Disposition: inline; filename=0050-SLUB-Add-get-and-kick-methods.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Add the two methods needed for defragmentation and add the display of the
methods via the proc interface.

Add documentation explaining the use of these methods.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab_def.h |    4 ++++
 include/linux/slob_def.h |    4 ++++
 include/linux/slub_def.h |   35 +++++++++++++++++++++++++++++++++++
 mm/slub.c                |   32 ++++++++++++++++++++++++++++++--
 4 files changed, 73 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-15 16:38:21.753876823 -0800
+++ linux-2.6/include/linux/slub_def.h	2008-02-15 16:38:31.401917080 -0800
@@ -74,6 +74,37 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(struct kmem_cache *, void *);
+	/*
+	 * Called with slab lock held and interrupts disabled.
+	 * No slab operation may be performed in get().
+	 *
+	 * Parameters passed are the number of objects to process
+	 * and an array of pointers to objects for which we
+	 * need references.
+	 *
+	 * Returns a pointer that is passed to the kick function.
+	 * If all objects cannot be moved then the pointer may
+	 * indicate that this wont work and then kick can simply
+	 * remove the references that were already obtained.
+	 *
+	 * The array passed to get() is also passed to kick(). The
+	 * function may remove objects by setting array elements to NULL.
+	 */
+	void *(*get)(struct kmem_cache *, int nr, void **);
+
+	/*
+	 * Called with no locks held and interrupts enabled.
+	 * Any operation may be performed in kick().
+	 *
+	 * Parameters passed are the number of objects in the array,
+	 * the array of pointers to the objects and the pointer
+	 * returned by get().
+	 *
+	 * Success is checked by examining the number of remaining
+	 * objects in the slab.
+	 */
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private);
+
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int defrag_ratio;	/*
@@ -238,4 +269,8 @@ static __always_inline void *kmalloc_nod
 }
 #endif
 
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
+
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-15 16:38:23.133882506 -0800
+++ linux-2.6/mm/slub.c	2008-02-15 16:39:19.946123239 -0800
@@ -2791,6 +2791,20 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private))
+{
+	/*
+	 * Defragmentable slabs must have a ctor otherwise objects may be
+	 * in an undetermined state after they are allocated.
+	 */
+	BUG_ON(!s->ctor);
+	s->get = get;
+	s->kick = kick;
+}
+EXPORT_SYMBOL(kmem_cache_setup_defrag);
+
 static unsigned long count_partial(struct kmem_cache_node *n)
 {
 	unsigned long flags;
@@ -3092,7 +3106,7 @@ static int slab_unmergeable(struct kmem_
 	if ((s->flags & __PAGE_ALLOC_FALLBACK))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->kick || s->get)
 		return 1;
 
 	/*
@@ -3827,7 +3841,21 @@ static ssize_t ops_show(struct kmem_cach
 
 	if (s->ctor) {
 		x += sprintf(buf + x, "ctor : ");
-		x += sprint_symbol(buf + x, (unsigned long)s->ops->ctor);
+		x += sprint_symbol(buf + x, (unsigned long)s->ctor);
+		x += sprintf(buf + x, "\n");
+	}
+
+	if (s->get) {
+		x += sprintf(buf + x, "get : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->get);
+		x += sprintf(buf + x, "\n");
+	}
+
+	if (s->kick) {
+		x += sprintf(buf + x, "kick : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->kick);
 		x += sprintf(buf + x, "\n");
 	}
 	return x;
Index: linux-2.6/include/linux/slab_def.h
===================================================================
--- linux-2.6.orig/include/linux/slab_def.h	2008-02-15 16:34:53.392938232 -0800
+++ linux-2.6/include/linux/slab_def.h	2008-02-15 16:38:31.405917002 -0800
@@ -95,4 +95,8 @@ found:
 
 #endif	/* CONFIG_NUMA */
 
+static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
+
 #endif	/* _LINUX_SLAB_DEF_H */
Index: linux-2.6/include/linux/slob_def.h
===================================================================
--- linux-2.6.orig/include/linux/slob_def.h	2008-02-15 16:34:53.392938232 -0800
+++ linux-2.6/include/linux/slob_def.h	2008-02-15 16:38:31.405917002 -0800
@@ -33,4 +33,8 @@ static inline void *__kmalloc(size_t siz
 	return kmalloc(size, flags);
 }
 
+static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
+
 #endif /* __LINUX_SLOB_DEF_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
