Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6B806B0265
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 11:31:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so21112340wme.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:34 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id b70si41895070wmg.18.2016.07.28.08.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 08:31:31 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id q128so256746837wma.1
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:31:31 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 3/3] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
Date: Thu, 28 Jul 2016 17:31:19 +0200
Message-Id: <1469719879-11761-4-git-send-email-glider@google.com>
In-Reply-To: <1469719879-11761-1-git-send-email-glider@google.com>
References: <1469719879-11761-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, akpm@linux-foundation.org, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

For KASAN builds:
 - switch SLUB allocator to using stackdepot instead of storing the
   allocation/deallocation stacks in the objects;
 - change the freelist hook so that parts of the freelist can be put
   into the quarantine.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v8: - incorporated fixes by Andrey Ryabinin submitted as
      mm-kasan-switch-slub-to-stackdepot-enable-memory-quarantine-for-slub-fix
    - account for kasan_free_meta 8-byte alignment in
      kasan_metadata_size()
v7: - addressed comments by Andrey Ryabinin:
      - split the nearest_obj() fix into a separate patch
      - introduce kasan_metadata_size()
      - move KASAN definitions back to mm/kasan/kasan.h
      - fix minor nits
    - addressed comments by Joonsoo Kim:
      - always return the unchanged freelist pointer from slab_free_hook()
      - account for KASAN metadata size in print_trailer()
      - fix minor nits
v6: - addressed comments by Andrey Ryabinin:
      - move nearest_obj() back to header files
      - fix check_pad_bytes() to address problems with poisoning
      - don't define __OBJECT_POISON to 0
      - simplify slab_free_freelist_hook() implementation
      - move KASAN definintions used by SLUB code to include/linux/kasan.h
      - fix minor nits
v5: - addressed comments by Andrey Ryabinin:
      - don't define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to 0
      - account for left redzone size when SLAB_RED_ZONE is used
    - incidentally moved the implementations of nearest_obj() to mm/sl[au]b.c
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
 include/linux/kasan.h    |  2 ++
 include/linux/slab_def.h |  3 ++-
 include/linux/slub_def.h |  4 +++
 lib/Kconfig.kasan        |  4 +--
 mm/kasan/Makefile        |  3 +--
 mm/kasan/kasan.c         | 66 ++++++++++++++++++++++++------------------------
 mm/kasan/kasan.h         |  3 +--
 mm/kasan/report.c        |  8 +++---
 mm/slab.h                |  2 ++
 mm/slub.c                | 57 +++++++++++++++++++++++++++++++----------
 10 files changed, 94 insertions(+), 58 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index ac4b3c4..c9cf374 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -77,6 +77,7 @@ void kasan_free_shadow(const struct vm_struct *vm);
 
 size_t ksize(const void *);
 static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
+size_t kasan_metadata_size(struct kmem_cache *cache);
 
 #else /* CONFIG_KASAN */
 
@@ -121,6 +122,7 @@ static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
 static inline void kasan_free_shadow(const struct vm_struct *vm) {}
 
 static inline void kasan_unpoison_slab(const void *ptr) { }
+static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
 
 #endif /* CONFIG_KASAN */
 
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 339ba02..4ad2c5a 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -88,7 +88,8 @@ struct kmem_cache {
 };
 
 static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
-				void *x) {
+				void *x)
+{
 	void *object = x - (x - page->s_mem) % cache->size;
 	void *last_object = page->s_mem + (cache->num - 1) * cache->size;
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index cf501cf..75f56c2 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -104,6 +104,10 @@ struct kmem_cache {
 	unsigned int *random_seq;
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
index 0379551..303139b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -351,7 +351,6 @@ void kasan_free_pages(struct page *page, unsigned int order)
 				KASAN_FREE_PAGE);
 }
 
-#ifdef CONFIG_SLAB
 /*
  * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
  * For larger allocations larger redzones are used.
@@ -373,16 +372,8 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
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
-	*flags |= SLAB_KASAN;
+	int orig_size = *size;
+
 	/* Add alloc meta. */
 	cache->kasan_info.alloc_meta_offset = *size;
 	*size += sizeof(struct kasan_alloc_meta);
@@ -390,20 +381,30 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	/* Add free meta. */
 	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
 	    cache->object_size < sizeof(struct kasan_free_meta)) {
-		cache->kasan_info.free_meta_offset =
-			ALIGN(*size, sizeof(void *));
+		*size = ALIGN(*size, sizeof(void *));
+		cache->kasan_info.free_meta_offset = *size;
 		*size += sizeof(struct kasan_free_meta);
 	}
 	redzone_adjust = optimal_redzone(cache->object_size) -
 		(*size - cache->object_size);
+
 	if (redzone_adjust > 0)
 		*size += redzone_adjust;
-	*size = min(KMALLOC_MAX_CACHE_SIZE,
-		    max(*size,
-			cache->object_size +
-			optimal_redzone(cache->object_size)));
+
+	*size = min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
+					optimal_redzone(cache->object_size)));
+	/*
+	 * If the metadata doesn't fit, don't enable KASAN at all.
+	 */
+	if (*size <= cache->kasan_info.alloc_meta_offset ||
+			*size <= cache->kasan_info.free_meta_offset) {
+		cache->kasan_info.alloc_meta_offset = 0;
+		cache->kasan_info.free_meta_offset = 0;
+		*size = orig_size;
+		return;
+	}
+	*flags |= SLAB_KASAN;
 }
-#endif
 
 void kasan_cache_shrink(struct kmem_cache *cache)
 {
@@ -415,6 +416,15 @@ void kasan_cache_destroy(struct kmem_cache *cache)
 	quarantine_remove_cache(cache);
 }
 
+size_t kasan_metadata_size(struct kmem_cache *cache)
+{
+	size_t result = cache->kasan_info.alloc_meta_offset ?
+		sizeof(struct kasan_alloc_meta) : 0;
+	return (cache->kasan_info.free_meta_offset ?
+		sizeof(struct kasan_free_meta) + ALIGN(result, sizeof(void *)) :
+		result);
+}
+
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -432,16 +442,13 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
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
@@ -502,7 +509,6 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
-#endif
 
 void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
@@ -523,16 +529,16 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 
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
@@ -551,10 +557,6 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 		}
 	}
 	return false;
-#else
-	kasan_poison_slab_free(cache, object);
-	return false;
-#endif
 }
 
 void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
@@ -577,7 +579,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
-#ifdef CONFIG_SLAB
 	if (cache->flags & SLAB_KASAN) {
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
@@ -586,7 +587,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		alloc_info->alloc_size = size;
 		set_track(&alloc_info->track, flags);
 	}
-#endif
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index fb87923..31972cd 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -95,7 +95,6 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 					const void *object);
 
-
 static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 {
 	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
@@ -110,7 +109,7 @@ static inline bool kasan_report_enabled(void)
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
index f33980a..9653f2e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -369,6 +369,8 @@ static inline size_t slab_ksize(const struct kmem_cache *s)
 	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
 		return s->object_size;
 # endif
+	if (s->flags & SLAB_KASAN)
+		return s->object_size;
 	/*
 	 * If we have the need to store the freelist pointer
 	 * back there or track user information then we can
diff --git a/mm/slub.c b/mm/slub.c
index 1cdde1a..74e7c8c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -454,8 +454,6 @@ static inline void *restore_red_left(struct kmem_cache *s, void *p)
  */
 #if defined(CONFIG_SLUB_DEBUG_ON)
 static int slub_debug = DEBUG_DEFAULT_FLAGS;
-#elif defined(CONFIG_KASAN)
-static int slub_debug = SLAB_STORE_USER;
 #else
 static int slub_debug;
 #endif
@@ -660,6 +658,8 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
 
+	off += kasan_metadata_size(s);
+
 	if (off != size_from_object(s))
 		/* Beginning of the filler is the free pointer */
 		print_section("Padding ", p + off, size_from_object(s) - off);
@@ -787,6 +787,8 @@ static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
 		/* We also have user information there */
 		off += 2 * sizeof(struct track);
 
+	off += kasan_metadata_size(s);
+
 	if (size_from_object(s) == off)
 		return 1;
 
@@ -1322,8 +1324,10 @@ static inline void kfree_hook(const void *x)
 	kasan_kfree_large(x);
 }
 
-static inline void slab_free_hook(struct kmem_cache *s, void *x)
+static inline void *slab_free_hook(struct kmem_cache *s, void *x)
 {
+	void *freeptr;
+
 	kmemleak_free_recursive(x, s->flags);
 
 	/*
@@ -1344,7 +1348,13 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
+	freeptr = get_freepointer(s, x);
+	/*
+	 * kasan_slab_free() may put x into memory quarantine, delaying its
+	 * reuse. In this case the object's freelist pointer is changed.
+	 */
 	kasan_slab_free(s, x);
+	return freeptr;
 }
 
 static inline void slab_free_freelist_hook(struct kmem_cache *s,
@@ -1362,11 +1372,11 @@ static inline void slab_free_freelist_hook(struct kmem_cache *s,
 
 	void *object = head;
 	void *tail_obj = tail ? : head;
+	void *freeptr;
 
 	do {
-		slab_free_hook(s, object);
-	} while ((object != tail_obj) &&
-		 (object = get_freepointer(s, object)));
+		freeptr = slab_free_hook(s, object);
+	} while ((object != tail_obj) && (object = freeptr));
 #endif
 }
 
@@ -2878,16 +2888,13 @@ slab_empty:
  * same page) possible by specifying head and tail ptr, plus objects
  * count (cnt). Bulk free indicated by tail pointer being set.
  */
-static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
-				      void *head, void *tail, int cnt,
-				      unsigned long addr)
+static __always_inline void do_slab_free(struct kmem_cache *s,
+				struct page *page, void *head, void *tail,
+				int cnt, unsigned long addr)
 {
 	void *tail_obj = tail ? : head;
 	struct kmem_cache_cpu *c;
 	unsigned long tid;
-
-	slab_free_freelist_hook(s, head, tail);
-
 redo:
 	/*
 	 * Determine the currently cpus per cpu slab.
@@ -2921,6 +2928,27 @@ redo:
 
 }
 
+static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
+				      void *head, void *tail, int cnt,
+				      unsigned long addr)
+{
+	slab_free_freelist_hook(s, head, tail);
+	/*
+	 * slab_free_freelist_hook() could have put the items into quarantine.
+	 * If so, no need to free them.
+	 */
+	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_DESTROY_BY_RCU))
+		return;
+	do_slab_free(s, page, head, tail, cnt, addr);
+}
+
+#ifdef CONFIG_KASAN
+void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
+{
+	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
+}
+#endif
+
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
 	s = cache_from_obj(s, x);
@@ -3363,7 +3391,7 @@ static void set_min_partial(struct kmem_cache *s, unsigned long min)
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	unsigned long flags = s->flags;
-	unsigned long size = s->object_size;
+	size_t size = s->object_size;
 	int order;
 
 	/*
@@ -3422,7 +3450,10 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		 * the object.
 		 */
 		size += 2 * sizeof(struct track);
+#endif
 
+	kasan_cache_create(s, &size, &s->flags);
+#ifdef CONFIG_SLUB_DEBUG
 	if (flags & SLAB_RED_ZONE) {
 		/*
 		 * Add some empty padding so that we can catch
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
