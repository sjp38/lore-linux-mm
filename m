Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF736B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:03:06 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id kb1so74900007igb.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:03:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c16si14268380igo.104.2016.04.11.00.03.04
        for <linux-mm@kvack.org>;
        Mon, 11 Apr 2016 00:03:05 -0700 (PDT)
Date: Mon, 11 Apr 2016 16:05:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/4] reduce latency of direct async compaction
Message-ID: <20160411070547.GA26116@js1304-P5Q-DELUXE>
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 31, 2016 at 10:50:32AM +0200, Vlastimil Babka wrote:
> The goal here is to reduce latency (and increase success) of direct async
> compaction by making it focus more on the goal of creating a high-order page,
> at some expense of thoroughness.
> 
> This is based on an older attempt [1] which I didn't finish as it seemed that
> it increased longer-term fragmentation. Now it seems it doesn't, and we have
> kcompactd for that goal. The main patch (3) makes migration scanner skip whole
> order-aligned blocks as soon as isolation fails in them, as it takes just one
> unmigrated page to prevent a high-order buddy page from fully merging.
> 
> Patch 4 then attempts to reduce the excessive freepage scanning (such as
> reported in [2]) by allocating migration targets directly from freelists. Here
> we just need to be sure that the free pages are not from the same block as the
> migrated pages. This is also limited to direct async compaction and is not
> meant to replace the more thorough free scanner for other scenarios.

I don't like that another algorithm is introduced for async
compaction. As you know, we already suffer from corner case that async
compaction have (such as compaction deferring doesn't work if we only
do async compaction). It makes further analysis/improvement harder. Generally,
more difference on async compaction would cause more problem later.

In suggested approach, possible risky places I think is finish condition
and deferring logic. Scanner meet position would be greatly affected
by system load. If there are no processes and async compaction
isn't aborted, freepage scanner will be at the end of the zone and
we can scan migratable page until we reach there. But, in the other case
that the system has some load, async compaction would be aborted easily and
freepage scanner will be at the some of point of the zone and
async compaction's scanning power can be limited a lot.

And, with different algorithm, it doesn't make sense to share same deferring
logic. Async compaction can succeed even if sync compaction continually fails.

I hope that we don't make async/sync compaction more diverse. I'd be
more happy if we can apply such a change to both async/sync direct
compaction.

> 
> [1] https://lkml.org/lkml/2014/7/16/988
> [2] http://www.spinics.net/lists/linux-mm/msg97475.html
> 
> Testing was done using stress-highalloc from mmtests, configured for order-4
> GFP_KERNEL allocations:
> 
>                               4.6-rc1               4.6-rc1               4.6-rc1
>                                patch2                patch3                patch4
> Success 1 Min         24.00 (  0.00%)       27.00 (-12.50%)       43.00 (-79.17%)
> Success 1 Mean        30.20 (  0.00%)       31.60 ( -4.64%)       51.60 (-70.86%)
> Success 1 Max         37.00 (  0.00%)       35.00 (  5.41%)       73.00 (-97.30%)
> Success 2 Min         42.00 (  0.00%)       32.00 ( 23.81%)       73.00 (-73.81%)
> Success 2 Mean        44.00 (  0.00%)       44.80 ( -1.82%)       78.00 (-77.27%)
> Success 2 Max         48.00 (  0.00%)       52.00 ( -8.33%)       81.00 (-68.75%)
> Success 3 Min         91.00 (  0.00%)       92.00 ( -1.10%)       88.00 (  3.30%)
> Success 3 Mean        92.20 (  0.00%)       92.80 ( -0.65%)       91.00 (  1.30%)
> Success 3 Max         94.00 (  0.00%)       93.00 (  1.06%)       94.00 (  0.00%)
> 
> While the eager skipping of unsuitable blocks from patch 3 didn't affect
> success rates, direct freepage allocation did improve them.

Direct freepage allocation changes compaction algorithm a lot. It
removes limitation that we cannot get freepages from behind the
migration scanner so we can get freepage easily. It would be achieved
by other compaction algorithm changes (such as your pivot change or my
compaction algorithm change or this patchset). For the long term, this
limitation should be removed for sync compaction (at least direct sync
compaction), too. What's the reason that you don't apply this algorithm
to other cases? Is there any change in fragmentation?

Thanks.

> 
>              4.6-rc1     4.6-rc1     4.6-rc1
>               patch2      patch3      patch4
> User         2587.42     2566.53     2413.57
> System        482.89      471.20      461.71
> Elapsed      1395.68     1382.00     1392.87
> 
> Times are not so useful metric for this benchmark as main portion is the
> interfering kernel builds, but results do hint at reduced system times.
> 
>                                    4.6-rc1     4.6-rc1     4.6-rc1
>                                     patch2      patch3      patch4
> Direct pages scanned                163614      159608      123385
> Kswapd pages scanned               2070139     2078790     2081385
> Kswapd pages reclaimed             2061707     2069757     2073723
> Direct pages reclaimed              163354      159505      122304
> 
> Reduced direct reclaim was unintended, but could be explained by more
> successful first attempt at (async) direct compaction, which is attempted
> before the first reclaim attempt in __alloc_pages_slowpath().
> 
> Compaction stalls                    33052       39853       55091
> Compaction success                   12121       19773       37875
> Compaction failures                  20931       20079       17216
> 
> Compaction is indeed more successful, and thus less likely to get deferred,
> so there are also more direct compaction stalls. 
> 
> Page migrate success               3781876     3326819     2790838
> Page migrate failure                 45817       41774       38113
> Compaction pages isolated          7868232     6941457     5025092
> Compaction migrate scanned       168160492   127269354    87087993
> Compaction migrate prescanned            0           0           0
> Compaction free scanned         2522142582  2326342620   743205879
> Compaction free direct alloc             0           0      920792
> Compaction free dir. all. miss           0           0        5865
> Compaction cost                       5252        4476        3602
> 
> Patch 2 reduces migration scanned pages by 25% thanks to the eager skipping.
> Patch 3 reduces free scanned pages by 70%. The portion of direct allocation
> misses to all direct allocations is less than 1% which should be acceptable.
> Interestingly, patch 3 also reduces migration scanned pages by another 30% on
> top of patch 2. The reason is not clear, but we can rejoice nevertheless.

s/Patch 2/Patch 3
s/Patch 3/Patch 4

> Vlastimil Babka (4):
>   mm, compaction: wrap calculating first and last pfn of pageblock
>   mm, compaction: reduce spurious pcplist drains
>   mm, compaction: skip blocks where isolation fails in async direct
>     compaction
>   mm, compaction: direct freepage allocation for async direct compaction
> 
>  include/linux/vm_event_item.h |   1 +
>  mm/compaction.c               | 189 ++++++++++++++++++++++++++++++++++--------
>  mm/internal.h                 |   5 ++
>  mm/page_alloc.c               |  27 ++++++
>  mm/vmstat.c                   |   2 +
>  5 files changed, 191 insertions(+), 33 deletions(-)
> 
> -- 
> 2.7.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
