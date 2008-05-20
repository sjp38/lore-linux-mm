Date: Tue, 20 May 2008 18:09:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/3] memcg: per node information
Message-Id: <20080520180955.70aa5459.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Show per-node statistics in following format.

 node-id total acitve inactive

[root@iridium bench]# cat /opt/cgroup/memory.numa_stat
0 417611776 99586048 318025728
1 655360000 0 655360000

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

Index: mm-2.6.26-rc2-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.26-rc2-mm1.orig/mm/memcontrol.c
+++ mm-2.6.26-rc2-mm1/mm/memcontrol.c
@@ -960,6 +960,66 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+#ifdef CONFIG_NUMA
+static void *memcg_numastat_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t node = *pos;
+	struct pglist_data *pgdat = first_online_pgdat();
+
+	while (pgdat != NULL) {
+		if (!node)
+			break;
+		pgdat = next_online_pgdat(pgdat);
+		node--;
+	}
+	return pgdat;
+}
+
+static void *memcg_numastat_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	struct pglist_data *pgdat = (struct pglist_data *)arg;
+
+	(*pos)++;
+	return next_online_pgdat(pgdat);
+}
+
+static void memcg_numastat_stop(struct seq_file *m, void *arg)
+{
+}
+
+static int memcg_numastat_show(struct seq_file *m, void *arg)
+{
+	struct pglist_data *pgdat = (struct pglist_data *)arg;
+	int nid = pgdat->node_id;
+	struct cgroup *cgrp = cgroup_of_seqfile(m);
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup_per_zone *mz;
+	long active, inactive, total;
+	int zid;
+
+	active = 0;
+	inactive = 0;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		mz = mem_cgroup_zoneinfo(memcg, nid, zid);
+		active += MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_ACTIVE);
+		inactive += MEM_CGROUP_ZSTAT(mz, MEM_CGROUP_ZSTAT_INACTIVE);
+	}
+	active *= PAGE_SIZE;
+	inactive *= PAGE_SIZE;
+	total = active + inactive;
+	/* Node Total Active Inactive (Total = Active + Inactive) */
+	return seq_printf(m, "%d %ld %ld %ld\n", nid, total, active, inactive);
+}
+
+struct seq_operations memcg_numastat_op = {
+	.start = memcg_numastat_start,
+	.next  = memcg_numastat_next,
+	.stop  = memcg_numastat_stop,
+	.show  = memcg_numastat_show,
+};
+#endif
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -992,6 +1052,12 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+#ifdef CONFIG_NUMA
+	{
+		.name = "numa_stat",
+		.seq_ops = &memcg_numastat_op,
+	},
+#endif
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
Index: mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
===================================================================
--- mm-2.6.26-rc2-mm1.orig/Documentation/controllers/memory_files.txt
+++ mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
@@ -74,3 +74,13 @@ Files under memory resource controller a
   (write)
   Reset to 0.
 
+* memory.numa_stat
+
+  This file appears only when the kernel is configured as NUMA.
+
+  (read)
+  Show per-node accounting information of acitve/inactive pages.
+  formated as following.
+  nodeid  total active inactive
+
+  total = active + inactive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
