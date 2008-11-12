Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mACBKmH1002611
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:20:48 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mACBLsCZ4837626
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:21:58 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mACBLiSr009224
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:21:45 +1100
Date: Wed, 12 Nov 2008 16:51:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
Message-ID: <20081112112141.GA25386@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop> <20081111123417.6566.52629.sendpatchset@balbir-laptop> <20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com> <491A6E71.5010307@linux.vnet.ibm.com> <20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com> <491A7345.4090500@linux.vnet.ibm.com> <20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com> <491A7637.3050402@linux.vnet.ibm.com> <20081112153314.a7162192.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081112153314.a7162192.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-11-12 15:33:14]:

> On Wed, 12 Nov 2008 11:52:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > KAMEZAWA Hiroyuki wrote:
> > > On Wed, 12 Nov 2008 11:40:13 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > >> I think of it as easy to update - as in the modularity, you can plug out
> > >> hierarchical reclaim easily and implement your own hierarchical reclaim.
> > >>
> > > When I do so, I'll rewrite all, again.
> > > 
> > 
> > I don't intend to ask you to rewrite it, rewrite all, I meant you as in a
> > generic person. With hierarchy we will need weighted reclaim, which I'll add in
> > later.
> > 
> > >>> Can you make this code iterative rather than recursive ?
> > >>>
> > >>> I don't like this kind of recursive call with complexed lock/unlock.
> > >> I tried an iterative version, which ended up looking very ugly. I think the
> > >> recursive version is easier to understand. What we do is a DFS walk - pretty
> > >> standard algorithm.
> > >>
> > > But recursive one is not good for search-and-try algorithm.
> > 
> > OK, I'll post the iterative algorithm, but it is going to be dirty :)
> > 
> Ah, thanks. I think maybe you're right that ittrative one is dirty.
> I want to compare before going further. 
> Thank you for your patience.

Here is the iterative version of this patch. I tested it in my
test environment. NOTE: The cgroup_locked check is still present, I'll
remove that shortly after your patch is accepted.

This patch introduces hierarchical reclaim. When an ancestor goes over its
limit, the charging routine points to the parent that is above its limit.
The reclaim process then starts from the last scanned child of the ancestor
and reclaims until the ancestor goes below its limit.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |  190 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 163 insertions(+), 27 deletions(-)

diff -puN mm/memcontrol.c~memcg-hierarchical-reclaim mm/memcontrol.c
--- linux-2.6.28-rc2/mm/memcontrol.c~memcg-hierarchical-reclaim	2008-11-11 17:51:56.000000000 +0530
+++ linux-2.6.28-rc2-balbir/mm/memcontrol.c	2008-11-12 16:49:42.000000000 +0530
@@ -132,6 +132,11 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+	/*
+	 * While reclaiming in a hiearchy, we cache the last child we
+	 * reclaimed from. Protected by cgroup_lock()
+	 */
+	struct mem_cgroup *last_scanned_child;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -467,6 +472,137 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+static struct mem_cgroup *
+mem_cgroup_from_res_counter(struct res_counter *counter)
+{
+	return container_of(counter, struct mem_cgroup, res);
+}
+
+/*
+ * Dance down the hierarchy if needed to reclaim memory. We remember the
+ * last child we reclaimed from, so that we don't end up penalizing
+ * one child extensively based on its position in the children list.
+ *
+ * root_mem is the original ancestor that we've been reclaim from.
+ */
+static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *mem,
+						struct mem_cgroup *root_mem,
+						gfp_t gfp_mask)
+{
+	struct cgroup *cgroup;
+	struct mem_cgroup *mem_child;
+	int ret = 0;
+
+	/*
+	 * Reclaim unconditionally and don't check for return value.
+	 * We need to reclaim in the current group and down the tree.
+	 * One might think about checking for children before reclaiming,
+	 * but there might be left over accounting, even after children
+	 * have left.
+	 */
+reclaim_down:
+	ret = try_to_free_mem_cgroup_pages(mem, gfp_mask);
+
+	if (res_counter_check_under_limit(&root_mem->res))
+		goto loop_next;
+
+	cgroup_lock();
+
+	if (list_empty(&mem->css.cgroup->children)) {
+		cgroup_unlock();
+		goto loop_next;
+	}
+
+	/*
+	 * Scan all children under the mem_cgroup mem
+	 */
+	if (!mem->last_scanned_child)
+		cgroup = list_first_entry(&mem->css.cgroup->children,
+				struct cgroup, sibling);
+	else {
+		struct list_head *next;
+		cgroup = mem->last_scanned_child->css.cgroup;
+		next = cgroup->sibling.next;
+
+		if (next == &cgroup->parent->children)
+			cgroup = list_first_entry(&mem->css.cgroup->children,
+							struct cgroup, sibling);
+		else
+			cgroup = container_of(next, struct cgroup, sibling);
+	}
+
+reclaim_up:
+	do {
+		struct list_head *next;
+
+		mem_child = mem_cgroup_from_cont(cgroup);
+		cgroup_unlock();
+
+		mem = mem_child;
+		goto reclaim_down;
+
+loop_next:
+		cgroup_lock();
+		mem->last_scanned_child = mem_child;
+
+		/*
+		 * Since we gave up the lock, it is time to
+		 * start from last cgroup
+		 */
+		cgroup = mem->last_scanned_child->css.cgroup;
+		next = cgroup->sibling.next;
+
+		if (next == &cgroup->parent->children)
+			break;
+		else
+			cgroup = container_of(next, struct cgroup, sibling);
+	} while (cgroup != &cgroup->parent->children);
+
+	cgroup = cgroup->parent;
+	mem = mem_cgroup_from_cont(cgroup);
+	if (mem == root_mem)
+		goto done;
+	goto reclaim_up;
+done:
+	cgroup_unlock();
+	return ret;
+}
+
+/*
+ * Charge memory cgroup mem and check if it is over its limit. If so, reclaim
+ * from mem.
+ */
+static int mem_cgroup_charge_and_reclaim(struct mem_cgroup *mem, gfp_t gfp_mask)
+{
+	int ret = 0;
+	unsigned long nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+	struct res_counter *fail_res;
+	struct mem_cgroup *mem_over_limit;
+
+	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
+		if (!(gfp_mask & __GFP_WAIT))
+			goto out;
+
+		/*
+		 * Is one of our ancestors over their limit?
+		 */
+		if (fail_res)
+			mem_over_limit = mem_cgroup_from_res_counter(fail_res);
+		else
+			mem_over_limit = mem;
+
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit,
+							mem_over_limit,
+							gfp_mask);
+
+		if (!nr_retries--) {
+			mem_cgroup_out_of_memory(mem, gfp_mask);
+			goto out;
+		}
+	}
+out:
+	return ret;
+}
 
 /**
  * mem_cgroup_try_charge - get charge of PAGE_SIZE.
@@ -484,8 +620,7 @@ int mem_cgroup_try_charge(struct mm_stru
 			gfp_t gfp_mask, struct mem_cgroup **memcg)
 {
 	struct mem_cgroup *mem;
-	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct res_counter *fail_res;
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -510,29 +645,9 @@ int mem_cgroup_try_charge(struct mm_stru
 		css_get(&mem->css);
 	}
 
+	if (mem_cgroup_charge_and_reclaim(mem, gfp_mask))
+		goto nomem;
 
-	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE, &fail_res))) {
-		if (!(gfp_mask & __GFP_WAIT))
-			goto nomem;
-
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
-			continue;
-
-		/*
-		 * try_to_free_mem_cgroup_pages() might not give us a full
-		 * picture of reclaim. Some pages are reclaimed and might be
-		 * moved to swap cache or just unmapped from the cgroup.
-		 * Check the limit again to see if the reclaim reduced the
-		 * current usage of the cgroup before giving up
-		 */
-		if (res_counter_check_under_limit(&mem->res))
-			continue;
-
-		if (!nr_retries--) {
-			mem_cgroup_out_of_memory(mem, gfp_mask);
-			goto nomem;
-		}
-	}
 	return 0;
 nomem:
 	css_put(&mem->css);
@@ -945,7 +1060,7 @@ static void mem_cgroup_force_empty_list(
  * make mem_cgroup's charge to be 0 if there is no task.
  * This enables deleting this mem_cgroup.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *mem)
+static int mem_cgroup_force_empty(struct mem_cgroup *mem, bool cgroup_locked)
 {
 	int ret = -EBUSY;
 	int node, zid;
@@ -959,8 +1074,20 @@ static int mem_cgroup_force_empty(struct
 	while (mem->res.usage > 0) {
 		if (atomic_read(&mem->css.cgroup->count) > 0)
 			goto out;
+
+		/*
+		 * We need to give up the cgroup lock if it is held, since
+		 * it creates the potential for deadlock. cgroup_mutex should
+		 * be acquired after cpu_hotplug lock. In this path, we
+		 * acquire the cpu_hotplug lock after acquiring the cgroup_mutex
+		 * Giving it up should be OK
+		 */
+		if (cgroup_locked)
+			cgroup_unlock();
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
+		if (cgroup_locked)
+			cgroup_lock();
 		for_each_node_state(node, N_POSSIBLE)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 				struct mem_cgroup_per_zone *mz;
@@ -1025,7 +1152,7 @@ static int mem_cgroup_reset(struct cgrou
 
 static int mem_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
+	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), false);
 }
 
 static const struct mem_cgroup_stat_desc {
@@ -1195,6 +1322,8 @@ mem_cgroup_create(struct cgroup_subsys *
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
+	mem->last_scanned_child = NULL;
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
@@ -1208,7 +1337,7 @@ static void mem_cgroup_pre_destroy(struc
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem_cgroup_force_empty(mem);
+	mem_cgroup_force_empty(mem, true);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
@@ -1217,6 +1346,13 @@ static void mem_cgroup_destroy(struct cg
 	int node;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	if (cont->parent) {
+		struct mem_cgroup *parent_mem =
+			mem_cgroup_from_cont(cont->parent);
+		if (parent_mem->last_scanned_child == mem)
+			parent_mem->last_scanned_child = NULL;
+	}
+
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
