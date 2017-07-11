Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00E826B050F
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:58:28 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t188so119801oih.15
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:58:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g7si109879oif.371.2017.07.11.07.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 07:58:27 -0700 (PDT)
Received: from mail-ua0-f173.google.com (mail-ua0-f173.google.com [209.85.217.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 600DE22C99
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:58:26 +0000 (UTC)
Received: by mail-ua0-f173.google.com with SMTP id g40so1530481uaa.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:58:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de> <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de> <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Jul 2017 07:58:04 -0700
Message-ID: <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 6:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> +
> +/*
> + * This is called after an mprotect update that altered no pages. Batched
> + * unmap releases the PTL before a flush occurs leaving a window where
> + * an mprotect that reduces access rights can still access the page after
> + * mprotect returns via a stale TLB entry. Avoid this possibility by flushing
> + * the local TLB if mprotect updates no pages so that the the caller of
> + * mprotect always gets expected behaviour. It's overkill and unnecessary to
> + * flush all TLBs as a separate thread accessing the data that raced with
> + * both reclaim and mprotect as there is no risk of data corruption and
> + * the exact timing of a parallel thread seeing a protection update without
> + * any serialisation on the application side is always uncertain.
> + */
> +void batched_unmap_protection_update(void)
> +{
> +       count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> +       local_flush_tlb();
> +       trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> +}
> +

What about remote CPUs?  You could get migrated right after mprotect()
or the inconsistency could be observed on another CPU.  I also really
don't like bypassing arch code like this.  The implementation of
flush_tlb_mm_range() in tip:x86/mm (and slated for this merge window!)
is *very* different from what's there now, and it is not written in
the expectation that some generic code might call local_tlb_flush()
and expect any kind of coherency at all.

I'm also still nervous about situations in which, while a batched
flush is active, a user calls mprotect() and then does something else
that gets confused by the fact that there's an RO PTE and doesn't
flush out the RW TLB entry.  COWing a page, perhaps?

Would a better fix perhaps be to find a way to figure out whether a
batched flush is pending on the mm in question and flush it out if you
do any optimizations based on assuming that the TLB is in any respect
consistent with the page tables?  With the changes in -tip, x86 could,
in principle, supply a function to sync up its TLB state.  That would
require cross-CPU poking at state or an inconditional IPI (that might
end up not flushing anything), but either is doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
