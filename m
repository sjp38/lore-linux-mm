Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E09A8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:36:20 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id g3so8467093wmf.1
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:36:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 123sor4978218wml.1.2019.01.02.09.36.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 09:36:18 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 3/3] kasan: fix krealloc handling for tag-based mode
Date: Wed,  2 Jan 2019 18:36:08 +0100
Message-Id: <bc983dc45be2af41701ac3a88f154b5dd1459a26.1546450432.git.andreyknvl@google.com>
In-Reply-To: <cover.1546450432.git.andreyknvl@google.com>
References: <cover.1546450432.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Right now tag-based KASAN can retag the memory that is reallocated via
krealloc and return a differently tagged pointer even if the same slab
object gets used and no reallocated technically happens.

There are a few issues with this approach. One is that krealloc callers
can't rely on comparing the return value with the passed argument to
check whether reallocation happened. Another is that if a caller knows
that no reallocation happened, that it can access object memory through
the old pointer, which leads to false positives. Look at nf_ct_ext_add()
to see an example.

Fix this by keeping the same tag if the memory don't actually gets
reallocated during krealloc.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h | 14 +++++---------
 include/linux/slab.h  |  4 ++--
 mm/kasan/common.c     | 20 ++++++++++++--------
 mm/slab.c             |  8 ++++----
 mm/slab_common.c      |  2 +-
 mm/slub.c             | 10 +++++-----
 6 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index b40ea104dd36..7576fff90923 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -57,9 +57,8 @@ void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
 void kasan_kfree_large(void *ptr, unsigned long ip);
 void kasan_poison_kfree(void *ptr, unsigned long ip);
 void * __must_check kasan_kmalloc(struct kmem_cache *s, const void *object,
-					size_t size, gfp_t flags);
-void * __must_check kasan_krealloc(const void *object, size_t new_size,
-					gfp_t flags);
+				size_t size, gfp_t flags, bool krealloc);
+void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
 void * __must_check kasan_slab_alloc(struct kmem_cache *s, void *object,
 					gfp_t flags);
@@ -118,15 +117,12 @@ static inline void *kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags)
 static inline void kasan_kfree_large(void *ptr, unsigned long ip) {}
 static inline void kasan_poison_kfree(void *ptr, unsigned long ip) {}
 static inline void *kasan_kmalloc(struct kmem_cache *s, const void *object,
-				size_t size, gfp_t flags)
-{
-	return (void *)object;
-}
-static inline void *kasan_krealloc(const void *object, size_t new_size,
-				 gfp_t flags)
+				size_t size, gfp_t flags, bool krealloc)
 {
 	return (void *)object;
 }
+static inline void kasan_krealloc(const void *object, size_t new_size,
+				 gfp_t flags) {}
 
 static inline void *kasan_slab_alloc(struct kmem_cache *s, void *object,
 				   gfp_t flags)
diff --git a/include/linux/slab.h b/include/linux/slab.h
index d87f913ab4e8..1cd168758c05 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -445,7 +445,7 @@ static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
 {
 	void *ret = kmem_cache_alloc(s, flags);
 
-	ret = kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags, false);
 	return ret;
 }
 
@@ -456,7 +456,7 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 {
 	void *ret = kmem_cache_alloc_node(s, gfpflags, node);
 
-	ret = kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags, false);
 	return ret;
 }
 #endif /* CONFIG_TRACING */
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 44390392d4c9..b6633ab86160 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -392,7 +392,7 @@ void * __must_check kasan_init_slab_obj(struct kmem_cache *cache,
 void * __must_check kasan_slab_alloc(struct kmem_cache *cache, void *object,
 					gfp_t flags)
 {
-	return kasan_kmalloc(cache, object, cache->object_size, flags);
+	return kasan_kmalloc(cache, object, cache->object_size, flags, false);
 }
 
 static inline bool shadow_invalid(u8 tag, s8 shadow_byte)
@@ -451,7 +451,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 }
 
 void * __must_check kasan_kmalloc(struct kmem_cache *cache, const void *object,
-					size_t size, gfp_t flags)
+				size_t size, gfp_t flags, bool krealloc)
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
@@ -468,8 +468,12 @@ void * __must_check kasan_kmalloc(struct kmem_cache *cache, const void *object,
 	redzone_end = round_up((unsigned long)object + cache->object_size,
 				KASAN_SHADOW_SCALE_SIZE);
 
-	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
-		tag = assign_tag(cache, object, false);
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS)) {
+		if (krealloc)
+			tag = get_tag(object);
+		else
+			tag = assign_tag(cache, object, false);
+	}
 
 	/* Tag is ignored in set_tag without CONFIG_KASAN_SW_TAGS */
 	kasan_unpoison_shadow(set_tag(object, tag), size);
@@ -508,19 +512,19 @@ void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
 	return (void *)ptr;
 }
 
-void * __must_check kasan_krealloc(const void *object, size_t size, gfp_t flags)
+void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
 
 	if (unlikely(object == ZERO_SIZE_PTR))
-		return (void *)object;
+		return;
 
 	page = virt_to_head_page(object);
 
 	if (unlikely(!PageSlab(page)))
-		return kasan_kmalloc_large(object, size, flags);
+		kasan_kmalloc_large(object, size, flags);
 	else
-		return kasan_kmalloc(page->slab_cache, object, size, flags);
+		kasan_kmalloc(page->slab_cache, object, size, flags, true);
 }
 
 void kasan_poison_kfree(void *ptr, unsigned long ip)
diff --git a/mm/slab.c b/mm/slab.c
index 73fe23e649c9..09b54386cf67 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3604,7 +3604,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 
 	ret = slab_alloc(cachep, flags, _RET_IP_);
 
-	ret = kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags, false);
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
 	return ret;
@@ -3647,7 +3647,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 
 	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
-	ret = kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags, false);
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3668,7 +3668,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
 	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
-	ret = kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags, false);
 
 	return ret;
 }
@@ -3706,7 +3706,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 		return cachep;
 	ret = slab_alloc(cachep, flags, caller);
 
-	ret = kasan_kmalloc(cachep, ret, size, flags);
+	ret = kasan_kmalloc(cachep, ret, size, flags, false);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d05e74a..b55c58178f83 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1507,7 +1507,7 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 		ks = ksize(p);
 
 	if (ks >= new_size) {
-		p = kasan_krealloc((void *)p, new_size, flags);
+		kasan_krealloc((void *)p, new_size, flags);
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..20aa0547acbf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2763,7 +2763,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	ret = kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags, false);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2791,7 +2791,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
 
-	ret = kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags, false);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3364,7 +3364,7 @@ static void early_kmem_cache_node_alloc(int node)
 	init_tracking(kmem_cache_node, n);
 #endif
 	n = kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
-		      GFP_KERNEL);
+		      GFP_KERNEL, false);
 	page->freelist = get_freepointer(kmem_cache_node, n);
 	page->inuse = 1;
 	page->frozen = 0;
@@ -3779,7 +3779,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
-	ret = kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags, false);
 
 	return ret;
 }
@@ -3823,7 +3823,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
-	ret = kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags, false);
 
 	return ret;
 }
-- 
2.20.1.415.g653613c723-goog
