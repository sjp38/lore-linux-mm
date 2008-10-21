From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: fix anon_vma races
Date: Tue, 21 Oct 2008 13:56:12 +1100
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810200427270.5543@blonde.site> <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810211356.13191.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 21 October 2008 02:17, Linus Torvalds wrote:
> On Mon, 20 Oct 2008, Hugh Dickins wrote:

> > But in the case of anon pages, what page->mapping points to may be
> > volatile, in the sense that that memory might at some point get reused
> > for a different anon_vma, or the slab page below it get freed and
> > reused for a different purpose completely: that's what we have to
> > careful of in the case of anon pages, and it's RCU and the
> > page_mapped() test which guard that.
>
> .. and I'm not worried about the slab page. It's stable, since we hold the
> RCU read-lock. No worries about that one either.
>
> It's the "struct page" itself - the one we use for lookup in
> page_lock_anon_vma(). And I'm worried about the need for *re-doing* the
> page_mapped() test.
>
> The problem that makes "page_lock_anon_vma()" such a total disaster is
> that yes, it does locking, but it does locking _after_ the lookup, and the
> lock doesn't actually protect any of the data that it is using for the
> lookup itself.
>
> And yes, we have various tricks to try to make the data "safe" even if we
> race with the lookup, like the RCU stability of the anon_vma allocation,
> so that even if we race, we don't do anything bad. And I don't worry about
> the anon_vma, that part looks fine.
>
> But page_remove_rmap() is run totally unlocked wrt page_lock_anon_vma(),
> it looks like. page_remove_rmap() is run under the pte lock, and
> page_lock_anon_vma() is run under no lock at all that I can see that is
> reliable.
>
> So yes, we have the same kind of "delay the destroy" wrt page->mapping (ie
> page_remove_rmap() doesn't actually clear page->mapping at all), but none
> of this runs under any lock at all.
>
> So as far as I can tell, the only reason "page_lock_anon_vma()" is safe is
> because we hopefully always hold an elevated page count when we call it,
> so at least the struct page itself will never get freed, so page->mapping
> is safe just because it's not cleared.
>
> But assuming all that is true, it boils down to this:
>
>  - the anon_vma we get may be the wrong one or a stale one (since
>    page_remove_rmap ran concurrently and we ended up freeing the
>    anon_vma), but it's always a "valid" anon_vma in the sense that it's
>    initialized and the list is always pointing to *some* stable set of
>    vm_area_struct's.
>
>  - if we raced, and the anon_vma is stale, we're going to walk over
>    some bogus list that pertains to a totally different page, but WHO
>    REALLY CARES? If it is about another page that got that anon_vma
>    reallocated to it, all the code that traverses the list of vma's still
>    has to check the page tables _anyway_. And that will never trigger, and
>    that will get the pte lock for checking anyway, so at _that_ point do
>    we correctly finally synchronize with a lock that is actually relevant.
>
>  - the "anon_vma->lock" is totally irrelevant wrt "page_mapped()", and I'm
>    not seeing what it could possibly help to re-check after getting that
>    lock.
>
> So what I'm trying to figure out is why Nick wanted to add another check
> for page_mapped(). I'm not seeing what it is supposed to protect against.

It's not supposed to protect against anything that would be a problem
in the existing code (well, I initially thought it might be, but Hugh
explained why its not needed). I'd still like to put the check in, in
order to constrain this peculiarity of SLAB_DESTROY_BY_RCU to those
couple of functions which allocate or take a reference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
