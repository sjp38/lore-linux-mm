Date: Sun, 18 Apr 2004 13:42:28 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
Message-ID: <20040418134228.B12222@flint.arm.linux.org.uk>
References: <20040418122344.A11293@flint.arm.linux.org.uk> <Pine.LNX.4.44.0404181331240.20000-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404181331240.20000-100000@localhost.localdomain>; from hugh@veritas.com on Sun, Apr 18, 2004 at 01:36:11PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 01:36:11PM +0100, Hugh Dickins wrote:
> On Sun, 18 Apr 2004, Russell King wrote:
> > 
> > So, I think we definitely need the flush there.  The available data
> > so far from Marc appears to confirm this, and the theory surrounding
> > ASID-based MMUs (which are coming on ARM) also require it.
> 
> I agree that we need to flush TLB more, that if we keep on ignoring a
> hint forever then things go awry.  I disagree that it needs to be done
> so immediately, in the young/referenced/accessed case.  But go ahead,
> we can always optimize some of it out later on.

Well, having struggled with the kernels include mess to try to get at
the information I need to flush the TLB from an asm-arm header file,
I'm just considering whether to just say "fuck it" and add

#ifdef __arm__
		flush_tlb_mm_page(ptep_to_mm(pte), ptep_to_address(pte));
#endif

directly into page_referenced() and be done with it.

Basically, to be able to use either ptep_to_mm() or ptep_to_address()
in asm/pgtable.h, you need to:

1. remove linux/mm.h from asm-generic/rmap.h
2. somehow work around linux/highmem.h which includes linux/mm.h so
   asm-generic/rmap.h can have a definition of kmap_atomic_to_page()
3. remove asm/pgtable.h from linux/mm.h and linux/page-flags.h

I've managed to get so far with that, but the real killer seems to
be (2).

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
