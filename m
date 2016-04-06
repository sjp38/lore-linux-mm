Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 242106B027F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:24:12 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 191so54416596wmq.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:24:12 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id m9si2676399wjx.242.2016.04.06.04.24.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:24:11 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id BD621210047
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:24:10 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 27/27] mm: vmstat: Account per-zone stalls and pages skipped during reclaim
Date: Wed,  6 Apr 2016 12:22:16 +0100
Message-Id: <1459941736-3633-28-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
References: <1459941736-3633-23-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The vmstat allocstall was fairly useful in the general sense but
node-based LRUs change that. It's important to know if a stall was for an
address-limited allocation request as this will require skipping pages from
other zones. This patch adds pgstall_* counters to replace allocstall. The
sum of the counters will equal the old allocstall so it can be trivially
recalculated. A high number of address-limited allocation requests may
result in a lot of useless LRU scanning for suitable pages.

As address-limited allocations require pages to be skipped, it's important
to know how much useless LRU scanning took place so this patch adds
pgskip* counters. This yields the following model

1. The number of address-space limited stalls can be accounted for (pgstall)
2. The amount of useless work required to reclaim the data is accounted (pgskip)
3. The total number of scans is available from pgscan_kswapd and pgscan_direct
   so from that the ratio of useful to useless scans can be calculated.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/vm_event_item.h |  4 +++-
 mm/vmscan.c                   | 15 +++++++++++++--
 mm/vmstat.c                   |  3 ++-
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 8dcb5a813163..0a0503da8c3b 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -23,6 +23,8 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
+		FOR_ALL_ZONES(PGSTALL),
+		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
@@ -37,7 +39,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+		PAGEOUTRUN, PGROTATED,
 		DROP_PAGECACHE, DROP_SLAB,
 #ifdef CONFIG_NUMA_BALANCING
 		NUMA_PTE_UPDATES,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 522378c9849a..d7d664324442 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1372,6 +1372,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	struct list_head *src = &lruvec->lists[lru];
 	unsigned long nr_taken = 0;
 	unsigned long scan;
+	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
@@ -1386,6 +1387,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
+			nr_skipped[page_zonenum(page)]++;
 			continue;
 		}
 
@@ -1414,8 +1416,17 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 * scanning would soon rescan the same pages to skip and put the
 	 * system at risk of premature OOM.
 	 */
-	if (!list_empty(&pages_skipped))
+	if (!list_empty(&pages_skipped)) {
+		int zid;
+
 		list_splice(&pages_skipped, src);
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			if (!nr_skipped[zid])
+				continue;
+
+			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
+		}
+	}
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
@@ -2686,7 +2697,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
-		count_vm_event(ALLOCSTALL);
+		__count_zid_vm_events(PGSTALL, classzone_idx, 1);
 
 	do {
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2de1f3790548..ee1fb1242c59 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -992,6 +992,8 @@ const char * const vmstat_text[] = {
 	"pswpout",
 
 	TEXTS_FOR_ZONES("pgalloc")
+	TEXTS_FOR_ZONES("pgstall")
+	TEXTS_FOR_ZONES("pgskip")
 
 	"pgfree",
 	"pgactivate",
@@ -1017,7 +1019,6 @@ const char * const vmstat_text[] = {
 	"kswapd_low_wmark_hit_quickly",
 	"kswapd_high_wmark_hit_quickly",
 	"pageoutrun",
-	"allocstall",
 
 	"pgrotated",
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
