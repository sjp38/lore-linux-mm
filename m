Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3078E6B0072
	for <linux-mm@kvack.org>; Sat, 27 Oct 2012 15:18:34 -0400 (EDT)
Date: Sat, 27 Oct 2012 21:18:30 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] slub: Use the correct per cpu slab on CPU_DEAD
Message-ID: <alpine.LFD.2.02.1210272117060.2756@ionos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

While making slub available for RT I noticed, that during CPU offline
for each kmem_cache __flush_cpu_slab() is called on a live CPU. This
correctly flushs the cpu_slab of the dead CPU via flush_slab. Though
unfreeze_partials which is called from __flush_cpu_slab() after that
looks at the cpu_slab of the cpu on which this is called. So we fail
to look at the partials of the dead cpu.

Correct this by extending the arguments of unfreeze_partials with the
target cpu number and use per_cpu_ptr instead of this_cpu_ptr.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 mm/slub.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1874,10 +1874,10 @@ redo:
  *
  * This function must be called with interrupt disabled.
  */
-static void unfreeze_partials(struct kmem_cache *s)
+static void unfreeze_partials(struct kmem_cache *s, unsigned int cpu)
 {
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
-	struct kmem_cache_cpu *c = this_cpu_ptr(s->cpu_slab);
+	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
@@ -1963,7 +1963,7 @@ static int put_cpu_partial(struct kmem_c
 				 * set to the per node partial list.
 				 */
 				local_irq_save(flags);
-				unfreeze_partials(s);
+				unfreeze_partials(s, smp_processor_id());
 				local_irq_restore(flags);
 				oldpage = NULL;
 				pobjects = 0;
@@ -2006,7 +2006,7 @@ static inline void __flush_cpu_slab(stru
 		if (c->page)
 			flush_slab(s, c);
 
-		unfreeze_partials(s);
+		unfreeze_partials(s, cpu);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
