Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id CA53A6B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 20:58:00 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so4900144pbb.11
        for <linux-mm@kvack.org>; Fri, 23 May 2014 17:58:00 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id zv2si5984775pbb.131.2014.05.23.17.57.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 May 2014 17:57:59 -0700 (PDT)
Message-ID: <537FEE96.8000704@codeaurora.org>
Date: Fri, 23 May 2014 17:57:58 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma reserved
 memory when not used
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <5370FF1D.10707@codeaurora.org>
In-Reply-To: <5370FF1D.10707@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lmark@codeaurora.org

On 5/12/2014 10:04 AM, Laura Abbott wrote:
> 
> I'm going to see about running this through tests internally for comparison.
> Hopefully I'll get useful results in a day or so.
> 
> Thanks,
> Laura
> 

We ran some tests internally and found that for our purposes these patches made
the benchmarks worse vs. the existing implementation of using CMA first for some
pages. These are mostly androidisms but androidisms that we care about for
having a device be useful.

The foreground memory headroom on the device was on average about 40 MB smaller
 when using these patches vs our existing implementation of something like
solution #1. By foreground memory headroom we simply mean the amount of memory
that the foreground application can allocate before it is killed by the Android
 Low Memory killer.

We also found that when running a sequence of app launches these patches had
more high priority app kills by the LMK and more alloc stalls. The test did a
total of 500 hundred app launches (using 9 separate applications) The CMA
memory in our system is rarely used by its client and is therefore available
to the system most of the time.

Test device
- 4 CPUs
- Android 4.4.2
- 512MB of RAM
- 68 MB of CMA


Results:

Existing solution:
Foreground headroom: 200MB
Number of higher priority LMK kills (oom_score_adj < 529): 332
Number of alloc stalls: 607


Test patches:
Foreground headroom: 160MB
Number of higher priority LMK kills (oom_score_adj < 529):
459 Number of alloc stalls: 29538

We believe that the issues seen with these patches are the result of the LMK
being more aggressive. The LMK will be more aggressive because it will ignore
free CMA pages for unmovable allocations, and since most calls to the LMK are
made by kswapd (which uses GFP_KERNEL) the LMK will mostly ignore free CMA
pages. Because the LMK thresholds are higher than the zone watermarks, there
will often be a lot of free CMA pages in the system when the LMK is called,
which the LMK will usually ignore.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
