Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 5BB8A6B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 11:21:02 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH] slab+slob: dup name string
Date: Mon, 21 May 2012 19:18:59 +0400
Message-Id: <1337613539-29108-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

The slub allocator creates a copy of the name string, and
frees it later. I would like all caches to behave the same,
whether it is the slab+slob starting to create a copy of it itself,
or the slub ceasing to.

This patch creates copies of the name string for slob and slab,
adopting slub behavior for them all.

For the slab, we can't really do it before the kmalloc caches are
up. We need to rely that caches created before the state was set to
EARLY will never be destroyed.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c |   10 ++++++++--
 mm/slob.c |   12 ++++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e901a36..cabd217 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2118,6 +2118,7 @@ static void __kmem_cache_destroy(struct kmem_cache *cachep)
 			kfree(l3);
 		}
 	}
+	kfree(cachep->name);
 	kmem_cache_free(&cache_cache, cachep);
 }
 
@@ -2526,9 +2527,14 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
 	cachep->ctor = ctor;
-	cachep->name = name;
 
-	if (setup_cpu_cache(cachep, gfp)) {
+	/* Can't do strdup while kmalloc is not up */
+	if (g_cpucache_up > EARLY)
+		cachep->name = kstrdup(name, GFP_KERNEL);
+	else
+		cachep->name = name;
+
+	if (!cachep->name || setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
 		cachep = NULL;
 		goto oops;
diff --git a/mm/slob.c b/mm/slob.c
index 8105be4..8f10d36 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -575,7 +575,12 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		GFP_KERNEL, ARCH_KMALLOC_MINALIGN, -1);
 
 	if (c) {
-		c->name = name;
+		c->name = kstrdup(name, GFP_KERNEL);
+		if (!c->name) {
+			slob_free(c, sizeof(struct kmem_cache));
+			c = NULL;
+			goto out;
+		}
 		c->size = size;
 		if (flags & SLAB_DESTROY_BY_RCU) {
 			/* leave room for rcu footer at the end of object */
@@ -589,7 +594,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 			c->align = ARCH_SLAB_MINALIGN;
 		if (c->align < align)
 			c->align = align;
-	} else if (flags & SLAB_PANIC)
+	}
+out:
+	if (!c && (flags & SLAB_PANIC))
 		panic("Cannot create slab cache %s\n", name);
 
 	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
@@ -602,6 +609,7 @@ void kmem_cache_destroy(struct kmem_cache *c)
 	kmemleak_free(c);
 	if (c->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();
+	kfree(c->name);
 	slob_free(c, sizeof(struct kmem_cache));
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
