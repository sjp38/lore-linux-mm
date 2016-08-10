Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92EE7828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so52868691wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si7155987wmh.11.2016.08.10.02.12.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 00/11] make direct compaction more deterministic
Date: Wed, 10 Aug 2016 11:12:15 +0200
Message-Id: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Changes since v3
* The first part with cleanups (v4, v5) went separately to 4.8-rc1
* Rebased to 4.8-rc1
* Patch 1 - don't touch cached pfns in whole-zone compaction (Joonsoo)
* New patches 2 and 3 in response to Joonsoo pointing out missing adustments
  to watermark checks in patch 7 - turns out we can remove those watermark
  checks altogether.
* Patch 6 made less aggressive to avoid premature OOM (Joonsoo)

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
THP-like order-9 scenarios. There's some improvement for compaction stats
for the order-4, which is likely due to the better watermarks handling.
In the previous version I reported mostly noise wrt compaction stats, and
decreased direct reclaim - now the reclaim is without difference. I believe
this is due to the less aggressive compaction priority increase in patch 6.

"before" is a mmotm tree prior to 4.7 release plus the first part of the
series that was sent and merged separately

                                    before        after
order-4:

Compaction stalls                    27216       30759
Compaction success                   19598       25475
Compaction failures                   7617        5283
Page migrate success                370510      464919
Page migrate failure                 25712       27987
Compaction pages isolated           849601     1041581
Compaction migrate scanned       143146541   101084990
Compaction free scanned          208355124   144863510
Compaction cost                       1403        1210

order-9:

Compaction stalls                     7311        7401
Compaction success                    1634        1683
Compaction failures                   5677        5718
Page migrate success                194657      183988
Page migrate failure                  4753        4170
Compaction pages isolated           498790      456130
Compaction migrate scanned          565371      524174
Compaction free scanned            4230296     4250744
Compaction cost                        215         203

[1] https://lwn.net/Articles/684611/

Vlastimil Babka (11):
  mm, compaction: make whole_zone flag ignore cached scanner positions
  mm, compaction: cleanup unused functions
  mm, compaction: rename COMPACT_PARTIAL to COMPACT_SUCCESS
  mm, compaction: don't recheck watermarks after COMPACT_SUCCESS
  mm, compaction: add the ultimate direct compaction priority
  mm, compaction: more reliably increase direct compaction priority
  mm, compaction: use correct watermark when checking compaction success
  mm, compaction: create compact_gap wrapper
  mm, compaction: use proper alloc_flags in __compaction_suitable()
  mm, compaction: require only min watermarks for non-costly orders
  mm, vmscan: make compaction_ready() more accurate and readable

 include/linux/compaction.h        |  32 +++++---
 include/trace/events/compaction.h |   2 +-
 mm/compaction.c                   | 154 +++++++++++++++++---------------------
 mm/internal.h                     |   2 +-
 mm/page_alloc.c                   |  22 +++---
 mm/vmscan.c                       |  49 ++++++------
 6 files changed, 128 insertions(+), 133 deletions(-)

-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
