Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 47DE06B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 15:01:00 -0400 (EDT)
Received: by mail-qc0-f201.google.com with SMTP id u18so542339qcx.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 12:00:59 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/2 v4] memcg: support hierarchical memory.numa_stats
Date: Mon, 16 Sep 2013 12:00:23 -0700
Message-Id: <1379358023-3093-2-git-send-email-gthelen@google.com>
In-Reply-To: <1379358023-3093-1-git-send-email-gthelen@google.com>
References: <1379358023-3093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hughd@google.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

From: Ying Han <yinghan@google.com>

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
hierarchical_total=908 N0=552 N1=317 N2=39 N3=0
hierarchical_file=850 N0=549 N1=301 N2=0 N3=0
hierarchical_anon=58 N0=3 N1=16 N2=39 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

$ cat a/b/memory.numa_stat
total=908 N0=552 N1=317 N2=39 N3=0
file=850 N0=549 N1=301 N2=0 N3=0
anon=58 N0=3 N1=16 N2=39 N3=0
unevictable=0 N0=0 N1=0 N2=0 N3=0
hierarchical_total=908 N0=552 N1=317 N2=39 N3=0
hierarchical_file=850 N0=549 N1=301 N2=0 N3=0
hierarchical_anon=58 N0=3 N1=16 N2=39 N3=0
hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v3:
- push 'iter' local variable usage closer to its usage
- documentation fixup

 Documentation/cgroups/memory.txt | 10 +++++++---
 mm/memcontrol.c                  | 17 +++++++++++++++++
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 8af4ad1..e2bc132 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -573,15 +573,19 @@ an memcg since the pages are allowed to be allocated from any physical
 node.  One of the use cases is evaluating application performance by
 combining this information with the application's CPU allocation.
 
-We export "total", "file", "anon" and "unevictable" pages per-node for
-each memcg.  The ouput format of memory.numa_stat is:
+Each memcg's numa_stat file includes "total", "file", "anon" and "unevictable"
+per-node page counts including "hierarchical_<counter>" which sums up all
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
index 5806eea..d02176d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5206,6 +5206,23 @@ static int memcg_numa_stat_show(struct cgroup_subsys_state *css,
 		seq_putc(m, '\n');
 	}
 
+	for (stat = stats; stat < stats + ARRAY_SIZE(stats); stat++) {
+		struct mem_cgroup *iter;
+
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
