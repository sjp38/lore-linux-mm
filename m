Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1186B004F
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:49:40 -0500 (EST)
Date: Thu, 5 Feb 2009 20:49:32 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pud_bad vs pud_bad
Message-ID: <20090205194932.GB3129@elte.hu>
References: <498B2EBC.60700@goop.org> <20090205184355.GF5661@elte.hu> <498B35F9.601@goop.org> <20090205191017.GF20470@elte.hu> <Pine.LNX.4.64.0902051921150.30938@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902051921150.30938@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, William Lee Irwin III <wli@movementarian.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Hugh Dickins <hugh@veritas.com> wrote:

> On Thu, 5 Feb 2009, Ingo Molnar wrote:
> > * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> > > Ingo Molnar wrote:
> > >> * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> > >>   
> > >>> I'm looking at unifying the 32 and 64-bit versions of pud_bad.
> > >>>
> > >>> 32-bits defines it as:
> > >>>
> > >>> static inline int pud_bad(pud_t pud)
> > >>> {
> > >>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _KERNPG_TABLE | _PAGE_USER)) != 0;
> > >>> }
> > >>>
> > >>> and 64 as:
> > >>>
> > >>> static inline int pud_bad(pud_t pud)
> > >>> {
> > >>> 	return (pud_val(pud) & ~(PTE_PFN_MASK | _PAGE_USER)) != _KERNPG_TABLE;
> > >>> }
> > >>>
> > >>>
> > >>> I'm inclined to go with the 64-bit version, but I'm wondering if 
> > >>> there's something subtle I'm missing here.
> > >>>     
> > >>
> > >> Why go with the 64-bit version? The 32-bit check looks more compact and 
> > >> should result in smaller code.
> > >>   
> > >
> > > Well, its stricter.  But I don't really understand what condition its  
> > > actually testing for.
> > 
> > Well it tests: "beyond the bits covered by PTE_PFN|_PAGE_USER, the rest 
> > must only be _KERNPG_TABLE".
> > 
> > The _KERNPG_TABLE bits are disjunct from PTE_PFN|_PAGE_USER bits, so this 
> > makes sense.
> > 
> > But the 32-bit check does the exact same thing but via a single binary 
> > operation: it checks whether any bits outside of those bits are zero -
> > just via a simpler test that compiles to more compact code.
> 
> Simpler and more compact, but not as strict: in particular, a value of
> 0 or 1 is identified as bad by that 64-bit test, but not by the 32-bit.

yes, indeed you are right - the 64-bit test does not allow the KERNPG_TABLE 
bits to go zero.

Those are the present, rw, accessed and dirty bits. Do they really matter 
that much? If a toplevel entry goes !present or readonly, we notice that 
_fast_, without any checks. If it goes !access or !dirty - does that matter?

These checks are done all the time, and even a single instruction can count. 
The bits that are checked are enough to notice random memory corruption.

( albeit these days with large RAM sizes pagetable corruption is quite rare 
  and only happens if it's specifically corrupting the pagetable - and then 
  it's not just a single bit. Most of the memory corruption goes into the 
  pagecache. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
