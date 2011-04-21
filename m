Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5133A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:08:49 -0400 (EDT)
Date: Thu, 21 Apr 2011 12:08:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110421110841.GA612@suse.de>
References: <20110415101248.GB22688@suse.de>
 <BANLkTik7H+cmA8iToV4j1ncbQqeraCaeTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTik7H+cmA8iToV4j1ncbQqeraCaeTg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Thu, Apr 21, 2011 at 03:59:47PM +0900, Minchan Kim wrote:
> Hi Mel,
> 
> On Fri, Apr 15, 2011 at 7:12 PM, Mel Gorman <mgorman@suse.de> wrote:
> > With transparent hugepage support, handle_mm_fault() has to be careful
> > that a normal PMD has been established before handling a PTE fault. To
> > achieve this, it used __pte_alloc() directly instead of pte_alloc_map
> > as pte_alloc_map is unsafe to run against a huge PMD. pte_offset_map()
> > is called once it is known the PMD is safe.
> >
> > pte_alloc_map() is smart enough to check if a PTE is already present
> > before calling __pte_alloc but this check was lost. As a consequence,
> > PTEs may be allocated unnecessarily and the page table lock taken.
> > Thi useless PTE does get cleaned up but it's a performance hit which
> > is visible in page_test from aim9.
> >
> > This patch simply re-adds the check normally done by pte_alloc_map to
> > check if the PTE needs to be allocated before taking the page table
> > lock. The effect is noticable in page_test from aim9.
> >
> > AIM9
> >                2.6.38-vanilla 2.6.38-checkptenone
> > creat-clo      446.10 ( 0.00%)   424.47 (-5.10%)
> > page_test       38.10 ( 0.00%)    42.04 ( 9.37%)
> > brk_test        52.45 ( 0.00%)    51.57 (-1.71%)
> > exec_test      382.00 ( 0.00%)   456.90 (16.39%)
> > fork_test       60.11 ( 0.00%)    67.79 (11.34%)
> > MMTests Statistics: duration
> > Total Elapsed Time (seconds)                611.90    612.22
> >
> > (While this affects 2.6.38, it is a performance rather than a
> > functional bug and normally outside the rules -stable. While the big
> > performance differences are to a microbench, the difference in fork
> > and exec performance may be significant enough that -stable wants to
> > consider the patch)
> >
> > Reported-by: Raz Ben Yehuda <raziebe@gmail.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > --
> >  mm/memory.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 5823698..1659574 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >         * run pte_offset_map on the pmd, if an huge pmd could
> >         * materialize from under us from a different thread.
> >         */
> > -       if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> > +       if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
> >                return VM_FAULT_OOM;
> >        /* if an huge pmd materialized from under us just retry later */
> >        if (unlikely(pmd_trans_huge(*pmd)))
> >
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Sorry for jumping in too late. I have a just nitpick.
> 

Better late than never :)

> We have another place, do_huge_pmd_anonymous_page.
> Although it isn't workload of page_test, is it valuable to expand your
> patch to cover it?
> If there is workload there are many thread and share one shared anon
> vma in ALWAYS THP mode, same problem would happen.

We already checked pmd_none() in handle_mm_fault() before calling
into do_huge_pmd_anonymous_page(). We could race for the fault while
attempting to allocate a huge page but it wouldn't be as severe a
problem particularly as it is encountered after failing a 2M allocation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
