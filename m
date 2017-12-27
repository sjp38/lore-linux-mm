Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64BFB6B025F
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d7so1255611wre.15
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m35sor8775508wrm.39.2017.12.27.04.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:46 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 2/5] kasan: don't use __builtin_return_address(1)
Date: Wed, 27 Dec 2017 13:44:33 +0100
Message-Id: <9b01bc2d237a4df74ff8472a3bf6b7635908de01.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
In-Reply-To: <cover.1514378558.git.dvyukov@google.com>
References: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

__builtin_return_address(1) is unreliable without frame pointers.
With defconfig on kmalloc_pagealloc_invalid_free test I am getting:

BUG: KASAN: double-free or invalid-free in           (null)

Pass caller PC from callers explicitly.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 include/linux/kasan.h | 9 +++++----
 mm/kasan/kasan.c      | 8 ++++----
 mm/kasan/kasan.h      | 2 +-
 mm/kasan/report.c     | 4 ++--
 mm/slab.c             | 6 +++---
 mm/slub.c             | 8 ++++----
 6 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index fc9e642533f8..f0d13c30acc6 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -56,14 +56,14 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
-void kasan_kfree_large(void *ptr);
+void kasan_kfree_large(void *ptr, unsigned long ip);
 void kasan_poison_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
-bool kasan_slab_free(struct kmem_cache *s, void *object);
+bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long ip);
 
 struct kasan_cache {
 	int alloc_meta_offset;
@@ -108,7 +108,7 @@ static inline void kasan_init_slab_obj(struct kmem_cache *cache,
 				const void *object) {}
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
-static inline void kasan_kfree_large(void *ptr) {}
+static inline void kasan_kfree_large(void *ptr, unsigned long ip) {}
 static inline void kasan_poison_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
@@ -117,7 +117,8 @@ static inline void kasan_krealloc(const void *object, size_t new_size,
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags) {}
-static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
+static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
+				   unsigned long ip)
 {
 	return false;
 }
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index ecb64fda79e6..32f555ded938 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -501,7 +501,7 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 }
 
-bool kasan_slab_free(struct kmem_cache *cache, void *object)
+bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 {
 	s8 shadow_byte;
 
@@ -511,7 +511,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_invalid_free(object, __builtin_return_address(1));
+		kasan_report_invalid_free(object, ip);
 		return true;
 	}
 
@@ -601,10 +601,10 @@ void kasan_poison_kfree(void *ptr)
 		kasan_poison_slab_free(page->slab_cache, ptr);
 }
 
-void kasan_kfree_large(void *ptr)
+void kasan_kfree_large(void *ptr, unsigned long ip)
 {
 	if (ptr != page_address(virt_to_head_page(ptr)))
-		kasan_report_invalid_free(ptr, __builtin_return_address(1));
+		kasan_report_invalid_free(ptr, ip);
 	/* The object will be poisoned by page_alloc. */
 }
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 57f517d1dfce..2792de927fcd 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -107,7 +107,7 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
-void kasan_report_invalid_free(void *object, void *ip);
+void kasan_report_invalid_free(void *object, unsigned long ip);
 
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 55916ad21722..75206991ece0 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -326,12 +326,12 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
-void kasan_report_invalid_free(void *object, void *ip)
+void kasan_report_invalid_free(void *object, unsigned long ip)
 {
 	unsigned long flags;
 
 	kasan_start_report(&flags);
-	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
 	pr_err("\n");
 	print_address_description(object);
 	pr_err("\n");
diff --git a/mm/slab.c b/mm/slab.c
index 6bc4e609e24b..d074fd0790f4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3478,11 +3478,11 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
  * Release an obj back to its cache. If the obj has a constructed state, it must
  * be in this state _before_ it is released.  Called with disabled ints.
  */
-static inline void __cache_free(struct kmem_cache *cachep, void *objp,
-				unsigned long caller)
+static __always_inline void __cache_free(struct kmem_cache *cachep, void *objp,
+					 unsigned long caller)
 {
 	/* Put the object into the quarantine, don't touch it for now. */
-	if (kasan_slab_free(cachep, objp))
+	if (kasan_slab_free(cachep, objp, _RET_IP_))
 		return;
 
 	___cache_free(cachep, objp, caller);
diff --git a/mm/slub.c b/mm/slub.c
index 67c8cee43cf6..b1e41572c6cb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1354,13 +1354,13 @@ static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 	kasan_kmalloc_large(ptr, size, flags);
 }
 
-static inline void kfree_hook(void *x)
+static __always_inline void kfree_hook(void *x)
 {
 	kmemleak_free(x);
-	kasan_kfree_large(x);
+	kasan_kfree_large(x, _RET_IP_);
 }
 
-static inline void *slab_free_hook(struct kmem_cache *s, void *x)
+static __always_inline void *slab_free_hook(struct kmem_cache *s, void *x)
 {
 	void *freeptr;
 
@@ -1388,7 +1388,7 @@ static inline void *slab_free_hook(struct kmem_cache *s, void *x)
 	 * kasan_slab_free() may put x into memory quarantine, delaying its
 	 * reuse. In this case the object's freelist pointer is changed.
 	 */
-	kasan_slab_free(s, x);
+	kasan_slab_free(s, x, _RET_IP_);
 	return freeptr;
 }
 
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
