Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 832856B025F
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:08:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so99077074lbc.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:08:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ka3si50535985wjb.136.2016.05.31.06.08.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:34 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 00/18] make direct compaction more deterministic
Date: Tue, 31 May 2016 15:08:00 +0200
Message-Id: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

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

Changes since v1 RFC:

* Incorporate feedback from Michal, Joonsoo, Tetsuo
* Expanded cleanup of watermark checks controlling reclaim/compaction

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

The series is based on 4.7-rc1.

[1] https://lwn.net/Articles/684611/

Hugh Dickins (1):
  mm, compaction: don't isolate PageWriteback pages in
    MIGRATE_SYNC_LIGHT mode

Vlastimil Babka (17):
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
  mm, vmscan: use proper classzone_idx in should_continue_reclaim()

 include/linux/compaction.h        | 101 +++++-----------
 include/linux/gfp.h               |  14 ++-
 include/trace/events/compaction.h |  12 +-
 include/trace/events/mmflags.h    |   1 +
 mm/compaction.c                   | 186 ++++++++++-------------------
 mm/huge_memory.c                  |  27 +++--
 mm/internal.h                     |   7 +-
 mm/migrate.c                      |   2 +-
 mm/page_alloc.c                   | 241 ++++++++++++++++++--------------------
 mm/vmscan.c                       |  80 +++++--------
 tools/perf/builtin-kmem.c         |   1 +
 11 files changed, 271 insertions(+), 401 deletions(-)

-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
