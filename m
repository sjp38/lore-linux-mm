Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD716B025E
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w141so9828387wme.1
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v72sor9017703wrb.36.2017.12.27.04.44.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:45 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 3/5] kasan: detect invalid frees for large mempool objects
Date: Wed, 27 Dec 2017 13:44:34 +0100
Message-Id: <bf7a7d035d7a5ed62d2dd0e3d2e8a4fcdf456aa7.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

Detect frees of pointers into middle of mempool objects.

I did a one-off test, but it turned out to be very tricky,
so I reverted it. First, mempool does not call kasan_poison_kfree()
unless allocation function fails. I stubbed an allocation function
to fail on second and subsequent allocations. But then mempool stopped
to call kasan_poison_kfree() at all, because it does it only when
allocation function is mempool_kmalloc(). We could support this
special failing test allocation function in mempool, but it also
can't live with kasan tests, because these are in a module.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 include/linux/kasan.h |  4 ++--
 mm/kasan/kasan.c      | 11 ++++++++---
 mm/mempool.c          |  6 +++---
 3 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index f0d13c30acc6..fc45f8952d1e 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -57,7 +57,7 @@ void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(void *ptr, unsigned long ip);
-void kasan_poison_kfree(void *ptr);
+void kasan_poison_kfree(void *ptr, unsigned long ip);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
@@ -109,7 +109,7 @@ static inline void kasan_init_slab_obj(struct kmem_cache *cache,
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
 static inline void kasan_kfree_large(void *ptr, unsigned long ip) {}
-static inline void kasan_poison_kfree(void *ptr) {}
+static inline void kasan_poison_kfree(void *ptr, unsigned long ip) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
 static inline void kasan_krealloc(const void *object, size_t new_size,
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 32f555ded938..77c103748728 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -588,17 +588,22 @@ void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 		kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
-void kasan_poison_kfree(void *ptr)
+void kasan_poison_kfree(void *ptr, unsigned long ip)
 {
 	struct page *page;
 
 	page = virt_to_head_page(ptr);
 
-	if (unlikely(!PageSlab(page)))
+	if (unlikely(!PageSlab(page))) {
+		if (ptr != page_address(page)) {
+			kasan_report_invalid_free(ptr, ip);
+			return;
+		}
 		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
 				KASAN_FREE_PAGE);
-	else
+	} else {
 		kasan_poison_slab_free(page->slab_cache, ptr);
+	}
 }
 
 void kasan_kfree_large(void *ptr, unsigned long ip)
diff --git a/mm/mempool.c b/mm/mempool.c
index 7d8c5a0010a2..5c9dce34719b 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -103,10 +103,10 @@ static inline void poison_element(mempool_t *pool, void *element)
 }
 #endif /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */
 
-static void kasan_poison_element(mempool_t *pool, void *element)
+static __always_inline void kasan_poison_element(mempool_t *pool, void *element)
 {
 	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
-		kasan_poison_kfree(element);
+		kasan_poison_kfree(element, _RET_IP_);
 	if (pool->alloc == mempool_alloc_pages)
 		kasan_free_pages(element, (unsigned long)pool->pool_data);
 }
@@ -119,7 +119,7 @@ static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
 		kasan_alloc_pages(element, (unsigned long)pool->pool_data);
 }
 
-static void add_element(mempool_t *pool, void *element)
+static __always_inline void add_element(mempool_t *pool, void *element)
 {
 	BUG_ON(pool->curr_nr >= pool->min_nr);
 	poison_element(pool, element);
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
