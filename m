Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 829D56B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:35 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so601998wes.16
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sd12si1752965wjb.172.2014.02.28.06.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:33 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/6] close pageblock_migratetype and pageblock_skip races
Date: Fri, 28 Feb 2014 15:14:58 +0100
Message-Id: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

this series follows on the discussions of Joonsoo Kim's series
"improve robustness on handling migratetype" https://lkml.org/lkml/2014/1/9/29
The goal is to close the race of get/set_pageblock_migratetype (and _skip)
which Joonsoo found in the code and I've observed in my further compaction
series development.

Instead of a new seqlock for the pageblock bitmap, my series extends the
coverage of zone->lock where possible (patch 1) and deals with the races where
it's not feasible to lock (patches 2-4), as suggested by Mel in the original
thread.

Testing of patches 1-4 made me realize that a race between setting migratetype
and set/clear_pageblock_skip is also an issue because all the 4 bits are packed
within the same byte for each pair of pageblocks and the bit operations are not
atomic. Thus and update to the skip bit may lose racing updates to some bits
comprising migratetype and break it. Patch 5 reduces the amount of unneeded
set_pageblock_skip calls, and patch 6 fixes the race by making the bit
operations atomic, including reasons for picking this solution instead of
using zone->lock also for set_pageblock_skip().

Vlastimil

Vlastimil Babka (6):
  mm: call get_pageblock_migratetype() under zone->lock where possible
  mm: add get_pageblock_migratetype_nolock() for cases where locking is
    undesirable
  mm: add is_migrate_isolate_page_nolock() for cases where locking is
    undesirable
  mm: add set_pageblock_migratetype_nolock() for calls outside
    zone->lock
  mm: compaction: do not set pageblock skip bit when already set
  mm: use atomic bit operations in set_pageblock_flags_group()

 include/linux/mmzone.h         | 24 +++++++++++++++
 include/linux/page-isolation.h | 24 +++++++++++++++
 mm/compaction.c                | 18 ++++++++---
 mm/hugetlb.c                   |  2 +-
 mm/memory-failure.c            |  3 +-
 mm/page_alloc.c                | 69 ++++++++++++++++++++++++++++--------------
 mm/page_isolation.c            | 23 ++++++++------
 mm/vmstat.c                    |  2 +-
 8 files changed, 126 insertions(+), 39 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
