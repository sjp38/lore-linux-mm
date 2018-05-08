Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 783EC6B02BE
	for <linux-mm@kvack.org>; Tue,  8 May 2018 13:21:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o16-v6so21489021wri.8
        for <linux-mm@kvack.org>; Tue, 08 May 2018 10:21:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8-v6sor9453341wrb.18.2018.05.08.10.21.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 10:21:13 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v1 01/16] khwasan, mm: change kasan hooks signatures
Date: Tue,  8 May 2018 19:20:47 +0200
Message-Id: <427db6b29eaf61d77cb485e9e0a393d34741e498.1525798753.git.andreyknvl@google.com>
In-Reply-To: <cover.1525798753.git.andreyknvl@google.com>
References: <cover.1525798753.git.andreyknvl@google.com>
In-Reply-To: <cover.1525798753.git.andreyknvl@google.com>
References: <cover.1525798753.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

KHWASAN will change the value of the top byte of pointers returned from the
kernel allocation functions (such as kmalloc). This patch updates KASAN
hooks signatures and their usage in SLAB and SLUB code to reflect that.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h | 34 +++++++++++++++++++++++-----------
 mm/kasan/kasan.c      | 24 ++++++++++++++----------
 mm/slab.c             | 12 ++++++------
 mm/slab.h             |  2 +-
 mm/slab_common.c      |  4 ++--
 mm/slub.c             | 16 ++++++++--------
 6 files changed, 54 insertions(+), 38 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index de784fd11d12..cbdc54543803 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -53,14 +53,14 @@ void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
 
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
@@ -105,16 +105,28 @@ static inline void kasan_poison_object_data(struct kmem_cache *cache,
 static inline void kasan_init_slab_obj(struct kmem_cache *cache,
 				const void *object) {}
 
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
index bc0e68f7dc75..2f5e52d72c2b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -485,9 +485,9 @@ void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
 	__memset(alloc_info, 0, sizeof(*alloc_info));
 }
 
-void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
+void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
-	kasan_kmalloc(cache, object, cache->object_size, flags);
+	return kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
 static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
@@ -528,7 +528,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
 	return __kasan_slab_free(cache, object, ip, true);
 }
 
-void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
+void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		   gfp_t flags)
 {
 	unsigned long redzone_start;
@@ -538,7 +538,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 		quarantine_reduce();
 
 	if (unlikely(object == NULL))
-		return;
+		return NULL;
 
 	redzone_start = round_up((unsigned long)(object + size),
 				KASAN_SHADOW_SCALE_SIZE);
@@ -551,10 +551,12 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 
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
@@ -564,7 +566,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 		quarantine_reduce();
 
 	if (unlikely(ptr == NULL))
-		return;
+		return NULL;
 
 	page = virt_to_page(ptr);
 	redzone_start = round_up((unsigned long)(ptr + size),
@@ -574,21 +576,23 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
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
index 2f308253c3d7..5f2aeeb18d3c 100644
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
index 68bdf498da3b..15ef6a0d9c16 100644
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
index 98dcdc352062..0582004351c4 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1148,7 +1148,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
-	kasan_kmalloc_large(ret, size, flags);
+	ret = kasan_kmalloc_large(ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -1426,7 +1426,7 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 		ks = ksize(p);
 
 	if (ks >= new_size) {
-		kasan_krealloc((void *)p, new_size, flags);
+		p = kasan_krealloc((void *)p, new_size, flags);
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index 44aa7847324a..4fcd1442a761 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1351,10 +1351,10 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
  */
-static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
+static inline void kmalloc_large_node_hook(void **ptr, size_t size, gfp_t flags)
 {
-	kmemleak_alloc(ptr, size, 1, flags);
-	kasan_kmalloc_large(ptr, size, flags);
+	kmemleak_alloc(*ptr, size, 1, flags);
+	*ptr = kasan_kmalloc_large(*ptr, size, flags);
 }
 
 static __always_inline void kfree_hook(void *x)
@@ -2765,7 +2765,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2793,7 +2793,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
 
-	kasan_kmalloc(s, ret, size, gfpflags);
+	ret = kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3786,7 +3786,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
-	kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3803,7 +3803,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	if (page)
 		ptr = page_address(page);
 
-	kmalloc_large_node_hook(ptr, size, flags);
+	kmalloc_large_node_hook(&ptr, size, flags);
 	return ptr;
 }
 
@@ -3831,7 +3831,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
-	kasan_kmalloc(s, ret, size, flags);
+	ret = kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
-- 
2.17.0.441.gb46fe60e1d-goog
