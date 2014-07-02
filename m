Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2BABE6B0038
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:16:27 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so1735868ier.12
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:16:27 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0241.hostedemail.com. [216.40.44.241])
        by mx.google.com with ESMTP id z7si22024558ign.25.2014.07.02.11.16.25
        for <linux-mm@kvack.org>;
        Wed, 02 Jul 2014 11:16:26 -0700 (PDT)
Message-ID: <53B44C9A.9070808@nellans.org>
Date: Wed, 02 Jul 2014 13:16:58 -0500
From: David Nellans <david@nellans.org>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] x86: mm: set TLB flush tunable to sane value (33)
References: <20140701164845.8D1A5702@viggo.jf.intel.com> <20140701164856.3020D644@viggo.jf.intel.com>
In-Reply-To: <20140701164856.3020D644@viggo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "x86@kernel.org" <x86@kernel.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>


On 07/01/2014 11:48 AM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> This has been run through Intel's LKP tests across a wide range
> of modern sytems and workloads and it wasn't shown to make a
> measurable performance difference positive or negative.
>
> Now that we have some shiny new tracepoints, we can actually
> figure out what the heck is going on.
>
> During a kernel compile, 60% of the flush_tlb_mm_range() calls
> are for a single page.  It breaks down like this:
>
>   size   percent  percent<=
>    V        V        V
> GLOBAL:   2.20%   2.20% avg cycles:  2283
>       1:  56.92%  59.12% avg cycles:  1276
>       2:  13.78%  72.90% avg cycles:  1505
>       3:   8.26%  81.16% avg cycles:  1880
>       4:   7.41%  88.58% avg cycles:  2447
>       5:   1.73%  90.31% avg cycles:  2358
>       6:   1.32%  91.63% avg cycles:  2563
>       7:   1.14%  92.77% avg cycles:  2862
>       8:   0.62%  93.39% avg cycles:  3542
>       9:   0.08%  93.47% avg cycles:  3289
>      10:   0.43%  93.90% avg cycles:  3570
>      11:   0.20%  94.10% avg cycles:  3767
>      12:   0.08%  94.18% avg cycles:  3996
>      13:   0.03%  94.20% avg cycles:  4077
>      14:   0.02%  94.23% avg cycles:  4836
>      15:   0.04%  94.26% avg cycles:  5699
>      16:   0.06%  94.32% avg cycles:  5041
>      17:   0.57%  94.89% avg cycles:  5473
>      18:   0.02%  94.91% avg cycles:  5396
>      19:   0.03%  94.95% avg cycles:  5296
>      20:   0.02%  94.96% avg cycles:  6749
>      21:   0.18%  95.14% avg cycles:  6225
>      22:   0.01%  95.15% avg cycles:  6393
>      23:   0.01%  95.16% avg cycles:  6861
>      24:   0.12%  95.28% avg cycles:  6912
>      25:   0.05%  95.32% avg cycles:  7190
>      26:   0.01%  95.33% avg cycles:  7793
>      27:   0.01%  95.34% avg cycles:  7833
>      28:   0.01%  95.35% avg cycles:  8253
>      29:   0.08%  95.42% avg cycles:  8024
>      30:   0.03%  95.45% avg cycles:  9670
>      31:   0.01%  95.46% avg cycles:  8949
>      32:   0.01%  95.46% avg cycles:  9350
>      33:   3.11%  98.57% avg cycles:  8534
>      34:   0.02%  98.60% avg cycles: 10977
>      35:   0.02%  98.62% avg cycles: 11400
>
> We get in to dimishing returns pretty quickly.  On pre-IvyBridge
> CPUs, we used to set the limit at 8 pages, and it was set at 128
> on IvyBrige.  That 128 number looks pretty silly considering that
> less than 0.5% of the flushes are that large.
>
> The previous code tried to size this number based on the size of
> the TLB.  Good idea, but it's error-prone, needs maintenance
> (which it didn't get up to now), and probably would not matter in
> practice much.
>
> Settting it to 33 means that we cover the mallopt
> M_TRIM_THRESHOLD, which is the most universally common size to do
> flushes.
>
> That's the short version.  Here's the long one for why I chose 33:
>
> 1. These numbers have a constant bias in the timestamps from the
>     tracing.  Probably counts for a couple hundred cycles in each of
>     these tests, but it should be fairly _even_ across all of them.
>     The smallest delta between the tracepoints I have ever seen is
>     335 cycles.  This is one reason the cycles/page cost goes down in
>     general as the flushes get larger.  The true cost is nearer to
>     100 cycles.
> 2. A full flush is more expensive than a single invlpg, but not
>     by much (single percentages).
> 3. A dtlb miss is 17.1ns (~45 cycles) and a itlb miss is 13.0ns
>     (~34 cycles).  At those rates, refilling the 512-entry dTLB takes
>     22,000 cycles.
> 4. 22,000 cycles is approximately the equivalent of doing 85
>     invlpg operations.  But, the odds are that the TLB can
>     actually be filled up faster than that because TLB misses that
>     are close in time also tend to leverage the same caches.
> 6. ~98% of flushes are <=33 pages.  There are a lot of flushes of
>     33 pages, probably because libc's M_TRIM_THRESHOLD is set to
>     128k (32 pages)
> 7. I've found no consistent data to support changing the IvyBridge
>     vs. SandyBridge tunable by a factor of 16
>
> I used the performance counters on this hardware (IvyBridge i5-3320M)
> to figure out the tlb miss costs:
>
> ocperf.py stat -e dtlb_load_misses.walk_duration,dtlb_load_misses.walk_completed,dtlb_store_misses.walk_duration,dtlb_store_misses.walk_completed,itlb_misses.walk_duration,itlb_misses.walk_completed,itlb.itlb_flush
>
>       7,720,030,970      dtlb_load_misses_walk_duration                                    [57.13%]
>         169,856,353      dtlb_load_misses_walk_completed                                    [57.15%]
>         708,832,859      dtlb_store_misses_walk_duration                                    [57.17%]
>          19,346,823      dtlb_store_misses_walk_completed                                    [57.17%]
>       2,779,687,402      itlb_misses_walk_duration                                    [57.15%]
>          82,241,148      itlb_misses_walk_completed                                    [57.13%]
>             770,717      itlb_itlb_flush                                              [57.11%]
>
> Show that a dtlb miss is 17.1ns (~45 cycles) and a itlb miss is 13.0ns
> (~34 cycles).  At those rates, refilling the 512-entry dTLB takes
> 22,000 cycles.  On a SandyBridge system with more cores and larger
> caches, those are dtlb=13.4ns and itlb=9.5ns.

Intuition here is that invalidate caused refills will almost always be serviced from the L2
or better since we've recently walked to modify the page needing flush and thus pre-warmed the caches
for any refill? Or is this an artifact of the flush/refill test setup? Main mem latency even on Ivybridge is ~100
clocks, worse in previous generations, so to get down to average ~30 cycle refill you basically can never be
missing in the L1 or maybe L2 which seems optimistic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
