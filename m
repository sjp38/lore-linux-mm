Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BE6A46B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 04:40:26 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M9eOTq002051
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 18:40:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7135C45DE50
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:40:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5627945DD71
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:40:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B814E18003
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:40:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D0C25E18002
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:40:23 +0900 (JST)
Date: Thu, 22 Jan 2009 18:39:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [FIX][PATCH 5/7] memcg : fix OOM Killer behavior under memcg
Message-Id: <20090122183919.1604c637.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch tries to fix OOM Killer problems caused by hierarchy.
Now, memcg itself has OOM KILL function (in oom_kill.c) and tries to
kill a task in memcg.

But, when hierarchy is used, it's broken and correct task cannot
be killed. For example, in following cgroup

	/groupA/	hierarchy=1, limit=1G,
		01	nolimit
		02	nolimit
All tasks' memory usage under /groupA, /groupA/01, groupA/02 is limited to
groupA's 1Gbytes but OOM Killer just kills tasks in groupA.

This patch provides makes the bad process be selected from all tasks
under hierarchy. BTW, currently, oom_jiffies is updated against groupA
in above case. oom_jiffies of tree should be updated.

To see how oom_jiffies is used, please check mem_cgroup_oom_called()
callers.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memcg_test.txt |   20 +++++++++++++++++++-
 include/linux/memcontrol.h           |    4 ++--
 mm/memcontrol.c                      |   32 +++++++++++++++++++++++++++++---
 3 files changed, 50 insertions(+), 6 deletions(-)

Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan16/mm/memcontrol.c
@@ -295,6 +295,9 @@ struct mem_cgroup *mem_cgroup_from_task(
 static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *mem = NULL;
+
+	if (!mm)
+		return;
 	/*
 	 * Because we have no locks, mm->owner's may be being moved to other
 	 * cgroup. We use css_tryget() here even if this looks
@@ -483,13 +486,23 @@ void mem_cgroup_move_lists(struct page *
 	mem_cgroup_add_lru_list(page, to);
 }
 
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
+int task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *mem)
 {
 	int ret;
+	struct mem_cgroup *curr = NULL;
 
 	task_lock(task);
-	ret = task->mm && mm_match_cgroup(task->mm, mem);
+	rcu_read_lock();
+	curr = try_get_mem_cgroup_from_mm(task->mm);
+	rcu_read_unlock();
 	task_unlock(task);
+	if (!curr)
+		return 0;
+	if (curr->use_hierarchy)
+		ret = css_is_ancestor(&curr->css, &mem->css);
+	else
+		ret = (curr == mem);
+	css_put(&curr->css);
 	return ret;
 }
 
@@ -820,6 +833,19 @@ bool mem_cgroup_oom_called(struct task_s
 	rcu_read_unlock();
 	return ret;
 }
+
+static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
+{
+	mem->last_oom_jiffies = jiffies;
+	return 0;
+}
+
+static void record_last_oom(struct mem_cgroup *mem)
+{
+	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
+}
+
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -902,7 +928,7 @@ static int __mem_cgroup_try_charge(struc
 				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
 				mutex_unlock(&memcg_tasklist);
-				mem_over_limit->last_oom_jiffies = jiffies;
+				record_last_oom(mem_over_limit);
 			}
 			goto nomem;
 		}
Index: mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
===================================================================
--- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/memcg_test.txt
+++ mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
@@ -1,5 +1,5 @@
 Memory Resource Controller(Memcg)  Implementation Memo.
-Last Updated: 2009/1/19
+Last Updated: 2009/1/20
 Base Kernel Version: based on 2.6.29-rc2.
 
 Because VM is getting complex (one of reasons is memcg...), memcg's behavior
@@ -360,3 +360,21 @@ Under below explanation, we assume CONFI
 	# kill malloc task.
 
 	Of course, tmpfs v.s. swapoff test should be tested, too.
+
+ 9.8 OOM-Killer
+	Out-of-memory caused by memcg's limit will kill tasks under
+	the memcg. When hierarchy is used, a task under hierarchy
+	will be killed by the kernel.
+	In this case, panic_on_oom shouldn't be invoked and tasks
+	in other groups shouldn't be killed.
+
+	It's not difficult to cause OOM under memcg as following.
+	Case A) when you can swapoff
+	#swapoff -a
+	#echo 50M > /memory.limit_in_bytes
+	run 51M of malloc
+
+	Case B) when you use mem+swap limitation.
+	#echo 50M > memory.limit_in_bytes
+	#echo 50M > memory.memsw.limit_in_bytes
+	run 51M of malloc
Index: mmotm-2.6.29-Jan16/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.29-Jan16.orig/include/linux/memcontrol.h
+++ mmotm-2.6.29-Jan16/include/linux/memcontrol.h
@@ -66,7 +66,7 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+int task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
@@ -192,7 +192,7 @@ static inline int mm_match_cgroup(struct
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
