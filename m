Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 81ACC6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 04:33:12 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n089XAS1013940
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 18:33:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12EC145DE50
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:33:10 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EAF5845DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:33:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D008EE18003
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:33:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 85E7A1DB8038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:33:09 +0900 (JST)
Date: Thu, 8 Jan 2009 18:32:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/4] memcg: fix OOM KILL under hierarchy
Message-Id: <20090108183207.26d88794.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Current memcg's oom-killer has 2 problems when hierarchy is used.

Assume following tree,
	Group_A/     use_hierarchy = 1, limit=1G
	        01/  nolimit
		02/  nolimit
		03/  nolimit
In this case, sum of memory usage from 01,02,03 is limited to 1G (of Group_A).

Assume a task in Group_A/01 causes OOM by limit of Group_A, in this case,
bad_process() will select a process in Group_A, not in 01,02,03.

This patch fixes the behavior and all processes under Group_A's hierarchy
01,02,03 will be OOM kill candidates.

And now, to avoid calling oom_kill twice, mem_cgroup_oom_called() hook is
used in pagefault_out_of_memory(). This check the timestamp of the most
recent OOM in memcg. This timestamp should be updated per hierarchy.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 Documentation/controllers/memcg_test.txt |   15 ++++++++
 include/linux/memcontrol.h               |    4 +-
 mm/memcontrol.c                          |   55 +++++++++++++++++++++++++++++--
 mm/oom_kill.c                            |    4 +-
 4 files changed, 72 insertions(+), 6 deletions(-)

Index: mmotm-2.6.28-Jan7/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Jan7.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Jan7/mm/memcontrol.c
@@ -431,12 +431,31 @@ void mem_cgroup_move_lists(struct page *
 	mem_cgroup_add_lru_list(page, to);
 }
 
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
+static int
+mm_match_cgroup_hierarchy(struct mm_struct *mm, struct mem_cgroup *mem)
+{
+	struct mem_cgroup *curr;
+	int ret;
+
+	if (!mm)
+		return 0;
+	rcu_read_lock();
+	curr = mem_cgroup_from_task(mm->owner);
+	if (mem->use_hierarchy)
+		ret = css_is_ancestor(&curr->css, &mem->css);
+	else
+		ret = (curr == mem);
+	rcu_read_unlock();
+	return ret;
+}
+
+int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+				 struct mem_cgroup *mem)
 {
 	int ret;
 
 	task_lock(task);
-	ret = task->mm && mm_match_cgroup(task->mm, mem);
+	ret = mm_match_cgroup_hierarchy(task->mm, mem);
 	task_unlock(task);
 	return ret;
 }
@@ -723,6 +742,36 @@ static int mem_cgroup_hierarchical_recla
 	return total;
 }
 
+/*
+ *  Update last_oom_jiffies of hierarchy.
+ */
+void mem_cgroup_update_oom_jiffies(struct mem_cgroup *mem)
+{
+	struct mem_cgroup *cur;
+	struct cgroup_subsys_state *css;
+	int id, found;
+
+	if (!mem->use_hierarchy) {
+		mem->last_oom_jiffies = jiffies;
+		return;
+	}
+
+	id = 0;
+	rcu_read_lock();
+	while (1) {
+		css = css_get_next(&mem_cgroup_subsys, id, &mem->css, &found);
+		if (!css)
+			break;
+		if (css_tryget(css)) {
+			cur = container_of(css, struct mem_cgroup, css);
+			cur->last_oom_jiffies = jiffies;
+			css_put(css);
+		}
+		id = found + 1;
+	}
+	rcu_read_unlock();
+	return;
+}
 bool mem_cgroup_oom_called(struct task_struct *task)
 {
 	bool ret = false;
@@ -819,7 +868,7 @@ static int __mem_cgroup_try_charge(struc
 				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
 				mutex_unlock(&memcg_tasklist);
-				mem_over_limit->last_oom_jiffies = jiffies;
+				mem_cgroup_update_oom_jiffies(mem_over_limit);
 			}
 			goto nomem;
 		}
Index: mmotm-2.6.28-Jan7/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Jan7.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Jan7/include/linux/memcontrol.h
@@ -66,7 +66,9 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+
+int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+			struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
Index: mmotm-2.6.28-Jan7/mm/oom_kill.c
===================================================================
--- mmotm-2.6.28-Jan7.orig/mm/oom_kill.c
+++ mmotm-2.6.28-Jan7/mm/oom_kill.c
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
Index: mmotm-2.6.28-Jan7/Documentation/controllers/memcg_test.txt
===================================================================
--- mmotm-2.6.28-Jan7.orig/Documentation/controllers/memcg_test.txt
+++ mmotm-2.6.28-Jan7/Documentation/controllers/memcg_test.txt
@@ -340,3 +340,18 @@ Under below explanation, we assume CONFI
 	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
 
 	and do task move, mkdir, rmdir etc...under this.
+
+ 9.7 OOM-KILL
+	If memcg finds out-of-memory, OOM Kill should kill a task in memcg.
+	The select_bad_process() should take hierarchy into account and
+	OOM-KILL itself shoudn't call panic_on_oom or some hooks for generic
+	OOM.
+
+	It's not difficult to cause OOM under memcg by setting memsw.limit
+	as following.
+	# echo 50M > memory.limit_in_bytes
+	# echo 50M > memory.memsw.limit_in_bytes
+	and run malloc(51M) program.
+	(Alternative is do swapoff/mlock and malloc())
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
