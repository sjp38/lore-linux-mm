Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B27BF6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 17:51:00 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so3617446wib.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:51:00 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id jv5si3863133wid.14.2015.06.08.14.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 14:50:59 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so615635wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:50:58 -0700 (PDT)
Date: Mon, 8 Jun 2015 23:50:54 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150608215054.GB30566@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <5575DD33.3000400@intel.com>
 <20150608195237.GA15429@gmail.com>
 <5576042E.9030001@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5576042E.9030001@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave.hansen@intel.com> wrote:

> On 06/08/2015 12:52 PM, Ingo Molnar wrote:
> > A CR3 driven TLB flush takes less time than a single INVLPG (!):
> > 
> >    [    0.389028] x86/fpu: Cost of: __flush_tlb()               fn            :    96 cycles
> >    [    0.405885] x86/fpu: Cost of: __flush_tlb_one()           fn            :   260 cycles
> >    [    0.414302] x86/fpu: Cost of: __flush_tlb_range()         fn            :   404 cycles
> 
> How was that measured, btw?  Are these instructions running in a loop?

Yes - see the x86 benchmarking patch in the big FPU submission for an earlier 
version.

> Does __flush_tlb_one() include the tracepoint?

No tracing overhead.

> (From the commit I referenced) This was (probably) using a different method than 
> you did, but "FULL" below is __flush_tlb() while "1" is __flush_tlb_one().  The 
> "cycles" includes some overhead from the tracing:
> 
> >       FULL:   2.20%   2.20% avg cycles:  2283 cycles/page: xxxx samples: 23960
> >          1:  56.92%  59.12% avg cycles:  1276 cycles/page: 1276 samples: 620895
> 
> So it looks like we've got some discrepancy, either from the test methodology or 
> the CPU.  All of the code and my methodology are in the commit.  Could you share 
> yours?

Yes, you can reproduce it by applying this patch from the FPU series:

  Subject: [PATCH 207/208] x86/fpu: Add FPU performance measurement subsystem

(you were Cc:-ed to it, so it should be in your inbox.)

I've got a more advanced version meanwhile, will post it in the next couple of 
days or so.

> > it's true that a full flush has hidden costs not measured above, because it has 
> > knock-on effects (because it drops non-global TLB entries), but it's not _that_ 
> > bad due to:
> > 
> >   - there almost always being a L1 or L2 cache miss when a TLB miss occurs,
> >     which latency can be overlaid
> > 
> >   - global bit being held for kernel entries
> > 
> >   - user-space with high memory pressure trashing through TLBs typically
> > 
> > ... and especially with caches and Intel's historically phenomenally low TLB 
> > refill latency it's difficult to measure the effects of local TLB refills, let 
> > alone measure it in any macro benchmark.
> 
> All that you're saying there is that you need to consider how TLB misses act in 
> _practice_ and not just measure worst-case or theoretical TLB miss cost.  I 
> completely agree with that.

So I'm saying considerably more than that: I consider it likely that a full TLB 
flush is not nearly as costly as assumed, for the three reasons outlined above.

It might even be a performance win in Mel's benchmark - although possibly not 
measurable within measurement noise levels.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
