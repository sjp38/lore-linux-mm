Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD0CB6B029E
	for <linux-mm@kvack.org>; Wed,  5 May 2010 10:56:44 -0400 (EDT)
Date: Wed, 5 May 2010 15:56:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100505145620.GP20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 07:34:37AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 5 May 2010, Mel Gorman wrote:
> >
> > With the recent anon_vma changes, there can be more than one anon_vma->lock
> > to take in a anon_vma_chain but a second lock cannot be spinned upon in case
> > of deadlock. The rmap walker tries to take locks of different anon_vma's
> > but if the attempt fails, locks are released and the operation is restarted.
> 
> Btw, is this really needed?
> 

I could not convince myself that it wasn't. lockdep throws a fit if you try
but it can be taught about the situation if necessary.

> Nobody else takes two anon_vma locks at the same time, so in order to 
> avoid ABBA deadlocks all we need to guarantee is that rmap_walk_ksm() and 
> rmap_walk_anon() always lock the anon_vma's in the same order.
> 

rmap_walk() appears to be the only one that takes multiple locks but it itself
is not serialised. If there are more than one process calling rmap_walk()
on different processes sharing the same VMAs, is there a guarantee they walk
it in the same order? I didn't think so at the time the patch because the
anon_vma the walk starts from is based on the page being migrated rather
than any idea of starting from a parent or primary anon_vma.

> And they do, as far as I can tell. How could we ever get a deadlock when 
> we have both cases doing the locking by walking the same_anon_vma list?
> 

If we always started the list walk in the same place then it'd be fine but
if they start in different places, it could deadlock.

> 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> 
> So I think the "retry" logic looks unnecessary, and actually opens us up 
> to a possible livelock bug (imagine a long chain, and heavy page fault 
> activity elsewhere that ends up locking some anon_vma in the chain, and 
> just the right behavior that gets us into a lockstep situation),

I imagined it and I'm not super-happy about it. It's one of the reasons Rik
called it "fragile".

> rather than fixing an ABBA deadlock.
> 
> Now, if it's true that somebody else _does_ do nested anon_vma locking, 
> I'm obviously wrong. But I don't see such usage.
> 
> Comments?
> 

Just what I have above. I couldn't convince myself that two callers to
rmap_walk from pages based on different VMAs on the same_anon_vma list would
always started in the same place.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
