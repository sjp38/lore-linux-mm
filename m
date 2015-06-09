Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB396B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 07:21:02 -0400 (EDT)
Received: by wifx6 with SMTP id x6so12997307wif.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 04:21:01 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x19si10843615wjq.43.2015.06.09.04.21.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 04:21:00 -0700 (PDT)
Date: Tue, 9 Jun 2015 12:20:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150609112055.GS26425@suse.de>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150609103231.GA11026@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jun 09, 2015 at 12:32:31PM +0200, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > So have you explored the possibility to significantly simplify your patch-set 
> > > by only deferring the flushing, and doing a simple TLB flush on the remote 
> > > CPU?
> > 
> > Yes. At one point I looked at range flushing but it is not a good idea.
> 
> My suggestion wasn't range-flushing, but a simple all-or-nothing batched flush of 
> user-space TLBs.
> 

I'm aware of that. I had considered both range flushing and full flushing
as alternatives to PFN tracking and settled on PFN tracking as the least
risky change.

> > The ranges that reach the end of the LRU are too large to be useful except in 
> > the ideal case of a workload that sequentially accesses memory. Flushing the 
> > full TLB has an unpredictable cost. [...]
> 
> Why would it have unpredictable cost?

Because we have no means of knowing how many active TLB entries are flushed,
no way of knowing if it matters and we potentially do this every 32
(BATCH_TLBFLUSH_SIZE) pages that are reclaimed.

> We flush the TLB on every process context 
> switch. Yes, it's somewhat workload dependent, but the performance profile is so 
> different anyway with batching that it has to be re-measured anyway.
> 

With the per-page flush, there is a direct cost associated with the
operation -- the IPI and the TLB flushes. This is easy to measure. With
a full flush there is an indirect cost -- the TLB entries that have to be
refilled after the full flush. It also works against any notion of using
ASID or similar mechanisms that avoid full flushes on context switches.

It will be very easy to show the benefit in the direct case. The indirect
case is both unpredictable and impossible to measure the full impact in
all cases.

> > With a full flush we clear entries we know were recently accessed and may have 
> > to be looked up again and we do this every 32 mapped pages that are reclaimed. 
> > In the ideal case of a sequential mapped reader it would not matter as the 
> > entries are not needed so we would not see the cost at all. Other workloads will 
> > have to do a refill that was not necessary before this series. The cost of the 
> > refill will depend on the CPU and whether the lookup information is still in the 
> > CPU cache or not. That means measuring the full impact of your proposal is 
> > impossible as it depends heavily on the workload, the timing of its interaction 
> > with kswapd in particular, the state of the CPU cache and the cost of refills 
> > for the CPU.
> >
> > I agree with you in that it would be a simplier series and the actual flush 
> > would probably be faster but the downsides are too unpredictable for a series 
> > that primarily is about reducing the number of IPIs.
> 
> Sorry, I don't buy this, at all.
> 
> Please measure this, the code would become a lot simpler, as I'm not convinced 
> that we need pfn (or struct page) or even range based flushing.
> 

The code will be simplier and the cost of reclaim will be lower and that
is the direct case but shows nothing about the indirect cost. The mapped
reader will benefit as it is not reusing the TLB entries and will look
artifically very good. It'll be very difficult for even experienced users
to determine that a slowdown during kswapd activity is due to increased
TLB misses incurred by the full flush.

> I.e. please first implement the simplest remote batching variant, then complicate 
> it if the numbers warrant it. Not the other way around. It's not like the VM code 
> needs the extra complexity!
> 

The simplest remote batching variant is a much more drastic change from what
we do today and an unpredictable one. If we were to take that direction,
it goes against the notion of making incremental changes. Even if we
ultimately ended up with your proposal, it would make sense to separte
it from this series by at least one release for bisection purposes. That
way we get;

Current:     Send one IPI per page to unmap, active TLB entries preserved
This series: Send one IPI per BATCH_TLBFLUSH_SIZE pages to unmap, active TLB entries preserved
Your proposal: Send one IPI, flush everything, active TLB entries must refill

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
