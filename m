Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 0F4916B0075
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:38:36 -0400 (EDT)
Message-Id: <0000013993a64ddd-0d791c46-537f-4b7f-811b-a8834fe02093-000000@email.amazonses.com>
Date: Tue, 4 Sep 2012 23:38:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C14 [14/14] [PATCH 23/28] Move kmem_cache refcounting to common code
References: <20120904230609.691088980@linux.com>
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
--- linux.orig/mm/slab.c	2012-09-04 18:00:16.870082786 -0500
+++ linux/mm/slab.c	2012-09-04 18:00:16.882082975 -0500
@@ -2555,7 +2555,6 @@ __kmem_cache_create (struct kmem_cache *
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
 	}
-	cachep->refcount = 1;
 
 	err = setup_cpu_cache(cachep, gfp);
 	if (err) {
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2012-09-04 18:00:16.870082786 -0500
+++ linux/mm/slab_common.c	2012-09-04 18:00:16.886083040 -0500
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
--- linux.orig/mm/slob.c	2012-09-04 18:00:16.870082786 -0500
+++ linux/mm/slob.c	2012-09-04 18:00:16.886083040 -0500
@@ -524,7 +524,6 @@ int __kmem_cache_create(struct kmem_cach
 	if (c->align < align)
 		c->align = align;
 
-	c->refcount = 1;
 	return 0;
 }
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-09-04 18:00:16.870082786 -0500
+++ linux/mm/slub.c	2012-09-04 18:00:16.886083040 -0500
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
