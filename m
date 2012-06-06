Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C0A7E6B00B7
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 14:24:13 -0400 (EDT)
Received: by eekd41 with SMTP id d41so438122eek.2
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 11:24:12 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 5/5] mm: memcg discount pages under softlimit from per-zone reclaimable_pages
Date: Wed,  6 Jun 2012 11:24:11 -0700
Message-Id: <1339007051-10672-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

The function zone_reclaimable() marks zone->all_unreclaimable based on
per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is true,
alloc_pages could go to OOM instead of getting stuck in page reclaim.

In memcg kernel, cgroup under its softlimit is not targeted under global
reclaim. So we need to remove those pages from reclaimable_pages, otherwise
it will cause reclaim mechanism to get stuck trying to reclaim from
all_unreclaimable zone.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65febc1..163b197 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3142,14 +3142,26 @@ unsigned long global_reclaimable_pages(void)
 
 unsigned long zone_reclaimable_pages(struct zone *zone)
 {
-	int nr;
+	int nr = 0;
+	struct mem_cgroup *memcg;
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+	memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct mem_cgroup_zone mz = {
+			.mem_cgroup = memcg,
+			.zone = zone,
+		};
 
-	if (nr_swap_pages > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+		if (should_reclaim_mem_cgroup(memcg)) {
+			nr += zone_nr_lru_pages(&mz, LRU_INACTIVE_FILE) +
+			      zone_nr_lru_pages(&mz, LRU_ACTIVE_FILE);
+
+			if (nr_swap_pages > 0)
+				nr += zone_nr_lru_pages(&mz, LRU_ACTIVE_ANON) +
+				      zone_nr_lru_pages(&mz, LRU_INACTIVE_ANON);
+		}
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
 
 	return nr;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
