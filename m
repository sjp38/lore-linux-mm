Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E47A08D003B
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:05:22 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1298565253.2428.288.camel@twins>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl>  <1298565253.2428.288.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 25 Feb 2011 19:04:43 +0100
Message-ID: <1298657083.2428.2483.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Russell King <rmk@arm.linux.org.uk>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>

On Thu, 2011-02-24 at 17:34 +0100, Peter Zijlstra wrote:
> On Thu, 2011-02-17 at 17:23 +0100, Peter Zijlstra wrote:
> > plain text document attachment
> > (peter_zijlstra-arm-preemptible_mmu_gather.patch)
> > Fix up the arm mmu_gather code to conform to the new API.
>=20
> So akpm noted that this one doesn't apply anymore because of:
>=20
> commit 06824ba824b3e9f2fedb38bee79af0643198ed7f
> Author: Russell King <rmk+kernel@arm.linux.org.uk>
> Date:   Sun Feb 20 12:16:45 2011 +0000
>=20
>     ARM: tlb: delay page freeing for SMP and ARMv7 CPUs
>    =20
>     We need to delay freeing any mapped page on SMP and ARMv7 systems to
>     ensure that the data is not accessed by other CPUs, or is used for
>     speculative prefetch with ARMv7.  This includes not only mapped pages
>     but also pages used for the page tables themselves.
>    =20
>     This avoids races with the MMU/other CPUs accessing pages after they'=
ve
>     been freed but before we've invalidated the TLB.
>    =20
>     Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
>=20
>=20
> Which raises a nice point about shift_arg_pages() which calls
> free_pgd_range(), the other architectures that look similar to arm in
> this respect are ia64 and sh, do they suffer the same problem?
>=20
> It doesn't look hard to fold the requirements for this into the generic
> tlb range support (patch 14 in this series).

It looks like both ia64 and sh do indeed suffer there.

I've pulled my generic range tracking to the head of the series so that
I can convert ARM, IA64 and SH to generic tlb solving it for those.

Russell, generic tlb doesn't look to need the extra logic you added for
the fs/exec.c case, but please double check the patches when I post
them.

In short, tlb_end_vma() will call flush_tlb_range() on the tracked range
and clear ->need_flush, so things like zap_page_range() will not then
also call tlb_flush().

In case of shift_arg_pages() and unmap_region() however we first call
free_pgtables() which might end up calling p??_free_tlb() which will
then set ->need_flush, and tlb_finish_mmu() will then end up calling
tlb_flush().

I'm not quite sure why you chose to add range tracking on
pte_free_tlb(), the only affected code path seems to be unmap_region()
where you'll use a flush_tlb_range(), but its buggy, the pte_free_tlb()
range is much larger than 1 page, and if you do it there you also need
it for all the other p??_free_tlb() functions.

The tlb flush after freeing page-tables is needed for things like
gup_fast() which needs to sync against them being freed.

So the stuff I have now will try its best to track ranges on zap_* while
clearing the page mapping, will use flush_cache_range() and
flush_tlb_range(). But when it comes to tearing down the page-tables
themselves we'll punt and use a full mm flush, which seems a waste of
all that careful range tracking by zap_*.

One possibility would be to add tlb_start/end_vma() in
unmap_page_range(), except we don't need to flush the cache again, also,
it would be nice to not have to flush on tlb_end_vma() but delay it all
to tlb_finish_mmu() where possible.

OK, let me try and hack up proper range tracking for free_*, that way I
can move the flush_tlb_range() from tlb_end_vma() and into
tlb_flush_mmu().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
