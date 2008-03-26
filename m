Message-Id: <20080326212347.792178000@polaris-admin.engr.sgi.com>
References: <20080326212347.466221000@polaris-admin.engr.sgi.com>
Date: Wed, 26 Mar 2008 14:23:49 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 2/2] sched: add new set_cpus_allowed_ptr function
Content-Disposition: inline; filename=add-set_cpus_allowed_ptr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a new function that accepts a pointer to the "newly allowed cpus"
cpumask argument.

int set_cpus_allowed_ptr(struct task_struct *p, const cpumask_t *new_mask)

The current set_cpus_allowed() function is modified to use the above
but this does not result in an ABI change.  And with some compiler
optimization help, it may not introduce any additional overhead.

Additionally, to enforce the read only nature of the new_mask arg, the
"const" property is migrated to sub-functions called by set_cpus_allowed.
This silences compiler warnings.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/sched.h |   15 +++++++++++----
 kernel/sched.c        |   14 +++++++-------
 kernel/sched_rt.c     |    3 ++-
 3 files changed, 20 insertions(+), 12 deletions(-)

--- linux.trees.git.orig/include/linux/sched.h
+++ linux.trees.git/include/linux/sched.h
@@ -889,7 +889,8 @@ struct sched_class {
 	void (*set_curr_task) (struct rq *rq);
 	void (*task_tick) (struct rq *rq, struct task_struct *p, int queued);
 	void (*task_new) (struct rq *rq, struct task_struct *p);
-	void (*set_cpus_allowed)(struct task_struct *p, cpumask_t *newmask);
+	void (*set_cpus_allowed)(struct task_struct *p,
+				 const cpumask_t *newmask);
 
 	void (*join_domain)(struct rq *rq);
 	void (*leave_domain)(struct rq *rq);
@@ -1501,15 +1502,21 @@ static inline void put_task_struct(struc
 #define used_math() tsk_used_math(current)
 
 #ifdef CONFIG_SMP
-extern int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask);
+extern int set_cpus_allowed_ptr(struct task_struct *p,
+				const cpumask_t *new_mask);
 #else
-static inline int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+static inline int set_cpus_allowed_ptr(struct task_struct *p,
+				       const cpumask_t *new_mask)
 {
-	if (!cpu_isset(0, new_mask))
+	if (!cpu_isset(0, *new_mask))
 		return -EINVAL;
 	return 0;
 }
 #endif
+static inline int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+{
+	return set_cpus_allowed_ptr(p, &new_mask);
+}
 
 extern unsigned long long sched_clock(void);
 
--- linux.trees.git.orig/kernel/sched.c
+++ linux.trees.git/kernel/sched.c
@@ -5295,7 +5295,7 @@ static inline void sched_init_granularit
  * task must not exit() & deallocate itself prematurely. The
  * call is not atomic; no spinlocks may be held.
  */
-int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+int set_cpus_allowed_ptr(struct task_struct *p, const cpumask_t *new_mask)
 {
 	struct migration_req req;
 	unsigned long flags;
@@ -5303,23 +5303,23 @@ int set_cpus_allowed(struct task_struct 
 	int ret = 0;
 
 	rq = task_rq_lock(p, &flags);
-	if (!cpus_intersects(new_mask, cpu_online_map)) {
+	if (!cpus_intersects(*new_mask, cpu_online_map)) {
 		ret = -EINVAL;
 		goto out;
 	}
 
 	if (p->sched_class->set_cpus_allowed)
-		p->sched_class->set_cpus_allowed(p, &new_mask);
+		p->sched_class->set_cpus_allowed(p, new_mask);
 	else {
-		p->cpus_allowed = new_mask;
-		p->rt.nr_cpus_allowed = cpus_weight(new_mask);
+		p->cpus_allowed = *new_mask;
+		p->rt.nr_cpus_allowed = cpus_weight(*new_mask);
 	}
 
 	/* Can the task run on the task's current CPU? If so, we're done */
-	if (cpu_isset(task_cpu(p), new_mask))
+	if (cpu_isset(task_cpu(p), *new_mask))
 		goto out;
 
-	if (migrate_task(p, any_online_cpu(new_mask), &req)) {
+	if (migrate_task(p, any_online_cpu(*new_mask), &req)) {
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
--- linux.trees.git.orig/kernel/sched_rt.c
+++ linux.trees.git/kernel/sched_rt.c
@@ -1001,7 +1001,8 @@ move_one_task_rt(struct rq *this_rq, int
 	return 0;
 }
 
-static void set_cpus_allowed_rt(struct task_struct *p, cpumask_t *new_mask)
+static void set_cpus_allowed_rt(struct task_struct *p,
+				const cpumask_t *new_mask)
 {
 	int weight = cpus_weight(*new_mask);
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
