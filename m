Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B11458D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 07:20:55 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110228115907.GB492@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>
	 <1298657083.2428.2483.camel@twins>
	 <20110225215123.GA10026@flint.arm.linux.org.uk>
	 <1298893487.2428.10537.camel@twins>
	 <20110228115907.GB492@flint.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Feb 2011 13:20:12 +0100
Message-ID: <1298895612.2428.10621.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, 2011-02-28 at 11:59 +0000, Russell King wrote:
> On Mon, Feb 28, 2011 at 12:44:47PM +0100, Peter Zijlstra wrote:
> > Right, so the normal case is:
> >=20
> >   unmap_region()
> >     tlb_gather_mmu()
>=20
> The fullmm argument is important here as it specifies the mode.

well, unmap_region always has that 0, I've mentioned the fullmm mode
separately below, its in many way the easiest case to deal with.

>       tlb_gather_mmu(, 0)
>=20
> >     unmap_vmas()
> >       for (; vma; vma =3D vma->vm_next)
> >         unmao_page_range()
> >           tlb_start_vma() -> flush cache range
> >           zap_*_range()
> >             ptep_get_and_clear_full() -> batch/track external tlbs
> >             tlb_remove_tlb_entry() -> batch/track external tlbs
> >             tlb_remove_page() -> track range/batch page
> >           tlb_end_vma() -> flush tlb range
>=20
>        tlb_finish_mmu() -> nothing
>=20
> >=20
> >  [ for architectures that have hardware page table walkers
> >    concurrent faults can still load the page tables ]
> >=20
> >     free_pgtables()
>=20
>         tlb_gather_mmu(, 1)
>=20
> >       while (vma)
> >         unlink_*_vma()
> >         free_*_range()
> >           *_free_tlb()
> >     tlb_finish_mmu()
>=20
>       tlb_finish_mmu() -> flush tlb mm
>=20
> >=20
> >   free vmas
>=20
> So this is all fine.  Note that we *don't* use the range stuff here.
>=20
> > Now, if we want to track ranges _and_ have hardware page table walkers
> > (ARM seems to be one such), we must flush TLBs at tlb_end_vma() because
> > flush_tlb_range() requires a vma pointer (ARM and TILE actually use mor=
e
> > than ->vm_mm), and on tlb_finish_mmu() issue a full mm wide invalidate
> > because the hardware walker could have re-populated the cache after
> > clearing the PTEs but before freeing the page tables.
>=20
> No.  The hardware walker won't re-populate the TLB after the page table

Never said it would repopulate the TLB, just said it could repopulate
your cache thing and that it might still walk the page tables.

> entries have been cleared - where would it get this information from if
> not from the page tables?
>=20
> > What ARM does is it retains the last vma pointer and tracks
> > pte_free_tlb() range and uses that in tlb_finish_mmu(), which is a tad
> > hacky.
>=20
> It may be hacky but then the TLB shootdown interface is hacky too.  We
> don't keep the vma around to re-use after tlb_end_vma() - if you think
> that then you misunderstand what's going on.  The vma pointer is kept
> around as a cheap way of allowing tlb_finish_mmu() to distinguish
> between the unmap_region() mode and the shift_arg_pages() mode.

Well, you most certainly use it in the unmap_region() case above.
tlb_end_vma() will do a flush_tlb_range(), but then your
__pte_free_tlb() will also track range and the tlb_finish_mmu() will
then again issue a flush_tlb_range() using the last vma pointer.

You argued you need that second tlb flush fo flush your cached level1
entries for your LPAE mode (btw arm sucks for having all those docs
private).

> > Mostly because of shift_arg_pages(), where we have:
> >=20
> >   shift_arg_pages()
> >     tlb_gather_mmu()
>=20
>       tlb_gather_mmu(, 0)
>=20
> >     free_*_range()
> >     tlb_finish_mmu()
>=20
>       tlb_finish_mmu() does nothing without the ARM change.
>       tlb_finish_mmu() -> flush_tlb_mm() with the ARM change.
>=20
> And this is where the bug was - these page table entries could find
> their way into the TLB and persist after they've been torn down.

Sure, I got that, you punt and do a full mm tlb invalidate (IA64 and SH
seem similarly challenged).

> > For which ARM now punts and does a full tlb invalidate (no vma pointer)=
.
> > But also because it drags along that vma pointer, which might not at al=
l
> > match the range its actually going to invalidate (and hence its vm_flag=
s
> > might not accurately reflect things -- at worst more expensive than
> > needed).
>=20
> Where do you get that from?  Where exactly in the above code would the
> VMA pointer get set?  In this case, it will be NULL, so we do a
> flush_tlb_mm() for this case.  We have to - we don't have any VMA to
> deal with at this point.

unmap_region()'s last tlb_start_vma(), with __pte_free_tlb() tracking
range will then get tlb_finish_mmu() to issue a second
flush_tlb_range().

> > The reason I wanted flush_tlb_range() to take an mm_struct and not the
> > current vm_area_struct is because we can avoid doing the
> > flush_tlb_range() from tlb_end_vma() and delay the thing until
> > tlb_finish_mmu() without having to resort to such games as above. We
> > could simply track the full range over all VMAs and free'd page-tables
> > and do one range invalidate.
>=20
> No.  That's stupid.  Consider the case where you have to loop one page
> at a time over the range (we do on ARM.)  If we ended up with your
> suggestion above, that means we could potentially have to loop 4K at a
> time over 3GB of address space.  That's idiotic when we have an
> instruction which can flush the entire TLB for a particular thread.

*blink* so you've implemented flush_tlb_range() as an iteration of
single page invalidates?

x86 could have done the same I think, instead we chose to implement it
as a full mm invalidate simply because that's way cheaper in general.

You could also put a threshold in, if (end-start) >> PAGE_SHIFT > n,
flush everything if you want.

Anyway, I don't see how that's related to the I-TLB thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
