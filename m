Date: Sun, 28 Jan 2007 14:29:25 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
Message-Id: <20070128142925.df2f4dce.akpm@osdl.org>
In-Reply-To: <1169993494.10987.23.camel@lappy>
References: <1169993494.10987.23.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jan 2007 15:11:34 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Eradicate global locks.
> 
>  - kmap_lock is removed by extensive use of atomic_t, a new flush
>    scheme and modifying set_page_address to only allow NULL<->virt
>    transitions.
> 
> A count of 0 is an exclusive state acting as an entry lock. This is done
> using inc_not_zero and cmpxchg. The restriction on changing the virtual
> address closes the gap with concurrent additions of the same entry.
> 
>  - pool_lock is removed by using the pkmap index for the
>    page_address_maps.
> 
> By using the pkmap index for the hash entries it is no longer needed to
> keep a free list.
> 
> This patch has been in -rt for a while but should also help regular
> highmem machines with multiple cores/cpus.

I really don't recall any performance problems being reported out of that
code in recent years.

As Christoph says, it's very much preferred that code be migrated over to
kmap_atomic().  Partly because kmap() is deadlockable in situations where a
large number of threads are trying to take two kmaps at the same time and
we run out.  This happened in the past, but incidences have gone away,
probably because of kmap->kmap_atomic conversions.

>From which callsite have you measured problems?

> Index: linux/include/linux/mm.h
> ===================================================================
> --- linux.orig/include/linux/mm.h
> +++ linux/include/linux/mm.h
> @@ -543,23 +543,39 @@ static __always_inline void *lowmem_page
>  #endif
>  
>  #if defined(WANT_PAGE_VIRTUAL)
> -#define page_address(page) ((page)->virtual)
> -#define set_page_address(page, address)			\
> -	do {						\
> -		(page)->virtual = (address);		\
> -	} while(0)
> -#define page_address_init()  do { } while(0)
> +/*
> + * wrap page->virtual so it is safe to set/read locklessly
> + */
> +#define page_address(page) \
> +	({ typeof((page)->virtual) v = (page)->virtual; \
> +	 smp_read_barrier_depends(); \
> +	 v; })
> +
> +static inline int set_page_address(struct page *page, void *address)
> +{
> +	if (address)
> +		return cmpxchg(&page->virtual, NULL, address) == NULL;
> +	else {
> +		/*
> +		 * cmpxchg is a bit abused because it is not guaranteed
> +		 * safe wrt direct assignment on all platforms.
> +		 */
> +		void *virt = page->virtual;
> +		return cmpxchg(&page->vitrual, virt, NULL) == virt;
> +	}
> +}

Have you verified that all architectures which can implement
WANT_PAGE_VIRTUAL also implement cmpxchg?

Have you verified that sufficient headers are included for this to compile
correctly on all WANT_PAGE_VIRTUAL-enabling architectures on all configs? 
I don't see asm/system.h being included in mm.h and if I get yet another
damned it-wont-compile patch I might do something irreversible.

> +static int pkmap_get_free(void)
>  {
> -	unsigned long vaddr;
> -	int count;
> +	int i, pos, flush;
> +	DECLARE_WAITQUEUE(wait, current);
>  
> -start:
> -	count = LAST_PKMAP;
> -	/* Find an empty entry */
> -	for (;;) {
> -		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;

The old code used masking.

> -		if (!last_pkmap_nr) {
> -			flush_all_zero_pkmaps();
> -			count = LAST_PKMAP;
> -		}
> -		if (!pkmap_count[last_pkmap_nr])
> -			break;	/* Found a usable entry */
> -		if (--count)
> -			continue;
> +restart:
> +	for (i = 0; i < LAST_PKMAP; i++) {
> +		pos = atomic_inc_return(&pkmap_hand) % LAST_PKMAP;

The new code does more-expensive modulus.  Necessary?

> +		flush = pkmap_try_free(pos);
> +		if (flush >= 0)
> +			goto got_one;
> +	}
> +
> +	/*
> +	 * wait for somebody else to unmap their entries
> +	 */
> +	__set_current_state(TASK_UNINTERRUPTIBLE);
> +	add_wait_queue(&pkmap_map_wait, &wait);
> +	schedule();
> +	remove_wait_queue(&pkmap_map_wait, &wait);

This looks wrong.  What happens if everyone else does their unmap between
the __set_current_state() and the add_wait_queue()?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
