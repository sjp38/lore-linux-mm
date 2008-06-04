Date: Wed, 4 Jun 2008 14:03:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] memcg: hardwall hierarhcy for memcg
Message-Id: <20080604140329.8db1b67e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hard-Wall hierarchy support for memcg.
 - new member hierarchy_model is added to memcg.

Only root cgroup can modify this only when there is no children.

Adds following functions for supporting HARDWALL hierarchy.
 - try to reclaim memory at the change of "limit".
 - try to reclaim all memory at force_empty
 - returns resources to the parent at destroy.

Changelog v2->v3
 - added documentation.
 - hierarhcy_model parameter is added.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/memory.txt |   27 +++++-
 mm/memcontrol.c                      |  156 ++++++++++++++++++++++++++++++++++-
 2 files changed, 178 insertions(+), 5 deletions(-)

Index: temp-2.6.26-rc2-mm1/mm/memcontrol.c
===================================================================
--- temp-2.6.26-rc2-mm1.orig/mm/memcontrol.c
+++ temp-2.6.26-rc2-mm1/mm/memcontrol.c
@@ -137,6 +137,8 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+
+	int	hierarchy_model; /* used hierarchical policy */
 	/*
 	 * statistics.
 	 */
@@ -144,6 +146,10 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
+
+#define MEMCG_NO_HIERARCHY	(0)
+#define MEMCG_HARDWALL_HIERARCHY	(1)
+
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
  * lock.  We need to ensure that page->page_cgroup is at least two
@@ -792,6 +798,89 @@ int mem_cgroup_shrink_usage(struct mm_st
 }
 
 /*
+ * Memory Controller hierarchy support.
+ */
+
+/*
+ * shrink usage to be res->usage + val < res->limit.
+ */
+
+int memcg_shrink_val(struct res_counter *cnt, unsigned long long val)
+{
+	struct mem_cgroup *memcg = container_of(cnt, struct mem_cgroup, res);
+	unsigned long flags;
+	int ret = 1;
+	int progress = 1;
+
+retry:
+	spin_lock_irqsave(&cnt->lock, flags);
+	/* Need to shrink ? */
+	if (cnt->usage + val <= cnt->limit)
+		ret = 0;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+
+	if (!ret)
+		return 0;
+
+	if (!progress)
+		return 1;
+	progress = try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL);
+
+	goto retry;
+}
+
+/*
+ * For Hard Wall Hierarchy.
+ */
+
+int mem_cgroup_resize_callback(struct res_counter *cnt,
+			unsigned long long val, int what)
+{
+	unsigned long flags, borrow;
+	unsigned long long diffs;
+	int ret = 0;
+
+	BUG_ON(what != RES_LIMIT);
+
+	/* Is this under hierarchy ? */
+	if (!cnt->parent) {
+		spin_lock_irqsave(&cnt->lock, flags);
+		cnt->limit = val;
+		spin_unlock_irqrestore(&cnt->lock, flags);
+		return 0;
+	}
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (val > cnt->limit) {
+		diffs = val - cnt->limit;
+		borrow = 1;
+	} else {
+		diffs = cnt->limit - val;
+		borrow = 0;
+	}
+	spin_unlock_irqrestore(&cnt->lock, flags);
+
+	if (borrow)
+		ret = res_counter_move_resource(cnt,diffs,
+					memcg_shrink_val,
+					MEM_CGROUP_RECLAIM_RETRIES);
+	else
+		ret = res_counter_return_resource(cnt, diffs,
+					memcg_shrink_val,
+					MEM_CGROUP_RECLAIM_RETRIES);
+	return ret;
+}
+
+
+void memcg_shrink_all(struct mem_cgroup *mem)
+{
+	unsigned long long val;
+
+	val = res_counter_read_u64(&mem->res, RES_LIMIT);
+	memcg_shrink_val(&mem->res, val);
+}
+
+/*
  * This routine traverse page_cgroup in given list and drop them all.
  * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
  */
@@ -848,6 +937,8 @@ static int mem_cgroup_force_empty(struct
 	if (mem_cgroup_subsys.disabled)
 		return 0;
 
+	memcg_shrink_all(mem);
+
 	css_get(&mem->css);
 	/*
 	 * page reclaim code (kswapd etc..) will move pages between
@@ -896,11 +987,44 @@ static ssize_t mem_cgroup_write(struct c
 				struct file *file, const char __user *userbuf,
 				size_t nbytes, loff_t *ppos)
 {
-	return res_counter_write(&mem_cgroup_from_cont(cont)->res,
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
+
+	if (cft->private != RES_LIMIT
+		|| !cont->parent
+		|| memcg->hierarchy_model == MEMCG_NO_HIERARCHY)
+		return res_counter_write(&memcg->res, cft->private, userbuf,
+			nbytes, ppos, mem_cgroup_write_strategy, NULL);
+	else
+		return res_counter_write(&memcg->res,
 				cft->private, userbuf, nbytes, ppos,
-				mem_cgroup_write_strategy);
+				mem_cgroup_write_strategy,
+				mem_cgroup_resize_callback);
+}
+
+
+static u64 mem_cgroup_read_hierarchy(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	return memcg->hierarchy_model;
+}
+
+static int mem_cgroup_write_hierarchy(struct cgroup *cgrp, struct cftype *cft,
+				u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	/* chage policy is allowed to ROOT cgroup && no children */
+	if (cgrp->parent)
+		return -EINVAL;
+	if (!list_empty(&cgrp->children))
+		return -EINVAL;
+	if (val == 0 || val == 1) {
+		memcg->hierarchy_model = val;
+		return 0;
+	}
+	return -EINVAL;
 }
 
+
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 {
 	struct mem_cgroup *mem;
@@ -992,6 +1116,16 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+	{
+		.name = "hierarchy_model",
+		.read_u64 = mem_cgroup_read_hierarchy,
+		.write_u64 = mem_cgroup_write_hierarchy,
+	},
+	{
+		.name = "assigned_to_child",
+		.private = RES_FOR_CHILDREN,
+		.read_u64 = mem_cgroup_read,
+	},
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -1056,19 +1190,27 @@ static void mem_cgroup_free(struct mem_c
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *parent;
 	int node;
 
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		parent = NULL;
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
 			return ERR_PTR(-ENOMEM);
+		parent = mem_cgroup_from_cont(cont->parent);
 	}
 
-	res_counter_init(&mem->res);
+	if (!parent || parent->hierarchy_model == MEMCG_NO_HIERARCHY) {
+		res_counter_init(&mem->res);
+		mem->hierarchy_model = MEMCG_NO_HIERARCHY;
+	} else {
+		res_counter_init_hierarchy(&mem->res, &parent->res);
+		mem->hierarchy_model = parent->hierarchy_model;
+	}
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
@@ -1096,6 +1238,12 @@ static void mem_cgroup_destroy(struct cg
 	int node;
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+	if (cont->parent &&
+	    mem->hierarchy_model == MEMCG_HARDWALL_HIERARCHY) {
+		/* we did what we can...just returns what we borrow */
+		res_counter_return_resource(&mem->res, -1, NULL, 0);
+	}
+
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
Index: temp-2.6.26-rc2-mm1/Documentation/controllers/memory.txt
===================================================================
--- temp-2.6.26-rc2-mm1.orig/Documentation/controllers/memory.txt
+++ temp-2.6.26-rc2-mm1/Documentation/controllers/memory.txt
@@ -237,12 +237,37 @@ cgroup might have some charge associated
 tasks have migrated away from it. Such charges are automatically dropped at
 rmdir() if there are no tasks.
 
-5. TODO
+5. Hierarchy Model
+  the kernel supports following kinds of hierarchy models.
+  (your middle-ware may support others based on this.)
+
+  5-a. Independent Hierarchy
+  There are no relationship between any cgroups, even among a parent and
+  children. This is the default mode. To use this hierarchy, write 0
+  to root cgroup's memory.hierarchy_model
+  echo 0 > .../memory.hierarchy_model.
+
+  5-b. Hardwall Hierarchy.
+  The resource has to be moved from the parent to the child before use it.
+  When a child's limit is set to 'val', val of the resource is moved from
+  the parent to the child. the parent's usage += val.
+  The amount of children's usage is reported by the file
+
+  - memory.assigned_to_child
+
+  This policy doesn't provide sophisticated automatic resource balancing in
+  the kernel. But this is very good for strict resource isolation. Users
+  can get high predictability of behavior of applications if this is used
+  under proper environments.
+
+
+6. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
 3. Teach controller to account for shared-pages
 4. Start reclamation when the limit is lowered
+   (this is already done in Hardwall Hierarchy)
 5. Start reclamation in the background when the limit is
    not yet hit but the usage is getting closer
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
