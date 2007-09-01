From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 06/26] SLUB: Add get() and kick() methods
Date: Fri, 31 Aug 2007 18:41:13 -0700
Message-ID: <20070901014220.690110465@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0006-slab_defrag_get_and_kick_method.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Add the two methods needed for defragmentation and add the display of the
methods via the proc interface.

Add documentation explaining the use of these methods.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h     |    3 +++
 include/linux/slub_def.h |   32 ++++++++++++++++++++++++++++++++
 mm/slub.c                |   32 ++++++++++++++++++++++++++++++--
 3 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index d859354..848e9a7 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -54,6 +54,9 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *, struct kmem_cache *, unsigned long));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 291881d..69c32a7 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -50,6 +50,38 @@ struct kmem_cache {
 	int objects;		/* Number of objects in slab */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+
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
diff --git a/mm/slub.c b/mm/slub.c
index fc2f1e3..4a64038 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2597,6 +2597,20 @@ void kfree(const void *x)
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
@@ -2777,7 +2791,7 @@ static int slab_unmergeable(struct kmem_cache *s)
 	if (slub_nomerge || (s->flags & SLUB_NEVER_MERGE))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->kick || s->get)
 		return 1;
 
 	/*
@@ -3507,7 +3521,21 @@ static ssize_t ops_show(struct kmem_cache *s, char *buf)
 
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
1.5.2.4

-- 
