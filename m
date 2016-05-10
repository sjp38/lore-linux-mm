Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97AF26B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 09:38:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k129so32268009iof.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 06:38:28 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0121.outbound.protection.outlook.com. [157.56.112.121])
        by mx.google.com with ESMTPS id k25si774073otb.162.2016.05.10.06.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 10 May 2016 06:38:27 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm-kasan-initial-memory-quarantine-implementation-v8-fix
Date: Tue, 10 May 2016 16:38:54 +0300
Message-ID: <1462887534-30428-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

 * Fix comment styles,
 * Get rid of some ifdefs
 * Revert needless functions renames in quarantine patch
 * Remove needless local_irq_save()/restore() in per_cpu_remove_cache()
 * Add new 'struct qlist_node' instead of 'void **' types. This makes
   code a bit more redable.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/kasan.h |  17 +++-----
 mm/kasan/Makefile     |   5 +--
 mm/kasan/kasan.c      |  14 ++-----
 mm/kasan/kasan.h      |  12 +++++-
 mm/kasan/quarantine.c | 110 +++++++++++++++++++++++++-------------------------
 mm/mempool.c          |   5 +--
 mm/page_alloc.c       |   2 +-
 mm/slab.c             |   7 +---
 mm/slub.c             |   4 +-
 9 files changed, 84 insertions(+), 92 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 645c280..611927f 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -46,7 +46,7 @@ void kasan_unpoison_shadow(const void *address, size_t size);
 void kasan_unpoison_task_stack(struct task_struct *task);
 
 void kasan_alloc_pages(struct page *page, unsigned int order);
-void kasan_poison_free_pages(struct page *page, unsigned int order);
+void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags);
@@ -58,15 +58,13 @@ void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
-void kasan_poison_kfree_large(const void *ptr);
-void kasan_poison_kfree(void *ptr);
+void kasan_kfree_large(const void *ptr);
+void kasan_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
-/* kasan_slab_free() returns true if the object has been put into quarantine.
- */
 bool kasan_slab_free(struct kmem_cache *s, void *object);
 void kasan_poison_slab_free(struct kmem_cache *s, void *object);
 
@@ -88,8 +86,7 @@ static inline void kasan_enable_current(void) {}
 static inline void kasan_disable_current(void) {}
 
 static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
-static inline void kasan_poison_free_pages(struct page *page,
-						unsigned int order) {}
+static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
@@ -104,8 +101,8 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 					void *object) {}
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
-static inline void kasan_poison_kfree_large(const void *ptr) {}
-static inline void kasan_poison_kfree(void *ptr) {}
+static inline void kasan_kfree_large(const void *ptr) {}
+static inline void kasan_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
 static inline void kasan_krealloc(const void *object, size_t new_size,
@@ -113,8 +110,6 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags) {}
-/* kasan_slab_free() returns true if the object has been put into quarantine.
- */
 static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
 {
 	return false;
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 63b54aa..1548749 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -8,7 +8,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o
-
-ifdef CONFIG_SLAB
-	obj-y	+= quarantine.o
-endif
+obj-$(CONFIG_SLAB) += quarantine.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ef2e87b..8df666b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -327,7 +327,7 @@ void kasan_alloc_pages(struct page *page, unsigned int order)
 		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
 }
 
-void kasan_poison_free_pages(struct page *page, unsigned int order)
+void kasan_free_pages(struct page *page, unsigned int order)
 {
 	if (likely(!PageHighMem(page)))
 		kasan_poison_shadow(page_address(page),
@@ -390,16 +390,12 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 
 void kasan_cache_shrink(struct kmem_cache *cache)
 {
-#ifdef CONFIG_SLAB
 	quarantine_remove_cache(cache);
-#endif
 }
 
 void kasan_cache_destroy(struct kmem_cache *cache)
 {
-#ifdef CONFIG_SLAB
 	quarantine_remove_cache(cache);
-#endif
 }
 
 void kasan_poison_slab(struct page *page)
@@ -550,10 +546,8 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-#ifdef CONFIG_SLAB
 	if (flags & __GFP_RECLAIM)
 		quarantine_reduce();
-#endif
 
 	if (unlikely(object == NULL))
 		return;
@@ -585,10 +579,8 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
-#ifdef CONFIG_SLAB
 	if (flags & __GFP_RECLAIM)
 		quarantine_reduce();
-#endif
 
 	if (unlikely(ptr == NULL))
 		return;
@@ -618,7 +610,7 @@ void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 		kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
-void kasan_poison_kfree(void *ptr)
+void kasan_kfree(void *ptr)
 {
 	struct page *page;
 
@@ -631,7 +623,7 @@ void kasan_poison_kfree(void *ptr)
 		kasan_slab_free(page->slab_cache, ptr);
 }
 
-void kasan_poison_kfree_large(const void *ptr)
+void kasan_kfree_large(const void *ptr)
 {
 	struct page *page = virt_to_page(ptr);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7da78a6..7f7ac51 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -80,11 +80,14 @@ struct kasan_alloc_meta {
 	u32 reserved;
 };
 
+struct qlist_node {
+	struct qlist_node *next;
+};
 struct kasan_free_meta {
 	/* This field is used while the object is in the quarantine.
 	 * Otherwise it might be used for the allocator freelist.
 	 */
-	void **quarantine_link;
+	struct qlist_node quarantine_link;
 	struct kasan_track track;
 };
 
@@ -108,8 +111,15 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 
+#ifdef CONFIG_SLAB
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
 void quarantine_remove_cache(struct kmem_cache *cache);
+#else
+static inline void quarantine_put(struct kasan_free_meta *info,
+				struct kmem_cache *cache) { }
+static inline void quarantine_reduce(void) { }
+static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
+#endif
 
 #endif
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 40159a6..1e687d7 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -33,40 +33,42 @@
 
 /* Data structure and operations for quarantine queues. */
 
-/* Each queue is a signle-linked list, which also stores the total size of
+/*
+ * Each queue is a signle-linked list, which also stores the total size of
  * objects inside of it.
  */
-struct qlist {
-	void **head;
-	void **tail;
+struct qlist_head {
+	struct qlist_node *head;
+	struct qlist_node *tail;
 	size_t bytes;
 };
 
 #define QLIST_INIT { NULL, NULL, 0 }
 
-static bool qlist_empty(struct qlist *q)
+static bool qlist_empty(struct qlist_head *q)
 {
 	return !q->head;
 }
 
-static void qlist_init(struct qlist *q)
+static void qlist_init(struct qlist_head *q)
 {
 	q->head = q->tail = NULL;
 	q->bytes = 0;
 }
 
-static void qlist_put(struct qlist *q, void **qlink, size_t size)
+static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
+		size_t size)
 {
 	if (unlikely(qlist_empty(q)))
 		q->head = qlink;
 	else
-		*q->tail = qlink;
+		q->tail->next = qlink;
 	q->tail = qlink;
-	*qlink = NULL;
+	qlink->next = NULL;
 	q->bytes += size;
 }
 
-static void qlist_move_all(struct qlist *from, struct qlist *to)
+static void qlist_move_all(struct qlist_head *from, struct qlist_head *to)
 {
 	if (unlikely(qlist_empty(from)))
 		return;
@@ -77,15 +79,15 @@ static void qlist_move_all(struct qlist *from, struct qlist *to)
 		return;
 	}
 
-	*to->tail = from->head;
+	to->tail->next = from->head;
 	to->tail = from->tail;
 	to->bytes += from->bytes;
 
 	qlist_init(from);
 }
 
-static void qlist_move(struct qlist *from, void **last, struct qlist *to,
-			  size_t size)
+static void qlist_move(struct qlist_head *from, struct qlist_node *last,
+		struct qlist_head *to, size_t size)
 {
 	if (unlikely(last == from->tail)) {
 		qlist_move_all(from, to);
@@ -94,53 +96,56 @@ static void qlist_move(struct qlist *from, void **last, struct qlist *to,
 	if (qlist_empty(to))
 		to->head = from->head;
 	else
-		*to->tail = from->head;
+		to->tail->next = from->head;
 	to->tail = last;
-	from->head = *last;
-	*last = NULL;
+	from->head = last->next;
+	last->next = NULL;
 	from->bytes -= size;
 	to->bytes += size;
 }
 
 
-/* The object quarantine consists of per-cpu queues and a global queue,
+/*
+ * The object quarantine consists of per-cpu queues and a global queue,
  * guarded by quarantine_lock.
  */
-static DEFINE_PER_CPU(struct qlist, cpu_quarantine);
+static DEFINE_PER_CPU(struct qlist_head, cpu_quarantine);
 
-static struct qlist global_quarantine;
+static struct qlist_head global_quarantine;
 static DEFINE_SPINLOCK(quarantine_lock);
 
 /* Maximum size of the global queue. */
 static unsigned long quarantine_size;
 
-/* The fraction of physical memory the quarantine is allowed to occupy.
+/*
+ * The fraction of physical memory the quarantine is allowed to occupy.
  * Quarantine doesn't support memory shrinker with SLAB allocator, so we keep
  * the ratio low to avoid OOM.
  */
 #define QUARANTINE_FRACTION 32
 
-/* smp_load_acquire() here pairs with smp_store_release() in
+/*
+ * smp_load_acquire() here pairs with smp_store_release() in
  * quarantine_reduce().
  */
 #define QUARANTINE_LOW_SIZE (smp_load_acquire(&quarantine_size) * 3 / 4)
 #define QUARANTINE_PERCPU_SIZE (1 << 20)
 
-static struct kmem_cache *qlink_to_cache(void **qlink)
+static struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
 {
 	return virt_to_head_page(qlink)->slab_cache;
 }
 
-static void *qlink_to_object(void **qlink, struct kmem_cache *cache)
+static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
 {
 	struct kasan_free_meta *free_info =
-		container_of((void ***)qlink, struct kasan_free_meta,
+		container_of(qlink, struct kasan_free_meta,
 			     quarantine_link);
 
 	return ((void *)free_info) - cache->kasan_info.free_meta_offset;
 }
 
-static void qlink_free(void **qlink, struct kmem_cache *cache)
+static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
 {
 	void *object = qlink_to_object(qlink, cache);
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
@@ -152,9 +157,9 @@ static void qlink_free(void **qlink, struct kmem_cache *cache)
 	local_irq_restore(flags);
 }
 
-static void qlist_free_all(struct qlist *q, struct kmem_cache *cache)
+static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
 {
-	void **qlink;
+	struct qlist_node *qlink;
 
 	if (unlikely(qlist_empty(q)))
 		return;
@@ -163,7 +168,7 @@ static void qlist_free_all(struct qlist *q, struct kmem_cache *cache)
 	while (qlink) {
 		struct kmem_cache *obj_cache =
 			cache ? cache :	qlink_to_cache(qlink);
-		void **next = *qlink;
+		struct qlist_node *next = qlink->next;
 
 		qlink_free(qlink, obj_cache);
 		qlink = next;
@@ -174,13 +179,13 @@ static void qlist_free_all(struct qlist *q, struct kmem_cache *cache)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 {
 	unsigned long flags;
-	struct qlist *q;
-	struct qlist temp = QLIST_INIT;
+	struct qlist_head *q;
+	struct qlist_head temp = QLIST_INIT;
 
 	local_irq_save(flags);
 
 	q = this_cpu_ptr(&cpu_quarantine);
-	qlist_put(q, (void **) &info->quarantine_link, cache->size);
+	qlist_put(q, &info->quarantine_link, cache->size);
 	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE))
 		qlist_move_all(q, &temp);
 
@@ -197,21 +202,22 @@ void quarantine_reduce(void)
 {
 	size_t new_quarantine_size;
 	unsigned long flags;
-	struct qlist to_free = QLIST_INIT;
+	struct qlist_head to_free = QLIST_INIT;
 	size_t size_to_free = 0;
-	void **last;
+	struct qlist_node *last;
 
 	/* smp_load_acquire() here pairs with smp_store_release() below. */
-	if (likely(ACCESS_ONCE(global_quarantine.bytes) <=
+	if (likely(READ_ONCE(global_quarantine.bytes) <=
 		   smp_load_acquire(&quarantine_size)))
 		return;
 
 	spin_lock_irqsave(&quarantine_lock, flags);
 
-	/* Update quarantine size in case of hotplug. Allocate a fraction of
+	/*
+	 * Update quarantine size in case of hotplug. Allocate a fraction of
 	 * the installed memory to quarantine minus per-cpu queue limits.
 	 */
-	new_quarantine_size = (ACCESS_ONCE(totalram_pages) << PAGE_SHIFT) /
+	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
 	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
 	/* Pairs with smp_load_acquire() above and in QUARANTINE_LOW_SIZE. */
@@ -222,10 +228,10 @@ void quarantine_reduce(void)
 		struct kmem_cache *cache = qlink_to_cache(last);
 
 		size_to_free += cache->size;
-		if (!*last || size_to_free >
+		if (!last->next || size_to_free >
 		    global_quarantine.bytes - QUARANTINE_LOW_SIZE)
 			break;
-		last = (void **) *last;
+		last = last->next;
 	}
 	qlist_move(&global_quarantine, last, &to_free, size_to_free);
 
@@ -234,50 +240,46 @@ void quarantine_reduce(void)
 	qlist_free_all(&to_free, NULL);
 }
 
-static void qlist_move_cache(struct qlist *from,
-				   struct qlist *to,
+static void qlist_move_cache(struct qlist_head *from,
+				   struct qlist_head *to,
 				   struct kmem_cache *cache)
 {
-	void ***prev;
+	struct qlist_node *prev;
 
 	if (unlikely(qlist_empty(from)))
 		return;
 
-	prev = &from->head;
-	while (*prev) {
-		void **qlink = *prev;
+	prev = from->head;
+	while (prev) {
+		struct qlist_node *qlink = prev->next;
 		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
 
 		if (obj_cache == cache) {
 			if (unlikely(from->tail == qlink))
-				from->tail = (void **) prev;
-			*prev = (void **) *qlink;
+				from->tail = prev;
+			prev = qlink->next;
 			from->bytes -= cache->size;
 			qlist_put(to, qlink, cache->size);
 		} else
-			prev = (void ***) *prev;
+			prev = prev->next;
 	}
 }
 
 static void per_cpu_remove_cache(void *arg)
 {
 	struct kmem_cache *cache = arg;
-	struct qlist to_free = QLIST_INIT;
-	struct qlist *q;
-	unsigned long flags;
+	struct qlist_head to_free = QLIST_INIT;
+	struct qlist_head *q;
 
-	local_irq_save(flags);
 	q = this_cpu_ptr(&cpu_quarantine);
 	qlist_move_cache(q, &to_free, cache);
-	local_irq_restore(flags);
-
 	qlist_free_all(&to_free, cache);
 }
 
 void quarantine_remove_cache(struct kmem_cache *cache)
 {
 	unsigned long flags;
-	struct qlist to_free = QLIST_INIT;
+	struct qlist_head to_free = QLIST_INIT;
 
 	on_each_cpu(per_cpu_remove_cache, cache, 1);
 
diff --git a/mm/mempool.c b/mm/mempool.c
index 8655831..9e075f8 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -107,10 +107,9 @@ static void kasan_poison_element(mempool_t *pool, void *element)
 	if (pool->alloc == mempool_alloc_slab)
 		kasan_poison_slab_free(pool->pool_data, element);
 	if (pool->alloc == mempool_kmalloc)
-		kasan_poison_kfree(element);
+		kasan_kfree(element);
 	if (pool->alloc == mempool_alloc_pages)
-		kasan_poison_free_pages(element,
-					(unsigned long)pool->pool_data);
+		kasan_free_pages(element, (unsigned long)pool->pool_data);
 }
 
 static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 497befe..477d938 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -993,7 +993,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
-	kasan_poison_free_pages(page, order);
+	kasan_free_pages(page, order);
 
 	/*
 	 * Check tail pages before head page information is cleared to
diff --git a/mm/slab.c b/mm/slab.c
index 3f20800..cc8bbc1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3547,13 +3547,10 @@ free_done:
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
-#ifdef CONFIG_KASAN
+	/* Put the object into the quarantine, don't touch it for now. */
 	if (kasan_slab_free(cachep, objp))
-		/* The object has been put into the quarantine, don't touch it
-		 * for now.
-		 */
 		return;
-#endif
+
 	___cache_free(cachep, objp, caller);
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index f41360e..538c858 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1319,7 +1319,7 @@ static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 static inline void kfree_hook(const void *x)
 {
 	kmemleak_free(x);
-	kasan_poison_kfree_large(x);
+	kasan_kfree_large(x);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -1344,7 +1344,7 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
-	kasan_poison_slab_free(s, x);
+	kasan_slab_free(s, x);
 }
 
 static inline void slab_free_freelist_hook(struct kmem_cache *s,
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
