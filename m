Date: Sun, 28 Oct 2007 17:10:36 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 09/10] SLUB: Do our own locking via slab_lock and
 slab_unlock.
In-Reply-To: <20071028033300.479692380@sgi.com>
Message-ID: <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033300.479692380@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Sat, 27 Oct 2007, Christoph Lameter wrote:
> Too many troubles with the bitlocks and we really do not need
> to do any bitops. Bitops do not effectively retrieve the old
> value which we want. So use a cmpxchg instead on the arches
> that allow it.

> -static inline int SlabFrozen(struct page *page)
> -{
> -	return page->flags & FROZEN;
> -}
> -
> -static inline void SetSlabFrozen(struct page *page)
> -{
> -	page->flags |= FROZEN;
> -}

[snip]

It would be easier to review the actual locking changes if you did the 
SlabXXX removal in a separate patch.

> +#ifdef __HAVE_ARCH_CMPXCHG
>  /*
>   * Per slab locking using the pagelock
>   */
> -static __always_inline void slab_lock(struct page *page)
> +static __always_inline void slab_unlock(struct page *page,
> +					unsigned long state)
>  {
> -	bit_spin_lock(PG_locked, &page->flags);
> +	smp_wmb();

Memory barriers deserve a comment. I suppose this is protecting 
page->flags but against what?

> +	page->flags = state;
> +	preempt_enable();

We don't need preempt_enable for CONFIG_SMP, right?

> +	 __release(bitlock);

This needs a less generic name and maybe a comment explaining that it's 
not annotating a proper lock? Or maybe we can drop it completely?

> +static __always_inline unsigned long slab_trylock(struct page *page)
> +{
> +	unsigned long state;
> +
> +	preempt_disable();
> +	state = page->flags & ~LOCKED;
> +#ifdef CONFIG_SMP
> +	if (cmpxchg(&page->flags, state, state | LOCKED) != state) {
> +		 preempt_enable();
> +		 return 0;
> +	}
> +#endif

This is hairy. Perhaps it would be cleaner to have totally separate 
functions for SMP and UP instead?

> -static __always_inline void slab_unlock(struct page *page)
> +static __always_inline unsigned long slab_lock(struct page *page)
>  {
> -	bit_spin_unlock(PG_locked, &page->flags);
> +	unsigned long state;
> +
> +	preempt_disable();
> +#ifdef CONFIG_SMP
> +	do {
> +		state = page->flags & ~LOCKED;
> +	} while (cmpxchg(&page->flags, state, state | LOCKED) != state);
> +#else
> +	state = page->flags & ~LOCKED;
> +#endif

Same here.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
