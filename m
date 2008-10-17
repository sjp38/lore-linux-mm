Date: Fri, 17 Oct 2008 16:53:39 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
Message-ID: <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 18 Oct 2008, Peter Zijlstra wrote:
> On Thu, 2008-10-16 at 06:10 +0200, Nick Piggin wrote:
> 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> > Index: linux-2.6/mm/rmap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/rmap.c
> > +++ linux-2.6/mm/rmap.c
> > @@ -81,8 +81,15 @@ int anon_vma_prepare(struct vm_area_stru
> >  		/* page_table_lock to protect against threads */
> >  		spin_lock(&mm->page_table_lock);
> >  		if (likely(!vma->anon_vma)) {
> > -			vma->anon_vma = anon_vma;
> >  			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
> > +			/*
> > +			 * This smp_wmb() is required to order all previous
> > +			 * stores to initialize the anon_vma (by the slab
> > +			 * ctor) and add this vma, with the store to make it
> > +			 * visible to other CPUs via vma->anon_vma.
> > +			 */
> > +			smp_wmb();
> > +			vma->anon_vma = anon_vma;
> 
> I'm not getting why you explicitly move the list_add_tail() before the
> wmb, doesn't the list also expose the anon_vma to other cpus?

I do think the anon_vma locking might be good to look over. It is very 
non-obvious. Especially the initial create is really really quite suspect. 
I suspect we should start out with the anon-vma locked, and do the

	spin_unlock(&anon_vma->lock);

unconditionally in anon_vma_prepare(), and just simplify it. As it is, 
newly allocated anon_vma's get exposed in unlocked state while we're still 
working on them.

But I think that what Nick did is correct - we always start traversal 
through anon_vma->head, so no, the "list_add_tail()" won't expose it to 
anybody else, because nobody else has seen the anon_vma().

That said, that's really too damn subtle. We shouldn't rely on memory 
ordering for the list handling, when the list handling is _supposed_ to be 
using that anon_vma->lock thing.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
