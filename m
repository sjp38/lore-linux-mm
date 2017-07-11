Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 725126B0528
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:53:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z45so951210wrb.13
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:53:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r30si195700wra.315.2017.07.11.08.53.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 08:53:14 -0700 (PDT)
Date: Tue, 11 Jul 2017 16:53:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711155312.637eyzpqeghcgqzp@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 07:58:04AM -0700, Andrew Lutomirski wrote:
> On Tue, Jul 11, 2017 at 6:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> > +
> > +/*
> > + * This is called after an mprotect update that altered no pages. Batched
> > + * unmap releases the PTL before a flush occurs leaving a window where
> > + * an mprotect that reduces access rights can still access the page after
> > + * mprotect returns via a stale TLB entry. Avoid this possibility by flushing
> > + * the local TLB if mprotect updates no pages so that the the caller of
> > + * mprotect always gets expected behaviour. It's overkill and unnecessary to
> > + * flush all TLBs as a separate thread accessing the data that raced with
> > + * both reclaim and mprotect as there is no risk of data corruption and
> > + * the exact timing of a parallel thread seeing a protection update without
> > + * any serialisation on the application side is always uncertain.
> > + */
> > +void batched_unmap_protection_update(void)
> > +{
> > +       count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> > +       local_flush_tlb();
> > +       trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> > +}
> > +
> 
> What about remote CPUs?  You could get migrated right after mprotect()
> or the inconsistency could be observed on another CPU. 

If it's migrated then it has also context switched so the TLB entry will
be read for the first time. If the entry is inconsistent for another CPU
accessing the data then it'll potentially successfully access a page that
was just mprotected but this is similar to simply racing with the call
to mprotect itself. The timing isn't exact, nor does it need to be. One
thread accessing data racing with another thread doing mprotect without
any synchronisation in the application is always going to be unreliable.
I'm less certain once PCID tracking is in place and whether it's possible for
a process to be context switching fast enough to allow an access. If it's
possible then batching would require an unconditional flush on mprotect
even if no pages are updated if access is being limited by the mprotect
which would be unfortunate.

> I also really
> don't like bypassing arch code like this.  The implementation of
> flush_tlb_mm_range() in tip:x86/mm (and slated for this merge window!)
> is *very* different from what's there now, and it is not written in
> the expectation that some generic code might call local_tlb_flush()
> and expect any kind of coherency at all.
> 

Assuming that gets merged first then the most straight-forward approach
would be to setup a arch_tlbflush_unmap_batch with just the local CPU set
in the mask or something similar.

> I'm also still nervous about situations in which, while a batched
> flush is active, a user calls mprotect() and then does something else
> that gets confused by the fact that there's an RO PTE and doesn't
> flush out the RW TLB entry.  COWing a page, perhaps?
> 

The race in question only applies if mprotect had no PTEs to update. If
any page was updated then the TLB is flushed before mprotect returns.
With the patch (or a variant on top of your work), at least the local TLB
will be flushed even if no PTEs were updated. This might be more expensive
than it has to be but I expect that mprotects on range with no PTEs to
update are fairly rare.

> Would a better fix perhaps be to find a way to figure out whether a
> batched flush is pending on the mm in question and flush it out if you
> do any optimizations based on assuming that the TLB is in any respect
> consistent with the page tables?  With the changes in -tip, x86 could,
> in principle, supply a function to sync up its TLB state.  That would
> require cross-CPU poking at state or an inconditional IPI (that might
> end up not flushing anything), but either is doable.

It's potentially doable if a field like tlb_flush_pending was added
to mm_struct that is set when batching starts. I don't think there is
a logical place where it can be cleared as when the TLB gets flushed by
reclaim, it can't rmap again to clear the flag. What would happen is that
the first mprotect after any batching happened at any point in the past
would have to unconditionally flush the TLB and then clear the flag. That
would be a relatively minor hit and cover all the possibilities and should
work unmodified with or without your series applied.

Would that be preferable to you?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
