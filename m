Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5326B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 09:32:58 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so2900437eek.23
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:32:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si4908401eeh.122.2013.12.17.06.32.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 06:32:57 -0800 (PST)
Date: Tue, 17 Dec 2013 14:32:53 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131217143253.GB11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131217110051.GA27701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Dec 17, 2013 at 12:00:51PM +0100, Ingo Molnar wrote:
> 
> > sched: Assign correct scheduling domain to sd_llc
> > 
> > Commit 42eb088e (sched: Avoid NULL dereference on sd_busy) corrected a NULL
> > dereference on sd_busy but the fix also altered what scheduling domain it
> > used for sd_llc. One impact of this is that a task selecting a runqueue may
> > consider idle CPUs that are not cache siblings as candidates for running.
> > Tasks are then running on CPUs that are not cache hot.
> > 
> > <PATCH SNIPPED>
> 
> Indeed that makes a lot of sense, thanks Mel for tracking down this 
> part of the puzzle! Will get your fix to Linus ASAP.
> 
> Does this fix also speed up Ebizzy's transaction performance, or is 
> its main effect a reduction in workload variation noise?
> 

Mixed results, some gains and some losses.

                     3.13.0-rc3            3.13.0-rc3                3.4.69            3.13.0-rc3
                        vanilla           nowalk-v2r7               vanilla            fixsd-v3r3
Mean   1      7295.77 (  0.00%)     7835.63 (  7.40%)     6713.32 ( -7.98%)     7757.03 (  6.32%)
Mean   2      8252.58 (  0.00%)     9554.63 ( 15.78%)     8334.43 (  0.99%)     9457.34 ( 14.60%)
Mean   3      8179.74 (  0.00%)     9032.46 ( 10.42%)     8134.42 ( -0.55%)     8928.25 (  9.15%)
Mean   4      7862.45 (  0.00%)     8688.01 ( 10.50%)     7966.27 (  1.32%)     8560.87 (  8.88%)
Mean   5      7170.24 (  0.00%)     8216.15 ( 14.59%)     7820.63 (  9.07%)     8270.72 ( 15.35%)
Mean   6      6835.10 (  0.00%)     7866.95 ( 15.10%)     7773.30 ( 13.73%)     7998.50 ( 17.02%)
Mean   7      6740.99 (  0.00%)     7586.36 ( 12.54%)     7712.45 ( 14.41%)     7519.46 ( 11.55%)
Mean   8      6494.01 (  0.00%)     6849.82 (  5.48%)     7705.62 ( 18.66%)     6842.44 (  5.37%)
Mean   12     6567.37 (  0.00%)     6973.66 (  6.19%)     7554.82 ( 15.04%)     6471.83 ( -1.45%)
Mean   16     6630.26 (  0.00%)     7042.52 (  6.22%)     7331.04 ( 10.57%)     6380.16 ( -3.77%)
Range  1       767.00 (  0.00%)      194.00 ( 74.71%)      661.00 ( 13.82%)      217.00 ( 71.71%)
Range  2       178.00 (  0.00%)      185.00 ( -3.93%)      592.00 (-232.58%)      240.00 (-34.83%)
Range  3       175.00 (  0.00%)      213.00 (-21.71%)      431.00 (-146.29%)      511.00 (-192.00%)
Range  4       806.00 (  0.00%)      924.00 (-14.64%)      542.00 ( 32.75%)      723.00 ( 10.30%)
Range  5       544.00 (  0.00%)      438.00 ( 19.49%)      444.00 ( 18.38%)      663.00 (-21.88%)
Range  6       399.00 (  0.00%)     1111.00 (-178.45%)      528.00 (-32.33%)     1031.00 (-158.40%)
Range  7       629.00 (  0.00%)      895.00 (-42.29%)      467.00 ( 25.76%)      877.00 (-39.43%)
Range  8       400.00 (  0.00%)      255.00 ( 36.25%)      435.00 ( -8.75%)      656.00 (-64.00%)
Range  12      233.00 (  0.00%)      108.00 ( 53.65%)      330.00 (-41.63%)      343.00 (-47.21%)
Range  16      141.00 (  0.00%)      134.00 (  4.96%)      496.00 (-251.77%)      291.00 (-106.38%)
Stddev 1        73.94 (  0.00%)       52.33 ( 29.23%)      177.17 (-139.59%)       37.34 ( 49.51%)
Stddev 2        23.47 (  0.00%)       42.08 (-79.24%)       88.91 (-278.74%)       38.16 (-62.58%)
Stddev 3        36.48 (  0.00%)       29.02 ( 20.45%)      101.07 (-177.05%)      134.62 (-269.01%)
Stddev 4       158.37 (  0.00%)      133.99 ( 15.40%)      130.52 ( 17.59%)      150.61 (  4.90%)
Stddev 5       116.74 (  0.00%)       76.76 ( 34.25%)       78.31 ( 32.92%)      116.67 (  0.06%)
Stddev 6        66.34 (  0.00%)      273.87 (-312.83%)       87.79 (-32.33%)      235.11 (-254.40%)
Stddev 7       145.62 (  0.00%)      174.99 (-20.16%)       90.52 ( 37.84%)      156.08 ( -7.18%)
Stddev 8        68.51 (  0.00%)       47.58 ( 30.54%)       81.11 (-18.39%)       96.00 (-40.13%)
Stddev 12       32.15 (  0.00%)       20.18 ( 37.22%)       65.74 (-104.50%)       45.00 (-39.99%)
Stddev 16       21.59 (  0.00%)       20.29 (  6.01%)       86.42 (-300.25%)       38.20 (-76.93%)

fixsd-v3r3 is all the patches discussed so far applied. Lost at higher
thread counts, won at lower ones. All the results still worse than 3.4.69

To complicate matters further, additional testing indicated that the
tlbflush shift change *may* have made the variation worse. I was preparing
to bisect to search for patches that increased "thread performance spread"
in ebizzy and tested a number of potential bisect points

Tue 17 Dec 11:11:08 GMT 2013 ivy ebizzyrange v3.12 mean-max:36 good
Tue 17 Dec 11:32:28 GMT 2013 ivy ebizzyrange v3.13-rc3 mean-max:80 bad
Tue 17 Dec 12:00:23 GMT 2013 ivy ebizzyrange v3.4 mean-max:0 good
Tue 17 Dec 12:21:58 GMT 2013 ivy ebizzyrange v3.10 mean-max:26 good
Tue 17 Dec 12:42:49 GMT 2013 ivy ebizzyrange v3.11 mean-max:7 good
Tue 17 Dec 13:32:14 GMT 2013 ivy ebizzyrange x86-tlb-range-flush-optimisation-v3r3 mean-max:110 bad

This is part of the log for an automated bisection script.  mean-max is
the worst average spread recorded for all threads tested. It's telling
me that the worst thread spread seen by v3.13-rc3 is 80 and the worst
seen by the patch series (tlbflush shift change, fix to sd etc) is 110.

The bisection is doing very few iterations so it could just be co-incidence
but it makes sense. If the kernel is scheduling tasks on CPUs that are not
cache siblings then the cost of remote TLB flushes (range or otherwise)
changes. It's an important enough problem that I feel compelled to
retest with

x86: mm: Clean up inconsistencies when flushing TLB ranges
x86: mm: Account for TLB flushes only when debugging
x86: mm: Eliminate redundant page table walk during TLB range flushing
sched: Assign correct scheduling domain to sd_llc

I'll then re-evalate the tlbflush shift patch based on what falls out of
that test. It may turn out that tlbflush shifts on its own simply cannot
optimise for both the tlbflush microbenchmark and ebizzy as the former
deals with average cost and the latter hits the worst case every time.

At that point it'll be time to look at profiles and see where we are
actually spending time because the possibilities of finding things to fix
through bisection will be exhausted.

> Also it appears the Ebizzy numbers ought to be stable enough now to 
> make the range-TLB-flush measurements more precise?
> 

Right now, the tlbflush microbenchmark figures look awful on the 8-core
machine when the tlbflush shift patch and the schedule domain fix are
both applied.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
