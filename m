Date: Tue, 21 Nov 2006 12:43:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Remove uses of kmem_cache_t from mm/* and include/linux/slab.h
Message-ID: <Pine.LNX.4.64.0611211242080.30941@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Remove all uses of kmem_cache_t (the most were left in slab.h). The
typedef for kmem_cache_t is then only necessary for other kernel subsystems.
Add a comment to that effect.

Patch must be applied on top of the patchset to remove the global slab cache
declarations from slab.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:37:04.675467797 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:40:02.479987422 -0600
@@ -9,6 +9,7 @@
 
 #if	defined(__KERNEL__)
 
+/* kmem_cache_t exists for legacy reasons and is not used by code in mm */
 typedef struct kmem_cache kmem_cache_t;
 
 #include	<linux/gfp.h>
@@ -57,23 +58,24 @@ typedef struct kmem_cache kmem_cache_t;
 /* prototypes */
 extern void __init kmem_cache_init(void);
 
-extern kmem_cache_t *kmem_cache_create(const char *, size_t, size_t, unsigned long,
-				       void (*)(void *, kmem_cache_t *, unsigned long),
-				       void (*)(void *, kmem_cache_t *, unsigned long));
-extern void kmem_cache_destroy(kmem_cache_t *);
-extern int kmem_cache_shrink(kmem_cache_t *);
-extern void *kmem_cache_alloc(kmem_cache_t *, gfp_t);
+extern struct kmem_cache *kmem_cache_create(const char *,
+		size_t, size_t, unsigned long,
+		void (*)(void *, struct kmem_cache *, unsigned long),
+		void (*)(void *, struct kmem_cache *, unsigned long));
+extern void kmem_cache_destroy(struct kmem_cache *);
+extern int kmem_cache_shrink(struct kmem_cache *);
+extern void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 extern void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
-extern void kmem_cache_free(kmem_cache_t *, void *);
-extern unsigned int kmem_cache_size(kmem_cache_t *);
-extern const char *kmem_cache_name(kmem_cache_t *);
+extern void kmem_cache_free(struct kmem_cache *, void *);
+extern unsigned int kmem_cache_size(struct kmem_cache *);
+extern const char *kmem_cache_name(struct kmem_cache *);
 
 /* Size description struct for general caches. */
 struct cache_sizes {
 	size_t		 cs_size;
-	kmem_cache_t	*cs_cachep;
+	struct kmem_cache *cs_cachep;
 #ifdef CONFIG_ZONE_DMA
-	kmem_cache_t	*cs_dmacachep;
+	struct kmem_cache *cs_dmacachep;
 #else
 #define cs_dmacachep cs_cachep
 #endif
@@ -215,7 +217,7 @@ extern unsigned int ksize(const void *);
 extern int slab_is_available(void);
 
 #ifdef CONFIG_NUMA
-extern void *kmem_cache_alloc_node(kmem_cache_t *, gfp_t flags, int node);
+extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 
 static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
@@ -241,7 +243,8 @@ found:
 	return __kmalloc_node(size, flags, node);
 }
 #else
-static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int node)
+static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
+						 gfp_t flags, int node)
 {
 	return kmem_cache_alloc(cachep, flags);
 }
@@ -252,10 +255,11 @@ static inline void *kmalloc_node(size_t 
 #endif
 
 extern int FASTCALL(kmem_cache_reap(int));
-extern int FASTCALL(kmem_ptr_validate(kmem_cache_t *cachep, void *ptr));
+extern int FASTCALL(kmem_ptr_validate(struct kmem_cache *cachep, void *ptr));
 
 struct shrinker;
-extern void kmem_set_shrinker(kmem_cache_t *cachep, struct shrinker *shrinker);
+extern void kmem_set_shrinker(struct kmem_cache *cachep,
+					struct shrinker *shrinker);
 
 #else /* CONFIG_SLOB */
 
@@ -291,7 +295,7 @@ static inline void *kcalloc(size_t n, si
 #define kmalloc_track_caller kmalloc
 
 struct shrinker;
-static inline void kmem_set_shrinker(kmem_cache_t *cachep,
+static inline void kmem_set_shrinker(struct kmem_cache *cachep,
 				     struct shrinker *shrinker) {}
 
 #endif /* CONFIG_SLOB */
Index: linux-2.6.19-rc5-mm2/mm/slab.c
===================================================================
--- linux-2.6.19-rc5-mm2.orig/mm/slab.c	2006-11-21 14:22:06.282972108 -0600
+++ linux-2.6.19-rc5-mm2/mm/slab.c	2006-11-21 14:37:06.200991064 -0600
@@ -4393,7 +4393,7 @@ unsigned int ksize(const void *objp)
 	return obj_size(virt_to_cache(objp));
 }
 
-void kmem_set_shrinker(kmem_cache_t *cachep, struct shrinker *shrinker)
+void kmem_set_shrinker(struct kmem_cache *cachep, struct shrinker *shrinker)
 {
 	cachep->shrinker = shrinker;
 }
Index: linux-2.6.19-rc5-mm2/mm/swap_prefetch.c
===================================================================
--- linux-2.6.19-rc5-mm2.orig/mm/swap_prefetch.c	2006-11-21 14:22:06.294691877 -0600
+++ linux-2.6.19-rc5-mm2/mm/swap_prefetch.c	2006-11-21 14:37:06.296702511 -0600
@@ -39,7 +39,7 @@ struct swapped_root {
 	struct radix_tree_root	swap_tree;	/* Lookup tree of pages */
 	unsigned int		count;		/* Number of entries */
 	unsigned int		maxcount;	/* Maximum entries allowed */
-	kmem_cache_t		*cache;		/* Of struct swapped_entry */
+	struct kmem_cache	*cache;		/* Of struct swapped_entry */
 };
 
 static struct swapped_root swapped = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
