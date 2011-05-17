Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 88E226B002C
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:26:45 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/2] memcg: add memory.numastat api for numa statistics
Date: Tue, 17 May 2011 15:25:51 -0700
Message-Id: <1305671151-21993-2-git-send-email-yinghan@google.com>
In-Reply-To: <1305671151-21993-1-git-send-email-yinghan@google.com>
References: <1305671151-21993-1-git-send-email-yinghan@google.com>
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

<total pages> N0=<node 0 pages> N1=<node 1 pages> ...

$ cat /dev/cgroup/memory/memory.numa_stat
292115 N0=36364 N1=166876 N2=39741 N3=49115

Note: I noticed <total pages> is not equal to the sum of the rest of counters.
I might need to change the way get that counter, comments are welcomed.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/memcontrol.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index da183dc..0fe9c75 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1162,6 +1162,22 @@ unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 	return MEM_CGROUP_ZSTAT(mz, lru);
 }
 
+unsigned long mem_cgroup_node_nr_pages(struct mem_cgroup *memcg, int nid)
+{
+	int zid;
+	struct mem_cgroup_per_zone *mz;
+	enum lru_list l;
+	u64 total = 0;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+		for_each_lru(l)
+			total += MEM_CGROUP_ZSTAT(mz, l);
+	}
+
+	return total;
+}
+
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone)
 {
@@ -4048,6 +4064,25 @@ mem_cgroup_get_total_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		mem_cgroup_get_local_stat(iter, s);
 }
 
+static int mem_control_numa_stat_show(struct seq_file *m, void *arg)
+{
+	int nid;
+	unsigned long total_nr, nid_nr;
+	struct cgroup *cont = m->private;
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+
+	total_nr = mem_cgroup_local_usage(mem_cont);
+	seq_printf(m, "%lu", total_nr);
+
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		nid_nr = mem_cgroup_node_nr_pages(mem_cont, nid);
+		seq_printf(m, " N%d=%lu", nid, nid_nr);
+	}
+	seq_putc(m, '\n');
+
+	return 0;
+}
+
 static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
@@ -4481,6 +4516,20 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
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
@@ -4544,6 +4593,10 @@ static struct cftype mem_cgroup_files[] = {
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
