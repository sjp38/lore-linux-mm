Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 673066B0255
	for <linux-mm@kvack.org>; Wed,  5 May 2010 14:36:13 -0400 (EDT)
Date: Wed, 5 May 2010 11:34:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100505181456.GV20979@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005051118540.27218@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
 <20100505155454.GT20979@csn.ul.ie> <alpine.LFD.2.00.1005051007140.27218@i5.linux-foundation.org> <20100505181456.GV20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>



On Wed, 5 May 2010, Mel Gorman wrote:
> 
> In the direction I was taking, only rmap_walk took the deepest lock (I called
> it oldest but hey) and would take other anon_vma locks as well. The objective
> was to make sure the order the locks were taken in was correct.
>
> I think you are suggesting that any anon_vma lock that is taken should always
> take the deepest lock. Am I right and is that necessary? The downsides is that
> there is a single lock that is hotter. The upside is that rmap_walk no longer
> has different semantics as vma_adjust and friends because it's the same lock.

I could personally go either way, I don't really care that deeply.

I think you could easily just take the root lock in the rmap_walk_anon/ksm 
paths, and _also_ take the individual locks as you walk it (safe, since 
now the root lock avoids the ABBA issue - you only need to compare the 
individual lock against the root lock to not take it twice, of course).

Or you could take the "heavy lock" approach that Andrea was arguing for, 
but rather than iterating you'd just take the root lock.

I absolutely _hated_ the "iterate over all locks in the normal case" idea, 
but with the root lock it's much more targeted and no longer is about 
nested locks of the same type.

So the things I care about are just:

 - I hate that "retry" logic that made things more complex and had the 
   livelock problem.

   The "root lock" helper function certainly wouldn't be any fewer lines 
   than your retry version, but it's a clearly separate locking function, 
   rather than mixed in with the walking code. And it doesn't do livelock.

 - I detest "take all locks" in normal paths. I'm ok with it for special 
   case code (and I think the migrate code counts as special case), but I 
   think it was really horribly and fundamentally wrong in that "mm: Take 
   all anon_vma locks in anon_vma_lock" patch I saw.

but whether we want to take the root lock in "anon_vma_lock()" or not is 
just a "detail" as far as I'm concerned. It's no longer "horribly wrong". 
It might have scalability issues etc, of course, but likely only under 
insane loads.

So either way works for me. 

> > 	if (!list_empty(&anon_vma->head)) {
> 
> Can it be empty? I didn't think it was possible as the anon_vma must
> have at least it's own chain.

Ok, so that was answered in the other email - I think it's necessary in 
the general case, although depending on exactly _how_ the page was looked 
up, that may not be true.

If you have guarantees that the page is still mapped (thanks for page 
table lock or something) and the anon_vma can't go away (just a read lock 
on a mm_sem that was used to look up the page would also be sufficient), 
that list_empty() check is unnecessary.

So it's a bit context-dependent.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
