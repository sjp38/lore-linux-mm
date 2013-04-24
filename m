Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DB4E46B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 05:02:25 -0400 (EDT)
Received: by mail-ye0-f202.google.com with SMTP id l8so164180yen.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:02:25 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2] memcg: support hierarchical memory.numa_stats
Date: Wed, 24 Apr 2013 02:02:08 -0700
Message-Id: <1366794128-28731-2-git-send-email-gthelen@google.com>
In-Reply-To: <1366794128-28731-1-git-send-email-gthelen@google.com>
References: <1365458326-17091-1-git-send-email-yinghan@google.com>
 <1366794128-28731-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

From: Ying Han <yinghan@google.com>

The memory.numa_stat file was not hierarchical.  Memory charged to the
children was not shown in parent's numa_stat.

This change adds the "hierarchical_" stats to the existing stats.  The
new hierarchical stats include the sum of all children's values in
addition to the value of the memcg.

Tested: Create cgroup a, a/b and run workload under b.  The values of
b are included in the "hierarchical_*" under a.

$ cat /dev/cgroup/memory/a/memory.numa_stat
total=0 N0=0 N1=0 N2=0 N3=0
file=0 N0=0 N1=0 N2=0 N3=0
anon=0 N0=0 N1=0 N2=0 N3=0
unevictable=0 N0=0 N1=0 N2=0 N3=0
hierarchical_total=21395 N0=0 N1=16 N2=21379 N3=0
hierarchical_file=21368 N0=0 N1=0 N2=21368 N3=0
hierarchical_anon=27 N0=0 N1=16 N2=11 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

$ cat /dev/cgroup/memory/a/b/memory.numa_stat
total=21395 N0=0 N1=16 N2=21379 N3=0
file=21368 N0=0 N1=0 N2=21368 N3=0
anon=27 N0=0 N1=16 N2=11 N3=0
unevictable=0 N0=0 N1=0 N2=0 N3=0
hierarchical_total=21395 N0=0 N1=16 N2=21379 N3=0
hierarchical_file=21368 N0=0 N1=0 N2=21368 N3=0
hierarchical_anon=27 N0=0 N1=16 N2=11 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e73526e..f0ec99d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5244,6 +5244,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 	int nid;
 	unsigned long nr;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *iter;
 
 	for (stat = stats; stat->name; stat++) {
 		nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
@@ -5256,6 +5257,21 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 		seq_putc(m, '\n');
 	}
 
+	for (stat = stats; stat->name; stat++) {
+		nr = 0;
+		for_each_mem_cgroup_tree(iter, memcg)
+			nr += mem_cgroup_nr_lru_pages(iter, stat->lru_mask);
+		seq_printf(m, "hierarchical_%s=%lu", stat->name, nr);
+		for_each_node_state(nid, N_MEMORY) {
+			nr = 0;
+			for_each_mem_cgroup_tree(iter, memcg)
+				nr += mem_cgroup_node_nr_lru_pages(
+					iter, nid, stat->lru_mask);
+			seq_printf(m, " N%d=%lu", nid, nr);
+		}
+		seq_putc(m, '\n');
+	}
+
 	return 0;
 }
 #endif /* CONFIG_NUMA */
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
