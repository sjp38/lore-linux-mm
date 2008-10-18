Date: Sat, 18 Oct 2008 20:14:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081018022541.GA19018@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810181952580.27309@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
 <20081018022541.GA19018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Sorry, I've only just got back to this, and just had one quick read
through the thread.  A couple of points on what I believe so far...

On Sat, 18 Oct 2008, Nick Piggin wrote:
> On Fri, Oct 17, 2008 at 07:11:38PM -0700, Linus Torvalds wrote:
> > On Sat, 18 Oct 2008, Nick Piggin wrote:
> > > 
> > > We can't do that, unfortuantely, because anon_vmas are allocated with
> > > SLAB_DESTROY_BY_RCU.
> > 
> > Aughh. I see what you're saying. We don't _free_ them by RCU, we just 
> > destroy the page allocation. So an anon_vma can get _re-allocated_ for 
> > another page (without being destroyed), concurrently with somebody 
> > optimistically being busy with that same anon_vma that they got through 
> > that optimistic 'page_lock_anon_vma()' thing.
> > 
> > So if we were to just set the lock, we might actually be messing with 
> > something that is still actively used by the previous page that was 
> > unmapped concurrently and still being accessed by try_to_unmap_anon. So 
> > even though we allocated a "new" anon_vma, it might still be busy.
> > 
> > Yes? No?

Yes, I believe Linus is right; but need to mull it over some more.
That not-taking-the-lock-on-newly-allocated optimization comes
from Andrea, and dates from before I removed the page_map_lock().
It looks like an optimization that was valid in Andrea's original,
but something I should have removed when going to SLAB_DESTROY_BY_RCU.

> 
> That's what I'm thinking, yes. But I admit the last time I looked at
> this really closely was probably reading through Hugh's patches and
> changelogs (which at the time must have convinced me ;)). So I could
> be wrong.
> 
> 
> > That thing really is too subtle for words. But if that's actually what you 
> > are alluding to, then doesn't that mean that we _really_ should be doing 
> > that "spin_lock(&anon_vma->lock)" even for the first allocation, and that 
> > the current code is broken? Because otherwise that other concurrent user 
> > that found the stale vma through page_lock_anon_vma() will now try to 
> > follow the linked list and _think_ it's stable (thanks to the lock), but 
> > we're actually inserting entries into it without holding any locks at all.
> 
> Yes, that's what I meant by "has other problems". Another thing is also
> that even if we have the lock here, I can't see why page_lock_anon_vma
> is safe against finding an anon_vma which has been deallocated then
> allocated for something else (and had vmas inserted into it etc.).

And Nick is right that page_lock_anon_vma() is not safe against finding
an anon_vma which has now been allocated for something else: but that
is no surprise, it's very much in the nature of SLAB_DESTROY_BY_RCU
(I left most of the comment in mm/slab.c, just said "tricky" here).

It should be no problem: having locked the right-or-perhaps-wrong
anon_vma, we then go on to search its list for a page which may or
may not be there, even when it's the right anon_vma; there's no need
for special code to deal with the very unlikely case that we've now
got an irrelevant list, it's just that the page we're looking for
won't be found in it.

But not-taking-the-lock-on-newly-allocated does then look wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
