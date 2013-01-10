Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id D3E556B0078
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 14:14:25 -0500 (EST)
Message-Id: <0000013c25e26045-81050f3b-2a41-4bcb-b9bf-667a604de29c-000000@email.amazonses.com>
Date: Thu, 10 Jan 2013 19:14:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: REN2 [13/13] Common definition for kmem_cache_node
References: <20130110190027.780479755@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Put the definitions for the kmem_cache_node structures together so that
we have one structure. That will allow us to create more common fields in
the future which could yield more opportunities to share code.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2013-01-10 09:43:58.241722939 -0600
+++ linux/mm/slab.c	2013-01-10 09:44:03.489803682 -0600
@@ -286,23 +286,6 @@ struct arraycache_init {
 };
 
 /*
- * The slab lists for all objects.
- */
-struct kmem_cache_node {
-	struct list_head slabs_partial;	/* partial list first, better asm code */
-	struct list_head slabs_full;
-	struct list_head slabs_free;
-	unsigned long free_objects;
-	unsigned int free_limit;
-	unsigned int colour_next;	/* Per-node cache coloring */
-	spinlock_t list_lock;
-	struct array_cache *shared;	/* shared per node */
-	struct array_cache **alien;	/* on other nodes */
-	unsigned long next_reap;	/* updated without locking */
-	int free_touched;		/* updated without locking */
-};
-
-/*
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (3 * MAX_NUMNODES)
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2013-01-10 09:43:58.241722939 -0600
+++ linux/mm/slab.h	2013-01-10 09:44:03.489803682 -0600
@@ -239,3 +239,36 @@ static inline struct kmem_cache *cache_f
 	return s;
 }
 #endif
+
+
+/*
+ * The slab lists for all objects.
+ */
+struct kmem_cache_node {
+	spinlock_t list_lock;
+
+#ifdef CONFIG_SLAB
+	struct list_head slabs_partial;	/* partial list first, better asm code */
+	struct list_head slabs_full;
+	struct list_head slabs_free;
+	unsigned long free_objects;
+	unsigned int free_limit;
+	unsigned int colour_next;	/* Per-node cache coloring */
+	struct array_cache *shared;	/* shared per node */
+	struct array_cache **alien;	/* on other nodes */
+	unsigned long next_reap;	/* updated without locking */
+	int free_touched;		/* updated without locking */
+#endif
+
+#ifdef CONFIG_SLUB
+	unsigned long nr_partial;
+	struct list_head partial;
+#ifdef CONFIG_SLUB_DEBUG
+	atomic_long_t nr_slabs;
+	atomic_long_t total_objects;
+	struct list_head full;
+#endif
+#endif
+
+};
+
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-01-10 09:43:54.625667508 -0600
+++ linux/include/linux/slub_def.h	2013-01-10 09:44:03.489803682 -0600
@@ -53,17 +53,6 @@ struct kmem_cache_cpu {
 #endif
 };
 
-struct kmem_cache_node {
-	spinlock_t list_lock;	/* Protect partial list and nr_partial */
-	unsigned long nr_partial;
-	struct list_head partial;
-#ifdef CONFIG_SLUB_DEBUG
-	atomic_long_t nr_slabs;
-	atomic_long_t total_objects;
-	struct list_head full;
-#endif
-};
-
 /*
  * Word size structure that can be atomically updated or read and that
  * contains both the order and the number of objects that a slab of the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
