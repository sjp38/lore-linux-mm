Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 576D06B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 15:07:29 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so32650513ied.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:07:29 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id z1si4408327igl.29.2015.04.06.12.07.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 06 Apr 2015 12:07:28 -0700 (PDT)
Date: Mon, 6 Apr 2015 14:07:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Slab infrastructure for bulk object allocation and freeing V3
Message-ID: <alpine.DEB.2.11.1504061405250.28605@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com


V2->V3
 - Rename functions so that they end in _bulk() instead of _array()
 - The bulk allocation function will either return a completely
   filled out array or nothing.
 - Add some documentation

This patch adds the basic infrastructure for alloc / free operations
on pointer arrays. It includes a generic function in the common
slab code that is used in this infrastructure patch to
create the unoptimized functionality for slab bulk operations.

Allocators can then provide optimized allocation functions
for situations in which large numbers of objects are needed.
These optimization may avoid taking locks repeatedly and
bypass metadata creation if all objects in slab pages
can be used to provide the objects required.

Allocators can extend the skeletons provided and add their own
code to the bulk alloc and free functions. They can keep the
generic allocation and freeing and just fall back to those if
optimizations would not work (like for example when debugging
is on).

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2015-04-06 13:45:56.114446424 -0500
+++ linux/include/linux/slab.h	2015-04-06 13:45:56.110446544 -0500
@@ -290,6 +290,16 @@ void *__kmalloc(size_t size, gfp_t flags
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
 void kmem_cache_free(struct kmem_cache *, void *);

+/*
+ * Bulk allocation and freeing operations. These are accellerated in an
+ * allocator specific way to avoid taking locks repeatedly or building
+ * metadata structures unnecessarily.
+ *
+ * Note that interrupts must be enabled when calling these functions.
+ */
+void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+bool kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2015-04-06 13:45:56.114446424 -0500
+++ linux/mm/slab_common.c	2015-04-06 13:53:59.835796346 -0500
@@ -105,6 +105,29 @@ static inline int kmem_cache_sanity_chec
 }
 #endif

+void __kmem_cache_free_bulk(struct kmem_cache *s, size_t nr, void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+
+bool __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
+								void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (!x) {
+			__kmem_cache_free_bulk(s, i, p);
+			return false;
+		}
+	}
+	return true;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 void slab_init_memcg_params(struct kmem_cache *s)
 {
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2015-04-06 13:45:56.114446424 -0500
+++ linux/mm/slab.h	2015-04-06 13:45:56.114446424 -0500
@@ -162,6 +162,15 @@ void slabinfo_show_stats(struct seq_file
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);

+/*
+ * Generic implementation of bulk operations
+ * These are useful for situations in which the allocator cannot
+ * perform optimizations. In that case segments of the objecct listed
+ * may be allocated or freed using these operations.
+ */
+void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
+bool __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2015-04-06 13:45:56.114446424 -0500
+++ linux/mm/slab.c	2015-04-06 13:45:56.114446424 -0500
@@ -3401,6 +3401,19 @@ void *kmem_cache_alloc(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_alloc);

+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
 #ifdef CONFIG_TRACING
 void *
 kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2015-04-06 13:45:56.114446424 -0500
+++ linux/mm/slub.c	2015-04-06 13:45:56.114446424 -0500
@@ -2752,6 +2752,20 @@ void kmem_cache_free(struct kmem_cache *
 }
 EXPORT_SYMBOL(kmem_cache_free);

+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
+
 /*
  * Object placement in a slab is made very easy because we always start at
  * offset 0. If we tune the size of the object to the alignment then we can
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2015-04-06 13:45:56.114446424 -0500
+++ linux/mm/slob.c	2015-04-06 13:45:56.114446424 -0500
@@ -612,6 +612,19 @@ void kmem_cache_free(struct kmem_cache *
 }
 EXPORT_SYMBOL(kmem_cache_free);

+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	__kmem_cache_free_bulk(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
+bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p)
+{
+	return kmem_cache_alloc_bulk(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_bulk);
+
 int __kmem_cache_shutdown(struct kmem_cache *c)
 {
 	/* No way to check for remaining objects */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
