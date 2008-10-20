Date: Mon, 20 Oct 2008 08:17:35 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <Pine.LNX.4.64.0810200427270.5543@blonde.site>
Message-ID: <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de>  <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>  <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>  <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>  <20081018013258.GA3595@wotan.suse.de>  <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>  <20081018022541.GA19018@wotan.suse.de>  <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
  <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>  <Pine.LNX.4.64.0810191048410.11802@blonde.site> <1224413500.10548.55.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
 <Pine.LNX.4.64.0810200427270.5543@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Oct 2008, Hugh Dickins wrote:
> 
> When you say "to the point where we don't need to care about anything
> else", are you there agreeing with Nick that your smp_wmb() and
> smp_read_barrier_depends() are no longer needed?

Yes. The anon_vma only has two fields: the spinlock itself, and the list. 
And with all list allocations being inside the spinlock, and with the 
spinlock itself being a memory barrier, I'm now convinced that the worry 
about memory ordering was unnecessary.

Well, not unnecessary, because I think the discussion was good, and I 
think we fixed another bug, but the smp_wmb++smp_read_barrier_depends does 
seem to be a non-issue in this path.

> But this is all _irrelevant_ : the tricky test to worry about in
> page_lock_anon_vma() is of page_mapped() i.e. does this page currently
> have any ptes in userspace, not of page_mapping() or page->mapping.

I'm not arguing for removing the page_mapped() we have now, I'm just 
wondering about the one Nick wanted to add at the end.

> In the case of file pages, it is in some places crucial to check
> page->mapping against a racing file truncation; but there's no such
> issue with anon pages, their page->mapping pointing to anon_vma is
> left set until the page is finally freed, it is not volatile.
> 
> But in the case of anon pages, what page->mapping points to may be
> volatile, in the sense that that memory might at some point get reused
> for a different anon_vma, or the slab page below it get freed and
> reused for a different purpose completely: that's what we have to
> careful of in the case of anon pages, and it's RCU and the
> page_mapped() test which guard that.

.. and I'm not worried about the slab page. It's stable, since we hold the 
RCU read-lock. No worries about that one either.

It's the "struct page" itself - the one we use for lookup in 
page_lock_anon_vma(). And I'm worried about the need for *re-doing* the 
page_mapped() test.

The problem that makes "page_lock_anon_vma()" such a total disaster is 
that yes, it does locking, but it does locking _after_ the lookup, and the 
lock doesn't actually protect any of the data that it is using for the 
lookup itself.

And yes, we have various tricks to try to make the data "safe" even if we 
race with the lookup, like the RCU stability of the anon_vma allocation, 
so that even if we race, we don't do anything bad. And I don't worry about 
the anon_vma, that part looks fine.

But page_remove_rmap() is run totally unlocked wrt page_lock_anon_vma(), 
it looks like. page_remove_rmap() is run under the pte lock, and 
page_lock_anon_vma() is run under no lock at all that I can see that is 
reliable.

So yes, we have the same kind of "delay the destroy" wrt page->mapping (ie 
page_remove_rmap() doesn't actually clear page->mapping at all), but none 
of this runs under any lock at all.

So as far as I can tell, the only reason "page_lock_anon_vma()" is safe is 
because we hopefully always hold an elevated page count when we call it, 
so at least the struct page itself will never get freed, so page->mapping 
is safe just because it's not cleared. 

But assuming all that is true, it boils down to this:

 - the anon_vma we get may be the wrong one or a stale one (since 
   page_remove_rmap ran concurrently and we ended up freeing the 
   anon_vma), but it's always a "valid" anon_vma in the sense that it's 
   initialized and the list is always pointing to *some* stable set of 
   vm_area_struct's.

 - if we raced, and the anon_vma is stale, we're going to walk over 
   some bogus list that pertains to a totally different page, but WHO 
   REALLY CARES? If it is about another page that got that anon_vma 
   reallocated to it, all the code that traverses the list of vma's still 
   has to check the page tables _anyway_. And that will never trigger, and 
   that will get the pte lock for checking anyway, so at _that_ point do 
   we correctly finally synchronize with a lock that is actually relevant.

 - the "anon_vma->lock" is totally irrelevant wrt "page_mapped()", and I'm 
   not seeing what it could possibly help to re-check after getting that 
   lock.

So what I'm trying to figure out is why Nick wanted to add another check 
for page_mapped(). I'm not seeing what it is supposed to protect against.

(Yes, we have checks for "page_mapped()" inside the "try_tp_unmap_xyz()" 
loops, but those are for a different reason - they're there to exit the 
loop early when we know there's no point. They don't claim to be about 
locking serialization).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
