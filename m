Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B3BFE6B0009
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 05:54:47 -0500 (EST)
Message-ID: <510658EE.9050006@oracle.com>
Date: Mon, 28 Jan 2013 18:54:38 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, handai.szj@taobao.com

Root memcg with swap cgroup is special since we only do tracking but can
not set limits against it.  In order to facilitate the implementation of
the coming swap cgroup structures delay allocation mechanism, we can bypass
the default swap statistics upon the root memcg and figure it out through
the global stats instead as below:

root_memcg_swap_stat: total_swap_pages - nr_swap_pages - used_swap_pages_of_all_memcgs
memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats

In this way, we'll return an invalid CSS_ID(generally, it's 0) at swap
cgroup related tracking infrastructures if only the root memcg is alive.
That is to say, we have not yet allocate swap cgroup structures.
As a result, the per pages swapin/swapout stats number agains the root
memcg shoud be ZERO.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>

---
 mm/memcontrol.c |   35 ++++++++++++++++++++++++++++++-----
 1 file changed, 30 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09255ec..afe5e86 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5231,12 +5231,34 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mem_cgroup *mi;
 	unsigned int i;
+	long long root_swap_stat = 0;
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
-		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
-			continue;
+		long val = 0;
+
+		if (i != MEM_CGROUP_STAT_SWAP)
+			val = mem_cgroup_read_stat(memcg, i);
+		else {
+			if (!do_swap_account)
+				continue;
+			if (!mem_cgroup_is_root(memcg))
+				val = mem_cgroup_read_stat(memcg, i);
+			else {
+				/*
+				 * The corresponding stat number of swap for
+				 * root_mem_cgroup is 0 since we don't account
+				 * it in any case.  Instead, we can fake the
+				 * root number via: total_swap_pages -
+				 * nr_swap_pages - total_swap_pages_of_all_memcg
+				 */
+				for_each_mem_cgroup(mi)
+					val += mem_cgroup_read_stat(mi, i);
+				val = root_swap_stat = (total_swap_pages -
+							nr_swap_pages - val);
+			}
+		}
 		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+			   val * PAGE_SIZE);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
@@ -5260,8 +5282,11 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		long long val = 0;
 
-		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
-			continue;
+		if (i == MEM_CGROUP_STAT_SWAP) {
+			if (!do_swap_account)
+				continue;
+			val += root_swap_stat * PAGE_SIZE;
+		}
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
 		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
