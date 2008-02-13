Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1DFFZ7f015107
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:35 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DFFZsm233864
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:35 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DFFYhJ000668
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:35 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2008 20:42:42 +0530
Message-Id: <20080213151242.7529.79924.sendpatchset@localhost.localdomain>
In-Reply-To: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
Subject: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under memory pressure
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


The global list of all cgroups over their soft limit is scanned under
memory pressure. We call mem_cgroup_pushback_groups_over_soft_limit
from __alloc_pages() prior to calling try_to_free_pages(), in an attempt
to rescue memory from groups that are using memory above their soft limit.
If this attempt is unsuccessfull, we call try_to_free_pages() and take
the normal global reclaim path.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h  |    9 +++++
 include/linux/res_counter.h |   11 +++++++
 include/linux/swap.h        |    4 +-
 mm/memcontrol.c             |   67 ++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c             |   10 +++++-
 mm/vmscan.c                 |   12 +++++--
 6 files changed, 101 insertions(+), 12 deletions(-)

diff -puN mm/vmscan.c~memory-controller-reclaim-on-contention mm/vmscan.c
--- linux-2.6.24/mm/vmscan.c~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/mm/vmscan.c	2008-02-13 20:16:04.000000000 +0530
@@ -1440,22 +1440,26 @@ unsigned long try_to_free_pages(struct z
 #ifdef CONFIG_CGROUP_MEM_CONT
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
-						gfp_t gfp_mask)
+						gfp_t gfp_mask,
+						unsigned long nr_pages,
+						struct zone **zones)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.may_swap = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.swap_cluster_max = nr_pages,
 		.swappiness = vm_swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
-	struct zone **zones;
 	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
-	zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
+	if (!zones)
+		zones =
+		NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
+
 	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
 		return 1;
 	return 0;
diff -puN include/linux/memcontrol.h~memory-controller-reclaim-on-contention include/linux/memcontrol.h
--- linux-2.6.24/include/linux/memcontrol.h~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/include/linux/memcontrol.h	2008-02-13 20:19:20.000000000 +0530
@@ -76,6 +76,8 @@ extern long mem_cgroup_calc_reclaim_acti
 				struct zone *zone, int priority);
 extern long mem_cgroup_calc_reclaim_inactive(struct mem_cgroup *mem,
 				struct zone *zone, int priority);
+extern unsigned long
+mem_cgroup_pushback_groups_over_soft_limit(struct zone **zones, gfp_t gfp_mask);
 
 #else /* CONFIG_CGROUP_MEM_CONT */
 static inline void mm_init_cgroup(struct mm_struct *mm,
@@ -184,6 +186,13 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static inline unsigned long
+mem_cgroup_pushback_groups_over_soft_limit(struct zone **zones, gfp_t gfp_mask)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff -puN mm/memcontrol.c~memory-controller-reclaim-on-contention mm/memcontrol.c
--- linux-2.6.24/mm/memcontrol.c~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/mm/memcontrol.c	2008-02-13 20:16:04.000000000 +0530
@@ -35,7 +35,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
-static spinlock_t mem_cgroup_sl_list_lock;	/* spin lock that protects */
+static rwlock_t mem_cgroup_sl_list_lock;	/* spin lock that protects */
 						/* the list of cgroups over*/
 						/* their soft limit */
 static struct list_head mem_cgroup_sl_exceeded_list;
@@ -646,7 +646,8 @@ retry:
 		if (!(gfp_mask & __GFP_WAIT))
 			goto out;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
+		if (try_to_free_mem_cgroup_pages(mem, gfp_mask,
+							SWAP_CLUSTER_MAX, NULL))
 			continue;
 
 		/*
@@ -692,11 +693,11 @@ retry:
 	 * cgroups over their soft limit
 	 */
 	if (!res_counter_check_under_limit(&mem->res, RES_SOFT_LIMIT)) {
-		spin_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
+		write_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
 		if (list_empty(&mem->sl_exceeded_list))
 			list_add_tail(&mem->sl_exceeded_list,
 						&mem_cgroup_sl_exceeded_list);
-		spin_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
+		write_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
 	}
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -928,7 +929,55 @@ out:
 	return ret;
 }
 
+/*
+ * Free all control groups, which are over their soft limit
+ */
+unsigned long mem_cgroup_pushback_groups_over_soft_limit(struct zone **zones,
+								gfp_t gfp_mask)
+{
+	struct mem_cgroup *mem;
+	unsigned long nr_pages;
+	long long nr_bytes_over_sl;
+	unsigned long ret = 0;
+	unsigned long flags;
+	struct list_head reclaimed_groups;
 
+	INIT_LIST_HEAD(&reclaimed_groups);
+	read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
+	while (!list_empty(&mem_cgroup_sl_exceeded_list)) {
+		mem = list_first_entry(&mem_cgroup_sl_exceeded_list,
+				struct mem_cgroup, sl_exceeded_list);
+		list_move(&mem->sl_exceeded_list, &reclaimed_groups);
+		read_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
+
+		nr_bytes_over_sl = res_counter_sl_excess(&mem->res);
+		if (nr_bytes_over_sl <= 0)
+			goto next;
+		nr_pages = (nr_bytes_over_sl >> PAGE_SHIFT);
+		ret += try_to_free_mem_cgroup_pages(mem, gfp_mask, nr_pages,
+							zones);
+next:
+		read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
+	}
+
+	while (!list_empty(&reclaimed_groups)) {
+		/*
+		 * Check again to see if we've gone below the soft
+		 * limit. XXX: Consider giving up the &mem_cgroup_sl_list_lock
+		 * before calling res_counter_sl_excess.
+		 */
+		mem = list_first_entry(&reclaimed_groups, struct mem_cgroup,
+					sl_exceeded_list);
+		nr_bytes_over_sl = res_counter_sl_excess(&mem->res);
+		if (nr_bytes_over_sl <= 0)
+			list_del_init(&mem->sl_exceeded_list);
+		else
+			list_move(&mem->sl_exceeded_list,
+				&mem_cgroup_sl_exceeded_list);
+	}
+	read_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
+	return ret;
+}
 
 int mem_cgroup_write_strategy(char *buf, unsigned long long *tmp)
 {
@@ -1124,8 +1173,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		init_mm.mem_cgroup = mem;
-		INIT_LIST_HEAD(&mem->sl_exceeded_list);
-		spin_lock_init(&mem_cgroup_sl_list_lock);
+		rwlock_init(&mem_cgroup_sl_list_lock);
 		INIT_LIST_HEAD(&mem_cgroup_sl_exceeded_list);
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
@@ -1155,7 +1203,14 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	unsigned long flags;
+
 	mem_cgroup_force_empty(mem);
+
+	write_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
+	if (!list_empty(&mem->sl_exceeded_list))
+		list_del_init(&mem->sl_exceeded_list);
+	write_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
diff -puN include/linux/res_counter.h~memory-controller-reclaim-on-contention include/linux/res_counter.h
--- linux-2.6.24/include/linux/res_counter.h~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/include/linux/res_counter.h	2008-02-13 20:16:04.000000000 +0530
@@ -142,4 +142,15 @@ static inline bool res_counter_check_und
 	return ret;
 }
 
+static inline long long res_counter_sl_excess(struct res_counter *cnt)
+{
+	unsigned long flags;
+	long long ret;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = cnt->usage - cnt->soft_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 #endif
diff -puN kernel/res_counter.c~memory-controller-reclaim-on-contention kernel/res_counter.c
diff -puN mm/page_alloc.c~memory-controller-reclaim-on-contention mm/page_alloc.c
--- linux-2.6.24/mm/page_alloc.c~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/mm/page_alloc.c	2008-02-13 20:16:04.000000000 +0530
@@ -1635,7 +1635,15 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist->zones, order, gfp_mask);
+	/*
+	 * First reclaim from all memory control groups over their
+	 * soft limit
+	 */
+	did_some_progress = mem_cgroup_pushback_groups_over_soft_limit(
+						zonelist->zones, gfp_mask);
+	if (!did_some_progress)
+		did_some_progress =
+			try_to_free_pages(zonelist->zones, order, gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff -puN include/linux/swap.h~memory-controller-reclaim-on-contention include/linux/swap.h
--- linux-2.6.24/include/linux/swap.h~memory-controller-reclaim-on-contention	2008-02-13 20:16:04.000000000 +0530
+++ linux-2.6.24-balbir/include/linux/swap.h	2008-02-13 20:16:04.000000000 +0530
@@ -184,7 +184,9 @@ extern void swap_setup(void);
 extern unsigned long try_to_free_pages(struct zone **zones, int order,
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-							gfp_t gfp_mask);
+							gfp_t gfp_mask,
+							unsigned long nr_pages,
+							struct zone **zones);
 extern int __isolate_lru_page(struct page *page, int mode);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
