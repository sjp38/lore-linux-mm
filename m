Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8BC76B0262
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:55:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so13322128wme.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 02:55:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lq5si6047541wjb.151.2016.06.24.02.55.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 02:55:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 00/17] make direct compaction more deterministic
Date: Fri, 24 Jun 2016 11:54:20 +0200
Message-Id: <20160624095437.16385-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Changes since v2:

* Rebase on mmotm-2016-06-15-16-18 with Mel's node-based reclaim series dropped
  locally. Note there will be some small conflicts, but nothing substantial
  that should complicate readding Mel's series later and invalidate testing.
* Dropped patch 18 which was the only major conflict with Mel's series, which
  solves the same thing, and it wasn't that important in this series.
* The rebasing however required some major rewrite of patches 2 and 3 due to
  changes in mmotm, so I dropped the acks. Changes there should also address
  reviewers' concerns. E.g. ALLOC_NO_WATERMARKS is used in direct reclaim and
  compaction attempts after patch 3, as Joonsoo suggested.
* In patch 12, compaction retries are now only counted after reaching the final
  priority (suggested by Michal Hocko).

Changes since v1 RFC:

* Incorporate feedback from Michal, Joonsoo, Tetsuo
* Expanded cleanup of watermark checks controlling reclaim/compaction

This is mostly a followup to Michal's oom detection rework, which highlighted
the need for direct compaction to provide better feedback in reclaim/compaction
loop, so that it can reliably recognize when compaction cannot make further
progress, and allocation should invoke OOM killer or fail. We've discussed
this at LSF/MM [1] where I proposed expanding the async/sync migration mode
used in compaction to more general "priorities". This patchset adds one new
priority that just overrides all the heuristics and makes compaction fully
scan all zones. I don't currently think that we need more fine-grained
priorities, but we'll see. Other than that there's some smaller fixes and
cleanups, mainly related to the THP-specific hacks.

I've tested this with stress-highalloc in GFP_KERNEL order-4 and
GFP_HIGHUSER_MOVABLE order-9 scenarios. There's not much report but noise,
except reductions in direct reclaim.

order-9:

Direct pages scanned                238949       41502
Kswapd pages scanned               2069710     2229295
Kswapd pages reclaimed             1981047     2139089
Direct pages reclaimed              236534       41502

order-4:

Direct pages scanned                204214      110733
Kswapd pages scanned               2125221     2179180
Kswapd pages reclaimed             2027102     2098257
Direct pages reclaimed              194942      110695

Also Patch 1 describes reductions in page migration failures.

[1] https://lwn.net/Articles/684611/

Hugh Dickins (1):
  mm, compaction: don't isolate PageWriteback pages in
    MIGRATE_SYNC_LIGHT mode

Vlastimil Babka (16):
  mm, page_alloc: set alloc_flags only once in slowpath
  mm, page_alloc: don't retry initial attempt in slowpath
  mm, page_alloc: restructure direct compaction handling in slowpath
  mm, page_alloc: make THP-specific decisions more generic
  mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
  mm, compaction: introduce direct compaction priority
  mm, compaction: simplify contended compaction handling
  mm, compaction: make whole_zone flag ignore cached scanner positions
  mm, compaction: cleanup unused functions
  mm, compaction: add the ultimate direct compaction priority
  mm, compaction: more reliably increase direct compaction priority
  mm, compaction: use correct watermark when checking allocation success
  mm, compaction: create compact_gap wrapper
  mm, compaction: use proper alloc_flags in __compaction_suitable()
  mm, compaction: require only min watermarks for non-costly orders
  mm, vmscan: make compaction_ready() more accurate and readable

 include/linux/compaction.h        |  84 ++++++-------
 include/linux/gfp.h               |  14 ++-
 include/trace/events/compaction.h |  12 +-
 include/trace/events/mmflags.h    |   1 +
 mm/compaction.c                   | 186 +++++++++------------------
 mm/huge_memory.c                  |  29 +++--
 mm/internal.h                     |   7 +-
 mm/khugepaged.c                   |   2 +-
 mm/migrate.c                      |   2 +-
 mm/page_alloc.c                   | 258 ++++++++++++++++++--------------------
 mm/vmscan.c                       |  47 ++++---
 tools/perf/builtin-kmem.c         |   1 +
 12 files changed, 281 insertions(+), 362 deletions(-)

-- 
2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
