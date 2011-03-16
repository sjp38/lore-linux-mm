Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA478D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:57:20 -0400 (EDT)
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110310155032.GB32302@csn.ul.ie>
References: <20110217162327.434629380@chello.nl>
	 <20110217163234.823185666@chello.nl>  <20110310155032.GB32302@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 16 Mar 2011 19:55:42 +0100
Message-ID: <1300301742.2203.1899.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Thu, 2011-03-10 at 15:50 +0000, Mel Gorman wrote:

> > +static inline void
> > +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned =
int full_mm_flush)
> >  {
>=20
> checkpatch will bitch about line length.

I did a s/full_mm_flush/fullmm/ which puts the line length at 81. At
which point I'll ignore it ;-)

> > -	struct mmu_gather *tlb =3D &get_cpu_var(mmu_gathers);
> > -
> >  	tlb->mm =3D mm;
> > =20
> > -	/* Use fast mode if only one CPU is online */
> > -	tlb->nr =3D num_online_cpus() > 1 ? 0U : ~0U;
> > +	tlb->max =3D ARRAY_SIZE(tlb->local);
> > +	tlb->pages =3D tlb->local;
> > +
> > +	if (num_online_cpus() > 1) {
> > +		tlb->nr =3D 0;
> > +		__tlb_alloc_page(tlb);
> > +	} else /* Use fast mode if only one CPU is online */
> > +		tlb->nr =3D ~0U;
> > =20
> >  	tlb->fullmm =3D full_mm_flush;
> > =20
> > -	return tlb;
> > +#ifdef HAVE_ARCH_MMU_GATHER
> > +	tlb->arch =3D ARCH_MMU_GATHER_INIT;
> > +#endif
> >  }
> > =20
> >  static inline void
> > -tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned lo=
ng end)
> > +tlb_flush_mmu(struct mmu_gather *tlb)
>=20
> Removing start/end here is a harmless, but unrelated cleanup. Is it
> worth keeping start/end on the rough off-chance the information is ever
> used to limit what portion of the TLB is flushed?

I've got another patch that adds full range tracking to
asm-generic/tlb.h, it uses tlb_remove_tlb_entry()/p.._free_tlb() to
track the range of the things actually removed.

> >  {
> >  	if (!tlb->need_flush)
> >  		return;
> > @@ -75,6 +95,8 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
> >  	if (!tlb_fast_mode(tlb)) {
> >  		free_pages_and_swap_cache(tlb->pages, tlb->nr);
> >  		tlb->nr =3D 0;
> > +		if (tlb->pages =3D=3D tlb->local)
> > +			__tlb_alloc_page(tlb);
> >  	}
>=20
> That needs a comment. Something like
>=20
> /*
>  * If we are using the local on-stack array of pages for MMU gather,
>  * try allocation again as we have recently freed pages
>  */

Fair enough, done.

> >  }
> > =20

> > @@ -98,16 +121,24 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
> >   *	handling the additional races in SMP caused by other CPUs caching v=
alid
> >   *	mappings in their TLBs.
> >   */
> > -static inline void tlb_remove_page(struct mmu_gather *tlb, struct page=
 *page)
> > +static inline int __tlb_remove_page(struct mmu_gather *tlb, struct pag=
e *page)
> >  {
>=20
> What does this return value mean?

Like you surmise below, that we need to call tlb_flush_mmu() before
calling more of __tlb_remove_page().

> Looking at the function, its obvious that 1 is returned when pages[] is f=
ull
> and needs to be freed, TLB flushed, etc. However, callers refer the retur=
n
> value as "need_flush" where as this function sets tlb->need_flush but the
> two values have different meaning: retval need_flush means the array is f=
ull
> and must be emptied where as tlb->need_flush just says there are some pag=
es
> that need to be freed.
>=20
> It's a nit-pick but how about having it return the number of array slots
> that are still available like what pagevec_add does? It would allow you
> to get rid of the slighty-different need_flush variable in mm/memory.c

That might work, let me do so.

> >  	tlb->need_flush =3D 1;
> >  	if (tlb_fast_mode(tlb)) {
> >  		free_page_and_swap_cache(page);
> > -		return;
> > +		return 0;
> >  	}
> >  	tlb->pages[tlb->nr++] =3D page;
> > -	if (tlb->nr >=3D FREE_PTE_NR)
> > -		tlb_flush_mmu(tlb, 0, 0);
> > +	if (tlb->nr >=3D tlb->max)
> > +		return 1;
> > +
>=20
> Use =3D=3D and VM_BUG_ON(tlb->nr > tlb->max) ?

Paranoia, I like ;-)

> > +	return 0;
> > +}
> > +

> > @@ -974,7 +975,7 @@ static unsigned long zap_pte_range(struc
> >  			page_remove_rmap(page);
> >  			if (unlikely(page_mapcount(page) < 0))
> >  				print_bad_pte(vma, addr, ptent, page);
> > -			tlb_remove_page(tlb, page);
> > +			need_flush =3D __tlb_remove_page(tlb, page);
> >  			continue;
>=20
> So, if __tlb_remove_page() returns 1 (should be bool for true/false) the
> caller is expected to call tlb_flush_mmu(). We call continue and as a
> side-effect break out of the loop unlocking various bits and pieces and
> restarted.
>=20
> It'd be a hell of a lot clearer to just say
>=20
> if (__tlb_remove_page(tlb, page))
> 	break;
>=20
> and not check !need_flush on each iteration.

Uhm,. right :-), /me wonders why he wrote it like it was.

> >  		}
> >  		/*
> > @@ -995,12 +996,20 @@ static unsigned long zap_pte_range(struc
> >  				print_bad_pte(vma, addr, ptent, NULL);
> >  		}
> >  		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> > -	} while (pte++, addr +=3D PAGE_SIZE, (addr !=3D end && *zap_work > 0)=
);
> > +	} while (pte++, addr +=3D PAGE_SIZE,
> > +			(addr !=3D end && *zap_work > 0 && !need_flush));
> > =20
> >  	add_mm_rss_vec(mm, rss);
> >  	arch_leave_lazy_mmu_mode();
> >  	pte_unmap_unlock(pte - 1, ptl);
> > =20
> > +	if (need_flush) {
> > +		need_flush =3D 0;
> > +		tlb_flush_mmu(tlb);
> > +		if (addr !=3D end)
> > +			goto again;
> > +	}
>=20
> So, I think the reasoning here is to update counters and release locks
> regularly while tearing down pagetables. If this is true, it could do wit=
h
> a comment explaining that's the intention. You can also obviate the need
> for the local need_flush here with just if (tlb->need_flush), right?

I'll add a comment. tlb->need_flush is not quite the same, its set as
soon as there's one page in, our need_flush is when there's no space
left. I should have spotted this confusion before.


>=20
> Functionally I didn't see any problems. Comments are more about form
> than function. Whether you apply them or not
>=20
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
