Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 044886B0253
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:09:30 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id b42so13868501uah.20
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:09:29 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id 61si1881038uas.96.2017.12.27.14.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:09:29 -0800 (PST)
Message-Id: <20171227220652.487092808@linux.com>
Date: Wed, 27 Dec 2017 16:06:40 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 4/8] slub: Sort slab cache list and establish maximum objects for defrag slabs
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=sort_and_max
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

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
@@ -197,6 +197,9 @@ static inline bool kmem_cache_has_cpu_pa
 /* Use cmpxchg_double */
 #define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000U)
 
+/* Maximum objects in defragmentable slabs */
+static unsigned int max_defrag_slab_objects;
+
 /*
  * Tracking user of a slab.
  */
@@ -4274,22 +4278,45 @@ int __kmem_cache_create(struct kmem_cach
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
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 	kmem_isolate_func isolate, kmem_migrate_func migrate)
 {
+	int max_objects = oo_objects(s->max);
+
 	/*
 	 * Defragmentable slabs must have a ctor otherwise objects may be
 	 * in an undetermined state after they are allocated.
 	 */
 	BUG_ON(!s->ctor);
+
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
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
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -392,7 +392,7 @@ static struct kmem_cache *create_cache(c
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
