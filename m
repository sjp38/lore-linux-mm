Subject: [RFC PATCH] slab: __GFP_NOWARN not being propagated from mempool_alloc()
Message-Id: <E1L4jMt-0006OW-5J@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 24 Nov 2008 22:53:19 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, david@fromorbit.com, peterz@infradead.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We see page allocation failure warnings on the mempool_alloc() path.
See this lkml posting for example:

http://lkml.org/lkml/2008/10/27/100

The cause is that on NUMA, alloc_slabmgmt() clears __GFP_NOWARN,
together with __GFP_THISNODE and __GFP_NORETRY.  But AFAICS it really
only wants to clear __GFP_THISNODE.

Does this patch looks good?

Warning: it's completely untested.

Miklos
---
 mm/slab.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2008-10-24 12:40:34.000000000 +0200
+++ linux-2.6/mm/slab.c	2008-11-24 22:17:04.000000000 +0100
@@ -2609,7 +2609,8 @@ static struct slab *alloc_slabmgmt(struc
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
 		slabp = kmem_cache_alloc_node(cachep->slabp_cache,
-					      local_flags & ~GFP_THISNODE, nodeid);
+					      local_flags & ~__GFP_THISNODE,
+					      nodeid);
 		if (!slabp)
 			return NULL;
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
