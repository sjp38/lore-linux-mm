Subject: Re: [patch] mm: fix anon_vma races
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0810191048410.11802@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de>
	 <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
	 <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
	 <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org>
	 <20081018013258.GA3595@wotan.suse.de>
	 <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
	 <20081018022541.GA19018@wotan.suse.de>
	 <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
	 <20081018052046.GA26472@wotan.suse.de> <1224326299.28131.132.camel@twins>
	 <Pine.LNX.4.64.0810191048410.11802@blonde.site>
Content-Type: text/plain
Date: Sun, 19 Oct 2008 12:51:40 +0200
Message-Id: <1224413500.10548.55.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-10-19 at 10:52 +0100, Hugh Dickins wrote:
> On Sat, 18 Oct 2008, Peter Zijlstra wrote:
> > 
> > fault_creation:
> > 
> >  anon_vma_prepare()
> >  page_add_new_anon_rmap();
> > 
> > expand_creation:
> > 
> >  anon_vma_prepare()
> >  anon_vma_lock();
> > 
> > rmap_lookup:
> > 
> >  page_referenced()/try_to_unmap()
> >    page_lock_anon_vma()
> > 
> > vma_lookup:
> > 
> >  vma_adjust()/vma_*
> >    vma->anon_vma
> > 
> > teardown:
> > 
> >  unmap_vmas()
> >    zap_range()
> >       page_remove_rmap()
> >       free_page()
> >  free_pgtables()
> >    anon_vma_unlink()
> >    free_range()
> >   
> > IOW we remove rmap, free the page (set mapping=NULL) and then unlink and
> > free the anon_vma.
> > 
> > But at that time vma->anon_vma is still set.
> > 
> > 
> > head starts to hurt,.. 
> 
> Comprehension isn't my strong suit at the moment: I don't grasp
> what problem you're seeing here - if you can spell it out in more
> detail for me, I'd like to try stopping your head hurt - though not
> at cost of making mine hurt more!

Heh, I meant to continue on this path more later yesterday, but weekend
chores kept me from it.

The above was my feeble attempt at getting an overview of what we do
with these anon_vma things so as to get a feel for the interaction.

I think my main concern in all this is validating that we have the right
anon_vma on dereference - both the vma->anon_vma and the page->mapping
one.

Part of the confusion is that we don't clear those pointers at the end
of their lifetimes (page_remove_rmap and anon_vma_unlink).

I guess the !page_mapping() test in page_lock_anon_vma() is meant to
deal with this, I think the point is that we have a stable page
reference, and thus the mapping is stable too (although
page_referenced() only holds a ref, and that could race with a fault
which would install the anon_vma? - still that looks a race the safe
way)

Still it looks odd to have a rcu_read_lock() section without and
rcu_dereference() or smp_read_depend barrier.

I think I see how the vma->anon_vma references work too, given the added
locking in anon_vma_prepare() proposed in this thread. But I need to
ponder those a bit more.

And alas, I need to run out again.. these weekends are too short.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
