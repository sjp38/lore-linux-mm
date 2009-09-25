Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 64DCD6B009C
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:29:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8TRMK017424
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:29:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 144F345DE60
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:29:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8BD345DE4D
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:29:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE224E18003
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:29:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 53DCDE18002
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:29:26 +0900 (JST)
Date: Fri, 25 Sep 2009 17:27:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 7/10] memcg: replace cont with cgroup
Message-Id: <20090925172716.04ec3a9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 memcontrol.c uses "cont" for indicating "cgroup" from historical reasons.
 It was called container in very young age.

 Now, memcontrol.c is a subsystem of Cgroups. Rename from_cont() to be
 from_cgroup(). This may be good for newcomers...they won't have to 
 consider what "cont" means and what variable name is appreciated.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   94 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 47 insertions(+), 47 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -248,9 +248,9 @@ static inline bool mem_cgroup_is_root(st
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
-static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
+static struct mem_cgroup *mem_cgroup_from_cgroup(struct cgroup *cgroup)
 {
-	return container_of(cgroup_subsys_state(cont,
+	return container_of(cgroup_subsys_state(cgroup,
 				mem_cgroup_subsys_id), struct mem_cgroup,
 				css);
 }
@@ -987,7 +987,7 @@ unsigned long mem_cgroup_isolate_pages(u
 					struct list_head *dst,
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
-					struct mem_cgroup *mem_cont,
+					struct mem_cgroup *mem,
 					int active, int file)
 {
 	unsigned long nr_taken = 0;
@@ -1002,8 +1002,8 @@ unsigned long mem_cgroup_isolate_pages(u
 	int lru = LRU_FILE * file + active;
 	int ret;
 
-	BUG_ON(!mem_cont);
-	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+	BUG_ON(!mem);
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
 	src = &mz->lists[lru];
 
 	scan = 0;
@@ -2178,7 +2178,7 @@ static int mem_cgroup_move_parent(struct
 		return -EINVAL;
 
 
-	parent = mem_cgroup_from_cont(pcg);
+	parent = mem_cgroup_from_cgroup(pcg);
 
 
 	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, page);
@@ -2219,7 +2219,7 @@ static DEFINE_MUTEX(set_limit_mutex);
 
 static u64 mem_cgroup_swappiness_read(struct cgroup *cgrp, struct cftype *cft)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cgrp);
 
 	return get_swappiness(memcg);
 }
@@ -2227,7 +2227,7 @@ static u64 mem_cgroup_swappiness_read(st
 static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 				       u64 val)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cgrp);
 	struct mem_cgroup *parent;
 
 	if (val > 100)
@@ -2236,7 +2236,7 @@ static int mem_cgroup_swappiness_write(s
 	if (cgrp->parent == NULL)
 		return -EINVAL;
 
-	parent = mem_cgroup_from_cont(cgrp->parent);
+	parent = mem_cgroup_from_cgroup(cgrp->parent);
 
 	cgroup_lock();
 
@@ -2512,27 +2512,27 @@ try_to_free:
 	goto out;
 }
 
-int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
+int mem_cgroup_force_empty_write(struct cgroup *cgroup, unsigned int event)
 {
-	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
+	return mem_cgroup_force_empty(mem_cgroup_from_cgroup(cgroup), true);
 }
 
 
-static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype *cft)
+static u64 mem_cgroup_hierarchy_read(struct cgroup *cgroup, struct cftype *cft)
 {
-	return mem_cgroup_from_cont(cont)->use_hierarchy;
+	return mem_cgroup_from_cgroup(cgroup)->use_hierarchy;
 }
 
-static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
+static int mem_cgroup_hierarchy_write(struct cgroup *cgroup, struct cftype *cft,
 					u64 val)
 {
 	int retval = 0;
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	struct cgroup *parent = cont->parent;
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
+	struct cgroup *parent = cgroup->parent;
 	struct mem_cgroup *parent_mem = NULL;
 
 	if (parent)
-		parent_mem = mem_cgroup_from_cont(parent);
+		parent_mem = mem_cgroup_from_cgroup(parent);
 
 	cgroup_lock();
 	/*
@@ -2545,7 +2545,7 @@ static int mem_cgroup_hierarchy_write(st
 	 */
 	if ((!parent_mem || !parent_mem->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (list_empty(&cont->children))
+		if (list_empty(&cgroup->children))
 			mem->use_hierarchy = val;
 		else
 			retval = -EBUSY;
@@ -2579,9 +2579,9 @@ mem_cgroup_get_recursive_idx_stat(struct
 	*val = d.val;
 }
 
-static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
+static u64 mem_cgroup_read(struct cgroup *cgroup, struct cftype *cft)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
 	u64 idx_val, val;
 	int type, name;
 
@@ -2624,10 +2624,10 @@ static u64 mem_cgroup_read(struct cgroup
  * The user of this function is...
  * RES_LIMIT.
  */
-static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
+static int mem_cgroup_write(struct cgroup *cgroup, struct cftype *cft,
 			    const char *buffer)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *memcg = mem_cgroup_from_cgroup(cgroup);
 	int type, name;
 	unsigned long long val;
 	int ret;
@@ -2684,7 +2684,7 @@ static void memcg_get_hierarchical_limit
 
 	while (cgroup->parent) {
 		cgroup = cgroup->parent;
-		memcg = mem_cgroup_from_cont(cgroup);
+		memcg = mem_cgroup_from_cgroup(cgroup);
 		if (!memcg->use_hierarchy)
 			break;
 		tmp = res_counter_read_u64(&memcg->res, RES_LIMIT);
@@ -2698,12 +2698,12 @@ out:
 	return;
 }
 
-static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_reset(struct cgroup *cgroup, unsigned int event)
 {
 	struct mem_cgroup *mem;
 	int type, name;
 
-	mem = mem_cgroup_from_cont(cont);
+	mem = mem_cgroup_from_cgroup(cgroup);
 	type = MEMFILE_TYPE(event);
 	name = MEMFILE_ATTR(event);
 	switch (name) {
@@ -2805,15 +2805,15 @@ mem_cgroup_get_total_stat(struct mem_cgr
 	mem_cgroup_walk_tree(mem, s, mem_cgroup_get_local_stat);
 }
 
-static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
+static int mem_control_stat_show(struct cgroup *cgroup, struct cftype *cft,
 				 struct cgroup_map_cb *cb)
 {
-	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
 	struct mcs_total_stat mystat;
 	int i;
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_local_stat(mem_cont, &mystat);
+	mem_cgroup_get_local_stat(mem, &mystat);
 
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
@@ -2824,14 +2824,14 @@ static int mem_control_stat_show(struct 
 	/* Hierarchical information */
 	{
 		unsigned long long limit, memsw_limit;
-		memcg_get_hierarchical_limit(mem_cont, &limit, &memsw_limit);
+		memcg_get_hierarchical_limit(mem, &limit, &memsw_limit);
 		cb->fill(cb, "hierarchical_memory_limit", limit);
 		if (do_swap_account)
 			cb->fill(cb, "hierarchical_memsw_limit", memsw_limit);
 	}
 
 	memset(&mystat, 0, sizeof(mystat));
-	mem_cgroup_get_total_stat(mem_cont, &mystat);
+	mem_cgroup_get_total_stat(mem, &mystat);
 	for (i = 0; i < NR_MCS_STAT; i++) {
 		if (i == MCS_SWAP && !do_swap_account)
 			continue;
@@ -2839,7 +2839,7 @@ static int mem_control_stat_show(struct 
 	}
 
 #ifdef CONFIG_DEBUG_VM
-	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont, NULL));
+	cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem, NULL));
 
 	{
 		int nid, zid;
@@ -2849,7 +2849,7 @@ static int mem_control_stat_show(struct 
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-				mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
+				mz = mem_cgroup_zoneinfo(mem, nid, zid);
 
 				recent_rotated[0] +=
 					mz->reclaim_stat.recent_rotated[0];
@@ -2953,8 +2953,8 @@ static struct cftype memsw_cgroup_files[
  * Moving tasks.
  */
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
-				struct cgroup *cont,
-				struct cgroup *old_cont,
+				struct cgroup *cgroup,
+				struct cgroup *old_cgroup,
 				struct task_struct *p,
 				bool threadgroup)
 {
@@ -2970,15 +2970,15 @@ static void mem_cgroup_move_task(struct 
  * memcg creation and destruction.
  */
 
-static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
+static int register_memsw_files(struct cgroup *cgroup, struct cgroup_subsys *ss)
 {
 	if (!do_swap_account)
 		return 0;
-	return cgroup_add_files(cont, ss, memsw_cgroup_files,
+	return cgroup_add_files(cgroup, ss, memsw_cgroup_files,
 				ARRAY_SIZE(memsw_cgroup_files));
 };
 #else
-static int register_memsw_files(struct cgroup *cont, struct cgroup_subsys *ss)
+static int register_memsw_files(struct cgroup *cgroup, struct cgroup_subsys *ss)
 {
 	return 0;
 }
@@ -3134,7 +3134,7 @@ static int mem_cgroup_soft_limit_tree_in
 }
 
 static struct cgroup_subsys_state * __ref
-mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
+mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgroup)
 {
 	struct mem_cgroup *mem, *parent;
 	long error = -ENOMEM;
@@ -3149,7 +3149,7 @@ mem_cgroup_create(struct cgroup_subsys *
 			goto free_out;
 
 	/* root ? */
-	if (cont->parent == NULL) {
+	if (cgroup->parent == NULL) {
 		enable_swap_cgroup();
 		parent = NULL;
 		root_mem_cgroup = mem;
@@ -3157,7 +3157,7 @@ mem_cgroup_create(struct cgroup_subsys *
 			goto free_out;
 
 	} else {
-		parent = mem_cgroup_from_cont(cont->parent);
+		parent = mem_cgroup_from_cgroup(cgroup->parent);
 		mem->use_hierarchy = parent->use_hierarchy;
 	}
 
@@ -3189,31 +3189,31 @@ free_out:
 }
 
 static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
-					struct cgroup *cont)
+					struct cgroup *cgroup)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
 
 	return mem_cgroup_force_empty(mem, false);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+				struct cgroup *cgroup)
 {
-	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *mem = mem_cgroup_from_cgroup(cgroup);
 
 	mem_cgroup_put(mem);
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,
-				struct cgroup *cont)
+				struct cgroup *cgroup)
 {
 	int ret;
 
-	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
+	ret = cgroup_add_files(cgroup, ss, mem_cgroup_files,
 				ARRAY_SIZE(mem_cgroup_files));
 
 	if (!ret)
-		ret = register_memsw_files(cont, ss);
+		ret = register_memsw_files(cgroup, ss);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
