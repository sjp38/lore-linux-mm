Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1419E6B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 10:27:52 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id nq2so569092lbc.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:27:52 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id 76si4605765wmp.74.2016.06.17.07.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 07:27:50 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id v199so555057wmv.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:27:50 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v4] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
Date: Fri, 17 Jun 2016 16:27:44 +0200
Message-Id: <1466173664-118413-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

For KASAN builds:
 - switch SLUB allocator to using stackdepot instead of storing the
   allocation/deallocation stacks in the objects;
 - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
   effectively disabling these debug features, as they're redundant in
   the presence of KASAN;
 - change the freelist hook so that parts of the freelist can be put into
   the quarantine.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v4: - addressed comments by Andrey Ryabinin:
      - don't set slub_debug by default for everyone;
      - introduce the ___cache_free() helper function.
v3: - addressed comments by Andrey Ryabinin:
      - replaced KMALLOC_MAX_CACHE_SIZE with KMALLOC_MAX_SIZE in
        kasan_cache_create();
      - for caches with SLAB_KASAN flag set, their alloc_meta_offset and
        free_meta_offset are always valid.
v2: - incorporated kbuild fixes by Andrew Morton
---
 include/linux/slab.h     |  9 +++++++
 include/linux/slub_def.h |  4 ++++
 lib/Kconfig.kasan        |  4 ++--
 mm/kasan/Makefile        |  3 +--
 mm/kasan/kasan.c         | 61 +++++++++++++++++++++++++----------------------
 mm/kasan/kasan.h         |  2 +-
 mm/kasan/report.c        |  8 +++----
 mm/slab.h                |  7 ++++++
 mm/slub.c                | 62 +++++++++++++++++++++++++++++++++++++-----------
 9 files changed, 108 insertions(+), 52 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index aeb3e6d..fe91eef 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -21,11 +21,20 @@
  * The ones marked DEBUG are only valid if CONFIG_DEBUG_SLAB is set.
  */
 #define SLAB_CONSISTENCY_CHECKS	0x00000100UL	/* DEBUG: Perform (expensive) checks on alloc/free */
+#ifndef CONFIG_KASAN
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
+#else
+#define SLAB_RED_ZONE		0x00000000UL	/* KASAN has its own redzones */
+#define SLAB_POISON		0x00000000UL	/* No extra poisoning */
+#endif
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
+#ifndef CONFIG_KASAN
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
+#else
+#define SLAB_STORE_USER		0x00000000UL	/* KASAN uses stack depot */
+#endif
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 /*
  * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d1faa01..5585598 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -99,6 +99,10 @@ struct kmem_cache {
 	 */
 	int remote_node_defrag_ratio;
 #endif
+#ifdef CONFIG_KASAN
+	struct kasan_cache kasan_info;
+#endif
+
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 67d8c68..bd38aab 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,9 +5,9 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "KASan: runtime memory debugger"
-	depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
+	depends on SLUB || (SLAB && !DEBUG_SLAB)
 	select CONSTRUCTORS
-	select STACKDEPOT if SLAB
+	select STACKDEPOT
 	help
 	  Enables kernel address sanitizer - runtime memory debugger,
 	  designed to find out-of-bounds accesses and use-after-free bugs.
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 1548749..2976a9e 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -7,5 +7,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := kasan.o report.o kasan_init.o
-obj-$(CONFIG_SLAB) += quarantine.o
+obj-y := kasan.o report.o kasan_init.o quarantine.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 18b6a2b..1d385e3 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -351,7 +351,6 @@ void kasan_free_pages(struct page *page, unsigned int order)
 				KASAN_FREE_PAGE);
 }
 
-#ifdef CONFIG_SLAB
 /*
  * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
  * For larger allocations larger redzones are used.
@@ -373,16 +372,12 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags)
 {
 	int redzone_adjust;
-	/* Make sure the adjusted size is still less than
-	 * KMALLOC_MAX_CACHE_SIZE.
-	 * TODO: this check is only useful for SLAB, but not SLUB. We'll need
-	 * to skip it for SLUB when it starts using kasan_cache_create().
-	 */
-	if (*size > KMALLOC_MAX_CACHE_SIZE -
-	    sizeof(struct kasan_alloc_meta) -
-	    sizeof(struct kasan_free_meta))
-		return;
+
+#ifdef CONFIG_SLAB
+	int orig_size = *size;
+#endif
 	*flags |= SLAB_KASAN;
+
 	/* Add alloc meta. */
 	cache->kasan_info.alloc_meta_offset = *size;
 	*size += sizeof(struct kasan_alloc_meta);
@@ -392,17 +387,35 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	    cache->object_size < sizeof(struct kasan_free_meta)) {
 		cache->kasan_info.free_meta_offset = *size;
 		*size += sizeof(struct kasan_free_meta);
+	} else {
+		cache->kasan_info.free_meta_offset = 0;
 	}
 	redzone_adjust = optimal_redzone(cache->object_size) -
 		(*size - cache->object_size);
+
 	if (redzone_adjust > 0)
 		*size += redzone_adjust;
-	*size = min(KMALLOC_MAX_CACHE_SIZE,
+
+#ifdef CONFIG_SLAB
+	*size = min(KMALLOC_MAX_SIZE,
 		    max(*size,
 			cache->object_size +
 			optimal_redzone(cache->object_size)));
-}
+	/*
+	 * If the metadata doesn't fit, disable KASAN at all.
+	 */
+	if (*size <= cache->kasan_info.alloc_meta_offset ||
+			*size <= cache->kasan_info.free_meta_offset) {
+		*flags &= ~SLAB_KASAN;
+		*size = orig_size;
+	}
+#else
+	*size = max(*size,
+			cache->object_size +
+			optimal_redzone(cache->object_size));
+
 #endif
+}
 
 void kasan_cache_shrink(struct kmem_cache *cache)
 {
@@ -431,16 +444,13 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object,
 			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
 			KASAN_KMALLOC_REDZONE);
-#ifdef CONFIG_SLAB
 	if (cache->flags & SLAB_KASAN) {
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
 		alloc_info->state = KASAN_STATE_INIT;
 	}
-#endif
 }
 
-#ifdef CONFIG_SLAB
 static inline int in_irqentry_text(unsigned long ptr)
 {
 	return (ptr >= (unsigned long)&__irqentry_text_start &&
@@ -501,7 +511,6 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
-#endif
 
 void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
@@ -522,16 +531,16 @@ void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 
 bool kasan_slab_free(struct kmem_cache *cache, void *object)
 {
-#ifdef CONFIG_SLAB
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
 		return false;
 
 	if (likely(cache->flags & SLAB_KASAN)) {
-		struct kasan_alloc_meta *alloc_info =
-			get_alloc_info(cache, object);
-		struct kasan_free_meta *free_info =
-			get_free_info(cache, object);
+		struct kasan_alloc_meta *alloc_info;
+		struct kasan_free_meta *free_info;
+
+		alloc_info = get_alloc_info(cache, object);
+		free_info = get_free_info(cache, object);
 
 		switch (alloc_info->state) {
 		case KASAN_STATE_ALLOC:
@@ -550,10 +559,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 		}
 	}
 	return false;
-#else
-	kasan_poison_slab_free(cache, object);
-	return false;
-#endif
 }
 
 void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
@@ -568,6 +573,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	if (unlikely(object == NULL))
 		return;
 
+	if (!(cache->flags & SLAB_KASAN))
+		return;
+
 	redzone_start = round_up((unsigned long)(object + size),
 				KASAN_SHADOW_SCALE_SIZE);
 	redzone_end = round_up((unsigned long)object + cache->object_size,
@@ -576,16 +584,13 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
-#ifdef CONFIG_SLAB
 	if (cache->flags & SLAB_KASAN) {
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
-
 		alloc_info->state = KASAN_STATE_ALLOC;
 		alloc_info->alloc_size = size;
 		set_track(&alloc_info->track, flags);
 	}
-#endif
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index fb87923..8c75953 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -110,7 +110,7 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
 void quarantine_remove_cache(struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b3c122d..861b977 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -116,7 +116,6 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
-#ifdef CONFIG_SLAB
 static void print_track(struct kasan_track *track)
 {
 	pr_err("PID = %u\n", track->pid);
@@ -130,8 +129,8 @@ static void print_track(struct kasan_track *track)
 	}
 }
 
-static void object_err(struct kmem_cache *cache, struct page *page,
-			void *object, char *unused_reason)
+static void kasan_object_err(struct kmem_cache *cache, struct page *page,
+				void *object, char *unused_reason)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 	struct kasan_free_meta *free_info;
@@ -162,7 +161,6 @@ static void object_err(struct kmem_cache *cache, struct page *page,
 		break;
 	}
 }
-#endif
 
 static void print_address_description(struct kasan_access_info *info)
 {
@@ -177,7 +175,7 @@ static void print_address_description(struct kasan_access_info *info)
 			struct kmem_cache *cache = page->slab_cache;
 			object = nearest_obj(cache, page,
 						(void *)info->access_addr);
-			object_err(cache, page, object,
+			kasan_object_err(cache, page, object,
 					"kasan: bad access detected");
 			return;
 		}
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a9..3381a74 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -366,6 +366,8 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
 		return s->object_size;
 # endif
+	if (s->flags & SLAB_KASAN)
+		return s->object_size;
 	/*
 	 * If we have the need to store the freelist pointer
 	 * back there or track user information then we can
@@ -463,5 +465,10 @@ void slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
+#if defined(CONFIG_SLUB)
+void do_slab_free(struct kmem_cache *s,
+		struct page *page, void *head, void *tail,
+		int cnt, unsigned long addr);
+#endif
 
 #endif /* MM_SLAB_H */
diff --git a/mm/slub.c b/mm/slub.c
index 825ff45..7b3d1fc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -191,7 +191,11 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 #define MAX_OBJS_PER_PAGE	32767 /* since page.objects is u15 */
 
 /* Internal SLUB flags */
+#ifndef CONFIG_KASAN
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
+#else
+#define __OBJECT_POISON		0x00000000UL /* Disable object poisoning */
+#endif
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
 
 #ifdef CONFIG_SMP
@@ -454,8 +458,6 @@ static inline void *restore_red_left(struct kmem_cache *s, void *p)
  */
 #if defined(CONFIG_SLUB_DEBUG_ON)
 static int slub_debug = DEBUG_DEFAULT_FLAGS;
-#elif defined(CONFIG_KASAN)
-static int slub_debug = SLAB_STORE_USER;
 #else
 static int slub_debug;
 #endif
@@ -1322,7 +1324,7 @@ static inline void kfree_hook(const void *x)
 	kasan_kfree_large(x);
 }
 
-static inline void slab_free_hook(struct kmem_cache *s, void *x)
+static inline bool slab_free_hook(struct kmem_cache *s, void *x)
 {
 	kmemleak_free_recursive(x, s->flags);
 
@@ -1344,11 +1346,11 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
-	kasan_slab_free(s, x);
+	return kasan_slab_free(s, x);
 }
 
 static inline void slab_free_freelist_hook(struct kmem_cache *s,
-					   void *head, void *tail)
+					   void **head, void **tail, int *cnt)
 {
 /*
  * Compiler cannot detect this function can be removed if slab_free_hook()
@@ -1360,13 +1362,27 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
 	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
 	defined(CONFIG_KASAN)
 
-	void *object = head;
-	void *tail_obj = tail ? : head;
+	void *object = *head, *prev = NULL, *next = NULL;
+	void *tail_obj = *tail ? : *head;
+	bool skip = false;
 
 	do {
-		slab_free_hook(s, object);
-	} while ((object != tail_obj) &&
-		 (object = get_freepointer(s, object)));
+		skip = slab_free_hook(s, object);
+		next = (object != tail_obj) ?
+			get_freepointer(s, object) : NULL;
+		if (skip) {
+			if (!prev)
+				*head = next;
+			else
+				set_freepointer(s, prev, next);
+			if (object == tail_obj)
+				*tail = prev;
+			(*cnt)--;
+		} else {
+			prev = object;
+		}
+		object = next;
+	} while (next);
 #endif
 }
 
@@ -2772,12 +2788,22 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 				      void *head, void *tail, int cnt,
 				      unsigned long addr)
 {
+	void *free_head = head, *free_tail = tail;
+
+	slab_free_freelist_hook(s, &free_head, &free_tail, &cnt);
+	/* slab_free_freelist_hook() could have emptied the freelist. */
+	if (cnt == 0)
+		return;
+	do_slab_free(s, page, free_head, free_tail, cnt, addr);
+}
+
+__always_inline void do_slab_free(struct kmem_cache *s,
+				struct page *page, void *head, void *tail,
+				int cnt, unsigned long addr)
+{
 	void *tail_obj = tail ? : head;
 	struct kmem_cache_cpu *c;
 	unsigned long tid;
-
-	slab_free_freelist_hook(s, head, tail);
-
 redo:
 	/*
 	 * Determine the currently cpus per cpu slab.
@@ -2811,6 +2837,12 @@ redo:
 
 }
 
+/* Helper function to be used from qlink_free() in mm/kasan/quarantine.c */
+void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
+{
+	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
+}
+
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
 	s = cache_from_obj(s, x);
@@ -3252,7 +3284,7 @@ static void set_min_partial(struct kmem_cache *s, unsigned long min)
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	unsigned long flags = s->flags;
-	unsigned long size = s->object_size;
+	size_t size = s->object_size;
 	int order;
 
 	/*
@@ -3328,6 +3360,8 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	}
 #endif
 
+	kasan_cache_create(s, &size, &s->flags);
+
 	/*
 	 * SLUB stores one object immediately after another beginning from
 	 * offset 0. In order to align the objects we have to simply size
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
