Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BB15D8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 07:26:06 -0500 (EST)
Subject: Re: [PATCH 06/17] arm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110228120651.GA25657@flint.arm.linux.org.uk>
References: <20110217162327.434629380@chello.nl>
	 <20110217163235.106239192@chello.nl> <1298565253.2428.288.camel@twins>
	 <1298657083.2428.2483.camel@twins>
	 <20110225215123.GA10026@flint.arm.linux.org.uk>
	 <1298893487.2428.10537.camel@twins>
	 <20110228115907.GB492@flint.arm.linux.org.uk>
	 <20110228120651.GA25657@flint.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Feb 2011 13:25:42 +0100
Message-ID: <1298895942.2428.10639.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, "Luck,Tony" <tony.luck@intel.com>, PaulMundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>

On Mon, 2011-02-28 at 12:06 +0000, Russell King wrote:
>=20
> As I think I mentioned, the TLB shootdown interface either needs rewritin=
g
> from scratch as its currently a broken design, or it needs tlb_gather_mmu=
()
> to take a proper mode argument, rather than this useless 'fullmm' argumen=
t
> which only gives half the story.
>=20
> The fact is that the interface has three modes, and distinguishing betwee=
n
> them requires a certain amount of black magic.  Explicitly, the !fullmm
> case has two modes, and it requires implementations to remember whether
> tlb_start_vma() has been called before tlb_finish_mm() or not.
>=20
> Maybe this will help you understand the ARM implementation - this doesn't
> change the functionality, but may make things clearer.

I've actually implemented that, but it didn't really help much.

Mostly because you want your TLB flush to be after freeing the
page-tables, not before it.

So I want to avoid having to flush at tlb_end_vma() _and_ at
tlb_finish_mmu(), and doing that needs a flush_tlb_range() that doesn't
need a vma.

ARM also does the whole IPI thing on TLB flush, so a gup_fast()
implementation for arm would also need that TLB flush after page-table
tear-down, not on tlb_end_vma().

And once you want a single TLB invalidate, it doesn't matter if you want
to track ranges for p*_free_tlb() too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
