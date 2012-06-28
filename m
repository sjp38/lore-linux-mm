Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 740DC6B005C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 05:19:58 -0400 (EDT)
Date: Thu, 28 Jun 2012 10:16:27 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
Message-ID: <20120628091627.GB8573@arm.com>
References: <20120627211540.459910855@chello.nl>
 <20120627212831.137126018@chello.nl>
 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
 <1340838154.10063.86.camel@twins>
 <1340838807.10063.90.camel@twins>
 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, Jun 28, 2012 at 12:33:44AM +0100, Linus Torvalds wrote:
> On Wed, Jun 27, 2012 at 4:23 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > But the branch prediction tables are obviously just predictions, and
> > they easily contain user addresses etc in them. So the kernel may well
> > end up speculatively doing a TLB fill on a user access.
> 
> That should be ".. on a user *address*", hopefully that was clear from
> the context, if not from the text.
> 
> IOW, the point I'm trying to make is that even if there are zero
> *actual* accesses of user space (because user space is dead, and the
> kernel hopefully does no "get_user()/put_user()" stuff at this point
> any more), the CPU may speculatively use user addresses for the
> bog-standard kernel addresses that happen.

That's definitely an issue on ARM and it was hit on older kernels.
Basically ARM processors can cache any page translation level in the
TLB. We need to make sure that no page entry at any level (either cached
in the TLB or not) points to an invalid next level table (hence the TLB
shootdown). For example, in cases like free_pgd_range(), if the cached
pgd entry points to an already freed pud/pmd table (pgd_clear is not
enough) it may walk the page tables speculatively cache another entry in
the TLB. Depending on the random data it reads from an old table page,
it may find a global entry (it's just a bit in the pte) which is not
tagged with an ASID (application specific id). A latter flush_tlb_mm()
only flushes the current ASID and doesn't touch global entries (used
only by kernel mappings). So we end up with global TLB entry in user
space that overrides any other application mapping.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
