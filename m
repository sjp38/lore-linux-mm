Date: Sun, 28 Oct 2007 20:03:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] SLUB: Do our own locking via slab_lock and
 slab_unlock.
In-Reply-To: <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0710282001000.28636@schroedinger.engr.sgi.com>
References: <20071028033156.022983073@sgi.com> <20071028033300.479692380@sgi.com>
 <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2007, Pekka J Enberg wrote:

> It would be easier to review the actual locking changes if you did the 
> SlabXXX removal in a separate patch.

There are no locking changes.

> > -static __always_inline void slab_lock(struct page *page)
> > +static __always_inline void slab_unlock(struct page *page,
> > +					unsigned long state)
> >  {
> > -	bit_spin_lock(PG_locked, &page->flags);
> > +	smp_wmb();
> 
> Memory barriers deserve a comment. I suppose this is protecting 
> page->flags but against what?

Its making sure that the changes to page flags are made visible after all 
other changes.

> 
> > +	page->flags = state;
> > +	preempt_enable();
> 
> We don't need preempt_enable for CONFIG_SMP, right?

preempt_enable is needed if preemption is enabled.

> 
> > +	 __release(bitlock);
> 
> This needs a less generic name and maybe a comment explaining that it's 
> not annotating a proper lock? Or maybe we can drop it completely?

Probably.

> > +static __always_inline unsigned long slab_trylock(struct page *page)
> > +{
> > +	unsigned long state;
> > +
> > +	preempt_disable();
> > +	state = page->flags & ~LOCKED;
> > +#ifdef CONFIG_SMP
> > +	if (cmpxchg(&page->flags, state, state | LOCKED) != state) {
> > +		 preempt_enable();
> > +		 return 0;
> > +	}
> > +#endif
> 
> This is hairy. Perhaps it would be cleaner to have totally separate 
> functions for SMP and UP instead?

I think that is reasonably clear. Having code duplicated is not good 
either. Well we may have to clean this up a bit.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
