Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBA4900146
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 16:47:42 -0400 (EDT)
Message-Id: <20110902204740.288877218@linux.com>
Date: Fri, 02 Sep 2011 15:46:59 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slub rfc1 02/12] slub: Remove useless statements in __slab_alloc
References: <20110902204657.105194589@linux.com>
Content-Disposition: inline; filename=remove_useless_page_null
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, torvalds@linux-foundation.org, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, linux-mm@kvack.org

Two statements in __slab_alloc() do not have any effect.

1. c->page is already set to NULL by deactivate_slab() called right before.

2. gfpflags are masked in new_slab() before being passed to the page
   allocator. There is no need to mask gfpflags in __slab_alloc in particular
   since most frequent processing in __slab_alloc does not require the use of a
   gfpmask.

Cc: torvalds@linux-foundation.org
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    4 ----
 1 file changed, 4 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-08-01 11:03:15.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-08-01 11:04:06.385859038 -0500
@@ -2064,9 +2064,6 @@ static void *__slab_alloc(struct kmem_ca
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
 
-	/* We handle __GFP_ZERO in the caller */
-	gfpflags &= ~__GFP_ZERO;
-
 	page = c->page;
 	if (!page)
 		goto new_slab;
@@ -2163,7 +2160,6 @@ debug:
 
 	c->freelist = get_freepointer(s, object);
 	deactivate_slab(s, c);
-	c->page = NULL;
 	c->node = NUMA_NO_NODE;
 	local_irq_restore(flags);
 	return object;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
