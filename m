Date: Mon, 20 Oct 2008 05:03:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810200427270.5543@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
 <20081018013258.GA3595@wotan.suse.de>  <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
  <20081018022541.GA19018@wotan.suse.de>  <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
  <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>
  <Pine.LNX.4.64.0810191048410.11802@blonde.site>
 <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
 <alpine.LFD.2.00.0810191105090.4386@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Oct 2008, Linus Torvalds wrote:
> On Sun, 19 Oct 2008, Peter Zijlstra wrote:
> > 
> > Part of the confusion is that we don't clear those pointers at the end
> > of their lifetimes (page_remove_rmap and anon_vma_unlink).
> > 
> > I guess the !page_mapping() test in page_lock_anon_vma() is meant to
                !page_mapped()
> > deal with this
> 
> Hmm. So that part I'm still not entirely convinced about.
> 
> The thing is, we have two issues on anon_vma usage, and the
> page_lock_anon_vma() usage in particular:
> 
>  - the integrity of the list itself
> 
>    Here it should be sufficient to just always get the lock, to the point 
>    where we don't need to care about anything else. So getting the lock 
>    properly on new allocation makes all the other races irrelevant.

Yes, I should have removed anon_vma_prepare()'s optimization
of not locking a newly allocated struct anon_vma when I moved
page_lock_anon_vma() over to rely on SLAB_DESTROY_BY_RCU.

When you say "to the point where we don't need to care about anything
else", are you there agreeing with Nick that your smp_wmb() and
smp_read_barrier_depends() are no longer needed?

> 
>  - the integrity of the _result_ of traversing the list
> 
>    This is what the !page_mapping() thing is supposedly protecting 
                      !page_mapped()
>    against, I think.
> 
>    But as far as I can tell, there's really two different use cases here: 
>    (a) people who care deeply about the result and (b) people who don't.

You could look at it that way, but I don't think it's like that really.

IIRC at one time it was the case that every caller had the page already
locked when coming in here, but none of them could care too deeply about
the result because there was a trylock of the page_table_lock which could
fail on one of the paths.

Nowadays the only trylocking in rmap.c is one place where it's being
called without holding page lock: that doesn't matter for anon pages,
but matters for file pages because page->mapping could go NULL from
truncation at any instant without the page lock, and we do need page
->mapping to locate the prio_tree of vmas - in that case it trylocks
for page lock, and just assumes referenced if couldn't get it.

> 
>    And the difference between the two cases is whether they had the page 
>    locked or not. The "try_to_unmap()" callers care deeply, and lock the 
>    page. In contrast, some "page_referenced()" callers (really just 
>    shrink_active_list) don't care deeply, and to them the return value is 
>    really just a heuristic.
> 
> As far as I can tell, all the people who care deeply will lock the page 
> (and _have_ to lock the page), and thus 'page->mapping' should be stable 
> for those cases.

It's certainly true that try_to_unmap() callers care more deeply
than page_referenced() callers, and that the only trylock is on the
page_referenced() file path.

But this is all _irrelevant_ : the tricky test to worry about in
page_lock_anon_vma() is of page_mapped() i.e. does this page currently
have any ptes in userspace, not of page_mapping() or page->mapping.

In the case of file pages, it is in some places crucial to check
page->mapping against a racing file truncation; but there's no such
issue with anon pages, their page->mapping pointing to anon_vma is
left set until the page is finally freed, it is not volatile.

But in the case of anon pages, what page->mapping points to may be
volatile, in the sense that that memory might at some point get reused
for a different anon_vma, or the slab page below it get freed and
reused for a different purpose completely: that's what we have to
careful of in the case of anon pages, and it's RCU and the
page_mapped() test which guard that.

> 
> And then we have the other cases, who just want a heuristic, and they 
> don't hold the page lock, but if we look at the wrong active_vma that has 
                                                        anon_vma
> gotten reallocated to something else, they don't even really care. 

It's not that they don't care, it's that if the struct anon_vma has
gotten reallocated to something else, they can then be sure there's
no longer anything to care about.

The struct anon_vma bundles together in a list all those vmas which
might conceivably contain a pte of the page we're interested in.
If the anon_vma has gotten freed, even reallocated, or utterly reused,
that implies that its list of vmas was emptied, there's no longer any
vma which might contain that page.

> 
> So I'm not seeing the reason for that check for page_mapped() at the end. 
> Does it actually protect against anything relevant?

Absolutely, it is crucial that page_lock_anon_vma(page) checks
page_mapped(page) after doing the rcu_read_lock() and before doing
the spin_lock(&anon_vma->lock).

When we get into page_lock_anon_vma, we do not know whether what
page->mapping (less its PageAnon bit) points to is really still
the anon_vma for the page.  Maybe all the tasks which had that
page mapped at the time we last checked page_mapped(), have now
exited, their vmas and anon_vmas and mms been freed.

So first we rcu_read_lock(): and because the anon_vma cache is
SLAB_DESTROY_BY_RCU, we know that while we hold that, if the memory
is now pointing to an anon_vma type of object, it will remain
pointing to an anon_vma type of object until the rcu_read_unlock().

That's important because what we're really wanting to do is
spin_lock(&anon_vma->lock), but that would be a corrupting thing
to do if the struct anon_vma's memory has meanwhile got reused for
something else.

Okay, we've got rcu_read_lock() to stabilize the situation, but
we still do not know whether the memory pointed to by page->mapping
is still in use as an anon_vma.  Well, we don't try to answer
precisely that question: but if the page we're holding (caller
better have a reference on it!) has any ptes in userspace,
i.e. page_mapcount is raised, i.e. page_mapped is true,
then we can be sure that what it's pointing to is the anon_vma.
And if page_mapped isn't true any longer, then we're no longer
interested in getting that lock anyway and can just back out.

At any instant thereafter the tasks concerned may exit or unmap
the page, the vmas and anon_vmas and mms may get freed and reused;
but SLAB_DESTROY_BY_RCU guarantees that while we have rcu_read_lock()
that struct anon_vma will remain of type struct anon_vma, and we can
now safely spin_lock(&anon_vma->lock).

Once we've got that spin lock, we can safely (given the fix in your
patch) traverse the anon_vma list.  Maybe the struct anon_vma is
still relevant to our page, and maybe we'll find ptes of our page
in one or more of the vmas it bundles together; or maybe it's
still the right anon_vma, but our page gets unmapped while we
search and no ptes are found; or maybe that struct anon_vma has
just got freed back to slab and its list is empty; or maybe it
has meanwhile got reused for another unrelated bundle of vmas,
and we search that bundle for our page which won't be there -
that's okay, it's a very unlikely case, but it's allowed for.

> 
> Anyway, I _think_ the part that everybody agrees about is the initial 
> locking of the anon_vma. Whether we then even need any memory barriers 
> and/or the page_mapped() check is an independent question. Yes? No?
> 
> So I'm suggesting this commit as the part we at least all agree on. But I 
> haven't pushed it out yet, so you can still holler.. But I think all the 
> discussion is about other issues, and we all agree on at least this part?

Yes, agreed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
