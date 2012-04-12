Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 4DCEA6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 14:03:04 -0400 (EDT)
Received: by qafk30 with SMTP id k30so300841qaf.2
        for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:03:03 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] mm: fix up the vmscan stat in vmstat
Date: Thu, 12 Apr 2012 11:03:02 -0700
Message-Id: <1334253782-22755-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

It is always confusing on stat "pgsteal" where it counts both direct
reclaim as well as background reclaim. However, we have "kswapd_steal"
which also counts background reclaim value.

This patch fixes it and also makes it match the existng "pgscan_" stats.

Test:
pgsteal_kswapd_dma32 447623
pgsteal_kswapd_normal 42272677
pgsteal_kswapd_movable 0
pgsteal_direct_dma32 2801
pgsteal_direct_normal 44353270
pgsteal_direct_movable 0

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/vm_event_item.h |    5 +++--
 mm/vmscan.c                   |   11 ++++++++---
 mm/vmstat.c                   |    4 ++--
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 03b90cdc..06f8e38 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -26,13 +26,14 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		FOR_ALL_ZONES(PGREFILL),
-		FOR_ALL_ZONES(PGSTEAL),
+		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
+		FOR_ALL_ZONES(PGSTEAL_DIRECT),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
 		FOR_ALL_ZONES(PGSCAN_DIRECT),
 #ifdef CONFIG_NUMA
 		PGSCAN_ZONE_RECLAIM_FAILED,
 #endif
-		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
+		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33c332b..078c9fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1568,9 +1568,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	reclaim_stat->recent_scanned[0] += nr_anon;
 	reclaim_stat->recent_scanned[1] += nr_file;
 
-	if (current_is_kswapd())
-		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
-	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+	if (global_reclaim(sc)) {
+		if (current_is_kswapd())
+			__count_zone_vm_events(PGSTEAL_KSWAPD, zone,
+					       nr_reclaimed);
+		else
+			__count_zone_vm_events(PGSTEAL_DIRECT, zone,
+					       nr_reclaimed);
+	}
 
 	putback_inactive_pages(mz, &page_list);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f600557..7db1b9b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -738,7 +738,8 @@ const char * const vmstat_text[] = {
 	"pgmajfault",
 
 	TEXTS_FOR_ZONES("pgrefill")
-	TEXTS_FOR_ZONES("pgsteal")
+	TEXTS_FOR_ZONES("pgsteal_kswapd")
+	TEXTS_FOR_ZONES("pgsteal_direct")
 	TEXTS_FOR_ZONES("pgscan_kswapd")
 	TEXTS_FOR_ZONES("pgscan_direct")
 
@@ -747,7 +748,6 @@ const char * const vmstat_text[] = {
 #endif
 	"pginodesteal",
 	"slabs_scanned",
-	"kswapd_steal",
 	"kswapd_inodesteal",
 	"kswapd_low_wmark_hit_quickly",
 	"kswapd_high_wmark_hit_quickly",
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
