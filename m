Received: from peculier ([10.10.188.58]) (2584 bytes) by megami.veritas.com
    via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1BFA0H-0000fvC@megami.veritas.com> for
    <linux-mm@kvack.org>; Sun, 18 Apr 2004 03:58:25 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sun, 18 Apr 2004 11:58:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: PTE aging, ptep_test_and_clear_young() and TLB
In-Reply-To: <20040418093949.GY743@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0404181142290.12120-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Apr 2004, William Lee Irwin III wrote:
> On Sun, Apr 18, 2004 at 10:36:16AM +0100, Russell King wrote:
> > Actually, we don't actually need the VMA - if you look at flush_tlb_page()
> > in include/asm-arm/tlbflush.h, we only really need the MM.  Therefore,
> > it's pointless digging up the VMA.  (I did think that we didn't flush
> > the I-TLB if VM_EXEC wasn't set, but I think that was a previous
> > incarnation.)
> 
> This sounds like when hugh's stuff to prep for either his or andrea's
> try_to_unmap() reimplementation goes in, something akin to current ppc64
> may be needed for ARM. That should preserve the mm/address tagging by
> shoving the pte page tagging into arch code.

mm and address are directly available in both mine and Andrea's (the
difference between us is finding vma: mine needs find_vma in the anon
case, on Andrea's it's directly available), shouldn't be any need to
add in that ppc/ppc64 code.

Hmm, maybe I didn't look hard enough at it, and could have just taken
it out of ppc/ppc64, instead of moving it from generic; I'll go back
and check on that sometime.

I'm not surprised Russell's found he just needs mm rather than vma,
I did try briefly yesterday to understand just what it is that vma
gives to flush TLB.  Needs thorough research through all the arches,
the ARM case is not necessarily representative.

Wouldn't surprise me if it turns out vma necessary on some in the
file-backed case, but on none in the anon case (would then cease
to be a differentiator between anonmm and anon_vma if so).

But I still think that we'd want to cut down on the intercpu TLB
flushes for page_referenced, should batch them up to some extent.
Russell may well be right that we're much too lazy about the
referenced bit in 2.6, but that doesn't mean we now have to
jump and get it exactly right all the time: the dirty bit is
vital, the referenced bit never more than a hint.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
