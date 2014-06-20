Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 12EF76B0069
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:50:22 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so4023745wes.13
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:50:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey4si2862886wid.15.2014.06.20.08.50.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:50:15 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 00/13] compaction: balancing overhead and success rates
Date: Fri, 20 Jun 2014 17:49:30 +0200
Message-Id: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Based on next-20140620.

This is a v3 of a series (first with proper cover letter) that tries to work
simultaneously towards two mutually exclusive goals in memory compaction -
reducing overhead and improving success rates. It includes some cleanups and
more or less trivial (micro-)optimizations, hopefully more intelligent lock
contention management, and some preparation patches that finally result in
last two patches that should improve success rates and minimize work that
is not likely to result on successful allocation for a THP page fault.
There are 3 new patches since last posting, and many have been reworked.

Patch 1: a simple change that will make khugepaged not hold uselessly mmap_sem
(new)    during potentially long sync compaction. I saw more opportunities for
         improvement there, but that will be for another series. This is rather
         trivial but still can reduce latencies for m(un)map heavy workloads.

Patch 2: fine-grained per-zone deferred compaction management, which should
(new)    result in more accurate decisions when to compact a particular zone

Patch 3: A cleanup/micro-optimization. No change since v2.

Patch 4: Another cleanup/optimization. Surprisingly there's still low hanging
(new)    fruit in functionality that was changed quite recently. Anything that
         simplifies isolate_migratepages_range() is a good thing...

Patch 5: First step towards not relying on need_resched() to limit amount of
         work done by async compaction. Incorporated feedback since v2 and
         reworked how lock contention is reported when multiple zones are
         compacted, so that it's no longer accidental.

Patch 6: Prevent running for long time with IRQs disabled, and improve lock
         contention detection. Incorporated feedback from David.

Patch 7: Microoptimization made possible by patch 6. No changes since v2.

Patch 8: Reduce some useless rescanning in the free scanner. I made quite major
         changes based on feedback, so I rather not keep Reviewed-by (thanks
         Minchan and Zhang though).

Patch 9: Reduce some iterations in the migration scanner, and make Patch 13
         possible. Based on discussions with David, I made page_order_unsafe()
         a #define so there will be no doubts about inlining behavior.

Patch 10: Cleanup, from David, no changes.

Patch 11: Prerequisity for Patch 13, from David, no changes.

Patch 12: Improve compaction success rates by grabbing page freed by migration
          ASAP. Since v2, I've removed the impact on allocation fast paths per
          Minchan's feedback and changed the rules for when capture is allowed.

Patch 13: Minimize work done in page fault direct compaction (i.e. THP) that
(RFC)     would not lead to successful allocation. Move on to next cc->order
          aligned block of pages as soon as the scanner encounters a page that
          is not free and cannot be isolated for migration.
          Only change since v2 is some cleanup moved to Patch 4 where it fits
          better. Still a RFC because I see this patch making a difference
          in stress-highalloc setting that doesn't use __GFP_NO_KSWAPD so it
          shouldn't be affected. So there is either a bug or unforeseen
          side-effect.

The only thorough evaluation was done when based on pre-3.16-rc1 kernel,
with mmtests stress-highalloc benchmark allocating order-9 pages which did
not use __GFP_NO_KSWAPD. Patches 1,2,4 were not yet in the series. This is not
a benchmark where microoptimizations would be visible, and the settings mean
it uses sync compaction and should not benefit from Patch 13 (but it did which
is weird). It has however shown improvements in vmstat figures in patches 8, 9
and 12, as documented in the commit messages. I hope David can test if it fixes
his issues. Patch 1 was tested separately on another machine, as documented.
I'll run further tests with stress-highalloc settings that would mimic THP
page faults (i.e. __GFP_NO_KSWAPD).

David Rientjes (2):
  mm: rename allocflags_to_migratetype for clarity
  mm, compaction: pass gfp mask to compact_control

Vlastimil Babka (11):
  mm, THP: don't hold mmap_sem in khugepaged when allocating THP
  mm, compaction: defer each zone individually instead of preferred zone
  mm, compaction: do not recheck suitable_migration_target under lock
  mm, compaction: move pageblock checks up from
    isolate_migratepages_range()
  mm, compaction: report compaction as contended only due to lock
    contention
  mm, compaction: periodically drop lock and restore IRQs in scanners
  mm, compaction: skip rechecks when lock was already held
  mm, compaction: remember position within pageblock in free pages
    scanner
  mm, compaction: skip buddy pages by their order in the migrate scanner
  mm, compaction: try to capture the just-created high-order freepage
  mm, compaction: do not migrate pages when that cannot satisfy page
    fault allocation

 include/linux/compaction.h |  10 +-
 include/linux/gfp.h        |   2 +-
 mm/compaction.c            | 569 +++++++++++++++++++++++++++++++++------------
 mm/huge_memory.c           |  20 +-
 mm/internal.h              |  38 ++-
 mm/page_alloc.c            | 122 +++++++---
 6 files changed, 554 insertions(+), 207 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
