Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 12A8F6B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 16:03:14 -0400 (EDT)
Received: by wiga1 with SMTP id a1so97951087wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 13:03:13 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id fa2si3410348wib.27.2015.06.08.13.03.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 13:03:12 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so97392456wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 13:03:12 -0700 (PDT)
Date: Mon, 8 Jun 2015 22:03:08 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150608200308.GA16978@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <5575DD33.3000400@intel.com>
 <20150608195237.GA15429@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150608195237.GA15429@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Ingo Molnar <mingo@kernel.org> wrote:

> So what I measured agrees generally with the comment you added in the commit:
> 
>  + * Each single flush is about 100 ns, so this caps the maximum overhead at
>  + * _about_ 3,000 ns.
> 
> Let that sink through: 3,000 nsecs = 3 usecs, that's like eternity!
> 
> A CR3 driven TLB flush takes less time than a single INVLPG (!):
> 
>    [    0.389028] x86/fpu: Cost of: __flush_tlb()               fn            :    96 cycles
>    [    0.405885] x86/fpu: Cost of: __flush_tlb_one()           fn            :   260 cycles
>    [    0.414302] x86/fpu: Cost of: __flush_tlb_range()         fn            :   404 cycles
> 
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

I also have cache-cold numbers from another (Intel) system:

[    0.176473] x86/bench:##########################################################################
[    0.185656] x86/bench: Running x86 benchmarks:                     cache-    hot /   cold cycles
[    1.234448] x86/bench: Cost of: null                                    :     35 /     73 cycles
[    ........]
[   27.930451] x86/bench:########  MM instructions:          ######################################
[   28.979251] x86/bench: Cost of: __flush_tlb()             fn            :    251 /    366 cycles
[   30.028795] x86/bench: Cost of: __flush_tlb_global()      fn            :    746 /   1795 cycles
[   31.077862] x86/bench: Cost of: __flush_tlb_one()         fn            :    237 /    883 cycles
[   32.127371] x86/bench: Cost of: __flush_tlb_range()       fn            :    312 /   1603 cycles
[   35.254202] x86/bench: Cost of: wbinvd()                  insn          : 2491761 / 2491922 cycles

Note how the numbers are even worse in the cache-cold case: the algorithmic 
complexity of __flush_tlb_range() versus __flush_tlb() makes it run slower 
(because we miss the I$), while the TLB cache-preservation argument is probably 
weaker, because when we are cache cold then TLB refill latency probably matters 
less (as it can be overlapped).

So __flush_tlb_range() is software trying to beat hardware, and that's almost 
always a bad idea on x86.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
