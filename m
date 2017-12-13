Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 417F26B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e128so902388wmg.1
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k62si19430edc.303.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [UNTESTED RFC PATCH 0/8] compaction scanners rework
Date: Wed, 13 Dec 2017 09:59:07 +0100
Message-Id: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hi,

I have been working on this in the past weeks, but probably won't have time to
finish and test properly this year. So here's an UNTESTED RFC for those brave
enough to test, and also for review comments. I've been focusing on 1-7, and
patch 8 is unchanged since the last posting,  so Mel's suggestions (wrt
fallbacks and scanning pageblock where we get the free page from) from are not
included yet.

For context, please see the recent threads [1] [2]. The main goal is to
eliminate the reported huge free scanner activity by replacing the scanner with
allocation from free lists. This has some dangers of excessive migrations as
described in Patch 8 commit log, so the earlier patches try to eliminate most
of them by making the migration scanner decide to actually migrate pages only
if it looks like it can succeed. This should be benefical even in the current
scheme.

[1] https://lkml.kernel.org/r/20171122143321.29501-1-hannes@cmpxchg.org
[2] https://lkml.kernel.org/r/0168732b-d53f-a1b8-6623-4e4e26b85c5d@suse.cz

Vlastimil Babka (8):
  mm, compaction: don't mark pageblocks unsuitable when not fully
    scanned
  mm, compaction: skip_on_failure only for MIGRATE_MOVABLE allocations
  mm, compaction: pass valid_page to isolate_migratepages_block
  mm, compaction: skip on isolation failure also in sync compaction
  mm, compaction: factor out checking if page can be isolated for
    migration
  mm, compaction: prescan before isolating in skip_on_failure mode
  mm, compaction: prescan all MIGRATE_MOVABLE pageblocks
  mm, compaction: replace free scanner with direct freelist allocation

 include/linux/vm_event_item.h |   2 +
 mm/compaction.c               | 311 ++++++++++++++++++++++++++++++++----------
 mm/internal.h                 |   3 +
 mm/page_alloc.c               |  71 ++++++++++
 mm/vmstat.c                   |   3 +
 5 files changed, 316 insertions(+), 74 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
