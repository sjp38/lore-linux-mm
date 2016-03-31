Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 78E096B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:51:02 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id 127so125838465wmu.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:51:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q17si10670061wjw.11.2016.03.31.01.51.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Mar 2016 01:51:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/4] reduce latency of direct async compaction
Date: Thu, 31 Mar 2016 10:50:32 +0200
Message-Id: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

The goal here is to reduce latency (and increase success) of direct async
compaction by making it focus more on the goal of creating a high-order page,
at some expense of thoroughness.

This is based on an older attempt [1] which I didn't finish as it seemed that
it increased longer-term fragmentation. Now it seems it doesn't, and we have
kcompactd for that goal. The main patch (3) makes migration scanner skip whole
order-aligned blocks as soon as isolation fails in them, as it takes just one
unmigrated page to prevent a high-order buddy page from fully merging.

Patch 4 then attempts to reduce the excessive freepage scanning (such as
reported in [2]) by allocating migration targets directly from freelists. Here
we just need to be sure that the free pages are not from the same block as the
migrated pages. This is also limited to direct async compaction and is not
meant to replace the more thorough free scanner for other scenarios.

[1] https://lkml.org/lkml/2014/7/16/988
[2] http://www.spinics.net/lists/linux-mm/msg97475.html

Testing was done using stress-highalloc from mmtests, configured for order-4
GFP_KERNEL allocations:

                              4.6-rc1               4.6-rc1               4.6-rc1
                               patch2                patch3                patch4
Success 1 Min         24.00 (  0.00%)       27.00 (-12.50%)       43.00 (-79.17%)
Success 1 Mean        30.20 (  0.00%)       31.60 ( -4.64%)       51.60 (-70.86%)
Success 1 Max         37.00 (  0.00%)       35.00 (  5.41%)       73.00 (-97.30%)
Success 2 Min         42.00 (  0.00%)       32.00 ( 23.81%)       73.00 (-73.81%)
Success 2 Mean        44.00 (  0.00%)       44.80 ( -1.82%)       78.00 (-77.27%)
Success 2 Max         48.00 (  0.00%)       52.00 ( -8.33%)       81.00 (-68.75%)
Success 3 Min         91.00 (  0.00%)       92.00 ( -1.10%)       88.00 (  3.30%)
Success 3 Mean        92.20 (  0.00%)       92.80 ( -0.65%)       91.00 (  1.30%)
Success 3 Max         94.00 (  0.00%)       93.00 (  1.06%)       94.00 (  0.00%)

While the eager skipping of unsuitable blocks from patch 3 didn't affect
success rates, direct freepage allocation did improve them.

             4.6-rc1     4.6-rc1     4.6-rc1
              patch2      patch3      patch4
User         2587.42     2566.53     2413.57
System        482.89      471.20      461.71
Elapsed      1395.68     1382.00     1392.87

Times are not so useful metric for this benchmark as main portion is the
interfering kernel builds, but results do hint at reduced system times.

                                   4.6-rc1     4.6-rc1     4.6-rc1
                                    patch2      patch3      patch4
Direct pages scanned                163614      159608      123385
Kswapd pages scanned               2070139     2078790     2081385
Kswapd pages reclaimed             2061707     2069757     2073723
Direct pages reclaimed              163354      159505      122304

Reduced direct reclaim was unintended, but could be explained by more
successful first attempt at (async) direct compaction, which is attempted
before the first reclaim attempt in __alloc_pages_slowpath().

Compaction stalls                    33052       39853       55091
Compaction success                   12121       19773       37875
Compaction failures                  20931       20079       17216

Compaction is indeed more successful, and thus less likely to get deferred,
so there are also more direct compaction stalls. 

Page migrate success               3781876     3326819     2790838
Page migrate failure                 45817       41774       38113
Compaction pages isolated          7868232     6941457     5025092
Compaction migrate scanned       168160492   127269354    87087993
Compaction migrate prescanned            0           0           0
Compaction free scanned         2522142582  2326342620   743205879
Compaction free direct alloc             0           0      920792
Compaction free dir. all. miss           0           0        5865
Compaction cost                       5252        4476        3602

Patch 2 reduces migration scanned pages by 25% thanks to the eager skipping.
Patch 3 reduces free scanned pages by 70%. The portion of direct allocation
misses to all direct allocations is less than 1% which should be acceptable.
Interestingly, patch 3 also reduces migration scanned pages by another 30% on
top of patch 2. The reason is not clear, but we can rejoice nevertheless.

Vlastimil Babka (4):
  mm, compaction: wrap calculating first and last pfn of pageblock
  mm, compaction: reduce spurious pcplist drains
  mm, compaction: skip blocks where isolation fails in async direct
    compaction
  mm, compaction: direct freepage allocation for async direct compaction

 include/linux/vm_event_item.h |   1 +
 mm/compaction.c               | 189 ++++++++++++++++++++++++++++++++++--------
 mm/internal.h                 |   5 ++
 mm/page_alloc.c               |  27 ++++++
 mm/vmstat.c                   |   2 +
 5 files changed, 191 insertions(+), 33 deletions(-)

-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
