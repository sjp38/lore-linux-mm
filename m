Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1D26B029B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 13:37:34 -0400 (EDT)
Date: Wed, 5 May 2010 10:34:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100505155454.GT20979@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505155454.GT20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Wed, 5 May 2010, Mel Gorman wrote:
> 
> I'm still thinking of the ordering but one possibility would be to use a mutex
> similar to mm_all_locks_mutex to force the serialisation of rmap_walk instead
> of the trylock-and-retry. That way, the ordering wouldn't matter. It would
> slow migration if multiple processes are migrating pages by some unknowable
> quantity but it would avoid livelocking.

Hmm.. An idea is starting to take form..

How about something like this?

 - the lock is per-anon_vma

BUT

 - you always lock the _deepest_ anon_vma you can find.

That means just a single lock. And the "deepest" anon_vma is well-defined 
for all anon_vma's, because each same_anon_vma chain is always rooted in 
the original anon_vma that caused it.

>From the vma, it's simply
	avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
	anon_vma = avc->anon_vma;

and once you take that lock, you know you've gotten the lock for all 
chains related to that page. We _know_ that every single vma that is 
associated with that anon_vma must have a chain that eventually ends in 
that entry.

So I wonder if the locking can't be just something like this:

   struct anon_vma *lock_anon_vma_root(struct page *page)
   {
	struct anon_vma *anon_vma, *root;

	rcu_read_lock();
	anon_vma = page_anon_vma(page);
	if (!anon_vma)
		return ret;
	/* Make sure the anon_vma 'same_anon_vma' list is stable! */
	spin_lock(&anon_vma->lock);
	root = NULL;
	if (!list_empty(&anon_vma->head)) {
		struct anon_vma_chain *avc;
		struct vm_area_struct *vma;
		struct anon_vma *root;
		avc = list_first_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
		vma = avc->vma;
		avc = list_entry(vma->anon_vma_chain.prev, struct anon_vma_chain, same_vma);
		root = avc->anon_vma;
	}
	/* We already locked it - anon_vma _was_ the root */
	if (root == anon_vma)
		return root;
	spin_unlock(&anon_vma->lock);
	if (root) {
		spin_lock(&root->lock);
		return root;
	}
	rcu_read_unlock();
	return NULL;
   }

and

   void unlock_anon_vma_root(struct anon_vma *root)
   {
	spin_unlock(&root->lock);
	rcu_read_unlock();
   }

or something. I agree that the above is not _beautiful_, and it's not 
exactly simple, but it does seem to have the absolutely huge advantage 
that it is a nice O(1) thing that only ever takes a single lock and has no 
nesting. And while the code looks complicated, it's based on a pretty 
simple constraint on the anon_vma's that we already require (ie that all 
related anon_vma chains have to end up at the same root anon_vma).

In other words: _any_ vma that is associated with _any_ related anon_vma 
will always end up feeding up to the same root anon_vma.

I do think other people should think this through. And it needs a comment 
that really explains all this.

(And the code above is written in my email editor - it has not been 
tested, compiled, or anythign else. It may _look_ like real code, but 
think of it as pseudo-code where the explanation for the code is more 
important than the exact details.

NOTE NOTE NOTE! In particular, I think that the 'rcu_read_lock()' and the 
actual lookup of the anon_vma (ie the "anon_vma = page_anon_vma(page)") 
part should probably be in the callers. I put it in the pseudo-code itself 
to just show how you go from a 'struct page' to the "immediate" anon_vma 
it is associated with, and from that to the "root" anon_vma of the whole 
chain.

And maybe I'm too clever for myself, and I've made some fundamental 
mistake that means that the above doesn't work.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
