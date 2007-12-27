Message-Id: <20071227203400.521395633@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:32:57 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [04/17] SLUB: Add get() and kick() methods
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

Index: linux-2.6.24-rc6-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/slub_def.h	2007-12-27 12:02:04.057636233 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/slub_def.h	2007-12-27 12:02:10.733665829 -0800
@@ -51,6 +51,37 @@ struct kmem_cache {
 	int objects;		/* Number of objects in slab */
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
@@ -211,4 +242,8 @@ static __always_inline void *kmalloc_nod
 }
 #endif
 
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
+
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux-2.6.24-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/slub.c	2007-12-27 12:02:07.405650961 -0800
+++ linux-2.6.24-rc6-mm1/mm/slub.c	2007-12-27 12:02:10.737665935 -0800
@@ -2772,6 +2772,20 @@ void kfree(const void *x)
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
@@ -3073,7 +3087,7 @@ static int slab_unmergeable(struct kmem_
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->kick || s->get)
 		return 1;
 
 	/*
@@ -3811,7 +3825,21 @@ static ssize_t ops_show(struct kmem_cach
 
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
Index: linux-2.6.24-rc6-mm1/include/linux/slab_def.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/slab_def.h	2007-12-20 17:25:48.000000000 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/slab_def.h	2007-12-27 12:02:10.745665612 -0800
@@ -98,4 +98,8 @@ found:
 extern const struct seq_operations slabinfo_op;
 ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
 
+static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
+
 #endif	/* _LINUX_SLAB_DEF_H */
Index: linux-2.6.24-rc6-mm1/include/linux/slob_def.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/slob_def.h	2007-12-20 17:25:48.000000000 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/slob_def.h	2007-12-27 12:02:10.745665612 -0800
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
