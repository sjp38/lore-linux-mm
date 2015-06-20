Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 379556B009C
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 03:57:47 -0400 (EDT)
Received: by obbsn1 with SMTP id sn1so87185052obb.1
        for <linux-mm@kvack.org>; Sat, 20 Jun 2015 00:57:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l7si8500637oes.9.2015.06.20.00.57.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 20 Jun 2015 00:57:45 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
	<20150617154159.GJ25056@dhcp22.suse.cz>
	<201506192030.CAH00597.FQVOtFFLOJMHOS@I-love.SAKURA.ne.jp>
	<20150619153620.GI4913@dhcp22.suse.cz>
	<201506200354.ABC87533.OFFMtSLOFHJVQO@I-love.SAKURA.ne.jp>
In-Reply-To: <201506200354.ABC87533.OFFMtSLOFHJVQO@I-love.SAKURA.ne.jp>
Message-Id: <201506201657.JCI48462.MFFFJVSOOLOtQH@I-love.SAKURA.ne.jp>
Date: Sat, 20 Jun 2015 16:57:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> One case is that the system can not panic of threads are unable to call
> out_of_memory() for some reason.
                                            ^ if

> Well, if without analysis purpose,
> 
>   if (time_after(jiffies, oom_start + sysctl_panic_on_oom_timeout * HZ))
>     panic();
> 
> (that is, pass the jiffies as of calling out_of_memory() for the first time
> of this memory allocation request as an argument to out_of_memory(), and
> compare at check_panic_on_oom()) is sufficient? Very simple implementation
> because we do not use mod_timer()/del_timer().

Here is an untested patch.

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index b5b4278..4c64b92 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -355,7 +355,7 @@ static void moom_callback(struct work_struct *ignored)
 {
 	mutex_lock(&oom_lock);
 	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
-			   GFP_KERNEL, 0, NULL, true))
+			   GFP_KERNEL, 0, NULL, true, NULL))
 		pr_info("OOM request ignored because killer is disabled\n");
 	mutex_unlock(&oom_lock);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7deecb7..75525e9 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -64,14 +64,16 @@ extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 
 extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			       int order, const nodemask_t *nodemask,
-			       struct mem_cgroup *memcg);
+			       struct mem_cgroup *memcg,
+			       const unsigned long *oom_start);
 
 extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
 
 extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		int order, nodemask_t *mask, bool force_kill);
+			  int order, nodemask_t *mask, bool force_kill,
+			  const unsigned long *oom_start);
 
 extern void exit_oom_victim(void);
 
@@ -99,4 +101,5 @@ static inline bool task_will_free_mem(struct task_struct *task)
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_panic_on_oom;
+extern int sysctl_panic_on_oom_timeout;
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c566b56..74a1b68 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1162,6 +1162,14 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &two,
 	},
 	{
+		.procname	= "panic_on_oom_timeout",
+		.data		= &sysctl_panic_on_oom_timeout,
+		.maxlen		= sizeof(sysctl_panic_on_oom_timeout),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "oom_kill_allocating_task",
 		.data		= &sysctl_oom_kill_allocating_task,
 		.maxlen		= sizeof(sysctl_oom_kill_allocating_task),
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c5..ab1ae3e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1563,7 +1563,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto unlock;
 	}
 
-	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg);
+	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL, memcg,
+			   NULL);
 	totalpages = mem_cgroup_get_limit(memcg) ? : 1;
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e..9d30f2e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -40,6 +40,7 @@
 #include <trace/events/oom.h>
 
 int sysctl_panic_on_oom;
+int sysctl_panic_on_oom_timeout;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 
@@ -602,7 +603,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
  */
 void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			int order, const nodemask_t *nodemask,
-			struct mem_cgroup *memcg)
+			struct mem_cgroup *memcg,
+			const unsigned long *oom_start)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -614,6 +616,14 @@ void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 		 */
 		if (constraint != CONSTRAINT_NONE)
 			return;
+		/*
+		 * panic_on_oom_timeout only affects panic_on_oom == 1 and
+		 * CONSTRAINT_NONE.
+		 */
+		if (sysctl_panic_on_oom_timeout && oom_start &&
+		    time_before(jiffies,
+				*oom_start + sysctl_panic_on_oom_timeout * HZ))
+			return;
 	}
 	dump_header(NULL, gfp_mask, order, memcg, nodemask);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
@@ -641,6 +651,8 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * @order: amount of memory being requested as a power of 2
  * @nodemask: nodemask passed to page allocator
  * @force_kill: true if a task must be killed, even if others are exiting
+ * @oom_start: Pointer to jiffies as of calling this function for the first
+ *             time of this memory allocation request. Ignored if NULL.
  *
  * If we run out of memory, we have the choice between either
  * killing a random task (bad), letting the system crash (worse)
@@ -648,7 +660,8 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
  * don't have to be perfect here, we just have to be good.
  */
 bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
-		   int order, nodemask_t *nodemask, bool force_kill)
+		   int order, nodemask_t *nodemask, bool force_kill,
+		   const unsigned long *oom_start)
 {
 	const nodemask_t *mpol_mask;
 	struct task_struct *p;
@@ -687,7 +700,8 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
 						&totalpages);
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
-	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
+	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL,
+			   oom_start);
 
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
@@ -734,7 +748,7 @@ void pagefault_out_of_memory(void)
 	if (!mutex_trylock(&oom_lock))
 		return;
 
-	if (!out_of_memory(NULL, 0, 0, NULL, false)) {
+	if (!out_of_memory(NULL, 0, 0, NULL, false, NULL)) {
 		/*
 		 * There shouldn't be any user tasks runnable while the
 		 * OOM killer is disabled, so the current task has to
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73aa335..3a75fe8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2678,7 +2678,9 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+		      const struct alloc_context *ac,
+		      unsigned long *did_some_progress,
+		      unsigned long *oom_start)
 {
 	struct page *page;
 
@@ -2731,7 +2733,10 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 			goto out;
 	}
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
+	if (!*oom_start)
+		*oom_start = jiffies;
+	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false,
+			  oom_start)
 			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;
 out:
@@ -2968,6 +2973,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	unsigned long oom_start = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3122,7 +3128,8 @@ retry:
 	}
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress,
+				     &oom_start);
 	if (page)
 		goto got_pg;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
