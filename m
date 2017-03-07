Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6196B038E
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:24:47 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id e12so16921186ioj.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:24:47 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e186si1688424ioa.102.2017.03.07.13.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:24:46 -0800 (PST)
Message-Id: <20170307212438.068748554@linux.com>
Date: Tue, 07 Mar 2017 15:24:32 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 3/6] slub: Add get() and kick() methods
References: <20170307212429.044249411@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=get_and_kick
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

V15->V16
 - Disable CMPXCHG_DOUBLE mode if these methods are specified.
   Maybe we can find another safer way later that can use the
   cmpxchg double fast mode.

Add the two methods needed for defragmentation and add the display of the
methods via the proc interface.

Add documentation explaining the use of these methods and the prototypes
for slab.h. Add functions to setup the defrag methods for a slab cache.

Add empty functions for SLAB/SLOB. The API is generic so it
could be theoretically implemented for either allocator.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h     |   50 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/slub_def.h |    3 ++
 mm/slub.c                |   29 ++++++++++++++++++++++++++-
 3 files changed, 81 insertions(+), 1 deletion(-)

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h
+++ linux/include/linux/slub_def.h
@@ -76,6 +76,9 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	kmem_defrag_get_func *get;
+	kmem_defrag_kick_func *kick;
+
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3439,6 +3439,8 @@ static int calculate_sizes(struct kmem_c
 	else
 		s->flags &= ~__OBJECT_POISON;
 
+	if (s->ctor || s->kick || s->get)
+		return 1;
 
 	/*
 	 * If we are Redzoning then check if there is some space between the
@@ -4258,6 +4260,25 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	kmem_defrag_get_func get, kmem_defrag_kick_func kick)
+{
+	/*
+	 * Defragmentable slabs must have a ctor otherwise objects may be
+	 * in an undetermined state after they are allocated.
+	 */
+	BUG_ON(!s->ctor);
+	s->get = get;
+	s->kick = kick;
+	/*
+	 * Sadly serialization requirements currently mean that we have
+	 * to disable fast cmpxchg based processing.
+	 */
+	s->flags &= ~__CMPXCHG_DOUBLE;
+
+}
+EXPORT_SYMBOL(kmem_cache_setup_defrag);
+
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
@@ -4952,6 +4973,20 @@ static ssize_t ops_show(struct kmem_cach
 
 	if (s->ctor)
 		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
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
+		x += sprintf(buf + x, "\n");
+	}
 	return x;
 }
 SLAB_ATTR_RO(ops);
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -135,6 +135,59 @@ void memcg_deactivate_kmem_caches(struct
 void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
+ * Function prototypes passed to kmem_cache_defrag() to enable defragmentation
+ * and targeted reclaim in slab caches.
+ */
+
+/*
+ * kmem_cache_defrag_get_func() is called with locks held so that the slab
+ * objects cannot be freed. We are in an atomic context and no slab
+ * operations may be performed. The purpose of kmem_cache_defrag_get_func()
+ * is to obtain a stable refcount on the objects, so that they cannot be
+ * removed until kmem_cache_kick_func() has handled them.
+ *
+ * Parameters passed are the number of objects to process and an array of
+ * pointers to objects for which we need references.
+ *
+ * Returns a pointer that is passed to the kick function. If any objects
+ * cannot be moved then the pointer may indicate a failure and
+ * then kick can simply remove the references that were already obtained.
+ *
+ * The object pointer array passed is also passed to kmem_cache_defrag_kick().
+ * The function may remove objects from the array by setting pointers to
+ * NULL. This is useful if we can determine that an object is already about
+ * to be removed. In that case it is often impossible to obtain the necessary
+ * refcount.
+ */
+typedef void *kmem_defrag_get_func(struct kmem_cache *, int, void **);
+
+/*
+ * kmem_cache_defrag_kick_func is called with no locks held and interrupts
+ * enabled. Sleeping is possible. Any operation may be performed in kick().
+ * kmem_cache_defrag should free all the objects in the pointer array.
+ *
+ * Parameters passed are the number of objects in the array, the array of
+ * pointers to the objects and the pointer returned by kmem_cache_defrag_get().
+ *
+ * Success is checked by examining the number of remaining objects in the slab.
+ */
+typedef void kmem_defrag_kick_func(struct kmem_cache *, int, void **, void *);
+
+/*
+ * kmem_cache_setup_defrag() is used to setup callbacks for a slab cache.
+ */
+#ifdef CONFIG_SLUB
+void kmem_cache_setup_defrag(struct kmem_cache *, kmem_defrag_get_func,
+						kmem_defrag_kick_func);
+#else
+static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
+	kmem_defrag_get_func get, kmem_defrag_kick_func kiok) {}
+#endif
+
+/*
+ * Allocator specific definitions. These are mainly used to establish optimized
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
