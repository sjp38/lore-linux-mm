Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 900BB6B006C
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:37:38 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id b13so8459674qcw.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 13:37:38 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id 16si3561459qab.57.2015.01.23.13.37.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 13:37:37 -0800 (PST)
Message-Id: <20150123213735.590610697@linux.com>
Date: Fri, 23 Jan 2015 15:37:28 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 1/3] Slab infrastructure for array operations
References: <20150123213727.142554068@linux.com>
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
@@ -290,6 +291,39 @@ static __always_inline int kmalloc_index
 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
 
+/*
+ * Additional flags that may be specified in kmem_cache_alloc_array()'s
+ * gfp flags.
+ *
+ * If no flags are specified then kmem_cache_alloc_array() will first exhaust
+ * the partial slab page lists of the local node, then allocate new pages from
+ * the page allocator as long as more than objects per page objects are wanted
+ * and fill up the rest from local cached objects. If that is not enough then
+ * the remaining objects will be allocated via kmem_cache_alloc()
+ */
+
+/* Use objects cached for the processor */
+#define GFP_SLAB_ARRAY_LOCAL		((__force gfp_t)0x40000000)
+
+/* Use slabs from this node that have objects available */
+#define GFP_SLAB_ARRAY_PARTIAL		((__force gfp_t)0x20000000)
+
+/* Allocate new slab pages from page allocator */
+#define GFP_SLAB_ARRAY_NEW		((__force gfp_t)0x10000000)
+
+/*
+ * If other measures did not fill up the array to the full count
+ * requested then use kmem_cache_alloc to ensure the number of
+ * objects requested is allocated.
+ * If this flag is not set then the the allocation may return
+ * less than specified if there are no more objects of the
+ * particular type.
+ */
+#define GFP_SLAB_ARRAY_FULL_COUNT	((__force gfp_t)0x08000000)
+
+int kmem_cache_alloc_array(struct kmem_cache *, gfp_t gfpflags,
+				size_t nr, void **);
+
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c
+++ linux/mm/slab_common.c
@@ -105,6 +105,92 @@ static inline int kmem_cache_sanity_chec
 }
 #endif
 
+#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
+int kmem_cache_alloc_array(struct kmem_cache *s,
+		gfp_t flags, size_t nr, void **p)
+{
+	int i;
+
+	/*
+	 * Generic code does not support the processing of the
+	 * special allocation flags. So strip them off the mask.
+	 */
+	flags &= __GFP_BITS_MASK;
+
+	for (i = 0; i < nr; i++) {
+		void *x = kmem_cache_alloc(s, flags);
+
+		if (!x)
+			return i;
+		p[i] = x;
+	}
+	return nr;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
+void kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+#else
+
+int kmem_cache_alloc_array(struct kmem_cache *s,
+		gfp_t flags, size_t nr, void **p)
+{
+	int i = 0;
+
+	/*
+	 * Setup the default operation mode if no special GFP_SLAB_*
+	 * flags were specified.
+	 */
+	if ((flags & ~__GFP_BITS_MASK) == 0)
+		flags |= GFP_SLAB_ARRAY_PARTIAL |
+			 GFP_SLAB_ARRAY_NEW |
+			 GFP_SLAB_ARRAY_LOCAL |
+			 GFP_SLAB_ARRAY_FULL_COUNT;
+
+	/*
+	 * First extract objects from partial lists in order to
+	 * avoid further fragmentation.
+	 */
+	if (flags & GFP_SLAB_ARRAY_PARTIAL)
+		i += slab_array_alloc_from_partial(s, nr - i, p + i);
+
+	/*
+	 * If there are still a larger number of objects to be allocated
+	 * use the page allocator directly.
+	 */
+	if ((flags & GFP_SLAB_ARRAY_NEW) && nr - i > objects_per_slab_page(s))
+		i += slab_array_alloc_from_page_allocator(s,
+				flags & __GFP_BITS_MASK,
+				nr - i, p + i);
+
+	/* Get per cpu objects that may be available */
+	if (flags & GFP_SLAB_ARRAY_LOCAL)
+		i += slab_array_alloc_from_local(s, nr - i, p + i);
+
+	/*
+	 * If a fully filled array has been requested then fill it
+	 * up if there are objects missing using the regular kmem_cache_alloc()
+	 */
+	if (flags & GFP_SLAB_ARRAY_FULL_COUNT)
+		while (i < nr) {
+			void *x = kmem_cache_alloc(s,
+					flags & __GFP_BITS_MASK);
+			if (!x)
+				return i;
+			p[i++] = x;
+		}
+
+	return i;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+#endif
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		struct kmem_cache *s, struct kmem_cache *root_cache)
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h
+++ linux/mm/slab.h
@@ -69,6 +69,10 @@ extern struct kmem_cache *kmem_cache;
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
+/* Determine the number of objects per slab page */
+unsigned objects_per_slab_page(struct kmem_cache *);
+
+
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
 void create_kmalloc_caches(unsigned long);
@@ -362,4 +366,10 @@ void *slab_next(struct seq_file *m, void
 void slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
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
