Date: Thu, 19 Jul 2007 04:58:07 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
Message-ID: <20070719025807.GE23641@wotan.suse.de>
References: <20070718150514.GA21823@skynet.ie> <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com> <alpine.LFD.0.999.0707181912210.27353@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707181912210.27353@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 18, 2007 at 07:28:26PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 18 Jul 2007, Hugh Dickins wrote:
> 
> > >     making the barrier unnecessary. A hint of lack of necessity is that there
> > >     does not appear to be a read barrier anywhere for this zeroed page.
> > 
> > Yes, I think Nick was similarly suspicious of a wmb without an rmb; but
> > Linus is _very_ barrier-savvy, so we might want to ask him about it (CC'ed).
> 
> A smp_wmb() should in general always have a paired smp_rmb(), or it's 
> pointless. A special case is when the wmb() is between the "data" and the 
> "exposure" of that data (ie the pointer write that makes the data 
> visible), in which case the other end doesn't need a smp_rmb(), but may 
> well still need a "smp_read_barrier_depends()".

I think the core mm should be OK, because setting and getting ptes should
(AFAIKS) always take the ptl. arch code that does lockless pte lookups
(ppc64's find_linux_pte for example seems to), and hardware fills of course
need a causal ordering there. So if there was something like find_linux_pte
used to load the TLB on alpha without smp_read_barrier_depends, I think
that would be a bug.


> > >  	void *addr = kmap_atomic(page, KM_USER0);
> > >  	clear_user_page(addr, vaddr, page);
> > >  	kunmap_atomic(addr, KM_USER0);
> > > -	/* Make sure this page is cleared on other CPU's too before using it */
> > > -	smp_wmb();
> 
> I suspect that the smp_wmb() is probably a good idea, since the 
> "kunmap_atomic()" is generally a no-op, and other CPU's may read the page 
> through the page tables without any other serialization.
> 
> And in that case, the others only need the "smp_read_barrier_depends()", 
> and the fact is, that's a no-op for pretty much everybody, and a TLB 
> lookup *has* to have that even on alpha, because otherwise the race is 
> simply unfixable.
> 
> But I did *not* look through the whole sequence, so who knows. If there is 
> a full lock/unlock pair between the clear_user_highpage() and actually 
> making it available in the page tables, the wmb wouldn't be needed.

Pretty sure Paulus, Ben, or Anton ran into it, yes. Actually, from
memory they submitted a variant on that patch which you didn't like ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
