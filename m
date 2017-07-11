Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 15E3B6B0538
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:24:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d77so407765oig.7
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:24:15 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c141si391009oig.176.2017.07.11.10.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 10:24:12 -0700 (PDT)
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ECF3A22C97
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:24:11 +0000 (UTC)
Received: by mail-vk0-f47.google.com with SMTP id 191so3800055vko.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:24:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711155312.637eyzpqeghcgqzp@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de> <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de> <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de> <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Jul 2017 10:23:50 -0700
Message-ID: <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 8:53 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Jul 11, 2017 at 07:58:04AM -0700, Andrew Lutomirski wrote:
>> On Tue, Jul 11, 2017 at 6:20 AM, Mel Gorman <mgorman@suse.de> wrote:
>> > +
>> > +/*
>> > + * This is called after an mprotect update that altered no pages. Batched
>> > + * unmap releases the PTL before a flush occurs leaving a window where
>> > + * an mprotect that reduces access rights can still access the page after
>> > + * mprotect returns via a stale TLB entry. Avoid this possibility by flushing
>> > + * the local TLB if mprotect updates no pages so that the the caller of
>> > + * mprotect always gets expected behaviour. It's overkill and unnecessary to
>> > + * flush all TLBs as a separate thread accessing the data that raced with
>> > + * both reclaim and mprotect as there is no risk of data corruption and
>> > + * the exact timing of a parallel thread seeing a protection update without
>> > + * any serialisation on the application side is always uncertain.
>> > + */
>> > +void batched_unmap_protection_update(void)
>> > +{
>> > +       count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
>> > +       local_flush_tlb();
>> > +       trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
>> > +}
>> > +
>>
>> What about remote CPUs?  You could get migrated right after mprotect()
>> or the inconsistency could be observed on another CPU.
>
> If it's migrated then it has also context switched so the TLB entry will
> be read for the first time.

I don't think this is true.  On current kernels, if the other CPU is
running a thread in the same process, then there won't be a flush if
we migrate there.  In -tip, slated for 4.13, if the other CPU is lazy
and is using the current process's page tables, it won't flush if we
migrate there and it's not stale (as determined by the real flush
APIs, not local_tlb_flush()).  With PCID, the kernel will aggressively
try to avoid the flush no matter what.

> If the entry is inconsistent for another CPU
> accessing the data then it'll potentially successfully access a page that
> was just mprotected but this is similar to simply racing with the call
> to mprotect itself. The timing isn't exact, nor does it need to be.

Thread A:
mprotect(..., PROT_READ);
pthread_mutex_unlock();

Thread B:
pthread_mutex_lock();
write to the mprotected address;

I think it's unlikely that this exact scenario will affect a
conventional C program, but I can see various GC systems and sandboxes
being very surprised.

> One
> thread accessing data racing with another thread doing mprotect without
> any synchronisation in the application is always going to be unreliable.

As above, there can be synchronization that's entirely invisible to the kernel.

>> I also really
>> don't like bypassing arch code like this.  The implementation of
>> flush_tlb_mm_range() in tip:x86/mm (and slated for this merge window!)
>> is *very* different from what's there now, and it is not written in
>> the expectation that some generic code might call local_tlb_flush()
>> and expect any kind of coherency at all.
>>
>
> Assuming that gets merged first then the most straight-forward approach
> would be to setup a arch_tlbflush_unmap_batch with just the local CPU set
> in the mask or something similar.

With what semantics?

>> Would a better fix perhaps be to find a way to figure out whether a
>> batched flush is pending on the mm in question and flush it out if you
>> do any optimizations based on assuming that the TLB is in any respect
>> consistent with the page tables?  With the changes in -tip, x86 could,
>> in principle, supply a function to sync up its TLB state.  That would
>> require cross-CPU poking at state or an inconditional IPI (that might
>> end up not flushing anything), but either is doable.
>
> It's potentially doable if a field like tlb_flush_pending was added
> to mm_struct that is set when batching starts. I don't think there is
> a logical place where it can be cleared as when the TLB gets flushed by
> reclaim, it can't rmap again to clear the flag. What would happen is that
> the first mprotect after any batching happened at any point in the past
> would have to unconditionally flush the TLB and then clear the flag. That
> would be a relatively minor hit and cover all the possibilities and should
> work unmodified with or without your series applied.
>
> Would that be preferable to you?

I'm not sure I understand it well enough to know whether I like it.
I'm imagining an API that says "I'm about to rely on TLBs being
coherent for this mm -- make it so".  On x86, this would be roughly
equivalent to a flush on the mm minus the mandatory flush part, at
least with my patches applied.  It would be considerably messier
without my patches.

But I'd like to make sure that the full extent of the problem is
understood before getting too excited about solving it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
