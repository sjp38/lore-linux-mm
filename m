Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 233D76B0005
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 19:27:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so63539562pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 16:27:18 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id y131si352351pfb.83.2016.07.07.16.27.16
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 16:27:17 -0700 (PDT)
Date: Fri, 8 Jul 2016 09:27:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160707232713.GM27480@dastard>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 04:37:15PM +0100, Mel Gorman wrote:
> Previous releases double accounted LRU stats on the zone and the node
> because it was required by should_reclaim_retry. The last patch in the
> series removes the double accounting. It's not integrated with the series
> as reviewers may not like the solution. If not, it can be safely dropped
> without a major impact to the results.
....
> tiobench on ext4
> ----------------

[snip other tests on ext4 which show good results]

.....
> This series is not without its hazards. There are at least three areas
> that I'm concerned with even though I could not reproduce any problems in
> that area.
> 
> 1. Reclaim/compaction is going to be affected because the amount of reclaim is
>    no longer targetted at a specific zone. Compaction works on a per-zone basis
>    so there is no guarantee that reclaiming a few THP's worth page pages will
>    have a positive impact on compaction success rates.
> 
> 2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
>    are called is now different. This may or may not be a problem but if it
>    is, it'll be because shrinkers are not called enough and some balancing
>    is required.

Given that XFS has a much more complex set of shrinkers and has a
much more finely tuned balancing between LRU and shrinker reclaim,
I'd be interested to see if you get the same results on XFS for the
tests you ran on ext4. It might also be worth running some highly
concurrent inode cache benchmarks (e.g. the 50-million inode, 16-way
concurrent fsmark tests) to see what impact heavy slab cache
pressure has on shrinker behaviour and system balance...

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
