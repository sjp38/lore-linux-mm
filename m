Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3972D6B003A
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:09:37 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so13669989pdb.13
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:09:36 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id df3si35325875pbc.99.2014.08.21.01.09.35
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:09:36 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/5] mm/sl[ao]b: always track caller in kmalloc_(node_)track_caller()
Date: Thu, 21 Aug 2014 17:09:19 +0900
Message-Id: <1408608562-20339-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we track caller if tracing or slab debugging is enabled. If they are
disabled, we could save one argument passing overhead by calling
__kmalloc(_node)(). But, I think that it would be marginal. Furthermore,
default slab allocator, SLUB, doesn't use this technique so I think
that it's okay to change this situation.

>From this change, we can turn on/off CONFIG_DEBUG_SLAB without full
kernel build and remove some complicated '#if' defintion. It looks
more benefitial to me.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab.h |   22 ----------------------
 mm/slab.c            |   18 ------------------
 mm/slob.c            |    2 --
 3 files changed, 42 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9062e4a..c265bec 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -549,37 +549,15 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
  * allocator where we care about the real place the memory allocation
  * request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
-	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING)) || \
-	(defined(CONFIG_SLOB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, _RET_IP_)
-#else
-#define kmalloc_track_caller(size, flags) \
-	__kmalloc(size, flags)
-#endif /* DEBUG_SLAB */
 
 #ifdef CONFIG_NUMA
-/*
- * kmalloc_node_track_caller is a special version of kmalloc_node that
- * records the calling function of the routine calling it for slab leak
- * tracking instead of just the calling function (confusing, eh?).
- * It's useful when the call to kmalloc_node comes from a widely-used
- * standard allocator where we care about the real place the memory
- * allocation request comes from.
- */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
-	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING)) || \
-	(defined(CONFIG_SLOB) && defined(CONFIG_TRACING))
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
 			_RET_IP_)
-#else
-#define kmalloc_node_track_caller(size, flags, node) \
-	__kmalloc_node(size, flags, node)
-#endif
 
 #else /* CONFIG_NUMA */
 
diff --git a/mm/slab.c b/mm/slab.c
index a467b30..d80b654 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3503,7 +3503,6 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 	return kmem_cache_alloc_node_trace(cachep, flags, node, size);
 }
 
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
 	return __do_kmalloc_node(size, flags, node, _RET_IP_);
@@ -3516,13 +3515,6 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t flags,
 	return __do_kmalloc_node(size, flags, node, caller);
 }
 EXPORT_SYMBOL(__kmalloc_node_track_caller);
-#else
-void *__kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return __do_kmalloc_node(size, flags, node, 0);
-}
-EXPORT_SYMBOL(__kmalloc_node);
-#endif /* CONFIG_DEBUG_SLAB || CONFIG_TRACING */
 #endif /* CONFIG_NUMA */
 
 /**
@@ -3548,8 +3540,6 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	return ret;
 }
 
-
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc(size_t size, gfp_t flags)
 {
 	return __do_kmalloc(size, flags, _RET_IP_);
@@ -3562,14 +3552,6 @@ void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
 }
 EXPORT_SYMBOL(__kmalloc_track_caller);
 
-#else
-void *__kmalloc(size_t size, gfp_t flags)
-{
-	return __do_kmalloc(size, flags, 0);
-}
-EXPORT_SYMBOL(__kmalloc);
-#endif
-
 /**
  * kmem_cache_free - Deallocate an object
  * @cachep: The cache the allocation was from.
diff --git a/mm/slob.c b/mm/slob.c
index 21980e0..96a8620 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -468,7 +468,6 @@ void *__kmalloc(size_t size, gfp_t gfp)
 }
 EXPORT_SYMBOL(__kmalloc);
 
-#ifdef CONFIG_TRACING
 void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
 {
 	return __do_kmalloc_node(size, gfp, NUMA_NO_NODE, caller);
@@ -481,7 +480,6 @@ void *__kmalloc_node_track_caller(size_t size, gfp_t gfp,
 	return __do_kmalloc_node(size, gfp, node, caller);
 }
 #endif
-#endif
 
 void kfree(const void *block)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
