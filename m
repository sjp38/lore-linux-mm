Subject: Re: [PATCH] mm: remove global locks from mm/highmem.c
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070128142925.df2f4dce.akpm@osdl.org>
References: <1169993494.10987.23.camel@lappy>
	 <20070128142925.df2f4dce.akpm@osdl.org>
Content-Type: text/plain
Date: Mon, 29 Jan 2007 10:44:08 +0100
Message-Id: <1170063848.6189.121.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-01-28 at 14:29 -0800, Andrew Morton wrote:

> As Christoph says, it's very much preferred that code be migrated over to
> kmap_atomic().  Partly because kmap() is deadlockable in situations where a
> large number of threads are trying to take two kmaps at the same time and
> we run out.  This happened in the past, but incidences have gone away,
> probably because of kmap->kmap_atomic conversions.

> From which callsite have you measured problems?

CONFIG_HIGHPTE code in -rt was horrid. I'll do some measurements on
mainline.

> > Index: linux/include/linux/mm.h
> > ===================================================================
> > --- linux.orig/include/linux/mm.h
> > +++ linux/include/linux/mm.h
> > @@ -543,23 +543,39 @@ static __always_inline void *lowmem_page
> >  #endif
> >  
> >  #if defined(WANT_PAGE_VIRTUAL)
> > -#define page_address(page) ((page)->virtual)
> > -#define set_page_address(page, address)			\
> > -	do {						\
> > -		(page)->virtual = (address);		\
> > -	} while(0)
> > -#define page_address_init()  do { } while(0)
> > +/*
> > + * wrap page->virtual so it is safe to set/read locklessly
> > + */
> > +#define page_address(page) \
> > +	({ typeof((page)->virtual) v = (page)->virtual; \
> > +	 smp_read_barrier_depends(); \
> > +	 v; })
> > +
> > +static inline int set_page_address(struct page *page, void *address)
> > +{
> > +	if (address)
> > +		return cmpxchg(&page->virtual, NULL, address) == NULL;
> > +	else {
> > +		/*
> > +		 * cmpxchg is a bit abused because it is not guaranteed
> > +		 * safe wrt direct assignment on all platforms.
> > +		 */
> > +		void *virt = page->virtual;
> > +		return cmpxchg(&page->vitrual, virt, NULL) == virt;
> > +	}
> > +}
> 
> Have you verified that all architectures which can implement
> WANT_PAGE_VIRTUAL also implement cmpxchg?

It might have been my mistaken in understanding the latest cmpxchg
thread. My understanding was that since LL/SC is not exposable as a low
level primitive all platforms should implement a cmpxchg where some
would not be save against direct assignment.

Anyway, I'll do as Nick says and replace it with atomic_long_cmpxchg.

> Have you verified that sufficient headers are included for this to compile
> correctly on all WANT_PAGE_VIRTUAL-enabling architectures on all configs? 
> I don't see asm/system.h being included in mm.h and if I get yet another
> damned it-wont-compile patch I might do something irreversible.

Point taken.

> > +static int pkmap_get_free(void)
> >  {
> > -	unsigned long vaddr;
> > -	int count;
> > +	int i, pos, flush;
> > +	DECLARE_WAITQUEUE(wait, current);
> >  
> > -start:
> > -	count = LAST_PKMAP;
> > -	/* Find an empty entry */
> > -	for (;;) {
> > -		last_pkmap_nr = (last_pkmap_nr + 1) & LAST_PKMAP_MASK;
> 
> The old code used masking.
> 
> > -		if (!last_pkmap_nr) {
> > -			flush_all_zero_pkmaps();
> > -			count = LAST_PKMAP;
> > -		}
> > -		if (!pkmap_count[last_pkmap_nr])
> > -			break;	/* Found a usable entry */
> > -		if (--count)
> > -			continue;
> > +restart:
> > +	for (i = 0; i < LAST_PKMAP; i++) {
> > +		pos = atomic_inc_return(&pkmap_hand) % LAST_PKMAP;
> 
> The new code does more-expensive modulus.  Necessary?

I thought GCC would automagically use masking when presented with a
power-of-two constant. Can make it more explicit though.

> > +		flush = pkmap_try_free(pos);
> > +		if (flush >= 0)
> > +			goto got_one;
> > +	}
> > +
> > +	/*
> > +	 * wait for somebody else to unmap their entries
> > +	 */
> > +	__set_current_state(TASK_UNINTERRUPTIBLE);
> > +	add_wait_queue(&pkmap_map_wait, &wait);
> > +	schedule();
> > +	remove_wait_queue(&pkmap_map_wait, &wait);
> 
> This looks wrong.  What happens if everyone else does their unmap between
> the __set_current_state() and the add_wait_queue()?

Eek, you are quite right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
