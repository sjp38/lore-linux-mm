Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 5FD6B6B029D
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 02:17:54 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3916562dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 23:17:53 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH 4/6] memcg: move recent_rotated and recent_scanned informations
Date: Sat, 23 Jun 2012 14:17:39 +0800
Message-Id: <1340432259-5317-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Move recent_rotated and recent_scanned prints next to inactive_anon,
ative_anon, inactive_file, active_file, and unevictable prints to
save developers' time. Since they have to go a long way(when cat memory.stat)
to find recent_rotated and recent_scanned prints which has relationship
with the memory cgroup we care. These prints are behind total_* which
not just focus on the memory cgroup we care currently.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |   50 +++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2e81328..c821e36 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4080,6 +4080,31 @@ static int mem_cgroup_stat_show(struct cgroup *cont, struct cftype *cft,
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
 			   mem_cgroup_nr_lru_pages(memcg, BIT(i)) * PAGE_SIZE);
 
+#ifdef CONFIG_DEBUG_VM
+	{
+		int nid, zid;
+		struct mem_cgroup_per_zone *mz;
+		struct zone_reclaim_stat *rstat;
+		unsigned long recent_rotated[2] = {0, 0};
+		unsigned long recent_scanned[2] = {0, 0};
+
+		for_each_online_node(nid)
+			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+				rstat = &mz->lruvec.reclaim_stat;
+
+				recent_rotated[0] += rstat->recent_rotated[0];
+				recent_rotated[1] += rstat->recent_rotated[1];
+				recent_scanned[0] += rstat->recent_scanned[0];
+				recent_scanned[1] += rstat->recent_scanned[1];
+			}
+		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
+		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
+		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
+		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
+	}
+#endif
+
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
@@ -4117,31 +4142,6 @@ static int mem_cgroup_stat_show(struct cgroup *cont, struct cftype *cft,
 		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i], val);
 	}
 
-#ifdef CONFIG_DEBUG_VM
-	{
-		int nid, zid;
-		struct mem_cgroup_per_zone *mz;
-		struct zone_reclaim_stat *rstat;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
-
-		for_each_online_node(nid)
-			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(memcg, nid, zid);
-				rstat = &mz->lruvec.reclaim_stat;
-
-				recent_rotated[0] += rstat->recent_rotated[0];
-				recent_rotated[1] += rstat->recent_rotated[1];
-				recent_scanned[0] += rstat->recent_scanned[0];
-				recent_scanned[1] += rstat->recent_scanned[1];
-			}
-		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
-		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
-		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
-		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
-	}
-#endif
-
 	return 0;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
