Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7EE6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r18so12931459wmd.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si2008518wma.39.2017.02.10.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 00/10] try to reduce fragmenting fallbacks
Date: Fri, 10 Feb 2017 18:23:33 +0100
Message-Id: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

Hi,

this is a v2 of [1] from last year, which was a response to Johanes' worries
about mobility grouping regressions. There are some new patches and the order
goes from cleanups to "obvious wins" towards "just RFC" (last two patches).
But it's all theoretical for now, I'm trying to run some tests with the usual
problem of not having good workloads and metrics :) But I'd like to hear some
feedback anyway. For now this is based on v4.9.

I think the only substantial new patch is 08/10, the rest is some cleanups,
small tweaks and bugfixes.

[1] https://www.spinics.net/lists/linux-mm/msg114380.html

Vlastimil Babka (10):
  mm, compaction: reorder fields in struct compact_control
  mm, compaction: remove redundant watermark check in compact_finished()
  mm, page_alloc: split smallest stolen page in fallback
  mm, page_alloc: count movable pages when stealing from pageblock
  mm, compaction: change migrate_async_suitable() to
    suitable_migration_source()
  mm, compaction: add migratetype to compact_control
  mm, compaction: restrict async compaction to pageblocks of same
    migratetype
  mm, compaction: finish whole pageblock to reduce fragmentation
  mm, page_alloc: disallow migratetype fallback in fastpath
  mm, page_alloc: introduce MIGRATE_MIXED migratetype

 include/linux/mmzone.h         |   6 ++
 include/linux/page-isolation.h |   5 +-
 mm/compaction.c                | 116 +++++++++++++++++-------
 mm/internal.h                  |  14 +--
 mm/page_alloc.c                | 196 +++++++++++++++++++++++++++++------------
 mm/page_isolation.c            |   5 +-
 6 files changed, 246 insertions(+), 96 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
