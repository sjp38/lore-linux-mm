Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BAE306B0078
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 06:27:47 -0500 (EST)
Date: Wed, 27 Jan 2010 22:27:40 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] slab: fix regression in touched logic
Message-ID: <20100127112740.GA14790@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This hasn't actually shown up in any real workloads, but if my following
logic is correct then it should be a good fix. Comments?

Thanks,
Nick
--

When factoring common code into transfer_objects, the 'touched' logic
got a bit broken. When refilling from the shared array (taking objects
from the shared array), we are making use of the shared array so it
should be marked as touched.

Subsequently pulling an element from the cpu array and allocating it
should also touch the cpu array, but that is taken care of after the
alloc_done label. (So yes, the cpu array was getting touched = 1
twice).

So revert this logic to how it worked in earlier kernels.

This also affects the behaviour in __drain_alien_cache, which would
previously 'touch' the shared array and now does not. I think it is
more logical not to touch there, because we are pushing objects into
the shared array rather than pulling them off. So there is no good
reason to postpone reaping them -- if the shared array is getting
utilized, then it will get 'touched' in the alloc path (where this
patch now restores the touch).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -935,7 +935,6 @@ static int transfer_objects(struct array
 
 	from->avail -= nr;
 	to->avail += nr;
-	to->touched = 1;
 	return nr;
 }
 
@@ -2963,8 +2962,10 @@ retry:
 	spin_lock(&l3->list_lock);
 
 	/* See if we can refill from the shared array */
-	if (l3->shared && transfer_objects(ac, l3->shared, batchcount))
+	if (l3->shared && transfer_objects(ac, l3->shared, batchcount)) {
+		l3->shared->touched = 1;
 		goto alloc_done;
+	}
 
 	while (batchcount > 0) {
 		struct list_head *entry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
