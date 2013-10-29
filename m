Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 74BA86B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 12:14:08 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so66074pde.3
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 09:14:08 -0700 (PDT)
Received: from psmtp.com ([74.125.245.124])
        by mx.google.com with SMTP id dk5si15305414pbc.166.2013.10.29.09.14.06
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 09:14:07 -0700 (PDT)
Message-ID: <526FDECB.7020201@codeaurora.org>
Date: Tue, 29 Oct 2013 09:14:03 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu
 hot page
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>	<20131029093322.GA2400@suse.de>	<CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>	<20131029122708.GD2400@suse.de> <CAGT3LerfYfgdkDd=LnuA8y7SUjOSTbw-HddbuzQ=O3yw-vtnnQ@mail.gmail.com>
In-Reply-To: <CAGT3LerfYfgdkDd=LnuA8y7SUjOSTbw-HddbuzQ=O3yw-vtnnQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Mingjun <zhang.mingjun@linaro.org>, Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

On 10/29/2013 8:02 AM, Zhang Mingjun wrote:

>     It would move the cost to the CMA paths so I would complain less. Bear
>     in mind as well that forcing everything to go through free_one_page()
>     means that every free goes through the zone lock. I doubt you have any
>     machine large enough but it is possible for simultaneous CMA allocations
>     to now contend on the zone lock that would have been previously fine.
>     Hence, I'm interesting in knowing the underlying cause of the
>     problem you
>     are experiencing.
>
> my platform uses CMA but disabled CMA's migration func by del MIGRATE_CMA
> in fallbacks[MIGRATE_MOVEABLE]. But I find CMA pages can still used by
> pagecache or page fault page request from PCP list and cma allocation has to
> migrate these page. So I want to free these cma pages to buddy directly
> not PCP..
>
>      > of course, it will waste the memory outside of the alloc range
>     but in the
>      > pageblocks.
>      >
>
>     I would hope/expect that the loss would only last for the duration of
>     the allocation attempt and a small amount of memory.
>
>      > > when a range of pages have been isolated and migrated. Is there any
>      > > measurable benefit to this patch?
>      > >
>      > after applying this patch, the video player on my platform works more
>      > fluent,
>
>     fluent almost always refers to ones command of a spoken language. I do
>     not see how a video player can be fluent in anything. What is measurably
>     better?
>
>     For example, are allocations faster? If so, why? What cost from another
>     path is removed as a result of this patch? If the cost is in the PCP
>     flush then can it be checked if the PCP flush was unnecessary and called
>     unconditionally even though all the pages were freed already? We had
>     problems in the past where drain_all_pages() or similar were called
>     unnecessarily causing long sync stalls related to IPIs. I'm wondering if
>     we are seeing a similar problem here.
>
>     Maybe the problem is the complete opposite. Are allocations failing
>     because there are PCP pages in the way? In that case, it real fix might
>     be to insert a  if the allocation is failing due to per-cpu
>     pages.
>
> problem is not the allocation failing, but the unexpected cma migration
> slows
> down the allocation.
>
>
>      > and the driver of video decoder on my test platform using cma
>     alloc/free
>      > frequently.
>      >
>
>     CMA allocations are almost never used outside of these contexts. While I
>     appreciate that embedded use is important I'm reluctant to see an impact
>     in fast paths unless there is a good reason for every other use case. I
>     also am a bit unhappy to see CMA allocations making the zone->lock
>     hotter than necessary even if no embedded use case it likely to
>     experience the problem in the short-term.
>
>     --
>     Mel Gorman
>     SUSE Labs
>
>

We've had a similar patch in our tree for a year and a half because of 
CMA migration failures, not just for a speedup in allocation time. I 
understand that CMA is not the fast case or the general use case but the 
problem is that the cost of CMA failure is very high (complete failure 
of the feature using CMA). Putting CMA on the PCP lists means they may 
be picked up by users who temporarily make the movable pages unmovable 
(page cache etc.) which prevents the allocation from succeeding. The 
problem still exists even if the CMA pages are not on the PCP list but 
the window gets slightly smaller.

This really highlights one of the biggest issues with CMA today. Movable 
pages make return -EBUSY for any number of reasons. For non-CMA pages 
this is mostly fine, another movable page may be substituted for the 
movable page that is busy. CMA is a restricted range though so any 
failure in that range is very costly because CMA regions are generally 
sized exactly for the use cases at hand which means there is very little 
extra space for retries.

To make CMA actually usable, we've had to go through and add in 
hacks/quirks that prevent CMA from being allocated in any path which may 
prevent migration. I've been mixed on if this is the right path or if 
the definition of MIGRATE_CMA needs to be changed to be more restrictive 
(can't prevent migration).

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
