Received: from attica.americas.sgi.com (attica.americas.sgi.com [128.162.236.44])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id ABE99908B3
	for <linux-mm@kvack.org>; Tue, 22 May 2007 13:53:00 -0700 (PDT)
Date: Tue, 22 May 2007 15:53:00 -0500
Subject: [PATCH 1/1] hotplug cpu: migrate a task within its cpuset
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20070522205300.708C2371896@attica.americas.sgi.com>
From: cpw@sgi.com (Cliff Wickman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(this is a third submission -- corrects a locking/blocking issue pointed
 out by Nathan Lynch)

When a cpu is disabled, move_task_off_dead_cpu() is called for tasks
that have been running on that cpu.

Currently, such a task is migrated:
 1) to any cpu on the same node as the disabled cpu, which is both online
    and among that task's cpus_allowed
 2) to any cpu which is both online and among that task's cpus_allowed

It is typical of a multithreaded application running on a large NUMA system
to have its tasks confined to a cpuset so as to cluster them near the
memory that they share. Furthermore, it is typical to explicitly place such
a task on a specific cpu in that cpuset.  And in that case the task's
cpus_allowed includes only a single cpu.

This patch inserts a preference to migrate such a task to some cpu within
its cpuset (and set its cpus_allowed to its entire cpuset).

With this patch, migrate the task to:
 1) to any cpu on the same node as the disabled cpu, which is both online
    and among that task's cpus_allowed
 2) to any online cpu within the task's cpuset
 3) to any cpu which is both online and among that task's cpus_allowed


In order to do this, move_task_off_dead_cpu() must make a call to
cpuset_cpus_allowed(), which may block.

move_task_off_dead_cpu() has been within a critical region when called
from migrate_live_tasks().  So this patch also changes migrate_live_tasks()
to enable interrupts before calling move_task_off_dead_cpu().
Since the tasklist_lock is dropped, the list scan must be restarted from
the top.
It locks the migrating task by bumping its usage count.
It disables interrupts in move_task_off_dead_cpu() before the
 call to __migrate_task().

This is the outline of the locking surrounding calls to
move_task_off_dead_cpu(), after applying this patch:

  migration_call()
  | case CPU_DEAD
  |   migrate_live_tasks(cpu)
  |   | recheck:
  |   | write_lock_irq(&tasklist_lock)
  |   | do_each_thread(t, p) {
  |   |         if (task_cpu(p) == src_cpu)
  |   |                 get_task_struct(p)
  |   |                 write_unlock_irq(&tasklist_lock)
  |   |                 move_task_off_dead_cpu(src_cpu, p) <<<< noncritical
  |   |                 put_task_struct(p);
  |   |                 goto recheck
  |   | } while_each_thread(t, p)
  |   | write_unlock_irq(&tasklist_lock)
  |
  |   rq = task_rq_lock(rq->idle, &flags)
  |
  |   migrate_dead_tasks(cpu)
  |   | for (arr = 0; arr < 2; arr++) {
  |   |   for (i = 0; i < MAX_PRIO; i++) {
  |   |     while (!list_empty(list))
  |   |       migrate_dead(dead_cpu
  |   |         get_task_struct(p)
  |   |         spin_unlock_irq(&rq->lock)
  |   |         move_task_off_dead_cpu(dead_cpu, p)        <<<< noncritcal
  |   |         spin_lock_irq(&rq->lock)
  |   |         put_task_struct(p)
  |
  |   task_rq_unlock(rq, &flags)

[Side note: a task may be migrated off of its cpuset, but is still attached to
 that cpuset (by pointer and reference count).  The cpuset will not be
 released.  This patch does not change that.]

Diffed against 2.6.21

Signed-off-by: Cliff Wickman <cpw@sgi.com>

 kernel/sched.c |   31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

Index: linus.070504/kernel/sched.c
===================================================================
--- linus.070504.orig/kernel/sched.c
+++ linus.070504/kernel/sched.c
@@ -4989,7 +4989,7 @@ wait_to_die:
 #ifdef CONFIG_HOTPLUG_CPU
 /*
  * Figure out where task on dead CPU should go, use force if neccessary.
- * NOTE: interrupts should be disabled by the caller
+ * NOTE: interrupts are not disabled by the caller
  */
 static void move_task_off_dead_cpu(int dead_cpu, struct task_struct *p)
 {
@@ -5008,6 +5008,17 @@ restart:
 	if (dest_cpu == NR_CPUS)
 		dest_cpu = any_online_cpu(p->cpus_allowed);
 
+	/* try to stay on the same cpuset */
+	if (dest_cpu == NR_CPUS) {
+		/*
+		 * Call to cpuset_cpus_allowed may sleep, so we depend
+		 * on move_task_off_dead_cpu() being called in a non-critical
+		 * region.
+		 */
+		p->cpus_allowed = cpuset_cpus_allowed(p);
+		dest_cpu = any_online_cpu(p->cpus_allowed);
+	}
+
 	/* No more Mr. Nice Guy. */
 	if (dest_cpu == NR_CPUS) {
 		rq = task_rq_lock(p, &flags);
@@ -5025,8 +5036,16 @@ restart:
 			       "longer affine to cpu%d\n",
 			       p->pid, p->comm, dead_cpu);
 	}
-	if (!__migrate_task(p, dead_cpu, dest_cpu))
+	/*
+	 * __migrate_task() requires interrupts to be disabled
+	 */
+	local_irq_disable();
+	if (!__migrate_task(p, dead_cpu, dest_cpu)) {
+		local_irq_enable();
 		goto restart;
+	}
+	local_irq_enable();
+	return;
 }
 
 /*
@@ -5054,14 +5073,20 @@ static void migrate_live_tasks(int src_c
 {
 	struct task_struct *p, *t;
 
+restartlist:
 	write_lock_irq(&tasklist_lock);
 
 	do_each_thread(t, p) {
 		if (p == current)
 			continue;
 
-		if (task_cpu(p) == src_cpu)
+		if (task_cpu(p) == src_cpu) {
+			get_task_struct(p);
+			write_unlock_irq(&tasklist_lock);
 			move_task_off_dead_cpu(src_cpu, p);
+			put_task_struct(p);
+			goto restartlist;
+		}
 	} while_each_thread(t, p);
 
 	write_unlock_irq(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
