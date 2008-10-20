Date: Mon, 20 Oct 2008 19:21:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810201809380.689@blonde.site>
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
 <Pine.LNX.4.64.0810200427270.5543@blonde.site>
 <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008, Linus Torvalds wrote:
> On Mon, 20 Oct 2008, Hugh Dickins wrote:
> > 
> > When you say "to the point where we don't need to care about anything
> > else", are you there agreeing with Nick that your smp_wmb() and
> > smp_read_barrier_depends() are no longer needed?
> 
> Yes. The anon_vma only has two fields: the spinlock itself, and the list. 
> And with all list allocations being inside the spinlock, and with the 
> spinlock itself being a memory barrier, I'm now convinced that the worry 
> about memory ordering was unnecessary.

Okay, thanks, that's a relief.  I'm afraid that once a barrier discussion
comes up and we insert them, then I become dazedly paranoid and it's very
hard to shake me from seeing a need for barriers everywhere, including a
barrier before and after every barrier ad infinitum to make sure they're
really barriers.

I still get a twinge of anxiety seeing anon_vma_prepare()'s unlocked
	if (unlikely(!anon_vma)) {
since it looks like the kind of thing that can be a problem.  But on
reflection, I guess there are lots and lots of places where we do such
opportunistic checks before going the slow path taking the lock.

> 
> Well, not unnecessary, because I think the discussion was good, and I 
> think we fixed another bug,

Yes, that was a valuable find, which Nick's ctor aberration led us to.
Though whether it ever bit anyone, I doubt.  We did have a spate of
anon_vma corruptions 2.5 years ago, but I think they were just one
manifestation of some more general slab corruption, don't match this.

> but the smp_wmb++smp_read_barrier_depends does 
> seem to be a non-issue in this path.
> 
> > But this is all _irrelevant_ : the tricky test to worry about in
> > page_lock_anon_vma() is of page_mapped() i.e. does this page currently
> > have any ptes in userspace, not of page_mapping() or page->mapping.
> 
> I'm not arguing for removing the page_mapped() we have now, I'm just 
> wondering about the one Nick wanted to add at the end.

Oh, that, sorry I didn't realize - but there again, it was well
worth my writing it down again, else I wouldn't have corrected
my embarrassingly mistaken goahead to Nick on moving the check.

[snipped a lot of good understanding of how it works]

> So what I'm trying to figure out is why Nick wanted to add another check 
> for page_mapped(). I'm not seeing what it is supposed to protect against.

I think it's a matter of mental comfort, or good interface design.

You're right that it will make no actual difference to what happens
in its two sole callers page_referenced_anon() and try_to_unmap_anon(),
beyond adding an extra branch to short-circuit a futile search which
would already terminate after the first iteration (each loop already
has a page_mapped test, to get out a.s.a.p. if the list is very long).

But (particularly because he didn't realize it could happen: I put
no comment there beyond "tricky") he thinks it would be better to
know that when you emerge from a successful page_lock_anon_vma(),
then the anon_vma you have is indeed still the right one for the
page (as you noted, we do assume caller holds a reference on page).

One might argue that a comment would be better than a runtime test:
so long as page_lock_anon_vma() is a static function with just those
two callers.

In writing this, another barrier anxiety crossed my mind.  I've made
a big deal of checking page_mapped after getting rcu_read_lock, but
now I wonder if another barrier is needed for that.

Documentation/memory-barriers.txt "LOCKING FUNCTIONS" groups RCU along
with spin locks in discussing their semipermeable characteristics, so
I guess no extra barrier needed; but it does work rather differently.

In CLASSIC_RCU the preempt_disable() has a compiler barrier() but
not any processor *mb().  As I understand it, that's fine because if
page->_mapcount was loaded before the preempt_disable and we don't
preempt before the preempt_disable, then so what, that's okay; and
if we are preempted immediately before the preempt_disable, then
all the business of context switch is sure to reload it again after.

In PREEMPT_RCU?  I don't know, that's some study I've never got
around to; but I think you and Peter will know whether it's good.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
