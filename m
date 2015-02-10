Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 843966B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 14:48:15 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id i8so9003441qcq.5
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 11:48:15 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id y34si19476602qgy.28.2015.02.10.11.48.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 11:48:13 -0800 (PST)
Message-Id: <20150210194811.787556326@linux.com>
Date: Tue, 10 Feb 2015 13:48:05 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 1/3] Slab infrastructure for array operations
References: <20150210194804.288708936@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=array_alloc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

This patch adds the basic infrastructure for alloc / free operations
on pointer arrays. It includes a fallback function that can perform
the array operations using the single alloc and free that every
slab allocator performs.

Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
header files in order to implement their own fast version for
these array operations.

Array operations allow a reduction of the processing overhead
during allocation and therefore speed up acquisition of larger
amounts of objects.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -123,6 +123,7 @@ struct kmem_cache *memcg_create_kmem_cac
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
+void kmem_cache_free_array(struct kmem_cache *, size_t, void **);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -289,6 +290,8 @@ static __always_inline int kmalloc_index
 
 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
+int kmem_cache_alloc_array(struct kmem_cache *, gfp_t gfpflags,
+				size_t nr, void **);
 
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -105,6 +105,83 @@ static inline int kmem_cache_sanity_chec
 }
 #endif
 
+/*
+ * Fallback function that just calls kmem_cache_alloc
+ * for each element. This may be used if not all
+ * objects can be allocated or as a generic fallback
+ * if the allocator cannot support buik operations.
+ */
+int __kmem_cache_alloc_array(struct kmem_cache *s,
+		gfp_t flags, size_t nr, void **p)
+{
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		void *x = kmem_cache_alloc(s, flags);
+
+		if (!x)
+			return i;
+		p[i] = x;
+	}
+	return i;
+}
+
+int kmem_cache_alloc_array(struct kmem_cache *s,
+		gfp_t flags, size_t nr, void **p)
+{
+	int i = 0;
+
+#ifdef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
+	/*
+	 * First extract objects from partial lists in order to
+	 * avoid further fragmentation.
+	 */
+	i += slab_array_alloc_from_partial(s, nr - i, p + i);
+
+	/*
+	 * If there are still a larger number of objects to be allocated
+	 * use the page allocator directly.
+	 */
+	if (nr - i > objects_per_slab_page(s))
+		i += slab_array_alloc_from_page_allocator(s,
+				flags, nr - i, p + i);
+
+	/* Get per cpu objects that may be available */
+	if (i < nr)
+		i += slab_array_alloc_from_local(s, nr - i, p + i);
+
+#endif
+	/*
+	 * If a fully filled array has been requested then fill it
+	 * up if there are objects missing using the regular kmem_cache_alloc()
+	 */
+	if (i < nr)
+		i += __kmem_cache_alloc_array(s, flags, nr - i, p + i);
+
+	return i;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
+/*
+ * Fallback function for objects that an allocator does not want
+ * to deal with or for allocators that do not support bulk operations.
+ */
+void __kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+
+#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
+void kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
+{
+	__kmem_cache_free_array(s, nr, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+#endif
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		struct kmem_cache *s, struct kmem_cache *root_cache)
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h
+++ linux/mm/slab.h
@@ -69,6 +69,9 @@ extern struct kmem_cache *kmem_cache;
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
+/* Determine the number of objects per slab page */
+unsigned objects_per_slab_page(struct kmem_cache *);
+
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
 void create_kmalloc_caches(unsigned long);
@@ -362,4 +365,12 @@ void *slab_next(struct seq_file *m, void
 void slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+void __kmem_cache_free_array(struct kmem_cache *s, int nr, void **p);
+void __kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, int nr, void **p);
+
+int slab_array_alloc_from_partial(struct kmem_cache *s, size_t nr, void **p);
+int slab_array_alloc_from_local(struct kmem_cache *s, size_t nr, void **p);
+int slab_array_alloc_from_page_allocator(struct kmem_cache *s, gfp_t flags,
+					size_t nr, void **p);
+
 #endif /* MM_SLAB_H */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -332,6 +332,11 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+unsigned objects_per_slab_page(struct kmem_cache *s)
+{
+	return oo_objects(s->oo);
+}
+
 /*
  * Per slab locking using the pagelock
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
