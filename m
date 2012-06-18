Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6FF4F6B0071
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:47:34 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so311786wgb.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 09:47:32 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V5 5/5] mm: memcg discount pages under softlimit from per-zone reclaimable_pages
Date: Mon, 18 Jun 2012 09:47:31 -0700
Message-Id: <1340038051-29502-5-git-send-email-yinghan@google.com>
In-Reply-To: <1340038051-29502-1-git-send-email-yinghan@google.com>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
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
 include/linux/mm_inline.h |   32 +++++++++++++++++++++++++-------
 mm/vmscan.c               |    8 --------
 2 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 5cb796c..521a498 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -100,18 +100,36 @@ static __always_inline enum lru_list page_lru(struct page *page)
 	return lru;
 }
 
+static inline unsigned long get_lru_size(struct lruvec *lruvec,
+					 enum lru_list lru)
+{
+	if (!mem_cgroup_disabled())
+		return mem_cgroup_get_lru_size(lruvec, lru);
+
+	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
+}
+
 static inline unsigned long zone_reclaimable_pages(struct zone *zone)
 {
-	int nr;
+	int nr = 0;
+	struct mem_cgroup *memcg;
+
+	memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	do {
+		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+		if (should_reclaim_mem_cgroup(memcg)) {
+			nr += get_lru_size(lruvec, LRU_INACTIVE_FILE) +
+			      get_lru_size(lruvec, LRU_ACTIVE_FILE);
 
-	if (nr_swap_pages > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+			if (nr_swap_pages > 0)
+				nr += get_lru_size(lruvec, LRU_ACTIVE_ANON) +
+				      get_lru_size(lruvec, LRU_INACTIVE_ANON);
+		}
+		memcg = mem_cgroup_iter(NULL, memcg, NULL);
+	} while (memcg);
 
-		return nr;
+	return nr;
 }
 
 static inline bool zone_reclaimable(struct zone *zone)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b95344c..4a44890 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -145,14 +145,6 @@ static bool global_reclaim(struct scan_control *sc)
 }
 #endif
 
-static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	if (!mem_cgroup_disabled())
-		return mem_cgroup_get_lru_size(lruvec, lru);
-
-	return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
-}
-
 /*
  * Add a shrinker callback to be called from the vm
  */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
