Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2C4B6B0390
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:24:48 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n76so16915596ioe.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:24:48 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id p62si1681136itp.13.2017.03.07.13.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:24:48 -0800 (PST)
Message-Id: <20170307212438.172407219@linux.com>
Date: Tue, 07 Mar 2017 15:24:33 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 4/6] slub: Sort slab cache list and establish maximum objects for defrag slabs
References: <20170307212429.044249411@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=sort_and_max
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Determine the maximum number of objects in defragmentable slabs. This allows
the sizing of the array holding refs to objects in a slab later.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -194,6 +194,9 @@ static inline bool kmem_cache_has_cpu_pa
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects;
+
 /*
  * Tracking user of a slab.
  */
@@ -2715,6 +2718,7 @@ redo:
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->object_size);
 
+	list_add_tail(&s->list, &slab_caches);
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
 
 	return object;
@@ -4260,22 +4264,44 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+/*
+ * Allocate a slab scratch space that is sufficient to keep at least
+ * max_defrag_slab_objects pointers to individual objects and also a bitmap
+ * for max_defrag_slab_objects.
+ */
+static inline void *alloc_scratch(void)
+{
+	return kmalloc(max_defrag_slab_objects * sizeof(void *) +
+		BITS_TO_LONGS(max_defrag_slab_objects) * sizeof(unsigned long),
+		GFP_KERNEL);
+}
+
 void kmem_cache_setup_defrag(struct kmem_cache *s,
 	kmem_defrag_get_func get, kmem_defrag_kick_func kick)
 {
+	int max_objects = oo_objects(s->max);
+
 	/*
 	 * Defragmentable slabs must have a ctor otherwise objects may be
 	 * in an undetermined state after they are allocated.
 	 */
 	BUG_ON(!s->ctor);
+	mutex_lock(&slab_mutex);
+
 	s->get = get;
 	s->kick = kick;
+
 	/*
 	 * Sadly serialization requirements currently mean that we have
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
 
+	list_move(&s->list, &slab_caches);	/* Move to top */
+	if (max_objects > max_defrag_slab_objects)
+		max_defrag_slab_objects = max_objects;
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_defrag);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -384,7 +384,7 @@ static struct kmem_cache *create_cache(c
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
