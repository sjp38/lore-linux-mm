Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id 600AB6B004D
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 11:07:45 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so10889842eaj.12
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 08:07:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l44si7363463eem.208.2013.12.04.08.07.44
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 08:07:44 -0800 (PST)
Date: Wed, 4 Dec 2013 16:07:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race
 with PTE scan update
Message-ID: <20131204160741.GC11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-15-git-send-email-mgorman@suse.de>
 <529E641A.7040804@redhat.com>
 <20131203234637.GS11295@suse.de>
 <529F3D51.1090203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <529F3D51.1090203@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 04, 2013 at 09:33:53AM -0500, Rik van Riel wrote:
> On 12/03/2013 06:46 PM, Mel Gorman wrote:
> > On Tue, Dec 03, 2013 at 06:07:06PM -0500, Rik van Riel wrote:
> >> On 12/03/2013 03:52 AM, Mel Gorman wrote:
> >>> NUMA PTE updates and NUMA PTE hinting faults can race against each other. The
> >>> setting of the NUMA bit defers the TLB flush to reduce overhead. NUMA
> >>> hinting faults do not flush the TLB as X86 at least does not cache TLB
> >>> entries for !present PTEs. However, in the event that the two race a NUMA
> >>> hinting fault may return with the TLB in an inconsistent state between
> >>> different processors. This patch detects potential for races between the
> >>> NUMA PTE scanner and fault handler and will flush the TLB for the affected
> >>> range if there is a race.
> >>>
> >>> Signed-off-by: Mel Gorman <mgorman@suse.de>
> >>
> >>> diff --git a/mm/migrate.c b/mm/migrate.c
> >>> index 5dfd552..ccc814b 100644
> >>> --- a/mm/migrate.c
> >>> +++ b/mm/migrate.c
> >>> @@ -1662,6 +1662,39 @@ void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
> >>>  	smp_rmb();
> >>>  }
> >>>  
> >>> +unsigned long numa_fault_prepare(struct mm_struct *mm)
> >>> +{
> >>> +	/* Paired with task_numa_work */
> >>> +	smp_rmb();
> >>> +	return mm->numa_next_reset;
> >>> +}
> >>
> >> The patch that introduces mm->numa_next_reset, and the
> >> patch that increments it, seem to be missing from your
> >> series...
> >>
> > 
> > Damn. s/numa_next_reset/numa_next_scan/ in that patch
> 
> How does that protect against the race?
> 

It's the local processors TLB I was primarily thinking about and the case
in particular is where the fault has cleared the pmd_numa and the scanner
sets it again before the fault completes and without any flush.

> Would it not be possible for task_numa_work to have a longer
> runtime than the numa fault?
> 

Yes.

> In other words, task_numa_work can increment numa_next_scan
> before the numa fault starts, and still be doing its thing
> when numa_fault_commit is run...
> 

a) the PTE was previously pte_numa, scanner ignores it, fault traps and
   clears it with no flush or TLB consistency due to the page being
   inaccessible before

b) the PTE was previously !pte_numa, scanner will set it
   o Reference is first? No trap
   o Reference is after the scanner goes by. If there is a fault trap,
     it means the local TLB has seen the protection change and is
     consistent. numa_next_scan will not appear to change and a further
     flush should be unnecessary as the page was previously inaccessible

c) PTE was previous pte_numa, fault starts, clears pmd, but scanner
   resets it before the fault returns. In this case, a change in
   numa_next_scan will be observed and the fault will flush the TLB before
   returning. It does mean that that particular page gets flushed twice
   but TLB of the scanner and faulting processor will be consistent on
   return from fault. The faulting CPU will probably fault again due to
   the pte being marked numa.

It was the third situation I was concerned with -- a NUMA fault returning
with pmd_numa still set and the TLBs of different processors having different
views. Due to a potential migration copy, the data may be in the TLB but
now inconsistent with the scanner. What's less clear is how the CPU reacts
in this case or if it's even defined. The architectural manual is vague
on what happens if there is access to a PTE just after a protection change
but before a TLB flush. If it was a race against mprotect and the process
segfaulted, it would be considered a buggy application.

> At that point, numa_fault_commit will not be seeing an
> increment in numa_next_scan, and we are relying completely
> on the batched tlb flush by the change_prot_numa.
> 
> Is that scenario a problem, or is it ok?
> 

I think the TLB is always in an consistent state after the patch even
though additional faults are possible in the event of races.

> And, why? :)
> 

Because I found it impossible to segfault processes under any level of
scanning and numa hinting fault stress after it was applied

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
