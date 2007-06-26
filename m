Date: Tue, 26 Jun 2007 10:00:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: serialize oom killer for cpusets
Message-ID: <alpine.DEB.0.99.0706260241460.26409@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Serializes the OOM killer for tasks attached to a cpuset.

If our memory allocation is constrained by a cpuset and we are currently
out of memory, we could end up killing multiple tasks when only the first
one is needed to alleviate the condition.  This patch serializes the OOM
killer so that only one task will be killed and then the allocation is
retried.

We cannot add a simple mutex to struct cpuset because we are required to
take task->alloc_lock to dereference task->cpuset.  Instead of using a
simple trylock instead, we can use only a single bit in struct cpuset's
flags field along with atomic operations.  CS_OOM is added to mark a
cpuset that has a corresponding task currently in the OOM killer.

Since current's cpuset must remain constant between cpuset_enter_oom()
and cpuset_exit_oom() so that we clear CS_OOM for the correct cpuset, we
must disallow tasks from being reassigned while in the OOM killer.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/cpuset.h |    8 ++++++++
 kernel/cpuset.c        |   46 ++++++++++++++++++++++++++++++++++++++++++----
 mm/oom_kill.c          |    3 +++
 3 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -46,6 +46,8 @@ static int inline cpuset_zone_allowed_hardwall(struct zone *z, gfp_t gfp_mask)
 }
 
 extern int cpuset_excl_nodes_overlap(const struct task_struct *p);
+extern int cpuset_enter_oom(struct task_struct *task);
+extern void cpuset_exit_oom(struct task_struct *task);
 
 #define cpuset_memory_pressure_bump() 				\
 	do {							\
@@ -118,6 +120,12 @@ static inline int cpuset_excl_nodes_overlap(const struct task_struct *p)
 	return 1;
 }
 
+static inline int cpuset_enter_oom(struct task_struct *task)
+{
+	return 0;
+}
+
+static inline void cpuset_exit_oom(struct task_struct *task) {}
 static inline void cpuset_memory_pressure_bump(void) {}
 
 static inline char *cpuset_task_status_allowed(struct task_struct *task,
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -109,6 +109,7 @@ typedef enum {
 	CS_NOTIFY_ON_RELEASE,
 	CS_SPREAD_PAGE,
 	CS_SPREAD_SLAB,
+	CS_OOM,
 } cpuset_flagbits_t;
 
 /* convenient tests for these bits */
@@ -147,6 +148,11 @@ static inline int is_spread_slab(const struct cpuset *cs)
 	return test_bit(CS_SPREAD_SLAB, &cs->flags);
 }
 
+static inline int is_oom(const struct cpuset *cs)
+{
+	return test_bit(CS_OOM, &cs->flags);
+}
+
 /*
  * Increment this integer everytime any cpuset changes its
  * mems_allowed value.  Users of cpusets can track this generation
@@ -1251,10 +1257,16 @@ static int attach_task(struct cpuset *cs, char *pidbuf, char **ppathbuf)
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
+	 * If this cpuset is currently in the OOM killer, we cannot remove it
+	 * because then we'll never clear the CS_OOM bit.
+	 */
+	if (unlikely(is_oom(oldcs))) {
+		retval = -EBUSY;
+		goto error;
 	}
 	atomic_inc(&cs->count);
 	rcu_assign_pointer(tsk->cpuset, cs);
@@ -1281,6 +1293,12 @@ static int attach_task(struct cpuset *cs, char *pidbuf, char **ppathbuf)
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
@@ -2355,6 +2373,26 @@ static const struct cpuset *nearest_exclusive_ancestor(const struct cpuset *cs)
 	return cs;
 }
 
+/*
+ * Test and set the CS_OOM bit for task's cpuset.  Returns 1 if the cpuset
+ * attached to the task is already in the OOM killer; otherwise, returns 0.
+ */
+int cpuset_enter_oom(struct task_struct *task)
+{
+	int ret;
+	task_lock(task);
+	ret = test_and_set_bit(CS_OOM, &task->cpuset->flags);
+	task_unlock(task);
+	return ret;
+}
+
+void cpuset_exit_oom(struct task_struct *task)
+{
+	task_lock(task);
+	clear_bit(CS_OOM, &task->cpuset->flags);
+	task_unlock(task);
+}
+
 /**
  * cpuset_zone_allowed_softwall - Can we allocate on zone z's memory node?
  * @z: is this zone on an allowed node?
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -405,10 +405,13 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 		break;
 
 	case CONSTRAINT_CPUSET:
+		if (cpuset_enter_oom(current))
+			break;
 		read_lock(&tasklist_lock);
 		oom_kill_process(current, points,
 				 "No available memory in cpuset", gfp_mask, order);
 		read_unlock(&tasklist_lock);
+		cpuset_exit_oom(current);
 		break;
 
 	case CONSTRAINT_NONE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
