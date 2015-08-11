Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 516806B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 06:55:16 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so63428520wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 03:55:15 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id fk20si2887687wjc.82.2015.08.11.03.55.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 03:55:15 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so189536915wib.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 03:55:14 -0700 (PDT)
Date: Tue, 11 Aug 2015 12:55:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-ID: <20150811105512.GD18998@dhcp22.suse.cz>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
 <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
 <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
 <012e01d0d351$5dc752a0$1955f7e0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <012e01d0d351$5dc752a0$1955f7e0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On Mon 10-08-15 15:15:06, PINTU KUMAR wrote:
[...]
> > > Regarding trace points, I am not sure if we can attach counter to it.
> > > Also trace may have more over-head and requires additional configs to
> > > be enabled to debug.
> > > Mostly these configs will not be enabled by default (at least in
> > > embedded, low memory device).
> > > I found the vmstat interface more easy and useful.
> > 
> > This does seem like a pretty basic and sensible thing to expose in vmstat.  It
> > probably makes more sense than some of the other things we have in there.

I still fail to see what exactly this number says. The allocator
slowpath (aka __alloc_pages_slowpath) is more an organizational split
up of the code than anything that would tell us about how costly the
allocation is - e.g. zone_reclaim might happen before we enter the
slowpath.

> Thanks Andrew.
> Yes, as par my analysis, I feel that this is one of the useful and important
> interface.
> I added it in one of our internal product and found it to be very useful.
> Specially during shrink_memory and compact_nodes analysis I found it really
> useful.
> It helps me to prove that if higher-order pages are present, it can reduce the
> slowpath drastically.

I am not sure I understand but this is kind of obvious, no?

> Also during my ELC presentation people asked me how to monitor the slowpath
> counts.

Isn't the allocation latency a much well defined metric? What does the
slowpath without compaction/reclaim tell to user?

> > Yes, it could be a tracepoint but practically speaking, a tracepoint makes it
> > developer-only.  You can ask a bug reporter or a customer "what is
> > /proc/vmstat:slowpath_entered" doing, but it's harder to ask them to set up
> > tracing.
> > 
> Yes, at times tracing are painful to analyze.
> Also, in commercial user binaries, most of tracing support are disabled (with no
> root privileges).
> However, /proc/vmstat works with normal user binaries.
> When memory issues are reported, we just get log dumps and few interfaces like
> this.
> Most of the time these memory issues are hard to reproduce because it may happen
> after long usage.

Yes, I do understand that vmstat is much more convenient. No question
about that. But the counter should be generally usable.

When I see COMPACTSTALL increasing I know that the direct compaction had
to be invoked and that tells me that the system is getting fragmented
and COMPACTFAIL/COMPACTSUCCESS will tell me how successful the
compaction is.

Similarly when I see ALLOCSTALL I know that kswapd doesn't catch up and
scan/reclaim will tell me how effective it is. Snapshoting
ALLOCSTALL/time helped me to narrow down memory pressure peaks to
further investigate other counters in a more detail.

What will entered-slowpath without triggering neither compaction nor
direct reclaim tell me?

[...]

> > Two things:
> > 
> > - we appear to have forgotten to document /proc/vmstat
> > 
> Yes, I could not find any document on vmstat under kernel/Documentation.
> I think it's a nice think to have.
> May be, I can start this initiative to create one :)

That would be more than appreciated.

> If respective owner can update, it will be great.
> 
> > - How does one actually use slowpath_entered?  Obviously we'd like to
> >   know "what proportion of allocations entered the slowpath", so we
> >   calculate
> > 
> > 	slowpath_entered/X
> > 
> >   how do we obtain "X"?  Is it by adding up all the pgalloc_*?

It's not because pgalloc_ count number of pages while slowpath_entered
counts allocations requests.

> >   If
> >   so, perhaps we should really have slowpath_entered_dma,
> >   slowpath_entered_dma32, ...?
>
> I think the slowpath for other zones may not be required.
> We just need to know how many times we entered slowpath and possibly do
> something to reduce it.
> But, I think, pgalloc_* count may also include success for fastpath.
> 
> How I use slowpath for analysis is:
> VMSTAT		BEFORE	AFTER		%DIFF
> ----------		----------	----------	------------
> nr_free_pages		6726		12494		46.17%
> pgalloc_normal		985836		1549333	36.37%
> pageoutrun		2699		529		80.40%
> allocstall		298		98		67.11%
> slowpath_entered	16659		739		95.56%
> compact_stall		244		21		91.39%
> compact_fail		178		11		93.82%
> compact_success	52		7		86.54%
> 
> The above values are from 512MB system with only NORMAL zone.
> Before, the slowpath count was 16659.
> After (memory shrinker + compaction), the slowpath reduced by 95%, for
> the same scenario.
> This is just an example.

But what additional information does it give to us? We can see that the
direct reclaim has been reduced as well as the compaction which was even
more effective so the overall memory pressure was lighter and memory
less fragmented. I assume that your test has requested the same amount
of high order allocations and pgalloc_normal much higher in the second
case suggests they were more effective but we can see that clearly even
without slowpath_entered.

So I would argue that we do not need slowpath_entered. We already have
it, even specialized depending on which _slow_ path has been executed.
What we are missing is a number of all requests to have a reasonable
base. Whether adding such a counter in the hot path is justified is a
question. I haven't really needed it so far and I am looking into vmstat
and meminfo to debug memory reclaim related issues quite often.

> If we are interested to know even allocation success/fail ratio in slowpath,
> then I think we need more counters.
> Such as; direct_reclaim_success/fail, kswapd_success/fail (just like compaction
> success/fail).
> OR, we can have pgalloc_success_fastpath counter.

This all sounds like exposing more and more details about internal
implementation. This all fits into tracepoints world IMO.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
