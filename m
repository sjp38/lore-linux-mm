Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD146B0083
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:18:26 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [PATCH] SLAB: Record actual last user of freed objects.
Date: Thu,  2 Jun 2011 00:16:42 -0700
Message-Id: <1306999002-29738-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: suleiman@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, Suleiman Souhlal <ssouhlal@FreeBSD.org>

Currently, when using CONFIG_DEBUG_SLAB, we put in kfree() or
kmem_cache_free() as the last user of free objects, which is not
very useful, so change it to the caller of those functions instead.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 mm/slab.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 98f114d..615e76c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3603,13 +3603,14 @@ free_done:
  * Release an obj back to its cache. If the obj has a constructed state, it must
  * be in this state _before_ it is released.  Called with disabled ints.
  */
-static inline void __cache_free(struct kmem_cache *cachep, void *objp)
+static inline void __cache_free(struct kmem_cache *cachep, void *objp,
+    void *caller)
 {
 	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
 	kmemleak_free_recursive(objp, cachep->flags);
-	objp = cache_free_debugcheck(cachep, objp, __builtin_return_address(0));
+	objp = cache_free_debugcheck(cachep, objp, caller);
 
 	kmemcheck_slab_free(cachep, objp, obj_size(cachep));
 
@@ -3800,7 +3801,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 	debug_check_no_locks_freed(objp, obj_size(cachep));
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(objp, obj_size(cachep));
-	__cache_free(cachep, objp);
+	__cache_free(cachep, objp, __builtin_return_address(0));
 	local_irq_restore(flags);
 
 	trace_kmem_cache_free(_RET_IP_, objp);
@@ -3830,7 +3831,7 @@ void kfree(const void *objp)
 	c = virt_to_cache(objp);
 	debug_check_no_locks_freed(objp, obj_size(c));
 	debug_check_no_obj_freed(objp, obj_size(c));
-	__cache_free(c, (void *)objp);
+	__cache_free(c, (void *)objp, __builtin_return_address(0));
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(kfree);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
