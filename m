Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 4CAF96B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:29:44 -0400 (EDT)
Message-Id: <0000013a04454f8b-658325fb-88d6-42a2-a7ab-81f82493edb4-000000@email.amazonses.com>
Date: Wed, 26 Sep 2012 20:29:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK1 [13/13] Common function to create the kmalloc array
References: <20120926200005.911809821@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The kmalloc array is created in similar ways in both SLAB
and SLUB. Create a common function and have both allocators
call that function.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-20 08:58:38.621735414 -0500
+++ linux/mm/slab.c	2012-09-20 08:58:38.673736492 -0500
@@ -1623,30 +1623,6 @@ void __init kmem_cache_init(void)
 
 	slab_early_init = 0;
 
-	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
-		size_t cs_size = kmalloc_size(i);
-
-		if (cs_size < KMALLOC_MIN_SIZE)
-			continue;
-
-		if (!kmalloc_caches[i]) {
-			/*
-			 * For performance, all the general caches are L1 aligned.
-			 * This should be particularly beneficial on SMP boxes, as it
-			 * eliminates "false sharing".
-			 * Note for systems short on memory removing the alignment will
-			 * allow tighter packing of the smaller caches.
-			 */
-			kmalloc_caches[i] = create_kmalloc_cache("kmalloc",
-					cs_size, ARCH_KMALLOC_FLAGS);
-		}
-
-#ifdef CONFIG_ZONE_DMA
-		kmalloc_dma_caches[i] = create_kmalloc_cache(
-			"kmalloc-dma", cs_size,
-			SLAB_CACHE_DMA|ARCH_KMALLOC_FLAGS);
-#endif
-	}
 	/* 4) Replace the bootstrap head arrays */
 	{
 		struct array_cache *ptr;
@@ -1692,29 +1668,7 @@ void __init kmem_cache_init(void)
 		}
 	}
 
-	slab_state = UP;
-
-	/* Create the proper names */
-	for (i = 1; i < PAGE_SHIFT + MAX_ORDER; i++) {
-		char *s;
-		struct kmem_cache *c = kmalloc_caches[i];
-
-		if (!c)
-			continue;
-
-		s = kasprintf(GFP_NOWAIT, "kmalloc-%d", kmalloc_size(i));
-
-		BUG_ON(!s);
-		c->name = s;
-		
-#ifdef CONFIG_ZONE_DMA
-		c = kmalloc_dma_caches[i];
-		BUG_ON(!c);
-		s = kasprintf(GFP_NOWAIT, "dma-kmalloc-%d", kmalloc_size(i));
-		BUG_ON(!s);
-		c->name = s;
-#endif
-	}
+	create_kmalloc_caches(ARCH_KMALLOC_FLAGS);
 }
 
 void __init kmem_cache_init_late(void)
Index: linux/mm/slab.h
===================================================================
--- linux.orig/mm/slab.h	2012-09-20 08:58:38.565734246 -0500
+++ linux/mm/slab.h	2012-09-20 08:58:38.673736492 -0500
@@ -35,6 +35,12 @@ extern struct kmem_cache *kmem_cache;
 unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size);
 
+#ifndef CONFIG_SLOB
+/* Kmalloc array related functions */
+void create_kmalloc_caches(gfp_t);
+#endif
+
+
 /* Functions provided by the slab allocators */
 extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
 
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-20 08:58:38.657736160 -0500
+++ linux/mm/slab_common.c	2012-09-20 08:59:38.554983198 -0500
@@ -260,4 +260,58 @@ struct kmem_cache *kmalloc_dma_caches[KM
 EXPORT_SYMBOL(kmalloc_dma_caches);
 #endif
 
+/*
+ * Create the kmalloc array. Some of the regular kmalloc arrays
+ * may already have been created because they were needed to
+ * enable allocations for slab creation.
+ */
+void __init create_kmalloc_caches(gfp_t flags)
+{
+	int i;
+
+	/* Caches that are not of the two-to-the-power-of size */
+	if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1])
+		kmalloc_caches[1] = create_kmalloc_cache(NULL, 96, flags);
+
+	if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2])
+		kmalloc_caches[2] = create_kmalloc_cache(NULL, 192, flags);
+
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
+		if (!kmalloc_caches[i])
+			kmalloc_caches[i] = create_kmalloc_cache(NULL,
+				       			1 << i, flags);
+
+	/* Kmalloc array is now usable */
+	slab_state = UP;
+
+	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
+		struct kmem_cache *s = kmalloc_caches[i];
+		char *n;
+
+		if (s) {
+			n = kasprintf(GFP_NOWAIT, "kmalloc-%d", kmalloc_size(i));
+
+			BUG_ON(!n);
+			s->name = n;
+		}
+	}
+
+#ifdef CONFIG_ZONE_DMA
+	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
+		struct kmem_cache *s = kmalloc_caches[i];
+
+		if (s) {
+			int size = kmalloc_size(i);
+			char *n = kasprintf(GFP_NOWAIT,
+				 "dma-kmalloc-%d", size);
+
+			BUG_ON(!n);
+			kmalloc_dma_caches[i] = create_kmalloc_cache(n,
+				size, SLAB_CACHE_DMA | flags);
+		}
+	}
+#endif
+}
+
+
 #endif /* !CONFIG_SLOB */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-20 08:58:38.661736249 -0500
+++ linux/mm/slub.c	2012-09-20 08:58:38.673736492 -0500
@@ -3628,7 +3628,6 @@ static __initdata struct kmem_cache boot
 void __init kmem_cache_init(void)
 {
 	int i;
-	int caches = 2;
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
@@ -3703,64 +3702,16 @@ void __init kmem_cache_init(void)
 			size_index[size_index_elem(i)] = 8;
 	}
 
-	/* Caches that are not of the two-to-the-power-of size */
-	if (KMALLOC_MIN_SIZE <= 32) {
-		kmalloc_caches[1] = create_kmalloc_cache("kmalloc-96", 96, 0);
-		caches++;
-	}
-
-	if (KMALLOC_MIN_SIZE <= 64) {
-		kmalloc_caches[2] = create_kmalloc_cache("kmalloc-192", 192, 0);
-		caches++;
-	}
-
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
-		kmalloc_caches[i] = create_kmalloc_cache("kmalloc", 1 << i, 0);
-		caches++;
-	}
-
-	slab_state = UP;
-
-	/* Provide the correct kmalloc names now that the caches are up */
-	if (KMALLOC_MIN_SIZE <= 32) {
-		kmalloc_caches[1]->name = kstrdup(kmalloc_caches[1]->name, GFP_NOWAIT);
-		BUG_ON(!kmalloc_caches[1]->name);
-	}
-
-	if (KMALLOC_MIN_SIZE <= 64) {
-		kmalloc_caches[2]->name = kstrdup(kmalloc_caches[2]->name, GFP_NOWAIT);
-		BUG_ON(!kmalloc_caches[2]->name);
-	}
-
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
-		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
-
-		BUG_ON(!s);
-		kmalloc_caches[i]->name = s;
-	}
+	create_kmalloc_caches(0);
 
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
 
-#ifdef CONFIG_ZONE_DMA
-	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
-		struct kmem_cache *s = kmalloc_caches[i];
-
-		if (s && s->size) {
-			char *name = kasprintf(GFP_NOWAIT,
-				 "dma-kmalloc-%d", s->object_size);
-
-			BUG_ON(!name);
-			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
-				s->object_size, SLAB_CACHE_DMA);
-		}
-	}
-#endif
 	printk(KERN_INFO
-		"SLUB: Genslabs=%d, HWalign=%d, Order=%d-%d, MinObjects=%d,"
+		"SLUB: HWalign=%d, Order=%d-%d, MinObjects=%d,"
 		" CPUs=%d, Nodes=%d\n",
-		caches, cache_line_size(),
+		cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
