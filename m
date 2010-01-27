Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 65ED86B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 10:29:46 -0500 (EST)
Date: Thu, 28 Jan 2010 02:29:39 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] slab: fix regression in touched logic
Message-ID: <20100127152939.GA17517@laptop>
References: <20100127112740.GA14790@laptop>
 <4B605802.7010401@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B605802.7010401@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 05:13:06PM +0200, Pekka Enberg wrote:
> Nick Piggin wrote:
> >Hi,
> >
> >This hasn't actually shown up in any real workloads, but if my following
> >logic is correct then it should be a good fix. Comments?
> >
> >Thanks,
> >Nick
> >--
> >
> >When factoring common code into transfer_objects, the 'touched' logic
> >got a bit broken. When refilling from the shared array (taking objects
> >from the shared array), we are making use of the shared array so it
> >should be marked as touched.
> >
> >Subsequently pulling an element from the cpu array and allocating it
> >should also touch the cpu array, but that is taken care of after the
> >alloc_done label. (So yes, the cpu array was getting touched = 1
> >twice).
> >
> >So revert this logic to how it worked in earlier kernels.
> >
> >This also affects the behaviour in __drain_alien_cache, which would
> >previously 'touch' the shared array and now does not. I think it is
> >more logical not to touch there, because we are pushing objects into
> >the shared array rather than pulling them off. So there is no good
> >reason to postpone reaping them -- if the shared array is getting
> >utilized, then it will get 'touched' in the alloc path (where this
> >patch now restores the touch).
> >
> >Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Makes sense but the rework doesn't ring a bell for me and I didn't
> check the git logs yet. Christoph, comments?

Ah, should have referenced it.

3ded175a4b7a4548f3358dcf5f3ad65f63cdb4ed

So we can see that we stopped touching the shared array cache there
(and now touch the cpu array cache twice).

The 2nd use of transfer_objects came later, but as in my comments,
I think it is reasonably justified to remove the touch there too.

> 
> >---
> >Index: linux-2.6/mm/slab.c
> >===================================================================
> >--- linux-2.6.orig/mm/slab.c
> >+++ linux-2.6/mm/slab.c
> >@@ -935,7 +935,6 @@ static int transfer_objects(struct array
> > 	from->avail -= nr;
> > 	to->avail += nr;
> >-	to->touched = 1;
> > 	return nr;
> > }
> >@@ -2963,8 +2962,10 @@ retry:
> > 	spin_lock(&l3->list_lock);
> > 	/* See if we can refill from the shared array */
> >-	if (l3->shared && transfer_objects(ac, l3->shared, batchcount))
> >+	if (l3->shared && transfer_objects(ac, l3->shared, batchcount)) {
> >+		l3->shared->touched = 1;
> > 		goto alloc_done;
> >+	}
> > 	while (batchcount > 0) {
> > 		struct list_head *entry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
