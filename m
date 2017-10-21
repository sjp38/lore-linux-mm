Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 11A2E6B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 06:02:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o88so4092808wrb.18
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 03:02:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 45sor1109454wrk.76.2017.10.21.03.02.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Oct 2017 03:02:29 -0700 (PDT)
Date: Sat, 21 Oct 2017 13:02:25 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/2] slab, slub, slob: add slab_flags_t
Message-ID: <20171021100225.GA22428@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, ecryptfs@vger.kernel.org, linux-xfs@vger.kernel.org, kasan-dev@googlegroups.com, netdev@vger.kernel.org

Add sparse-checked slab_flags_t for struct kmem_cache::flags
(SLAB_POISON, etc).

SLAB is bloated temporarily by switching to "unsigned long",
but only temporarily.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 fs/ecryptfs/main.c       |    2 -
 fs/xfs/kmem.h            |    2 -
 include/linux/kasan.h    |    4 +--
 include/linux/kmemleak.h |    8 +++---
 include/linux/slab.h     |   60 ++++++++++++++++++++++++++++-------------------
 include/linux/slab_def.h |    2 -
 include/linux/slub_def.h |    2 -
 include/linux/types.h    |    1 
 include/net/sock.h       |    2 -
 mm/kasan/kasan.c         |    2 -
 mm/slab.c                |   23 ++++++++----------
 mm/slab.h                |   26 ++++++++++----------
 mm/slab_common.c         |   16 ++++++------
 mm/slob.c                |    2 -
 mm/slub.c                |   26 ++++++++++----------
 15 files changed, 97 insertions(+), 81 deletions(-)

--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -660,7 +660,7 @@ static struct ecryptfs_cache_info {
 	struct kmem_cache **cache;
 	const char *name;
 	size_t size;
-	unsigned long flags;
+	slab_flags_t flags;
 	void (*ctor)(void *obj);
 } ecryptfs_cache_infos[] = {
 	{
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -104,7 +104,7 @@ kmem_zone_init(int size, char *zone_name)
 }
 
 static inline kmem_zone_t *
-kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
+kmem_zone_init_flags(int size, char *zone_name, slab_flags_t flags,
 		     void (*construct)(void *))
 {
 	return kmem_cache_create(zone_name, size, 0, flags, construct);
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -45,7 +45,7 @@ void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
-			unsigned long *flags);
+			slab_flags_t *flags);
 void kasan_cache_shrink(struct kmem_cache *cache);
 void kasan_cache_shutdown(struct kmem_cache *cache);
 
@@ -94,7 +94,7 @@ static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
-				      unsigned long *flags) {}
+				      slab_flags_t *flags) {}
 static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
 static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -48,14 +48,14 @@ extern void kmemleak_not_leak_phys(phys_addr_t phys) __ref;
 extern void kmemleak_ignore_phys(phys_addr_t phys) __ref;
 
 static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
-					    int min_count, unsigned long flags,
+					    int min_count, slab_flags_t flags,
 					    gfp_t gfp)
 {
 	if (!(flags & SLAB_NOLEAKTRACE))
 		kmemleak_alloc(ptr, size, min_count, gfp);
 }
 
-static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
+static inline void kmemleak_free_recursive(const void *ptr, slab_flags_t flags)
 {
 	if (!(flags & SLAB_NOLEAKTRACE))
 		kmemleak_free(ptr);
@@ -76,7 +76,7 @@ static inline void kmemleak_alloc(const void *ptr, size_t size, int min_count,
 {
 }
 static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
-					    int min_count, unsigned long flags,
+					    int min_count, slab_flags_t flags,
 					    gfp_t gfp)
 {
 }
@@ -94,7 +94,7 @@ static inline void kmemleak_free(const void *ptr)
 static inline void kmemleak_free_part(const void *ptr, size_t size)
 {
 }
-static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
+static inline void kmemleak_free_recursive(const void *ptr, slab_flags_t flags)
 {
 }
 static inline void kmemleak_free_percpu(const void __percpu *ptr)
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -20,13 +20,20 @@
  * Flags to pass to kmem_cache_create().
  * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
-#define SLAB_CONSISTENCY_CHECKS	0x00000100UL	/* DEBUG: Perform (expensive) checks on alloc/free */
-#define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
-#define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
-#define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
-#define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
-#define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
+/* DEBUG: Perform (expensive) checks on alloc/free */
+#define SLAB_CONSISTENCY_CHECKS	((slab_flags_t __force)0x00000100UL)
+/* DEBUG: Red zone objs in a cache */
+#define SLAB_RED_ZONE		((slab_flags_t __force)0x00000400UL)
+/* DEBUG: Poison objects */
+#define SLAB_POISON		((slab_flags_t __force)0x00000800UL)
+/* Align objs on cache lines */
+#define SLAB_HWCACHE_ALIGN	((slab_flags_t __force)0x00002000UL)
+/* Use GFP_DMA memory */
+#define SLAB_CACHE_DMA		((slab_flags_t __force)0x00004000UL)
+/* DEBUG: Store the last owner for bug hunting */
+#define SLAB_STORE_USER		((slab_flags_t __force)0x00010000UL)
+/* Panic if kmem_cache_create() fails */
+#define SLAB_PANIC		((slab_flags_t __force)0x00040000UL)
 /*
  * SLAB_TYPESAFE_BY_RCU - **WARNING** READ THIS!
  *
@@ -64,44 +71,51 @@
  *
  * Note that SLAB_TYPESAFE_BY_RCU was originally named SLAB_DESTROY_BY_RCU.
  */
-#define SLAB_TYPESAFE_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
-#define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
-#define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
+/* Defer freeing slabs to RCU */
+#define SLAB_TYPESAFE_BY_RCU	((slab_flags_t __force)0x00080000UL)
+/* Spread some memory over cpuset */
+#define SLAB_MEM_SPREAD		((slab_flags_t __force)0x00100000UL)
+/* Trace allocations and frees */
+#define SLAB_TRACE		((slab_flags_t __force)0x00200000UL)
 
 /* Flag to prevent checks on free */
 #ifdef CONFIG_DEBUG_OBJECTS
-# define SLAB_DEBUG_OBJECTS	0x00400000UL
+# define SLAB_DEBUG_OBJECTS	((slab_flags_t __force)0x00400000UL)
 #else
-# define SLAB_DEBUG_OBJECTS	0x00000000UL
+# define SLAB_DEBUG_OBJECTS	((slab_flags_t __force)0x00000000UL)
 #endif
 
-#define SLAB_NOLEAKTRACE	0x00800000UL	/* Avoid kmemleak tracing */
+/* Avoid kmemleak tracing */
+#define SLAB_NOLEAKTRACE	((slab_flags_t __force)0x00800000UL)
 
 /* Don't track use of uninitialized memory */
 #ifdef CONFIG_KMEMCHECK
-# define SLAB_NOTRACK		0x01000000UL
+# define SLAB_NOTRACK		((slab_flags_t __force)0x01000000UL)
 #else
-# define SLAB_NOTRACK		0x00000000UL
+# define SLAB_NOTRACK		((slab_flags_t __force)0x00000000UL)
 #endif
+/* Fault injection mark */
 #ifdef CONFIG_FAILSLAB
-# define SLAB_FAILSLAB		0x02000000UL	/* Fault injection mark */
+# define SLAB_FAILSLAB		((slab_flags_t __force)0x02000000UL)
 #else
-# define SLAB_FAILSLAB		0x00000000UL
+# define SLAB_FAILSLAB		((slab_flags_t __force)0x00000000UL)
 #endif
+/* Account to memcg */
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
-# define SLAB_ACCOUNT		0x04000000UL	/* Account to memcg */
+# define SLAB_ACCOUNT		((slab_flags_t __force)0x04000000UL)
 #else
-# define SLAB_ACCOUNT		0x00000000UL
+# define SLAB_ACCOUNT		((slab_flags_t __force)0x00000000UL)
 #endif
 
 #ifdef CONFIG_KASAN
-#define SLAB_KASAN		0x08000000UL
+#define SLAB_KASAN		((slab_flags_t __force)0x08000000UL)
 #else
-#define SLAB_KASAN		0x00000000UL
+#define SLAB_KASAN		((slab_flags_t __force)0x00000000UL)
 #endif
 
 /* The following flags affect the page allocator grouping pages by mobility */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
+/* Objects are reclaimable */
+#define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000UL)
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
@@ -127,7 +141,7 @@ void __init kmem_cache_init(void);
 bool slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			unsigned long,
+			slab_flags_t,
 			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -19,7 +19,7 @@ struct kmem_cache {
 	struct reciprocal_value reciprocal_buffer_size;
 /* 2) touched by every alloc & free from the backend */
 
-	unsigned int flags;		/* constant flags */
+	slab_flags_t flags;		/* constant flags */
 	unsigned int num;		/* # of objs per slab */
 
 /* 3) cache_grow/shrink */
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -81,7 +81,7 @@ struct kmem_cache_order_objects {
 struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
 	/* Used for retriving partial slabs etc */
-	unsigned long flags;
+	slab_flags_t flags;
 	unsigned long min_partial;
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -155,6 +155,7 @@ typedef u32 dma_addr_t;
 #endif
 
 typedef unsigned __bitwise gfp_t;
+typedef unsigned long __bitwise slab_flags_t;
 typedef unsigned __bitwise fmode_t;
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1105,7 +1105,7 @@ struct proto {
 
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
-	int			slab_flags;
+	slab_flags_t		slab_flags;
 
 	struct percpu_counter	*orphan_count;
 
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -337,7 +337,7 @@ static size_t optimal_redzone(size_t object_size)
 }
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
-			unsigned long *flags)
+			slab_flags_t *flags)
 {
 	int redzone_adjust;
 	int orig_size = *size;
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -251,8 +251,8 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	MAKE_LIST((cachep), (&(ptr)->slabs_free), slabs_free, nodeid);	\
 	} while (0)
 
-#define CFLGS_OBJFREELIST_SLAB	(0x40000000UL)
-#define CFLGS_OFF_SLAB		(0x80000000UL)
+#define CFLGS_OBJFREELIST_SLAB	((slab_flags_t __force)0x40000000UL)
+#define CFLGS_OFF_SLAB		((slab_flags_t __force)0x80000000UL)
 #define	OBJFREELIST_SLAB(x)	((x)->flags & CFLGS_OBJFREELIST_SLAB)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
 
@@ -440,7 +440,7 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
  * Calculate the number of objects and left-over bytes for a given buffer size.
  */
 static unsigned int cache_estimate(unsigned long gfporder, size_t buffer_size,
-		unsigned long flags, size_t *left_over)
+		slab_flags_t flags, size_t *left_over)
 {
 	unsigned int num;
 	size_t slab_size = PAGE_SIZE << gfporder;
@@ -1760,7 +1760,7 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
  * towards high-order requests, this should be changed.
  */
 static size_t calculate_slab_order(struct kmem_cache *cachep,
-				size_t size, unsigned long flags)
+				size_t size, slab_flags_t flags)
 {
 	size_t left_over = 0;
 	int gfporder;
@@ -1887,8 +1887,8 @@ static int __ref setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return 0;
 }
 
-unsigned long kmem_cache_flags(unsigned long object_size,
-	unsigned long flags, const char *name,
+slab_flags_t kmem_cache_flags(unsigned long object_size,
+	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
 	return flags;
@@ -1896,7 +1896,7 @@ unsigned long kmem_cache_flags(unsigned long object_size,
 
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
-		   unsigned long flags, void (*ctor)(void *))
+		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *cachep;
 
@@ -1914,7 +1914,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 }
 
 static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
-			size_t size, unsigned long flags)
+			size_t size, slab_flags_t flags)
 {
 	size_t left;
 
@@ -1937,7 +1937,7 @@ static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
 }
 
 static bool set_off_slab_cache(struct kmem_cache *cachep,
-			size_t size, unsigned long flags)
+			size_t size, slab_flags_t flags)
 {
 	size_t left;
 
@@ -1971,7 +1971,7 @@ static bool set_off_slab_cache(struct kmem_cache *cachep,
 }
 
 static bool set_on_slab_cache(struct kmem_cache *cachep,
-			size_t size, unsigned long flags)
+			size_t size, slab_flags_t flags)
 {
 	size_t left;
 
@@ -2007,8 +2007,7 @@ static bool set_on_slab_cache(struct kmem_cache *cachep,
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-int
-__kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 {
 	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -20,7 +20,7 @@ struct kmem_cache {
 	unsigned int object_size;/* The original size of the object */
 	unsigned int size;	/* The aligned/padded/added on size  */
 	unsigned int align;	/* Alignment as calculated */
-	unsigned long flags;	/* Active flags on the slab */
+	slab_flags_t flags;	/* Active flags on the slab */
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
@@ -78,13 +78,13 @@ extern const struct kmalloc_info_struct {
 	unsigned long size;
 } kmalloc_info[];
 
-unsigned long calculate_alignment(unsigned long flags,
+unsigned long calculate_alignment(slab_flags_t flags,
 		unsigned long align, unsigned long size);
 
 #ifndef CONFIG_SLOB
 /* Kmalloc array related functions */
 void setup_kmalloc_cache_index_table(void);
-void create_kmalloc_caches(unsigned long);
+void create_kmalloc_caches(slab_flags_t);
 
 /* Find the kmalloc slab corresponding for a certain size */
 struct kmem_cache *kmalloc_slab(size_t, gfp_t);
@@ -92,32 +92,32 @@ struct kmem_cache *kmalloc_slab(size_t, gfp_t);
 
 
 /* Functions provided by the slab allocators */
-extern int __kmem_cache_create(struct kmem_cache *, unsigned long flags);
+int __kmem_cache_create(struct kmem_cache *, slab_flags_t flags);
 
 extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
-			unsigned long flags);
+			slab_flags_t flags);
 extern void create_boot_cache(struct kmem_cache *, const char *name,
-			size_t size, unsigned long flags);
+			size_t size, slab_flags_t flags);
 
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
-		unsigned long flags, const char *name, void (*ctor)(void *));
+		slab_flags_t flags, const char *name, void (*ctor)(void *));
 #ifndef CONFIG_SLOB
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
-		   unsigned long flags, void (*ctor)(void *));
+		   slab_flags_t flags, void (*ctor)(void *));
 
-unsigned long kmem_cache_flags(unsigned long object_size,
-	unsigned long flags, const char *name,
+slab_flags_t kmem_cache_flags(unsigned long object_size,
+	slab_flags_t flags, const char *name,
 	void (*ctor)(void *));
 #else
 static inline struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
-		   unsigned long flags, void (*ctor)(void *))
+		   slab_flags_t flags, void (*ctor)(void *))
 { return NULL; }
 
-static inline unsigned long kmem_cache_flags(unsigned long object_size,
-	unsigned long flags, const char *name,
+static inline slab_flags_t kmem_cache_flags(unsigned long object_size,
+	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
 	return flags;
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -290,7 +290,7 @@ int slab_unmergeable(struct kmem_cache *s)
 }
 
 struct kmem_cache *find_mergeable(size_t size, size_t align,
-		unsigned long flags, const char *name, void (*ctor)(void *))
+		slab_flags_t flags, const char *name, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
@@ -340,7 +340,7 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
  * Figure out what the alignment of the objects will be given a set of
  * flags, a user specified alignment and the size of the objects.
  */
-unsigned long calculate_alignment(unsigned long flags,
+unsigned long calculate_alignment(slab_flags_t flags,
 		unsigned long align, unsigned long size)
 {
 	/*
@@ -365,7 +365,7 @@ unsigned long calculate_alignment(unsigned long flags,
 
 static struct kmem_cache *create_cache(const char *name,
 		size_t object_size, size_t size, size_t align,
-		unsigned long flags, void (*ctor)(void *),
+		slab_flags_t flags, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s;
@@ -430,7 +430,7 @@ static struct kmem_cache *create_cache(const char *name,
  */
 struct kmem_cache *
 kmem_cache_create(const char *name, size_t size, size_t align,
-		  unsigned long flags, void (*ctor)(void *))
+		  slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
 	const char *cache_name;
@@ -878,7 +878,7 @@ bool slab_is_available(void)
 #ifndef CONFIG_SLOB
 /* Create a cache during boot when no slab services are available yet */
 void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
-		unsigned long flags)
+		slab_flags_t flags)
 {
 	int err;
 
@@ -898,7 +898,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 }
 
 struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t size,
-				unsigned long flags)
+				slab_flags_t flags)
 {
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
@@ -1056,7 +1056,7 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
 
-static void __init new_kmalloc_cache(int idx, unsigned long flags)
+static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
 {
 	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
 					kmalloc_info[idx].size, flags);
@@ -1067,7 +1067,7 @@ static void __init new_kmalloc_cache(int idx, unsigned long flags)
  * may already have been created because they were needed to
  * enable allocations for slab creation.
  */
-void __init create_kmalloc_caches(unsigned long flags)
+void __init create_kmalloc_caches(slab_flags_t flags)
 {
 	int i;
 
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -523,7 +523,7 @@ size_t ksize(const void *block)
 }
 EXPORT_SYMBOL(ksize);
 
-int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *c, slab_flags_t flags)
 {
 	if (flags & SLAB_TYPESAFE_BY_RCU) {
 		/* leave room for rcu footer at the end of object */
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -192,8 +192,10 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 #define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
 
 /* Internal SLUB flags */
-#define __OBJECT_POISON		0x80000000UL /* Poison object */
-#define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
+/* Poison object */
+#define __OBJECT_POISON		((slab_flags_t __force)0x80000000UL)
+/* Use cmpxchg_double */
+#define __CMPXCHG_DOUBLE	((slab_flags_t __force)0x40000000UL)
 
 /*
  * Tracking user of a slab.
@@ -484,9 +486,9 @@ static inline void *restore_red_left(struct kmem_cache *s, void *p)
  * Debug settings:
  */
 #if defined(CONFIG_SLUB_DEBUG_ON)
-static int slub_debug = DEBUG_DEFAULT_FLAGS;
+static slab_flags_t slub_debug = DEBUG_DEFAULT_FLAGS;
 #else
-static int slub_debug;
+static slab_flags_t slub_debug;
 #endif
 
 static char *slub_debug_slabs;
@@ -1288,8 +1290,8 @@ static int __init setup_slub_debug(char *str)
 
 __setup("slub_debug", setup_slub_debug);
 
-unsigned long kmem_cache_flags(unsigned long object_size,
-	unsigned long flags, const char *name,
+slab_flags_t kmem_cache_flags(unsigned long object_size,
+	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
 	/*
@@ -1321,8 +1323,8 @@ static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
 static inline void remove_full(struct kmem_cache *s, struct kmem_cache_node *n,
 					struct page *page) {}
-unsigned long kmem_cache_flags(unsigned long object_size,
-	unsigned long flags, const char *name,
+slab_flags_t kmem_cache_flags(unsigned long object_size,
+	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
 	return flags;
@@ -3476,7 +3478,7 @@ static void set_cpu_partial(struct kmem_cache *s)
  */
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
-	unsigned long flags = s->flags;
+	slab_flags_t flags = s->flags;
 	size_t size = s->object_size;
 	int order;
 
@@ -3592,7 +3594,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	return !!oo_objects(s->oo);
 }
 
-static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
+static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 {
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
 	s->reserved = 0;
@@ -4244,7 +4246,7 @@ void __init kmem_cache_init_late(void)
 
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
-		   unsigned long flags, void (*ctor)(void *))
+		   slab_flags_t flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s, *c;
 
@@ -4274,7 +4276,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 	return s;
 }
 
-int __kmem_cache_create(struct kmem_cache *s, unsigned long flags)
+int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
 {
 	int err;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
