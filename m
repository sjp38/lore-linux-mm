Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C66A86B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 05:22:48 -0400 (EDT)
Received: by mail-ye0-f201.google.com with SMTP id m2so165967yen.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:22:47 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2 v2] memcg: support hierarchical memory.numa_stats
Date: Wed, 24 Apr 2013 02:22:44 -0700
Message-Id: <1366795365-30808-1-git-send-email-gthelen@google.com>
In-Reply-To: <1366794128-28731-2-git-send-email-gthelen@google.com>
References: <1366794128-28731-2-git-send-email-gthelen@google.com>
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
Changelog:
- v2: add documentation

 Documentation/cgroups/memory.txt |  5 ++++-
 mm/memcontrol.c                  | 16 ++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 8b8c28b..b519e74 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -568,7 +568,10 @@ node.  One of the use cases is evaluating application performance by
 combining this information with the application's CPU allocation.
 
 We export "total", "file", "anon" and "unevictable" pages per-node for
-each memcg.  The ouput format of memory.numa_stat is:
+each memcg and "hierarchical_" for sum of all hierarchical children's values
+in addition to the memcg's own value.
+
+The ouput format of memory.numa_stat is:
 
 total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
 file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
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
