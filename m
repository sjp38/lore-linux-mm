Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB9BDKtT024194
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 20:13:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 408A145DD7D
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:13:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0358545DD81
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:13:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA32EE08003
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:13:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67BD91DB803F
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:13:19 +0900 (JST)
Date: Tue, 9 Dec 2008 20:12:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/6] fix oom under hierarchy
Message-Id: <20081209201225.710e9f0b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyki <kamezawa.hiroyu@jp.fujitsu.com>

Current memcg's code other than memcontrol.c cannot handle hierarchy
in correct way.
In following,
	/opt/cgroup/01 limit=1G
	/opt/cgroup/01/A limit = unlimited
	/opt/cgroup/01/B limit = unlimited

searching tasks under '01' and cannot find bad process in 01/A and 01/B

After this.
	- OOM Killer check hierarchy and can Kill badprocess under hierarchy.

Changelog:
  - adjusted to the base kernel.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/memcontrol.h |    6 +++-
 mm/memcontrol.c            |   57 ++++++++++++++++++++++++++++++++++++++++++---
 mm/oom_kill.c              |    2 -
 3 files changed, 59 insertions(+), 6 deletions(-)

Index: mmotm-2.6.28-Dec08/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec08.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec08/mm/memcontrol.c
@@ -403,12 +403,36 @@ void mem_cgroup_move_lists(struct page *
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
+	cg = task_cgroup(rcu_dereference(mm->owner), mem_cgroup_subsys_id);
+	check = mcg->css.cgroup;
+
+	if (!mcg->use_hierarchy)
+		ret = (cg == check);
+	else
+		ret = cgroup_is_ancestor(cg, check);
+	rcu_read_unlock();
+
+	return ret;
+}
+
+
+int task_in_mem_cgroup(struct task_struct *task,
+				struct mem_cgroup *mem)
 {
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && mm_match_cgroup(task->mm, mem);
+	ret = mm_under_cgroup(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
@@ -662,6 +686,33 @@ static int mem_cgroup_hierarchical_recla
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
@@ -764,7 +815,7 @@ static int __mem_cgroup_try_charge(struc
 				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
 				mutex_unlock(&memcg_tasklist);
-				mem_over_limit->last_oom_jiffies = jiffies;
+				update_oom_jiffies(mem_over_limit);
 			}
 			goto nomem;
 		}
Index: mmotm-2.6.28-Dec08/mm/oom_kill.c
===================================================================
--- mmotm-2.6.28-Dec08.orig/mm/oom_kill.c
+++ mmotm-2.6.28-Dec08/mm/oom_kill.c
@@ -279,7 +279,7 @@ static struct task_struct *select_bad_pr
  *
  * Call with tasklist_lock read-locked.
  */
-static void dump_tasks(const struct mem_cgroup *mem)
+static void dump_tasks(struct mem_cgroup *mem)
 {
 	struct task_struct *g, *p;
 
Index: mmotm-2.6.28-Dec08/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec08.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec08/include/linux/memcontrol.h
@@ -65,7 +65,9 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+
+int task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *mem);
+
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
@@ -191,7 +193,7 @@ static inline int mm_match_cgroup(struct
 }
 
 static inline int task_in_mem_cgroup(struct task_struct *task,
-				     const struct mem_cgroup *mem)
+				     struct mem_cgroup *mem)
 {
 	return 1;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
