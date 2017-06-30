Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C37F46B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 22:26:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g27so103435944pfj.6
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 19:26:28 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f8si5268411pli.377.2017.06.29.19.26.27
        for <linux-mm@kvack.org>;
        Thu, 29 Jun 2017 19:26:27 -0700 (PDT)
Date: Fri, 30 Jun 2017 11:26:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v2 0/6] mm, swap: VMA based swap readahead
Message-ID: <20170630022626.GA25190@bbox>
References: <20170630014443.23983-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630014443.23983-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Huang,

Ccing Johannes:

I don't read this patch yet but I remember Johannes tried VMA-based
readahead approach long time ago so he might have good comment.

On Fri, Jun 30, 2017 at 09:44:37AM +0800, Huang, Ying wrote:
> The swap readahead is an important mechanism to reduce the swap in
> latency.  Although pure sequential memory access pattern isn't very
> popular for anonymous memory, the space locality is still considered
> valid.
> 
> In the original swap readahead implementation, the consecutive blocks
> in swap device are readahead based on the global space locality
> estimation.  But the consecutive blocks in swap device just reflect
> the order of page reclaiming, don't necessarily reflect the access
> pattern in virtual memory space.  And the different tasks in the
> system may have different access patterns, which makes the global
> space locality estimation incorrect.
> 
> In this patchset, when page fault occurs, the virtual pages near the
> fault address will be readahead instead of the swap slots near the
> fault swap slot in swap device.  This avoid to readahead the unrelated
> swap slots.  At the same time, the swap readahead is changed to work
> on per-VMA from globally.  So that the different access patterns of
> the different VMAs could be distinguished, and the different readahead
> policy could be applied accordingly.  The original core readahead
> detection and scaling algorithm is reused, because it is an effect
> algorithm to detect the space locality.
> 
> In addition to the swap readahead changes, some new sysfs interface is
> added to show the efficiency of the readahead algorithm and some other
> swap statistics.
> 
> This new implementation will incur more small random read, on SSD, the
> improved correctness of estimation and readahead target should beat
> the potential increased overhead, this is also illustrated in the test
> results below.  But on HDD, the overhead may beat the benefit, so the
> original implementation will be used by default.
> 
> The test and result is as follow,
> 
> Common test condition
> =====================
> 
> Test Machine: Xeon E5 v3 (2 sockets, 72 threads, 32G RAM)
> Swap device: NVMe disk
> 
> Micro-benchmark with combined access pattern
> ============================================
> 
> vm-scalability, sequential swap test case, 4 processes to eat 50G
> virtual memory space, repeat the sequential memory writing until 300
> seconds.  The first round writing will trigger swap out, the following
> rounds will trigger sequential swap in and out.
> 
> At the same time, run vm-scalability random swap test case in
> background, 8 processes to eat 30G virtual memory space, repeat the
> random memory write until 300 seconds.  This will trigger random
> swap-in in the background.
> 
> This is a combined workload with sequential and random memory
> accessing at the same time.  The result (for sequential workload) is
> as follow,
> 
> 			Base		Optimized
> 			----		---------
> throughput		345413 KB/s	414029 KB/s (+19.9%)
> latency.average		97.14 us	61.06 us (-37.1%)
> latency.50th		2 us		1 us
> latency.60th		2 us		1 us
> latency.70th		98 us		2 us
> latency.80th		160 us		2 us
> latency.90th		260 us		217 us
> latency.95th		346 us		369 us
> latency.99th		1.34 ms		1.09 ms
> ra_hit%			52.69%		99.98%
> 
> The original swap readahead algorithm is confused by the background
> random access workload, so readahead hit rate is lower.  The VMA-base
> readahead algorithm works much better.
> 
> Linpack
> =======
> 
> The test memory size is bigger than RAM to trigger swapping.
> 
> 			Base		Optimized
> 			----		---------
> elapsed_time		393.49 s	329.88 s (-16.2%)
> ra_hit%			86.21%		98.82%
> 
> The score of base and optimized kernel hasn't visible changes.  But
> the elapsed time reduced and readahead hit rate improved, so the
> optimized kernel runs better for startup and tear down stages.  And
> the absolute value of readahead hit rate is high, shows that the space
> locality is still valid in some practical workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
