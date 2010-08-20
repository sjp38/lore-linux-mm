Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EB416B033F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:37:43 -0400 (EDT)
Message-Id: <20100820173740.449355843@linux.com>
Date: Fri, 20 Aug 2010 12:37:17 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [S+Q Cleanup4 6/6] slub: Move gfpflag masking out of the hotpath
References: <20100820173711.136529149@linux.com>
Content-Disposition: inline; filename=slub_move_gfpflags
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Move the gfpflags masking into the hooks for checkers and into the slowpaths.
gfpflag masking requires access to a global variable and thus adds an
additional cacheline reference to the hotpaths.

If no hooks are active then the gfpflag masking will result in
code that the compiler can toss out.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-20 11:43:50.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-20 11:43:50.000000000 -0500
@@ -796,6 +796,7 @@ static void trace(struct kmem_cache *s, 
  */
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 {
+	flags &= gfp_allowed_mask;
 	lockdep_trace_alloc(flags);
 	might_sleep_if(flags & __GFP_WAIT);
 
@@ -804,6 +805,7 @@ static inline int slab_pre_alloc_hook(st
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
 {
+	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, s->objsize);
 	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
 }
@@ -1677,6 +1679,7 @@ new_slab:
 		goto load_freelist;
 	}
 
+	gfpflags &= gfp_allowed_mask;
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
@@ -1725,8 +1728,6 @@ static __always_inline void *slab_alloc(
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
 
-	gfpflags &= gfp_allowed_mask;
-
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
