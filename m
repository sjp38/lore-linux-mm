Message-Id: <20071121080225.916131000@sgi.com>
References: <20071121080225.606291000@sgi.com>
Date: Wed, 21 Nov 2007 00:02:27 -0800
From: travis@sgi.com
Subject: [PATCH 2/2] cpumask: Convert set_cpus_allowed to use ptr for cpumask arg
Content-Disposition: inline; filename=set_cpus_allowed-use-ptr-arg
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: mingo@elte.hu, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Avoid pushing cpumask variables onto stack when calling set_cpus_allowed
when NR_CPUS > BITS_PER_LONG by passing cpumast_t arg as a pointer.

Signed-off-by: Mike Travis <travis@sgi.com>

---
 include/linux/sched.h |   11 +++++++++--
 kernel/sched.c        |   22 ++++++++++++++++------
 2 files changed, 25 insertions(+), 8 deletions(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1435,8 +1435,15 @@ static inline void put_task_struct(struc
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
-#ifdef CONFIG_SMP
-extern int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask);
+#if defined(CONFIG_SMP)
+#  if NR_CPUS > BITS_PER_LONG
+     /* avoid pushing cpumask variable onto the stack */
+#    define set_cpus_allowed(p, new_mask) __set_cpus_allowed((p), &(new_mask))
+     extern int __set_cpus_allowed(struct task_struct *p, cpumask_t *new_mask);
+#  else
+#    define set_cpus_allowed(p, new_mask) __set_cpus_allowed((p), (new_mask))
+     extern int __set_cpus_allowed(struct task_struct *p, cpumask_t new_mask);
+#  endif
 #else
 static inline int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
 {
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5036,7 +5036,16 @@ static inline void sched_init_granularit
  * task must not exit() & deallocate itself prematurely.  The
  * call is not atomic; no spinlocks may be held.
  */
-int set_cpus_allowed(struct task_struct *p, cpumask_t new_mask)
+#if NR_CPUS > BITS_PER_LONG
+/*
+ * avoid pushing a large CPU count cpumask_t variable onto stack
+ * (relies on the fact that new_mask is a const arg to subfunctions)
+ */
+#define CPU_MASK_VAR(v)		*v
+#else
+#define CPU_MASK_VAR(v)		v
+#endif
+int __set_cpus_allowed(struct task_struct *p, cpumask_t CPU_MASK_VAR(new_mask))
 {
 	struct migration_req req;
 	unsigned long flags;
@@ -5044,17 +5053,17 @@ int set_cpus_allowed(struct task_struct 
 	int ret = 0;
 
 	rq = task_rq_lock(p, &flags);
-	if (!cpus_intersects(new_mask, cpu_online_map)) {
+	if (!cpus_intersects(CPU_MASK_VAR(new_mask), cpu_online_map)) {
 		ret = -EINVAL;
 		goto out;
 	}
 
-	p->cpus_allowed = new_mask;
+	p->cpus_allowed = CPU_MASK_VAR(new_mask);
 	/* Can the task run on the task's current CPU? If so, we're done */
-	if (cpu_isset(task_cpu(p), new_mask))
+	if (cpu_isset(task_cpu(p), CPU_MASK_VAR(new_mask)))
 		goto out;
 
-	if (migrate_task(p, any_online_cpu(new_mask), &req)) {
+	if (migrate_task(p, any_online_cpu(CPU_MASK_VAR(new_mask)), &req)) {
 		/* Need help from migration thread: drop lock and wait. */
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
@@ -5067,7 +5076,8 @@ out:
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(set_cpus_allowed);
+/* keep CPU_MASK_VAR local to __set_cpus_allowed */
+EXPORT_SYMBOL_GPL(__set_cpus_allowed);
 
 /*
  * Move (not current) task off this cpu, onto dest cpu.  We're doing

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
