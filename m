Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAFF6B0038
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 21:49:38 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id jt11so3621934pbb.15
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 18:49:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id ba2si2691629pbc.298.2013.10.31.18.49.36
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 18:49:37 -0700 (PDT)
Date: Fri, 1 Nov 2013 10:49:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot
 page
Message-ID: <20131101014948.GG26080@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
 <20131029093322.GA2400@suse.de>
 <CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
 <20131029122708.GD2400@suse.de>
 <CAGT3LerfYfgdkDd=LnuA8y7SUjOSTbw-HddbuzQ=O3yw-vtnnQ@mail.gmail.com>
 <526FDECB.7020201@codeaurora.org>
 <20131030054006.GF17013@bbox>
 <5271BD15.4050008@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5271BD15.4050008@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Zhang Mingjun <zhang.mingjun@linaro.org>, Mel Gorman <mgorman@suse.de>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

Hello,

On Wed, Oct 30, 2013 at 07:14:45PM -0700, Laura Abbott wrote:
> On 10/29/2013 10:40 PM, Minchan Kim wrote:
> >>
> >>We've had a similar patch in our tree for a year and a half because
> >>of CMA migration failures, not just for a speedup in allocation
> >>time. I understand that CMA is not the fast case or the general use
> >>case but the problem is that the cost of CMA failure is very high
> >>(complete failure of the feature using CMA). Putting CMA on the PCP
> >>lists means they may be picked up by users who temporarily make the
> >>movable pages unmovable (page cache etc.) which prevents the
> >>allocation from succeeding. The problem still exists even if the CMA
> >>pages are not on the PCP list but the window gets slightly smaller.
> >
> >I understand that I have seen many people want to use CMA have tweaked
> >their system to work well and although they do best effort, it doesn't
> >work well because CMA doesn't gaurantee to succeed in getting free
> >space since there are lots of hurdle. (get_user_pages, AIO ring buffer,
> >buffer cache, short of free memory for migration, no swap and so on).
> >Even, someone want to allocate CMA space with speedy. SIGH.
> >
> >Yeah, at the moment, CMA is really SUCK.
> >
> 
> Yes, without hacks there are enough issues where it makes more sense
> to turn off CMA in some cases.
> 
> >>
> >>This really highlights one of the biggest issues with CMA today.
> >>Movable pages make return -EBUSY for any number of reasons. For
> >>non-CMA pages this is mostly fine, another movable page may be
> >>substituted for the movable page that is busy. CMA is a restricted
> >>range though so any failure in that range is very costly because CMA
> >>regions are generally sized exactly for the use cases at hand which
> >>means there is very little extra space for retries.
> >>
> >>To make CMA actually usable, we've had to go through and add in
> >>hacks/quirks that prevent CMA from being allocated in any path which
> >>may prevent migration. I've been mixed on if this is the right path
> >>or if the definition of MIGRATE_CMA needs to be changed to be more
> >>restrictive (can't prevent migration).
> >
> >Fundamental problem is that every subsystem could grab a page anytime
> >and they doesn't gaurantee to release it soonish or within time CMA
> >user want so it turns out non-determisitic mess which just hook into
> >core MM system here and there.
> >
> >Sometime, I see some people try to solve it case by case with ad-hoc
> >approach. I guess it would be never ending story as kernel evolves.
> >
> >I suggest that we could make new wheel with frontswap/cleancache stuff.
> >The idea is that pages in frontswap/cleancache are evicted from kernel
> >POV so that we can gaurantee that there is no chance to grab a page
> >in CMA area and we could remove lots of hook from core MM which just
> >complicated MM without benefit.
> >
> >As benefit, cleancache pages could drop easily so it would be fast
> >to get free space but frontswap cache pages should be move into somewhere.
> >If there are enough free pages, it could be migrated out there. Optionally
> >we could compress them. Otherwise, we could pageout them into backed device.
> >Yeah, it could be slow than migration but at least, we could estimate the time
> >by storage speed ideally so we could have tunable knob. If someone want
> >fast CMA, he could control it with ratio of cleancache:frontswap.
> >IOW, higher frontswap page ratio is, slower the speed would be.
> >Important thing is admin could have tuned control knob and it gaurantees to
> >get CMA free space with deterministic time.
> >
> 
> Before CMA was available, we attempted to do something similar with
> carved out memory where we hooked up the carveout to tmem and
> cleancache. The feature never really went anywhere because we saw
> impacts on file system benchmarks (too much time copying data to
> carveout memory). The feature has long been deprecated and we never
> debugged too far. Admittedly, this was many kernel versions ago and
> with a backport of various patches to an older kernel so I'd take
> our results with a grain of salt.

Did you use only cleancache?
If so, I guess the problem is from cleancache which could store used-once
pages easily due to lack of function to identify such pages so that copy
from frontend to backend would be totally overhead.
AFAIR, there was some patch to remove such overhead from Dan who is author.
He wanted to detect it by seeing evicted page was LRU active list of VM.
https://lkml.org/lkml/2012/1/25/300
Maybe, we could enhance that part.

> 
> >As drawback, if we fail to tune the ratio, memeory efficieny would be
> >bad so that it ends up thrashing but you guys is saying we have been
> >used CMA without movable fallback which means that it's already static
> >reserved memory and it's never CMA so you already have lost memory
> >efficiency and even fail to get a space so I think it's good trade-off
> >for embedded people.
> >
> 
> Agreed. It really should be a policy decision how much effort to put
> into getting CMA pages. There isn't a nice way to do this now.
> 
> >If anyone has interest the idea, I will move into that.
> >If it sounds crazy idea, feel free to ignore, please.
> >
> 
> I'm interested in the idea with the warning noted above.

Okay, I will start the work if other going works are done.
I will send a patch with Ccing you if the prototype is done.
Of course, you could kick off firstly. :)

Thanks for the interest!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
