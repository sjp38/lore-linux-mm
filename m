Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 33865828E1
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:36:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so7067237wme.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:36:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eq16si4535913wjc.86.2016.07.21.00.36.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 00:36:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/8] compaction-related cleanups v5
Date: Thu, 21 Jul 2016 09:36:06 +0200
Message-Id: <20160721073614.24395-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Changes since v4:
- Patch 4 - skip initial compaction when allowed to ignore watermarks (DavidR)
- Rebased to mmotm-2016-07-18-16-40-20
- Acks by Mel Gorman, Michal Hocko, David Rientjes - Thanks!

Hi,

this is the splitted-off first part of my "make direct compaction more
deterministic" series [1], rebased on mmotm-2016-07-13-16-09-18. For the whole
series it's probably too late for 4.8 given some unresolved feedback, but I
hope this part could go in as it was stable for quite some time.

At the very least, the first patch really shouldn't wait any longer.

[1] http://marc.info/?l=linux-mm&m=146676211226806&w=2

Hugh Dickins (1):
  mm, compaction: don't isolate PageWriteback pages in
    MIGRATE_SYNC_LIGHT mode

Vlastimil Babka (7):
  mm, page_alloc: set alloc_flags only once in slowpath
  mm, page_alloc: don't retry initial attempt in slowpath
  mm, page_alloc: restructure direct compaction handling in slowpath
  mm, page_alloc: make THP-specific decisions more generic
  mm, thp: remove __GFP_NORETRY from khugepaged and madvised allocations
  mm, compaction: introduce direct compaction priority
  mm, compaction: simplify contended compaction handling

 include/linux/compaction.h        |  33 +++---
 include/linux/gfp.h               |  14 +--
 include/trace/events/compaction.h |  12 +--
 include/trace/events/mmflags.h    |   1 +
 mm/compaction.c                   |  83 ++++-----------
 mm/huge_memory.c                  |  29 ++---
 mm/internal.h                     |   5 +-
 mm/khugepaged.c                   |   2 +-
 mm/migrate.c                      |   2 +-
 mm/page_alloc.c                   | 218 +++++++++++++++++---------------------
 tools/perf/builtin-kmem.c         |   1 +
 11 files changed, 167 insertions(+), 233 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
