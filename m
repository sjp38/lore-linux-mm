Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 828A28D0047
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:48:35 -0400 (EDT)
Subject: Re: [PATCH 01/20] mm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110419130606.fb7139b2.akpm@linux-foundation.org>
References: <20110401121258.211963744@chello.nl>
	 <20110401121725.360704327@chello.nl>
	 <20110419130606.fb7139b2.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 10:47:28 +0200
Message-ID: <1303289248.8345.62.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Tue, 2011-04-19 at 13:06 -0700, Andrew Morton wrote:
> On Fri, 01 Apr 2011 14:12:59 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>=20
> > Remove the first obstackle towards a fully preemptible mmu_gather.
> >=20
> > The current scheme assumes mmu_gather is always done with preemption
> > disabled and uses per-cpu storage for the page batches. Change this to
> > try and allocate a page for batching and in case of failure, use a
> > small on-stack array to make some progress.
> >=20
> > Preemptible mmu_gather is desired in general and usable once
> > i_mmap_lock becomes a mutex. Doing it before the mutex conversion
> > saves us from having to rework the code by moving the mmu_gather
> > bits inside the pte_lock.
> >=20
> > Also avoid flushing the tlb batches from under the pte lock,
> > this is useful even without the i_mmap_lock conversion as it
> > significantly reduces pte lock hold times.
>=20
> There doesn't seem much point in reviewing this closely, as a lot of it
> gets tossed away later in the series..

That's a result of breaking patches along concept boundaries :/

> >  		free_pages_and_swap_cache(tlb->pages, tlb->nr);
>=20
> It seems inappropriate that this code uses
> free_page[s]_and_swap_cache().  It should go direct to put_page() and
> release_pages()?  Please review this code's implicit decision to pass
> "cold=3D=3D0" into release_pages().

Well, that isn't new with this patch, however it does look to be
correct. We're freeing user pages, those could indeed still be part of
the swapcache. Furthermore, the PAGEVEC_SIZE split in
free_pages_and_swap_cache() alone makes it worth calling that over
release_pages().

As to the cold=3D=3D0, I think that too is correct since we don't actually
touch the pages themselves and we have no inkling as to their cache
state, we're simply wiping out user pages.

> > -static inline void tlb_remove_page(struct mmu_gather *tlb, struct page=
 *page)
> > +static inline int __tlb_remove_page(struct mmu_gather *tlb, struct pag=
e *page)
>=20
> I wonder if all the inlining which remains in this code is needed and
> desirable.

Probably not, the big plan was to make everybody use the generic code
and then move it into mm/memory.c or so.

But I guess I can have asm-generic/tlb.h define HAVE_GENERIC_MMU_GATHER
and make the compilation in mm/memory.c conditional on that (or generate
lots of Kconfig churn).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
