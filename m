Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3A46B053C
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 04:27:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p64so3771664wrc.8
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 01:27:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y21si1638056wmh.132.2017.07.12.01.27.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 01:27:35 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:27:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170712082733.ouf7yx2bnvwwcfms@suse.de>
References: <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 03:27:55PM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Tue, Jul 11, 2017 at 09:09:23PM +0100, Mel Gorman wrote:
> >> On Tue, Jul 11, 2017 at 08:18:23PM +0100, Mel Gorman wrote:
> >>> I don't think we should be particularly clever about this and instead just
> >>> flush the full mm if there is a risk of a parallel batching of flushing is
> >>> in progress resulting in a stale TLB entry being used. I think tracking mms
> >>> that are currently batching would end up being costly in terms of memory,
> >>> fairly complex, or both. Something like this?
> >> 
> >> mremap and madvise(DONTNEED) would also need to flush. Memory policies are
> >> fine as a move_pages call that hits the race will simply fail to migrate
> >> a page that is being freed and once migration starts, it'll be flushed so
> >> a stale access has no further risk. copy_page_range should also be ok as
> >> the old mm is flushed and the new mm cannot have entries yet.
> > 
> > Adding those results in
> 
> You are way too fast for me.
> 
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -637,12 +637,34 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
> > 		return false;
> > 
> > 	/* If remote CPUs need to be flushed then defer batch the flush */
> > -	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
> > +	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids) {
> > 		should_defer = true;
> > +		mm->tlb_flush_batched = true;
> > +	}
> 
> Since mm->tlb_flush_batched is set before the PTE is actually cleared, it
> still seems to leave a short window for a race.
> 
> CPU0				CPU1
> ---- 				----
> should_defer_flush
> => mm->tlb_flush_batched=true		
> 				flush_tlb_batched_pending (another PT)
> 				=> flush TLB
> 				=> mm->tlb_flush_batched=false
> ptep_get_and_clear
> ...
> 
> 				flush_tlb_batched_pending (batched PT)
> 				use the stale PTE
> ...
> try_to_unmap_flush
> 
> IOW it seems that mm->flush_flush_batched should be set after the PTE is
> cleared (and have some compiler barrier to be on the safe side).

I'm relying on setting and clearing of tlb_flush_batched is under a PTL
that is contended if the race is active.

If reclaim is first, it'll take the PTL, set batched while a racing
mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
immediately calls flush_tlb_batched_pending() before proceeding as normal,
finding pte_none with the TLB flushed.

If the mprotect/munmap/etc is first, it'll take the PTL, observe that
pte_present and handle the flushing itself while reclaim potentially
spins. When reclaim acquires the lock, it'll still set set tlb_flush_batched.

As it's PTL that is taken for that field, it is possible for the accesses
to be re-ordered but only in the case where a race is not occurring.
I'll think some more about whether barriers are necessary but concluded
they weren't needed in this instance. Doing the setting/clear+flush under
the PTL, the protection is similar to normal page table operations that
do not batch the flush.

> One more question, please: how does elevated page count or even locking the
> page help (as you mention in regard to uprobes and ksm)? Yes, the page will
> not be reclaimed, but IIUC try_to_unmap is called before the reference count
> is frozen, and the page lock is dropped on each iteration of the loop in
> shrink_page_list. In this case, it seems to me that uprobes or ksm may still
> not flush the TLB.
> 

If page lock is held then reclaim skips the page entirely and uprobe,
ksm and cow holds the page lock for pages that potentially be observed
by reclaim.  That is the primary protection for those paths.

The elevated page count is less relevant but I was keeping it in mind
trying to think of cases where a stale TLB entry existed and pointed to
the wrong page.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
