Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0FD2A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 17:58:48 -0400 (EDT)
Received: by mail-ob0-f201.google.com with SMTP id uz6so1596426obc.2
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 14:58:48 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: support hierarchical memory.numa_stats
Date: Mon,  8 Apr 2013 14:58:46 -0700
Message-Id: <1365458326-17091-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org

The memory.numa_stat is not currently hierarchical. Memory charged to the
children are not shown in parent's numa_stat.

This change adds the "hierarchical_" stats on top of all existing stats, and
it includes the sum of all children's values in addition to the value of
the memcg.

Tested: Create cgroup a, a/b and run workload under b. The values of b are
included in the "hierarchical_*" under a.

$ cat /dev/cgroup/memory/a/memory.numa_stat
total=0 N0=0 N1=0
file=0 N0=0 N1=0
anon=0 N0=0 N1=0
unevictable=0 N0=0 N1=0
hierarchical_total=262474 N0=262162 N1=312
hierarchical_file=247 N0=0 N1=247
hierarchical_anon=262227 N0=262162 N1=65
hierarchical_unevictable=0 N0=0 N1=0

$ cat /dev/cgroup/memory/a/b/memory.numa_stat
total=262474 N0=262162 N1=312
file=247 N0=0 N1=247
anon=262227 N0=262162 N1=65
unevictable=0 N0=0 N1=0
hierarchical_total=262474 N0=262162 N1=312
hierarchical_file=247 N0=0 N1=247
hierarchical_anon=262227 N0=262162 N1=65
hierarchical_unevictable=0 N0=0 N1=0

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |  5 +++-
 mm/memcontrol.c                  | 65 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+), 1 deletion(-)

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
index 2b55222..9d8cf25 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1177,6 +1177,32 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
+static unsigned long
+mem_cgroup_node_hierarchical_nr_lru_pages(struct mem_cgroup *memcg,
+				int nid, unsigned int lru_mask)
+{
+	u64 total = 0;
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, memcg)
+		total += mem_cgroup_node_nr_lru_pages(iter, nid, lru_mask);
+
+	return total;
+}
+
+static unsigned long
+mem_cgroup_hierarchical_nr_lru_pages(struct mem_cgroup *memcg,
+					unsigned int lru_mask)
+{
+	u64 total = 0;
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, memcg)
+	total += mem_cgroup_nr_lru_pages(iter, lru_mask);
+
+	return total;
+}
+
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
@@ -5267,6 +5293,45 @@ static int memcg_numa_stat_show(struct cgroup *cont, struct cftype *cft,
 		seq_printf(m, " N%d=%lu", nid, node_nr);
 	}
 	seq_putc(m, '\n');
+
+	total_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL);
+	seq_printf(m, "hierarchical_total=%lu", total_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr =
+			mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
+								LRU_ALL);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	file_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL_FILE);
+	seq_printf(m, "hierarchical_file=%lu", file_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
+				LRU_ALL_FILE);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	anon_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg, LRU_ALL_ANON);
+	seq_printf(m, "hierarchical_anon=%lu", anon_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
+				LRU_ALL_ANON);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	unevictable_nr = mem_cgroup_hierarchical_nr_lru_pages(memcg,
+						BIT(LRU_UNEVICTABLE));
+	seq_printf(m, "hierarchical_unevictable=%lu", unevictable_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_hierarchical_nr_lru_pages(memcg, nid,
+				BIT(LRU_UNEVICTABLE));
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
 	return 0;
 }
 #endif /* CONFIG_NUMA */
-- 
1.8.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
