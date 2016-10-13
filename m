Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF2486B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so70804285pab.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:12 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id xn2si11092757pab.68.2016.10.13.01.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:12 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id qn10so4443184pac.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:12 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 0/5] Reduce fragmentation
Date: Thu, 13 Oct 2016 17:08:17 +0900
Message-Id: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

This is a patchset to reduce fragmentation. Patch 1 ~ 3 changes
allocation/free logic to reduce fragmentation. Patch 4 ~ 5 is
to manually control number of unmovable/reclaimable pageblock by user.
Usually user has more knowledge about their system and if the number of
unmovable/reclaimable pageblock is pre-defined properly, fragmentation
would be reduced a lot.

I found that this patchset reduce fragmentaion on my test.

System: 512 MB
Workload: Kernel build test (make -j12, 5 times)
Result: Number of mixed movable pageblock / Number of movable pageblock

Base: 50 / 205
Patch 1 ~ 3: 20 / 205
Patchset + 15% Pre-defined unmovable/reclaimable pageblock: 0 / 176

Note that I didn't test hard so I'm not sure if there is a side-effect
or not. If there is no disagreement, I will do more testing and repost
the patchset.

Johannes, this patchset would not help to find the root cause of
your regression but it would help to mitigate your symptom.

This patchset is based on next-20161006.

Thanks.

Joonsoo Kim (5):
  mm/page_alloc: always add freeing page at the tail of the buddy list
  mm/page_alloc: use smallest fallback page first in movable allocation
  mm/page_alloc: stop instantly reusing freed page
  mm/page_alloc: add fixed migratetype pageblock infrastructure
  mm/page_alloc: support fixed migratetype pageblock

 include/linux/mmzone.h          |   6 +-
 include/linux/pageblock-flags.h |   3 +-
 mm/page_alloc.c                 | 224 ++++++++++++++++++++++++++++++----------
 mm/vmstat.c                     |   7 +-
 4 files changed, 179 insertions(+), 61 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
