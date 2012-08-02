Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 51E406B0087
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:42 -0400 (EDT)
Message-Id: <20120802201540.570017751@linux.com>
Date: Thu, 02 Aug 2012 15:15:24 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [18/19] Move kmem_cache refcounting to common code
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=refcount_move
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

Get rid of the refcount stuff in the allocators and do that
part of kmem_cache management in the common code.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2012-08-02 14:26:36.299565690 -0500
+++ linux-2.6/mm/slab.c	2012-08-02 14:37:42.671454099 -0500
@@ -2533,7 +2533,6 @@
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->refcount = 1;
 
 	r = setup_cpu_cache(cachep, gfp);
 	if (r) {
Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 14:36:43.000000000 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 14:40:37.686580855 -0500
@@ -111,11 +111,12 @@
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
@@ -195,6 +196,7 @@
 
 		if (!r) {
 			list_add(&s->list, &slab_caches);
+			s->refcount = 1;
 			return s;
 		}
 	}
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-08-02 14:26:36.000000000 -0500
+++ linux-2.6/mm/slob.c	2012-08-02 14:37:42.671454099 -0500
@@ -524,8 +524,6 @@
 	if (c->align < align)
 		c->align = align;
 
-	kmemleak_alloc(c, sizeof(struct kmem_cache), 1, GFP_KERNEL);
-	c->refcount = 1;
 	return 0;
 }
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 14:26:36.299565690 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 14:37:42.675454385 -0500
@@ -3086,7 +3086,6 @@
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
