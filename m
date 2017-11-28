Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 635C36B02A3
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b77so13479006pfl.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u12sor1618874plz.10.2017.11.27.23.50.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:11 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 15/18] mm/vchecker: pass allocation caller address to vchecker hook
Date: Tue, 28 Nov 2017 16:48:50 +0900
Message-Id: <1511855333-3570-16-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Vchecker requires kmalloc caller address to support validation on
*specific* kmalloc user. Therefore, this patch passes slab allocation
caller address to vchecker hook. This caller address will be used in the
following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab.h |  2 ++
 mm/kasan/kasan.c     |  1 -
 mm/kasan/vchecker.c  |  3 ++-
 mm/kasan/vchecker.h  |  5 +++--
 mm/slab.c            | 14 ++++++++++----
 mm/slab.h            |  4 +++-
 mm/slab_common.c     |  6 ++++++
 mm/slub.c            | 11 ++++++++---
 8 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index f6efbbe..25a74f3c 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -421,6 +421,7 @@ static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
 	void *ret = kmem_cache_alloc(s, flags);
 
 	kasan_kmalloc(s, ret, size, flags);
+	vchecker_kmalloc(s, ret, size, _THIS_IP_);
 	return ret;
 }
 
@@ -432,6 +433,7 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	void *ret = kmem_cache_alloc_node(s, gfpflags, node);
 
 	kasan_kmalloc(s, ret, size, gfpflags);
+	vchecker_kmalloc(s, ret, size, _THIS_IP_);
 	return ret;
 }
 #endif /* CONFIG_TRACING */
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 984e423..8634e43 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -552,7 +552,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
-	vchecker_kmalloc(cache, object, size);
 
 	if (cache->flags & SLAB_KASAN)
 		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 4d140e7..918f05a 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -144,7 +144,8 @@ void vchecker_cache_create(struct kmem_cache *s,
 	*size += sizeof(struct vchecker_data);
 }
 
-void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size)
+void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size,
+			unsigned long ret_ip)
 {
 	struct vchecker *checker;
 	struct vchecker_cb *cb;
diff --git a/mm/kasan/vchecker.h b/mm/kasan/vchecker.h
index efebc63..ab5a6f6 100644
--- a/mm/kasan/vchecker.h
+++ b/mm/kasan/vchecker.h
@@ -12,7 +12,8 @@ struct vchecker_cache {
 
 
 #ifdef CONFIG_VCHECKER
-void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size);
+void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size,
+			unsigned long ret_ip);
 bool vchecker_check(unsigned long addr, size_t size,
 			bool write, unsigned long ret_ip);
 int init_vchecker(struct kmem_cache *s);
@@ -26,7 +27,7 @@ void vchecker_enable_obj(struct kmem_cache *s, const void *object,
 
 #else
 static inline void vchecker_kmalloc(struct kmem_cache *s,
-	const void *object, size_t size) { }
+	const void *object, size_t size, unsigned long ret_ip) { }
 static inline bool vchecker_check(unsigned long addr, size_t size,
 			bool write, unsigned long ret_ip) { return false; }
 static inline int init_vchecker(struct kmem_cache *s) { return 0; }
diff --git a/mm/slab.c b/mm/slab.c
index 64d768b..f6b1adf 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3359,7 +3359,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	if (unlikely(flags & __GFP_ZERO) && ptr)
 		memset(ptr, 0, cachep->object_size);
 
-	slab_post_alloc_hook(cachep, flags, 1, &ptr);
+	slab_post_alloc_hook(cachep, flags, 1, &ptr, caller);
 	return ptr;
 }
 
@@ -3416,7 +3416,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	if (unlikely(flags & __GFP_ZERO) && objp)
 		memset(objp, 0, cachep->object_size);
 
-	slab_post_alloc_hook(cachep, flags, 1, &objp);
+	slab_post_alloc_hook(cachep, flags, 1, &objp, caller);
 	return objp;
 }
 
@@ -3579,6 +3579,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 
 	kasan_slab_alloc(cachep, ret, flags);
+	vchecker_kmalloc(cachep, ret, cachep->object_size, _RET_IP_);
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
 
@@ -3624,13 +3625,13 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 		for (i = 0; i < size; i++)
 			memset(p[i], 0, s->object_size);
 
-	slab_post_alloc_hook(s, flags, size, p);
+	slab_post_alloc_hook(s, flags, size, p, _RET_IP_);
 	/* FIXME: Trace call missing. Christoph would like a bulk variant */
 	return size;
 error:
 	local_irq_enable();
 	cache_alloc_debugcheck_after_bulk(s, flags, i, p, _RET_IP_);
-	slab_post_alloc_hook(s, flags, i, p);
+	slab_post_alloc_hook(s, flags, i, p, _RET_IP_);
 	__kmem_cache_free_bulk(s, i, p);
 	return 0;
 }
@@ -3645,6 +3646,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 	ret = slab_alloc(cachep, flags, _RET_IP_);
 
 	kasan_kmalloc(cachep, ret, size, flags);
+	vchecker_kmalloc(cachep, ret, size, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
 	return ret;
@@ -3669,6 +3671,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	kasan_slab_alloc(cachep, ret, flags);
+	vchecker_kmalloc(cachep, ret, cachep->object_size, _RET_IP_);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
@@ -3688,6 +3691,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	kasan_kmalloc(cachep, ret, size, flags);
+	vchecker_kmalloc(cachep, ret, size, _RET_IP_);
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3707,6 +3711,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 		return cachep;
 	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
 	kasan_kmalloc(cachep, ret, size, flags);
+	vchecker_kmalloc(cachep, ret, size, _RET_IP_);
 
 	return ret;
 }
@@ -3743,6 +3748,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	ret = slab_alloc(cachep, flags, caller);
 
 	kasan_kmalloc(cachep, ret, size, flags);
+	vchecker_kmalloc(cachep, ret, size, _RET_IP_);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
diff --git a/mm/slab.h b/mm/slab.h
index c1cf486..9fce8ab 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -435,7 +435,8 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 }
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
-					size_t size, void **p)
+					size_t size, void **p,
+					unsigned long caller)
 {
 	size_t i;
 
@@ -446,6 +447,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 		kmemleak_alloc_recursive(object, s->object_size, 1,
 					 s->flags, flags);
 		kasan_slab_alloc(s, object, flags);
+		vchecker_kmalloc(s, object, s->object_size, caller);
 	}
 
 	if (memcg_kmem_enabled())
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6f700f3..ffc7515 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1446,12 +1446,18 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 {
 	void *ret;
 	size_t ks = 0;
+	struct page *page;
 
 	if (p)
 		ks = ksize(p);
 
 	if (ks >= new_size) {
 		kasan_krealloc((void *)p, new_size, flags);
+		page = virt_to_head_page(p);
+		if (PageSlab(page)) {
+			vchecker_kmalloc(page->slab_cache, p,
+					new_size, _RET_IP_);
+		}
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index c099b33..d37f023 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2755,7 +2755,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->object_size);
 
-	slab_post_alloc_hook(s, gfpflags, 1, &object);
+	slab_post_alloc_hook(s, gfpflags, 1, &object, addr);
 
 	return object;
 }
@@ -2783,6 +2783,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
 	kasan_kmalloc(s, ret, size, gfpflags);
+	vchecker_kmalloc(s, ret, size, _RET_IP_);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2811,6 +2812,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			   size, s->size, gfpflags, node);
 
 	kasan_kmalloc(s, ret, size, gfpflags);
+	vchecker_kmalloc(s, ret, size, _RET_IP_);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3184,11 +3186,11 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	}
 
 	/* memcg and kmem_cache debug support */
-	slab_post_alloc_hook(s, flags, size, p);
+	slab_post_alloc_hook(s, flags, size, p, _RET_IP_);
 	return i;
 error:
 	local_irq_enable();
-	slab_post_alloc_hook(s, flags, i, p);
+	slab_post_alloc_hook(s, flags, i, p, _RET_IP_);
 	__kmem_cache_free_bulk(s, i, p);
 	return 0;
 }
@@ -3388,6 +3390,7 @@ static void early_kmem_cache_node_alloc(int node)
 #endif
 	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
 		      GFP_KERNEL);
+	vchecker_kmalloc(kmem_cache_node, n, sizeof(*n), _RET_IP_);
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
@@ -3794,6 +3797,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
 	kasan_kmalloc(s, ret, size, flags);
+	vchecker_kmalloc(s, ret, size, _RET_IP_);
 
 	return ret;
 }
@@ -3839,6 +3843,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
 	kasan_kmalloc(s, ret, size, flags);
+	vchecker_kmalloc(s, ret, size, _RET_IP_);
 
 	return ret;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
