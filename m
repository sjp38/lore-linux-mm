Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id CDFB66B004D
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:11 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so7325746wgh.30
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dw1si19373502wib.88.2014.08.04.01.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 00/13] compaction: balancing overhead and success rates
Date: Mon,  4 Aug 2014 10:55:11 +0200
Message-Id: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Based on next-20140801.

The v6 of the series has been reduced of the page capture patch due to
relatively less review and concerns by Joonsoo. I'll do that as a new
series with some more variants being tested. Hopefully this will increase
the chance of the remaining patches being accepted.

Otherwise, there's new Acked-by's by DavidR and three patches were discussed
(apologies for messing up linux-mm CC in v5, but at least lkml was OK) and
changed as follows:

Patch 2: Joonsoo spotted (thanks!) that new value for COMPACT_SKIPPED changed
         outcome for callers of compaction_suitable() who treat the return
         value as bool. This is now fixed. Some of the comments in those
         callers have been also made more accurate. I also realized that the
         same problem would apply to the did_some_progress output parameter of
         __alloc_pages_direct_compact(), and to my surprise the caller does
         not check it anyway, although it's not obvious. Removed it completely
         to avoid further confusion.
         
         Joonsoo also wondered why defer_compaction() is needed when allocation
         fails in __alloc_pages_direct_compact(). Turns out it is needed until
         a mismatch in watermark checking is resolved in further series.
         Otherwise DMA zone wouldn't be properly deferred.

Patch 5: David spotted a stupid mistake in changelog (thanks!) and also
         wondered about some aspects of migration scanner that the patch
         has to touch. However they are not introduced by the patch and
         changing them should be done separate patches for bisectability
         concerns. And this series is already large enough.

Patch 6: David pointed out that pageblock_within_zone() isn't the best name
         for a function that returns a struct page* pointer and not a bool.
         Tried renaming to pageblock_pfn_to_page() which however doesn't
         say anything about the checks being made. Still better than an
         overly long name I guess.

Patch 7: David suggested some improvements, most importantly a better way to
         determine the "all zones lock contended" bit, and to use GFP_TRANSHUGE
         instead of plain __GFP_NO_KSWAPD to more accurately restrict the
         decisions to THP allocations only.

David Rientjes (2):
  mm: rename allocflags_to_migratetype for clarity
  mm, compaction: pass gfp mask to compact_control

Vlastimil Babka (11):
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

 include/linux/compaction.h |  24 +-
 include/linux/gfp.h        |   2 +-
 mm/compaction.c            | 651 ++++++++++++++++++++++++++++++---------------
 mm/huge_memory.c           |  20 +-
 mm/internal.h              |  26 +-
 mm/page_alloc.c            | 144 ++++++----
 mm/vmscan.c                |  14 +-
 7 files changed, 578 insertions(+), 303 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
