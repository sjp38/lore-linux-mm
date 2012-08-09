Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 650B06B0093
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:22:17 -0400 (EDT)
Message-Id: <20120809135635.968248518@linux.com>
Date: Thu, 09 Aug 2012 08:56:38 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [15/20] Move kmem_cache refcounting to common code
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=refcount_move
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Get rid of the refcount stuff in the allocators and do that
part of kmem_cache management in the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-08 12:58:11.038137838 -0500
+++ linux-2.6/mm/slab.c	2012-08-08 13:04:01.267084197 -0500
@@ -2550,7 +2550,6 @@ __kmem_cache_create (struct kmem_cache *
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->refcount = 1;
 
 	err = setup_cpu_cache(cachep, gfp);
 	if (err) {
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-08 12:58:11.038137838 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-08 13:04:01.271084210 -0500
@@ -110,11 +110,12 @@ struct kmem_cache *kmem_cache_create(con
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
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-08 12:58:11.038137838 -0500
+++ linux-2.6/mm/slob.c	2012-08-08 13:04:01.271084210 -0500
@@ -524,8 +524,6 @@ int __kmem_cache_create(struct kmem_cach
 	if (c->align < align)
 		c->align = align;
 
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-08 12:58:38.850212989 -0500
+++ linux-2.6/mm/slub.c	2012-08-08 13:04:01.271084210 -0500
@@ -3086,7 +3086,6 @@ static int kmem_cache_open(struct kmem_c
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
