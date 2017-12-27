Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63D9E6B0253
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:46 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w74so8550729wmf.0
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s206sor5016735wme.2.2017.12.27.04.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:44 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 1/5] kasan: detect invalid frees for large objects
Date: Wed, 27 Dec 2017 13:44:32 +0100
Message-Id: <1b45b4fe1d20fc0de1329aab674c1dd973fee723.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

Detect frees of pointers into middle of large heap objects.

I dropped const from kasan_kfree_large() because it starts propagating
through a bunch of functions in kasan_report.c, slab/slub nearest_obj(),
all of their local variables, fixup_red_left(), etc.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 include/linux/kasan.h |  4 ++--
 lib/test_kasan.c      | 33 +++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c      | 12 +++++-------
 mm/kasan/kasan.h      |  3 +--
 mm/kasan/report.c     |  3 +--
 mm/slub.c             |  4 ++--
 6 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index e3eb834c9a35..fc9e642533f8 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -56,7 +56,7 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
-void kasan_kfree_large(const void *ptr);
+void kasan_kfree_large(void *ptr);
 void kasan_poison_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
@@ -108,7 +108,7 @@ static inline void kasan_init_slab_obj(struct kmem_cache *cache,
 				const void *object) {}
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
-static inline void kasan_kfree_large(const void *ptr) {}
+static inline void kasan_kfree_large(void *ptr) {}
 static inline void kasan_poison_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 2724f86c4cef..e9c5d765be66 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -94,6 +94,37 @@ static noinline void __init kmalloc_pagealloc_oob_right(void)
 	ptr[size] = 0;
 	kfree(ptr);
 }
+
+static noinline void __init kmalloc_pagealloc_uaf(void)
+{
+	char *ptr;
+	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
+
+	pr_info("kmalloc pagealloc allocation: use-after-free\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kfree(ptr);
+	ptr[0] = 0;
+}
+
+static noinline void __init kmalloc_pagealloc_invalid_free(void)
+{
+	char *ptr;
+	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
+
+	pr_info("kmalloc pagealloc allocation: invalid-free\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	kfree(ptr + 1);
+}
 #endif
 
 static noinline void __init kmalloc_large_oob_right(void)
@@ -505,6 +536,8 @@ static int __init kmalloc_tests_init(void)
 	kmalloc_node_oob_right();
 #ifdef CONFIG_SLUB
 	kmalloc_pagealloc_oob_right();
+	kmalloc_pagealloc_uaf();
+	kmalloc_pagealloc_invalid_free();
 #endif
 	kmalloc_large_oob_right();
 	kmalloc_oob_krealloc_more();
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8aaee42fcfab..ecb64fda79e6 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -511,8 +511,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_double_free(cache, object,
-				__builtin_return_address(1));
+		kasan_report_invalid_free(object, __builtin_return_address(1));
 		return true;
 	}
 
@@ -602,12 +601,11 @@ void kasan_poison_kfree(void *ptr)
 		kasan_poison_slab_free(page->slab_cache, ptr);
 }
 
-void kasan_kfree_large(const void *ptr)
+void kasan_kfree_large(void *ptr)
 {
-	struct page *page = virt_to_page(ptr);
-
-	kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
-			KASAN_FREE_PAGE);
+	if (ptr != page_address(virt_to_head_page(ptr)))
+		kasan_report_invalid_free(ptr, __builtin_return_address(1));
+	/* The object will be poisoned by page_alloc. */
 }
 
 int kasan_module_alloc(void *addr, size_t size)
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7c0bcd1f4c0d..57f517d1dfce 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -107,8 +107,7 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
-void kasan_report_double_free(struct kmem_cache *cache, void *object,
-					void *ip);
+void kasan_report_invalid_free(void *object, void *ip);
 
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index eff12e040498..55916ad21722 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -326,8 +326,7 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
-void kasan_report_double_free(struct kmem_cache *cache, void *object,
-				void *ip)
+void kasan_report_invalid_free(void *object, void *ip)
 {
 	unsigned long flags;
 
diff --git a/mm/slub.c b/mm/slub.c
index 3530b3c60ad6..67c8cee43cf6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1354,7 +1354,7 @@ static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 	kasan_kmalloc_large(ptr, size, flags);
 }
 
-static inline void kfree_hook(const void *x)
+static inline void kfree_hook(void *x)
 {
 	kmemleak_free(x);
 	kasan_kfree_large(x);
@@ -3911,7 +3911,7 @@ void kfree(const void *x)
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
-		kfree_hook(x);
+		kfree_hook(object);
 		__free_pages(page, compound_order(page));
 		return;
 	}
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
