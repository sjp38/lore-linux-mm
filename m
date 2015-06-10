Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A8EEB6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:26:45 -0400 (EDT)
Received: by wgme6 with SMTP id e6so29753733wgm.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:26:45 -0700 (PDT)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id az10si8176538wib.65.2015.06.10.01.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 01:26:44 -0700 (PDT)
Received: by wgez8 with SMTP id z8so29814266wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:26:43 -0700 (PDT)
Date: Wed, 10 Jun 2015 10:26:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/4] mm: Send one IPI per CPU to TLB flush all entries
 after unmapping pages
Message-ID: <20150610082640.GA24483@gmail.com>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433871118-15207-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> On a 4-socket machine the results were
> 
>                                         4.1.0-rc6          4.1.0-rc6
>                                     batchdirty-v6      batchunmap-v6
> Ops lru-file-mmap-read-elapsed   121.27 (  0.00%)   118.79 (  2.05%)
> 
>            4.1.0-rc6      4.1.0-rc6
>         batchdirty-v6 batchunmap-v6
> User          620.84         608.48
> System       4245.35        4152.89
> Elapsed       122.65         120.15
> 
> In this case the workload completed faster and there was less CPU overhead
> but as it's a NUMA machine there are a lot of factors at play. It's easier
> to quantify on a single socket machine;
> 
>                                         4.1.0-rc6          4.1.0-rc6
>                                     batchdirty-v6      batchunmap-v6
> Ops lru-file-mmap-read-elapsed    20.35 (  0.00%)    21.52 ( -5.75%)
> 
>            4.1.0-rc6   4.1.0-rc6
>         batchdirty-v6r5batchunmap-v6r5
> User           58.02       60.70
> System         77.57       81.92
> Elapsed        22.14       23.16
> 
> That shows the workload takes 5.75% longer to complete with a similar
> increase in the system CPU usage.

Btw., do you have any stddev noise numbers?

The batching speedup is brutal enough to not need any noise estimations, it's a 
clear winner.

But this PFN tracking patch is more difficult to judge as the numbers are pretty 
close to each other.

> It is expected that there is overhead to tracking the PFNs and flushing 
> individual pages. This can be quantified but we cannot quantify the indirect 
> savings due to active unrelated TLB entries being preserved. Whether this 
> matters depends on whether the workload was using those entries and if they 
> would be used before a context switch but targeting the TLB flushes is the 
> conservative and safer choice.

So this is how I picture a realistic TLB flushing 'worst case': a workload that 
uses about 80% of the TLB cache in a 'fast' function and trashes memory in a 
'slow' function, and does alternate calls to the two functions from the same task.

Typical dTLB sizes on x86 are a couple of hundred entries (you can see the precise 
count in x86info -c), up to 1024 entries on the latest uarchs.

A cached TLB miss will take about 10-20 cycles (progressively more if the lookup 
chain misses in the cache) - but that cost is partially hidden if the L1 data 
cache was missed (which is likely for most TLB-flush intense workloads), and will 
be almost completely hidden if it goes out to the L3 cache or goes to RAM. (It 
takes up cache/memory bandwidth though, but unless the access patters are totally 
sparse, it should be a small fraction.)

A single INVLPG with its 200+ cycles cost is equivalent to about 10-20 TLB misses. 
That's a lot.

So this kind of workload should trigger the TLB flushing 'worst case': with say 
512 dTLB entries you could see up to 5k-10k cycles of hidden/indirect cost, but 
potentially parallelized with other misses going on with the same data accesses.

The current limit for INVLPG flushing is 33 entries: that's 10k-20k cycles max 
with an INVLPG cost of 250 cycles - this could explain the results you got.

But the problem is: AFAICS you can only decrease the INVLPG count by decreasing 
the batching size - the additional IPI costs will overwhelm any TLB preservation 
benefits. So depending on the cost relationship between INVLPG, TLB miss cost and 
IPI cost, it might not be possible to see a speedup even in the worst-case.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
