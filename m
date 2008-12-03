Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB35AXU1030372
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:10:33 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 446DF45DD78
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:10:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2169745DD7C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:10:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 033AD1DB803C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:10:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C4951DB8037
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:10:32 +0900 (JST)
Date: Wed, 3 Dec 2008 14:09:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  18/21] memcg-swappiness.patch
Message-Id: <20081203140943.bc451023.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Currently, /proc/sys/vm/swappiness can change swappiness ratio for global reclaim.
However, memcg reclaim doesn't have tuning parameter for itself.

In general, the optimal swappiness depend on workload.
(e.g. hpc workload need to low swappiness than the others.)

Then, per cgroup swappiness improve administrator tunability.

Changelog:
 - modified for stacking file.
 - return -EINVAL rather than -EBUSY.
 - fixed hierarchy handling.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 Documentation/controllers/memory.txt |    9 ++++
 include/linux/swap.h                 |    3 -
 mm/memcontrol.c                      |   78 +++++++++++++++++++++++++++++++----
 mm/vmscan.c                          |    7 +--
 4 files changed, 86 insertions(+), 11 deletions(-)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -164,6 +164,9 @@ struct mem_cgroup {
 	int		obsolete;
 	atomic_t	refcnt;
 
+	unsigned int	swappiness;
+
+
 	unsigned int inactive_ratio;
 
 	/*
@@ -630,6 +633,22 @@ static bool mem_cgroup_check_under_limit
 	return false;
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
+	spin_lock(&memcg->reclaim_param_lock);
+	swappiness = memcg->swappiness;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	return swappiness;
+}
+
 /*
  * Dance down the hierarchy if needed to reclaim memory. We remember the
  * last child we reclaimed from, so that we don't end up penalizing
@@ -650,7 +669,8 @@ static int mem_cgroup_hierarchical_recla
 	 * but there might be left over accounting, even after children
 	 * have left.
 	 */
-	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
+	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
+					   get_swappiness(root_mem));
 	if (mem_cgroup_check_under_limit(root_mem))
 		return 0;
 	if (!root_mem->use_hierarchy)
@@ -666,7 +686,8 @@ static int mem_cgroup_hierarchical_recla
 			cgroup_unlock();
 			continue;
 		}
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
+		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
+						   get_swappiness(next_mem));
 		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
 		cgroup_lock();
@@ -1394,7 +1415,8 @@ int mem_cgroup_shrink_usage(struct mm_st
 	rcu_read_unlock();
 
 	do {
-		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true);
+		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask, true,
+							get_swappiness(mem));
 		progress += mem_cgroup_check_under_limit(mem);
 	} while (!progress && --retry);
 
@@ -1462,7 +1484,9 @@ static int mem_cgroup_resize_limit(struc
 			break;
 
 		progress = try_to_free_mem_cgroup_pages(memcg,
-				GFP_KERNEL, false);
+							GFP_KERNEL,
+							false,
+							get_swappiness(memcg));
   		if (!progress)			retry_count--;
 	}
 
@@ -1506,7 +1530,8 @@ int mem_cgroup_resize_memsw_limit(struct
 			break;
 
 		oldusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
-		try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL, true);
+		try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL, true,
+					     get_swappiness(memcg));
 		curusage = res_counter_read_u64(&memcg->memsw, RES_USAGE);
 		if (curusage >= oldusage)
 			retry_count--;
@@ -1637,8 +1662,8 @@ try_to_free:
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem,
-						  GFP_KERNEL, false);
+		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
+						false, get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -1858,6 +1883,37 @@ static int mem_control_stat_show(struct 
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
+	struct mem_cgroup *parent;
+	if (val > 100)
+		return -EINVAL;
+
+	if (cgrp->parent == NULL)
+		return -EINVAL;
+
+	parent = mem_cgroup_from_cont(cgrp->parent);
+	/* If under hierarchy, only empty-root can set this value */
+	if ((parent->use_hierarchy) ||
+	    (memcg->use_hierarchy && !list_empty(&cgrp->children)))
+		return -EINVAL;
+
+	spin_lock(&memcg->reclaim_param_lock);
+	memcg->swappiness = val;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	return 0;
+}
+
 
 static struct cftype mem_cgroup_files[] = {
 	{
@@ -1896,6 +1952,11 @@ static struct cftype mem_cgroup_files[] 
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
@@ -2087,6 +2148,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	mem->last_scanned_child = NULL;
 	spin_lock_init(&mem->reclaim_param_lock);
 
+	if (parent)
+		mem->swappiness = get_swappiness(parent);
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
Index: mmotm-2.6.28-Dec02/mm/vmscan.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/vmscan.c
+++ mmotm-2.6.28-Dec02/mm/vmscan.c
@@ -1759,14 +1759,15 @@ unsigned long try_to_free_pages(struct z
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
Index: mmotm-2.6.28-Dec02/include/linux/swap.h
===================================================================
--- mmotm-2.6.28-Dec02.orig/include/linux/swap.h
+++ mmotm-2.6.28-Dec02/include/linux/swap.h
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
Index: mmotm-2.6.28-Dec02/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.28-Dec02.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.28-Dec02/Documentation/controllers/memory.txt
@@ -314,6 +314,15 @@ will be charged as a new owner of it.
 	showing for better debug please see the code for meanings.
 
 
+5.3 swappiness
+  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
+
+  Following cgroup's swapiness can't be changed.
+  - root cgroup (uses /proc/sys/vm/swappiness).
+  - a cgroup which uses hierarchy and it has child cgroup.
+  - a cgroup which uses hierarchy and not the root of hierarchy.
+
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
