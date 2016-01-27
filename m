Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6E033680F7F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:23 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so39772820wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:23 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id v2si10002739wjz.107.2016.01.27.10.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:22 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id n5so39828561wmn.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:21 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 2/8] mm, kasan: SLAB support
Date: Wed, 27 Jan 2016 19:25:07 +0100
Message-Id: <7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch adds KASAN hooks to SLAB allocator.

This patch is based on the "mm: kasan: unified support for SLUB and
SLAB allocators" patch originally prepared by Dmitry Chernenkov.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 Documentation/kasan.txt  |  5 ++-
 include/linux/kasan.h    | 12 +++++++
 include/linux/slab.h     |  6 ++++
 include/linux/slab_def.h | 14 ++++++++
 include/linux/slub_def.h | 11 ++++++
 lib/Kconfig.kasan        |  4 ++-
 mm/Makefile              |  1 +
 mm/kasan/kasan.c         | 91 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h         | 34 ++++++++++++++++++
 mm/kasan/report.c        | 59 +++++++++++++++++++++++++------
 mm/slab.c                | 46 +++++++++++++++++++++---
 mm/slab_common.c         |  2 +-
 12 files changed, 264 insertions(+), 21 deletions(-)

diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
index aa1e0c9..7dd95b3 100644
--- a/Documentation/kasan.txt
+++ b/Documentation/kasan.txt
@@ -12,8 +12,7 @@ KASAN uses compile-time instrumentation for checking every memory access,
 therefore you will need a GCC version 4.9.2 or later. GCC 5.0 or later is
 required for detection of out-of-bounds accesses to stack or global variables.
 
-Currently KASAN is supported only for x86_64 architecture and requires the
-kernel to be built with the SLUB allocator.
+Currently KASAN is supported only for x86_64 architecture.
 
 1. Usage
 ========
@@ -27,7 +26,7 @@ inline are compiler instrumentation types. The former produces smaller binary
 the latter is 1.1 - 2 times faster. Inline instrumentation requires a GCC
 version 5.0 or later.
 
-Currently KASAN works only with the SLUB memory allocator.
+KASAN works with both SLUB and SLAB memory allocators.
 For better bug detection and nicer reporting, enable CONFIG_STACKTRACE.
 
 To disable instrumentation for specific files or directories, add a line
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 4b9f85c..4405a35 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -46,6 +46,9 @@ void kasan_unpoison_shadow(const void *address, size_t size);
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
+void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+			unsigned long *flags);
+
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
@@ -59,6 +62,11 @@ void kasan_krealloc(const void *object, size_t new_size);
 void kasan_slab_alloc(struct kmem_cache *s, void *object);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
+struct kasan_cache {
+	int alloc_meta_offset;
+	int free_meta_offset;
+};
+
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
 
@@ -72,6 +80,10 @@ static inline void kasan_disable_current(void) {}
 static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
 static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
+static inline void kasan_cache_create(struct kmem_cache *cache,
+				      size_t *size,
+				      unsigned long *flags) {}
+
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
 					void *object) {}
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3ffee74..92f8558 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -92,6 +92,12 @@
 # define SLAB_ACCOUNT		0x00000000UL
 #endif
 
+#ifdef CONFIG_KASAN
+#define SLAB_KASAN		0x08000000UL
+#else
+#define SLAB_KASAN		0x00000000UL
+#endif
+
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 33d0490..a25804d 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -72,8 +72,22 @@ struct kmem_cache {
 #ifdef CONFIG_MEMCG_KMEM
 	struct memcg_cache_params memcg_params;
 #endif
+#ifdef CONFIG_KASAN
+	struct kasan_cache kasan_info;
+#endif
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
+static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
+				void *x) {
+	void *object = x - (x - page->s_mem) % cache->size;
+	void *last_object = page->s_mem + (cache->num - 1) * cache->size;
+
+	if (unlikely(object > last_object))
+		return last_object;
+	else
+		return object;
+}
+
 #endif	/* _LINUX_SLAB_DEF_H */
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3388511..c553dad 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -129,4 +129,15 @@ static inline void *virt_to_obj(struct kmem_cache *s,
 void object_err(struct kmem_cache *s, struct page *page,
 		u8 *object, char *reason);
 
+static inline void *nearest_obj(struct kmem_cache *cache, struct page *page,
+				void *x) {
+	void *object = x - (x - page_address(page)) % cache->size;
+	void *last_object = page_address(page) +
+		(page->objects - 1) * cache->size;
+	if (unlikely(object > last_object))
+		return last_object;
+	else
+		return object;
+}
+
 #endif /* _LINUX_SLUB_DEF_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 0fee5ac..0e4d2b3 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -5,7 +5,7 @@ if HAVE_ARCH_KASAN
 
 config KASAN
 	bool "KASan: runtime memory debugger"
-	depends on SLUB_DEBUG
+	depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
 	select CONSTRUCTORS
 	help
 	  Enables kernel address sanitizer - runtime memory debugger,
@@ -16,6 +16,8 @@ config KASAN
 	  This feature consumes about 1/8 of available memory and brings about
 	  ~x3 performance slowdown.
 	  For better error detection enable CONFIG_STACKTRACE.
+	  Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
+	  (the resulting kernel does not boot).
 
 choice
 	prompt "Instrumentation type"
diff --git a/mm/Makefile b/mm/Makefile
index 2ed4319..d675b37 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -3,6 +3,7 @@
 #
 
 KASAN_SANITIZE_slab_common.o := n
+KASAN_SANITIZE_slab.o := n
 KASAN_SANITIZE_slub.o := n
 
 mmu-y			:= nommu.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index bc0a8d8..84305c2 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -314,6 +314,59 @@ void kasan_free_pages(struct page *page, unsigned int order)
 				KASAN_FREE_PAGE);
 }
 
+#ifdef CONFIG_SLAB
+/*
+ * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
+ * For larger allocations larger redzones are used.
+ */
+static size_t optimal_redzone(size_t object_size)
+{
+	int rz =
+		object_size <= 64        - 16   ? 16 :
+		object_size <= 128       - 32   ? 32 :
+		object_size <= 512       - 64   ? 64 :
+		object_size <= 4096      - 128  ? 128 :
+		object_size <= (1 << 14) - 256  ? 256 :
+		object_size <= (1 << 15) - 512  ? 512 :
+		object_size <= (1 << 16) - 1024 ? 1024 : 2048;
+	return rz;
+}
+
+void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+			unsigned long *flags)
+{
+	int redzone_adjust;
+	/* Make sure the adjusted size is still less than
+	 * KMALLOC_MAX_CACHE_SIZE.
+	 * TODO: this check is only useful for SLAB, but not SLUB. We'll need
+	 * to skip it for SLUB when it starts using kasan_cache_create().
+	 */
+	if (*size > KMALLOC_MAX_CACHE_SIZE -
+	    sizeof(struct kasan_alloc_meta) -
+	    sizeof(struct kasan_free_meta))
+		return;
+	*flags |= SLAB_KASAN;
+	/* Add alloc meta. */
+	cache->kasan_info.alloc_meta_offset = *size;
+	*size += sizeof(struct kasan_alloc_meta);
+
+	/* Add free meta. */
+	if (cache->flags & SLAB_DESTROY_BY_RCU || cache->ctor ||
+	    cache->object_size < sizeof(struct kasan_free_meta)) {
+		cache->kasan_info.free_meta_offset = *size;
+		*size += sizeof(struct kasan_free_meta);
+	}
+	redzone_adjust = optimal_redzone(cache->object_size) -
+		(*size - cache->object_size);
+	if (redzone_adjust > 0)
+		*size += redzone_adjust;
+	*size = min(KMALLOC_MAX_CACHE_SIZE,
+		    max(*size,
+			cache->object_size +
+			optimal_redzone(cache->object_size)));
+}
+#endif
+
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -331,8 +384,36 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object,
 			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
 			KASAN_KMALLOC_REDZONE);
+#ifdef CONFIG_SLAB
+	if (cache->flags & SLAB_KASAN) {
+		struct kasan_alloc_meta *alloc_info =
+			get_alloc_info(cache, object);
+		alloc_info->state = KASAN_STATE_INIT;
+	}
+#endif
 }
 
+static inline void set_track(struct kasan_track *track)
+{
+	track->cpu = raw_smp_processor_id();
+	track->pid = current->pid;
+	track->when = jiffies;
+}
+
+#ifdef CONFIG_SLAB
+struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
+					const void *object)
+{
+	return (void *)object + cache->kasan_info.alloc_meta_offset;
+}
+
+struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
+				      const void *object)
+{
+	return (void *)object + cache->kasan_info.free_meta_offset;
+}
+#endif
+
 void kasan_slab_alloc(struct kmem_cache *cache, void *object)
 {
 	kasan_kmalloc(cache, object, cache->object_size);
@@ -366,6 +447,16 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
+#ifdef CONFIG_SLAB
+	if (cache->flags & SLAB_KASAN) {
+		struct kasan_alloc_meta *alloc_info =
+			get_alloc_info(cache, object);
+
+		alloc_info->state = KASAN_STATE_ALLOC;
+		alloc_info->alloc_size = size;
+		set_track(&alloc_info->track);
+	}
+#endif
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 4f6c62e..7b9e4ab9 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -54,6 +54,40 @@ struct kasan_global {
 #endif
 };
 
+/**
+ * Structures to keep alloc and free tracks *
+ */
+
+enum kasan_state {
+	KASAN_STATE_INIT,
+	KASAN_STATE_ALLOC,
+	KASAN_STATE_FREE
+};
+
+struct kasan_track {
+	u64 cpu : 6;			/* for NR_CPUS = 64 */
+	u64 pid : 16;			/* 65536 processes */
+	u64 when : 42;			/* ~140 years */
+};
+
+struct kasan_alloc_meta {
+	u32 state : 2;	/* enum kasan_state */
+	u32 alloc_size : 30;
+	struct kasan_track track;
+};
+
+struct kasan_free_meta {
+	/* Allocator freelist pointer, unused by KASAN. */
+	void **freelist;
+	struct kasan_track track;
+};
+
+struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
+					const void *object);
+struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
+					const void *object);
+
+
 static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 {
 	return (void *)(((unsigned long)shadow_addr - KASAN_SHADOW_OFFSET)
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 12f222d..2bf7218 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -115,6 +115,42 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
+static void print_track(struct kasan_track *track)
+{
+	pr_err("PID = %lu, CPU = %lu, timestamp = %lu\n", track->pid,
+	       track->cpu, track->when);
+}
+
+static void print_object(struct kmem_cache *cache, void *object)
+{
+	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	struct kasan_free_meta *free_info;
+
+	pr_err("Object at %p, in cache %s\n", object, cache->name);
+	if (!(cache->flags & SLAB_KASAN))
+		return;
+	switch (alloc_info->state) {
+	case KASAN_STATE_INIT:
+		pr_err("Object not allocated yet\n");
+		break;
+	case KASAN_STATE_ALLOC:
+		pr_err("Object allocated with size %u bytes.\n",
+		       alloc_info->alloc_size);
+		pr_err("Allocation:\n");
+		print_track(&alloc_info->track);
+		break;
+	case KASAN_STATE_FREE:
+		pr_err("Object freed, allocated with size %u bytes\n",
+		       alloc_info->alloc_size);
+		free_info = get_free_info(cache, object);
+		pr_err("Allocation:\n");
+		print_track(&alloc_info->track);
+		pr_err("Deallocation:\n");
+		print_track(&free_info->track);
+		break;
+	}
+}
+
 static void print_address_description(struct kasan_access_info *info)
 {
 	const void *addr = info->access_addr;
@@ -126,17 +162,14 @@ static void print_address_description(struct kasan_access_info *info)
 		if (PageSlab(page)) {
 			void *object;
 			struct kmem_cache *cache = page->slab_cache;
-			void *last_object;
-
-			object = virt_to_obj(cache, page_address(page), addr);
-			last_object = page_address(page) +
-				page->objects * cache->size;
-
-			if (unlikely(object > last_object))
-				object = last_object; /* we hit into padding */
-
+			object = nearest_obj(cache, page,
+						(void *)info->access_addr);
+#ifdef CONFIG_SLAB
+			print_object(cache, object);
+#else
 			object_err(cache, page, object,
-				"kasan: bad access detected");
+					"kasan: bad access detected");
+#endif
 			return;
 		}
 		dump_page(page, "kasan: bad access detected");
@@ -146,8 +179,9 @@ static void print_address_description(struct kasan_access_info *info)
 		if (!init_task_stack_addr(addr))
 			pr_err("Address belongs to variable %pS\n", addr);
 	}
-
+#ifdef CONFIG_SLUB
 	dump_stack();
+#endif
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
@@ -233,6 +267,9 @@ static void kasan_report_error(struct kasan_access_info *info)
 		dump_stack();
 	} else {
 		print_error_description(info);
+#ifdef CONFIG_SLAB
+		dump_stack();
+#endif
 		print_address_description(info);
 		print_shadow_for_address(info->first_bad_addr);
 	}
diff --git a/mm/slab.c b/mm/slab.c
index 6ecc697..739b89d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2196,6 +2196,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 #endif
 #endif
 
+	kasan_cache_create(cachep, &size, &flags);
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
 	 * (bootstrapping cannot cope with offslab caches so don't do
@@ -2503,8 +2504,13 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		 * cache which they are a constructor for.  Otherwise, deadlock.
 		 * They must also be threaded.
 		 */
-		if (cachep->ctor && !(cachep->flags & SLAB_POISON))
+		if (cachep->ctor && !(cachep->flags & SLAB_POISON)) {
+			kasan_unpoison_object_data(cachep,
+						   objp + obj_offset(cachep));
 			cachep->ctor(objp + obj_offset(cachep));
+			kasan_poison_object_data(
+				cachep, objp + obj_offset(cachep));
+		}
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
@@ -2519,8 +2525,11 @@ static void cache_init_objs(struct kmem_cache *cachep,
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->size / PAGE_SIZE, 0);
 #else
-		if (cachep->ctor)
+		if (cachep->ctor) {
+			kasan_unpoison_object_data(cachep, objp);
 			cachep->ctor(objp);
+			kasan_poison_object_data(cachep, objp);
+		}
 #endif
 		set_obj_status(page, i, OBJECT_FREE);
 		set_free_obj(page, i, i);
@@ -2650,6 +2659,7 @@ static int cache_grow(struct kmem_cache *cachep,
 
 	slab_map_pages(cachep, page, freelist);
 
+	kasan_poison_slab(page);
 	cache_init_objs(cachep, page);
 
 	if (gfpflags_allow_blocking(local_flags))
@@ -3364,7 +3374,10 @@ free_done:
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
-	struct array_cache *ac = cpu_cache_get(cachep);
+	struct array_cache *ac;
+
+	kasan_slab_free(cachep, objp);
+	ac = cpu_cache_get(cachep);
 
 	check_irq_off();
 	kmemleak_free_recursive(objp, cachep->flags);
@@ -3403,6 +3416,8 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
+	if (ret)
+		kasan_slab_alloc(cachep, ret);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3432,6 +3447,8 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 
 	ret = slab_alloc(cachep, flags, _RET_IP_);
 
+	if (ret)
+		kasan_kmalloc(cachep, ret, size);
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
 	return ret;
@@ -3455,6 +3472,8 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
+	if (ret)
+		kasan_slab_alloc(cachep, ret);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
@@ -3473,6 +3492,8 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 
 	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
+	if (ret)
+		kasan_kmalloc(cachep, ret, size);
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3485,11 +3506,16 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 {
 	struct kmem_cache *cachep;
+	void *ret;
 
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
+	if (ret)
+		kasan_kmalloc(cachep, ret, size);
+
+	return ret;
 }
 
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
@@ -3523,6 +3549,8 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 		return cachep;
 	ret = slab_alloc(cachep, flags, caller);
 
+	if (ret)
+		kasan_kmalloc(cachep, ret, size);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
@@ -4240,10 +4268,18 @@ module_init(slab_proc_init);
  */
 size_t ksize(const void *objp)
 {
+	size_t size;
+
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	return virt_to_cache(objp)->object_size;
+	size = virt_to_cache(objp)->object_size;
+	/* We assume that ksize callers could use whole allocated area,
+	 * so we need to unpoison this area.
+	 */
+	kasan_krealloc(objp, size);
+
+	return size;
 }
 EXPORT_SYMBOL(ksize);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e016178..8d2531d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -35,7 +35,7 @@ struct kmem_cache *kmem_cache;
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB)
+		SLAB_FAILSLAB | SLAB_KASAN)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
 			 SLAB_NOTRACK | SLAB_ACCOUNT)
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
