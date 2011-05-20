Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8272B6B0022
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:25:30 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V4 3/3] memcg: add memory.numastat api for numa statistics
Date: Thu, 19 May 2011 20:24:51 -0700
Message-Id: <1305861891-26140-3-git-send-email-yinghan@google.com>
In-Reply-To: <1305861891-26140-1-git-send-email-yinghan@google.com>
References: <1305861891-26140-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The new API exports numa_maps per-memcg basis. This is a piece of useful
information where it exports per-memcg page distribution across real numa
nodes.

One of the usecase is evaluating application performance by combining this
information w/ the cpu allocation to the application.

The output of the memory.numastat tries to follow w/ simiar format of numa_maps
like:

total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...

And we have per-node:
total = file + anon + unevictable

$ cat /dev/cgroup/memory/memory.numa_stat
total=250020 N0=87620 N1=52367 N2=45298 N3=64735
file=225232 N0=83402 N1=46160 N2=40522 N3=55148
anon=21053 N0=3424 N1=6207 N2=4776 N3=6646
unevictable=3735 N0=794 N1=0 N2=0 N3=2941

change v4..v3:
1. add per-node "unevictable" value.
2. change the functions to be static.

change v3..v2:
1. calculate the "total" based on the per-memcg lru size instead of rss+cache.
this makes the "total" value to be consistant w/ the per-node values follows
after.

change v2..v1:
1. add also the file and anon pages on per-node distribution.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |  147 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e14677c..ec444ca 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1162,6 +1162,91 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+static unsigned long mem_cgroup_node_nr_file_lru_pages(struct mem_cgroup *memcg,
+							int nid)
+{
+	unsigned long ret;
+
+	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_FILE) +
+		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_FILE);
+
+	return ret;
+}
+
+static unsigned long mem_cgroup_nr_file_lru_pages(struct mem_cgroup *memcg)
+{
+	u64 total = 0;
+	int nid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		total += mem_cgroup_node_nr_file_lru_pages(memcg, nid);
+
+	return total;
+}
+
+static unsigned long mem_cgroup_node_nr_anon_lru_pages(struct mem_cgroup *memcg,
+							int nid)
+{
+	unsigned long ret;
+
+	ret = mem_cgroup_get_zonestat_node(memcg, nid, LRU_INACTIVE_ANON) +
+		mem_cgroup_get_zonestat_node(memcg, nid, LRU_ACTIVE_ANON);
+
+	return ret;
+}
+
+static unsigned long mem_cgroup_nr_anon_lru_pages(struct mem_cgroup *memcg)
+{
+	u64 total = 0;
+	int nid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		total += mem_cgroup_node_nr_anon_lru_pages(memcg, nid);
+
+	return total;
+}
+
+static unsigned long
+mem_cgroup_node_nr_unevictable_lru_pages(struct mem_cgroup *memcg, int nid)
+{
+	return mem_cgroup_get_zonestat_node(memcg, nid, LRU_UNEVICTABLE);
+}
+
+static unsigned long
+mem_cgroup_nr_unevictable_lru_pages(struct mem_cgroup *memcg)
+{
+	u64 total = 0;
+	int nid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		total += mem_cgroup_node_nr_unevictable_lru_pages(memcg, nid);
+
+	return total;
+}
+
+static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+							int nid)
+{
+	enum lru_list l;
+	u64 total = 0;
+
+	for_each_lru(l)
+		total += mem_cgroup_get_zonestat_node(memcg, nid, l);
+
+	return total;
+}
+
+static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg)
+{
+	u64 total = 0;
+	int nid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY)
+		total += mem_cgroup_node_nr_lru_pages(memcg, nid);
+
+	return total;
+}
+
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
@@ -4048,6 +4133,49 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		mem_cgroup_get_local_stat(iter, s);
 }
 
+static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
+{
+	int nid;
+	unsigned long total_nr, file_nr, anon_nr, unevictable_nr;
+	unsigned long node_nr;
+	struct cgroup *cont = m->private;
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+
+	total_nr = mem_cgroup_nr_lru_pages(mem_cont);
+	seq_printf(m, "total=%lu", total_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_nr_lru_pages(mem_cont, nid);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	file_nr = mem_cgroup_nr_file_lru_pages(mem_cont);
+	seq_printf(m, "file=%lu", file_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_nr_file_lru_pages(mem_cont, nid);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	anon_nr = mem_cgroup_nr_anon_lru_pages(mem_cont);
+	seq_printf(m, "anon=%lu", anon_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_nr_anon_lru_pages(mem_cont, nid);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+
+	unevictable_nr = mem_cgroup_nr_unevictable_lru_pages(mem_cont);
+	seq_printf(m, "unevictable=%lu", unevictable_nr);
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		node_nr = mem_cgroup_node_nr_unevictable_lru_pages(mem_cont,
+									nid);
+		seq_printf(m, " N%d=%lu", nid, node_nr);
+	}
+	seq_putc(m, '\n');
+	return 0;
+}
+
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
@@ -4058,6 +4186,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 	memset(&mystat, 0, sizeof(mystat));
 	mem_cgroup_get_local_stat(mem_cont, &mystat);
 
+
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
@@ -4481,6 +4610,20 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	return 0;
 }
 
+static const struct file_operations mem_control_numa_stat_file_operations = {
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
+{
+	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
+
+	file->f_op = &mem_control_numa_stat_file_operations;
+	return single_open(file, mem_control_numa_stat_show, cont);
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4544,6 +4687,10 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "numa_stat",
+		.open = mem_control_numa_stat_open,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
