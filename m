Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 37ADD6B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:52:43 -0400 (EDT)
Received: by wigg3 with SMTP id g3so63670957wig.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:52:42 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id u3si3366163wiy.42.2015.06.08.12.52.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:52:41 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so111617336wgb.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:52:41 -0700 (PDT)
Date: Mon, 8 Jun 2015 21:52:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150608195237.GA15429@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <5575DD33.3000400@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5575DD33.3000400@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave.hansen@intel.com> wrote:

> On 06/08/2015 10:45 AM, Ingo Molnar wrote:
> > As per my measurements the __flush_tlb_single() primitive (which you use in patch
> > #2) is very expensive on most Intel and AMD CPUs. It barely makes sense for a 2
> > pages and gets exponentially worse. It's probably done in microcode and its 
> > performance is horrible.
> 
> I discussed this a bit in commit a5102476a2.  I'd be curious what
> numbers you came up with.

... which for those of us who don't have sha1's cached in their brain is:

  a5102476a24b ("x86/mm: Set TLB flush tunable to sane value (33)")

;-)

So what I measured agrees generally with the comment you added in the commit:

 + * Each single flush is about 100 ns, so this caps the maximum overhead at
 + * _about_ 3,000 ns.

Let that sink through: 3,000 nsecs = 3 usecs, that's like eternity!

A CR3 driven TLB flush takes less time than a single INVLPG (!):

   [    0.389028] x86/fpu: Cost of: __flush_tlb()               fn            :    96 cycles
   [    0.405885] x86/fpu: Cost of: __flush_tlb_one()           fn            :   260 cycles
   [    0.414302] x86/fpu: Cost of: __flush_tlb_range()         fn            :   404 cycles

it's true that a full flush has hidden costs not measured above, because it has 
knock-on effects (because it drops non-global TLB entries), but it's not _that_ 
bad due to:

  - there almost always being a L1 or L2 cache miss when a TLB miss occurs,
    which latency can be overlaid

  - global bit being held for kernel entries

  - user-space with high memory pressure trashing through TLBs typically

... and especially with caches and Intel's historically phenomenally low TLB 
refill latency it's difficult to measure the effects of local TLB refills, let 
alone measure it in any macro benchmark.

Cross-CPU flushes are expensive, absolutely no argument about that - my suggestion 
here is to keep the batching but simplify it: because I strongly suspect that the 
biggest win is the batching, not the pfn queueing.

We might even win a bit more performance due to the simplification.

> But, don't we have to take in to account the cost of refilling the TLB in 
> addition to the cost of emptying it?  The TLB size is historically increasing on 
> a per-core basis, so isn't this refill cost only going to get worse?

Only if TLB refill latency sucks - but Intel's is very good and AMD's is pretty 
good as well.

Also, usually if you miss the TLB you miss the cache line as well (you definitely 
miss the L1 cache, and TLB caches are sized to hold a fair chunk of your L2 
cache), and the CPU can overlap the two latencies.

So while it might sound counter-intuitive, a full TLB flush might be faster than 
trying to do software based TLB cache management ...

INVLPG really sucks. I can be convinced by numbers, but this isn't nearly as 
clear-cut as it might look.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
