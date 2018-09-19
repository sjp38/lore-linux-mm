Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82E4B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:55:07 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t16so179032wrx.2
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:55:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3-v6sor16409027wrw.12.2018.09.19.11.55.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 11:55:05 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v8 01/20] kasan, mm: change hooks signatures
Date: Wed, 19 Sep 2018 20:54:40 +0200
Message-Id: <8b30f2d3e325de843f892e32f076fe9cc726191d.1537383101.git.andreyknvl@google.com>
In-Reply-To: <cover.1537383101.git.andreyknvl@google.com>
References: <cover.1537383101.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Tag-based KASAN changes the value of the top byte of pointers returned
from the kernel allocation functions (such as kmalloc). This patch updates
KASAN hooks signatures and their usage in SLAB and SLUB code to reflect
that.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h | 43 +++++++++++++++++++++++++++++--------------
 mm/kasan/kasan.c      | 30 ++++++++++++++++++------------
 mm/slab.c             | 12 ++++++------
 mm/slab.h             |  2 +-
 mm/slab_common.c      |  4 ++--
 mm/slub.c             | 15 +++++++--------
 6 files changed, 63 insertions(+), 43 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 46aae129917c..3b019db87892 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -51,16 +51,16 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
-void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
+void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
-void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
+void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(void *ptr, unsigned long ip);
 void kasan_poison_kfree(void *ptr, unsigned long ip);
-void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
+void *kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
-void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
+void *kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
-void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
+void *kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
 bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long ip);
 
 struct kasan_cache {
@@ -105,19 +105,34 @@ static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
 					void *object) {}
 static inline void kasan_poison_object_data(struct kmem_cache *cache,
 					void *object) {}
-static inline void kasan_init_slab_obj(struct kmem_cache *cache,
-				const void *object) {}
+static inline void *kasan_init_slab_obj(struct kmem_cache *cache,
+				const void *object)
+{
+	return ptr;
+}
 
-static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
+static inline void *kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags)
+{
+	return ptr;
+}
 static inline void kasan_kfree_large(void *ptr, unsigned long ip) {}
 static inline void kasan_poison_kfree(void *ptr, unsigned long ip) {}
-static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
-				size_t size, gfp_t flags) {}
-static inline void kasan_krealloc(const void *object, size_t new_size,
-				 gfp_t flags) {}
+static inline void *kasan_kmalloc(struct kmem_cache *s, const void *object,
+				size_t size, gfp_t flags)
+{
+	return (void *)object;
+}
+static inline void *kasan_krealloc(const void *object, size_t new_size,
+				 gfp_t flags)
+{
+	return (void *)object;
+}
 
-static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
-				   gfp_t flags) {}
+static inline void *kasan_slab_alloc(struct kmem_cache *s, void *object,
+				   gfp_t flags)
+{
+	return object;
+}
 static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
 				   unsigned long ip)
 {
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index c3bd5209da38..55deff17a4d9 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -474,20 +474,22 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
 
-void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
+void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
 {
 	struct kasan_alloc_meta *alloc_info;
 
 	if (!(cache->flags & SLAB_KASAN))
-		return;
+		return (void *)object;
 
 	alloc_info = get_alloc_info(cache, object);
 	__memset(alloc_info, 0, sizeof(*alloc_info));
+
+	return (void *)object;
 }
 
-void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
+void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
-	kasan_kmalloc(cache, object, cache->object_size, flags);
+	return kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
 static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
@@ -528,7 +530,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 	return __kasan_slab_free(cache, object, ip, true);
 }
 
-void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
+void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		   gfp_t flags)
 {
 	unsigned long redzone_start;
@@ -538,7 +540,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		quarantine_reduce();
 
 	if (unlikely(object == NULL))
-		return;
+		return NULL;
 
 	redzone_start = round_up((unsigned long)(object + size),
 				KASAN_SHADOW_SCALE_SIZE);
@@ -551,10 +553,12 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 
 	if (cache->flags & SLAB_KASAN)
 		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
+
+	return (void *)object;
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
+void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 {
 	struct page *page;
 	unsigned long redzone_start;
@@ -564,7 +568,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 		quarantine_reduce();
 
 	if (unlikely(ptr == NULL))
-		return;
+		return NULL;
 
 	page = virt_to_page(ptr);
 	redzone_start = round_up((unsigned long)(ptr + size),
@@ -574,21 +578,23 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	kasan_unpoison_shadow(ptr, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_PAGE_REDZONE);
+
+	return (void *)ptr;
 }
 
-void kasan_krealloc(const void *object, size_t size, gfp_t flags)
+void *kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
 
 	if (unlikely(object == ZERO_SIZE_PTR))
-		return;
+		return ZERO_SIZE_PTR;
 
 	page = virt_to_head_page(object);
 
 	if (unlikely(!PageSlab(page)))
-		kasan_kmalloc_large(object, size, flags);
+		return kasan_kmalloc_large(object, size, flags);
 	else
-		kasan_kmalloc(page->slab_cache, object, size, flags);
+		return kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
 void kasan_poison_kfree(void *ptr, unsigned long ip)
diff --git a/mm/slab.c b/mm/slab.c
index aa76a70e087e..6fdca9ec2ea4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3551,7 +3551,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 
-	kasan_slab_alloc(cachep, ret, flags);
+	ret = kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
 
@@ -3617,7 +3617,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 
 	ret = slab_alloc(cachep, flags, _RET_IP_);
 
-	kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
 	return ret;
@@ -3641,7 +3641,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
-	kasan_slab_alloc(cachep, ret, flags);
+	ret = kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
@@ -3660,7 +3660,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 
 	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
-	kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3679,7 +3679,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
 	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
-	kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags);
 
 	return ret;
 }
@@ -3715,7 +3715,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 		return cachep;
 	ret = slab_alloc(cachep, flags, caller);
 
-	kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
diff --git a/mm/slab.h b/mm/slab.h
index 58c6c1c2a78e..4190c24ef0e9 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -441,7 +441,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 
 		kmemleak_alloc_recursive(object, s->object_size, 1,
 					 s->flags, flags);
-		kasan_slab_alloc(s, object, flags);
+		p[i] = kasan_slab_alloc(s, object, flags);
 	}
 
 	if (memcg_kmem_enabled())
diff --git a/mm/slab_common.c b/mm/slab_common.c
index fea3376f9816..3abfa0f86118 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1183,7 +1183,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
-	kasan_kmalloc_large(ret, size, flags);
+	ret = kasan_kmalloc_large(ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -1461,7 +1461,7 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 		ks = ksize(p);
 
 	if (ks >= new_size) {
-		kasan_krealloc((void *)p, new_size, flags);
+		p = kasan_krealloc((void *)p, new_size, flags);
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index 8da34a8af53d..b2172284d421 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1334,10 +1334,10 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
  */
-static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
+static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
-	kasan_kmalloc_large(ptr, size, flags);
+	return kasan_kmalloc_large(ptr, size, flags);
 }
 
 static __always_inline void kfree_hook(void *x)
@@ -2730,7 +2730,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2758,7 +2758,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
 
-	kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3748,7 +3748,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
-	kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3765,8 +3765,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	if (page)
 		ptr = page_address(page);
 
-	kmalloc_large_node_hook(ptr, size, flags);
-	return ptr;
+	return kmalloc_large_node_hook(ptr, size, flags);
 }
 
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
@@ -3793,7 +3792,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
-	kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
-- 
2.19.0.397.gdd90340f6a-goog
