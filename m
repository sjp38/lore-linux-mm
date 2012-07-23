Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id A695A6B0074
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 24/34] mm: vmscan: Do not OOM if aborting reclaim to start compaction
Date: Mon, 23 Jul 2012 14:38:37 +0100
Message-Id: <1343050727-3045-25-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit 7335084d446b83cbcb15da80497d03f0c1dc9e21 upstream.

Stable note: Not tracked in Bugzilla. This patch makes later patches
	easier to apply but otherwise has little to justify it. The
	problem it fixes was never observed but the source of the
	theoretical problem did not exist for very long.

When direct reclaim is entered is is possible that reclaim will be
aborted so that compaction can be attempted to satisfy a high-order
allocation.  If this decision is made before any pages are reclaimed,
it is possible for 0 to be returned to the page allocator potentially
triggering an OOM. This has not been observed but it is a possibility
so this patch addresses it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e85abfd..f109f2d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2240,6 +2240,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
+	bool should_abort_reclaim;
 
 	get_mems_allowed();
 	delayacct_freepages_start();
@@ -2251,7 +2252,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token(sc->mem_cgroup);
-		if (shrink_zones(priority, zonelist, sc))
+		should_abort_reclaim = shrink_zones(priority, zonelist, sc);
+		if (should_abort_reclaim)
 			break;
 
 		/*
@@ -2318,6 +2320,10 @@ out:
 	if (oom_killer_disabled)
 		return 0;
 
+	/* Aborting reclaim to try compaction? don't OOM, then */
+	if (should_abort_reclaim)
+		return 1;
+
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
