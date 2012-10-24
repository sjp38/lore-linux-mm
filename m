Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C67546B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 09:59:33 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 2/2] slab: move kmem_cache_free to common code
Date: Wed, 24 Oct 2012 17:59:18 +0400
Message-Id: <1351087158-8524-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1351087158-8524-1-git-send-email-glommer@parallels.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

In the effort of commonizing the slab allocators, it would be better if
we had a single entry-point for kmem_cache_free. The low-level freeing
is still left to the allocators, But at least the tracing can be done in
slab_common.c

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Joonsoo Kim <js1304@gmail.com>
CC: David Rientjes <rientjes@google.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>

---
 mm/slab.c        | 14 ++------------
 mm/slab_common.c | 17 +++++++++++++++++
 mm/slob.c        | 11 ++++-------
 mm/slub.c        |  5 +----
 4 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 72dadce..11e5f3b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3903,15 +3903,8 @@ void *__kmalloc(size_t size, gfp_t flags)
 EXPORT_SYMBOL(__kmalloc);
 #endif
 
-/**
- * kmem_cache_free - Deallocate an object
- * @cachep: The cache the allocation was from.
- * @objp: The previously allocated object.
- *
- * Free an object which was previously allocated from this
- * cache.
- */
-void kmem_cache_free(struct kmem_cache *cachep, void *objp)
+static __always_inline
+void __kmem_cache_free(struct kmem_cache *cachep, void *objp)
 {
 	unsigned long flags;
 
@@ -3921,10 +3914,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
 		debug_check_no_obj_freed(objp, cachep->object_size);
 	__cache_free(cachep, objp, __builtin_return_address(0));
 	local_irq_restore(flags);
-
-	trace_kmem_cache_free(_RET_IP_, objp);
 }
-EXPORT_SYMBOL(kmem_cache_free);
 
 /**
  * kfree - free previously allocated memory
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 66416ee..c6c6e52 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -19,6 +19,8 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 
+#include <trace/events/kmem.h>
+
 #include "slab.h"
 
 /*
@@ -198,6 +200,21 @@ out_locked:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
+/**
+ * kmem_cache_free - Deallocate an object
+ * @cachep: The cache the allocation was from.
+ * @objp: The previously allocated object.
+ *
+ * Free an object which was previously allocated from this
+ * cache.
+ */
+void kmem_cache_free(struct kmem_cache *s, void *x)
+{
+	__kmem_cache_free(s, x);
+	trace_kmem_cache_free(_RET_IP_, x);
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
 void kmem_cache_destroy(struct kmem_cache *s)
 {
 	get_online_cpus();
diff --git a/mm/slob.c b/mm/slob.c
index 3edfeaa..4033ce2 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -555,7 +555,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-static void __kmem_cache_free(void *b, int size)
+static void do_kmem_cache_free(void *b, int size)
 {
 	if (size < PAGE_SIZE)
 		slob_free(b, size);
@@ -568,10 +568,10 @@ static void kmem_rcu_free(struct rcu_head *head)
 	struct slob_rcu *slob_rcu = (struct slob_rcu *)head;
 	void *b = (void *)slob_rcu - (slob_rcu->size - sizeof(struct slob_rcu));
 
-	__kmem_cache_free(b, slob_rcu->size);
+	do_kmem_cache_free(b, slob_rcu->size);
 }
 
-void kmem_cache_free(struct kmem_cache *c, void *b)
+static __always_inline void __kmem_cache_free(struct kmem_cache *c, void *b)
 {
 	kmemleak_free_recursive(b, c->flags);
 	if (unlikely(c->flags & SLAB_DESTROY_BY_RCU)) {
@@ -580,12 +580,9 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 		slob_rcu->size = c->size;
 		call_rcu(&slob_rcu->head, kmem_rcu_free);
 	} else {
-		__kmem_cache_free(b, c->size);
+		do_kmem_cache_free(b, c->size);
 	}
-
-	trace_kmem_cache_free(_RET_IP_, b);
 }
-EXPORT_SYMBOL(kmem_cache_free);
 
 unsigned int kmem_cache_size(struct kmem_cache *c)
 {
diff --git a/mm/slub.c b/mm/slub.c
index 259bc2c..3430564 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2606,7 +2606,7 @@ redo:
 
 }
 
-void kmem_cache_free(struct kmem_cache *s, void *x)
+static __always_inline void __kmem_cache_free(struct kmem_cache *s, void *x)
 {
 	struct page *page;
 
@@ -2620,10 +2620,7 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 	}
 
 	slab_free(s, page, x, _RET_IP_);
-
-	trace_kmem_cache_free(_RET_IP_, x);
 }
-EXPORT_SYMBOL(kmem_cache_free);
 
 /*
  * Object placement in a slab is made very easy because we always start at
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
