Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id A20146B0261
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:17:51 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id q18so1588605igr.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:17:51 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0123.outbound.protection.outlook.com. [157.56.112.123])
        by mx.google.com with ESMTPS id 34si13897779otz.27.2016.05.27.07.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 07:17:50 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 1/2] mm: oom: add memcg to oom_control
Date: Fri, 27 May 2016 17:17:41 +0300
Message-ID: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's a part of oom context just like allocation order and nodemask, so
let's move it to oom_control instead of passing it in the argument list.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 drivers/tty/sysrq.c |  1 +
 include/linux/oom.h |  8 +++++---
 mm/memcontrol.c     |  5 +++--
 mm/oom_kill.c       | 32 +++++++++++++++-----------------
 mm/page_alloc.c     |  1 +
 5 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index e5139402e7f8..52bbd27e93ae 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -363,6 +363,7 @@ static void moom_callback(struct work_struct *ignored)
 	struct oom_control oc = {
 		.zonelist = node_zonelist(first_memory_node, gfp_mask),
 		.nodemask = NULL,
+		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = -1,
 	};
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 83469522690a..cbc24a5fe28d 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -23,6 +23,9 @@ struct oom_control {
 	/* Used to determine mempolicy */
 	nodemask_t *nodemask;
 
+	/* Memory cgroup in which oom is invoked, or NULL for global oom */
+	struct mem_cgroup *memcg;
+
 	/* Used to determine cpuset and node locality requirement */
 	const gfp_t gfp_mask;
 
@@ -83,11 +86,10 @@ extern unsigned long oom_badness(struct task_struct *p,
 
 extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			     unsigned int points, unsigned long totalpages,
-			     struct mem_cgroup *memcg, const char *message);
+			     const char *message);
 
 extern void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint,
-			       struct mem_cgroup *memcg);
+			       enum oom_constraint constraint);
 
 extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 		struct task_struct *task, unsigned long totalpages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 37ba604984c9..eeb3b14de01a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1259,6 +1259,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	struct oom_control oc = {
 		.zonelist = NULL,
 		.nodemask = NULL,
+		.memcg = memcg,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
@@ -1281,7 +1282,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto unlock;
 	}
 
-	check_panic_on_oom(&oc, CONSTRAINT_MEMCG, memcg);
+	check_panic_on_oom(&oc, CONSTRAINT_MEMCG);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
@@ -1329,7 +1330,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	if (chosen) {
 		points = chosen_points * 1000 / totalpages;
-		oom_kill_process(&oc, chosen, points, totalpages, memcg,
+		oom_kill_process(&oc, chosen, points, totalpages,
 				 "Memory cgroup out of memory");
 	}
 unlock:
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b95c4c101b35..b3424199069b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -383,8 +383,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	rcu_read_unlock();
 }
 
-static void dump_header(struct oom_control *oc, struct task_struct *p,
-			struct mem_cgroup *memcg)
+static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
@@ -392,12 +391,12 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
 
 	cpuset_print_current_mems_allowed();
 	dump_stack();
-	if (memcg)
-		mem_cgroup_print_oom_info(memcg, p);
+	if (oc->memcg)
+		mem_cgroup_print_oom_info(oc->memcg, p);
 	else
 		show_mem(SHOW_MEM_FILTER_NODES);
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(memcg, oc->nodemask);
+		dump_tasks(oc->memcg, oc->nodemask);
 }
 
 /*
@@ -748,7 +747,7 @@ void oom_killer_enable(void)
  */
 void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		      unsigned int points, unsigned long totalpages,
-		      struct mem_cgroup *memcg, const char *message)
+		      const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
@@ -774,7 +773,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(oc, p, memcg);
+		dump_header(oc, p);
 
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
@@ -795,8 +794,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-			child_points = oom_badness(child, memcg, oc->nodemask,
-								totalpages);
+			child_points = oom_badness(child,
+					oc->memcg, oc->nodemask, totalpages);
 			if (child_points > victim_points) {
 				put_task_struct(victim);
 				victim = child;
@@ -874,8 +873,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
-			struct mem_cgroup *memcg)
+void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -891,7 +889,7 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
 	/* Do not panic for oom kills triggered by sysrq */
 	if (is_sysrq_oom(oc))
 		return;
-	dump_header(oc, NULL, memcg);
+	dump_header(oc, NULL);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -966,13 +964,13 @@ bool out_of_memory(struct oom_control *oc)
 	constraint = constrained_alloc(oc, &totalpages);
 	if (constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
-	check_panic_on_oom(oc, constraint, NULL);
+	check_panic_on_oom(oc, constraint);
 
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
+		oom_kill_process(oc, current, 0, totalpages,
 				 "Out of memory (oom_kill_allocating_task)");
 		return true;
 	}
@@ -980,12 +978,11 @@ bool out_of_memory(struct oom_control *oc)
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p && !is_sysrq_oom(oc)) {
-		dump_header(oc, NULL, NULL);
+		dump_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (p && p != (void *)-1UL) {
-		oom_kill_process(oc, p, points, totalpages, NULL,
-				 "Out of memory");
+		oom_kill_process(oc, p, points, totalpages, "Out of memory");
 		/*
 		 * Give the killed process a good chance to exit before trying
 		 * to allocate memory again.
@@ -1005,6 +1002,7 @@ void pagefault_out_of_memory(void)
 	struct oom_control oc = {
 		.zonelist = NULL,
 		.nodemask = NULL,
+		.memcg = NULL,
 		.gfp_mask = 0,
 		.order = 0,
 	};
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f21f56f88c8a..7da8310b86e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3101,6 +3101,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
 		.nodemask = ac->nodemask,
+		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
