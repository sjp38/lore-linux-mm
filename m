Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 81B5D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:24:10 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so508532eaj.23
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:24:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si4586156eeg.94.2013.12.19.06.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 06:24:09 -0800 (PST)
Date: Thu, 19 Dec 2013 14:24:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131219142405.GM11295@suse.de>
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
> > It's eliminated for one machine and reduced for another.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  kernel/sched/core.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> > index e85cda2..a848254 100644
> > --- a/kernel/sched/core.c
> > +++ b/kernel/sched/core.c
> > @@ -4902,6 +4902,7 @@ DEFINE_PER_CPU(struct sched_domain *, sd_asym);
> >  static void update_top_cache_domain(int cpu)
> >  {
> >  	struct sched_domain *sd;
> > +	struct sched_domain *busy_sd = NULL;
> >  	int id = cpu;
> >  	int size = 1;
> >  
> > @@ -4909,9 +4910,9 @@ static void update_top_cache_domain(int cpu)
> >  	if (sd) {
> >  		id = cpumask_first(sched_domain_span(sd));
> >  		size = cpumask_weight(sched_domain_span(sd));
> > -		sd = sd->parent; /* sd_busy */
> > +		busy_sd = sd->parent; /* sd_busy */
> >  	}
> > -	rcu_assign_pointer(per_cpu(sd_busy, cpu), sd);
> > +	rcu_assign_pointer(per_cpu(sd_busy, cpu), busy_sd);
> >  
> >  	rcu_assign_pointer(per_cpu(sd_llc, cpu), sd);
> >  	per_cpu(sd_llc_size, cpu) = size;
> 
> Indeed that makes a lot of sense, thanks Mel for tracking down this 
> part of the puzzle! Will get your fix to Linus ASAP.
> 
> Does this fix also speed up Ebizzy's transaction performance, or is 
> its main effect a reduction in workload variation noise?
> 
> Also it appears the Ebizzy numbers ought to be stable enough now to 
> make the range-TLB-flush measurements more precise?

Ok, so the results on this question finally came in. I still have not
profiled this due to other bugs in flight.

fixsd-v3r4 is only the scheduling domain fix
shift-v3r4 is this series, including the tlbshift flush change

8-core machine
ebizzy performance
                     3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
                        vanilla               vanilla            fixsd-v3r4            shift-v3r4
Mean   1      7295.77 (  0.00%)     6713.32 ( -7.98%)     7320.71 (  0.34%)     7744.07 (  6.14%)
Mean   2      8252.58 (  0.00%)     8334.43 (  0.99%)     8233.29 ( -0.23%)     9451.07 ( 14.52%)
Mean   3      8179.74 (  0.00%)     8134.42 ( -0.55%)     8137.38 ( -0.52%)     8947.15 (  9.38%)
Mean   4      7862.45 (  0.00%)     7966.27 (  1.32%)     7837.52 ( -0.32%)     8594.52 (  9.31%)
Mean   5      7170.24 (  0.00%)     7820.63 (  9.07%)     7086.82 ( -1.16%)     8222.22 ( 14.67%)
Mean   6      6835.10 (  0.00%)     7773.30 ( 13.73%)     6822.95 ( -0.18%)     7863.05 ( 15.04%)
Mean   7      6740.99 (  0.00%)     7712.45 ( 14.41%)     6697.30 ( -0.65%)     7537.98 ( 11.82%)
Mean   8      6494.01 (  0.00%)     7705.62 ( 18.66%)     6449.95 ( -0.68%)     6848.89 (  5.46%)
Mean   12     6567.37 (  0.00%)     7554.82 ( 15.04%)     6106.56 ( -7.02%)     6515.51 ( -0.79%)
Mean   16     6630.26 (  0.00%)     7331.04 ( 10.57%)     5999.57 ( -9.51%)     6410.09 ( -3.32%)
Range  1       767.00 (  0.00%)      661.00 ( 13.82%)      182.00 ( 76.27%)      243.00 ( 68.32%)
Range  2       178.00 (  0.00%)      592.00 (-232.58%)      200.00 (-12.36%)      376.00 (-111.24%)
Range  3       175.00 (  0.00%)      431.00 (-146.29%)      225.00 (-28.57%)      522.00 (-198.29%)
Range  4       806.00 (  0.00%)      542.00 ( 32.75%)      878.00 ( -8.93%)      478.00 ( 40.69%)
Range  5       544.00 (  0.00%)      444.00 ( 18.38%)      893.00 (-64.15%)      576.00 ( -5.88%)
Range  6       399.00 (  0.00%)      528.00 (-32.33%)      669.00 (-67.67%)     1134.00 (-184.21%)
Range  7       629.00 (  0.00%)      467.00 ( 25.76%)      517.00 ( 17.81%)      870.00 (-38.31%)
Range  8       400.00 (  0.00%)      435.00 ( -8.75%)      309.00 ( 22.75%)      441.00 (-10.25%)
Range  12      233.00 (  0.00%)      330.00 (-41.63%)      260.00 (-11.59%)      314.00 (-34.76%)
Range  16      141.00 (  0.00%)      496.00 (-251.77%)      127.00 (  9.93%)      156.00 (-10.64%)
Stddev 1        73.94 (  0.00%)      177.17 (-139.59%)       33.77 ( 54.32%)       40.82 ( 44.80%)
Stddev 2        23.47 (  0.00%)       88.91 (-278.74%)       30.60 (-30.35%)       44.64 (-90.17%)
Stddev 3        36.48 (  0.00%)      101.07 (-177.05%)       41.76 (-14.47%)      114.25 (-213.16%)
Stddev 4       158.37 (  0.00%)      130.52 ( 17.59%)      178.91 (-12.97%)      114.66 ( 27.60%)
Stddev 5       116.74 (  0.00%)       78.31 ( 32.92%)      213.76 (-83.10%)      105.69 (  9.47%)
Stddev 6        66.34 (  0.00%)       87.79 (-32.33%)      103.69 (-56.30%)      238.52 (-259.54%)
Stddev 7       145.62 (  0.00%)       90.52 ( 37.84%)      126.49 ( 13.14%)      170.51 (-17.09%)
Stddev 8        68.51 (  0.00%)       81.11 (-18.39%)       45.73 ( 33.25%)       65.11 (  4.96%)
Stddev 12       32.15 (  0.00%)       65.74 (-104.50%)       37.52 (-16.72%)       46.79 (-45.53%)
Stddev 16       21.59 (  0.00%)       86.42 (-300.25%)       26.05 (-20.67%)       37.20 (-72.28%)

Scheduling fix on its own makes little difference and hurts ebizzy if
anything. However, the patch is clearly the right thing to do and we can
still see the tlb flush shift change is required for good results.

As for the stability

8-core machine
ebizzy Thread spread
                     3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
                        vanilla               vanilla            fixsd-v3r4            shift-v3r4
Mean   1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Mean   2         0.40 (  0.00%)        0.13 ( 67.50%)        0.50 (-25.00%)        0.24 ( 40.00%)
Mean   3        23.73 (  0.00%)        0.26 ( 98.90%)       19.80 ( 16.56%)        1.03 ( 95.66%)
Mean   4        12.79 (  0.00%)        0.67 ( 94.76%)        7.92 ( 38.08%)        1.20 ( 90.62%)
Mean   5        13.08 (  0.00%)        0.36 ( 97.25%)      102.28 (-681.96%)        5.86 ( 55.20%)
Mean   6        23.21 (  0.00%)        1.13 ( 95.13%)       13.61 ( 41.36%)       92.37 (-297.98%)
Mean   7        15.85 (  0.00%)        1.51 ( 90.47%)        9.48 ( 40.19%)      131.49 (-729.59%)
Mean   8       109.37 (  0.00%)        1.05 ( 99.04%)        7.37 ( 93.26%)       19.75 ( 81.94%)
Mean   12      124.84 (  0.00%)        0.59 ( 99.53%)       27.32 ( 78.12%)       34.32 ( 72.51%)
Mean   16      113.50 (  0.00%)        0.49 ( 99.57%)       20.02 ( 82.36%)       28.57 ( 74.83%)
Range  1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Range  2         3.00 (  0.00%)        1.00 ( 66.67%)        2.00 ( 33.33%)        1.00 ( 66.67%)
Range  3        80.00 (  0.00%)        1.00 ( 98.75%)       87.00 ( -8.75%)       21.00 ( 73.75%)
Range  4        38.00 (  0.00%)        2.00 ( 94.74%)       39.00 ( -2.63%)        5.00 ( 86.84%)
Range  5        37.00 (  0.00%)        1.00 ( 97.30%)      368.00 (-894.59%)       50.00 (-35.14%)
Range  6        46.00 (  0.00%)        8.00 ( 82.61%)       39.00 ( 15.22%)      876.00 (-1804.35%)
Range  7        28.00 (  0.00%)       36.00 (-28.57%)       21.00 ( 25.00%)      649.00 (-2217.86%)
Range  8       325.00 (  0.00%)       26.00 ( 92.00%)       11.00 ( 96.62%)       74.00 ( 77.23%)
Range  12      160.00 (  0.00%)        5.00 ( 96.88%)       39.00 ( 75.62%)       47.00 ( 70.62%)
Range  16      108.00 (  0.00%)        1.00 ( 99.07%)       29.00 ( 73.15%)       34.00 ( 68.52%)
Stddev 1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Stddev 2         0.62 (  0.00%)        0.34 (-45.44%)        0.66 (  6.38%)        0.43 (-30.72%)
Stddev 3        17.40 (  0.00%)        0.44 (-97.48%)       16.54 ( -4.96%)        2.43 (-86.03%)
Stddev 4         8.52 (  0.00%)        0.51 (-94.00%)        7.81 ( -8.38%)        0.84 (-90.18%)
Stddev 5         7.91 (  0.00%)        0.48 (-93.93%)      105.16 (1229.65%)        9.00 ( 13.74%)
Stddev 6         7.11 (  0.00%)        1.48 (-79.18%)        7.20 (  1.17%)      124.99 (1657.37%)
Stddev 7         5.90 (  0.00%)        4.12 (-30.24%)        4.28 (-27.41%)      110.32 (1769.33%)
Stddev 8        80.95 (  0.00%)        2.65 (-96.72%)        2.63 (-96.76%)       10.01 (-87.64%)
Stddev 12       31.48 (  0.00%)        0.66 (-97.89%)       12.20 (-61.24%)       13.06 (-58.50%)
Stddev 16       24.32 (  0.00%)        0.50 (-97.94%)        8.96 (-63.18%)        9.56 (-60.70%)

The spread is much improved but still less stable than 3.4 was so something
weird is still going on there and the tlb flush measurements are still a
bit questionable.

Still, I had queued up long-lived tests with more thread counts to
measure the impact and found this

4-core
tlbflush
                        3.13.0-rc3            3.13.0-rc3            3.13.0-rc3
                           vanilla            fixsd-v3r4            shift-v3r4
Mean       1       10.68 (  0.00%)       10.27 (  3.83%)       10.45 (  2.11%)
Mean       2       11.02 (  0.00%)       18.62 (-68.97%)       22.57 (-104.79%)
Mean       3       22.73 (  0.00%)       22.95 ( -0.99%)       22.10 (  2.76%)
Mean       5       51.06 (  0.00%)       47.20 (  7.56%)       46.45 (  9.03%)
Mean       8       82.62 (  0.00%)       43.67 ( 47.15%)       42.72 ( 48.29%)
Range      1        6.00 (  0.00%)        8.00 (-33.33%)        8.00 (-33.33%)
Range      2       17.00 (  0.00%)       52.00 (-205.88%)       49.00 (-188.24%)
Range      3       15.00 (  0.00%)       24.00 (-60.00%)       24.00 (-60.00%)
Range      5       36.00 (  0.00%)       35.00 (  2.78%)       21.00 ( 41.67%)
Range      8       49.00 (  0.00%)       10.00 ( 79.59%)       15.00 ( 69.39%)
Stddev     1        0.95 (  0.00%)        1.28 ( 35.11%)        0.87 ( -7.82%)
Stddev     2        1.67 (  0.00%)       15.21 (812.95%)       16.25 (875.62%)
Stddev     3        2.53 (  0.00%)        3.42 ( 35.13%)        3.05 ( 20.61%)
Stddev     5        4.25 (  0.00%)        4.31 (  1.37%)        3.65 (-14.16%)
Stddev     8        5.71 (  0.00%)        1.88 (-67.09%)        1.71 (-70.12%)

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanilla  fixsd-v3r4  shift-v3r4
User          804.88      900.31     1057.53
System        526.53      507.57      578.95
Elapsed     12629.24    14931.78    17925.47

There are 320 iterations of the test per thread count. The number of
entries is randomly selected with a min of 1 and max of 512. To ensure
a reasonably even spread of entries, the full range is broken up into 8
sections and a random number selected within that section.

iteration 1, random number between 0-64
iteration 2, random number between 64-128 etc

This is actually still a very weak methodology. When you do not know what
are typical ranges, random is a reasonable choice but it can be easily
argued that the opimisation was for smaller ranges and an even spread is
not representative of any workload that matters. To improve this, we'd
need to know the probability distribution of TLB flush range sizes for a
set of workloads that are considered "common", build a synthetic trace and
feed that into this benchmark. Even that is not perfect because it would
not account for the time between flushes but there are limits of what can
be reasonably done and still be doing something useful. Alex or Peter,
was there any specific methodology used for selecting the ranges to be
flushed by the microbenchmark?

Anyway, random ranges on the 4-core machine showed that the conservative
choice was a good one in many cases. Two threads seems to be screwed implying
that fixing the scheduling domain may have meant we are frequently sending
an IPI to a relatively remote core. It's a separate issue because that
smacks of being a pure scheduling problem.

8-core
tlbflush
                         3.13.0-rc3            3.13.0-rc3            3.13.0-rc3
                            vanilla            fixsd-v3r4            shift-v3r4
Mean       1         8.78 (  0.00%)        9.54 ( -8.65%)        9.46 ( -7.76%)
Mean       2         8.19 (  0.00%)        9.54 (-16.44%)        9.43 (-15.03%)
Mean       3         8.86 (  0.00%)        9.95 (-12.39%)        9.81 (-10.80%)
Mean       5        13.38 (  0.00%)       14.67 ( -9.60%)       15.51 (-15.93%)
Mean       8        32.97 (  0.00%)       40.88 (-24.02%)       38.91 (-18.04%)
Mean       13       68.47 (  0.00%)       32.10 ( 53.12%)       31.38 ( 54.16%)
Mean       16       86.15 (  0.00%)       40.10 ( 53.46%)       39.04 ( 54.68%)
Range      1         7.00 (  0.00%)        8.00 (-14.29%)        7.00 (  0.00%)
Range      2         6.00 (  0.00%)       38.00 (-533.33%)       36.00 (-500.00%)
Range      3        12.00 (  0.00%)       18.00 (-50.00%)       17.00 (-41.67%)
Range      5        16.00 (  0.00%)       34.00 (-112.50%)       27.00 (-68.75%)
Range      8        34.00 (  0.00%)       23.00 ( 32.35%)       21.00 ( 38.24%)
Range      13       47.00 (  0.00%)       11.00 ( 76.60%)        9.00 ( 80.85%)
Range      16       50.00 (  0.00%)       12.00 ( 76.00%)       11.00 ( 78.00%)
Stddev     1         1.46 (  0.00%)        1.58 (  8.37%)        1.24 (-15.19%)
Stddev     2         1.47 (  0.00%)        4.11 (180.46%)        2.65 ( 80.77%)
Stddev     3         2.00 (  0.00%)        3.61 ( 80.40%)        2.73 ( 36.59%)
Stddev     5         2.36 (  0.00%)        4.71 (100.05%)        5.01 (112.85%)
Stddev     8         7.03 (  0.00%)        4.54 (-35.42%)        4.08 (-41.92%)
Stddev     13        6.80 (  0.00%)        2.28 (-66.48%)        1.67 (-75.53%)
Stddev     16        7.36 (  0.00%)        2.71 (-63.22%)        2.14 (-70.93%)

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanilla  fixsd-v3r4  shift-v3r4
User         3181.72     3640.00     4234.63
System       3043.31     2746.05     3606.61
Elapsed     31871.22    34678.69    38131.45

And this shows for two Ivybridge processors that the select of shift value
gives different results. I wonder was that taken into account. This is
showing that we see big relative regressions for lower number of threads
*but* the absolute difference between them is very small. There are
relatively big gains for higher numbers of threads *and* big absolute
gains. The worst case is far less worse with the series applied at least
for randomly selected ranges to flush.

Because we lack data on TLB range flush distributions I think we should
still go with the conservative choice for the TLB flush shift. The worst
case is really bad here and it's painfully obvious on ebizzy.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
