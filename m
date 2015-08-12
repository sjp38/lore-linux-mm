Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 58A026B0255
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:54:09 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so16169838pac.3
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 07:54:09 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id q2si9867782pda.244.2015.08.12.07.54.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Aug 2015 07:54:08 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSZ00Q7O5DK5Q80@mailout3.samsung.com> for linux-mm@kvack.org;
 Wed, 12 Aug 2015 23:53:44 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
 <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
 <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
 <012e01d0d351$5dc752a0$1955f7e0$@samsung.com>
 <20150811105512.GD18998@dhcp22.suse.cz>
In-reply-to: <20150811105512.GD18998@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Date: Wed, 12 Aug 2015 20:22:10 +0530
Message-id: <077101d0d50e$a37310f0$ea5932d0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

Hi,

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Tuesday, August 11, 2015 4:25 PM
> To: PINTU KUMAR
> Cc: 'Andrew Morton'; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> minchan@kernel.org; dave@stgolabs.net; koct9i@gmail.com;
> mgorman@suse.de; vbabka@suse.cz; js1304@gmail.com;
> hannes@cmpxchg.org; alexander.h.duyck@redhat.com;
> sasha.levin@oracle.com; cl@linux.com; fengguang.wu@intel.com;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.k@outlook.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
> 
> On Mon 10-08-15 15:15:06, PINTU KUMAR wrote:
> [...]
> > > > Regarding trace points, I am not sure if we can attach counter to it.
> > > > Also trace may have more over-head and requires additional configs
> > > > to be enabled to debug.
> > > > Mostly these configs will not be enabled by default (at least in
> > > > embedded, low memory device).
> > > > I found the vmstat interface more easy and useful.
> > >
> > > This does seem like a pretty basic and sensible thing to expose in
> > > vmstat.  It probably makes more sense than some of the other things we
have
> in there.
> 
> I still fail to see what exactly this number says. The allocator slowpath (aka
> __alloc_pages_slowpath) is more an organizational split up of the code than
> anything that would tell us about how costly the allocation is - e.g.
zone_reclaim
> might happen before we enter the slowpath.
> 
> > Thanks Andrew.
> > Yes, as par my analysis, I feel that this is one of the useful and
> > important interface.
> > I added it in one of our internal product and found it to be very useful.
> > Specially during shrink_memory and compact_nodes analysis I found it
> > really useful.
> > It helps me to prove that if higher-order pages are present, it can
> > reduce the slowpath drastically.
> 
> I am not sure I understand but this is kind of obvious, no?
> 
Yes, but it's hard to prove to management that the slowpath count is reduced.
As we have seen, most of the time this kind of performance issues are hard to
reproduce.

> > Also during my ELC presentation people asked me how to monitor the
> > slowpath counts.
> 
> Isn't the allocation latency a much well defined metric? What does the
slowpath
> without compaction/reclaim tell to user?
> 
The current metrics in slowpath is the story half told. 

> > > Yes, it could be a tracepoint but practically speaking, a tracepoint
> > > makes it developer-only.  You can ask a bug reporter or a customer
> > > "what is /proc/vmstat:slowpath_entered" doing, but it's harder to
> > > ask them to set up tracing.
> > >
> > Yes, at times tracing are painful to analyze.
> > Also, in commercial user binaries, most of tracing support are
> > disabled (with no root privileges).
> > However, /proc/vmstat works with normal user binaries.
> > When memory issues are reported, we just get log dumps and few
> > interfaces like this.
> > Most of the time these memory issues are hard to reproduce because it
> > may happen after long usage.
> 
> Yes, I do understand that vmstat is much more convenient. No question about
> that. But the counter should be generally usable.
> 
> When I see COMPACTSTALL increasing I know that the direct compaction had to
> be invoked and that tells me that the system is getting fragmented and
> COMPACTFAIL/COMPACTSUCCESS will tell me how successful the compaction is.
> 
> Similarly when I see ALLOCSTALL I know that kswapd doesn't catch up and
> scan/reclaim will tell me how effective it is. Snapshoting ALLOCSTALL/time
> helped me to narrow down memory pressure peaks to further investigate other
> counters in a more detail.
> 
> What will entered-slowpath without triggering neither compaction nor direct
> reclaim tell me?
> 
The slowpath count will actually give the actual number, irrespective of
compact/reclaim/kswapd.
There are other things that happens in slowpath, for which we don't have
counters.
Thus having one counter _slowpath_ is enough for all situations.
Even, when KSWAP/COMPACTION is disabled, or not used.

> [...]
> 
> > > Two things:
> > >
> > > - we appear to have forgotten to document /proc/vmstat
> > >
> > Yes, I could not find any document on vmstat under kernel/Documentation.
> > I think it's a nice think to have.
> > May be, I can start this initiative to create one :)
> 
> That would be more than appreciated.
> 
Ok, I will start the basic vmstat.txt in Documentation and release first
version.
Thanks.

> > If respective owner can update, it will be great.
> >
> > > - How does one actually use slowpath_entered?  Obviously we'd like to
> > >   know "what proportion of allocations entered the slowpath", so we
> > >   calculate
> > >
> > > 	slowpath_entered/X
> > >
> > >   how do we obtain "X"?  Is it by adding up all the pgalloc_*?
> 
> It's not because pgalloc_ count number of pages while slowpath_entered counts
> allocations requests.
> 
> > >   If
> > >   so, perhaps we should really have slowpath_entered_dma,
> > >   slowpath_entered_dma32, ...?
> >
> > I think the slowpath for other zones may not be required.
> > We just need to know how many times we entered slowpath and possibly
> > do something to reduce it.
> > But, I think, pgalloc_* count may also include success for fastpath.
> >
> > How I use slowpath for analysis is:
> > VMSTAT		BEFORE	AFTER		%DIFF
> > ----------		----------	----------	------------
> > nr_free_pages		6726		12494		46.17%
> > pgalloc_normal		985836		1549333	36.37%
> > pageoutrun		2699		529		80.40%
> > allocstall		298		98		67.11%
> > slowpath_entered	16659		739		95.56%
> > compact_stall		244		21		91.39%
> > compact_fail		178		11		93.82%
> > compact_success	52		7		86.54%
> >
> > The above values are from 512MB system with only NORMAL zone.
> > Before, the slowpath count was 16659.
> > After (memory shrinker + compaction), the slowpath reduced by 95%, for
> > the same scenario.
> > This is just an example.
> 
> But what additional information does it give to us? We can see that the direct
> reclaim has been reduced as well as the compaction which was even more
> effective so the overall memory pressure was lighter and memory less
> fragmented. I assume that your test has requested the same amount of high
> order allocations and pgalloc_normal much higher in the second case suggests
> they were more effective but we can see that clearly even without
> slowpath_entered.
> 
The think to note here is that, slowpath count is 16659 (which is 100% actual,
and no confusion).
However, if you see the other counter for slowpath (pageoutrun:2699,
allocstall:298, compact_stall:244), 
And add all of them (2699+298+244)=3241, it is much lesser than the actual
slowpath count.
So, these counter doesn't really tells what actually happened in the slowpath.
There are other factors that effects slowpath (like, alloc without watermarks).
Moreover, with _retry_ and _rebalance_ mechanism, the allocstall/compact_stall
counter will keep increasing.
But, slowpath count will remain same.
Also, in some system, the KSWAP can be disabled, so pageoutrun will be always 0.
Similarly, COMPACTION can be disabled, so compact_stall will not be present.
In this scenario, we are left with only allocstall.
Also, as I said earlier, this allocstall can also be incremented from other
place, such as shrink_all_memory.
Consider, another situation like below:
VMSTAT
-------------------------------------
nr_free_pages		59982
pgalloc_normal 	364163
pgalloc_high 		2046
pageoutrun 		1
allocstall 		0
compact_stall 		0
compact_fail 		0
compact_success 	0
------------------------------------
>From the above, is it possible to tell how many times it entered into slowpath?
Now, I will add slowpath here, and check again. I don't have that data right
now.
Thus, the point is, just one counter is enough to quickly analyze the behavior
in slowpath.

More suggestions are welcome!

> So I would argue that we do not need slowpath_entered. We already have it,
> even specialized depending on which _slow_ path has been executed.
> What we are missing is a number of all requests to have a reasonable base.
> Whether adding such a counter in the hot path is justified is a question. I
haven't
> really needed it so far and I am looking into vmstat and meminfo to debug
> memory reclaim related issues quite often.
> 
> > If we are interested to know even allocation success/fail ratio in
> > slowpath, then I think we need more counters.
> > Such as; direct_reclaim_success/fail, kswapd_success/fail (just like
> > compaction success/fail).
> > OR, we can have pgalloc_success_fastpath counter.
> 
> This all sounds like exposing more and more details about internal
> implementation. This all fits into tracepoints world IMO.
> 
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
