Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27D056B0276
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 10:05:17 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z189so69566777itg.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 07:05:17 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0128.outbound.protection.outlook.com. [157.55.234.128])
        by mx.google.com with ESMTPS id p36si3143972otb.220.2016.06.09.07.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 07:05:16 -0700 (PDT)
Subject: [PATCH] mm: mempool: kasan: don't poot mempool objects in quarantine
References: <1464785606-20349-1-git-send-email-glider@google.com>
 <574F0BB6.1040400@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <575977C3.1010905@virtuozzo.com>
Date: Thu, 9 Jun 2016 17:05:55 +0300
MIME-Version: 1.0
In-Reply-To: <574F0BB6.1040400@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/01/2016 07:22 PM, Andrey Ryabinin wrote:
> 
> 
> On 06/01/2016 03:53 PM, Alexander Potapenko wrote:
>> To avoid draining the mempools, KASAN shouldn't put the mempool elements
>> into the quarantine upon mempool_free().
> 
> Correct, but unfortunately this patch doesn't fix that.
> 

So, I made this:


From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm: mempool: kasan: don't poot mempool objects in quarantine

Currently we may put reserved by mempool elements into quarantine
via kasan_kfree(). This is totally wrong since quarantine may really
free these objects. So when mempool will try to use such element,
use-after-free will happen. Or mempool may decide that it no longer
need that element and double-free it.

So don't put object into quarantine in kasan_kfree(), just poison it.
Rename kasan_kfree() to kasan_poison_kfree() to respect that.

Also, we shouldn't use kasan_slab_alloc()/kasan_krealloc() in
kasan_unpoison_element() because those functions may update allocation
stacktrace. This would be wrong for the most of the remove_element
call sites.

(The only call site where we may want to update alloc stacktrace is
 in mempool_alloc(). Kmemleak solves this by calling
 kmemleak_update_trace(), so we could make something like that too.
 But this is out of scope of this patch).

Fixes: 55834c59098d ("mm: kasan: initial memory quarantine implementation")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reported-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
---
 include/linux/kasan.h | 11 +++++++----
 mm/kasan/kasan.c      |  6 +++---
 mm/mempool.c          | 12 ++++--------
 3 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 611927f..ac4b3c4 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -59,14 +59,13 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 
 void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(const void *ptr);
-void kasan_kfree(void *ptr);
+void kasan_poison_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
 bool kasan_slab_free(struct kmem_cache *s, void *object);
-void kasan_poison_slab_free(struct kmem_cache *s, void *object);
 
 struct kasan_cache {
 	int alloc_meta_offset;
@@ -76,6 +75,9 @@ struct kasan_cache {
 int kasan_module_alloc(void *addr, size_t size);
 void kasan_free_shadow(const struct vm_struct *vm);
 
+size_t ksize(const void *);
+static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
@@ -102,7 +104,7 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 
 static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
 static inline void kasan_kfree_large(const void *ptr) {}
-static inline void kasan_kfree(void *ptr) {}
+static inline void kasan_poison_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
 static inline void kasan_krealloc(const void *object, size_t new_size,
@@ -114,11 +116,12 @@ static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
 {
 	return false;
 }
-static inline void kasan_poison_slab_free(struct kmem_cache *s, void *object) {}
 
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
 static inline void kasan_free_shadow(const struct vm_struct *vm) {}
 
+static inline void kasan_unpoison_slab(const void *ptr) { }
+
 #endif /* CONFIG_KASAN */
 
 #endif /* LINUX_KASAN_H */
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 28439ac..6845f92 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -508,7 +508,7 @@ void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
-void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
+static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 {
 	unsigned long size = cache->object_size;
 	unsigned long rounded_up_size = round_up(size, KASAN_SHADOW_SCALE_SIZE);
@@ -626,7 +626,7 @@ void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 		kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
-void kasan_kfree(void *ptr)
+void kasan_poison_kfree(void *ptr)
 {
 	struct page *page;
 
@@ -636,7 +636,7 @@ void kasan_kfree(void *ptr)
 		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
 				KASAN_FREE_PAGE);
 	else
-		kasan_slab_free(page->slab_cache, ptr);
+		kasan_poison_slab_free(page->slab_cache, ptr);
 }
 
 void kasan_kfree_large(const void *ptr)
diff --git a/mm/mempool.c b/mm/mempool.c
index 9e075f8..8f65464 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -104,20 +104,16 @@ static inline void poison_element(mempool_t *pool, void *element)
 
 static void kasan_poison_element(mempool_t *pool, void *element)
 {
-	if (pool->alloc == mempool_alloc_slab)
-		kasan_poison_slab_free(pool->pool_data, element);
-	if (pool->alloc == mempool_kmalloc)
-		kasan_kfree(element);
+	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
+		kasan_poison_kfree(element);
 	if (pool->alloc == mempool_alloc_pages)
 		kasan_free_pages(element, (unsigned long)pool->pool_data);
 }
 
 static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
 {
-	if (pool->alloc == mempool_alloc_slab)
-		kasan_slab_alloc(pool->pool_data, element, flags);
-	if (pool->alloc == mempool_kmalloc)
-		kasan_krealloc(element, (size_t)pool->pool_data, flags);
+	if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
+		kasan_unpoison_slab(element);
 	if (pool->alloc == mempool_alloc_pages)
 		kasan_alloc_pages(element, (unsigned long)pool->pool_data);
 }
-- 
2.7.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
