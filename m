Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A86986B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 13:18:57 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so41062094lfd.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 10:18:57 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id z140si40102193wmc.8.2016.05.11.10.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 10:18:55 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id a17so94573349wme.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 10:18:55 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v9] mm: kasan: Initial memory quarantine implementation
Date: Wed, 11 May 2016 19:18:50 +0200
Message-Id: <1462987130-144092-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Quarantine isolates freed objects in a separate queue. The objects are
returned to the allocator later, which helps to detect use-after-free
errors.

Freed objects are first added to per-cpu quarantine queues.
When a cache is destroyed or memory shrinking is requested, the objects
are moved into the global quarantine queue. Whenever a kmalloc call
allows memory reclaiming, the oldest objects are popped out of the
global queue until the total size of objects in quarantine is less than
3/4 of the maximum quarantine size (which is a fraction of installed
physical memory).

As long as an object remains in the quarantine, KASAN is able to report
accesses to it, so the chance of reporting a use-after-free is increased.
Once the object leaves quarantine, the allocator may reuse it, in which
case the object is unpoisoned and KASAN can't detect incorrect accesses
to it.

Right now quarantine support is only enabled in SLAB allocator.
Unification of KASAN features in SLAB and SLUB will be done later.

This patch is based on the "mm: kasan: quarantine" patch originally
prepared by Dmitry Chernenkov. A number of improvements have been
suggested by Andrey Ryabinin.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - added copyright comments
    - per request from Joonsoo Kim made __cache_free() more straightforward
    - added comments for smp_load_acquire()/smp_store_release()

v3: - incorporate changes introduced by the "mm, kasan: SLAB support" patch

v4: - fix kbuild compile-time error (missing ___cache_free() declaration)
      and a warning (wrong format specifier)

v6: - extended the patch description
    - dropped the unused qlist_remove() function

v9: - incorporate the fixes by Andrey Ryabinin:
      * Fix comment styles,
      * Get rid of some ifdefs
      * Revert needless functions renames in quarantine patch
      * Remove needless local_irq_save()/restore() in
        per_cpu_remove_cache()
      * Add new 'struct qlist_node' instead of 'void **' types. This makes
        code a bit more redable.
    - remove the non-deterministic quarantine test
    - dropped smp_load_acquire()/smp_store_release()
---
 include/linux/kasan.h |  13 ++-
 mm/kasan/Makefile     |   1 +
 mm/kasan/kasan.c      |  57 ++++++++--
 mm/kasan/kasan.h      |  21 +++-
 mm/kasan/quarantine.c | 291 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/report.c     |   1 +
 mm/mempool.c          |   2 +-
 mm/slab.c             |  12 ++-
 mm/slab.h             |   2 +
 mm/slab_common.c      |   2 +
 10 files changed, 387 insertions(+), 15 deletions(-)
 create mode 100644 mm/kasan/quarantine.c

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 737371b..611927f 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -50,6 +50,8 @@ void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags);
+void kasan_cache_shrink(struct kmem_cache *cache);
+void kasan_cache_destroy(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
@@ -63,7 +65,8 @@ void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
-void kasan_slab_free(struct kmem_cache *s, void *object);
+bool kasan_slab_free(struct kmem_cache *s, void *object);
+void kasan_poison_slab_free(struct kmem_cache *s, void *object);
 
 struct kasan_cache {
 	int alloc_meta_offset;
@@ -88,6 +91,8 @@ static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
 				      unsigned long *flags) {}
+static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
+static inline void kasan_cache_destroy(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
@@ -105,7 +110,11 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags) {}
-static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
+static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
+{
+	return false;
+}
+static inline void kasan_poison_slab_free(struct kmem_cache *s, void *object) {}
 
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
 static inline void kasan_free_shadow(const struct vm_struct *vm) {}
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 131daad..1548749 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -8,3 +8,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o
+obj-$(CONFIG_SLAB) += quarantine.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 38f1dd7..8df666b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -388,6 +388,16 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 }
 #endif
 
+void kasan_cache_shrink(struct kmem_cache *cache)
+{
+	quarantine_remove_cache(cache);
+}
+
+void kasan_cache_destroy(struct kmem_cache *cache)
+{
+	quarantine_remove_cache(cache);
+}
+
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -482,7 +492,7 @@ void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
-void kasan_slab_free(struct kmem_cache *cache, void *object)
+void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 {
 	unsigned long size = cache->object_size;
 	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
@@ -491,18 +501,43 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
 	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
 		return;
 
+	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
+}
+
+bool kasan_slab_free(struct kmem_cache *cache, void *object)
+{
 #ifdef CONFIG_SLAB
-	if (cache->flags & SLAB_KASAN) {
-		struct kasan_free_meta *free_info =
-			get_free_info(cache, object);
+	/* RCU slabs could be legally used after free within the RCU period */
+	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
+		return false;
+
+	if (likely(cache->flags & SLAB_KASAN)) {
 		struct kasan_alloc_meta *alloc_info =
 			get_alloc_info(cache, object);
-		alloc_info->state = KASAN_STATE_FREE;
-		set_track(&free_info->track, GFP_NOWAIT);
+		struct kasan_free_meta *free_info =
+			get_free_info(cache, object);
+
+		switch (alloc_info->state) {
+		case KASAN_STATE_ALLOC:
+			alloc_info->state = KASAN_STATE_QUARANTINE;
+			quarantine_put(free_info, cache);
+			set_track(&free_info->track, GFP_NOWAIT);
+			kasan_poison_slab_free(cache, object);
+			return true;
+		case KASAN_STATE_QUARANTINE:
+		case KASAN_STATE_FREE:
+			pr_err("Double free");
+			dump_stack();
+			break;
+		default:
+			break;
+		}
 	}
+	return false;
+#else
+	kasan_poison_slab_free(cache, object);
+	return false;
 #endif
-
-	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 }
 
 void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
@@ -511,6 +546,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
+	if (flags & __GFP_RECLAIM)
+		quarantine_reduce();
+
 	if (unlikely(object == NULL))
 		return;
 
@@ -541,6 +579,9 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
+	if (flags & __GFP_RECLAIM)
+		quarantine_reduce();
+
 	if (unlikely(ptr == NULL))
 		return;
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 30a2f0b..7f7ac51 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -62,6 +62,7 @@ struct kasan_global {
 enum kasan_state {
 	KASAN_STATE_INIT,
 	KASAN_STATE_ALLOC,
+	KASAN_STATE_QUARANTINE,
 	KASAN_STATE_FREE
 };
 
@@ -79,9 +80,14 @@ struct kasan_alloc_meta {
 	u32 reserved;
 };
 
+struct qlist_node {
+	struct qlist_node *next;
+};
 struct kasan_free_meta {
-	/* Allocator freelist pointer, unused by KASAN. */
-	void **freelist;
+	/* This field is used while the object is in the quarantine.
+	 * Otherwise it might be used for the allocator freelist.
+	 */
+	struct qlist_node quarantine_link;
 	struct kasan_track track;
 };
 
@@ -105,4 +111,15 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 
+#ifdef CONFIG_SLAB
+void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
+void quarantine_reduce(void);
+void quarantine_remove_cache(struct kmem_cache *cache);
+#else
+static inline void quarantine_put(struct kasan_free_meta *info,
+				struct kmem_cache *cache) { }
+static inline void quarantine_reduce(void) { }
+static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
+#endif
+
 #endif
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
new file mode 100644
index 0000000..4973505
--- /dev/null
+++ b/mm/kasan/quarantine.c
@@ -0,0 +1,291 @@
+/*
+ * KASAN quarantine.
+ *
+ * Author: Alexander Potapenko <glider@google.com>
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * Based on code by Dmitry Chernenkov.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ */
+
+#include <linux/gfp.h>
+#include <linux/hash.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/percpu.h>
+#include <linux/printk.h>
+#include <linux/shrinker.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/types.h>
+
+#include "../slab.h"
+#include "kasan.h"
+
+/* Data structure and operations for quarantine queues. */
+
+/*
+ * Each queue is a signle-linked list, which also stores the total size of
+ * objects inside of it.
+ */
+struct qlist_head {
+	struct qlist_node *head;
+	struct qlist_node *tail;
+	size_t bytes;
+};
+
+#define QLIST_INIT { NULL, NULL, 0 }
+
+static bool qlist_empty(struct qlist_head *q)
+{
+	return !q->head;
+}
+
+static void qlist_init(struct qlist_head *q)
+{
+	q->head = q->tail = NULL;
+	q->bytes = 0;
+}
+
+static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
+		size_t size)
+{
+	if (unlikely(qlist_empty(q)))
+		q->head = qlink;
+	else
+		q->tail->next = qlink;
+	q->tail = qlink;
+	qlink->next = NULL;
+	q->bytes += size;
+}
+
+static void qlist_move_all(struct qlist_head *from, struct qlist_head *to)
+{
+	if (unlikely(qlist_empty(from)))
+		return;
+
+	if (qlist_empty(to)) {
+		*to = *from;
+		qlist_init(from);
+		return;
+	}
+
+	to->tail->next = from->head;
+	to->tail = from->tail;
+	to->bytes += from->bytes;
+
+	qlist_init(from);
+}
+
+static void qlist_move(struct qlist_head *from, struct qlist_node *last,
+		struct qlist_head *to, size_t size)
+{
+	if (unlikely(last == from->tail)) {
+		qlist_move_all(from, to);
+		return;
+	}
+	if (qlist_empty(to))
+		to->head = from->head;
+	else
+		to->tail->next = from->head;
+	to->tail = last;
+	from->head = last->next;
+	last->next = NULL;
+	from->bytes -= size;
+	to->bytes += size;
+}
+
+
+/*
+ * The object quarantine consists of per-cpu queues and a global queue,
+ * guarded by quarantine_lock.
+ */
+static DEFINE_PER_CPU(struct qlist_head, cpu_quarantine);
+
+static struct qlist_head global_quarantine;
+static DEFINE_SPINLOCK(quarantine_lock);
+
+/* Maximum size of the global queue. */
+static unsigned long quarantine_size;
+
+/*
+ * The fraction of physical memory the quarantine is allowed to occupy.
+ * Quarantine doesn't support memory shrinker with SLAB allocator, so we keep
+ * the ratio low to avoid OOM.
+ */
+#define QUARANTINE_FRACTION 32
+
+#define QUARANTINE_LOW_SIZE (READ_ONCE(quarantine_size) * 3 / 4)
+#define QUARANTINE_PERCPU_SIZE (1 << 20)
+
+static struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
+{
+	return virt_to_head_page(qlink)->slab_cache;
+}
+
+static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
+{
+	struct kasan_free_meta *free_info =
+		container_of(qlink, struct kasan_free_meta,
+			     quarantine_link);
+
+	return ((void *)free_info) - cache->kasan_info.free_meta_offset;
+}
+
+static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
+{
+	void *object = qlink_to_object(qlink, cache);
+	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	unsigned long flags;
+
+	local_irq_save(flags);
+	alloc_info->state = KASAN_STATE_FREE;
+	___cache_free(cache, object, _THIS_IP_);
+	local_irq_restore(flags);
+}
+
+static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
+{
+	struct qlist_node *qlink;
+
+	if (unlikely(qlist_empty(q)))
+		return;
+
+	qlink = q->head;
+	while (qlink) {
+		struct kmem_cache *obj_cache =
+			cache ? cache :	qlink_to_cache(qlink);
+		struct qlist_node *next = qlink->next;
+
+		qlink_free(qlink, obj_cache);
+		qlink = next;
+	}
+	qlist_init(q);
+}
+
+void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
+{
+	unsigned long flags;
+	struct qlist_head *q;
+	struct qlist_head temp = QLIST_INIT;
+
+	local_irq_save(flags);
+
+	q = this_cpu_ptr(&cpu_quarantine);
+	qlist_put(q, &info->quarantine_link, cache->size);
+	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE))
+		qlist_move_all(q, &temp);
+
+	local_irq_restore(flags);
+
+	if (unlikely(!qlist_empty(&temp))) {
+		spin_lock_irqsave(&quarantine_lock, flags);
+		qlist_move_all(&temp, &global_quarantine);
+		spin_unlock_irqrestore(&quarantine_lock, flags);
+	}
+}
+
+void quarantine_reduce(void)
+{
+	size_t new_quarantine_size;
+	unsigned long flags;
+	struct qlist_head to_free = QLIST_INIT;
+	size_t size_to_free = 0;
+	struct qlist_node *last;
+
+	if (likely(READ_ONCE(global_quarantine.bytes) <=
+		   READ_ONCE(quarantine_size)))
+		return;
+
+	spin_lock_irqsave(&quarantine_lock, flags);
+
+	/*
+	 * Update quarantine size in case of hotplug. Allocate a fraction of
+	 * the installed memory to quarantine minus per-cpu queue limits.
+	 */
+	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
+		QUARANTINE_FRACTION;
+	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	WRITE_ONCE(quarantine_size, new_quarantine_size);
+
+	last = global_quarantine.head;
+	while (last) {
+		struct kmem_cache *cache = qlink_to_cache(last);
+
+		size_to_free += cache->size;
+		if (!last->next || size_to_free >
+		    global_quarantine.bytes - QUARANTINE_LOW_SIZE)
+			break;
+		last = last->next;
+	}
+	qlist_move(&global_quarantine, last, &to_free, size_to_free);
+
+	spin_unlock_irqrestore(&quarantine_lock, flags);
+
+	qlist_free_all(&to_free, NULL);
+}
+
+static void qlist_move_cache(struct qlist_head *from,
+				   struct qlist_head *to,
+				   struct kmem_cache *cache)
+{
+	struct qlist_node *prev = NULL, *curr;
+
+	if (unlikely(qlist_empty(from)))
+		return;
+
+	curr = from->head;
+	while (curr) {
+		struct qlist_node *qlink = curr;
+		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
+
+		if (obj_cache == cache) {
+			if (unlikely(from->head == qlink)) {
+				from->head = curr->next;
+				prev = curr;
+			} else
+				prev->next = curr->next;
+			if (unlikely(from->tail == qlink))
+				from->tail = curr->next;
+			from->bytes -= cache->size;
+			qlist_put(to, qlink, cache->size);
+		} else {
+			prev = curr;
+		}
+		curr = curr->next;
+	}
+}
+
+static void per_cpu_remove_cache(void *arg)
+{
+	struct kmem_cache *cache = arg;
+	struct qlist_head to_free = QLIST_INIT;
+	struct qlist_head *q;
+
+	q = this_cpu_ptr(&cpu_quarantine);
+	qlist_move_cache(q, &to_free, cache);
+	qlist_free_all(&to_free, cache);
+}
+
+void quarantine_remove_cache(struct kmem_cache *cache)
+{
+	unsigned long flags;
+	struct qlist_head to_free = QLIST_INIT;
+
+	on_each_cpu(per_cpu_remove_cache, cache, 1);
+
+	spin_lock_irqsave(&quarantine_lock, flags);
+	qlist_move_cache(&global_quarantine, &to_free, cache);
+	spin_unlock_irqrestore(&quarantine_lock, flags);
+
+	qlist_free_all(&to_free, cache);
+}
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 60869a5..b3c122d 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -151,6 +151,7 @@ static void object_err(struct kmem_cache *cache, struct page *page,
 		print_track(&alloc_info->track);
 		break;
 	case KASAN_STATE_FREE:
+	case KASAN_STATE_QUARANTINE:
 		pr_err("Object freed, allocated with size %u bytes\n",
 		       alloc_info->alloc_size);
 		free_info = get_free_info(cache, object);
diff --git a/mm/mempool.c b/mm/mempool.c
index 9b7a14a..9e075f8 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -105,7 +105,7 @@ static inline void poison_element(mempool_t *pool, void *element)
 static void kasan_poison_element(mempool_t *pool, void *element)
 {
 	if (pool->alloc == mempool_alloc_slab)
-		kasan_slab_free(pool->pool_data, element);
+		kasan_poison_slab_free(pool->pool_data, element);
 	if (pool->alloc == mempool_kmalloc)
 		kasan_kfree(element);
 	if (pool->alloc == mempool_alloc_pages)
diff --git a/mm/slab.c b/mm/slab.c
index 17e2848..167a9b1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3327,9 +3327,17 @@ free_done:
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
-	struct array_cache *ac = cpu_cache_get(cachep);
+	/* Put the object into the quarantine, don't touch it for now. */
+	if (kasan_slab_free(cachep, objp))
+		return;
+
+	___cache_free(cachep, objp, caller);
+}
 
-	kasan_slab_free(cachep, objp);
+void ___cache_free(struct kmem_cache *cachep, void *objp,
+		unsigned long caller)
+{
+	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
 	kmemleak_free_recursive(objp, cachep->flags);
diff --git a/mm/slab.h b/mm/slab.h
index 5969769..dedb1a9 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -462,4 +462,6 @@ void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
 int memcg_slab_show(struct seq_file *m, void *p);
 
+void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
+
 #endif /* MM_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3239bfd..a65dad7 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -715,6 +715,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	get_online_cpus();
 	get_online_mems();
 
+	kasan_cache_destroy(s);
 	mutex_lock(&slab_mutex);
 
 	s->refcount--;
@@ -753,6 +754,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 
 	get_online_cpus();
 	get_online_mems();
+	kasan_cache_shrink(cachep);
 	ret = __kmem_cache_shrink(cachep, false);
 	put_online_mems();
 	put_online_cpus();
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
