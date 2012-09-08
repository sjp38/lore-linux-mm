Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 59FA06B00A4
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 16:50:13 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so272821yhj.8
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 13:50:12 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 06/10] mm, slab: Replace 'caller' type, void* -> unsigned long
Date: Sat,  8 Sep 2012 17:47:55 -0300
Message-Id: <1347137279-17568-6-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>

This allows to use _RET_IP_ instead of builtin_address(0), thus
achiveing implementation consistency in all three allocators.
Though maybe a nitpick, the real goal behind this patch is
to be able to obtain common code between SLAB and SLUB.

Cc: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slab.c |   50 ++++++++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 53e41de..bc342d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3083,7 +3083,7 @@ static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 }
 
 static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
-				   void *caller)
+				   unsigned long caller)
 {
 	struct page *page;
 	unsigned int objnr;
@@ -3103,7 +3103,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 		*dbg_redzone2(cachep, objp) = RED_INACTIVE;
 	}
 	if (cachep->flags & SLAB_STORE_USER)
-		*dbg_userword(cachep, objp) = caller;
+		*dbg_userword(cachep, objp) = (void *)caller;
 
 	objnr = obj_to_index(cachep, slabp, objp);
 
@@ -3116,7 +3116,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		if ((cachep->size % PAGE_SIZE)==0 && OFF_SLAB(cachep)) {
-			store_stackinfo(cachep, objp, (unsigned long)caller);
+			store_stackinfo(cachep, objp, caller);
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->size / PAGE_SIZE, 0);
 		} else {
@@ -3269,7 +3269,7 @@ static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
 
 #if DEBUG
 static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
-				gfp_t flags, void *objp, void *caller)
+				gfp_t flags, void *objp, unsigned long caller)
 {
 	if (!objp)
 		return objp;
@@ -3286,7 +3286,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		poison_obj(cachep, objp, POISON_INUSE);
 	}
 	if (cachep->flags & SLAB_STORE_USER)
-		*dbg_userword(cachep, objp) = caller;
+		*dbg_userword(cachep, objp) = (void *)caller;
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
@@ -3561,7 +3561,7 @@ done:
  */
 static __always_inline void *
 __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
-		   void *caller)
+		   unsigned long caller)
 {
 	unsigned long save_flags;
 	void *ptr;
@@ -3647,7 +3647,7 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 #endif /* CONFIG_NUMA */
 
 static __always_inline void *
-__cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
+__cache_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 {
 	unsigned long save_flags;
 	void *objp;
@@ -3783,7 +3783,7 @@ free_done:
  * be in this state _before_ it is released.  Called with disabled ints.
  */
 static inline void __cache_free(struct kmem_cache *cachep, void *objp,
-    void *caller)
+				unsigned long caller)
 {
 	struct array_cache *ac = cpu_cache_get(cachep);
 
@@ -3823,7 +3823,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
+	void *ret = __cache_alloc(cachep, flags, _RET_IP_);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3838,7 +3838,7 @@ kmem_cache_alloc_trace(size_t size, struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret;
 
-	ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
+	ret = __cache_alloc(cachep, flags, _RET_IP_);
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
@@ -3850,8 +3850,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
-	void *ret = __cache_alloc_node(cachep, flags, nodeid,
-				       __builtin_return_address(0));
+	void *ret = __cache_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
@@ -3869,8 +3868,8 @@ void *kmem_cache_alloc_node_trace(size_t size,
 {
 	void *ret;
 
-	ret = __cache_alloc_node(cachep, flags, nodeid,
-				  __builtin_return_address(0));
+	ret = __cache_alloc_node(cachep, flags, nodeid, _RET_IP);
+
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3880,7 +3879,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 
 static __always_inline void *
-__do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
+__do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 {
 	struct kmem_cache *cachep;
 
@@ -3893,21 +3892,20 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
-	return __do_kmalloc_node(size, flags, node,
-			__builtin_return_address(0));
+	return __do_kmalloc_node(size, flags, node, _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc_node);
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t flags,
 		int node, unsigned long caller)
 {
-	return __do_kmalloc_node(size, flags, node, (void *)caller);
+	return __do_kmalloc_node(size, flags, node, caller);
 }
 EXPORT_SYMBOL(__kmalloc_node_track_caller);
 #else
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
-	return __do_kmalloc_node(size, flags, node, NULL);
+	return __do_kmalloc_node(size, flags, node, 0);
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif /* CONFIG_DEBUG_SLAB || CONFIG_TRACING */
@@ -3920,7 +3918,7 @@ EXPORT_SYMBOL(__kmalloc_node);
  * @caller: function caller for debug tracking of the caller
  */
 static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
-					  void *caller)
+					  unsigned long caller)
 {
 	struct kmem_cache *cachep;
 	void *ret;
@@ -3935,7 +3933,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 		return cachep;
 	ret = __cache_alloc(cachep, flags, caller);
 
-	trace_kmalloc((unsigned long) caller, ret,
+	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
 	return ret;
@@ -3945,20 +3943,20 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
 void *__kmalloc(size_t size, gfp_t flags)
 {
-	return __do_kmalloc(size, flags, __builtin_return_address(0));
+	return __do_kmalloc(size, flags, _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc);
 
 void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
 {
-	return __do_kmalloc(size, flags, (void *)caller);
+	return __do_kmalloc(size, flags, caller);
 }
 EXPORT_SYMBOL(__kmalloc_track_caller);
 
 #else
 void *__kmalloc(size_t size, gfp_t flags)
 {
-	return __do_kmalloc(size, flags, NULL);
+	return __do_kmalloc(size, flags, 0);
 }
 EXPORT_SYMBOL(__kmalloc);
 #endif
@@ -3979,7 +3977,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 	debug_check_no_locks_freed(objp, cachep->object_size);
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(objp, cachep->object_size);
-	__cache_free(cachep, objp, __builtin_return_address(0));
+	__cache_free(cachep, objp, _RET_IP_);
 	local_irq_restore(flags);
 
 	trace_kmem_cache_free(_RET_IP_, objp);
@@ -4010,7 +4008,7 @@ void kfree(const void *objp)
 	debug_check_no_locks_freed(objp, c->object_size);
 
 	debug_check_no_obj_freed(objp, c->object_size);
-	__cache_free(c, (void *)objp, __builtin_return_address(0));
+	__cache_free(c, (void *)objp, _RET_IP_);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(kfree);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
