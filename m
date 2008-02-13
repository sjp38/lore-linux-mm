Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1DFFMdH022908
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DFFLfH096924
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:22 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1DFFLIZ014798
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 10:15:21 -0500
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2008 20:42:29 +0530
Message-Id: <20080213151229.7529.17894.sendpatchset@localhost.localdomain>
In-Reply-To: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
Subject: [RFC] [PATCH 2/4] Add the soft limit interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Herbert Poetzl <herbert@13thfloor.at>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik Van Riel <riel@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


A new configuration file called soft_limit_in_bytes is added. The parsing
and configuration rules remain the same as for the limit_in_bytes user
interface.

A global list of all memory cgroups over their soft limit is maintained.
This list is then used to reclaim memory on global pressure. A cgroup is
removed from the list when the cgroup is deleted.

The global list is protected with a read-write spinlock.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   33 ++++++++++++++++++++++++++++++++-
 1 file changed, 32 insertions(+), 1 deletion(-)

diff -puN mm/memcontrol.c~memory-controller-add-soft-limit-interface mm/memcontrol.c
--- linux-2.6.24/mm/memcontrol.c~memory-controller-add-soft-limit-interface	2008-02-13 19:50:27.000000000 +0530
+++ linux-2.6.24-balbir/mm/memcontrol.c	2008-02-13 19:50:27.000000000 +0530
@@ -35,6 +35,10 @@
 
 struct cgroup_subsys mem_cgroup_subsys;
 static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
+static spinlock_t mem_cgroup_sl_list_lock;	/* spin lock that protects */
+						/* the list of cgroups over*/
+						/* their soft limit */
+static struct list_head mem_cgroup_sl_exceeded_list;
 
 /*
  * Statistics for memory cgroup.
@@ -136,6 +140,10 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+	/*
+	 * List of all mem_cgroup's that exceed their soft limit
+	 */
+	struct list_head sl_exceeded_list;
 };
 
 /*
@@ -679,6 +687,18 @@ retry:
 		goto retry;
 	}
 
+	/*
+	 * If we exceed our soft limit, we get added to the list of
+	 * cgroups over their soft limit
+	 */
+	if (!res_counter_check_under_limit(&mem->res, RES_SOFT_LIMIT)) {
+		spin_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
+		if (list_empty(&mem->sl_exceeded_list))
+			list_add_tail(&mem->sl_exceeded_list,
+						&mem_cgroup_sl_exceeded_list);
+		spin_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
+	}
+
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	/* Update statistics vector */
@@ -736,13 +756,14 @@ void mem_cgroup_uncharge(struct page_cgr
 	if (atomic_dec_and_test(&pc->ref_cnt)) {
 		page = pc->page;
 		mz = page_cgroup_zoneinfo(pc);
+		mem = pc->mem_cgroup;
 		/*
 		 * get page->cgroup and clear it under lock.
 		 * force_empty can drop page->cgroup without checking refcnt.
 		 */
 		unlock_page_cgroup(page);
+
 		if (clear_page_cgroup(page, pc) == pc) {
-			mem = pc->mem_cgroup;
 			css_put(&mem->css);
 			res_counter_uncharge(&mem->res, PAGE_SIZE);
 			spin_lock_irqsave(&mz->lru_lock, flags);
@@ -1046,6 +1067,12 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.open = mem_control_stat_open,
 	},
+	{
+		.name = "soft_limit_in_bytes",
+		.private = RES_SOFT_LIMIT,
+		.write = mem_cgroup_write,
+		.read = mem_cgroup_read,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1097,6 +1124,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		init_mm.mem_cgroup = mem;
+		INIT_LIST_HEAD(&mem->sl_exceeded_list);
+		spin_lock_init(&mem_cgroup_sl_list_lock);
+		INIT_LIST_HEAD(&mem_cgroup_sl_exceeded_list);
 	} else
 		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
 
@@ -1104,6 +1134,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		return NULL;
 
 	res_counter_init(&mem->res);
+	INIT_LIST_HEAD(&mem->sl_exceeded_list);
 
 	memset(&mem->info, 0, sizeof(mem->info));
 
diff -puN include/linux/memcontrol.h~memory-controller-add-soft-limit-interface include/linux/memcontrol.h
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
