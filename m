Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6486B0235
	for <linux-mm@kvack.org>; Wed,  5 May 2010 14:15:18 -0400 (EDT)
Date: Wed, 5 May 2010 19:14:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100505181456.GV20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505155454.GT20979@csn.ul.ie> <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 10:34:03AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 5 May 2010, Mel Gorman wrote:
> > 
> > I'm still thinking of the ordering but one possibility would be to use a mutex
> > similar to mm_all_locks_mutex to force the serialisation of rmap_walk instead
> > of the trylock-and-retry. That way, the ordering wouldn't matter. It would
> > slow migration if multiple processes are migrating pages by some unknowable
> > quantity but it would avoid livelocking.
> 
> Hmm.. An idea is starting to take form..
> 
> How about something like this?
> 
>  - the lock is per-anon_vma
> 
> BUT
> 
>  - you always lock the _deepest_ anon_vma you can find.
> 

Maybe I should have read mail before sending off a work-in-progress patch :/ .

> That means just a single lock. And the "deepest" anon_vma is well-defined 
> for all anon_vma's, because each same_anon_vma chain is always rooted in 
> the original anon_vma that caused it.
> 

In the direction I was taking, only rmap_walk took the deepest lock (I called
it oldest but hey) and would take other anon_vma locks as well. The objective
was to make sure the order the locks were taken in was correct.

I think you are suggesting that any anon_vma lock that is taken should always
take the deepest lock. Am I right and is that necessary? The downsides is that
there is a single lock that is hotter. The upside is that rmap_walk no longer
has different semantics as vma_adjust and friends because it's the same lock.

> From the vma, it's simply
> 	avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
> 	anon_vma = avc->anon_vma;
> 

I think I got that right at least.

> and once you take that lock, you know you've gotten the lock for all 
> chains related to that page. We _know_ that every single vma that is 
> associated with that anon_vma must have a chain that eventually ends in 
> that entry.
> 

That was my understanding but I'm still not sure of my footing on the
anon_vma changes so doubted myself.

> So I wonder if the locking can't be just something like this:
> 
>    struct anon_vma *lock_anon_vma_root(struct page *page)
>    {
> 	struct anon_vma *anon_vma, *root;
> 
> 	rcu_read_lock();

Not sure if this is necessary. In the case of rmap_walk(), it's already
held. In the other cases, a semaphore is held which should prevent the first
anon_vma disappearing.

> 	anon_vma = page_anon_vma(page);
> 	if (!anon_vma)
> 		return ret;
> 	/* Make sure the anon_vma 'same_anon_vma' list is stable! */
> 	spin_lock(&anon_vma->lock);
> 	root = NULL;
> 	if (!list_empty(&anon_vma->head)) {

Can it be empty? I didn't think it was possible as the anon_vma must
have at least it's own chain.

> 		struct anon_vma_chain *avc;
> 		struct vm_area_struct *vma;
> 		struct anon_vma *root;
> 		avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
> 		vma = avc->vma;
> 		avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
> 		root = avc->anon_vma;
> 	}
> 	/* We already locked it - anon_vma _was_ the root */
> 	if (root == anon_vma)
> 		return root;
> 	spin_unlock(&anon_vma->lock);
> 	if (root) {
> 		spin_lock(&root->lock);
> 		return root;
> 	}
> 	rcu_read_unlock();
> 	return NULL;
>    }

Other than terminology and minor implementation details, this is more or
less what I came up with as well.

> 
> and
> 
>    void unlock_anon_vma_root(struct anon_vma *root)
>    {
> 	spin_unlock(&root->lock);
> 	rcu_read_unlock();
>    }
> 
> or something. I agree that the above is not _beautiful_, and it's not 
> exactly simple, but it does seem to have the absolutely huge advantage 
> that it is a nice O(1) thing that only ever takes a single lock and has no 
> nesting.

This is the only significant point we differ on. Do we;

1. Always take the deepest anon_vma lock using the lock anon_vma lock
   just to protect the list long enough to find it?

or

2. Only have rmap_walk use the deepest anon_vma lock just so it takes
   multiple locks in the correct order?

I am not seeing a killer advantage of one over the order. While (2)
would mean the same lock is always taken - it's a double lock to get it
"lock local, find deepest, lock deepest, release local" which adds a
small overhead to the common path. With 1, the searching around is
confined to migration.

Andrea, is there an advantage of one over the other for you or is Rik's
approach just better overall?

Rik, any opinions?

> And while the code looks complicated, it's based on a pretty 
> simple constraint on the anon_vma's that we already require (ie that all 
> related anon_vma chains have to end up at the same root anon_vma).
> 
> In other words: _any_ vma that is associated with _any_ related anon_vma 
> will always end up feeding up to the same root anon_vma.
> 
> I do think other people should think this through. And it needs a comment 
> that really explains all this.
> 
> (And the code above is written in my email editor - it has not been 
> tested, compiled, or anythign else. It may _look_ like real code, but 
> think of it as pseudo-code where the explanation for the code is more 
> important than the exact details.
> 

Well, for what it works, the basic principal appears to work. At least,
the machine I'm testing my own patch on hasn't managed to deadlock yet.

> NOTE NOTE NOTE! In particular, I think that the 'rcu_read_lock()' and the 
> actual lookup of the anon_vma (ie the "anon_vma = page_anon_vma(page)") 
> part should probably be in the callers. I put it in the pseudo-code itself 
> to just show how you go from a 'struct page' to the "immediate" anon_vma 
> it is associated with, and from that to the "root" anon_vma of the whole 
> chain.
> 
> And maybe I'm too clever for myself, and I've made some fundamental 
> mistake that means that the above doesn't work.
> 

Considering that we came up with more or less the same idea, the basic
idea of "lock the deepest anon_vma" must be sound :/

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
