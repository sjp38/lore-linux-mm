Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id BA0476B0070
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 17:07:59 -0400 (EDT)
Received: by payr10 with SMTP id r10so105478548pay.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:07:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tz3si5757726pbc.224.2015.06.08.14.07.58
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 14:07:58 -0700 (PDT)
Message-ID: <5576042E.9030001@intel.com>
Date: Mon, 08 Jun 2015 14:07:58 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
References: <1433767854-24408-1-git-send-email-mgorman@suse.de> <20150608174551.GA27558@gmail.com> <5575DD33.3000400@intel.com> <20150608195237.GA15429@gmail.com>
In-Reply-To: <20150608195237.GA15429@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 06/08/2015 12:52 PM, Ingo Molnar wrote:
> A CR3 driven TLB flush takes less time than a single INVLPG (!):
> 
>    [    0.389028] x86/fpu: Cost of: __flush_tlb()               fn            :    96 cycles
>    [    0.405885] x86/fpu: Cost of: __flush_tlb_one()           fn            :   260 cycles
>    [    0.414302] x86/fpu: Cost of: __flush_tlb_range()         fn            :   404 cycles

How was that measured, btw?  Are these instructions running in a loop?
Does __flush_tlb_one() include the tracepoint?

(From the commit I referenced) This was (probably) using a different
method than you did, but "FULL" below is __flush_tlb() while "1" is
__flush_tlb_one().  The "cycles" includes some overhead from the tracing:

>       FULL:   2.20%   2.20% avg cycles:  2283 cycles/page: xxxx samples: 23960
>          1:  56.92%  59.12% avg cycles:  1276 cycles/page: 1276 samples: 620895

So it looks like we've got some discrepancy, either from the test
methodology or the CPU.  All of the code and my methodology are in the
commit.  Could you share yours?

> it's true that a full flush has hidden costs not measured above, because it has 
> knock-on effects (because it drops non-global TLB entries), but it's not _that_ 
> bad due to:
> 
>   - there almost always being a L1 or L2 cache miss when a TLB miss occurs,
>     which latency can be overlaid
> 
>   - global bit being held for kernel entries
> 
>   - user-space with high memory pressure trashing through TLBs typically
> 
> ... and especially with caches and Intel's historically phenomenally low TLB 
> refill latency it's difficult to measure the effects of local TLB refills, let 
> alone measure it in any macro benchmark.

All that you're saying there is that you need to consider how TLB misses
act in _practice_ and not just measure worst-case or theoretical TLB
miss cost.  I completely agree with that.

...
> INVLPG really sucks. I can be convinced by numbers, but this isn't nearly as 
> clear-cut as it might look.

It's clear as mud!

I'd be very interested to see any numbers for how this affects real
workloads.  I've been unable to find anything that was measurably
affected by invlpg vs a full flush.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
