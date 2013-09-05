Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 61EA16B0033
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 02:29:15 -0400 (EDT)
Received: by mail-yh0-f73.google.com with SMTP id z20so88374yhz.2
        for <linux-mm@kvack.org>; Wed, 04 Sep 2013 23:29:14 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2 v3] memcg: support hierarchical memory.numa_stats
Date: Wed,  4 Sep 2013 23:28:59 -0700
Message-Id: <1378362539-18100-2-git-send-email-gthelen@google.com>
In-Reply-To: <1378362539-18100-1-git-send-email-gthelen@google.com>
References: <1378362539-18100-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hughd@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>

From: Ying Han <yinghan@google.com>

The memory.numa_stat file was not hierarchical.  Memory charged to the
children was not shown in parent's numa_stat.

This change adds the "hierarchical_" stats to the existing stats.  The
new hierarchical stats include the sum of all children's values in
addition to the value of the memcg.

Tested: Create cgroup a, a/b and run workload under b.  The values of
b are included in the "hierarchical_*" under a.

$ cd /sys/fs/cgroup
$ echo 1 > memory.use_hierarchy
$ mkdir a a/b

Run workload in a/b:
$ (echo $BASHPID >> a/b/cgroup.procs && cat /some/file && bash) &

The hierarchical_ fields in parent (a) show use of workload in a/b:
$ cat a/memory.numa_stat
total=0 N0=0 N1=0 N2=0 N3=0
file=0 N0=0 N1=0 N2=0 N3=0
anon=0 N0=0 N1=0 N2=0 N3=0
unevictable=0 N0=0 N1=0 N2=0 N3=0
hierarchical_total=61 N0=0 N1=41 N2=20 N3=0
hierarchical_file=14 N0=0 N1=0 N2=14 N3=0
hierarchical_anon=47 N0=0 N1=41 N2=6 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

The workload memory usage:
$ cat a/b/memory.numa_stat
total=73 N0=0 N1=41 N2=32 N3=0
file=14 N0=0 N1=0 N2=14 N3=0
anon=59 N0=0 N1=41 N2=18 N3=0
unevictable=0 N0=0 N1=0 N2=0 N3=0
hierarchical_total=73 N0=0 N1=41 N2=32 N3=0
hierarchical_file=14 N0=0 N1=0 N2=14 N3=0
hierarchical_anon=59 N0=0 N1=41 N2=18 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v2:
- reworded Documentation/cgroup/memory.txt
- updated commit description

 Documentation/cgroups/memory.txt | 10 +++++++---
 mm/memcontrol.c                  | 16 ++++++++++++++++
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2a33306..d6d6479 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -571,15 +571,19 @@ an memcg since the pages are allowed to be allocated from any physical
 node.  One of the use cases is evaluating application performance by
 combining this information with the application's CPU allocation.
 
-We export "total", "file", "anon" and "unevictable" pages per-node for
-each memcg.  The ouput format of memory.numa_stat is:
+Each memcg's numa_stat file includes "total", "file", "anon" and "unevictable"
+per-node page counts including "hierarchical_<counter>" which sums of all
+hierarchical children's values in addition to the memcg's own value.
+
+The ouput format of memory.numa_stat is:
 
 total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
 file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
 anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
 unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
+hierarchical_<counter>=<counter pages> N0=<node 0 pages> N1=<node 1 pages> ...
 
-And we have total = file + anon + unevictable.
+The "total" count is sum of file + anon + unevictable.
 
 6. Hierarchy support
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d2b037..0e5be30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5394,6 +5394,7 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 	int nid;
 	unsigned long nr;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *iter;
 
 	for (stat = stats; stat->name; stat++) {
 		nr = mem_cgroup_nr_lru_pages(memcg, stat->lru_mask);
@@ -5406,6 +5407,21 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
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
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
