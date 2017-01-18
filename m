Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28CC96B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:15:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so3022035wjc.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:15:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g65si20335073wmd.148.2017.01.18.07.15.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 07:15:32 -0800 (PST)
Date: Wed, 18 Jan 2017 16:15:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170118151530.GR7015@dhcp22.suse.cz>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118144655.3lra7xgdcl2awgjd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed 18-01-17 14:46:55, Mel Gorman wrote:
> On Wed, Jan 18, 2017 at 02:44:52PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 599d0c954f91 ("mm, vmscan: move LRU lists to node") has moved
> > NR_ISOLATED* counters from zones to nodes. This is not the best fit
> > especially for systems with high/lowmem because a heavy memory pressure
> > on the highmem zone might block lowmem requests from making progress. Or
> > we might allow to reclaim lowmem zone even though there are too many
> > pages already isolated from the eligible zones just because highmem
> > pages will easily bias too_many_isolated to say no.
> > 
> > Fix these potential issues by moving isolated stats back to zones and
> > teach too_many_isolated to consider only eligible zones. Per zone
> > isolation counters are a bit tricky with the node reclaim because
> > we have to track each page separatelly.
> > 
> 
> I'm quite unhappy with this. Each move back increases the cache footprint
> because of the counters

Why would per zone counters cause an increased cache footprint?

> but it's not clear at all this patch actually helps anything.

Yes, I cannot prove any real issue so far. The main motivation was the
patch 2 which needs per-zone accounting to use it in the retry logic
(should_reclaim_retry). I've spotted too_many_isoalated issues on the
way.

> Heavy memory pressure on highmem should be spread across the whole node as
> we no longer are applying the fair zone allocation policy. The processes
> with highmem requirements will be reclaiming from all zones and when it
> finishes, it's possible that a lowmem-specific request will be clear to make
> progress. It's all the same LRU so if there are too many pages isolated,
> it makes sense to wait regardless of the allocation request.

This is true but I am not sure how it is realated to the patch. If we
have a heavy highmem memory pressure then we will throttle based on
pages isolated from the respective zones. So if the there is a lowmem
pressure at the same time then we throttle it only when we need to.

Also consider that lowmem throttling in too_many_isolated has only small
chance to ever work with the node counters because highmem >> lowmem in
many/most configurations.

> More importantly, this patch may make things worse and delay reclaim. If
> this patch allowed a lowmem request to make progress that would have
> previously stalled, it's going to spend time skipping pages in the LRU
> instead of letting kswapd and the highmem pressured processes make progress.

I am not sure I understand this part. Say that we have highmem pressure
which would isolated too many pages from the LRU. lowmem request would
stall previously regardless of where those pages came from. With this
patch it would stall only when we isolated too many pages from the
eligible zones. So let's assume that lowmem is not under pressure, why
should we stall? And why would it delay reclaim? Whoever want to make
progress on that zone has to iterate and potentially skip many pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
