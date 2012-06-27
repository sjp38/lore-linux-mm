Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C6B656B009C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:14:38 -0400 (EDT)
Message-ID: <1340835199.10063.76.camel@twins>
Subject: Re: [PATCH 11/20] mm, s390: Convert to use generic mmu_gather
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 28 Jun 2012 00:13:19 +0200
In-Reply-To: <20120627212831.353649870@chello.nl>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.353649870@chello.nl>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Wed, 2012-06-27 at 23:15 +0200, Peter Zijlstra wrote:
>=20
> S390 doesn't need a TLB flush after ptep_get_and_clear_full() and
> before __tlb_remove_page() because its ptep_get_and_clear*() family
> already does a full TLB invalidate. Therefore force it to use
> tlb_fast_mode.=20

On that.. ptep_get_and_clear() says:

/*                                                                         =
                   =20
 * This is hard to understand. ptep_get_and_clear and ptep_clear_flush     =
                   =20
 * both clear the TLB for the unmapped pte. The reason is that             =
                   =20
 * ptep_get_and_clear is used in common code (e.g. change_pte_range)       =
                   =20
 * to modify an active pte. The sequence is                                =
                   =20
 *   1) ptep_get_and_clear                                                 =
                   =20
 *   2) set_pte_at                                                         =
                   =20
 *   3) flush_tlb_range                                                    =
                   =20
 * On s390 the tlb needs to get flushed with the modification of the pte   =
                   =20
 * if the pte is active. The only way how this can be implemented is to    =
                   =20
 * have ptep_get_and_clear do the tlb flush. In exchange flush_tlb_range   =
                   =20
 * is a nop.                                                               =
                   =20
 */=20

I think there is another way, arch_{enter,leave}_lazy_mmu_mode() seems
to wrap these sites so you can do as SPARC64 and PPC do and batch
through there.

That should save a number of TLB invalidates..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
