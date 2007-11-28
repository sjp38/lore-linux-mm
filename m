Message-Id: <20071128223155.837924672@sgi.com>
References: <20071128223101.864822396@sgi.com>
Date: Wed, 28 Nov 2007 14:31:05 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/17] SLUB: Add get() and kick() methods
Content-Disposition: inline; filename=0050-SLUB-Add-get-and-kick-methods.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
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

Index: linux-2.6.24-rc2-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.24-rc2-mm1.orig/include/linux/slub_def.h	2007-11-14 12:06:05.330593714 -0800
+++ linux-2.6.24-rc2-mm1/include/linux/slub_def.h	2007-11-14 12:42:38.534492973 -0800
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
Index: linux-2.6.24-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/slub.c	2007-11-14 12:06:18.770343797 -0800
+++ linux-2.6.24-rc2-mm1/mm/slub.c	2007-11-14 12:40:58.510493314 -0800
@@ -2760,6 +2760,20 @@ void kfree(const void *x)
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
@@ -3061,7 +3075,7 @@ static int slab_unmergeable(struct kmem_
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->kick || s->get)
 		return 1;
 
 	/*
@@ -3799,7 +3813,21 @@ static ssize_t ops_show(struct kmem_cach
 
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
Index: linux-2.6.24-rc2-mm1/include/linux/slab_def.h
===================================================================
--- linux-2.6.24-rc2-mm1.orig/include/linux/slab_def.h	2007-11-14 12:42:42.794242754 -0800
+++ linux-2.6.24-rc2-mm1/include/linux/slab_def.h	2007-11-14 12:43:09.914742360 -0800
@@ -98,4 +98,8 @@ found:
 extern const struct seq_operations slabinfo_op;
 ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
 
+static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private)) {}
+
 #endif	/* _LINUX_SLAB_DEF_H */
Index: linux-2.6.24-rc2-mm1/include/linux/slob_def.h
===================================================================
--- linux-2.6.24-rc2-mm1.orig/include/linux/slob_def.h	2007-11-14 12:43:13.442493053 -0800
+++ linux-2.6.24-rc2-mm1/include/linux/slob_def.h	2007-11-14 12:43:27.914179349 -0800
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
