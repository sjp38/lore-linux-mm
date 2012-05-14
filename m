Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 56FE06B00E8
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:01:03 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/6] mm: memcg: print statistics directly to seq_file
Date: Mon, 14 May 2012 20:00:48 +0200
Message-Id: <1337018451-27359-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
References: <1337018451-27359-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Being able to use seq_printf() allows being smarter about statistics
name strings, which are currently listed twice, with the only
difference being a "total_" prefix on the hierarchical version.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   56 +++++++++++++++++++++++++++----------------------------
 1 file changed, 28 insertions(+), 28 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f0d248b..9e8551c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4274,24 +4274,21 @@ struct mcs_total_stat {
 	s64 stat[NR_MCS_STAT];
 };
 
-static struct {
-	char *local_name;
-	char *total_name;
-} memcg_stat_strings[NR_MCS_STAT] = {
-	{"cache", "total_cache"},
-	{"rss", "total_rss"},
-	{"mapped_file", "total_mapped_file"},
-	{"mlock", "total_mlock"},
-	{"pgpgin", "total_pgpgin"},
-	{"pgpgout", "total_pgpgout"},
-	{"swap", "total_swap"},
-	{"pgfault", "total_pgfault"},
-	{"pgmajfault", "total_pgmajfault"},
-	{"inactive_anon", "total_inactive_anon"},
-	{"active_anon", "total_active_anon"},
-	{"inactive_file", "total_inactive_file"},
-	{"active_file", "total_active_file"},
-	{"unevictable", "total_unevictable"}
+static const char *memcg_stat_strings[NR_MCS_STAT] = {
+	"cache",
+	"rss",
+	"mapped_file",
+	"mlock",
+	"pgpgin",
+	"pgpgout",
+	"swap",
+	"pgfault",
+	"pgmajfault",
+	"inactive_anon",
+	"active_anon",
+	"inactive_file",
+	"active_file",
+	"unevictable",
 };
 
 
@@ -4392,7 +4389,7 @@ static int mem_control_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 #endif /* CONFIG_NUMA */
 
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
-				 struct cgroup_map_cb *cb)
+				 struct seq_file *m)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mcs_total_stat mystat;
@@ -4405,16 +4402,18 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
-		cb->fill(cb, memcg_stat_strings[i].local_name, mystat.stat[i]);
+		seq_printf(m, "%s %llu\n", memcg_stat_strings[i],
+			   (unsigned long long)mystat.stat[i]);
 	}
 
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
 		memcg_get_hierarchical_limit(memcg, &limit, &memsw_limit);
-		cb->fill(cb, "hierarchical_memory_limit", limit);
+		seq_printf(m, "hierarchical_memory_limit %llu\n", limit);
 		if (do_swap_account)
-			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
+			seq_printf(m, "hierarchical_memsw_limit %llu\n",
+				   memsw_limit);
 	}
 
 	memset(&mystat, 0, sizeof(mystat));
@@ -4422,7 +4421,8 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
-		cb->fill(cb, memcg_stat_strings[i].total_name, mystat.stat[i]);
+		seq_printf(m, "total_%s %llu\n", memcg_stat_strings[i],
+			   (unsigned long long)mystat.stat[i]);
 	}
 
 #ifdef CONFIG_DEBUG_VM
@@ -4443,10 +4443,10 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				recent_scanned[0] += rstat->recent_scanned[0];
 				recent_scanned[1] += rstat->recent_scanned[1];
 			}
-		cb->fill(cb, "recent_rotated_anon", recent_rotated[0]);
-		cb->fill(cb, "recent_rotated_file", recent_rotated[1]);
-		cb->fill(cb, "recent_scanned_anon", recent_scanned[0]);
-		cb->fill(cb, "recent_scanned_file", recent_scanned[1]);
+		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
+		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
+		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
+		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
 	}
 #endif
 
@@ -4880,7 +4880,7 @@ static struct cftype mem_cgroup_files[] = {
 	},
 	{
 		.name = "stat",
-		.read_map = mem_control_stat_show,
+		.read_seq_string = mem_control_stat_show,
 	},
 	{
 		.name = "force_empty",
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
