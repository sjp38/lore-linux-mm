Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 826BC6B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 12:36:52 -0500 (EST)
Received: by iafj26 with SMTP id j26so7968045iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 09:36:51 -0800 (PST)
Date: Sat, 14 Jan 2012 09:36:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] proc: clear_refs: do not clear reserved pages
In-Reply-To: <alpine.LFD.2.02.1201131748380.2722@xanadu.home>
Message-ID: <alpine.LSU.2.00.1201140901260.2381@eggly.anvils>
References: <1326467587-22218-1-git-send-email-will.deacon@arm.com> <alpine.LFD.2.02.1201131748380.2722@xanadu.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nico@fluxnic.net>
Cc: Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, moussaba@micron.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

On Fri, 13 Jan 2012, Nicolas Pitre wrote:
> On Fri, 13 Jan 2012, Will Deacon wrote:
> 
> > /proc/pid/clear_refs is used to clear the Referenced and YOUNG bits for
> > pages and corresponding page table entries of the task with PID pid,
> > which includes any special mappings inserted into the page tables in
> > order to provide things like vDSOs and user helper functions.
> > 
> > On ARM this causes a problem because the vectors page is mapped as a
> > global mapping and since ec706dab ("ARM: add a vma entry for the user
> > accessible vector page"), a VMA is also inserted into each task for this
> > page to aid unwinding through signals and syscall restarts. Since the
> > vectors page is required for handling faults, clearing the YOUNG bit
> > (and subsequently writing a faulting pte) means that we lose the vectors
> > page *globally* and cannot fault it back in. This results in a system
> > deadlock on the next exception.
> > 
> > This patch avoids clearing the aforementioned bits for reserved pages,
> > therefore leaving the vectors page intact on ARM. Since reserved pages
> > are not candidates for swap, this change should not have any impact on
> > the usefulness of clear_refs.
> > 
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Nicolas Pitre <nico@fluxnic.net>
> > Reported-by: Moussa Ba <moussaba@micron.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Given Andrew's answer, this should be fine wrt Russell's concern.
> 
> Acked-by: Nicolas Pitre <nico@linaro.org>

Yes, it should be okay as an urgent fix for -stable.
But going forward, I doubt it's the right answer: comments below.

> 
> > An aside: if you want to see this problem in action, just run:
> > 
> > $ echo 1 > /proc/self/clear_refs
> > 
> > on an ARM platform (as any user) and watch your system hang. I think this
> > has been the case since 2.6.37, so I'll CC stable once people are happy
> > with the fix.
> > 
> >  fs/proc/task_mmu.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index e418c5a..7dcd2a2 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -518,6 +518,9 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,

What got me worried was the line just above the context shown below:
    		page = vm_normal_page(vma, addr, ptent);
> >  		if (!page)
> >  			continue;

This is not a normal page, and it's worrying that vm_normal_page() did
not catch it: I wonder how many other places that could be a problem
(but I have not actually identified any).

vm_normal_page() doesn't catch it because at the time it was written,
we thought we were on the point of removing both PageReserved and
VM_RESERVED (both of whose meanings are imprecise), and there was no
need for it to check either of them.  But nobody found time to do the
final (not entirely trivial) cleanup, removing the definitions.

Maybe ec706dab added a need for it to check one of those; though you
can understand my reluctance to spread PageReserved any further than
it goes already.  I was looking for VM_ flags which might serve you
better, when I thought...

This is a horrible hack vma, which is very liable to introduce bugs
of this nature, because not many people are at all aware of it.
But we've had a horrible hack vma for years, the gate_vma (see
mm/memory.c), and that seems to share many characteristics with your
vectors page (most notably, being in kernel not user address space).

Please, going forward, can you delete your vectors page code, and
use the gate_vma for it?  Extending it a little if it somehow does
not satsify your need.  Or else can you please explain (ec706dab
does not) why the gate_vma does not suit you.

I'm not saying the horrible hack gate_vma mechanism is any safer
than yours (the latest bug in it was fixed all of 13 days ago).
But I am saying that one horrible hack is safer than two.

> >  
> > +		if (PageReserved(page))
> > +			continue;

Let's note in passing that this does change the "behaviour" of clear_refs
on the ZERO_PAGE; but it doesn't make any functional difference, we just
need to be aware of it, in case someone tries examining /proc/pid/smaps
after /proc/pid/clear_refs, and complains that some pages are left marked
referenced which were cleared before.  Doesn't make a real difference.

> > +
> >  		/* Clear accessed and referenced bits. */
> >  		ptep_test_and_clear_young(vma, addr, pte);
> >  		ClearPageReferenced(page);
> > -- 
> > 1.7.4.1

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
