Date: Fri, 17 Oct 2008 19:11:38 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081018013258.GA3595@wotan.suse.de>
Message-ID: <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org> <20081018013258.GA3595@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 18 Oct 2008, Nick Piggin wrote:
> > 
> > Side note: it would be nicer if we had a "spin_lock_init_locked()", so 
> > that we could avoid the more expensive "true lock" when doing the initial 
> > allocation, but we don't. That said, the case of having to allocate a new 
> > anon_vma _should_ be the rare one.
> 
> We can't do that, unfortuantely, because anon_vmas are allocated with
> SLAB_DESTROY_BY_RCU.

Aughh. I see what you're saying. We don't _free_ them by RCU, we just 
destroy the page allocation. So an anon_vma can get _re-allocated_ for 
another page (without being destroyed), concurrently with somebody 
optimistically being busy with that same anon_vma that they got through 
that optimistic 'page_lock_anon_vma()' thing.

So if we were to just set the lock, we might actually be messing with 
something that is still actively used by the previous page that was 
unmapped concurrently and still being accessed by try_to_unmap_anon. So 
even though we allocated a "new" anon_vma, it might still be busy.

Yes? No?

That thing really is too subtle for words. But if that's actually what you 
are alluding to, then doesn't that mean that we _really_ should be doing 
that "spin_lock(&anon_vma->lock)" even for the first allocation, and that 
the current code is broken? Because otherwise that other concurrent user 
that found the stale vma through page_lock_anon_vma() will now try to 
follow the linked list and _think_ it's stable (thanks to the lock), but 
we're actually inserting entries into it without holding any locks at all.

But I'm hoping I actually am totally *not* understanding what you meant, 
and am actually just terminally confused.

Hugh, this is very much your code. Can you please tell me I'm really 
confused here, and un-confuse me. Pretty please?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
