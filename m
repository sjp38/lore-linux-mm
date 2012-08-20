Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2A6C36B0073
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 16:50:43 -0400 (EDT)
Message-Id: <0000013945cd3125-1c686fa7-3878-4d2a-ab45-fcdbab8ac0f2-000000@email.amazonses.com>
Date: Mon, 20 Aug 2012 20:50:39 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [14/19] Move kmem_cache refcounting to common code
References: <20120820204021.494276880@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Get rid of the refcount stuff in the allocators and do that
part of kmem_cache management in the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slab.c        |    1 -
 mm/slab_common.c |    5 +++--
 mm/slob.c        |    2 --
 mm/slub.c        |    1 -
 4 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c2c1c88..32ba049 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2543,7 +2543,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->refcount = 1;
 
 	err = setup_cpu_cache(cachep, gfp);
 	if (err) {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 4640ef65..0dc1cde 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -125,11 +125,12 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t align
 		}
 
 		err = __kmem_cache_create(s, flags);
-		if (!err)
+		if (!err) {
 
+			s->refcount = 1;
 			list_add(&s->list, &slab_caches);
 
-		else {
+		} else {
 			kfree(s->name);
 			kmem_cache_free(kmem_cache, s);
 		}
diff --git a/mm/slob.c b/mm/slob.c
index 0df4943..3edfeaa 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -524,8 +524,6 @@ int __kmem_cache_create(struct kmem_cache *c, unsigned long flags)
 	if (c->align < align)
 		c->align = align;
 
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 744ba08..e8115c8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3093,7 +3093,6 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
 	else
 		s->cpu_partial = 30;
 
-	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
-- 
1.7.9.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
