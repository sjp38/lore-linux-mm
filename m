Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6AE6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:46:23 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so103178511pab.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:46:23 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id bz4si32254095pbd.70.2015.08.10.02.46.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 02:46:22 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSV02A2T1T7M1A0@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 10 Aug 2015 18:46:19 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
 <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
 <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
In-reply-to: <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
Subject: RE: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Date: Mon, 10 Aug 2015 15:15:06 +0530
Message-id: <012e01d0d351$5dc752a0$1955f7e0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

Hi,

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Saturday, August 08, 2015 4:06 AM
> To: PINTU KUMAR
> Cc: 'Michal Hocko'; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> minchan@kernel.org; dave@stgolabs.net; koct9i@gmail.com;
> mgorman@suse.de; vbabka@suse.cz; js1304@gmail.com;
> hannes@cmpxchg.org; alexander.h.duyck@redhat.com;
> sasha.levin@oracle.com; cl@linux.com; fengguang.wu@intel.com;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.k@outlook.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
> 
> On Fri, 07 Aug 2015 18:16:47 +0530 PINTU KUMAR <pintu.k@samsung.com>
> wrote:
> 
> > > > This is useful to know the rate of allocation success within the
> > > > slowpath.
> > >
> > > What would be that information good for? Is a regular administrator
> > > expected
> > to
> > > consume this value or this is aimed more to kernel developers? If
> > > the later
> > then I
> > > think a trace point sounds like a better interface.
> > >
> > This information is good for kernel developers.
> > I found this information useful while debugging low memory situation
> > and sluggishness behavior.
> > I wanted to know how many times the first allocation is failing and
> > how many times system entering slowpath.
> > As I said, the existing counter does not give this information clearly.
> > The pageoutrun, allocstall is too confusing.
> > Also, if kswapd and compaction is disabled, we have no other counter
> > for slowpath (except allocstall).
> > Another problem is that allocstall can also be incremented from
> > hibernation during shrink_all_memory calling.
> > Which may create more confusion.
> > Thus I found this interface useful to understand low memory behavior.
> > If device sluggishness is happening because of too many slowpath or
> > due to some other problem.
> > Then we can decide what will be the best memory configuration for my
> > device to reduce the slowpath.
> >
> > Regarding trace points, I am not sure if we can attach counter to it.
> > Also trace may have more over-head and requires additional configs to
> > be enabled to debug.
> > Mostly these configs will not be enabled by default (at least in
> > embedded, low memory device).
> > I found the vmstat interface more easy and useful.
> 
> This does seem like a pretty basic and sensible thing to expose in vmstat.  It
> probably makes more sense than some of the other things we have in there.
> 
Thanks Andrew.
Yes, as par my analysis, I feel that this is one of the useful and important
interface.
I added it in one of our internal product and found it to be very useful.
Specially during shrink_memory and compact_nodes analysis I found it really
useful.
It helps me to prove that if higher-order pages are present, it can reduce the
slowpath drastically.
Also during my ELC presentation people asked me how to monitor the slowpath
counts.

> Yes, it could be a tracepoint but practically speaking, a tracepoint makes it
> developer-only.  You can ask a bug reporter or a customer "what is
> /proc/vmstat:slowpath_entered" doing, but it's harder to ask them to set up
> tracing.
> 
Yes, at times tracing are painful to analyze.
Also, in commercial user binaries, most of tracing support are disabled (with no
root privileges).
However, /proc/vmstat works with normal user binaries.
When memory issues are reported, we just get log dumps and few interfaces like
this.
Most of the time these memory issues are hard to reproduce because it may happen
after long usage.

> And I don't think this will lock us into anything - vmstat is a big dumping
ground
> and I don't see a big problem with removing or changing things later on.  IMO,
> debugfs rules apply here and vmstat would be in debugfs, had debugfs existed
at
> the time.
> 
> 
> Two things:
> 
> - we appear to have forgotten to document /proc/vmstat
> 
Yes, I could not find any document on vmstat under kernel/Documentation.
I think it's a nice think to have.
May be, I can start this initiative to create one :)
If respective owner can update, it will be great.

> - How does one actually use slowpath_entered?  Obviously we'd like to
>   know "what proportion of allocations entered the slowpath", so we
>   calculate
> 
> 	slowpath_entered/X
> 
>   how do we obtain "X"?  Is it by adding up all the pgalloc_*?  If
>   so, perhaps we should really have slowpath_entered_dma,
>   slowpath_entered_dma32, ...?

I think the slowpath for other zones may not be required.
We just need to know how many times we entered slowpath and possibly do
something to reduce it.
But, I think, pgalloc_* count may also include success for fastpath.

How I use slowpath for analysis is:
VMSTAT		BEFORE	AFTER		%DIFF
----------		----------	----------	------------
nr_free_pages		6726		12494		46.17%
pgalloc_normal		985836		1549333	36.37%
pageoutrun		2699		529		80.40%
allocstall		298		98		67.11%
slowpath_entered	16659		739		95.56%
compact_stall		244		21		91.39%
compact_fail		178		11		93.82%
compact_success	52		7		86.54%

The above values are from 512MB system with only NORMAL zone.
Before, the slowpath count was 16659.
After (memory shrinker + compaction), the slowpath reduced by 95%, for the same
scenario.
This is just an example.

If we are interested to know even allocation success/fail ratio in slowpath,
then I think we need more counters.
Such as; direct_reclaim_success/fail, kswapd_success/fail (just like compaction
success/fail).
OR, we can have pgalloc_success_fastpath counter.
Then we can do:
pgalloc_success_in_slowpath = (pgalloc_normal - pgalloc_success_fastpath)
Therefore, success_ratio for slowpath could be;

(pgalloc_success_in_slowpath/slowpath_entered) * 100

More comments, welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
