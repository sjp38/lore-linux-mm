Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1C1FA6B00F6
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:12:07 -0400 (EDT)
Message-ID: <4B9F759C.8090300@cn.fujitsu.com>
Date: Tue, 16 Mar 2010 20:12:12 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [RESEND][PATCH 2/2] cpuset: alloc nodemask_t at heap not stack (v2)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Allocating nodemask_t at heap instead of stack.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 kernel/cpuset.c |   94 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 66 insertions(+), 28 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 5d38bd7..d109467 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -970,15 +970,20 @@ static void cpuset_change_nodemask(struct task_struct *p,
 	struct cpuset *cs;
 	int migrate;
 	const nodemask_t *oldmem = scan->data;
-	nodemask_t newmems;
+	NODEMASK_ALLOC(nodemask_t, newmems, GFP_KERNEL);
+
+	if (!newmems)
+		return;
 
 	cs = cgroup_cs(scan->cg);
-	guarantee_online_mems(cs, &newmems);
+	guarantee_online_mems(cs, newmems);
 
 	task_lock(p);
-	cpuset_change_task_nodemask(p, &newmems);
+	cpuset_change_task_nodemask(p, newmems);
 	task_unlock(p);
 
+	NODEMASK_FREE(newmems);
+
 	mm = get_task_mm(p);
 	if (!mm)
 		return;
@@ -1048,16 +1053,21 @@ static void update_tasks_nodemask(struct cpuset *cs, const nodemask_t *oldmem,
 static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			   const char *buf)
 {
-	nodemask_t oldmem;
+	NODEMASK_ALLOC(nodemask_t, oldmem, GFP_KERNEL);
 	int retval;
 	struct ptr_heap heap;
 
+	if (!oldmem)
+		return -ENOMEM;
+
 	/*
 	 * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
 	 * it's read-only
 	 */
-	if (cs == &top_cpuset)
-		return -EACCES;
+	if (cs == &top_cpuset) {
+		retval = -EACCES;
+		goto done;
+	}
 
 	/*
 	 * An empty mems_allowed is ok iff there are no tasks in the cpuset.
@@ -1073,11 +1083,13 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			goto done;
 
 		if (!nodes_subset(trialcs->mems_allowed,
-				node_states[N_HIGH_MEMORY]))
-			return -EINVAL;
+				node_states[N_HIGH_MEMORY])) {
+			retval =  -EINVAL;
+			goto done;
+		}
 	}
-	oldmem = cs->mems_allowed;
-	if (nodes_equal(oldmem, trialcs->mems_allowed)) {
+	*oldmem = cs->mems_allowed;
+	if (nodes_equal(*oldmem, trialcs->mems_allowed)) {
 		retval = 0;		/* Too easy - nothing to do */
 		goto done;
 	}
@@ -1093,10 +1105,11 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	update_tasks_nodemask(cs, &oldmem, &heap);
+	update_tasks_nodemask(cs, oldmem, &heap);
 
 	heap_free(&heap);
 done:
+	NODEMASK_FREE(oldmem);
 	return retval;
 }
 
@@ -1381,39 +1394,47 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 			  struct cgroup *oldcont, struct task_struct *tsk,
 			  bool threadgroup)
 {
-	nodemask_t from, to;
 	struct mm_struct *mm;
 	struct cpuset *cs = cgroup_cs(cont);
 	struct cpuset *oldcs = cgroup_cs(oldcont);
+	NODEMASK_ALLOC(nodemask_t, from, GFP_KERNEL);
+	NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
+
+	if (from == NULL || to == NULL)
+		goto alloc_fail;
 
 	if (cs == &top_cpuset) {
 		cpumask_copy(cpus_attach, cpu_possible_mask);
 	} else {
 		guarantee_online_cpus(cs, cpus_attach);
 	}
-	guarantee_online_mems(cs, &to);
+	guarantee_online_mems(cs, to);
 
 	/* do per-task migration stuff possibly for each in the threadgroup */
-	cpuset_attach_task(tsk, &to, cs);
+	cpuset_attach_task(tsk, to, cs);
 	if (threadgroup) {
 		struct task_struct *c;
 		rcu_read_lock();
 		list_for_each_entry_rcu(c, &tsk->thread_group, thread_group) {
-			cpuset_attach_task(c, &to, cs);
+			cpuset_attach_task(c, to, cs);
 		}
 		rcu_read_unlock();
 	}
 
 	/* change mm; only needs to be done once even if threadgroup */
-	from = oldcs->mems_allowed;
-	to = cs->mems_allowed;
+	*from = oldcs->mems_allowed;
+	*to = cs->mems_allowed;
 	mm = get_task_mm(tsk);
 	if (mm) {
-		mpol_rebind_mm(mm, &to);
+		mpol_rebind_mm(mm, to);
 		if (is_memory_migrate(cs))
-			cpuset_migrate_mm(mm, &from, &to);
+			cpuset_migrate_mm(mm, from, to);
 		mmput(mm);
 	}
+
+alloc_fail:
+	NODEMASK_FREE(from);
+	NODEMASK_FREE(to);
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -1558,13 +1579,21 @@ static int cpuset_sprintf_cpulist(char *page, struct cpuset *cs)
 
 static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
 {
-	nodemask_t mask;
+	NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
+	int retval;
+
+	if (mask == NULL)
+		return -ENOMEM;
 
 	mutex_lock(&callback_mutex);
-	mask = cs->mems_allowed;
+	*mask = cs->mems_allowed;
 	mutex_unlock(&callback_mutex);
 
-	return nodelist_scnprintf(page, PAGE_SIZE, mask);
+	retval = nodelist_scnprintf(page, PAGE_SIZE, *mask);
+
+	NODEMASK_FREE(mask);
+
+	return retval;
 }
 
 static ssize_t cpuset_common_file_read(struct cgroup *cont,
@@ -1993,7 +2022,10 @@ static void scan_for_empty_cpusets(struct cpuset *root)
 	struct cpuset *cp;	/* scans cpusets being updated */
 	struct cpuset *child;	/* scans child cpusets of cp */
 	struct cgroup *cont;
-	nodemask_t oldmems;
+	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
+
+	if (oldmems == NULL)
+		return;
 
 	list_add_tail((struct list_head *)&root->stack_list, &queue);
 
@@ -2010,7 +2042,7 @@ static void scan_for_empty_cpusets(struct cpuset *root)
 		    nodes_subset(cp->mems_allowed, node_states[N_HIGH_MEMORY]))
 			continue;
 
-		oldmems = cp->mems_allowed;
+		*oldmems = cp->mems_allowed;
 
 		/* Remove offline cpus and mems from this cpuset. */
 		mutex_lock(&callback_mutex);
@@ -2026,9 +2058,10 @@ static void scan_for_empty_cpusets(struct cpuset *root)
 			remove_tasks_in_empty_cpuset(cp);
 		else {
 			update_tasks_cpumask(cp, NULL);
-			update_tasks_nodemask(cp, &oldmems, NULL);
+			update_tasks_nodemask(cp, oldmems, NULL);
 		}
 	}
+	NODEMASK_FREE(oldmems);
 }
 
 /*
@@ -2086,16 +2119,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
 static int cpuset_track_online_nodes(struct notifier_block *self,
 				unsigned long action, void *arg)
 {
-	nodemask_t oldmems;
+	NODEMASK_ALLOC(nodemask_t, oldmems, GFP_KERNEL);
+
+	if (oldmems == NULL)
+		return NOTIFY_DONE;
 
 	cgroup_lock();
 	switch (action) {
 	case MEM_ONLINE:
-		oldmems = top_cpuset.mems_allowed;
+		*oldmems = top_cpuset.mems_allowed;
 		mutex_lock(&callback_mutex);
 		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
 		mutex_unlock(&callback_mutex);
-		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
+		update_tasks_nodemask(&top_cpuset, oldmems, NULL);
 		break;
 	case MEM_OFFLINE:
 		/*
@@ -2108,6 +2144,8 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 		break;
 	}
 	cgroup_unlock();
+
+	NODEMASK_FREE(oldmems);
 	return NOTIFY_OK;
 }
 #endif
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
