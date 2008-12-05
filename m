Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB58XICA010058
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 17:33:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8170645DD76
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:33:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6256045DD75
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:33:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28D581DB803A
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:33:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C9BBF1DB803C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 17:33:17 +0900 (JST)
Date: Fri, 5 Dec 2008 17:32:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] fix oom kill under hierarchy
Message-Id: <20081205173227.4df2ee5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081205172642.565661b1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyki <kamezawa.hiroyu@jp.fujitsu.com>

Current oom-kill by memcg cannot handle hierarchy in correct way.
This is a trial. please review.

After this.
	- OOM Killer check hierarchy and can Kill badprocess under hierarchy.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/cgroup.h     |    1 
 include/linux/memcontrol.h |    7 +++--
 kernel/cgroup.c            |   14 ++++++++++
 mm/memcontrol.c            |   59 ++++++++++++++++++++++++++++++++++++++++++---
 mm/oom_kill.c              |    4 +--
 5 files changed, 77 insertions(+), 8 deletions(-)

Index: mmotm-2.6.28-Dec03/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec03/mm/memcontrol.c
@@ -380,12 +380,38 @@ void mem_cgroup_move_lists(struct page *
 	mem_cgroup_add_lru_list(page, to);
 }
 
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
+static int mm_under_cgroup(struct mm_struct *mm, struct mem_cgroup *mcg)
+{
+	struct cgroup *cg, *check;
+	int ret = 0;
+
+	if (!mm)
+		return 0;
+
+	rcu_read_lock();
+
+	VM_BUG_ON(css_under_removal(&mcg->css));
+
+	cg = task_cgroup(rcu_dereference(mm->owner), mem_cgroup_subsys_id);
+	check = mcg->css.cgroup;
+
+	if (!mcg->use_hierarchy)
+		ret = (cg == check);
+	else
+		ret = cgroup_check_ancestor(cg, check);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+
+int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+				struct mem_cgroup *mem)
 {
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && mm_match_cgroup(task->mm, mem);
+	ret = mm_under_cgroup(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
@@ -636,6 +662,33 @@ static int mem_cgroup_hierarchical_recla
 	return ret;
 }
 
+void update_oom_jiffies(struct mem_cgroup *mem)
+{
+	struct cgroup *cgroup, *rootcg;
+	struct mem_cgroup *tmp;
+	int rootid, nextid, depth, found;
+
+	if (!mem->use_hierarchy) {
+		mem->last_oom_jiffies = jiffies;
+		return;
+	}
+	rootcg = mem->css.cgroup;
+	rootid = cgroup_id(rootcg);
+	depth = cgroup_depth(rootcg);
+	nextid = 0;
+	rcu_read_lock();
+	while (1) {
+		cgroup = cgroup_get_next(nextid, rootid, depth, &found);
+
+		if (!cgroup)
+			break;
+		tmp = mem_cgroup_from_cont(cgroup);
+		tmp->last_oom_jiffies = jiffies;
+		nextid = found + 1;
+	}
+	rcu_read_unlock();
+}
+
 bool mem_cgroup_oom_called(struct task_struct *task)
 {
 	bool ret = false;
@@ -735,7 +788,7 @@ static int __mem_cgroup_try_charge(struc
 			if (oom) {
 				mem_cgroup_out_of_memory(mem_over_limit,
 							gfp_mask);
-				mem_over_limit->last_oom_jiffies = jiffies;
+				update_oom_jiffies(mem_over_limit);
 			}
 			goto nomem;
 		}
Index: mmotm-2.6.28-Dec03/mm/oom_kill.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/mm/oom_kill.c
+++ mmotm-2.6.28-Dec03/mm/oom_kill.c
@@ -220,7 +220,7 @@ static struct task_struct *select_bad_pr
 		/* skip the init task */
 		if (is_global_init(p))
 			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (mem && !task_in_mem_cgroup_hierarchy(p, mem))
 			continue;
 
 		/*
@@ -292,7 +292,7 @@ static void dump_tasks(const struct mem_
 		 */
 		if (!p->mm)
 			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (mem && !task_in_mem_cgroup_hierarchy(p, mem))
 			continue;
 		if (!thread_group_leader(p))
 			continue;
Index: mmotm-2.6.28-Dec03/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec03.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec03/include/linux/cgroup.h
@@ -440,6 +440,7 @@ cgroup_get_next(int id, int rootid, int 
 /* get id and depth of cgroup */
 int cgroup_id(struct cgroup *cgroup);
 int cgroup_depth(struct cgroup *cgroup);
+int cgroup_check_ancestor(struct cgroup *cur, struct cgroup *ans);
 /* For delayed freeing of IDs */
 int cgroup_id_tryget(int id);
 void cgroup_id_put(int id);
Index: mmotm-2.6.28-Dec03/kernel/cgroup.c
===================================================================
--- mmotm-2.6.28-Dec03.orig/kernel/cgroup.c
+++ mmotm-2.6.28-Dec03/kernel/cgroup.c
@@ -805,6 +805,20 @@ cgroup_get_next(int id, int rootid, int 
 	*foundid = tmpid;
 	return ret;
 }
+/*
+ * called under RCU. (or some routine which prevent freeing cgroup)
+ */
+int cgroup_check_ancestor(struct cgroup *cur, struct cgroup *ans)
+{
+	struct cgroup_id *cid = rcu_dereference(cur->id);
+	struct cgroup_id *ansid = rcu_dereference(ans->id);
+
+	if (!cid || !ansid)
+		return 0;
+	if (cid->hierarchy_code[ansid->depth] == ansid->id)
+		return 1;
+	return 0;
+}
 
 /*
  * A couple of forward declarations required, due to cyclic reference loop:
Index: mmotm-2.6.28-Dec03/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec03.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec03/include/linux/memcontrol.h
@@ -67,7 +67,8 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+			struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
@@ -198,8 +199,8 @@ static inline int mm_match_cgroup(struct
 	return 1;
 }
 
-static inline int task_in_mem_cgroup(struct task_struct *task,
-				     const struct mem_cgroup *mem)
+static inline int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+				     struct mem_cgroup *mem)
 {
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
