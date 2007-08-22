Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 23 of 24] serialize for cpusets
Message-Id: <a3d679df54ebb1f977b9.1187786950@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:10 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User David Rientjes <rientjes@google.com>
# Date 1187778125 -7200
# Node ID a3d679df54ebb1f977b97ab6b3e501134bf9e7ef
# Parent  8807a4d14b241b2d1132fde7f83834603b6cf093
serialize for cpusets

Adds a last_tif_memdie_jiffies field to struct cpuset to store the
jiffies value at the last OOM kill.  This will detect deadlocks in the
CONSTRAINT_CPUSET case and kill another task if its detected.

Adds a CS_OOM bit to struct cpuset's flags field.  This will be tested,
set, and cleared atomically to denote a cpuset that currently has an
attached task exiting as a result of the OOM killer.  We are required to
take p->alloc_lock to dereference p->cpuset so this cannot be implemented
as a simple trylock.

As a result, we cannot allow the detachment of a task from a cpuset that
is currently OOM killing one of its tasks.  If we did, we would end up
clearing the CS_OOM bit in the wrong cpuset upon that task's exit.

sysctl's panic_on_oom is now only effected in the non-cpuset-constrained
case.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/cpuset.h |   19 ++++++++++++++
 kernel/cpuset.c        |   65 +++++++++++++++++++++++++++++++++++++++++++++---
 kernel/exit.c          |    1 +
 mm/oom_kill.c          |   21 ++++++++++++++-
 4 files changed, 100 insertions(+), 6 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -46,6 +46,12 @@ static int inline cpuset_zone_allowed_ha
 }
 
 extern int cpuset_excl_nodes_overlap(const struct task_struct *p);
+
+extern int cpuset_get_last_tif_memdie(struct task_struct *task);
+extern void cpuset_set_last_tif_memdie(struct task_struct *task,
+				       unsigned long last_tif_memdie);
+extern int cpuset_set_oom(struct task_struct *task);
+extern void cpuset_clear_oom(struct task_struct *task);
 
 #define cpuset_memory_pressure_bump() 				\
 	do {							\
@@ -118,6 +124,19 @@ static inline int cpuset_excl_nodes_over
 	return 1;
 }
 
+static inline int cpuset_get_last_tif_memdie(struct task_struct *task)
+{
+	return jiffies;
+}
+static inline void cpuset_set_last_tif_memdie(struct task_struct *task,
+					      unsigned long last_tif_memdie) {}
+
+static inline int cpuset_set_oom(struct task_struct *task)
+{
+	return 0;
+}
+static inline void cpuset_clear_oom(struct task_struct *task) {}
+
 static inline void cpuset_memory_pressure_bump(void) {}
 
 static inline char *cpuset_task_status_allowed(struct task_struct *task,
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -98,6 +98,12 @@ struct cpuset {
 	int mems_generation;
 
 	struct fmeter fmeter;		/* memory_pressure filter */
+
+	/*
+	 * The jiffies at the last time TIF_MEMDIE was set for a task
+	 * associated with this cpuset.
+	 */
+	unsigned long last_tif_memdie_jiffies;
 };
 
 /* bits in struct cpuset flags field */
@@ -109,6 +115,7 @@ typedef enum {
 	CS_NOTIFY_ON_RELEASE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_OOM,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -145,6 +152,11 @@ static inline int is_spread_slab(const s
 static inline int is_spread_slab(const struct cpuset *cs)
 {
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
+}
+
+static inline int is_oom(const struct cpuset *cs)
+{
+	return test_bit(CS_OOM, &cs->flags);
 }
 
 /*
@@ -1251,10 +1263,16 @@ static int attach_task(struct cpuset *cs
 	 * then fail this attach_task(), to avoid breaking top_cpuset.count.
 	 */
 	if (tsk->flags & PF_EXITING) {
-		task_unlock(tsk);
-		mutex_unlock(&callback_mutex);
-		put_task_struct(tsk);
-		return -ESRCH;
+		retval = -ESRCH;
+		goto error;
+	}
+	/*
+	 * If the task's cpuset is currently in the OOM killer, we cannot
+	 * move it or we'll clear the CS_OOM flag in the new cpuset.
+	 */
+	if (unlikely(is_oom(oldcs))) {
+		retval = -EBUSY;
+		goto error;
 	}
 	atomic_inc(&cs->count);
 	rcu_assign_pointer(tsk->cpuset, cs);
@@ -1281,6 +1299,12 @@ static int attach_task(struct cpuset *cs
 	if (atomic_dec_and_test(&oldcs->count))
 		check_for_release(oldcs, ppathbuf);
 	return 0;
+
+error:
+	task_unlock(tsk);
+	mutex_unlock(&callback_mutex);
+	put_task_struct(tsk);
+	return retval;
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -2603,6 +2627,39 @@ done:
 	return overlap;
 }
 
+int cpuset_get_last_tif_memdie(struct task_struct *task)
+{
+	unsigned long ret;
+	task_lock(task);
+	ret = task->cpuset->last_tif_memdie_jiffies;
+	task_unlock(task);
+	return ret;
+}
+
+void cpuset_set_last_tif_memdie(struct task_struct *task,
+				unsigned long last_tif_memdie)
+{
+	task_lock(task);
+	task->cpuset->last_tif_memdie_jiffies = last_tif_memdie;
+	task_unlock(task);
+}
+
+int cpuset_set_oom(struct task_struct *task)
+{
+	int ret;
+	task_lock(task);
+	ret = test_and_set_bit(CS_OOM, &task->cpuset->flags);
+	task_unlock(task);
+	return ret;
+}
+
+void cpuset_clear_oom(struct task_struct *task)
+{
+	task_lock(task);
+	clear_bit(CS_OOM, &task->cpuset->flags);
+	task_unlock(task);
+}
+
 /*
  * Collection of memory_pressure is suppressed unless
  * this flag is enabled by writing "1" to the special
diff --git a/kernel/exit.c b/kernel/exit.c
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -857,6 +857,7 @@ static void exit_notify(struct task_stru
 	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE))) {
 		extern unsigned long VM_is_OOM;
 		clear_bit(0, &VM_is_OOM);
+		cpuset_clear_oom(tsk);
 	}
 
 	write_unlock_irq(&tasklist_lock);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,6 +428,7 @@ void out_of_memory(struct zonelist *zone
 void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 {
 	unsigned long freed = 0;
+	unsigned long last_tif_memdie;
 	int constraint;
 	static DECLARE_MUTEX(OOM_lock);
 
@@ -455,6 +456,22 @@ void out_of_memory(struct zonelist *zone
 		break;
 
 	case CONSTRAINT_CPUSET:
+		read_lock(&tasklist_lock);
+		last_tif_memdie = cpuset_get_last_tif_memdie(current);
+		/*
+		 * If current's cpuset is already in the OOM killer or its killed
+		 * task has not yet exited and a deadlock hasn't been detected, then
+		 * do nothing.
+		 */
+		if (unlikely(cpuset_set_oom(current)) &&
+		    !oom_is_deadlocked(&last_tif_memdie))
+			goto out_cpuset;
+		cpuset_set_last_tif_memdie(current, last_tif_memdie);
+		select_and_kill_process(gfp_mask, order, constraint);
+
+	out_cpuset:
+		read_unlock(&tasklist_lock);
+		break;
 	case CONSTRAINT_NONE:
 		if (down_trylock(&OOM_lock))
 			break;
@@ -467,7 +484,7 @@ void out_of_memory(struct zonelist *zone
 		 */
 		if (unlikely(test_bit(0, &VM_is_OOM)) &&
 		    !oom_is_deadlocked(&last_tif_memdie_jiffies))
-			goto out;
+			goto out_none;
 
 		if (sysctl_panic_on_oom) {
 			read_unlock(&tasklist_lock);
@@ -477,7 +494,7 @@ void out_of_memory(struct zonelist *zone
 
 		select_and_kill_process(gfp_mask, order, constraint);
 
-	out:
+	out_none:
 		read_unlock(&tasklist_lock);
 		up(&OOM_lock);
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
