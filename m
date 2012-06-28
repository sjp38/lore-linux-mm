Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 21A2C6B0069
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:00:55 -0400 (EDT)
Message-ID: <1340881196.28750.16.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 12:59:56 +0200
In-Reply-To: <1340879984.20977.80.camel@pasglop>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
	 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 20:39 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2012-06-28 at 10:16 +0100, Catalin Marinas wrote:
> > That's definitely an issue on ARM and it was hit on older kernels.
> > Basically ARM processors can cache any page translation level in the
> > TLB. We need to make sure that no page entry at any level (either cache=
d
> > in the TLB or not) points to an invalid next level table (hence the TLB
> > shootdown). For example, in cases like free_pgd_range(), if the cached
> > pgd entry points to an already freed pud/pmd table (pgd_clear is not
> > enough) it may walk the page tables speculatively cache another entry i=
n
> > the TLB. Depending on the random data it reads from an old table page,
> > it may find a global entry (it's just a bit in the pte) which is not
> > tagged with an ASID (application specific id). A latter flush_tlb_mm()
> > only flushes the current ASID and doesn't touch global entries (used
> > only by kernel mappings). So we end up with global TLB entry in user
> > space that overrides any other application mapping.
>=20
> Right, that's the typical scenario. I haven't looked at your flush
> implementation though, but surely you can defer the actual freeing so
> you can batch them & limit the number of TLB flushes right ?

Yes they do.. its just the up-front TLB invalidate for fullmm that's a
problem.

s390 really wants this so it can avoid the per pte invalidate otherwise
required by ptep_get_and_clear_full().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
