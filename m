Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 14A0A6B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 01:46:21 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so2232017pac.36
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 22:46:20 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id bz3si5394686pbb.64.2014.11.25.22.46.18
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 22:46:19 -0800 (PST)
Date: Wed, 26 Nov 2014 15:46:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [LSF/MM TOPIC] Improving CMA
Message-ID: <20141126064620.GA10412@bbox>
References: <5473E146.7000503@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5473E146.7000503@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, zhuhui@xiaomi.com, iamjoonsoo.kim@lge.com, gioh.kim@lge.com, SeongJae Park <sj38.park@gmail.com>

Hello Laura,

On Mon, Nov 24, 2014 at 05:54:14PM -0800, Laura Abbott wrote:
> There have been a number of patch series posted designed to improve various
> aspects of CMA. A sampling:
> 
> https://lkml.org/lkml/2014/10/15/623
> http://marc.info/?l=linux-mm&m=141571797202006&w=2
> https://lkml.org/lkml/2014/6/26/549
> 
> As far as I can tell, these are all trying to fix real problems with CMA but
> none of them have moved forward very much from what I can tell. The goal of
> this session would be to come out with an agreement on what are the biggest
> problems with CMA and the best ways to solve them.

Thanks for the proposal.
Yes, CMA has broken for a long time.

1. Memory allocation for CMA area -> Broken
2. Memory reclaim for CMA area -> Broken
3. CMA allocation latency -> Broken
4. CMA allocation success guarantee -> Broken.

I believe there is no real product to use vanilla CMA in mainline
without any hack.

Recently, there are some efforts to fix 1 but patchset I have seen hurt
allocator's hot path which is really not what I want. Instead, I suggested
to use movalbe zone. It would help 1 and 2 problem and make mm code simple
so I think it's worth to try before making mm code more bloat with CMA hooks.
https://lkml.org/lkml/2014/11/4/55

However, we don't have a nice idea to solve 3 and 4 still.
There were some trying to migrate CMA page out when someone try to pin
CMA page via GUP but it's not a perfect solution. We should take care of
indirect object dependency(ex, obj A gets obj B, obj B gets obj C)
so page located in obj C will not release until obj B release and
obj B doesn't relase until obj A released). It means we should
take care of get_page as well as GUP. It's terrible.

Recently, I and SeongJae posted GCMA(Guaranteed CMA) which is a idea
to solve above all problems. https://lkml.org/lkml/2014/10/15/623
But it apparently has tradeoff. So, our goal is to recommend GCMA
if you want to make sure fast allocation success. Or, use CMA
if you have fallback scheme of failure of allocation, if you
are okay to allocation latency(a few seconds) sometime, if you
should use really big contiguous memory.

Anyway, I have an interest on this topic and want to attend.

Thanks.

> 
> Thanks,
> Laura
> 
> -- 
> Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> a Linux Foundation Collaborative Project
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
