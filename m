Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFCE8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 10:46:25 -0500 (EST)
Date: Wed, 9 Feb 2011 16:46:06 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110209154606.GJ27110@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I think this should fix the problem of processes getting stuck in
reclaim that has been reported several times.  Kent actually
single-stepped through this code and noted that it was never exiting
shrink_zone(), which really narrowed it down a lot, considering the
tons of nested loops from the allocator down to the list shrinking.

	Hannes

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: vmscan: fix zone shrinking exit when scan work is done

'3e7d344 mm: vmscan: reclaim order-0 and use compaction instead of
lumpy reclaim' introduced an indefinite loop in shrink_zone().

It meant to break out of this loop when no pages had been reclaimed
and not a single page was even scanned.  The way it would detect the
latter is by taking a snapshot of sc->nr_scanned at the beginning of
the function and comparing it against the new sc->nr_scanned after the
scan loop.  But it would re-iterate without updating that snapshot,
looping forever if sc->nr_scanned changed at least once since
shrink_zone() was invoked.

This is not the sole condition that would exit that loop, but it
requires other processes to change the zone state, as the reclaimer
that is stuck obviously can not anymore.

This is only happening for higher-order allocations, where reclaim is
run back to back with compaction.

Reported-by: Michal Hocko <mhocko@suse.cz>
Reported-by: Kent Overstreet <kent.overstreet@gmail.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 148c6e6..17497d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1882,12 +1882,12 @@ static void shrink_zone(int priority, struct zone *zone,
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list l;
-	unsigned long nr_reclaimed;
+	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
-	unsigned long nr_scanned = sc->nr_scanned;
 
 restart:
 	nr_reclaimed = 0;
+	nr_scanned = sc->nr_scanned;
 	get_scan_count(zone, sc, nr, priority);
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
