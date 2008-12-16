Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E8D286B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:09:04 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9NuHh029229
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:23:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7243F45DD7A
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:23:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 50C7245DE50
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:23:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E0171DB8013
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:23:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B7F9B1DB801A
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:23:55 +0900 (JST)
Date: Tue, 16 Dec 2008 18:22:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 9/9] memcg : fix OOM killer under hierarchy
Message-Id: <20081216182259.ab93d816.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Current memcg's oom-killer has 2 problems when hierarchy is used.

Assume following tree,
	Group_A/     use_hierarchy = 1, limit=1G
	        01/  nolimit
		02/  nolimit
		03/  nolimit
In this case, sum of memory usage from 01,02,03 is limted to 1G (of Group_A).

Assume a task in Group_A/01 causes OOM, in this case, bad_process() will
select a process in Group_A, (never scans 01,02,03)
This patch fixes the behavior.

And now, to avoid calling oom_kill twice, mem_cgroup_oom_called() hook is
used in pagefault_out_of_memory(). This check the timestamp of the most
recent OOM in memcg. This timestamp should be updated per hierarchy.

Changelog:
  - added an documentation about easy OOM-Kill test.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 Documentation/controllers/memcg_test.txt |   14 +++++++
 include/linux/memcontrol.h               |    4 +-
 mm/memcontrol.c                          |   55 +++++++++++++++++++++++++++++--
 mm/oom_kill.c                            |    4 +-
 4 files changed, 71 insertions(+), 6 deletions(-)

Index: mmotm-2.6.28-Dec15/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec15.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec15/mm/memcontrol.c
@@ -399,12 +399,31 @@ void mem_cgroup_move_lists(struct page *
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
@@ -677,6 +696,36 @@ static int mem_cgroup_hierarchical_recla
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
@@ -773,7 +822,7 @@ static int __mem_cgroup_try_charge(struc
 				mutex_lock(&memcg_tasklist);
 				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
 				mutex_unlock(&memcg_tasklist);
-				mem_over_limit->last_oom_jiffies = jiffies;
+				mem_cgroup_update_oom_jiffies(mem_over_limit);
 			}
 			goto nomem;
 		}
Index: mmotm-2.6.28-Dec15/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.28-Dec15.orig/include/linux/memcontrol.h
+++ mmotm-2.6.28-Dec15/include/linux/memcontrol.h
@@ -65,7 +65,9 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+
+int task_in_mem_cgroup_hierarchy(struct task_struct *task,
+			struct mem_cgroup *mem);
 
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
Index: mmotm-2.6.28-Dec15/mm/oom_kill.c
===================================================================
--- mmotm-2.6.28-Dec15.orig/mm/oom_kill.c
+++ mmotm-2.6.28-Dec15/mm/oom_kill.c
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
Index: mmotm-2.6.28-Dec15/Documentation/controllers/memcg_test.txt
===================================================================
--- mmotm-2.6.28-Dec15.orig/Documentation/controllers/memcg_test.txt
+++ mmotm-2.6.28-Dec15/Documentation/controllers/memcg_test.txt
@@ -340,3 +340,17 @@ Under below explanation, we assume CONFI
 	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
 
 	and do task move, mkdir, rmdir etc...under this.
+
+ 9.7 OOM-KILL
+	If memcg finds out-of-memory, OOM Kill should kill a task in memcg.
+	This select_bad_process() should take hierarchy into account and
+	OOM-KILL itself shoudn't call panic_on_oom.
+
+	It's not difficult to cause OOM under memcg by setting memsw.limit
+	as following.
+	# echo 50M > memory.limit_in_bytes
+	# echo 50M > memory.memsw.limit_in_bytes
+	and run malloc(51M) program.
+	(Alternative is do swapoff and malloc())
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
