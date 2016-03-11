Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4945E6B0260
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 12:21:34 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so26204524wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:21:34 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id x68si3834666wme.32.2016.03.11.09.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 09:21:26 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id n186so27874599wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:21:26 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v6 7/7] mm: kasan: Initial memory quarantine implementation
Date: Fri, 11 Mar 2016 18:21:03 +0100
Message-Id: <d6237baf339d691d708fd83e866ce14c898b58c2.1457715116.git.glider@google.com>
In-Reply-To: <cover.1457715116.git.glider@google.com>
References: <cover.1457715116.git.glider@google.com>
In-Reply-To: <cover.1457715116.git.glider@google.com>
References: <cover.1457715116.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
prepared by Dmitry Chernenkov.

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
---
 include/linux/kasan.h |  30 +++--
 lib/test_kasan.c      |  29 +++++
 mm/kasan/Makefile     |   4 +
 mm/kasan/kasan.c      |  71 +++++++++++--
 mm/kasan/kasan.h      |  11 +-
 mm/kasan/quarantine.c | 289 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/report.c     |   1 +
 mm/mempool.c          |   7 +-
 mm/page_alloc.c       |   2 +-
 mm/slab.c             |  15 ++-
 mm/slab.h             |   2 +
 mm/slab_common.c      |   2 +
 mm/slub.c             |   4 +-
 13 files changed, 438 insertions(+), 29 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index bf71ab0..355e722 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -44,24 +44,29 @@ static inline void kasan_disable_current(void)
 void kasan_unpoison_shadow(const void *address, size_t size);
 
 void kasan_alloc_pages(struct page *page, unsigned int order);
-void kasan_free_pages(struct page *page, unsigned int order);
+void kasan_poison_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			unsigned long *flags);
+void kasan_cache_shrink(struct kmem_cache *cache);
+void kasan_cache_destroy(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
-void kasan_kfree_large(const void *ptr);
-void kasan_kfree(void *ptr);
+void kasan_poison_kfree_large(const void *ptr);
+void kasan_poison_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
-void kasan_slab_free(struct kmem_cache *s, void *object);
+/* kasan_slab_free() returns true if the object has been put into quarantine.
+ */
+bool kasan_slab_free(struct kmem_cache *s, void *object);
+void kasan_poison_slab_free(struct kmem_cache *s, void *object);
 
 struct kasan_cache {
 	int alloc_meta_offset;
@@ -79,11 +84,14 @@ static inline void kasan_enable_current(void) {}
 static inline void kasan_disable_current(void) {}
 
 static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
-static inline void kasan_free_pages(struct page *page, unsigned int order) {}
+static inline void kasan_poison_free_pages(struct page *page,
+						unsigned int order) {}
 
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
 				      unsigned long *flags) {}
+static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
+static inline void kasan_cache_destroy(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
@@ -92,8 +100,8 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 					void *object) {}
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
-static inline void kasan_kfree_large(const void *ptr) {}
-static inline void kasan_kfree(void *ptr) {}
+static inline void kasan_poison_kfree_large(const void *ptr) {}
+static inline void kasan_poison_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
 static inline void kasan_krealloc(const void *object, size_t new_size,
@@ -101,7 +109,13 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags) {}
-static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
+/* kasan_slab_free() returns true if the object has been put into quarantine.
+ */
+static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
+{
+	return false;
+}
+static inline void kasan_poison_slab_free(struct kmem_cache *s, void *object) {}
 
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
 static inline void kasan_free_shadow(const struct vm_struct *vm) {}
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 82169fb..799c98e 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -344,6 +344,32 @@ static noinline void __init kasan_stack_oob(void)
 	*(volatile char *)p;
 }
 
+#ifdef CONFIG_SLAB
+static noinline void __init kasan_quarantine_cache(void)
+{
+	struct kmem_cache *cache = kmem_cache_create(
+			"test", 137, 8, GFP_KERNEL, NULL);
+	int i;
+
+	for (i = 0; i <  100; i++) {
+		void *p = kmem_cache_alloc(cache, GFP_KERNEL);
+
+		kmem_cache_free(cache, p);
+		p = kmalloc(sizeof(u64), GFP_KERNEL);
+		kfree(p);
+	}
+	kmem_cache_shrink(cache);
+	for (i = 0; i <  100; i++) {
+		u64 *p = kmem_cache_alloc(cache, GFP_KERNEL);
+
+		kmem_cache_free(cache, p);
+		p = kmalloc(sizeof(u64), GFP_KERNEL);
+		kfree(p);
+	}
+	kmem_cache_destroy(cache);
+}
+#endif
+
 static int __init kmalloc_tests_init(void)
 {
 	kmalloc_oob_right();
@@ -367,6 +393,9 @@ static int __init kmalloc_tests_init(void)
 	kmem_cache_oob();
 	kasan_stack_oob();
 	kasan_global_oob();
+#ifdef CONFIG_SLAB
+	kasan_quarantine_cache();
+#endif
 	return -EAGAIN;
 }
 
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 131daad..63b54aa 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -8,3 +8,7 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o
+
+ifdef CONFIG_SLAB
+	obj-y	+= quarantine.o
+endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 30bb240..9576326 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -307,7 +307,7 @@ void kasan_alloc_pages(struct page *page, unsigned int order)
 		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
 }
 
-void kasan_free_pages(struct page *page, unsigned int order)
+void kasan_poison_free_pages(struct page *page, unsigned int order)
 {
 	if (likely(!PageHighMem(page)))
 		kasan_poison_shadow(page_address(page),
@@ -368,6 +368,20 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 }
 #endif
 
+void kasan_cache_shrink(struct kmem_cache *cache)
+{
+#ifdef CONFIG_SLAB
+	quarantine_remove_cache(cache);
+#endif
+}
+
+void kasan_cache_destroy(struct kmem_cache *cache)
+{
+#ifdef CONFIG_SLAB
+	quarantine_remove_cache(cache);
+#endif
+}
+
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -462,7 +476,7 @@ void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
-void kasan_slab_free(struct kmem_cache *cache, void *object)
+void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 {
 	unsigned long size = cache->object_size;
 	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
@@ -471,18 +485,43 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
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
-		set_track(&free_info->track);
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
@@ -491,6 +530,11 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
+#ifdef CONFIG_SLAB
+	if (flags & __GFP_RECLAIM)
+		quarantine_reduce();
+#endif
+
 	if (unlikely(object == NULL))
 		return;
 
@@ -521,6 +565,11 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	unsigned long redzone_start;
 	unsigned long redzone_end;
 
+#ifdef CONFIG_SLAB
+	if (flags & __GFP_RECLAIM)
+		quarantine_reduce();
+#endif
+
 	if (unlikely(ptr == NULL))
 		return;
 
@@ -549,7 +598,7 @@ void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 		kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
-void kasan_kfree(void *ptr)
+void kasan_poison_kfree(void *ptr)
 {
 	struct page *page;
 
@@ -562,7 +611,7 @@ void kasan_kfree(void *ptr)
 		kasan_slab_free(page->slab_cache, ptr);
 }
 
-void kasan_kfree_large(const void *ptr)
+void kasan_poison_kfree_large(const void *ptr)
 {
 	struct page *page = virt_to_page(ptr);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 30a2f0b..7da78a6 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -62,6 +62,7 @@ struct kasan_global {
 enum kasan_state {
 	KASAN_STATE_INIT,
 	KASAN_STATE_ALLOC,
+	KASAN_STATE_QUARANTINE,
 	KASAN_STATE_FREE
 };
 
@@ -80,8 +81,10 @@ struct kasan_alloc_meta {
 };
 
 struct kasan_free_meta {
-	/* Allocator freelist pointer, unused by KASAN. */
-	void **freelist;
+	/* This field is used while the object is in the quarantine.
+	 * Otherwise it might be used for the allocator freelist.
+	 */
+	void **quarantine_link;
 	struct kasan_track track;
 };
 
@@ -105,4 +108,8 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 
+void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
+void quarantine_reduce(void);
+void quarantine_remove_cache(struct kmem_cache *cache);
+
 #endif
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
new file mode 100644
index 0000000..40159a6
--- /dev/null
+++ b/mm/kasan/quarantine.c
@@ -0,0 +1,289 @@
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
+/* Each queue is a signle-linked list, which also stores the total size of
+ * objects inside of it.
+ */
+struct qlist {
+	void **head;
+	void **tail;
+	size_t bytes;
+};
+
+#define QLIST_INIT { NULL, NULL, 0 }
+
+static bool qlist_empty(struct qlist *q)
+{
+	return !q->head;
+}
+
+static void qlist_init(struct qlist *q)
+{
+	q->head = q->tail = NULL;
+	q->bytes = 0;
+}
+
+static void qlist_put(struct qlist *q, void **qlink, size_t size)
+{
+	if (unlikely(qlist_empty(q)))
+		q->head = qlink;
+	else
+		*q->tail = qlink;
+	q->tail = qlink;
+	*qlink = NULL;
+	q->bytes += size;
+}
+
+static void qlist_move_all(struct qlist *from, struct qlist *to)
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
+	*to->tail = from->head;
+	to->tail = from->tail;
+	to->bytes += from->bytes;
+
+	qlist_init(from);
+}
+
+static void qlist_move(struct qlist *from, void **last, struct qlist *to,
+			  size_t size)
+{
+	if (unlikely(last == from->tail)) {
+		qlist_move_all(from, to);
+		return;
+	}
+	if (qlist_empty(to))
+		to->head = from->head;
+	else
+		*to->tail = from->head;
+	to->tail = last;
+	from->head = *last;
+	*last = NULL;
+	from->bytes -= size;
+	to->bytes += size;
+}
+
+
+/* The object quarantine consists of per-cpu queues and a global queue,
+ * guarded by quarantine_lock.
+ */
+static DEFINE_PER_CPU(struct qlist, cpu_quarantine);
+
+static struct qlist global_quarantine;
+static DEFINE_SPINLOCK(quarantine_lock);
+
+/* Maximum size of the global queue. */
+static unsigned long quarantine_size;
+
+/* The fraction of physical memory the quarantine is allowed to occupy.
+ * Quarantine doesn't support memory shrinker with SLAB allocator, so we keep
+ * the ratio low to avoid OOM.
+ */
+#define QUARANTINE_FRACTION 32
+
+/* smp_load_acquire() here pairs with smp_store_release() in
+ * quarantine_reduce().
+ */
+#define QUARANTINE_LOW_SIZE (smp_load_acquire(&quarantine_size) * 3 / 4)
+#define QUARANTINE_PERCPU_SIZE (1 << 20)
+
+static struct kmem_cache *qlink_to_cache(void **qlink)
+{
+	return virt_to_head_page(qlink)->slab_cache;
+}
+
+static void *qlink_to_object(void **qlink, struct kmem_cache *cache)
+{
+	struct kasan_free_meta *free_info =
+		container_of((void ***)qlink, struct kasan_free_meta,
+			     quarantine_link);
+
+	return ((void *)free_info) - cache->kasan_info.free_meta_offset;
+}
+
+static void qlink_free(void **qlink, struct kmem_cache *cache)
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
+static void qlist_free_all(struct qlist *q, struct kmem_cache *cache)
+{
+	void **qlink;
+
+	if (unlikely(qlist_empty(q)))
+		return;
+
+	qlink = q->head;
+	while (qlink) {
+		struct kmem_cache *obj_cache =
+			cache ? cache :	qlink_to_cache(qlink);
+		void **next = *qlink;
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
+	struct qlist *q;
+	struct qlist temp = QLIST_INIT;
+
+	local_irq_save(flags);
+
+	q = this_cpu_ptr(&cpu_quarantine);
+	qlist_put(q, (void **) &info->quarantine_link, cache->size);
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
+	struct qlist to_free = QLIST_INIT;
+	size_t size_to_free = 0;
+	void **last;
+
+	/* smp_load_acquire() here pairs with smp_store_release() below. */
+	if (likely(ACCESS_ONCE(global_quarantine.bytes) <=
+		   smp_load_acquire(&quarantine_size)))
+		return;
+
+	spin_lock_irqsave(&quarantine_lock, flags);
+
+	/* Update quarantine size in case of hotplug. Allocate a fraction of
+	 * the installed memory to quarantine minus per-cpu queue limits.
+	 */
+	new_quarantine_size = (ACCESS_ONCE(totalram_pages) << PAGE_SHIFT) /
+		QUARANTINE_FRACTION;
+	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
+	/* Pairs with smp_load_acquire() above and in QUARANTINE_LOW_SIZE. */
+	smp_store_release(&quarantine_size, new_quarantine_size);
+
+	last = global_quarantine.head;
+	while (last) {
+		struct kmem_cache *cache = qlink_to_cache(last);
+
+		size_to_free += cache->size;
+		if (!*last || size_to_free >
+		    global_quarantine.bytes - QUARANTINE_LOW_SIZE)
+			break;
+		last = (void **) *last;
+	}
+	qlist_move(&global_quarantine, last, &to_free, size_to_free);
+
+	spin_unlock_irqrestore(&quarantine_lock, flags);
+
+	qlist_free_all(&to_free, NULL);
+}
+
+static void qlist_move_cache(struct qlist *from,
+				   struct qlist *to,
+				   struct kmem_cache *cache)
+{
+	void ***prev;
+
+	if (unlikely(qlist_empty(from)))
+		return;
+
+	prev = &from->head;
+	while (*prev) {
+		void **qlink = *prev;
+		struct kmem_cache *obj_cache = qlink_to_cache(qlink);
+
+		if (obj_cache == cache) {
+			if (unlikely(from->tail == qlink))
+				from->tail = (void **) prev;
+			*prev = (void **) *qlink;
+			from->bytes -= cache->size;
+			qlist_put(to, qlink, cache->size);
+		} else
+			prev = (void ***) *prev;
+	}
+}
+
+static void per_cpu_remove_cache(void *arg)
+{
+	struct kmem_cache *cache = arg;
+	struct qlist to_free = QLIST_INIT;
+	struct qlist *q;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	q = this_cpu_ptr(&cpu_quarantine);
+	qlist_move_cache(q, &to_free, cache);
+	local_irq_restore(flags);
+
+	qlist_free_all(&to_free, cache);
+}
+
+void quarantine_remove_cache(struct kmem_cache *cache)
+{
+	unsigned long flags;
+	struct qlist to_free = QLIST_INIT;
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
index 8e58be0f..bb27732 100644
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
index 716efa8..9da9bef 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -105,11 +105,12 @@ static inline void poison_element(mempool_t *pool, void *element)
 static void kasan_poison_element(mempool_t *pool, void *element)
 {
 	if (pool->alloc == mempool_alloc_slab)
-		kasan_slab_free(pool->pool_data, element);
+		kasan_poison_slab_free(pool->pool_data, element);
 	if (pool->alloc == mempool_kmalloc)
-		kasan_kfree(element);
+		kasan_poison_kfree(element);
 	if (pool->alloc == mempool_alloc_pages)
-		kasan_free_pages(element, (unsigned long)pool->pool_data);
+		kasan_poison_free_pages(element,
+					(unsigned long)pool->pool_data);
 }
 
 static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894..0cadb5d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1005,7 +1005,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
-	kasan_free_pages(page, order);
+	kasan_poison_free_pages(page, order);
 
 	if (PageAnon(page))
 		page->mapping = NULL;
diff --git a/mm/slab.c b/mm/slab.c
index 7d27277..222a3bf 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3336,9 +3336,20 @@ free_done:
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 				unsigned long caller)
 {
-	struct array_cache *ac = cpu_cache_get(cachep);
+#ifdef CONFIG_KASAN
+	if (kasan_slab_free(cachep, objp))
+		/* The object has been put into the quarantine, don't touch it
+		 * for now.
+		 */
+		return;
+#endif
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
index 07690d3..b8502a2 100644
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
diff --git a/mm/slub.c b/mm/slub.c
index 4e63f3b..c76fd2e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1324,7 +1324,7 @@ static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 static inline void kfree_hook(const void *x)
 {
 	kmemleak_free(x);
-	kasan_kfree_large(x);
+	kasan_poison_kfree_large(x);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -1349,7 +1349,7 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(x, s->object_size);
 
-	kasan_slab_free(s, x);
+	kasan_poison_slab_free(s, x);
 }
 
 static inline void slab_free_freelist_hook(struct kmem_cache *s,
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
