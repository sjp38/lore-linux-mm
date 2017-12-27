Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A63B6B0069
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 17:09:29 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id a4so15713370uae.14
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:09:29 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id h32si2809318uae.350.2017.12.27.14.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 14:09:28 -0800 (PST)
Message-Id: <20171227220652.402842142@linux.com>
Date: Wed, 27 Dec 2017 16:06:39 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 3/8] slub: Add isolate() and migrate() methods
References: <20171227220636.361857279@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=isolate_and_migrate_methods
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

Add the two methods needed for moving objects and enable the
display of the callbacks via the /sys/kernel/slab interface.

Add documentation explaining the use of these methods and the prototypes
for slab.h. Add functions to setup the callbacks method for a slab cache.

Add empty functions for SLAB/SLOB. The API is generic so it
could be theoretically implemented for these allocators as well.

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
@@ -98,6 +98,9 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	kmem_isolate_func *isolate;
+	kmem_migrate_func *migrate;
+
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3479,7 +3479,6 @@ static int calculate_sizes(struct kmem_c
 	else
 		s->flags &= ~__OBJECT_POISON;
 
-
 	/*
 	 * If we are Redzoning then check if there is some space between the
 	 * end of the object and the free pointer. If not then add an
@@ -4275,6 +4274,25 @@ int __kmem_cache_create(struct kmem_cach
 	return err;
 }
 
+void kmem_cache_setup_mobility(struct kmem_cache *s,
+	kmem_isolate_func isolate, kmem_migrate_func migrate)
+{
+	/*
+	 * Defragmentable slabs must have a ctor otherwise objects may be
+	 * in an undetermined state after they are allocated.
+	 */
+	BUG_ON(!s->ctor);
+	s->isolate = isolate;
+	s->migrate = migrate;
+	/*
+	 * Sadly serialization requirements currently mean that we have
+	 * to disable fast cmpxchg based processing.
+	 */
+	s->flags &= ~__CMPXCHG_DOUBLE;
+
+}
+EXPORT_SYMBOL(kmem_cache_setup_mobility);
+
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
@@ -4969,6 +4987,20 @@ static ssize_t ops_show(struct kmem_cach
 
 	if (s->ctor)
 		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
+
+	if (s->isolate) {
+		x += sprintf(buf + x, "isolate : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->isolate);
+		x += sprintf(buf + x, "\n");
+	}
+
+	if (s->migrate) {
+		x += sprintf(buf + x, "migrate : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->migrate);
+		x += sprintf(buf + x, "\n");
+	}
 	return x;
 }
 SLAB_ATTR_RO(ops);
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -146,6 +146,68 @@ void memcg_deactivate_kmem_caches(struct
 void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
 /*
+ * Function prototypes passed to kmem_cache_setup_mobility() to enable mobile
+ * objects and targeted reclaim in slab caches.
+ */
+
+/*
+ * kmem_cache_isolate_func() is called with locks held so that the slab
+ * objects cannot be freed. We are in an atomic context and no slab
+ * operations may be performed. The purpose of kmem_cache_isolate_func()
+ * is to pin the object so that it cannot be freed until
+ * kmem_cache_migrate_func() has processed them. This may be accomplished
+ * by increasing the refcount or setting a flag.
+ *
+ * Parameters passed are the number of objects to process and an array of
+ * pointers to objects which are intended to be moved.
+ *
+ * Returns a pointer that is passed to the migrate function. If any objects
+ * cannot be touched at this point then the pointer may indicate a
+ * failure and then the migration function can simply remove the references
+ * that were already obtained. The private data could be used to track
+ * the objects that were already pinned.
+ *
+ * The object pointer array passed is also passed to kmem_cache_migrate().
+ * The function may remove objects from the array by setting pointers to
+ * NULL. This is useful if we can determine that an object is being freed
+ * because kmem_cache_isolate_func() was called when the subsystem
+ * was calling kmem_cache_free().
+ * In that case it is not necessary to increase the refcount or
+ * specially mark the object because the release of the slab lock
+ * will lead to the immediate freeing of the object.
+ */
+typedef void *kmem_isolate_func(struct kmem_cache *, void **, int);
+
+/*
+ * kmem_cache_move_migrate_func is called with no locks held and interrupts
+ * enabled. Sleeping is possible. Any operation may be performed in
+ * migrate(). kmem_cache_migrate_func should allocate new objects and
+ * free all the objects.
+ **
+ * Parameters passed are the number of objects in the array, the array of
+ * pointers to the objects, the NUMA node where the object should be
+ * allocated and the pointer returned by kmem_cache_isolate_func().
+ *
+ * Success is checked by examining the number of remaining objects in
+ * the slab. If the number is zero then the objects will be freed.
+ */
+typedef void kmem_migrate_func(struct kmem_cache *, void **, int nr, int node, void *private);
+
+/*
+ * kmem_cache_setup_mobility() is used to setup callbacks for a slab cache.
+ */
+#ifdef CONFIG_SLUB
+void kmem_cache_setup_mobility(struct kmem_cache *, kmem_isolate_func,
+						kmem_migrate_func);
+#else
+static inline void kmem_cache_setup_mobility(struct kmem_cache *s,
+	kmem_isolate_func isolate, kmem_migrate_func migrate) {}
+#endif
+
+/*
+ * Allocator specific definitions. These are mainly used to establish optimized
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
  *
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -278,7 +278,7 @@ int slab_unmergeable(struct kmem_cache *
 	if (!is_root_cache(s))
 		return 1;
 
-	if (s->ctor)
+	if (s->ctor || s->isolate || s->migrate)
 		return 1;
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
