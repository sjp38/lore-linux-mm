Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 439906B0074
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:33:27 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id rl12so1427194iec.16
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 08:33:27 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id l76si5421201ioi.15.2014.12.18.08.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 08:33:25 -0800 (PST)
Date: Thu, 18 Dec 2014 10:33:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH] Slab infrastructure for array operations
Message-ID: <alpine.DEB.2.11.1412181031520.2962@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>

This patch adds the basic infrastructure for alloc / free operations
on pointer arrays. It includes a fallback function.

Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
header files in order to implement their own fast version for
these array operations.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2014-12-16 09:27:26.369447763 -0600
+++ linux/include/linux/slab.h	2014-12-18 10:30:33.394927526 -0600
@@ -123,6 +123,7 @@ struct kmem_cache *memcg_create_kmem_cac
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
+void kmem_cache_free_array(struct kmem_cache *, int, void **);

 /*
  * Please use this macro to create slab caches. Simply specify the
@@ -289,6 +290,7 @@ static __always_inline int kmalloc_index

 void *__kmalloc(size_t size, gfp_t flags);
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
+int kmem_cache_alloc_array(struct kmem_cache *, gfp_t, int, void **);

 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2014-12-12 10:27:49.360799479 -0600
+++ linux/mm/slab_common.c	2014-12-18 10:25:41.695889129 -0600
@@ -105,6 +105,31 @@ static inline int kmem_cache_sanity_chec
 }
 #endif

+#ifndef _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS
+int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, int nr, void **p)
+{
+	int i;
+
+	for (i=0; i < nr; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (!x)
+			return i;
+	}
+	return nr;
+}
+EXPORT_SYMBOL(kmem_cache_alloc_array);
+
+void kmem_cache_free_array(struct kmem_cache *s, int nr, void **p)
+{
+	int i;
+
+	for (i=0; i < nr; i++)
+		kmem_cache_free(s, p[i]);
+}
+EXPORT_SYMBOL(kmem_cache_free_array);
+
+#endif
+
 #ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		struct kmem_cache *s, struct kmem_cache *root_cache)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
