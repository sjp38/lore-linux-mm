Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1A16B0035
	for <linux-mm@kvack.org>; Sun, 25 May 2014 22:41:26 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so6894146pad.13
        for <linux-mm@kvack.org>; Sun, 25 May 2014 19:41:26 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id dx7si11185299pab.190.2014.05.25.19.41.23
        for <linux-mm@kvack.org>;
        Sun, 25 May 2014 19:41:25 -0700 (PDT)
Date: Mon, 26 May 2014 11:44:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140526024417.GA26935@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <5370FF1D.10707@codeaurora.org>
 <537FEE96.8000704@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537FEE96.8000704@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lmark@codeaurora.org

On Fri, May 23, 2014 at 05:57:58PM -0700, Laura Abbott wrote:
> On 5/12/2014 10:04 AM, Laura Abbott wrote:
> > 
> > I'm going to see about running this through tests internally for comparison.
> > Hopefully I'll get useful results in a day or so.
> > 
> > Thanks,
> > Laura
> > 
> 
> We ran some tests internally and found that for our purposes these patches made
> the benchmarks worse vs. the existing implementation of using CMA first for some
> pages. These are mostly androidisms but androidisms that we care about for
> having a device be useful.
> 
> The foreground memory headroom on the device was on average about 40 MB smaller
>  when using these patches vs our existing implementation of something like
> solution #1. By foreground memory headroom we simply mean the amount of memory
> that the foreground application can allocate before it is killed by the Android
>  Low Memory killer.
> 
> We also found that when running a sequence of app launches these patches had
> more high priority app kills by the LMK and more alloc stalls. The test did a
> total of 500 hundred app launches (using 9 separate applications) The CMA
> memory in our system is rarely used by its client and is therefore available
> to the system most of the time.
> 
> Test device
> - 4 CPUs
> - Android 4.4.2
> - 512MB of RAM
> - 68 MB of CMA
> 
> 
> Results:
> 
> Existing solution:
> Foreground headroom: 200MB
> Number of higher priority LMK kills (oom_score_adj < 529): 332
> Number of alloc stalls: 607
> 
> 
> Test patches:
> Foreground headroom: 160MB
> Number of higher priority LMK kills (oom_score_adj < 529):
> 459 Number of alloc stalls: 29538
> 
> We believe that the issues seen with these patches are the result of the LMK
> being more aggressive. The LMK will be more aggressive because it will ignore
> free CMA pages for unmovable allocations, and since most calls to the LMK are
> made by kswapd (which uses GFP_KERNEL) the LMK will mostly ignore free CMA
> pages. Because the LMK thresholds are higher than the zone watermarks, there
> will often be a lot of free CMA pages in the system when the LMK is called,
> which the LMK will usually ignore.

Hello,

Really thanks for testing!!!
If possible, please let me know nr_free_cma of these patches/your in-house
implementation before testing.

I can guess following scenario about your test.

On boot-up, CMA memory are mostly used by native processes, because
your implementation use CMA first for some pages. kswapd
is woken up late since non-CMA free memory is larger than my
implementation. And, on reclaiming, the LMK reclaiming memory by
killing app process would reclaim movable memory with high probability
since cma memory are mostly used by native processes and app processes
have just movable memory.

This is just my guess. But, if it is true, this is not fair test for
this patchset. If possible, could you make nr_free_cma same on both
implementation before testing?

Moreover, in mainline implementation, the LMK doesn't consider if memory
type is CMA or not. Maybe your overall system would be highly optimized
for your implementation, so I'm not sure if your testing is
appropriate or not for this patchset.

Anyway, I would like to optimize this for android. :)
Please let me know more about your system.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
