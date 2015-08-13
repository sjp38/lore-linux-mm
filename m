Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id F0D8A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 05:07:49 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so250526260wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:07:49 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id et10si2817937wib.62.2015.08.13.02.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 02:07:48 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so250525093wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:07:47 -0700 (PDT)
Date: Thu, 13 Aug 2015 11:07:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-ID: <20150813090704.GA31736@dhcp22.suse.cz>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
 <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
 <20150807153547.04cf3a12ae095fcdd19da670@linux-foundation.org>
 <012e01d0d351$5dc752a0$1955f7e0$@samsung.com>
 <20150811105512.GD18998@dhcp22.suse.cz>
 <077101d0d50e$a37310f0$ea5932d0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <077101d0d50e$a37310f0$ea5932d0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

On Wed 12-08-15 20:22:10, PINTU KUMAR wrote:
> > On Mon 10-08-15 15:15:06, PINTU KUMAR wrote:
[...]
> > > Yes, as par my analysis, I feel that this is one of the useful and
> > > important interface.
> > > I added it in one of our internal product and found it to be very useful.
> > > Specially during shrink_memory and compact_nodes analysis I found it
> > > really useful.
> > > It helps me to prove that if higher-order pages are present, it can
> > > reduce the slowpath drastically.
> > 
> > I am not sure I understand but this is kind of obvious, no?
> > 
> Yes, but it's hard to prove to management that the slowpath count is reduced.
> As we have seen, most of the time this kind of performance issues are hard to
> reproduce.

But the counter doesn't tell you much as I've tried to explain in my
previous email. You simply do not have the base to compare it to. The
fact is that slow path in this context is quite ambiguous. As I've
mentioned the fast path (as per the code organization) can already do
expensive operations (e.g. zone_reclaim). So what you are exporting is
more a slow path from the code organization POV.

Management might be happy about comparing two arbitrary numbers but that
doesn't mean it is relevant...

[...]

> > When I see COMPACTSTALL increasing I know that the direct compaction had to
> > be invoked and that tells me that the system is getting fragmented and
> > COMPACTFAIL/COMPACTSUCCESS will tell me how successful the compaction is.
> > 
> > Similarly when I see ALLOCSTALL I know that kswapd doesn't catch up and
> > scan/reclaim will tell me how effective it is. Snapshoting ALLOCSTALL/time
> > helped me to narrow down memory pressure peaks to further investigate other
> > counters in a more detail.
> > 
> > What will entered-slowpath without triggering neither compaction nor direct
> > reclaim tell me?
> > 
> The slowpath count will actually give the actual number, irrespective of
> compact/reclaim/kswapd.

If we are missing them and they are significant to make a picture of
what is causing allocation delays then let's focus on those.

> There are other things that happens in slowpath, for which we don't have
> counters.

Which would be interesting enough to account for?

[...]

> > > How I use slowpath for analysis is:
> > > VMSTAT		BEFORE	AFTER		%DIFF
> > > ----------		----------	----------	------------
> > > nr_free_pages		6726		12494		46.17%
> > > pgalloc_normal		985836		1549333	36.37%
> > > pageoutrun		2699		529		80.40%
> > > allocstall		298		98		67.11%
> > > slowpath_entered	16659		739		95.56%
> > > compact_stall		244		21		91.39%
> > > compact_fail		178		11		93.82%
> > > compact_success	52		7		86.54%
> > >
> > > The above values are from 512MB system with only NORMAL zone.
> > > Before, the slowpath count was 16659.
> > > After (memory shrinker + compaction), the slowpath reduced by 95%, for
> > > the same scenario.
> > > This is just an example.
> > 
> > But what additional information does it give to us? We can see that the direct
> > reclaim has been reduced as well as the compaction which was even more
> > effective so the overall memory pressure was lighter and memory less
> > fragmented. I assume that your test has requested the same amount of high
> > order allocations and pgalloc_normal much higher in the second case suggests
> > they were more effective but we can see that clearly even without
> > slowpath_entered.
> > 
> The think to note here is that, slowpath count is 16659 (which is 100% actual,
> and no confusion).

100% against what? It certainly is not 100% of all costly allocations
because of what has been said already. Moreover this number is really
meaningless without knowing how many allocations requests were done
in total.

> However, if you see the other counter for slowpath (pageoutrun:2699,
> allocstall:298, compact_stall:244), 
> And add all of them (2699+298+244)=3241, it is much lesser than the actual
> slowpath count.

Yes, because the allocation might have succeeded before the compaction
and/or direct reclaim. Such an allocation could be marginally slower
than what is not accounted as a fastpath.

> So, these counter doesn't really tells what actually happened in the slowpath.

No they are not and that is not their purpose. They aim at telling you
about costly allocation paths and they give you quite a good view into
how they operate. At least they've been serving good for me so far. If
there are gaps then let's fill them.

> There are other factors that effects slowpath (like, alloc without watermarks).
> Moreover, with _retry_ and _rebalance_ mechanism, the allocstall/compact_stall
> counter will keep increasing.
> But, slowpath count will remain same.

I am not sure direct reclaims per one slow path is a super important
information. It's been quite sufficient for me to see that there have
been many direct reclaims per time unit to debug what is causing the
memory peak.

> Also, in some system, the KSWAP can be disabled, so pageoutrun will be always 0.

Such a system would be really unhealthy but that is really irrelevant to
the discussion.

> Similarly, COMPACTION can be disabled, so compact_stall will not be present.
> In this scenario, we are left with only allocstall.

Yes and so what?

> Also, as I said earlier, this allocstall can also be incremented from other
> place, such as shrink_all_memory.

But shrink_all_memory is really uninteresting because this is a
hibernation path. You can save the file before and after the hibernation
to exclude it.

> Consider, another situation like below:
> VMSTAT
> -------------------------------------
> nr_free_pages		59982
> pgalloc_normal 	364163
> pgalloc_high 		2046
> pageoutrun 		1
> allocstall 		0
> compact_stall 		0
> compact_fail 		0
> compact_success 	0
> ------------------------------------
> From the above, is it possible to tell how many times it entered into slowpath?

No and I would argue this is not really that interesting. Because we
know that neither the direct reclaim nor compaction had to be triggered.
So from my point of view those allocations were still in a good shape.
entered_slowpath would tell me marginally more. Merely the fact that I had
to go via get_page_from_freelist one more time and as this doesn't have
a constant cost I would have to go for tracing to have a better picture.

That being said, this counter alone is IMHO useless for any reasonable
analysis. I would even argue it is actively misleading because it
doesn't mark all the slow paths during the allocation. So NAK to this
patch.

Nevertheless, I can imagine some additional counters could help for
debugging.
ALLOC_REQUESTS - to count all requests
ALLOC_FAILS - to count number of failed requests
ALLOC_OOM - to count OOM events
COMPACTBACKOFF - compaction backed off because it wouldn't be worth it

I could find a way without them until now so I am so sure they are
really necessary but if somebody has a usecase and the additional
overhead (especially for ALLOC_REQUESTS which is the hot path) is worth
it I wouldn't mind.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
