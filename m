Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A71F26007B8
	for <linux-mm@kvack.org>; Mon,  3 May 2010 13:19:56 -0400 (EDT)
Date: Mon, 3 May 2010 10:17:26 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Take all anon_vma locks in anon_vma_lock
In-Reply-To: <4BDEFF9E.6080508@redhat.com>
Message-ID: <alpine.LFD.2.00.1005030958140.5478@i5.linux-foundation.org>
References: <20100503121743.653e5ecc@annuminas.surriel.com> <20100503121847.7997d280@annuminas.surriel.com> <alpine.LFD.2.00.1005030940490.5478@i5.linux-foundation.org> <4BDEFF9E.6080508@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>



On Mon, 3 May 2010, Rik van Riel wrote:
> > 
> > Pretty much same comments as for the other one. Why are we pandering to
> > the case that is/should be unusual?
> 
> In this case, because the fix from the migration side is
> difficult and fragile, while fixing things from the mmap
> side is straightforward.
> 
> I believe the overhead of patch 1/2 should be minimal
> as well, because the locks we take are the _depth_ of
> the process tree (truncated every exec), not the width.

Quite frankly, I think it's totally insane to walk a list of all 
anon_vma's that are associated with one vma, just to lock them all.

Tell me why you just don't put the lock in the vma itself then? Walking a 
list in order to lock multiple things is something we should _never_ do 
under any normal circumstances.

I can see why you'd want to do this in theory (the "other side" of the 
locker might have to lock just the _one_ anon_vma), but if your argument 
is that the list is usually not very deep ("one"?), then there is no 
advantage, because putting the lock in the anon_vma vs the vma will get 
the same kind of contention.

And if the list _is_ deep, then walking the list to lock them all is a 
crime against humanity.

So explain.

> As for patch 2/2, Mel has an alternative approach for that:
> 
> http://lkml.org/lkml/2010/4/30/198
> 
> Does Mel's patch seem more reasonable to you?

Well, I certainly think that seems to be a lot more targeted, and not add 
new allocations in a path that I think is already one of the more 
expensive ones. Yes, you can argue that execve() is already so expensive 
that a few more allocations don't matter, and you migth be right, but 
that's how things get to be too expensive to begin with.

That said, I do still wonder why we shouldn't just say that the person who 
wants the safety is the one that should do the extra work.

In particular, why don't we just make rmap_walk() be the one that locks 
all the anon_vma's? Instead of locking just one? THAT is the function that 
cares. THAT is the function that should do proper locking and not expect 
others to do extra unnecessary locking.

So again, my gut feel is that if the lock just were in the vma itself, 
then the "normal" users would have just one natural lock, while the 
special case users (rmap_walk_anon) would have to lock each vma it 
traverses. That would seem to be the more natural way to lock things.

I dunno. There may well be reasons why it doesn't work, like just the 
allocation lifetime rules for vma's vs anon_vma's. I'm not claiming I've 
thought this true. I just get a feeling of "that isn't right" when I look 
at the original 2/2 patch, and while Mel's patch certainly looks better, 
it seems to be a bit ad-hoc and hacky to me.

Btw, Mel's patch doesn't really match the description of 2/2. 2/2 says 
that all pages must always be findable in rmap. Mel's patch seems to 
explicitly say "we want to ignore that thing that is busy for execve". Are 
we just avoiding a BUG_ON()? Is perhaps the BUG_ON() buggy?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
