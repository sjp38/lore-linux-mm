Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 150E06B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:06:07 -0400 (EDT)
Message-ID: <1340881511.28750.19.camel@twins>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU
 page-table freeing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 28 Jun 2012 13:05:11 +0200
In-Reply-To: <1340867364.20977.65.camel@pasglop>
References: <20120627211540.459910855@chello.nl>
	 <20120627212830.693232452@chello.nl>
	 <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com>
	 <1340838106.10063.85.camel@twins> <1340867364.20977.65.camel@pasglop>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A.
 Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 17:09 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2012-06-28 at 01:01 +0200, Peter Zijlstra wrote:
> > On Wed, 2012-06-27 at 15:23 -0700, Linus Torvalds wrote:
> >=20
> > > Plus it really isn't about hardware page table walkers at all. It's
> > > more about the possibility of speculative TLB fils, it has nothing to
> > > do with *how* they are done. Sure, it's likely that a software
> > > pagetable walker wouldn't be something that gets called speculatively=
,
> > > but it's not out of the question.
> > >=20
> > Hmm, I would call gup_fast() as speculative as we can get in software.
> > It does a lock-less walk of the page-tables. That's what the RCU free'd
> > page-table stuff is for to begin with.
>=20
> Strictly speaking it's not :-) To *begin with* (as in the origin of that
> code) it comes from powerpc hash table code which walks the linux page
> tables locklessly :-) It then came in handy with gup_fast :-)

Ah, ok my bad.

> > > IOW, if Sparc/PPC really want to guarantee that they never fill TLB
> > > entries speculatively, and that if we are in a kernel thread they wil=
l
> > > *never* fill the TLB with anything else, then make them enable
> > > CONFIG_STRICT_TLB_FILL or something in their architecture Kconfig
> > > files.=20
> >=20
> > Since we've dealt with the speculative software side by using RCU-ish
> > stuff, the only thing that's left is hardware, now neither sparc64 nor
> > ppc actually know about the linux page-tables from what I understood,
> > they only look at their hash-table thing.
>=20
> Some embedded ppc's know about the lowest level (SW loaded PMD) but
> that's not an issue here. We flush these special TLB entries
> specifically and synchronously in __pte_free_tlb().

OK, I missed that.. is that
arch/powerpc/mm/tlb_nohash.c:tlb_flush_pgtable() ?

> > So even if the hardware did do speculative tlb fills, it would do them
> > from the hash-table, but that's already cleared out.
>=20
> Right,

Phew at least I got the important thing right ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
