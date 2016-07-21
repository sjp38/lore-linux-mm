Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 803A56B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:11:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so14134689wma.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:11:04 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id x8si3750369wme.6.2016.07.21.07.11.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 07:11:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id A3EBD990AF
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 14:11:02 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Candidate fixes for premature OOM kills with node-lru v2
Date: Thu, 21 Jul 2016 15:10:56 +0100
Message-Id: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Both Joonsoo Kim and Minchan Kim have reported premature OOM kills.
The common element is a zone-constrained allocation failings. Two factors
appear to be at fault -- pgdat being considered unreclaimable prematurely
and insufficient rotation of the active list.

The series is in three basic parts;

Patches 1-3 add per-zone stats back in. The actual stats patch is different
	to Minchan's as the original patch did not account for unevictable
	LRU which would corrupt counters. The second two patches remove
	approximations based on pgdat statistics. It's effectively a
	revert of "mm, vmstat: remove zone and node double accounting
	by approximating retries" but different LRU stats are used. This
	is better than a full revert or a reworking of the series as it
	preserves history of why the zone stats are necessary.

	If this work out, we may have to leave the double accounting in
	place for now until an alternative cheap solution presents itself.

Patch 4 rotates inactive/active lists for lowmem allocations. This is also
	quite different to Minchan's patch as the original patch did not
	account for memcg and would rotate if *any* eligible zone needed
	rotation which may rotate excessively. The new patch considers the
	ratio for all eligible zones which is more in line with node-lru
	in general.

Patch 5 accounts for skipped pages as partial scanned. This avoids the pgdat
	being prematurely marked unreclaimable while still allowing it to
	be marked unreclaimable if there are no reclaimable pages.

These patches did not OOM for me on a 2G 32-bit KVM instance while running
a stress test for an hour. Preliminary tests on a 64-bit system using a
parallel dd workload did not show anything alarming.

If an OOM is detected then please post the full OOM message.

Optionally please test without patch 5 if an OOM occurs.

 include/linux/mm_inline.h | 19 ++---------
 include/linux/mmzone.h    |  7 ++++
 include/linux/swap.h      |  1 +
 mm/compaction.c           | 20 +----------
 mm/migrate.c              |  2 ++
 mm/page-writeback.c       | 17 +++++-----
 mm/page_alloc.c           | 59 +++++++++++----------------------
 mm/vmscan.c               | 84 ++++++++++++++++++++++++++++++++++++++---------
 mm/vmstat.c               |  6 ++++
 9 files changed, 116 insertions(+), 99 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
