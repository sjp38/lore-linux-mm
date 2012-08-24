Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7E4F86B00A2
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:17:39 -0400 (EDT)
Message-Id: <00000139596cab0a-61fcd4d7-52b5-4e16-89de-57c8df4dc8a4-000000@email.amazonses.com>
Date: Fri, 24 Aug 2012 16:17:38 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C13 [14/14] Move kmem_cache refcounting to common code
References: <20120824160903.168122683@linux.com>
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

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-08-22 10:27:54.838388363 -0500
+++ linux/mm/slab.c	2012-08-22 10:28:31.658969127 -0500
@@ -2543,7 +2543,6 @@ __kmem_cache_create (struct kmem_cache *
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->refcount = 1;
 
 	err = setup_cpu_cache(cachep, gfp);
 	if (err) {
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-08-22 10:27:54.858388583 -0500
+++ linux/mm/slab_common.c	2012-08-22 10:28:31.658969127 -0500
@@ -125,11 +125,12 @@ struct kmem_cache *kmem_cache_create(con
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
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2012-08-22 10:27:54.846388442 -0500
+++ linux/mm/slob.c	2012-08-22 10:28:31.658969127 -0500
@@ -524,8 +524,6 @@ int __kmem_cache_create(struct kmem_cach
 	if (c->align < align)
 		c->align = align;
 
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-08-22 10:27:54.870388814 -0500
+++ linux/mm/slub.c	2012-08-22 10:28:31.662969186 -0500
@@ -3093,7 +3093,6 @@ static int kmem_cache_open(struct kmem_c
 	else
 		s->cpu_partial = 30;
 
-	s->refcount = 1;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
