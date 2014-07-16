Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 204766B00A5
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:29 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so1376335wiv.1
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vq2si24052272wjc.89.2014.07.16.06.49.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:49:10 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 00/15] compaction: balancing overhead and success rates
Date: Wed, 16 Jul 2014 15:48:08 +0200
Message-Id: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Based on next-20140715.

After a while, here's a V4 of series tweaking memory compaction.

Additional evaluation was made with stress-highalloc configured to use
__GFP_NO_KSWAPD, which makes it look like a THP page fault, so it only does
async compaction and is more likely to abort. This led to different (mostly
better) results in patches 10, 11 and 15, which is according to expectation.

Major changes in V4:

- Patch 2 changed deferred compaction signalling to a new return value instead
  of boolean pointer (suggested by Joonsoo Kim)

- Patch 3 is a new small change to make compact_stall reporting more accurate.
  I did it separately instead of within patch 2, as that one can also change
  reported compact_stall for other reasons, so bisectability etc...

- Patch 5 (previously 4) is bigger than last time as according to the
  suggestions it has gone all way to make isolate_migratepages family of
  functions to be the same as isolate_freepages family. So there is now a
  separate isolate_migratepages_block() function, and redundant parameters
  were removed across both families of functions.

- Patch 6 is a new patch triggered by Naoya Horiguchi's suggestion. It further
  unifies the scanner families and removes a per-page page_zone check from
  the migration scanner.

- Patch 7 (previously 5) was, after some discussions with Minchan Kim, changed
  to affect only khugepaged. For that reason, the contention type is passed
  back all the way to __alloc_pages_slowpath() where the decisions to continue
  or abort are made. I also changed the enum to a simple int, as the enum
  definition would otherwise had to be included in more source files.
  Also there are now hopefully no remaining holes where need_sched() or fatal
  signal pending would not lead to immediate abort through all the layers of
  direct compaction.

- Patch 15 remains a RFC, as there are still some not fully clear consequences,
  and I need to measure whether not calling update_pageblock_skip() in the
  skip_on_failure mode is a good decision. It probably isn't, as not marking
  the pageblock as skipped and not updating cached pfn means pageblocks will
  be checked repeatedly. On the other hand, marking pageblock as unsuitable
  for compaction, even though it was not fully scanned to due skip_on_failure,
  means that a lower-order compaction could succeed, but won't try the
  pageblock. Sigh.
 
David Rientjes (2):
  mm: rename allocflags_to_migratetype for clarity
  mm, compaction: pass gfp mask to compact_control

Vlastimil Babka (13):
  mm, THP: don't hold mmap_sem in khugepaged when allocating THP
  mm, compaction: defer each zone individually instead of preferred zone
  mm, compaction: do not count compact_stall if all zones skipped
    compaction
  mm, compaction: do not recheck suitable_migration_target under lock
  mm, compaction: move pageblock checks up from
    isolate_migratepages_range()
  mm, compaction: reduce zone checking frequency in the migration
    scanner
  mm, compaction: khugepaged should not give up due to need_resched()
  mm, compaction: periodically drop lock and restore IRQs in scanners
  mm, compaction: skip rechecks when lock was already held
  mm, compaction: remember position within pageblock in free pages
    scanner
  mm, compaction: skip buddy pages by their order in the migrate scanner
  mm, compaction: try to capture the just-created high-order freepage
  mm, compaction: do not migrate pages when that cannot satisfy page
    fault allocation

 include/linux/compaction.h |  28 +-
 include/linux/gfp.h        |   2 +-
 mm/compaction.c            | 781 ++++++++++++++++++++++++++++++++-------------
 mm/huge_memory.c           |  20 +-
 mm/internal.h              |  28 +-
 mm/page_alloc.c            | 189 ++++++++---
 6 files changed, 752 insertions(+), 296 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
