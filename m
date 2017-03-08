Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE4D831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:21:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c143so9323478wmd.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:21:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si3561055wrd.2.2017.03.08.01.21.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 01:21:17 -0800 (PST)
Date: Wed, 8 Mar 2017 10:21:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170308092114.GB11028@dhcp22.suse.cz>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1488916356.6405.4.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 07-03-17 14:52:36, Rik van Riel wrote:
> On Tue, 2017-03-07 at 14:30 +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo Handa has reported [1][2] that direct reclaimers might get
> > stuck
> > in too_many_isolated loop basically for ever because the last few
> > pages
> > on the LRU lists are isolated by the kswapd which is stuck on fs
> > locks
> > when doing the pageout or slab reclaim. This in turn means that there
> > is
> > nobody to actually trigger the oom killer and the system is basically
> > unusable.
> > 
> > too_many_isolated has been introduced by 35cd78156c49 ("vmscan:
> > throttle
> > direct reclaim when too many pages are isolated already") to prevent
> > from pre-mature oom killer invocations because back then no reclaim
> > progress could indeed trigger the OOM killer too early. But since the
> > oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
> > the allocation/reclaim retry loop considers all the reclaimable pages
> > and throttles the allocation at that layer so we can loosen the
> > direct
> > reclaim throttling.
> 
> It only does this to some extent.  If reclaim made
> no progress, for example due to immediately bailing
> out because the number of already isolated pages is
> too high (due to many parallel reclaimers), the code
> could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> test without ever looking at the number of reclaimable
> pages.
> 
> Could that create problems if we have many concurrent
> reclaimers?

As the changelog mentions it might cause a premature oom killer
invocation theoretically. We could easily see that from the oom report
by checking isolated counters. My testing didn't trigger that though
and I was hammering the page allocator path from many threads.

I suspect some artificial tests can trigger that, I am not so sure about
reasonabel workloads. If we see this happening though then the fix would
be to resurrect my previous attempt to track NR_ISOLATED* per zone and
use them in the allocator retry logic.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
