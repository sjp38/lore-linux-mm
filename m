Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA686B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:40:35 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so290700eaj.9
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:40:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si13289896eel.196.2013.12.12.06.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 06:40:34 -0800 (PST)
Date: Thu, 12 Dec 2013 14:40:29 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/3] Fix ebizzy performance regression on IvyBridge
 due to X86 TLB range flush
Message-ID: <20131212144029.GI11295@suse.de>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <20131212130107.GC5806@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131212130107.GC5806@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Alex Shi <alex.shi@linaro.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 12, 2013 at 02:01:07PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > I found that ebizzy regressed between 3.4 and 3.10 while testing on a new
> > machine. Bisection initially found at least two problems of which the
> > first was commit 611ae8e3 (x86/tlb: enable tlb flush range support for
> > x86). The second was related to ACPI cpufreq and so it was disabled for
> > the purposes of this series.
> > 
> > The intent of the TLB range flush patch appeared to be to preserve
> > existing TLB entries which makes sense. The decision on whether to do a
> > full mm flush or a number of single page flushes depends on the size of the
> > relevant TLB and the CPU which is presuably taking the cost of a TLB refill.
> > It is a gamble because the cost of the per-page flushes must be offset by a
> > reduced TLB miss count. There are no indications what the cost of calling
> > invlpg are if there are no TLB entries and it's also not taking into
> > account how many CPUs it may have to execute these single TLB flushes on.
> > 
> > Ebizzy sees very little benefit as it discards newly allocated memory very
> > quickly which is why it appeared to regress so badly. While I'm wary of
> > optimising for such a benchmark, it's commonly tested and the defaults for
> > Ivybridge may need to be re-examined.
> > 
> > The following small series restores ebizzy to 3.4-era performance. Is there a
> > better way of doing this? Bear in mind that I'm testing on a single IvyBridge
> > machine and there is no guarantee the gain is universal or even relevant.
> > 
> > kernel build was tested but it's uninteresting as TLB range is unimportant
> > to it. A page fault benchmark was also tested but it does not hit the same paths
> > impacted by commit 611ae8e3.
> > 
> > ebizzy
> >                        3.13.0-rc3                3.4.69            3.13.0-rc3
> >                           vanilla               vanilla           newdefault-v1
> > Mean     1      7353.60 (  0.00%)     6782.00 ( -7.77%)     7836.20 (  6.56%)
> > Mean     2      8120.40 (  0.00%)     8278.80 (  1.95%)     9520.60 ( 17.24%)
> > Mean     3      8087.80 (  0.00%)     8083.60 ( -0.05%)     9003.80 ( 11.33%)
> > Mean     4      7919.20 (  0.00%)     7842.60 ( -0.97%)     8680.60 (  9.61%)
> > Mean     5      7310.60 (  0.00%)     7740.60 (  5.88%)     8273.20 ( 13.17%)
> > Mean     6      6798.00 (  0.00%)     7720.20 ( 13.57%)     8033.20 ( 18.17%)
> > Mean     7      6759.40 (  0.00%)     7644.00 ( 13.09%)     7643.80 ( 13.08%)
> > Mean     8      6501.80 (  0.00%)     7666.40 ( 17.91%)     6944.40 (  6.81%)
> > Mean     12     6606.00 (  0.00%)     7523.20 ( 13.88%)     7035.80 (  6.51%)
> > Mean     16     6655.40 (  0.00%)     7287.40 (  9.50%)     7099.20 (  6.67%)
> > Mean     20     6703.80 (  0.00%)     7152.20 (  6.69%)     7116.60 (  6.16%)
> > Mean     24     6705.80 (  0.00%)     7014.80 (  4.61%)     7113.60 (  6.08%)
> > Mean     28     6706.60 (  0.00%)     6940.40 (  3.49%)     7115.20 (  6.09%)
> > Mean     32     6727.20 (  0.00%)     6878.80 (  2.25%)     7110.80 (  5.70%)
> > Stddev   1        42.71 (  0.00%)       53.16 (-24.46%)       39.80 (  6.82%)
> > Stddev   2       250.26 (  0.00%)      150.57 ( 39.84%)       31.94 ( 87.24%)
> > Stddev   3        71.67 (  0.00%)       69.38 (  3.19%)       84.13 (-17.39%)
> > Stddev   4        30.25 (  0.00%)       87.06 (-187.82%)       31.80 ( -5.14%)
> > Stddev   5        71.18 (  0.00%)       25.68 ( 63.92%)      125.24 (-75.95%)
> > Stddev   6        34.22 (  0.00%)       23.35 ( 31.75%)      124.40 (-263.57%)
> > Stddev   7       100.59 (  0.00%)      112.83 (-12.17%)       65.07 ( 35.31%)
> > Stddev   8        20.26 (  0.00%)       43.43 (-114.32%)       48.26 (-138.16%)
> > Stddev   12       19.43 (  0.00%)       19.73 ( -1.55%)       23.25 (-19.65%)
> > Stddev   16       14.47 (  0.00%)       26.42 (-82.54%)       17.71 (-22.40%)
> > Stddev   20       21.37 (  0.00%)       15.97 ( 25.27%)       14.87 ( 30.42%)
> > Stddev   24       12.87 (  0.00%)       28.12 (-118.44%)       10.46 ( 18.75%)
> > Stddev   28       13.89 (  0.00%)       17.97 (-29.36%)       12.22 ( 12.04%)
> > Stddev   32       18.14 (  0.00%)       20.37 (-12.31%)       16.40 (  9.58%)
> > 
> >           3.13.0-rc3      3.4.69  3.13.0-rc3
> >              vanilla     vanilla newdefault-v1
> > User          900.27      995.20      947.33
> > System       1583.41     1680.76     1533.17
> > Elapsed      2100.78     2100.81     2100.76
> > 
> > This shows the ebizzy comparison between 3.13-rc3, 3.4.69-stable and this series.
> > The series is not a universal win against 3.4 but the figure are generally better
> > and system CPU usage is reduced.
> 
> I think you found a real bug and I definitely agree that we want to 
> fix it - the TLB range optimization was supposed to be a (nearly) 
> unconditional win, so a regression like this is totally not acceptable 
> IMHO.
> 

Ok.

> Please help me out with interpreting the numbers. The Ebizzy table:
> 
> > ebizzy
> >                        3.13.0-rc3                3.4.69            3.13.0-rc3
> >                           vanilla               vanilla           newdefault-v1
> > Mean     1      7353.60 (  0.00%)     6782.00 ( -7.77%)     7836.20 (  6.56%)
> > Mean     2      8120.40 (  0.00%)     8278.80 (  1.95%)     9520.60 ( 17.24%)
> > Mean     3      8087.80 (  0.00%)     8083.60 ( -0.05%)     9003.80 ( 11.33%)
> 
> is the first numeric column number of threads/clients?

The number of threads.

> The other 
> colums are showing pairs of throughput (higher is better), with a 
> performance regression percentage in parentheses.
> 

Average operations/second measured over the duration of the entire test.
The output of the program is essentially records/duration.

> do the stddev numbers:
> 
> > Stddev   1        42.71 (  0.00%)       53.16 (-24.46%)       39.80 (  6.82%)
> > Stddev   2       250.26 (  0.00%)      150.57 ( 39.84%)       31.94 ( 87.24%)
> 
> ... correspond to the respective thread count and thus overlay the 
> first table, right?
> 

Each iteration of the test ran for a fixed duration of 30 seconds. There were
5 iterations per thread which I know is very low, this was an RFC. The stddev
is the standard deviation of the records/sec recorded for the 5 iterations.

> stddev appears to be rather large especially around a client count of 
> 7-8. It will be difficult to fine-tune the TLB range flush constants 
> if noise is too large.
> 

The number of iterations were very low to have high confidence of the
figures. The high standard deviation for 5 clients was a single large
outlier. It potentially could be stabilised to some extent by bumping up
the number of iterations a lot and using percentiles instead of means.

I'm a bit wary of optimising the TLB flush ranges based on the benchmark
even if we stabilised the figures. There are major weaknesses that limit
its usefulness for tuning this the shift value. The range of pages being
flushed are fixed so whether the CPU sees a benefit depends on the cost of
a single page flush, a global flush and the number of TLB entries relative
to the fixed size used by ebizzy. Similarly, the full cost/benefit of using
single page flushes vs global flush partially depends on whether the TLB
contains hot entries for the task being flushed that will be used in the
near future. ebizzy's allocations are short lived and, while I have not
analysed it, I suspect it benefits little from preserving its TLB entries.

I'm not entirely convinced that the balance points are a good idea at
all. There are a lot of assumptions and some complete unknowns. For example,
if this task is completely cold is a mm flush far cheaper than flushing
non-existent entries page by page? Unfortunately I do not know what the
original thinking was and why something like a calibration loop was not
used (other than the sheer difficulty of measuring it). i.e. Estimate the
cost of an mm flush, estimate the cost of a single page flush and then

if (cost(mm_flush) < nr_to_flush * cost(page_flush))
	flush_mm
else
	flush_page_range

Hopefully someone does remember.

> Regarding total CPU usage:
> 
> >           3.13.0-rc3      3.4.69  3.13.0-rc3
> >              vanilla     vanilla newdefault-v1
> > User          900.27      995.20      947.33
> > System       1583.41     1680.76     1533.17
> > Elapsed      2100.78     2100.81     2100.76
> 
> ... elapsed time appears to be the same - does the benchmark run for a 
> constant amount of time, regardless of performance?
> 

Constant.

> This means that higher user time and lower system time generally 
> represents higher achieved throughput, right?
> 

Good point, these values cannot be meaningfully interpreted because of
the fixed duration of the test. I should not even have looked.

> Yet the sum does not appear to be constant across kernels - does this 
> mean that even newdefault-v1 is idling around more than v3.4.69?

There are a number of factors that could affect this. Light monitoring was
active so there is some IO logging that. The workload is very context switch
so changes to the scheduler will distort results. The load is interrupt
heavy which will not be properly captured. The cost of the benchmark is
heavily dominated by zeroing newly allocated pages so changes in cache
coloring would show up in different ways.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
