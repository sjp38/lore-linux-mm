Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 937C06B0073
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:23:02 -0500 (EST)
Message-Id: <0000013b47d4167a-f32f2166-dbf4-4ae5-b1b4-284ba72ce445-000000@email.amazonses.com>
Date: Wed, 28 Nov 2012 16:23:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK5 [1/6] Use correct cpu_slab on dead cpu
References: <20121128162238.111670741@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

Pass a kmem_cache_cpu pointer into unfreeze partials so that a different
kmem_cache_cpu structure than the local one can be specified.

V1->V2:
 - Improve the comments

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2012-11-05 09:05:23.572665087 -0600
+++ linux/mm/slub.c	2012-11-05 09:08:04.208740893 -0600
@@ -1869,12 +1869,14 @@ redo:
 /*
  * Unfreeze all the cpu partial slabs.
  *
- * This function must be called with interrupt disabled.
+ * This function must be called with interrupts disabled
+ * for the cpu using c (or some other guarantee must be there
+ * to guarantee no concurrent accesses).
  */
-static void unfreeze_partials(struct kmem_cache *s)
+static void unfreeze_partials(struct kmem_cache *s,
+		struct kmem_cache_cpu *c)
 {
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
-	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
 	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
@@ -1960,7 +1962,7 @@ static int put_cpu_partial(struct kmem_c
 				 * set to the per node partial list.
 				 */
 				local_irq_save(flags);
-				unfreeze_partials(s);
+				unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
 				local_irq_restore(flags);
 				oldpage = NULL;
 				pobjects = 0;
@@ -2003,7 +2005,7 @@ static inline void __flush_cpu_slab(stru
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
