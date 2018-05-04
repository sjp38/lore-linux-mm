Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7045D6B0011
	for <linux-mm@kvack.org>; Fri,  4 May 2018 00:30:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y12so8476386pfe.8
        for <linux-mm@kvack.org>; Thu, 03 May 2018 21:30:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor2446711plt.70.2018.05.03.21.30.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 21:30:56 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
Date: Fri,  4 May 2018 13:30:46 +0900
Message-Id: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we use the zone index of preferred_zone which represents
the best matching zone for allocation, as classzone_idx. It has a problem
on NUMA system with ZONE_MOVABLE.

In NUMA system, it can be possible that each node has different populated
zones. For example, node 0 could have DMA/DMA32/NORMAL/MOVABLE zone and
node 1 could have only NORMAL zone. In this setup, allocation request
initiated on node 0 and the one on node 1 would have different
classzone_idx, 3 and 2, respectively, since their preferred_zones are
different. If they are handled by only their own node, there is no problem.
However, if they are somtimes handled by the remote node, the problem
would happen.

In the following setup, allocation initiated on node 1 will have some
precedence than allocation initiated on node 0 when former allocation is
processed on node 0 due to not enough memory on node 1. They will have
different lowmem reserve due to their different classzone_idx thus
an watermark bars are also different.

root@ubuntu:/sys/devices/system/memory# cat /proc/zoneinfo
Node 0, zone      DMA
  per-node stats
...
  pages free     3965
        min      5
        low      8
        high     11
        spanned  4095
        present  3998
        managed  3977
        protection: (0, 2961, 4928, 5440)
...
Node 0, zone    DMA32
  pages free     757955
        min      1129
        low      1887
        high     2645
        spanned  1044480
        present  782303
        managed  758116
        protection: (0, 0, 1967, 2479)
...
Node 0, zone   Normal
  pages free     459806
        min      750
        low      1253
        high     1756
        spanned  524288
        present  524288
        managed  503620
        protection: (0, 0, 0, 4096)
...
Node 0, zone  Movable
  pages free     130759
        min      195
        low      326
        high     457
        spanned  1966079
        present  131072
        managed  131072
        protection: (0, 0, 0, 0)
...
Node 1, zone      DMA
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 1006, 1006)
Node 1, zone    DMA32
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 1006, 1006)
Node 1, zone   Normal
  per-node stats
...
  pages free     233277
        min      383
        low      640
        high     897
        spanned  262144
        present  262144
        managed  257744
        protection: (0, 0, 0, 0)
...
Node 1, zone  Movable
  pages free     0
        min      0
        low      0
        high     0
        spanned  262144
        present  0
        managed  0
        protection: (0, 0, 0, 0)

min watermark for NORMAL zone on node 0
allocation initiated on node 0: 750 + 4096 = 4846
allocation initiated on node 1: 750 + 0 = 750

This watermark difference could cause too many numa_miss allocation
in some situation and then performance could be downgraded.

Recently, there was a regression report about this problem on CMA patches
since CMA memory are placed in ZONE_MOVABLE by those patches. I checked
that problem is disappeared with this fix that uses high_zoneidx
for classzone_idx.

http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop

Using high_zoneidx for classzone_idx is more consistent way than previous
approach because system's memory layout doesn't affect anything to it.
With this patch, both classzone_idx on above example will be 3 so will
have the same min watermark.

allocation initiated on node 0: 750 + 4096 = 4846
allocation initiated on node 1: 750 + 4096 = 4846

Reported-by: Ye Xiaolong <xiaolong.ye@intel.com>
Tested-by: Ye Xiaolong <xiaolong.ye@intel.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/internal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/internal.h b/mm/internal.h
index 228dd66..e1d7376 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -123,7 +123,7 @@ struct alloc_context {
 	bool spread_dirty_pages;
 };
 
-#define ac_classzone_idx(ac) zonelist_zone_idx(ac->preferred_zoneref)
+#define ac_classzone_idx(ac) (ac->high_zoneidx)
 
 /*
  * Locate the struct page for both the matching buddy in our
-- 
2.7.4
