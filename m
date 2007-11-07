From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 10/23] SLUB: Sort slab cache list and establish maximum objects for defrag slabs
Date: Tue, 06 Nov 2007 17:11:40 -0800
Message-ID: <20071107011228.858031377@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756575AbXKGBPz@vger.kernel.org>
Content-Disposition: inline; filename=0007-slab_defrag_determine_maximum_objects.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

When defragmenting slabs then it is advantageous to have all
defragmentable slabs together at the beginning of the list so that we do not
have to scan the complete list. When adding a slab cache put defragmentable
caches first and others last.

Determine the maximum number of objects in defragmentable slabs. This allows
to size the allocation of arrays holding refs to these objects later.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-11-06 12:37:51.000000000 -0800
+++ linux-2.6/mm/slub.c	2007-11-06 12:37:54.000000000 -0800
@@ -198,6 +198,9 @@ static enum {
 static DECLARE_RWSEM(slub_lock);
 static LIST_HEAD(slab_caches);
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects = 0;
+
 /*
  * Tracking user of a slab.
  */
@@ -2546,7 +2549,7 @@ static struct kmem_cache *create_kmalloc
 			flags, NULL))
 		goto panic;
 
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	up_write(&slub_lock);
 	if (sysfs_slab_add(s))
 		goto panic;
@@ -2760,6 +2763,13 @@ void kfree(const void *x)
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
@@ -2771,6 +2781,11 @@ void kmem_cache_setup_defrag(struct kmem
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
 
@@ -3159,7 +3174,7 @@ struct kmem_cache *kmem_cache_create(con
 	if (s) {
 		if (kmem_cache_open(s, GFP_KERNEL, name,
 				size, align, flags, ctor)) {
-			list_add(&s->list, &slab_caches);
+			list_add_tail(&s->list, &slab_caches);
 			up_write(&slub_lock);
 			if (sysfs_slab_add(s))
 				goto err;

-- 
