Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id CC9AF6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:31:22 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so72516387qcb.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:31:22 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id m97si10516295qgm.37.2015.03.30.07.31.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 07:31:21 -0700 (PDT)
Date: Mon, 30 Mar 2015 09:31:19 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Slab infrastructure for bulk object allocation and freeing V2
Message-ID: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com

After all of the earlier discussions I thought it would be better to
first get agreement on the basic way to allow implementation of the
bulk alloc in the common slab code. So this is a revision of the initial
proposal and it just covers the first patch.



This patch adds the basic infrastructure for alloc / free operations
on pointer arrays. It includes a generic function in the common
slab code that is used in this infrastructure patch to
create the unoptimized functionality for slab bulk operations.

Allocators can then provide optimized allocation functions
for situations in which large numbers of objects are needed.
These optimization may avoid taking locks repeatedly and
bypass metadata creation if all objects in slab pages
can be used to provide the objects required.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2015-03-30 08:48:12.923927793 -0500
+++ linux/include/linux/slab.h	2015-03-30 08:48:12.923927793 -0500
@@ -289,6 +289,8 @@ static __always_inline int kmalloc_index
 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
 void kmem_cache_free(struct kmem_cache *, void *);
+void kmem_cache_free_array(struct kmem_cache *, size_t, void **);
+int kmem_cache_alloc_array(struct kmem_cache *, gfp_t, size_t, void **);

 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2015-03-30 08:48:12.923927793 -0500
+++ linux/mm/slab_common.c	2015-03-30 08:57:41.737572817 -0500
@@ -105,6 +105,29 @@ static inline int kmem_cache_sanity_chec
 }
 #endif

+int __kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t nr,
+								void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (!x)
+			return i;
+	}
+	return nr;
+}
+
+void __kmem_cache_free_array(struct kmem_cache *s, size_t nr, void **p)
+{
+	size_t i;
+
+	for (i = 0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+
+#endif
+
 #ifdef CONFIG_MEMCG_KMEM
 void slab_init_memcg_params(struct kmem_cache *s)
 {
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2015-03-30 08:48:12.923927793 -0500
+++ linux/mm/slab.h	2015-03-30 08:48:12.923927793 -0500
@@ -162,6 +162,10 @@ void slabinfo_show_stats(struct seq_file
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos);

+/* Generic implementations of array operations */
+void __kmem_cache_free_array(struct kmem_cache *, size_t, void **);
+int __kmem_cache_alloc_array(struct kmem_cache *, gfp_t, size_t, void **);
+
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2015-03-30 08:48:12.923927793 -0500
+++ linux/mm/slab.c	2015-03-30 08:49:08.398137844 -0500
@@ -3401,6 +3401,17 @@ void *kmem_cache_alloc(struct kmem_cache
 }
 EXPORT_SYMBOL(kmem_cache_alloc);

+void kmem_cache_free_array(struct kmem_cache *s, size_t size, void **p) {
+	__kmem_cache_free_array(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+
+int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p) {
+	return kmem_cache_alloc_array(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
 #ifdef CONFIG_TRACING
 void *
 kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2015-03-30 08:48:12.923927793 -0500
+++ linux/mm/slub.c	2015-03-30 08:48:12.923927793 -0500
@@ -2752,6 +2752,18 @@ void kmem_cache_free(struct kmem_cache *
 }
 EXPORT_SYMBOL(kmem_cache_free);

+void kmem_cache_free_array(struct kmem_cache *s, size_t size, void **p) {
+	__kmem_cache_free_array(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+
+int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p) {
+	return kmem_cache_alloc_array(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
+
 /*
  * Object placement in a slab is made very easy because we always start at
  * offset 0. If we tune the size of the object to the alignment then we can
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2015-03-30 08:48:12.923927793 -0500
+++ linux/mm/slob.c	2015-03-30 08:50:16.995924460 -0500
@@ -612,6 +612,17 @@ void kmem_cache_free(struct kmem_cache *
 }
 EXPORT_SYMBOL(kmem_cache_free);

+void kmem_cache_free_array(struct kmem_cache *s, size_t size, void **p) {
+	__kmem_cache_free_array(s, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+
+int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t size,
+								void **p) {
+	return kmem_cache_alloc_array(s, flags, size, p);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
 int __kmem_cache_shutdown(struct kmem_cache *c)
 {
 	/* No way to check for remaining objects */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
