Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2616B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 11:57:34 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so1963649pdj.33
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 08:57:33 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id bb9si6257307pbd.51.2014.06.19.08.57.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Jun 2014 08:57:33 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7F00DRKAZO9X80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Jun 2014 16:57:24 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] mm: slub: SLUB_DEBUG=n: use the same alloc/free hooks as for
 SLUB_DEBUG=y
Date: Thu, 19 Jun 2014 19:52:18 +0400
Message-id: <1403193138-7677-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ryabinin.a.a@gmail.com, Andrey Ryabinin <a.ryabinin@samsung.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>

There are two versions of alloc/free hooks now - one for CONFIG_SLUB_DEBUG=y
and another one for CONFIG_SLUB_DEBUG=n.

I see no reason why calls to other debugging subsystems (LOCKDEP,
DEBUG_ATOMIC_SLEEP, KMEMCHECK and FAILSLAB) are hidden under SLUB_DEBUG.
All this features should work regardless of SLUB_DEBUG config, as all of
them already have own Kconfig options.

This also fixes failslab for CONFIG_SLUB_DEBUG=n configuration.
It simply not worked before because should_failslab() call was in hook
hidden under "#ifdef CONFIG_SLUB_DEBUG #else".

Note: There is one concealed change in allocation path for SLUB_DEBUG=n and all
other debugging features disabled. might_sleep_if() call can generate some code
even if DEBUG_ATOMIC_SLEEP=n. For PREEMPT_VOLUNTARY=y migth_sleep() inserts
_cond_resched() call, but I think it should be ok.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slub.c | 97 ++++++++++++++++++++++++---------------------------------------
 1 file changed, 36 insertions(+), 61 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b2b0473..8f477c3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -945,60 +945,6 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 }
 
 /*
- * Hooks for other subsystems that check memory allocations. In a typical
- * production configuration these hooks all should produce no code at all.
- */
-static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
-{
-	kmemleak_alloc(ptr, size, 1, flags);
-}
-
-static inline void kfree_hook(const void *x)
-{
-	kmemleak_free(x);
-}
-
-static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
-{
-	flags &= gfp_allowed_mask;
-	lockdep_trace_alloc(flags);
-	might_sleep_if(flags & __GFP_WAIT);
-
-	return should_failslab(s->object_size, flags, s->flags);
-}
-
-static inline void slab_post_alloc_hook(struct kmem_cache *s,
-					gfp_t flags, void *object)
-{
-	flags &= gfp_allowed_mask;
-	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
-	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
-}
-
-static inline void slab_free_hook(struct kmem_cache *s, void *x)
-{
-	kmemleak_free_recursive(x, s->flags);
-
-	/*
-	 * Trouble is that we may no longer disable interrupts in the fast path
-	 * So in order to make the debug calls that expect irqs to be
-	 * disabled we need to disable interrupts temporarily.
-	 */
-#if defined(CONFIG_KMEMCHECK) || defined(CONFIG_LOCKDEP)
-	{
-		unsigned long flags;
-
-		local_irq_save(flags);
-		kmemcheck_slab_free(s, x, s->object_size);
-		debug_check_no_locks_freed(x, s->object_size);
-		local_irq_restore(flags);
-	}
-#endif
-	if (!(s->flags & SLAB_DEBUG_OBJECTS))
-		debug_check_no_obj_freed(x, s->object_size);
-}
-
-/*
  * Tracking of fully allocated slabs for debugging purposes.
  */
 static void add_full(struct kmem_cache *s,
@@ -1282,6 +1228,12 @@ static inline void inc_slabs_node(struct kmem_cache *s, int node,
 static inline void dec_slabs_node(struct kmem_cache *s, int node,
 							int objects) {}
 
+#endif /* CONFIG_SLUB_DEBUG */
+
+/*
+ * Hooks for other subsystems that check memory allocations. In a typical
+ * production configuration these hooks all should produce no code at all.
+ */
 static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
@@ -1293,22 +1245,45 @@ static inline void kfree_hook(const void *x)
 }
 
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
-							{ return 0; }
+{
+	flags &= gfp_allowed_mask;
+	lockdep_trace_alloc(flags);
+	might_sleep_if(flags & __GFP_WAIT);
+
+	return should_failslab(s->object_size, flags, s->flags);
+}
 
-static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
-		void *object)
+static inline void slab_post_alloc_hook(struct kmem_cache *s,
+					gfp_t flags, void *object)
 {
-	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags,
-		flags & gfp_allowed_mask);
+	flags &= gfp_allowed_mask;
+	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
+	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
 {
 	kmemleak_free_recursive(x, s->flags);
+
+	/*
+	 * Trouble is that we may no longer disable interrupts in the fast path
+	 * So in order to make the debug calls that expect irqs to be
+	 * disabled we need to disable interrupts temporarily.
+	 */
+#if defined(CONFIG_KMEMCHECK) || defined(CONFIG_LOCKDEP)
+	{
+		unsigned long flags;
+
+		local_irq_save(flags);
+		kmemcheck_slab_free(s, x, s->object_size);
+		debug_check_no_locks_freed(x, s->object_size);
+		local_irq_restore(flags);
+	}
+#endif
+	if (!(s->flags & SLAB_DEBUG_OBJECTS))
+		debug_check_no_obj_freed(x, s->object_size);
 }
 
-#endif /* CONFIG_SLUB_DEBUG */
-
 /*
  * Slab allocation and freeing
  */
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
