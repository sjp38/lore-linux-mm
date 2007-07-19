Date: Wed, 18 Jul 2007 19:28:26 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Remove unnecessary smp_wmb from clear_user_highpage()
In-Reply-To: <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
Message-ID: <alpine.LFD.0.999.0707181912210.27353@woody.linux-foundation.org>
References: <20070718150514.GA21823@skynet.ie>
 <Pine.LNX.4.64.0707181645590.26413@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 18 Jul 2007, Hugh Dickins wrote:
> 
> Be careful: as Linus indicates, spinlocks on x86 act as good barriers,
> but on some architectures they guarantee no more than is strictly
> necessary.  alpha, powerpc and ia64 spring to my mind as particularly
> difficult ordering-wise, but I bet there are others too.

A full lock/unlock *pair* should (as far as I know) always be equivalent 
to a full memory barrier. Why? Because, by definition, no reads or writes 
inside the locked region may escape outside it, and that in turn implies 
that no access _outside_ the locked region may escape to the other side of 
it. 

I think.

However, neither a "lock" nor an "unlock" on *its*own* is a barrier at 
all, at most they are semi-permeable barriers for some things, where 
different architectures can be differently semi-permeable.

So if you have both a lock and an unlock between two points, you don't 
need any extra barriers, but if you only have one or the other, you'd need 
to add barriers.

And yes, on x86, just the "lock" part ends up being a total barrier, but 
that's not necessarily true on other architectures.

(Interestingly, it shouldn't matter "which way" the lock/unlock pair is: 
if the unlock of a previous lock was first, and a lock of another lock 
comes second, the *combination* of those two operations should still be a 
total memory barrier on the CPU that executed that pair, afaik, and it 
would be a bug if a memory op could escape from one critical region to the 
other. So "lock + unlock" and "unlock + lock" should both be equivalent to 
memory barriers, I think, even if neither of lock and unlock on their own 
is one).

> >     making the barrier unnecessary. A hint of lack of necessity is that there
> >     does not appear to be a read barrier anywhere for this zeroed page.
> 
> Yes, I think Nick was similarly suspicious of a wmb without an rmb; but
> Linus is _very_ barrier-savvy, so we might want to ask him about it (CC'ed).

A smp_wmb() should in general always have a paired smp_rmb(), or it's 
pointless. A special case is when the wmb() is between the "data" and the 
"exposure" of that data (ie the pointer write that makes the data 
visible), in which case the other end doesn't need a smp_rmb(), but may 
well still need a "smp_read_barrier_depends()".


> >  	void *addr = kmap_atomic(page, KM_USER0);
> >  	clear_user_page(addr, vaddr, page);
> >  	kunmap_atomic(addr, KM_USER0);
> > -	/* Make sure this page is cleared on other CPU's too before using it */
> > -	smp_wmb();

I suspect that the smp_wmb() is probably a good idea, since the 
"kunmap_atomic()" is generally a no-op, and other CPU's may read the page 
through the page tables without any other serialization.

And in that case, the others only need the "smp_read_barrier_depends()", 
and the fact is, that's a no-op for pretty much everybody, and a TLB 
lookup *has* to have that even on alpha, because otherwise the race is 
simply unfixable.

But I did *not* look through the whole sequence, so who knows. If there is 
a full lock/unlock pair between the clear_user_highpage() and actually 
making it available in the page tables, the wmb wouldn't be needed.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
