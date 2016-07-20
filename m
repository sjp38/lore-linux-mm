Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C30E6B0253
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 11:21:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so34637750wmp.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:21:54 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id rj10si1355453wjb.163.2016.07.20.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 08:21:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id AE2341C138D
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:21:51 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Candidate fixes for premature OOM kills with node-lru v1
Date: Wed, 20 Jul 2016 16:21:46 +0100
Message-Id: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Both Joonsoo Kim and Minchan Kim have reported premature OOM kills on
a 32-bit platform. The common element is a zone-constrained high-order
allocation failing. Two factors appear to be at fault -- pgdat being
considered unreclaimable prematurely and insufficient rotation of the
active list.

Unfortunately to date I have been unable to reproduce this with a variety
of stress workloads on a 2G 32-bit KVM instance. It's not clear why as
the steps are similar to what was described. It means I've been unable to
determine if this series addresses the problem or not. I'm hoping they can
test and report back before these are merged to mmotm. What I have checked
is that a basic parallel DD workload completed successfully on the same
machine I used for the node-lru performance tests. I'll leave the other
tests running just in case anything interesting falls out.

The series is in three basic parts;

Patch 1 does not account for skipped pages as scanned. This avoids the pgdat
	being prematurely marked unreclaimable

Patches 2-4 add per-zone stats back in. The actual stats patch is different
	to Minchan's as the original patch did not account for unevictable
	LRU which would corrupt counters. The second two patches remove
	approximations based on pgdat statistics. It's effectively a
	revert of "mm, vmstat: remove zone and node double accounting by
	approximating retries" but different LRU stats are used. This
	is better than a full revert or a reworking of the series as
	it preserves history of why the zone stats are necessary.

	If this work out, we may have to leave the double accounting in
	place for now until an alternative cheap solution presents itself.

Patch 5 rotates inactive/active lists for lowmem allocations. This is also
	quite different to Minchan's patch as the original patch did not
	account for memcg and would rotate if *any* eligible zone needed
	rotation which may rotate excessively. The new patch considers
	the ratio for all eligible zones which is more in line with
	node-lru in general.

 include/linux/mm_inline.h | 19 ++-------------
 include/linux/mmzone.h    |  7 ++++++
 include/linux/swap.h      |  1 +
 mm/compaction.c           | 20 +---------------
 mm/migrate.c              |  2 ++
 mm/page-writeback.c       | 17 +++++++-------
 mm/page_alloc.c           | 59 ++++++++++++++++------------------------------
 mm/vmscan.c               | 60 ++++++++++++++++++++++++++++++++++++++++++-----
 mm/vmstat.c               |  6 +++++
 9 files changed, 102 insertions(+), 89 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
