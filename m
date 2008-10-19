Date: Sun, 19 Oct 2008 04:41:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081019024115.GA16562@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org> <Pine.LNX.4.64.0810190111250.25710@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810190111250.25710@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Oct 19, 2008 at 02:13:06AM +0100, Hugh Dickins wrote:
> On Fri, 17 Oct 2008, Linus Torvalds wrote:
> > On Fri, 17 Oct 2008, Linus Torvalds wrote:
> > > 
> > > But I think that what Nick did is correct - we always start traversal 
> > > through anon_vma->head, so no, the "list_add_tail()" won't expose it to 
> > > anybody else, because nobody else has seen the anon_vma().
> > > 
> > > That said, that's really too damn subtle. We shouldn't rely on memory 
> > > ordering for the list handling, when the list handling is _supposed_ to be 
> > > using that anon_vma->lock thing.
> > 
> > So maybe a better patch would be as follows? It simplifies the whole thing 
> > by just always locking and unlocking the vma, whether it's newly allocated 
> > or not (and whether it then gets dropped as unnecessary or not).
> > 
> > It still does that "smp_read_barrier_depends()" in the same old place. I 
> > don't have the energy to look at Hugh's point about people reading 
> > anon_vma without doing the whole "prepare" thing.
> > 
> > It adds more lines than it removes, but it's just because of the comments. 
> > With the locking simplification, it actually removes more lines of actual 
> > code than it adds. And now we always do that list_add_tail() with the 
> > anon_vma lock held, which should simplify thinking about this, and avoid 
> > at least one subtle ordering issue.
> > 
> > 		Linus
> 
> I'm slowly approaching the conclusion that this is the only patch
> which is needed here.
> 
> The newly-allocated "locked = NULL" mis-optimization still looks
> wrong to me in the face of SLAB_DESTROY_BY_RCU, and you kill that.
> 
> You also address Nick's second point about barriers: you've arranged
> them differently, but I don't think that matters; or the smp_wmb()
> could go into the "allocated = anon_vma" block, couldn't it?  that
> would reduce its overhead a little.  (If we needed more than an
> Alpha-barrier in the common path, then I'd look harder for a way
> to avoid it more often, but it'll do as is.)
> 
> I thought for a while that even the barriers weren't needed, because
> the only thing mmap.c and memory.c do with anon_vma (until they've
> up_readed mmap_sem and down_writed it to rearrange vmas) is note its
> address.  Then I found one exception, the use of anon_vma_lock()
> in expand_downwards() and expand_upwards() (it's not really being
> used as an anon_vma lock, just as a convenient spinlock to serialize
> concurrent stack faults for a moment): but I don't think that could
> ever actually need the barriers, the anon_vma for the stack should
> be well-established before there can be any racing threads on it.
> 
> But at last I realized the significant exception is right there in
> anon_vma_prepare(): the spin_lock(&anon_vma->lock) of an anon_vma
> coming back from find_mergeable_anon_vma() does need that lock to
> be visibly initialized - that is the clinching case for barriers.
> 
> That leaves Nick's original point, of the three CPUs with the third
> doing reclaim, with my point about needing smp_read_barrier_depends()
> over there.  I now think those races were illusory, that we were all
> overlooking something.  Reclaim (or page migration) doesn't arrive at
> those pages by scanning the old mem_map[] array, it gets them off an
> LRU list, whose spinlock is locked and unlocked to take them off; and
> the original faulting CPU had to lock and unlock that spinlock to put
> them on the LRU originally, at a stage after its anon_vma_prepare().
> 
> Surely we have enough barriers there to make sure that anon_vma->lock
> is visibly initialized by the time page_lock_anon_vma() tries to take
> it?

I don't think so. According to the race, the stores to anon_vma from
the first process would not arrive at the reclaimer in time. There
is no amount of barriers the reclaimer can perform to change this. But
anyway all that goes away if we just use locking properly as -per my
last patch (see below).


>  And it's not any kind of coincidence: isn't this a general pattern,
> that a newly initialized structure containing a lock is made available
> to other threads such as reclaim, and they can rely on that lock being
> visibly initialized, because the structure is made available to them
> by being put onto and examined on some separately locked list or tree?
> 
> Nick, are you happy with Linus's patch below?
> Or if not, please explain again what's missing - thanks.

No, I don't agree with the need for barriers and I think Linus had also
not worked through the whole problem at this point because of the
just-in-case barriers and hoping to initialise the newly allocated lock
as locked, as an optimisation.

With my patch, the rules are simple: anybody who wants to look in the
anon_vma or modify the anon_vma must take the anon_vma->lock. Then there
are no problems with ordering, and no need for any explicit barriers.

I don't understand your point about requiring ->lock to be initialised
coming from find_mergeable_anon_vma. Why? All the critical memory operations
get ordered inside the lock AFAIKS (I haven't actually applied Linus'
patch to see what the result is, but that should be the case with my
patch).

So, no. I still think my patch is the right one.


This btw. is modulo the final hunk of my last patch. That was supposed to
address the different, percieved issue I saw with getting an old anon_vma.
I still think that's pretty ugly even if correct. It would be nice just
to add the single branch (or better, just move one down) to avoid having
to think about it. I will submit a separate patch for that.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
