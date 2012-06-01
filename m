Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7D5E46B0069
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:53:05 -0400 (EDT)
Message-Id: <20120601195303.550968150@linux.com>
Date: Fri, 01 Jun 2012 14:52:52 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [07/20] [slab] Get rid of obj_size macro
References: <20120601195245.084749371@linux.com>
Content-Disposition: inline; filename=get_rid_of_obj_size
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

The size of the slab object is frequently needed. Since we now
have a size field directly in the kmem_cache structure there is no
need anymore of the obj_size macro/function.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slab.c |   47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-06-01 07:33:29.606676062 -0500
+++ linux-2.6/mm/slab.c	2012-06-01 07:42:48.146664594 -0500
@@ -433,11 +433,6 @@ static int obj_offset(struct kmem_cache
 	return cachep->obj_offset;
 }
 
-static int obj_size(struct kmem_cache *cachep)
-{
-	return cachep->object_size;
-}
-
 static unsigned long long *dbg_redzone1(struct kmem_cache *cachep, void *objp)
 {
 	BUG_ON(!(cachep->flags & SLAB_RED_ZONE));
@@ -465,7 +460,6 @@ static void **dbg_userword(struct kmem_c
 #else
 
 #define obj_offset(x)			0
-#define obj_size(cachep)		(cachep->size)
 #define dbg_redzone1(cachep, objp)	({BUG(); (unsigned long long *)NULL;})
 #define dbg_redzone2(cachep, objp)	({BUG(); (unsigned long long *)NULL;})
 #define dbg_userword(cachep, objp)	({BUG(); (void **)NULL;})
@@ -1853,7 +1847,7 @@ static void kmem_rcu_free(struct rcu_hea
 static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
 			    unsigned long caller)
 {
-	int size = obj_size(cachep);
+	int size = cachep->object_size;
 
 	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
 
@@ -1885,7 +1879,7 @@ static void store_stackinfo(struct kmem_
 
 static void poison_obj(struct kmem_cache *cachep, void *addr, unsigned char val)
 {
-	int size = obj_size(cachep);
+	int size = cachep->object_size;
 	addr = &((char *)addr)[obj_offset(cachep)];
 
 	memset(addr, val, size);
@@ -1945,7 +1939,7 @@ static void print_objinfo(struct kmem_ca
 		printk("\n");
 	}
 	realobj = (char *)objp + obj_offset(cachep);
-	size = obj_size(cachep);
+	size = cachep->object_size;
 	for (i = 0; i < size && lines; i += 16, lines--) {
 		int limit;
 		limit = 16;
@@ -1962,7 +1956,7 @@ static void check_poison_obj(struct kmem
 	int lines = 0;
 
 	realobj = (char *)objp + obj_offset(cachep);
-	size = obj_size(cachep);
+	size = cachep->object_size;
 
 	for (i = 0; i < size; i++) {
 		char exp = POISON_FREE;
@@ -3265,7 +3259,7 @@ static bool slab_should_failslab(struct
 	if (cachep == &cache_cache)
 		return false;
 
-	return should_failslab(obj_size(cachep), flags, cachep->flags);
+	return should_failslab(cachep->object_size, flags, cachep->flags);
 }
 
 static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
@@ -3525,14 +3519,14 @@ __cache_alloc_node(struct kmem_cache *ca
   out:
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
-	kmemleak_alloc_recursive(ptr, obj_size(cachep), 1, cachep->flags,
+	kmemleak_alloc_recursive(ptr, cachep->object_size, 1, cachep->flags,
 				 flags);
 
 	if (likely(ptr))
-		kmemcheck_slab_alloc(cachep, flags, ptr, obj_size(cachep));
+		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
 
 	if (unlikely((flags & __GFP_ZERO) && ptr))
-		memset(ptr, 0, obj_size(cachep));
+		memset(ptr, 0, cachep->object_size);
 
 	return ptr;
 }
@@ -3587,15 +3581,15 @@ __cache_alloc(struct kmem_cache *cachep,
 	objp = __do_cache_alloc(cachep, flags);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
-	kmemleak_alloc_recursive(objp, obj_size(cachep), 1, cachep->flags,
+	kmemleak_alloc_recursive(objp, cachep->object_size, 1, cachep->flags,
 				 flags);
 	prefetchw(objp);
 
 	if (likely(objp))
-		kmemcheck_slab_alloc(cachep, flags, objp, obj_size(cachep));
+		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
 
 	if (unlikely((flags & __GFP_ZERO) && objp))
-		memset(objp, 0, obj_size(cachep));
+		memset(objp, 0, cachep->object_size);
 
 	return objp;
 }
@@ -3711,7 +3705,7 @@ static inline void __cache_free(struct k
 	kmemleak_free_recursive(objp, cachep->flags);
 	objp = cache_free_debugcheck(cachep, objp, caller);
 
-	kmemcheck_slab_free(cachep, objp, obj_size(cachep));
+	kmemcheck_slab_free(cachep, objp, cachep->object_size);
 
 	/*
 	 * Skip calling cache_free_alien() when the platform is not numa.
@@ -3746,7 +3740,7 @@ void *kmem_cache_alloc(struct kmem_cache
 	void *ret = __cache_alloc(cachep, flags, __builtin_return_address(0));
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
-			       obj_size(cachep), cachep->size, flags);
+			       cachep->object_size, cachep->size, flags);
 
 	return ret;
 }
@@ -3774,7 +3768,7 @@ void *kmem_cache_alloc_node(struct kmem_
 				       __builtin_return_address(0));
 
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
-				    obj_size(cachep), cachep->size,
+				    cachep->object_size, cachep->size,
 				    flags, nodeid);
 
 	return ret;
@@ -3896,9 +3890,9 @@ void kmem_cache_free(struct kmem_cache *
 	unsigned long flags;
 
 	local_irq_save(flags);
-	debug_check_no_locks_freed(objp, obj_size(cachep));
+	debug_check_no_locks_freed(objp, cachep->size);
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
-		debug_check_no_obj_freed(objp, obj_size(cachep));
+		debug_check_no_obj_freed(objp, cachep->object_size);
 	__cache_free(cachep, objp, __builtin_return_address(0));
 	local_irq_restore(flags);
 
@@ -3927,8 +3921,9 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
-	debug_check_no_locks_freed(objp, obj_size(c));
-	debug_check_no_obj_freed(objp, obj_size(c));
+	debug_check_no_locks_freed(objp, c->object_size);
+
+	debug_check_no_obj_freed(objp, c->object_size);
 	__cache_free(c, (void *)objp, __builtin_return_address(0));
 	local_irq_restore(flags);
 }
@@ -3936,7 +3931,7 @@ EXPORT_SYMBOL(kfree);
 
 unsigned int kmem_cache_size(struct kmem_cache *cachep)
 {
-	return obj_size(cachep);
+	return cachep->object_size;
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
@@ -4657,6 +4652,6 @@ size_t ksize(const void *objp)
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
-	return obj_size(virt_to_cache(objp));
+	return virt_to_cache(objp)->object_size;
 }
 EXPORT_SYMBOL(ksize);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
