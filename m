From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 09/23] SLUB: Add get() and kick() methods
Date: Tue, 06 Nov 2007 17:11:39 -0800
Message-ID: <20071107011228.605750914@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756886AbXKGBPl@vger.kernel.org>
Content-Disposition: inline; filename=0006-slab_defrag_get_and_kick_method.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Add the two methods needed for defragmentation and add the display of the
methods via the proc interface.

Add documentation explaining the use of these methods.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h     |    3 +++
 include/linux/slub_def.h |   31 +++++++++++++++++++++++++++++++
 mm/slub.c                |   32 ++++++++++++++++++++++++++++++--
 3 files changed, 64 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-10-17 13:35:53.000000000 -0700
+++ linux-2.6/include/linux/slab.h	2007-11-06 12:37:51.000000000 -0800
@@ -56,6 +56,9 @@ struct kmem_cache *kmem_cache_create(con
 			void (*)(struct kmem_cache *, void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2007-11-06 12:37:44.000000000 -0800
+++ linux-2.6/include/linux/slub_def.h	2007-11-06 12:37:51.000000000 -0800
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
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-11-06 12:37:47.000000000 -0800
+++ linux-2.6/mm/slub.c	2007-11-06 12:37:51.000000000 -0800
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
@@ -3058,7 +3072,7 @@ static int slab_unmergeable(struct kmem_
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->kick || s->get)
 		return 1;
 
 	/*
@@ -3795,7 +3809,21 @@ static ssize_t ops_show(struct kmem_cach
 
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

-- 
