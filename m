Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9856B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 04:47:47 -0400 (EDT)
Received: by wgez8 with SMTP id z8so7455248wge.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 01:47:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vn9si10181562wjc.113.2015.06.09.01.47.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 01:47:45 -0700 (PDT)
Date: Tue, 9 Jun 2015 09:47:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609084739.GQ26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150608174551.GA27558@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jun 08, 2015 at 07:45:51PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Changelog since V4
> > o Rebase to 4.1-rc6
> > 
> > Changelog since V3
> > o Drop batching of TLB flush from migration
> > o Redo how larger batching is managed
> > o Batch TLB flushes when writable entries exist
> > 
> > When unmapping pages it is necessary to flush the TLB. If that page was
> > accessed by another CPU then an IPI is used to flush the remote CPU. That
> > is a lot of IPIs if kswapd is scanning and unmapping >100K pages per second.
> > 
> > There already is a window between when a page is unmapped and when it is
> > TLB flushed. This series simply increases the window so multiple pages
> > can be flushed using a single IPI. This *should* be safe or the kernel is
> > hosed already but I've cc'd the x86 maintainers and some of the Intel folk
> > for comment.
> > 
> > Patch 1 simply made the rest of the series easier to write as ftrace
> > 	could identify all the senders of TLB flush IPIS.
> > 
> > Patch 2 collects a list of PFNs and sends one IPI to flush them all
> > 
> > Patch 3 tracks when there potentially are writable TLB entries that
> > 	need to be batched differently
> > 
> > The performance impact is documented in the changelogs but in the optimistic
> > case on a 4-socket machine the full series reduces interrupts from 900K
> > interrupts/second to 60K interrupts/second.
> 
> Yeah, so I think batching writable flushes is useful I think, but I disagree with 
> one aspect of it: with the need to gather _pfns_ and batch them over to the remote 
> CPU.
> 

It's PFN-based for three reasons. The first is because the old code
is flushing on a per-page basis and the intent of the series was to
reduce the number of IPIs that requires. Moving away from that has an
unpredictable impact that depends on the workload and the exact CPU
used.  The second is that a struct page-based interface would require
percpu_flush_tlb_batch_pages to do a page->pfn lookup in the IPI call which
is more expensive than necessary. The final reason is that the TLB flush
API given to architectures at the moment includes single page primitives
and while it's not necessarily the best decision for x86, the same may
not be true for other architectures if they decide to activate the batching.

> As per my measurements the __flush_tlb_single() primitive (which you use in patch
> #2) is very expensive on most Intel and AMD CPUs. It barely makes sense for a 2
> pages and gets exponentially worse. It's probably done in microcode and its 
> performance is horrible.
> 
> So have you explored the possibility to significantly simplify your patch-set by 
> only deferring the flushing, and doing a simple TLB flush on the remote CPU?

Yes. At one point I looked at range flushing but it is not a good idea.
The ranges that reach the end of the LRU are too large to be useful except
in the ideal case of a workload that sequentially accesses memory. Flushing
the full TLB has an unpredictable cost. Currently, the unmapping and flush
is of inactive pages, some of which may not be in the TLB at all and the
impact on the workload is limited to the IPI and flush cost.

With a full flush we clear entries we know were recently accessed and
may have to be looked up again and we do this every 32 mapped pages that
are reclaimed. In the ideal case of a sequential mapped reader it would
not matter as the entries are not needed so we would not see the cost at
all. Other workloads will have to do a refill that was not necessary before
this series. The cost of the refill will depend on the CPU and whether the
lookup information is still in the CPU cache or not. That means measuring
the full impact of your proposal is impossible as it depends heavily on
the workload, the timing of its interaction with kswapd in particular,
the state of the CPU cache and the cost of refills for the CPU.

I agree with you in that it would be a simplier series and the actual
flush would probably be faster but the downsides are too unpredictable
for a series that primarily is about reducing the number of IPIs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
