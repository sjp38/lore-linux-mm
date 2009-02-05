Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3656B004F
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:40:29 -0500 (EST)
Date: Thu, 5 Feb 2009 19:38:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: pud_bad vs pud_bad
In-Reply-To: <20090205191017.GF20470@elte.hu>
Message-ID: <Pine.LNX.4.64.0902051921150.30938@blonde.anvils>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu>
 <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009, Ingo Molnar wrote:
> * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> > Ingo Molnar wrote:
> >> * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> >>   
> >>> I'm looking at unifying the 32 and 64-bit versions of pud_bad.
> >>>
> >>> 32-bits defines it as:
> >>>
> >>> static inline int pud_bad(pud_t pud)
> >>> {
> >>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _KERNPG_TABLE | _PAGE_USER)) != 0;
> >>> }
> >>>
> >>> and 64 as:
> >>>
> >>> static inline int pud_bad(pud_t pud)
> >>> {
> >>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _PAGE_USER)) != _KERNPG_TABLE;
> >>> }
> >>>
> >>>
> >>> I'm inclined to go with the 64-bit version, but I'm wondering if 
> >>> there's something subtle I'm missing here.
> >>>     
> >>
> >> Why go with the 64-bit version? The 32-bit check looks more compact and 
> >> should result in smaller code.
> >>   
> >
> > Well, its stricter.  But I don't really understand what condition its  
> > actually testing for.
> 
> Well it tests: "beyond the bits covered by PTE_PFN|_PAGE_USER, the rest 
> must only be _KERNPG_TABLE".
> 
> The _KERNPG_TABLE bits are disjunct from PTE_PFN|_PAGE_USER bits, so this 
> makes sense.
> 
> But the 32-bit check does the exact same thing but via a single binary 
> operation: it checks whether any bits outside of those bits are zero -
> just via a simpler test that compiles to more compact code.

Simpler and more compact, but not as strict: in particular, a value of
0 or 1 is identified as bad by that 64-bit test, but not by the 32-bit.

I most definitely prefer the stricter 64-bit version.  I thought we'd
gone around this all before, but maybe that was for pmd_bad(): there
too one variant was weaker than the other and we went for the stronger.

However... I forget how the folding works out.  The pgd in the 32-bit
PAE case used to have just the pfn and the present bit set in that
little array of four entries: if pud_bad() ends up getting applied
to that, I guess it will blow up.

If so, my preferred answer would actually be to make those 4 entries
look more like real ptes; but you may think I'm being a bit silly.

Not quite sure why wli is Cc'ed but I've fixed his address:
it's good to see you back, Bill.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
