Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 52BB66B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 07:38:31 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so5257809pad.31
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 04:38:31 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id ey5si8565431pab.16.2013.12.23.04.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 04:38:29 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 23 Dec 2013 18:08:26 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 13904E005A
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 18:10:54 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBNCcKNw55443544
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 18:08:21 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBNCcLW5019350
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 18:08:21 +0530
Date: Mon, 23 Dec 2013 20:38:18 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <52b82ec5.8564420a.24c7.fffff13cSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
 <20131029093322.GA2400@suse.de>
 <CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
 <20131029122708.GD2400@suse.de>
 <CAGT3LerfYfgdkDd=LnuA8y7SUjOSTbw-HddbuzQ=O3yw-vtnnQ@mail.gmail.com>
 <526FDECB.7020201@codeaurora.org>
 <20131030054006.GF17013@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131030054006.GF17013@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Zhang Mingjun <zhang.mingjun@linaro.org>, Mel Gorman <mgorman@suse.de>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

On Wed, Oct 30, 2013 at 02:40:06PM +0900, Minchan Kim wrote:
>Hello,
>
>On Tue, Oct 29, 2013 at 09:14:03AM -0700, Laura Abbott wrote:
>> On 10/29/2013 8:02 AM, Zhang Mingjun wrote:
>> 
>> >    It would move the cost to the CMA paths so I would complain less. Bear
>> >    in mind as well that forcing everything to go through free_one_page()
>> >    means that every free goes through the zone lock. I doubt you have any
>> >    machine large enough but it is possible for simultaneous CMA allocations
>> >    to now contend on the zone lock that would have been previously fine.
>> >    Hence, I'm interesting in knowing the underlying cause of the
>> >    problem you
>> >    are experiencing.
>> >
>> >my platform uses CMA but disabled CMA's migration func by del MIGRATE_CMA
>> >in fallbacks[MIGRATE_MOVEABLE]. But I find CMA pages can still used by
>> >pagecache or page fault page request from PCP list and cma allocation has to
>> >migrate these page. So I want to free these cma pages to buddy directly
>> >not PCP..
>> >
>> >     > of course, it will waste the memory outside of the alloc range
>> >    but in the
>> >     > pageblocks.
>> >     >
>> >
>> >    I would hope/expect that the loss would only last for the duration of
>> >    the allocation attempt and a small amount of memory.
>> >
>> >     > > when a range of pages have been isolated and migrated. Is there any
>> >     > > measurable benefit to this patch?
>> >     > >
>> >     > after applying this patch, the video player on my platform works more
>> >     > fluent,
>> >
>> >    fluent almost always refers to ones command of a spoken language. I do
>> >    not see how a video player can be fluent in anything. What is measurably
>> >    better?
>> >
>> >    For example, are allocations faster? If so, why? What cost from another
>> >    path is removed as a result of this patch? If the cost is in the PCP
>> >    flush then can it be checked if the PCP flush was unnecessary and called
>> >    unconditionally even though all the pages were freed already? We had
>> >    problems in the past where drain_all_pages() or similar were called
>> >    unnecessarily causing long sync stalls related to IPIs. I'm wondering if
>> >    we are seeing a similar problem here.
>> >
>> >    Maybe the problem is the complete opposite. Are allocations failing
>> >    because there are PCP pages in the way? In that case, it real fix might
>> >    be to insert a  if the allocation is failing due to per-cpu
>> >    pages.
>> >
>> >problem is not the allocation failing, but the unexpected cma migration
>> >slows
>> >down the allocation.
>> >
>> >
>> >     > and the driver of video decoder on my test platform using cma
>> >    alloc/free
>> >     > frequently.
>> >     >
>> >
>> >    CMA allocations are almost never used outside of these contexts. While I
>> >    appreciate that embedded use is important I'm reluctant to see an impact
>> >    in fast paths unless there is a good reason for every other use case. I
>> >    also am a bit unhappy to see CMA allocations making the zone->lock
>> >    hotter than necessary even if no embedded use case it likely to
>> >    experience the problem in the short-term.
>> >
>> >    --
>> >    Mel Gorman
>> >    SUSE Labs
>> >
>> >
>> 
>> We've had a similar patch in our tree for a year and a half because
>> of CMA migration failures, not just for a speedup in allocation
>> time. I understand that CMA is not the fast case or the general use
>> case but the problem is that the cost of CMA failure is very high
>> (complete failure of the feature using CMA). Putting CMA on the PCP
>> lists means they may be picked up by users who temporarily make the
>> movable pages unmovable (page cache etc.) which prevents the
>> allocation from succeeding. The problem still exists even if the CMA
>> pages are not on the PCP list but the window gets slightly smaller.
>
>I understand that I have seen many people want to use CMA have tweaked
>their system to work well and although they do best effort, it doesn't
>work well because CMA doesn't gaurantee to succeed in getting free
>space since there are lots of hurdle. (get_user_pages, AIO ring buffer,
>buffer cache, short of free memory for migration, no swap and so on).
>Even, someone want to allocate CMA space with speedy. SIGH.
>
>Yeah, at the moment, CMA is really SUCK.
>
>> 
>> This really highlights one of the biggest issues with CMA today.
>> Movable pages make return -EBUSY for any number of reasons. For
>> non-CMA pages this is mostly fine, another movable page may be
>> substituted for the movable page that is busy. CMA is a restricted
>> range though so any failure in that range is very costly because CMA
>> regions are generally sized exactly for the use cases at hand which
>> means there is very little extra space for retries.
>> 
>> To make CMA actually usable, we've had to go through and add in
>> hacks/quirks that prevent CMA from being allocated in any path which
>> may prevent migration. I've been mixed on if this is the right path
>> or if the definition of MIGRATE_CMA needs to be changed to be more
>> restrictive (can't prevent migration).
>
>Fundamental problem is that every subsystem could grab a page anytime
>and they doesn't gaurantee to release it soonish or within time CMA
>user want so it turns out non-determisitic mess which just hook into
>core MM system here and there.
>
>Sometime, I see some people try to solve it case by case with ad-hoc
>approach. I guess it would be never ending story as kernel evolves.
>
>I suggest that we could make new wheel with frontswap/cleancache stuff.
>The idea is that pages in frontswap/cleancache are evicted from kernel
>POV so that we can gaurantee that there is no chance to grab a page
>in CMA area and we could remove lots of hook from core MM which just
>complicated MM without benefit.
>
>As benefit, cleancache pages could drop easily so it would be fast
>to get free space but frontswap cache pages should be move into somewhere.
>If there are enough free pages, it could be migrated out there. Optionally
>we could compress them. Otherwise, we could pageout them into backed device.
>Yeah, it could be slow than migration but at least, we could estimate the time
>by storage speed ideally so we could have tunable knob. If someone want
>fast CMA, he could control it with ratio of cleancache:frontswap.
>IOW, higher frontswap page ratio is, slower the speed would be.
>Important thing is admin could have tuned control knob and it gaurantees to
>get CMA free space with deterministic time.
>
>As drawback, if we fail to tune the ratio, memeory efficieny would be
>bad so that it ends up thrashing but you guys is saying we have been
>used CMA without movable fallback which means that it's already static
>reserved memory and it's never CMA so you already have lost memory
>efficiency and even fail to get a space so I think it's good trade-off
>for embedded people.
>
>If anyone has interest the idea, I will move into that.
>If it sounds crazy idea, feel free to ignore, please.
>

Interesting. ;-)

Regards,
Wanpeng Li 

>Thanks.
>
>> 
>> Thanks,
>> Laura
>> -- 
>> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
>> hosted by The Linux Foundation
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Kind regards,
>Minchan Kim
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
