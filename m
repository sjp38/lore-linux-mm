Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C168A6B0098
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:46:43 -0400 (EDT)
Message-Id: <0000013abdf0bd68-4a493a6a-3009-4ee4-8a66-1029eee65507-000000@email.amazonses.com>
Date: Thu, 1 Nov 2012 21:46:42 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [01/18] Use correct cpu_slab on dead cpu
References: <20121101214538.971500204@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

Pass a kmem_cache_cpu pointer into unfreeze partials so that a different
kmem_cache_cpu structure than the local one can be specified.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-11-01 10:10:05.073716747 -0500
+++ linux/mm/slub.c	2012-11-01 10:10:06.173734998 -0500
@@ -1871,10 +1871,10 @@ redo:
  *
  * This function must be called with interrupt disabled.
  */
-static void unfreeze_partials(struct kmem_cache *s)
+static void unfreeze_partials(struct kmem_cache *s,
+		struct kmem_cache_cpu *c)
 {
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
-	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
 	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
@@ -1960,7 +1960,7 @@ static int put_cpu_partial(struct kmem_c
 				 * set to the per node partial list.
 				 */
 				local_irq_save(flags);
-				unfreeze_partials(s);
+				unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
 				local_irq_restore(flags);
 				oldpage = NULL;
 				pobjects = 0;
@@ -2003,7 +2003,7 @@ static inline void __flush_cpu_slab(stru
 		if (c->page)
 			flush_slab(s, c);
 
-		unfreeze_partials(s);
+		unfreeze_partials(s, c);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
