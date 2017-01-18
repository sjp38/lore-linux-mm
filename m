Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 463046B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:17:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r126so3977251wmr.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si2952052wmh.15.2017.01.18.08.17.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 08:17:33 -0800 (PST)
Date: Wed, 18 Jan 2017 17:17:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170118161731.GT7015@dhcp22.suse.cz>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
 <20170118155430.kimzqkur5c3te2at@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118155430.kimzqkur5c3te2at@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed 18-01-17 15:54:30, Mel Gorman wrote:
> On Wed, Jan 18, 2017 at 04:15:31PM +0100, Michal Hocko wrote:
> > On Wed 18-01-17 14:46:55, Mel Gorman wrote:
> > > On Wed, Jan 18, 2017 at 02:44:52PM +0100, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > 599d0c954f91 ("mm, vmscan: move LRU lists to node") has moved
> > > > NR_ISOLATED* counters from zones to nodes. This is not the best fit
> > > > especially for systems with high/lowmem because a heavy memory pressure
> > > > on the highmem zone might block lowmem requests from making progress. Or
> > > > we might allow to reclaim lowmem zone even though there are too many
> > > > pages already isolated from the eligible zones just because highmem
> > > > pages will easily bias too_many_isolated to say no.
> > > > 
> > > > Fix these potential issues by moving isolated stats back to zones and
> > > > teach too_many_isolated to consider only eligible zones. Per zone
> > > > isolation counters are a bit tricky with the node reclaim because
> > > > we have to track each page separatelly.
> > > > 
> > > 
> > > I'm quite unhappy with this. Each move back increases the cache footprint
> > > because of the counters
> > 
> > Why would per zone counters cause an increased cache footprint?
> > 
> 
> Because there are multiple counters, each of which need to be updated.

How does this differ from per node counter though. We would need to do
the accounting anyway. Moreover none of the accounting is done in a hot
path.

> > > but it's not clear at all this patch actually helps anything.
> > 
> > Yes, I cannot prove any real issue so far. The main motivation was the
> > patch 2 which needs per-zone accounting to use it in the retry logic
> > (should_reclaim_retry). I've spotted too_many_isoalated issues on the
> > way.
> > 
> 
> You don't appear to directly use that information in patch 2.

It is used via zone_reclaimable_pages in should_reclaim_retry

> The primary
> breakout is returning after stalling at least once. You could also avoid
> an infinite loop by using a waitqueue that sleeps on too many isolated.

That would be tricky on its own. Just consider the report form Tetsuo.
Basically all the direct reclamers are looping on too_many_isolated
while the kswapd is not making any progres because it is blocked on FS
locks which are held by flushers which are making dead slow progress.
Some of those direct reclaimers could have gone oom instead and release
some memory if we decide so, which we cannot because we are deep down in
the reclaim path. Waiting for on the reclaimer to increase the ISOLATED
counter wouldn't help in this situation.

> That would both avoid the clunky congestion_wait() and guarantee forward
> progress. If the primary motivation is to avoid an infinite loop with
> too_many_isolated then there are ways of handling that without reintroducing
> zone-based counters.
> 
> > > Heavy memory pressure on highmem should be spread across the whole node as
> > > we no longer are applying the fair zone allocation policy. The processes
> > > with highmem requirements will be reclaiming from all zones and when it
> > > finishes, it's possible that a lowmem-specific request will be clear to make
> > > progress. It's all the same LRU so if there are too many pages isolated,
> > > it makes sense to wait regardless of the allocation request.
> > 
> > This is true but I am not sure how it is realated to the patch.
> 
> Because heavy pressure that is enough to trigger too many isolated pages
> is unlikely to be specifically targetting a lower zone.

Why? Basically any GFP_KERNEL allocation will make lowmem pressure and
going OOM on lowmem is not all that unrealistic scenario on 32b systems.

> There is general
> pressure with multiple direct reclaimers being applied. If the system is
> under enough pressure with parallel reclaimers to trigger too_many_isolated
> checks then the system is grinding already and making little progress. Adding
> multiple counters to allow a lowmem reclaimer to potentially make faster
> progress is going to be marginal at best.

OK, I agree that the situation where highmem blocks lowmem from making
progress is much less likely than the other situation described in the
changelog when lowmem doesn't get throttled ever. Which is the one I am
interested more about.

> > Also consider that lowmem throttling in too_many_isolated has only small
> > chance to ever work with the node counters because highmem >> lowmem in
> > many/most configurations.
> > 
> 
> While true, it's also not that important.
> 
> > > More importantly, this patch may make things worse and delay reclaim. If
> > > this patch allowed a lowmem request to make progress that would have
> > > previously stalled, it's going to spend time skipping pages in the LRU
> > > instead of letting kswapd and the highmem pressured processes make progress.
> > 
> > I am not sure I understand this part. Say that we have highmem pressure
> > which would isolated too many pages from the LRU.
> 
> Which requires multiple direct reclaimers or tiny inactive lists. In the
> event there is such highmem pressure, it also means the lower zones are
> depleted.

But consider a lowmem without highmem pressure. E.g. a heavy parallel
fork or any other GFP_KERNEL intensive workload.
 
> > lowmem request would
> > stall previously regardless of where those pages came from. With this
> > patch it would stall only when we isolated too many pages from the
> > eligible zones.
> 
> And when it makes progress, it's goign to compete with the other direct
> reclaimers except the lowmem reclaim is skipping some pages and
> recycling them through the LRU. It chews up CPU that would probably have
> been better spent letting kswapd and the other direct reclaimers do
> their work.

OK, I guess we are talking past each other. What I meant to say is that
it doesn't really make any difference who is chewing through the LRU to
find last few lowmem pages to reclaim. So I do not see much of a
difference sleeping and postponing that to the kswapd.

That being said, I _believe_ I will need per zone ISOLATED counters in
order to make the other patch work reliably and do not declare oom
prematurely. Maybe there is some other way around that (hence this RFC).
Would you be strongly opposed to the patch which would make counters per
zone without touching too_many_isolated?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
