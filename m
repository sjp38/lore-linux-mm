Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E105F6B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 20:43:49 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so2341058pad.13
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 17:43:49 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id ee4si3575091pbb.52.2014.08.05.17.43.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 17:43:48 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so2258343pdi.34
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 17:43:48 -0700 (PDT)
Date: Tue, 5 Aug 2014 17:42:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG in unmap_page_range
In-Reply-To: <20140805144439.GW10819@suse.de>
Message-ID: <alpine.LSU.2.11.1408051649330.6591@eggly.anvils>
References: <53DD5F20.8010507@oracle.com> <alpine.LSU.2.11.1408040418500.3406@eggly.anvils> <20140805144439.GW10819@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Tue, 5 Aug 2014, Mel Gorman wrote:
> On Mon, Aug 04, 2014 at 04:40:38AM -0700, Hugh Dickins wrote:
> > 
> > [INCOMPLETE PATCH] x86,mm: fix pte_special versus pte_numa
> > 
> > Sasha Levin has shown oopses on ffffea0003480048 and ffffea0003480008
> > at mm/memory.c:1132, running Trinity on different 3.16-rc-next kernels:
> > where zap_pte_range() checks page->mapping to see if PageAnon(page).
> > 
> > Those addresses fit struct pages for pfns d2001 and d2000, and in each
> > dump a register or a stack slot showed d2001730 or d2000730: pte flags
> > 0x730 are PCD ACCESSED PROTNONE SPECIAL IOMAP; and Sasha's e820 map has
> > a hole between cfffffff and 100000000, which would need special access.
> > 
> > Commit c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on
> > the PMD and PTE levels") has broken vm_normal_page(): a PROTNONE SPECIAL
> > pte no longer passes the pte_special() test, so zap_pte_range() goes on
> > to try to access a non-existent struct page.
> > 
> 
> :(
> 
> > Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
> > to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).
> > 
> > It's unclear why c46a7c817e66 added pte_numa() test to vm_normal_page(),
> > and moved its is_zero_pfn() test from slow to fast path: I suspect both
> > were papering over PROT_NONE issues seen with inadequate pte_special().
> > Revert vm_normal_page() to how it was before, relying on pte_special().
> > 
> 
> Rather than answering directly I updated your changelog
> 
>     Fix this by refining pte_special() (SPECIAL with PRESENT or PROTNONE)
>     to complement pte_numa() (SPECIAL with neither PRESENT nor PROTNONE).
> 
>     A hint that this was a problem was that c46a7c817e66 added pte_numa()
>     test to vm_normal_page(), and moved its is_zero_pfn() test from slow to
>     fast path: This was papering over a pte_special() snag when the zero
>     page was encountered during zap. This patch reverts vm_normal_page()
>     to how it was before, relying on pte_special().

Thanks, that's fine.

> 
> > I find it confusing, that the only example of ARCH_USES_NUMA_PROT_NONE
> > no longer uses PROTNONE for NUMA, but SPECIAL instead: update the
> > asm-generic comment a little, but that config option remains unhelpful.
> > 
> 
> ARCH_USES_NUMA_PROT_NONE should have been sent to the farm at the same time
> as that patch and by rights unified with the powerpc helpers. With the new
> _PAGE_NUMA bit, there is no reason they should have different implementations
> of pte_numa and related functions. Unfortunately unifying them is a little
> problematic due to differences in fundamental types. It could be done with
> #defines but I'm attaching a preliminary prototype to illustrate the issue.
> 
> > But more seriously, I think this patch is incomplete: aren't there
> > other places which need to be handling PROTNONE along with PRESENT?
> > For example, pte_mknuma() clears _PAGE_PRESENT and sets _PAGE_NUMA,
> > but on a PROT_NONE area, I think that will now make it pte_special()?
> > So it ought to clear _PAGE_PROTNONE too.  Or maybe we can never
> > pte_mknuma() on a PROT_NONE area - there would be no point?
> > 
> 
> We are depending on the fact that inaccessible VMAs are skipped by the
> NUMA hinting scanner.

Ah, okay.  And the other way round (mprotecting to PROT_NONE an area
which already contains _PAGE_NUMA ptes) already looked safe to me.

> 
> > Around here I began to wonder if it was just a mistake to have deserted
> > the PROTNONE for NUMA model: I know Linus had a strong reaction against
> > it, and I've never delved into its drawbacks myself; but bringing yet
> > another (SPECIAL) flag into the game is not an obvious improvement.
> > Should we just revert c46a7c817e66, or would that be a mistake?
> > 
> 
> It's replacing one type of complexity with another. The downside is that
> _PAGE_NUMA == _PAGE_PROTNONE puts subtle traps all over the core for
> powerpc to fall foul of.

Okay.

> 
> I'm attaching a preliminary pair of patches. The first which deals with
> ARCH_USES_NUMA_PROT_NONE and the second which is yours with a revised
> changelog. I'm adding Aneesh to the cc to look at the powerpc portion of
> the first patch.

Thanks a lot, Mel.

I am surprised by the ordering, but perhaps you meant nothing by it.
Isn't the first one a welcome but optional cleanup, and the second one
a fix that we need in 3.16-stable?  Or does the fix actually depend in
some unstated way upon the cleanup, in powerpc-land perhaps?

Aside from that, for the first patch: yes, I heartily approve of the
disappearance of CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE and
CONFIG_ARCH_USES_NUMA_PROT_NONE.  If you wish, add
Acked-by: Hugh Dickins <hughd@google.com>
but of course it's really Aneesh and powerpc who are the test of it.

One thing I did wonder, though: at first I was reassured by the
VM_BUG_ON(!pte_present(pte)) you add to pte_mknuma(); but then thought
it would be better as VM_BUG_ON(!(val & _PAGE_PRESENT)), being stronger
- asserting that indeed we do not put NUMA hints on PROT_NONE areas.
(But I have not tested, perhaps such a VM_BUG_ON would actually fire.)

And in the second patch, a few trivial edits:

> It still appears that this patch may be incomplete: aren't there other
> places which need to be handling PROTNONE along with PRESENT?  For example,
> pte_mknuma() clears _PAGE_PRESENT and sets _PAGE_NUMA, but on a PROT_NONE
> area, that would make it it pte_special(). This is side-stepped by the fact

s/it it/it/

> that NUMA hinting faults skiped PROT_NONE VMAs and there are no grounds

s/skiped/skip/

> where a NUMA hinting fault on a PROT_NONE VMA would be interesting.
> 
> Partially-Fixes: c46a7c817e66 ("x86: define _PAGE_NUMA by reusing software bits on the PMD and PTE levels")

s/Partially-//

> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Not-yet-Signed-off-by: Hugh Dickins <hughd@google.com>

s/Not-yet-//

> Not-yet-Signed-off-by: Mel Gorman <mgorman@suse.de>

Ditto I must leave to you!

> Cc: stable@vger.kernel.org [3.16]
> ---
>  arch/x86/include/asm/pgtable.h | 9 +++++++--
>  mm/memory.c                    | 7 +++----
>  2 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 0ec0560..230b811 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -131,8 +131,13 @@ static inline int pte_exec(pte_t pte)
>  
>  static inline int pte_special(pte_t pte)
>  {
> -	return (pte_flags(pte) & (_PAGE_PRESENT|_PAGE_SPECIAL)) ==
> -				 (_PAGE_PRESENT|_PAGE_SPECIAL);
> +	/*
> +	 * See CONFIG_NUMA_BALANCING CONFIG_ARCH_USES_NUMA_PROT_NONE pte_numa()

s/CONFIG_ARCH_USES_NUMA_PROT_NONE //
even if you do end up reordering this patch before the other.

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
