Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA566B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so9373733wmu.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:13 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e1si3985580wrd.138.2017.02.28.13.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:12 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/9] mm: kswapd spinning on unreclaimable nodes - fixes and cleanups
Date: Tue, 28 Feb 2017 16:39:58 -0500
Message-Id: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

Jia reported a scenario in which the kswapd of a node indefinitely
spins at 100% CPU usage. We have seen similar cases at Facebook.

The kernel's current method of judging its ability to reclaim a node
(or whether to back off and sleep) is based on the amount of scanned
pages in proportion to the amount of reclaimable pages. In Jia's and
our scenarios, there are no reclaimable pages in the node, however,
and the condition for backing off is never met. Kswapd busyloops in an
attempt to restore the watermarks while having nothing to work with.

This series reworks the definition of an unreclaimable node based not
on scanning but on whether kswapd is able to actually reclaim pages in
MAX_RECLAIM_RETRIES (16) consecutive runs. This is the same criteria
the page allocator uses for giving up on direct reclaim and invoking
the OOM killer. If it cannot free any pages, kswapd will go to sleep
and leave further attempts to direct reclaim invocations, which will
either make progress and re-enable kswapd, or invoke the OOM killer.

Patch #1 fixes the immediate problem Jia reported, the remainder are
smaller fixlets, cleanups, and overall phasing out of the old method.

Patch #6 is the odd one out. It's a nice cleanup to get_scan_count(),
and directly related to #5, but in itself not relevant to the series.

If the whole series is too ambitious for 4.11, I would consider the
first three patches fixes, the rest cleanups.

Thanks

 include/linux/mmzone.h |   3 +-
 mm/internal.h          |   7 +-
 mm/migrate.c           |   3 -
 mm/page_alloc.c        |  39 +++--------
 mm/vmscan.c            | 169 ++++++++++++++++++-----------------------------
 mm/vmstat.c            |  24 ++-----
 6 files changed, 89 insertions(+), 156 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
