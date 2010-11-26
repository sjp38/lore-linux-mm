Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E9C08D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 12:59:15 -0500 (EST)
Date: Fri, 26 Nov 2010 18:57:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 18 of 66] add pmd mangling functions to x86
Message-ID: <20101126175751.GY6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <c681aaa016f2bd9ce393.1288798073@v2.random>
 <20101118130446.GO8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118130446.GO8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 01:04:46PM +0000, Mel Gorman wrote:
> On Wed, Nov 03, 2010 at 04:27:53PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Add needed pmd mangling functions with simmetry with their pte counterparts.
> 
> symmetry

Fixed.

> 
> > pmdp_freeze_flush is the only exception only present on the pmd side and it's
> > needed to serialize the VM against split_huge_page, it simply atomically clears
> > the present bit in the same way pmdp_clear_flush_young atomically clears the
> > accessed bit (and both need to flush the tlb to make it effective, which is
> > mandatory to happen synchronously for pmdp_freeze_flush).
> 
> I don't see a pmdp_freeze_flush defined in the patch. Did yu mean 
> pmdp_splitting_flush? Even if it is, it's the splitting bit you are
> dealing with which isn't the same as the present bit. I'm missing
> something.

Well the comment went out of sync with the code sorry. I updated it:

=======
Add needed pmd mangling functions with symmetry with their pte counterparts.
pmdp_splitting_flush() is the only new addition on the pmd_ methods and it's
needed to serialize the VM against split_huge_page. It simply atomically sets
the splitting bit in a similar way pmdp_clear_flush_young atomically clears the
accessed bit. pmdp_splitting_flush() also has to flush the tlb to make it
effective against gup_fast, but it wouldn't really require to flush the tlb
too. Just the tlb flush is the simplest operation we can invoke to serialize
pmdp_splitting_flush() against gup_fast.
=======

> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Acked-by: Rik van Riel <riel@redhat.com>
> > ---
> > 
> > diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> > --- a/arch/x86/include/asm/pgtable.h
> > +++ b/arch/x86/include/asm/pgtable.h
> > @@ -302,15 +302,15 @@ pmd_t *populate_extra_pmd(unsigned long 
> >  pte_t *populate_extra_pte(unsigned long vaddr);
> >  #endif	/* __ASSEMBLY__ */
> >  
> > +#ifndef __ASSEMBLY__
> > +#include <linux/mm_types.h>
> > +
> >  #ifdef CONFIG_X86_32
> >  # include "pgtable_32.h"
> >  #else
> >  # include "pgtable_64.h"
> >  #endif
> >  
> > -#ifndef __ASSEMBLY__
> > -#include <linux/mm_types.h>
> > -
> 
> Stupid quetion: Why is this move necessary?

That's not a stupid question, it seems to build in all configurations
even with this part backed out. I'll try to reverse this one in the
hope that it won't break build. I suppose some earlier version of the
patchset required this to build (I would never make a gratuitous
change like this if it wasn't needed at some point) but it seems not
be required anymore according to my build tests. If I'm wrong and some
build breaks I'll reintroduce it later.

> >  static inline int pte_none(pte_t pte)
> >  {
> >  	return !pte.pte;
> > @@ -353,7 +353,7 @@ static inline unsigned long pmd_page_vad
> >   * Currently stuck as a macro due to indirect forward reference to
> >   * linux/mmzone.h's __section_mem_map_addr() definition:
> >   */
> > -#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
> > +#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
> >  
> 
> Why is it now necessary to use PTE_PFN_MASK?

Just for the NX bit, that couldn't be set before the pmd could be
marked PSE.

> The implementations look fine but I'm having trouble reconsiling what
> the leader says with the patch :(

Yes because it was out of sync, the new version is above.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
