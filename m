Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B51F86B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 19:18:05 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so105213948pab.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 16:18:05 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id fa2si14080048pbd.12.2015.04.16.16.18.03
        for <linux-mm@kvack.org>;
        Thu, 16 Apr 2015 16:18:04 -0700 (PDT)
Date: Fri, 17 Apr 2015 09:17:53 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Message-ID: <20150416231753.GC15810@dastard>
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
 <20141128160637.GH6948@esperanza>
 <20150416035736.GA1203@js1304-P5Q-DELUXE>
 <20150416143413.GA9228@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150416143413.GA9228@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 16, 2015 at 10:34:13AM -0400, Johannes Weiner wrote:
> On Thu, Apr 16, 2015 at 12:57:36PM +0900, Joonsoo Kim wrote:
> > This causes following success rate regression of phase 1,2 on stress-highalloc
> > benchmark. The situation of phase 1,2 is that many high order allocations are
> > requested while many threads do kernel build in parallel.
> 
> Yes, the patch made the shrinkers on multi-zone nodes less aggressive.
> From the changelog:
> 
>     This changes kswapd behavior, which used to invoke the shrinkers for each
>     zone, but with scan ratios gathered from the entire node, resulting in
>     meaningless pressure quantities on multi-zone nodes.
> 
> So the previous code *did* apply more pressure on the shrinkers, but
> it didn't make any sense.  The number of slab objects to scan for each
> scanned LRU page depended on how many zones there were in a node, and
> their relative sizes.  So a node with a large DMA32 and a small Normal
> would receive vastly different relative slab pressure than a node with
> only one big zone Normal.  That's not something we should revert to.
> 
> If we are too weak on objects compared to LRU pages then we should
> adjust DEFAULT_SEEKS or individual shrinker settings.

Now this thread has my attention. Changing shrinker defaults will
seriously upset the memory balance under load (in unpredictable
ways) so I really don't think we should even consider changing
DEFAULT_SEEKS.

If there's a shrinker imbalance, we need to understand which
shrinker needs rebalancing, then modify that shrinker's
configuration and then observe the impact this has on the rest of
the system. This means looking at variance of the memory footprint
in steady state, reclaim overshoot and damping rates before steady
state is acheived, etc.  Balancing multiple shrinkers (especially
those with dependencies on other caches) under memory
load is a non-trivial undertaking.

I don't see any evidence that we have a shrinker imbalance, so I
really suspect the problem is "shrinkers aren't doing enough work".
In that case, we need to increase the pressure being generated, not
start fiddling around with shrinker configurations.

> If we think our pressure ratio is accurate but we don't reclaim enough
> compared to our compaction efforts, then any adjustments to improve
> huge page successrate should come from the allocator/compaction side.

Right - if compaction is failing, then the problem is more likely
that it isn't generating enough pressure, and so the shrinkers
aren't doing the work we are expecting them to do. That's a problem
with compaction, not the shrinkers...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
