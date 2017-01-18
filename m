Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B09C6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:54:38 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id jz4so3207541wjb.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:54:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b40si793129wrb.87.2017.01.18.07.54.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 07:54:36 -0800 (PST)
Date: Wed, 18 Jan 2017 15:54:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170118155430.kimzqkur5c3te2at@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170118151530.GR7015@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 18, 2017 at 04:15:31PM +0100, Michal Hocko wrote:
> On Wed 18-01-17 14:46:55, Mel Gorman wrote:
> > On Wed, Jan 18, 2017 at 02:44:52PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > 599d0c954f91 ("mm, vmscan: move LRU lists to node") has moved
> > > NR_ISOLATED* counters from zones to nodes. This is not the best fit
> > > especially for systems with high/lowmem because a heavy memory pressure
> > > on the highmem zone might block lowmem requests from making progress. Or
> > > we might allow to reclaim lowmem zone even though there are too many
> > > pages already isolated from the eligible zones just because highmem
> > > pages will easily bias too_many_isolated to say no.
> > > 
> > > Fix these potential issues by moving isolated stats back to zones and
> > > teach too_many_isolated to consider only eligible zones. Per zone
> > > isolation counters are a bit tricky with the node reclaim because
> > > we have to track each page separatelly.
> > > 
> > 
> > I'm quite unhappy with this. Each move back increases the cache footprint
> > because of the counters
> 
> Why would per zone counters cause an increased cache footprint?
> 

Because there are multiple counters, each of which need to be updated.

> > but it's not clear at all this patch actually helps anything.
> 
> Yes, I cannot prove any real issue so far. The main motivation was the
> patch 2 which needs per-zone accounting to use it in the retry logic
> (should_reclaim_retry). I've spotted too_many_isoalated issues on the
> way.
> 

You don't appear to directly use that information in patch 2. The primary
breakout is returning after stalling at least once. You could also avoid
an infinite loop by using a waitqueue that sleeps on too many isolated.
That would both avoid the clunky congestion_wait() and guarantee forward
progress. If the primary motivation is to avoid an infinite loop with
too_many_isolated then there are ways of handling that without reintroducing
zone-based counters.

> > Heavy memory pressure on highmem should be spread across the whole node as
> > we no longer are applying the fair zone allocation policy. The processes
> > with highmem requirements will be reclaiming from all zones and when it
> > finishes, it's possible that a lowmem-specific request will be clear to make
> > progress. It's all the same LRU so if there are too many pages isolated,
> > it makes sense to wait regardless of the allocation request.
> 
> This is true but I am not sure how it is realated to the patch.

Because heavy pressure that is enough to trigger too many isolated pages
is unlikely to be specifically targetting a lower zone. There is general
pressure with multiple direct reclaimers being applied. If the system is
under enough pressure with parallel reclaimers to trigger too_many_isolated
checks then the system is grinding already and making little progress. Adding
multiple counters to allow a lowmem reclaimer to potentially make faster
progress is going to be marginal at best.

> Also consider that lowmem throttling in too_many_isolated has only small
> chance to ever work with the node counters because highmem >> lowmem in
> many/most configurations.
> 

While true, it's also not that important.

> > More importantly, this patch may make things worse and delay reclaim. If
> > this patch allowed a lowmem request to make progress that would have
> > previously stalled, it's going to spend time skipping pages in the LRU
> > instead of letting kswapd and the highmem pressured processes make progress.
> 
> I am not sure I understand this part. Say that we have highmem pressure
> which would isolated too many pages from the LRU.

Which requires multiple direct reclaimers or tiny inactive lists. In the
event there is such highmem pressure, it also means the lower zones are
depleted.

> lowmem request would
> stall previously regardless of where those pages came from. With this
> patch it would stall only when we isolated too many pages from the
> eligible zones.

And when it makes progress, it's goign to compete with the other direct
reclaimers except the lowmem reclaim is skipping some pages and
recycling them through the LRU. It chews up CPU that would probably have
been better spent letting kswapd and the other direct reclaimers do
their work.

> So let's assume that lowmem is not under pressure,

It has to be or the highmem request would have used memory from the
lower zones.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
