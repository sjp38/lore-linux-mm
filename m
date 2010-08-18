Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 05D006B01F5
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:26:41 -0400 (EDT)
Message-Id: <20100818162639.402753062@linux.com>
Date: Wed, 18 Aug 2010 11:25:45 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q Cleanup2 6/6] slub: Move gfpflag masking out of the hotpath
References: <20100818162539.281413425@linux.com>
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

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-18 09:58:16.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-18 10:01:11.000000000 -0500
@@ -797,6 +797,7 @@ static void trace(struct kmem_cache *s, 
  */
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 {
+	flags &= gfp_allowed_mask;
 	lockdep_trace_alloc(flags);
 	might_sleep_if(flags & __GFP_WAIT);
 
@@ -805,6 +806,7 @@ static inline int slab_pre_alloc_hook(st
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags, void *object)
 {
+	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, s->objsize);
 	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
 }
@@ -1678,6 +1680,7 @@ new_slab:
 		goto load_freelist;
 	}
 
+	gfpflags &= gfp_allowed_mask;
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
