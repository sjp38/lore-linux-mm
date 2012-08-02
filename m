Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 111BD6B0069
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 17:24:27 -0400 (EDT)
Received: by obbun3 with SMTP id un3so6396751obb.2
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 14:24:26 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under zone reclaim
Date: Thu,  2 Aug 2012 14:24:24 -0700
Message-Id: <1343942664-13365-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

In memcg kernel, cgroup under its softlimit is not targeted under global
reclaim. It could be possible that all memcgs are under their softlimit for
a particular zone. If that is the case, the current implementation will
burn extra cpu cycles without making forward progress.

The idea is from LSF discussion where we detect it after the first round of
scanning and restart the reclaim by not looking at softlimit at all. This
allows us to make forward progress on shrink_zone().

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    9 +++++++++
 mm/memcontrol.c            |    3 +--
 mm/vmscan.c                |   18 ++++++++++++++++--
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 65538f9..cbad102 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -180,6 +180,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 }
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
+
+bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
@@ -360,6 +362,13 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline bool
+mem_cgroup_is_root(struct mem_cgroup *memcg)
+{
+	return true;
+}
+
 static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d8b91bb..368eecc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -378,7 +378,6 @@ enum charge_type {
 
 static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
-static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
 
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
@@ -850,7 +849,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
-static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
+bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 {
 	return (memcg == root_mem_cgroup);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 88487b3..8622022 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1861,6 +1861,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		.priority = sc->priority,
 	};
 	struct mem_cgroup *memcg;
+	bool over_softlimit, ignore_softlimit = false;
+
+restart:
+	over_softlimit = false;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
@@ -1879,10 +1883,15 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		 * we have to reclaim under softlimit instead of burning more
 		 * cpu cycles.
 		 */
-		if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY ||
-				mem_cgroup_over_soft_limit(memcg))
+		if (ignore_softlimit || !global_reclaim(sc) ||
+				sc->priority < DEF_PRIORITY ||
+				mem_cgroup_over_soft_limit(memcg)) {
 			shrink_lruvec(lruvec, sc);
 
+			if (!mem_cgroup_is_root(memcg))
+				over_softlimit = true;
+		}
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -1899,6 +1908,11 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		}
 		memcg = mem_cgroup_iter(root, memcg, &reclaim);
 	} while (memcg);
+
+	if (!over_softlimit) {
+		ignore_softlimit = true;
+		goto restart;
+	}
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
