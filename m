Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 6C4B66B0031
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 15:55:15 -0400 (EDT)
Message-ID: <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
Date: Fri, 14 Jun 2013 19:55:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.11 1/4] slub: Make cpu partial slab support configurable V2
References: <20130614195500.373711648@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

cpu partial support can introduce level of indeterminism that is not wanted
in certain context (like a realtime kernel). Make it configurable.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-06-14 09:50:58.190453865 -0500
+++ linux/include/linux/slub_def.h	2013-06-14 09:50:58.186453794 -0500
@@ -73,7 +73,9 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+#endif
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
@@ -104,6 +106,15 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
+static inline int kmem_cache_cpu_partial(struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+	return s->cpu_partial;
+#else
+	return 0;
+#endif
+}
+
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-06-14 09:50:58.190453865 -0500
+++ linux/mm/slub.c	2013-06-14 09:50:58.186453794 -0500
@@ -1573,7 +1573,8 @@ static void *get_partial_node(struct kme
 			put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
-		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
+		if (kmem_cache_debug(s) ||
+			       available > kmem_cache_cpu_partial(s) / 2)
 			break;
 
 	}
@@ -1884,6 +1885,7 @@ redo:
 static void unfreeze_partials(struct kmem_cache *s,
 		struct kmem_cache_cpu *c)
 {
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
 	struct page *page, *discard_page = NULL;
 
@@ -1938,6 +1940,7 @@ static void unfreeze_partials(struct kme
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
 	}
+#endif
 }
 
 /*
@@ -1951,6 +1954,7 @@ static void unfreeze_partials(struct kme
  */
 static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 {
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	struct page *oldpage;
 	int pages;
 	int pobjects;
@@ -1987,6 +1991,7 @@ static void put_cpu_partial(struct kmem_
 		page->next = oldpage;
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
+#endif
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -2495,6 +2500,7 @@ static void __slab_free(struct kmem_cach
 		new.inuse--;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 			if (!kmem_cache_debug(s) && !prior)
 
 				/*
@@ -2503,7 +2509,9 @@ static void __slab_free(struct kmem_cach
 				 */
 				new.frozen = 1;
 
-			else { /* Needs to be taken off a list */
+			else
+#endif
+		       		{ /* Needs to be taken off a list */
 
 	                        n = get_node(s, page_to_nid(page));
 				/*
@@ -2525,6 +2533,7 @@ static void __slab_free(struct kmem_cach
 		"__slab_free"));
 
 	if (likely(!n)) {
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 
 		/*
 		 * If we just froze the page then put it onto the
@@ -2534,6 +2543,7 @@ static void __slab_free(struct kmem_cach
 			put_cpu_partial(s, page, 1);
 			stat(s, CPU_PARTIAL_FREE);
 		}
+#endif
 		/*
 		 * The list lock was not taken therefore no list
 		 * activity can be necessary.
@@ -3041,7 +3051,7 @@ static int kmem_cache_open(struct kmem_c
 	 * list to avoid pounding the page allocator excessively.
 	 */
 	set_min_partial(s, ilog2(s->size) / 2);
-
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	/*
 	 * cpu_partial determined the maximum number of objects kept in the
 	 * per cpu partial lists of a processor.
@@ -3069,6 +3079,7 @@ static int kmem_cache_open(struct kmem_c
 		s->cpu_partial = 13;
 	else
 		s->cpu_partial = 30;
+#endif
 
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
@@ -4424,7 +4435,7 @@ SLAB_ATTR(order);
 
 static ssize_t min_partial_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%lu\n", s->min_partial);
+	return sprintf(buf, "%u\n", kmem_cache_cpu_partial(s));
 }
 
 static ssize_t min_partial_store(struct kmem_cache *s, const char *buf,
@@ -4444,7 +4455,7 @@ SLAB_ATTR(min_partial);
 
 static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->cpu_partial);
+	return sprintf(buf, "%u\n", kmem_cache_cpu_partial(s));
 }
 
 static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
@@ -4458,10 +4469,13 @@ static ssize_t cpu_partial_store(struct
 		return err;
 	if (objects && kmem_cache_debug(s))
 		return -EINVAL;
-
+#ifdef CONFIG_SLUB_CPU_PARTIAL
 	s->cpu_partial = objects;
 	flush_all(s);
 	return length;
+#else
+	return -ENOSYS;
+#endif
 }
 SLAB_ATTR(cpu_partial);
 
Index: linux/init/Kconfig
===================================================================
--- linux.orig/init/Kconfig	2013-06-14 09:50:58.190453865 -0500
+++ linux/init/Kconfig	2013-06-14 09:50:58.186453794 -0500
@@ -1559,6 +1559,17 @@ config SLOB
 
 endchoice
 
+config SLUB_CPU_PARTIAL
+	default y
+	depends on SLUB
+	bool "SLUB per cpu partial cache"
+	help
+	  Per cpu partial caches accellerate objects allocation and freeing
+	  that is local to a processor at the price of more indeterminism
+	  in the latency of the free. On overflow these caches will be cleared
+	  which requires the taking of locks that may cause latency spikes.
+	  Typically one would choose no for a realtime system.
+
 config MMAP_ALLOW_UNINITIALIZED
 	bool "Allow mmapped anonymous memory to be uninitialized"
 	depends on EXPERT && !MMU

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
