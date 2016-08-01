Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD14E828E4
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:44:20 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i199so308236937ioi.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:44:20 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00124.outbound.protection.outlook.com. [40.107.0.124])
        by mx.google.com with ESMTPS id 30si19830051otb.226.2016.08.01.07.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:44:15 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 5/6] mm/kasan: get rid of ->state in struct kasan_alloc_meta
Date: Mon, 1 Aug 2016 17:45:14 +0300
Message-ID: <1470062715-14077-5-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, xiaolong.ye@intel.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The state of object currently tracked in two places - shadow memory,
and the ->state field in struct kasan_alloc_meta.
We can get rid of the latter. The will save us a little bit of memory.
Also, this allow us to move free stack into struct kasan_alloc_meta,
without increasing memory consumption. So now we should always know
when the last time the object was freed. This may be useful for
long delayed use-after-free bugs.

As a side effect this fixes following UBSAN warning:
	UBSAN: Undefined behaviour in mm/kasan/quarantine.c:102:13
	member access within misaligned address ffff88000d1efebc for type 'struct qlist_node'
	which requires 8 byte alignment

Reported-by: kernel test robot <xiaolong.ye@intel.com>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kasan.h |  3 +++
 mm/kasan/kasan.c      | 61 +++++++++++++++++++++++----------------------------
 mm/kasan/kasan.h      | 12 ++--------
 mm/kasan/quarantine.c |  2 --
 mm/kasan/report.c     | 23 +++++--------------
 mm/slab.c             |  4 +++-
 mm/slub.c             |  1 +
 7 files changed, 42 insertions(+), 64 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index c9cf374..d600303 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -56,6 +56,7 @@ void kasan_cache_destroy(struct kmem_cache *cache);
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
+void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(const void *ptr);
@@ -102,6 +103,8 @@ static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
 					void *object) {}
 static inline void kasan_poison_object_data(struct kmem_cache *cache,
 					void *object) {}
+static inline void kasan_init_slab_obj(struct kmem_cache *cache,
+				const void *object) {}
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
 static inline void kasan_kfree_large(const void *ptr) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 388e812..92750e3 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -442,11 +442,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object,
 			round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE),
 			KASAN_KMALLOC_REDZONE);
-	if (cache->flags & SLAB_KASAN) {
-		struct kasan_alloc_meta *alloc_info =
-			get_alloc_info(cache, object);
-		alloc_info->state = KASAN_STATE_INIT;
-	}
 }
 
 static inline int in_irqentry_text(unsigned long ptr)
@@ -510,6 +505,17 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
 
+void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
+{
+	struct kasan_alloc_meta *alloc_info;
+
+	if (!(cache->flags & SLAB_KASAN))
+		return;
+
+	alloc_info = get_alloc_info(cache, object);
+	__memset(alloc_info, 0, sizeof(*alloc_info));
+}
+
 void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
 	kasan_kmalloc(cache, object, cache->object_size, flags);
@@ -529,34 +535,27 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 
 bool kasan_slab_free(struct kmem_cache *cache, void *object)
 {
+	s8 shadow_byte;
+
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_DESTROY_BY_RCU))
 		return false;
 
-	if (likely(cache->flags & SLAB_KASAN)) {
-		struct kasan_alloc_meta *alloc_info;
-		struct kasan_free_meta *free_info;
+	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
+	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
+		pr_err("Double free");
+		dump_stack();
+		return true;
+	}
 
-		alloc_info = get_alloc_info(cache, object);
-		free_info = get_free_info(cache, object);
+	kasan_poison_slab_free(cache, object);
 
-		switch (alloc_info->state) {
-		case KASAN_STATE_ALLOC:
-			alloc_info->state = KASAN_STATE_QUARANTINE;
-			set_track(&free_info->track, GFP_NOWAIT);
-			kasan_poison_slab_free(cache, object);
-			quarantine_put(free_info, cache);
-			return true;
-		case KASAN_STATE_QUARANTINE:
-		case KASAN_STATE_FREE:
-			pr_err("Double free");
-			dump_stack();
-			break;
-		default:
-			break;
-		}
-	}
-	return false;
+	if (unlikely(!(cache->flags & SLAB_KASAN)))
+		return false;
+
+	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
+	quarantine_put(get_free_info(cache, object), cache);
+	return true;
 }
 
 void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
@@ -579,13 +578,9 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
-	if (cache->flags & SLAB_KASAN) {
-		struct kasan_alloc_meta *alloc_info =
-			get_alloc_info(cache, object);
 
-		alloc_info->state = KASAN_STATE_ALLOC;
-		set_track(&alloc_info->track, flags);
-	}
+	if (cache->flags & SLAB_KASAN)
+		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index aa17546..9b7b31e 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -59,13 +59,6 @@ struct kasan_global {
  * Structures to keep alloc and free tracks *
  */
 
-enum kasan_state {
-	KASAN_STATE_INIT,
-	KASAN_STATE_ALLOC,
-	KASAN_STATE_QUARANTINE,
-	KASAN_STATE_FREE
-};
-
 #define KASAN_STACK_DEPTH 64
 
 struct kasan_track {
@@ -74,8 +67,8 @@ struct kasan_track {
 };
 
 struct kasan_alloc_meta {
-	struct kasan_track track;
-	u32 state;
+	struct kasan_track alloc_track;
+	struct kasan_track free_track;
 };
 
 struct qlist_node {
@@ -86,7 +79,6 @@ struct kasan_free_meta {
 	 * Otherwise it might be used for the allocator freelist.
 	 */
 	struct qlist_node quarantine_link;
-	struct kasan_track track;
 };
 
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 4852625..7fd121d 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -144,13 +144,11 @@ static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
 static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
 {
 	void *object = qlink_to_object(qlink, cache);
-	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 	unsigned long flags;
 
 	if (IS_ENABLED(CONFIG_SLAB))
 		local_irq_save(flags);
 
-	alloc_info->state = KASAN_STATE_FREE;
 	___cache_free(cache, object, _THIS_IP_);
 
 	if (IS_ENABLED(CONFIG_SLAB))
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index d67a7e0..f437398 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -133,7 +133,6 @@ static void kasan_object_err(struct kmem_cache *cache, struct page *page,
 				void *object, char *unused_reason)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
-	struct kasan_free_meta *free_info;
 
 	dump_stack();
 	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
@@ -141,23 +140,11 @@ static void kasan_object_err(struct kmem_cache *cache, struct page *page,
 
 	if (!(cache->flags & SLAB_KASAN))
 		return;
-	switch (alloc_info->state) {
-	case KASAN_STATE_INIT:
-		pr_err("Object not allocated yet\n");
-		break;
-	case KASAN_STATE_ALLOC:
-		pr_err("Allocation:\n");
-		print_track(&alloc_info->track);
-		break;
-	case KASAN_STATE_FREE:
-	case KASAN_STATE_QUARANTINE:
-		free_info = get_free_info(cache, object);
-		pr_err("Allocation:\n");
-		print_track(&alloc_info->track);
-		pr_err("Deallocation:\n");
-		print_track(&free_info->track);
-		break;
-	}
+
+	pr_err("Allocated:\n");
+	print_track(&alloc_info->alloc_track);
+	pr_err("Freed:\n");
+	print_track(&alloc_info->free_track);
 }
 
 static void print_address_description(struct kasan_access_info *info)
diff --git a/mm/slab.c b/mm/slab.c
index 09771ed..ca135bd 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2604,9 +2604,11 @@ static void cache_init_objs(struct kmem_cache *cachep,
 	}
 
 	for (i = 0; i < cachep->num; i++) {
+		objp = index_to_obj(cachep, page, i);
+		kasan_init_slab_obj(cachep, objp);
+
 		/* constructor could break poison info */
 		if (DEBUG == 0 && cachep->ctor) {
-			objp = index_to_obj(cachep, page, i);
 			kasan_unpoison_object_data(cachep, objp);
 			cachep->ctor(objp);
 			kasan_poison_object_data(cachep, objp);
diff --git a/mm/slub.c b/mm/slub.c
index 74e7c8c..26eb6a99 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1384,6 +1384,7 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
 	setup_object_debug(s, page, object);
+	kasan_init_slab_obj(s, object);
 	if (unlikely(s->ctor)) {
 		kasan_unpoison_object_data(s, object);
 		s->ctor(object);
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
