Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF1086B0027
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:55:55 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 1/2] memcg: rename mem_cgroup_zone_nr_pages() to mem_cgroup_zone_nr_lru_pages()
Date: Wed, 18 May 2011 17:55:10 -0700
Message-Id: <1305766511-11469-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The caller of the function has been renamed to zone_nr_lru_pages(), and this
is just fixing up in the memcg code. The current name is easily to be mis-read
as zone's total number of pages.

This patch is based on mmotm-2011-05-06-16-39

no change on this patch from v1.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   10 +++++-----
 mm/memcontrol.c            |    6 +++---
 mm/vmscan.c                |    2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 77e47f5..22b3190 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -109,9 +109,9 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
-unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
-				       struct zone *zone,
-				       enum lru_list lru);
+unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
+						struct zone *zone,
+						enum lru_list lru);
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
@@ -306,8 +306,8 @@ mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 }
 
 static inline unsigned long
-mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
-			 enum lru_list lru)
+mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, struct zone *zone,
+			     enum lru_list lru)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95aecca..da183dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1151,9 +1151,9 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 	return (active > inactive);
 }
 
-unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
-				       struct zone *zone,
-				       enum lru_list lru)
+unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
+						struct zone *zone,
+						enum lru_list lru)
 {
 	int nid = zone_to_nid(zone);
 	int zid = zone_idx(zone);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..fbbb958 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -172,7 +172,7 @@ static unsigned long zone_nr_lru_pages(struct zone *zone,
 				struct scan_control *sc, enum lru_list lru)
 {
 	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone, lru);
+		return mem_cgroup_zone_nr_lru_pages(sc->mem_cgroup, zone, lru);
 
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
