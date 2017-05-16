Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59B476B02FA
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so125169020pgc.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:59 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id s68si12129515pfg.108.2017.05.15.18.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:58 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id s62so19215363pgc.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:58 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 06/11] mm/kasan: mark/unmark the target range that is for original shadow memory
Date: Tue, 16 May 2017 10:16:44 +0900
Message-Id: <1494897409-14408-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have the per-page shadow. The purpose of the per-page shadow is
to check the page that is just used/checked in page size granularity.
File cache pages/anonymous page are in this category. The other
category is for being used by byte size granularity. Global variable,
kernel stack and slab memory are in this category.

This patch distinguishes them and mark the page that should be checked by
the original shadow. Validity check for this page will be performed
by using original shadow so we don't lose any checking accuracy even if
we check other pages by using per-page shadow.

Note that there is no code for global variable in this patch since it is
a static area and it will be directly handled by architecture
specific code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kasan.h | 15 ++++++++--
 kernel/fork.c         |  7 +++++
 mm/kasan/kasan.c      | 77 +++++++++++++++++++++++++++++++++++++++++++++------
 mm/slab.c             |  9 ++++++
 mm/slab_common.c      | 11 ++++++--
 mm/slub.c             |  8 ++++++
 6 files changed, 115 insertions(+), 12 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 4390788..c8ef665 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -83,6 +83,10 @@ extern void kasan_disable_current(void);
 void kasan_unpoison_shadow(const void *address, size_t size);
 void kasan_poison_pshadow(const void *address, size_t size);
 void kasan_unpoison_pshadow(const void *address, size_t size);
+int kasan_stack_alloc(const void *address, size_t size);
+void kasan_stack_free(const void *addr, size_t size);
+int kasan_slab_page_alloc(const void *address, size_t size, gfp_t flags);
+void kasan_slab_page_free(const void *addr, size_t size);
 
 void kasan_unpoison_task_stack(struct task_struct *task);
 void kasan_unpoison_stack_above_sp_to(const void *watermark);
@@ -100,7 +104,7 @@ void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
-void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
+int kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(const void *ptr);
 void kasan_poison_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
@@ -130,6 +134,12 @@ void kasan_restore_multi_shot(bool enabled);
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 static inline void kasan_poison_pshadow(const void *address, size_t size) {}
 static inline void kasan_unpoison_pshadow(const void *address, size_t size) {}
+static inline int kasan_stack_alloc(const void *address,
+					size_t size) { return 0; }
+static inline void kasan_stack_free(const void *addr, size_t size) {}
+static inline int kasan_slab_page_alloc(const void *address, size_t size,
+					gfp_t flags) { return 0; }
+static inline void kasan_slab_page_free(const void *addr, size_t size) {}
 
 static inline void kasan_unpoison_task_stack(struct task_struct *task) {}
 static inline void kasan_unpoison_stack_above_sp_to(const void *watermark) {}
@@ -154,7 +164,8 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 static inline void kasan_init_slab_obj(struct kmem_cache *cache,
 				const void *object) {}
 
-static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
+static inline int kasan_kmalloc_large(void *ptr, size_t size,
+				gfp_t flags) { return 0; }
 static inline void kasan_kfree_large(const void *ptr) {}
 static inline void kasan_poison_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
diff --git a/kernel/fork.c b/kernel/fork.c
index 5d32780..6741d3c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -237,6 +237,12 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
 
+	if (kasan_stack_alloc(page ? page_address(page) : NULL,
+				PAGE_SIZE << THREAD_SIZE_ORDER)) {
+		__free_pages(page, THREAD_SIZE_ORDER);
+		page = NULL;
+	}
+
 	return page ? page_address(page) : NULL;
 #endif
 }
@@ -264,6 +270,7 @@ static inline void free_thread_stack(struct task_struct *tsk)
 	}
 #endif
 
+	kasan_stack_free(tsk->stack, PAGE_SIZE << THREAD_SIZE_ORDER);
 	__free_pages(virt_to_page(tsk->stack), THREAD_SIZE_ORDER);
 }
 # else
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 76b7b89..fb18283 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -455,16 +455,31 @@ void *memcpy(void *dest, const void *src, size_t len)
 
 void kasan_alloc_pages(struct page *page, unsigned int order)
 {
-	if (likely(!PageHighMem(page)))
-		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
+	if (likely(!PageHighMem(page))) {
+		if (!kasan_pshadow_inited()) {
+			kasan_unpoison_shadow(page_address(page),
+					PAGE_SIZE << order);
+			return;
+		}
+
+		kasan_unpoison_pshadow(page_address(page), PAGE_SIZE << order);
+	}
 }
 
 void kasan_free_pages(struct page *page, unsigned int order)
 {
-	if (likely(!PageHighMem(page)))
-		kasan_poison_shadow(page_address(page),
-				PAGE_SIZE << order,
-				KASAN_FREE_PAGE);
+	if (likely(!PageHighMem(page))) {
+		if (!kasan_pshadow_inited()) {
+			kasan_poison_shadow(page_address(page),
+					PAGE_SIZE << order,
+					KASAN_FREE_PAGE);
+			return;
+		}
+
+		kasan_mark_pshadow(page_address(page),
+					PAGE_SIZE << order,
+					KASAN_PER_PAGE_FREE);
+	}
 }
 
 /*
@@ -700,19 +715,25 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
+int kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 {
 	struct page *page;
 	unsigned long redzone_start;
 	unsigned long redzone_end;
+	int err;
 
 	if (gfpflags_allow_blocking(flags))
 		quarantine_reduce();
 
 	if (unlikely(ptr == NULL))
-		return;
+		return 0;
 
 	page = virt_to_page(ptr);
+	err = kasan_slab_page_alloc(ptr,
+		PAGE_SIZE << compound_order(page), flags);
+	if (err)
+		return err;
+
 	redzone_start = round_up((unsigned long)(ptr + size),
 				KASAN_SHADOW_SCALE_SIZE);
 	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
@@ -720,6 +741,8 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	kasan_unpoison_shadow(ptr, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_PAGE_REDZONE);
+
+	return 0;
 }
 
 void kasan_krealloc(const void *object, size_t size, gfp_t flags)
@@ -758,6 +781,25 @@ void kasan_kfree_large(const void *ptr)
 			KASAN_FREE_PAGE);
 }
 
+int kasan_slab_page_alloc(const void *addr, size_t size, gfp_t flags)
+{
+	if (!kasan_pshadow_inited() || !addr)
+		return 0;
+
+	kasan_unpoison_shadow(addr, size);
+	kasan_poison_pshadow(addr, size);
+
+	return 0;
+}
+
+void kasan_slab_page_free(const void *addr, size_t size)
+{
+	if (!kasan_pshadow_inited() || !addr)
+		return;
+
+	kasan_poison_shadow(addr, size, KASAN_FREE_PAGE);
+}
+
 int kasan_module_alloc(void *addr, size_t size)
 {
 	void *ret;
@@ -792,6 +834,25 @@ void kasan_free_shadow(const struct vm_struct *vm)
 		vfree(kasan_mem_to_shadow(vm->addr));
 }
 
+int kasan_stack_alloc(const void *addr, size_t size)
+{
+	if (!kasan_pshadow_inited() || !addr)
+		return 0;
+
+	kasan_unpoison_shadow(addr, size);
+	kasan_poison_pshadow(addr, size);
+
+	return 0;
+}
+
+void kasan_stack_free(const void *addr, size_t size)
+{
+	if (!kasan_pshadow_inited() || !addr)
+		return;
+
+	kasan_poison_shadow(addr, size, KASAN_FREE_PAGE);
+}
+
 static void register_global(struct kasan_global *global)
 {
 	size_t aligned_size = round_up(global->size, KASAN_SHADOW_SCALE_SIZE);
diff --git a/mm/slab.c b/mm/slab.c
index 2a31ee3..77b8be6 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1418,7 +1418,15 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 		return NULL;
 	}
 
+	if (kasan_slab_page_alloc(page_address(page),
+			PAGE_SIZE << cachep->gfporder, flags)) {
+		__free_pages(page, cachep->gfporder);
+		return NULL;
+	}
+
 	if (memcg_charge_slab(page, flags, cachep->gfporder, cachep)) {
+		kasan_slab_page_free(page_address(page),
+				PAGE_SIZE << cachep->gfporder);
 		__free_pages(page, cachep->gfporder);
 		return NULL;
 	}
@@ -1474,6 +1482,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	memcg_uncharge_slab(page, order, cachep);
+	kasan_slab_page_free(page_address(page), PAGE_SIZE << order);
 	__free_pages(page, order);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 01a0fe2..4545975 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1112,9 +1112,16 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 
 	flags |= __GFP_COMP;
 	page = alloc_pages(flags, order);
-	ret = page ? page_address(page) : NULL;
+	if (!page)
+		return NULL;
+
+	ret = page_address(page);
+	if (kasan_kmalloc_large(ret, size, flags)) {
+		__free_pages(page, order);
+		return NULL;
+	}
+
 	kmemleak_alloc(ret, size, 1, flags);
-	kasan_kmalloc_large(ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
diff --git a/mm/slub.c b/mm/slub.c
index 57e5156..721894c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1409,7 +1409,14 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	else
 		page = __alloc_pages_node(node, flags, order);
 
+	if (kasan_slab_page_alloc(page ? page_address(page) : NULL,
+				PAGE_SIZE << order, flags)) {
+		__free_pages(page, order);
+		page = NULL;
+	}
+
 	if (page && memcg_charge_slab(page, flags, order, s)) {
+		kasan_slab_page_free(page_address(page), PAGE_SIZE << order);
 		__free_pages(page, order);
 		page = NULL;
 	}
@@ -1667,6 +1674,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	memcg_uncharge_slab(page, order, s);
+	kasan_slab_page_free(page_address(page), PAGE_SIZE << order);
 	__free_pages(page, order);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
