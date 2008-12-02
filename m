Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB27DI0F015248
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 2 Dec 2008 16:13:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6147E2AEA85
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:13:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AD791EF085
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:13:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E8131DB803A
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:13:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B31E8E08002
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:13:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg: make memory.swappiness file
In-Reply-To: <20081202160949.1CFE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081202160949.1CFE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081202161111.1D01.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  2 Dec 2008 16:13:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, /proc/sys/vm/swappiness can change swappiness ratio for global reclaim.
However, memcg reclaim doesn't have tuning parameter for itself.

In general, the optimal swappiness depend on workload.
(e.g. hpc workload need to low swappiness than the others.)

Then, per cgroup swappiness improve administrator tunability.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/controllers/memory.txt |    6 ++
 include/linux/swap.h                 |    3 -
 mm/memcontrol.c                      |   72 ++++++++++++++++++++++++++++++++---
 mm/vmscan.c                          |    7 +--
 4 files changed, 78 insertions(+), 10 deletions(-)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -163,6 +163,9 @@ struct mem_cgroup {
 	unsigned long	last_oom_jiffies;
 	int		obsolete;
 	atomic_t	refcnt;
+
+	unsigned int	swappiness;
+
 	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
@@ -588,6 +591,22 @@ done:
 	return ret;
 }
 
+static unsigned int get_swappiness(struct mem_cgroup *memcg)
+{
+	struct cgroup *cgrp = memcg->css.cgroup;
+	unsigned int swappiness;
+
+	/* root ? */
+	if (cgrp->parent == NULL)
+		return vm_swappiness;
+
+	spin_lock(&memcg->misc_lock);
+	swappiness = memcg->swappiness;
+	spin_unlock(&memcg->misc_lock);
+
+	return swappiness;
+}
+
 /*
  * Dance down the hierarchy if needed to reclaim memory. We remember the
  * last child we reclaimed from, so that we don't end up penalizing
@@ -608,7 +627,8 @@ static int mem_cgroup_hierarchical_recla
 	 * but there might be left over accounting, even after children
 	 * have left.
 	 */
-	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
+	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
+					   get_swappiness(root_mem));
 	if (res_counter_check_under_limit(&root_mem->res))
 		return 0;
 
@@ -622,7 +642,8 @@ static int mem_cgroup_hierarchical_recla
 			cgroup_unlock();
 			continue;
 		}
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
+		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
+						   get_swappiness(next_mem));
 		if (res_counter_check_under_limit(&root_mem->res))
 			return 0;
 		cgroup_lock();
@@ -1350,7 +1371,8 @@ int mem_cgroup_shrink_usage(struct mm_st
 	rcu_read_unlock();
 
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true);
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true,
+							get_swappiness(mem));
 		progress += res_counter_check_under_limit(&mem->res);
 	} while (!progress && --retry);
 
@@ -1395,7 +1417,9 @@ static int mem_cgroup_resize_limit(struc
 			break;
 
 		progress = try_to_free_mem_cgroup_pages(memcg,
-				GFP_HIGHUSER_MOVABLE, false);
+							GFP_HIGHUSER_MOVABLE,
+							false,
+							get_swappiness(memcg));
   		if (!progress)			retry_count--;
 	}
 	return ret;
@@ -1435,7 +1459,8 @@ int mem_cgroup_resize_memsw_limit(struct
 			break;
 
 		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true);
+		try_to_free_mem_cgroup_pages(memcg, GFP_HIGHUSER_MOVABLE, true,
+					     get_swappiness(memcg));
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
 			retry_count--;
@@ -1567,7 +1592,9 @@ try_to_free:
 			goto out;
 		}
 		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_HIGHUSER_MOVABLE, false);
+							GFP_HIGHUSER_MOVABLE,
+							false,
+							get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -1757,6 +1784,31 @@ static int mem_control_stat_show(struct 
 	return 0;
 }
 
+static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return get_swappiness(memcg);
+}
+
+static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
+				       u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	if (val > 100)
+		return -EINVAL;
+
+	if (cgrp->parent == NULL)
+		return -EBUSY;
+
+	spin_lock(&memcg->misc_lock);
+	memcg->swappiness = val;
+	spin_unlock(&memcg->misc_lock);
+
+	return 0;
+}
+
 
 static struct cftype mem_cgroup_files[] = {
 	{
@@ -1795,6 +1847,11 @@ static struct cftype mem_cgroup_files[] 
 		.write_u64 = mem_cgroup_hierarchy_write,
 		.read_u64 = mem_cgroup_hierarchy_read,
 	},
+	{
+		.name = "swappiness",
+		.read_u64 = mem_cgroup_swappiness_read,
+		.write_u64 = mem_cgroup_swappiness_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -1986,6 +2043,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	mem->last_scanned_child = NULL;
 	spin_lock_init(&mem->misc_lock);
 
+	if (parent)
+		mem->swappiness = get_swappiness(parent);
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1716,14 +1716,15 @@ unsigned long try_to_free_pages(struct z
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
-						gfp_t gfp_mask,
-					   bool noswap)
+					   gfp_t gfp_mask,
+					   bool noswap,
+					   unsigned int swappiness)
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
-		.swappiness = vm_swappiness,
+		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -214,7 +214,8 @@ static inline void lru_cache_add_active_
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap);
+						  gfp_t gfp_mask, bool noswap,
+						  unsigned int swappiness);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
Index: b/Documentation/controllers/memory.txt
===================================================================
--- a/Documentation/controllers/memory.txt
+++ b/Documentation/controllers/memory.txt
@@ -289,6 +289,12 @@ will be charged as a new owner of it.
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
   moved to the parent. If you want to avoid that, force_empty will be useful.
 
+5.2 swappiness
+  Similar to /proc/sys/vm/swappiness, but affecting one group only.
+
+  The root cgroup can't be changed this parameter.
+  it always use /proc/sys/vm/swappiness internally.
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
