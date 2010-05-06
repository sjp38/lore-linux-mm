Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1B76B01F9
	for <linux-mm@kvack.org>; Thu,  6 May 2010 07:03:44 -0400 (EDT)
Date: Thu, 6 May 2010 12:03:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100506110322.GE20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org> <20100505155454.GT20979@csn.ul.ie> <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org> <20100505181456.GV20979@csn.ul.ie> <alpine.LFD.2.00.1005051118540.27218@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005051118540.27218@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 11:34:05AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 5 May 2010, Mel Gorman wrote:
> > 
> > In the direction I was taking, only rmap_walk took the deepest lock (I called
> > it oldest but hey) and would take other anon_vma locks as well. The objective
> > was to make sure the order the locks were taken in was correct.
> >
> > I think you are suggesting that any anon_vma lock that is taken should always
> > take the deepest lock. Am I right and is that necessary? The downsides is that
> > there is a single lock that is hotter. The upside is that rmap_walk no longer
> > has different semantics as vma_adjust and friends because it's the same lock.
> 
> I could personally go either way, I don't really care that deeply.
> 
> I think you could easily just take the root lock in the rmap_walk_anon/ksm 
> paths, and _also_ take the individual locks as you walk it (safe, since 
> now the root lock avoids the ABBA issue - you only need to compare the 
> individual lock against the root lock to not take it twice, of course).
> 

This is what I'm currently doing.

> Or you could take the "heavy lock" approach that Andrea was arguing for, 
> but rather than iterating you'd just take the root lock.
> 

Initially, I thought the problem with this was making the root anon_vma
lock hotter. It didn't seem that big of a deal but it was there. The greater
problem was that the RCU lock is needed to exchange the local anon_vma lock
with the root anon_vma lock. So the "heavy lock" approach is actually quite
heavy because it involves two spinlocks, the RCU lock and the root lock
being hotter.

Right now, I'm thinking that only rmap_walk taking the root anon_vma
lock and taking multiple locks as it walks is nicer. I believe it's
sufficient for migration but it also needs to be sufficient for
transparent hugepage support.

> I absolutely _hated_ the "iterate over all locks in the normal case" idea, 
> but with the root lock it's much more targeted and no longer is about 
> nested locks of the same type.
> 
> So the things I care about are just:
> 
>  - I hate that "retry" logic that made things more complex and had the 
>    livelock problem.
> 

Dumped.

>    The "root lock" helper function certainly wouldn't be any fewer lines 
>    than your retry version, but it's a clearly separate locking function, 
>    rather than mixed in with the walking code. And it doesn't do livelock.
> 

Agreed.

>  - I detest "take all locks" in normal paths. I'm ok with it for special 
>    case code (and I think the migrate code counts as special case), but I 
>    think it was really horribly and fundamentally wrong in that "mm: Take 
>    all anon_vma locks in anon_vma_lock" patch I saw.
> 
> but whether we want to take the root lock in "anon_vma_lock()" or not is 
> just a "detail" as far as I'm concerned. It's no longer "horribly wrong". 
> It might have scalability issues etc, of course, but likely only under 
> insane loads.
> 

I think this approach of always taking the root lock would be neater in a
number of respects because from a page, there would be the "one true lock".
If RCU was not involved, it would be particularly nice.

Part of PeterZ's "replace anon_vma lock with mutex" involves proper
reference counting of anon_vma. If even the reference count part was
polished, it would allow us to always take the root anon_vma lock
without RCU because it would be

lock local_anon_vma
find root_anon_vma
get root_anon_vma
unlock local_anon_vma
lock root anon_vma
put root_anon_vma

So maybe when anon_vma is reference counted, it'd be best to switch to
always locking the root anon_vma.

For the moment though, I reckon it's best to only have rmap_walk
concerned with the root anon_vma and have it take multiple locks.

> So either way works for me. 
> 
> > > 	if (!list_empty(&anon_vma->head)) {
> > 
> > Can it be empty? I didn't think it was possible as the anon_vma must
> > have at least it's own chain.
> 
> Ok, so that was answered in the other email - I think it's necessary in 
> the general case, although depending on exactly _how_ the page was looked 
> up, that may not be true.
> 
> If you have guarantees that the page is still mapped (thanks for page 
> table lock or something) and the anon_vma can't go away (just a read lock 
> on a mm_sem that was used to look up the page would also be sufficient), 
> that list_empty() check is unnecessary.
> 
> So it's a bit context-dependent.
> 
> 			Linus
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
