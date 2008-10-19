Date: Sun, 19 Oct 2008 13:39:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0810191256580.23569@blonde.site>
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
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Oct 2008, Peter Zijlstra wrote:
> 
> I think my main concern in all this is validating that we have the right
> anon_vma on dereference - both the vma->anon_vma and the page->mapping
> one.
> 
> Part of the confusion is that we don't clear those pointers at the end
> of their lifetimes (page_remove_rmap and anon_vma_unlink).

Yes, I would very much have liked to clear it in page_remove_rmap(),
as I say there: it's still feels ugly to be cleaning up after it in
free_hot_cold_page() (gosh! and that's still the name of where it
happens!), though there are some good debug advantages to having it
set indefinitely too.

Clearing vma->anon_vma at the end, I don't think I ever cared about
that: it's very common to kfree() something without resetting the
pointers to it, I don't think there's any worrying race in its case.

> 
> I guess the !page_mapping() test in page_lock_anon_vma() is meant to
              !page_mapped()
> deal with this, I think the point is that we have a stable page
> reference, and thus the mapping is stable too (although
> page_referenced() only holds a ref, and that could race with a fault
> which would install the anon_vma? - still that looks a race the safe
> way)

page_lock_anon_vma() is like those scenes where sailors are pulleyed
down a rope from one ship to another in stormy mid-ocean.  There,
now you understand it, need I say more?

If we see page_mapcount is raised (in the RCU locked section), we
can be sure that the slab page which the struct anon_vma rests on
will not get freed and reused for something else: page_mapcount
may go down to 0 at any instant, but having been non-0, we are
assured that anon_vma->lock will remain the spinlock in a struct
anon_vma, even if by the time we've acquired that spinlock, that
particular piece of memory has been freed and reused for the
anon_vma of another group of vmas altogether.

Certainly mapcount could also go up and another vma be added to
the anon_vma's list while we wait to get the spinlock, as you say,
but that's no worry.

> 
> Still it looks odd to have a rcu_read_lock() section without and
> rcu_dereference() or smp_read_depend barrier.

At the 2.6.8 time I wrote it, I was using preempt_disable() and
preempt_enable(), and there was no such thing as rcu_dereference().
But I don't think it's now lacking in that respect: the whole idea
was to keep almost all of the code free of RCU worries, just
concentrate them all into page_lock_anon_vma() (and slab.c).

> 
> I think I see how the vma->anon_vma references work too, given the added
> locking in anon_vma_prepare() proposed in this thread. But I need to
> ponder those a bit more.
> 
> And alas, I need to run out again.. these weekends are too short.

I know the feeling: I also seem to have promised many too many
people that I'll be attending to this or that at the weekend.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
