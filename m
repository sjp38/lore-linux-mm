Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FC3C6B0078
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 22:05:38 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1935Zbw022569
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 12:05:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B9345DE5D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 12:05:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A9FD45DE64
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 12:05:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DB561DB803A
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 12:05:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 885D9EF8004
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 12:05:34 +0900 (JST)
Date: Tue, 9 Feb 2010 12:02:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other  cgroup
 v2
Message-Id: <20100209120209.686c348c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

How about this ?
Passed simple oom-kill test on mmotom-Feb06
==
Now, oom-killer kills process's chidlren at first. But this means
a child in other cgroup can be killed. But it's not checked now.

This patch fixes that.

It's pointed out that task_lock in task_in_mem_cgroup is bad at
killing a task in oom-killer. It can cause siginificant delay or
deadlock. For removing unnecessary task_lock under oom-killer, we use
use some loose way. Considering oom-killer and task-walk in the tasklist, 
checking "task is in mem_cgroup" itself includes some race and we don't
have to do strict check, here.
(IOW, we can't do it.)

Changelog: 2009/02/09
 - modified task_in_mem_cgroup to be lockless.

CC: Minchan Kim <minchan.kim@gmail.com>
CC: David Rientjes <rientjes@google.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    5 +++--
 mm/memcontrol.c            |   32 ++++++++++++++++++++++++++++----
 mm/oom_kill.c              |    6 ++++--
 3 files changed, 35 insertions(+), 8 deletions(-)

Index: mmotm-2.6.33-Feb06/include/linux/memcontrol.h
===================================================================
--- mmotm-2.6.33-Feb06.orig/include/linux/memcontrol.h
+++ mmotm-2.6.33-Feb06/include/linux/memcontrol.h
@@ -71,7 +71,8 @@ extern unsigned long mem_cgroup_isolate_
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
+int task_in_oom_mem_cgroup(struct task_struct *task,
+	const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
@@ -215,7 +216,7 @@ static inline int mm_match_cgroup(struct
 	return 1;
 }
 
-static inline int task_in_mem_cgroup(struct task_struct *task,
+static inline int task_in_oom_mem_cgroup(struct task_struct *task,
 				     const struct mem_cgroup *mem)
 {
 	return 1;
Index: mmotm-2.6.33-Feb06/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb06.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb06/mm/memcontrol.c
@@ -781,16 +781,40 @@ void mem_cgroup_move_lists(struct page *
 	mem_cgroup_add_lru_list(page, to);
 }
 
-int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
+/*
+ * This function is called from OOM Killer. This checks the task is mm_owner
+ * and checks it's mem_cgroup is under oom.
+ */
+int task_in_oom_mem_cgroup(struct task_struct *task,
+		const struct mem_cgroup *mem)
 {
+	struct mm_struct *mm;
 	int ret;
 	struct mem_cgroup *curr = NULL;
 
-	task_lock(task);
+	/*
+ 	 * The task's task->mm pointer is guarded by task_lock() but it's
+ 	 * risky to take task_lock in oom kill situaion. Oom-killer may
+ 	 * kill a task which is in unknown status and cause siginificant delay
+ 	 * or deadlock.
+ 	 * So, we use some loose way. Because we're under taslist lock, "task"
+ 	 * pointer is always safe and we can access it. So, accessing mem_cgroup
+ 	 * via task struct is safe. To check the task is mm owner, we do loose
+ 	 * check. And this is enough.
+ 	 * There is small race at updating mm->onwer but we can ignore it.
+ 	 * A problematic race here means that oom-selection logic by walking
+ 	 * task list itself is racy. We can't make any strict guarantee between
+ 	 * task's cgroup status and oom-killer selection, anyway. And, in real
+ 	 * world, this will be no problem.
+ 	 */
+	mm = task->mm;
+	if (!mm || mm->owner != task)
+		return 0;
 	rcu_read_lock();
-	curr = try_get_mem_cgroup_from_mm(task->mm);
+	curr = mem_cgroup_from_task(task);
+	if (!css_tryget(&curr->css));
+		curr = NULL;
 	rcu_read_unlock();
-	task_unlock(task);
 	if (!curr)
 		return 0;
 	/*
Index: mmotm-2.6.33-Feb06/mm/oom_kill.c
===================================================================
--- mmotm-2.6.33-Feb06.orig/mm/oom_kill.c
+++ mmotm-2.6.33-Feb06/mm/oom_kill.c
@@ -264,7 +264,7 @@ static struct task_struct *select_bad_pr
 		/* skip the init task */
 		if (is_global_init(p))
 			continue;
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (mem && !task_in_oom_mem_cgroup(p, mem))
 			continue;
 
 		/*
@@ -332,7 +332,7 @@ static void dump_tasks(const struct mem_
 	do_each_thread(g, p) {
 		struct mm_struct *mm;
 
-		if (mem && !task_in_mem_cgroup(p, mem))
+		if (mem && !task_in_oom_mem_cgroup(p, mem))
 			continue;
 		if (!thread_group_leader(p))
 			continue;
@@ -459,6 +459,8 @@ static int oom_kill_process(struct task_
 	list_for_each_entry(c, &p->children, sibling) {
 		if (c->mm == p->mm)
 			continue;
+		if (mem && !task_in_oom_mem_cgroup(c, mem))
+			continue;
 		if (!oom_kill_task(c))
 			return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
