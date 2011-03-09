Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0339D8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 10:39:36 -0500 (EST)
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1299684963.19820.344.camel@e102109-lin.cambridge.arm.com>
References: <20110302175928.022902359@chello.nl>
	 <20110302180259.109909335@chello.nl>
	 <AANLkTimbRS++SCcKGrUcL5xKsCO+1ygkg+83x7F+2S4i@mail.gmail.com>
	 <1299683964.2308.3075.camel@twins>
	 <1299684963.19820.344.camel@e102109-lin.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 09 Mar 2011 16:39:10 +0100
Message-ID: <1299685150.2308.3097.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 2011-03-09 at 15:36 +0000, Catalin Marinas wrote:
> On Wed, 2011-03-09 at 15:19 +0000, Peter Zijlstra wrote:
> > On Wed, 2011-03-09 at 15:16 +0000, Catalin Marinas wrote:
> > > Hi Peter,
> > >
> > > On 2 March 2011 17:59, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > > --- linux-2.6.orig/arch/arm/include/asm/tlb.h
> > > > +++ linux-2.6/arch/arm/include/asm/tlb.h
> > > [...]
> > > > +__pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned lon=
g addr)
> > > >  {
> > > >        pgtable_page_dtor(pte);
> > > > -       tlb_add_flush(tlb, addr);
> > > >        tlb_remove_page(tlb, pte);
> > > >  }
> > >
> > > I think we still need a tlb_track_range() call here. On the path to
> > > pte_free_tlb() (for example shift_arg_pages ... free_pte_range) there
> > > doesn't seem to be any code setting the tlb->start/end range. Did I
> > > miss anything?
> >=20
> > Patch 3 included:
> >=20
> > -#define pte_free_tlb(tlb, ptep, address)                       \
> > -       do {                                                    \
> > -               tlb->need_flush =3D 1;                            \
> > -               __pte_free_tlb(tlb, ptep, address);             \
> > +#define pte_free_tlb(tlb, ptep, address)                              =
         \
> > +       do {                                                           =
         \
> > +               tlb->need_flush =3D 1;                                 =
           \
> > +               tlb_track_range(tlb, address, pmd_addr_end(address, TAS=
K_SIZE));\
> > +               __pte_free_tlb(tlb, ptep, address);                    =
         \
> >         } while (0)
>=20
> OK, so the range is tracked. The only issue is that for platforms with a
> folded pmd the range end would go to TASK_SIZE. In this case
> pgd_addr_end() would make more sense (or something like
> PTRS_PER_PTE*PAGE_SIZE).

Urgh, so when pmds are folded pmd_addr_end() doesn't get to be the next
biggest thing?  PTRS_PER_PTE*PAGE_SIZE like things don't work since
there is no guarantee addr is at the beginning of the pmd.

Ok, will try and sort that out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
