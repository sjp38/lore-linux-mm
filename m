Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2481D6B0070
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:39 -0400 (EDT)
Message-Id: <0000013945cd251f-e4b812a7-c35f-42fa-a1fb-a1fcc4246427-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [04/19] Move list_add() to slab_common.c
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org

Move the code to append the new kmem_cache to the list of slab caches to
the kmem_cache_create code in the shared code.

This is possible now since the acquisition of the mutex was moved into
kmem_cache_create().

V1->V2:
	- SLOB: Add code to remove the slab from list
	 (will be removed a couple of patches down when we also move the
	 list_del to common code).

Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |    7 +++++--
 mm/slab_common.c |    7 +++++++
 mm/slob.c        |    4 ++++
 mm/slub.c        |    2 --
 4 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3b4587b..a699031 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1680,6 +1680,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
 
+	list_add(&sizes[INDEX_AC].cs_cachep->list, &slab_caches);
 	if (INDEX_AC != INDEX_L3) {
 		sizes[INDEX_L3].cs_cachep =
 			__kmem_cache_create(names[INDEX_L3].name,
@@ -1687,6 +1688,7 @@ void __init kmem_cache_init(void)
 				ARCH_KMALLOC_MINALIGN,
 				ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 				NULL);
+		list_add(&sizes[INDEX_L3].cs_cachep->list, &slab_caches);
 	}
 
 	slab_early_init = 0;
@@ -1705,6 +1707,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_MINALIGN,
 					ARCH_KMALLOC_FLAGS|SLAB_PANIC,
 					NULL);
+			list_add(&sizes->cs_cachep->list, &slab_caches);
 		}
 #ifdef CONFIG_ZONE_DMA
 		sizes->cs_dmacachep = __kmem_cache_create(
@@ -1714,6 +1717,7 @@ void __init kmem_cache_init(void)
 					ARCH_KMALLOC_FLAGS|SLAB_CACHE_DMA|
 						SLAB_PANIC,
 					NULL);
+		list_add(&sizes->cs_dmacachep->list, &slab_caches);
 #endif
 		sizes++;
 		names++;
@@ -2583,6 +2587,7 @@ __kmem_cache_create (const char *name, size_t size, size_t align,
 	}
 	cachep->ctor = ctor;
 	cachep->name = name;
+	cachep->refcount = 1;
 
 	if (setup_cpu_cache(cachep, gfp)) {
 		__kmem_cache_destroy(cachep);
@@ -2599,8 +2604,6 @@ __kmem_cache_create (const char *name, size_t size, size_t align,
 		slab_set_debugobj_lock_classes(cachep);
 	}
 
-	/* cache setup completed, link it into the list */
-	list_add(&cachep->list, &slab_caches);
 	return cachep;
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b61c9ae..d419a3e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -111,6 +111,13 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 	if (!s)
 		err = -ENOSYS; /* Until __kmem_cache_create returns code */
 
+	/*
+	 * Check if the slab has actually been created and if it was a
+	 * real instatiation. Aliases do not belong on the list
+	 */
+	if (s && s->refcount == 1)
+		list_add(&s->list, &slab_caches);
+
 out_locked:
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();
diff --git a/mm/slob.c b/mm/slob.c
index 45d4ca7..5225d28 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -540,6 +540,10 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 
 void kmem_cache_destroy(struct kmem_cache *c)
 {
+	mutex_lock(&slab_mutex);
+	list_del(&c->list);
+	mutex_unlock(&slab_mutex);
+
 	kmemleak_free(c);
 	if (c->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();
diff --git a/mm/slub.c b/mm/slub.c
index e0b9403..37d5177 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3975,7 +3975,6 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 				size, align, flags, ctor)) {
 			int r;
 
-			list_add(&s->list, &slab_caches);
 			mutex_unlock(&slab_mutex);
 			r = sysfs_slab_add(s);
 			mutex_lock(&slab_mutex);
@@ -3983,7 +3982,6 @@ struct kmem_cache *__kmem_cache_create(const char *name, size_t size,
 			if (!r)
 				return s;
 
-			list_del(&s->list);
 			kmem_cache_close(s);
 		}
 		kmem_cache_free(kmem_cache, s);
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
