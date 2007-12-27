Message-Id: <20071227203401.027269044@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:32:58 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [05/17] SLUB: Sort slab cache list and establish maximum objects for defrag slabs
Content-Disposition: inline; filename=0051-SLUB-Sort-slab-cache-list-and-establish-maximum-obj.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

When defragmenting slabs then it is advantageous to have all
defragmentable slabs together at the beginning of the list so that there is
no need to scan the complete list. Put defragmentable caches first when adding
a slab cache and others last.

Determine the maximum number of objects in defragmentable slabs. This allows
to size the allocation of arrays holding refs to these objects later.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/slub.c	2007-12-27 12:02:10.737665935 -0800
+++ linux-2.6.24-rc6-mm1/mm/slub.c	2007-12-27 12:02:15.261686032 -0800
@@ -198,6 +198,9 @@ static enum {
 static DECLARE_RWSEM(slub_lock);
 static LIST_HEAD(slab_caches);
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects = 0;
+
 /*
  * Tracking user of a slab.
  */
@@ -2554,7 +2557,7 @@ static struct kmem_cache *create_kmalloc
 			flags, NULL))
 		goto panic;
 
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	up_write(&slub_lock);
 	if (sysfs_slab_add(s))
 		goto panic;
@@ -2772,6 +2775,13 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static inline void *alloc_scratch(void)
+{
+	return kmalloc(max_defrag_slab_objects * sizeof(void *) +
+	    BITS_TO_LONGS(max_defrag_slab_objects) * sizeof(unsigned long),
+								GFP_KERNEL);
+}
+
 void kmem_cache_setup_defrag(struct kmem_cache *s,
 	void *(*get)(struct kmem_cache *, int nr, void **),
 	void (*kick)(struct kmem_cache *, int nr, void **, void *private))
@@ -2783,6 +2793,11 @@ void kmem_cache_setup_defrag(struct kmem
 	BUG_ON(!s->ctor);
 	s->get = get;
 	s->kick = kick;
+	down_write(&slub_lock);
+	list_move(&s->list, &slab_caches);
+	if (s->objects > max_defrag_slab_objects)
+		max_defrag_slab_objects = s->objects;
+	up_write(&slub_lock);
 }
 EXPORT_SYMBOL(kmem_cache_setup_defrag);
 
@@ -3174,7 +3189,7 @@ struct kmem_cache *kmem_cache_create(con
 	if (s) {
 		if (kmem_cache_open(s, GFP_KERNEL, name,
 				size, align, flags, ctor)) {
-			list_add(&s->list, &slab_caches);
+			list_add_tail(&s->list, &slab_caches);
 			up_write(&slub_lock);
 			if (sysfs_slab_add(s))
 				goto err;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
