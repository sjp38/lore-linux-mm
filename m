Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D8CDA6B006C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:42 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4763716eek.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:42 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/9] numa, sched: Implement wake-cpu migration support
Date: Fri,  7 Dec 2012 01:19:20 +0100
Message-Id: <1354839566-15697-4-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Task flipping via sched_rebalance_to() was only partially successful
in a number of cases, especially with modified preemption options.

The reason was that when we'd migrate over to the target node,
with the right timing the source task might already be sleeping
waiting for the migration thread to run - which prevented it
from changing its target CPU.

But we cannot simply set the CPU in the migration handler, because
our per entity load average calculations rely on tasks spending
their sleeping time on the CPU they went to sleep and only being
requeued at wakeup.

So introduce a ->wake_cpu construct to allow the migration at
wakeup time. This gives us maximum information while still
preserving the task-flipping destination.

( Also make sure we don't wake up to CPUs that are outside
  the hard affinity ->cpus_allowed CPU mask. )

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/init_task.h |  3 ++-
 include/linux/sched.h     |  1 +
 kernel/sched/core.c       |  3 +++
 kernel/sched/fair.c       | 14 +++++++++++---
 4 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index a5da0fc..ec31d7b 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -146,7 +146,8 @@ extern struct task_group root_task_group;
 #ifdef CONFIG_NUMA_BALANCING
 # define INIT_TASK_NUMA(tsk)						\
 	.numa_shared = -1,						\
-	.numa_shared_enqueue = -1
+	.numa_shared_enqueue = -1,					\
+	.wake_cpu = -1,
 #else
 # define INIT_TASK_NUMA(tsk)
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index ee39f6b..1c3cc50 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1502,6 +1502,7 @@ struct task_struct {
 	short il_next;
 	short pref_node_fork;
 #endif
+	int wake_cpu;
 #ifdef CONFIG_NUMA_BALANCING
 	int numa_shared;
 	int numa_shared_enqueue;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index a7f0000..cfa8426 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1546,6 +1546,7 @@ static void __sched_fork(struct task_struct *p)
 #ifdef CONFIG_PREEMPT_NOTIFIERS
 	INIT_HLIST_HEAD(&p->preempt_notifiers);
 #endif
+	p->wake_cpu = -1;
 
 #ifdef CONFIG_NUMA_BALANCING
 	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
@@ -4782,6 +4783,8 @@ static int __migrate_task(struct task_struct *p, int src_cpu, int dest_cpu)
 		set_task_cpu(p, dest_cpu);
 		enqueue_task(rq_dest, p, 0);
 		check_preempt_curr(rq_dest, p, 0);
+	} else {
+		p->wake_cpu = dest_cpu;
 	}
 done:
 	ret = 1;
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8cdbfde..8664f39 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -4963,6 +4963,12 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 	int new_cpu = cpu;
 	int want_affine = 0;
 	int sync = wake_flags & WF_SYNC;
+	int wake_cpu = p->wake_cpu;
+
+	if (wake_cpu != -1 && cpumask_test_cpu(wake_cpu, tsk_cpus_allowed(p))) {
+		p->wake_cpu = -1;
+		return wake_cpu;
+	}
 
 	if (p->nr_cpus_allowed == 1)
 		return prev_cpu;
@@ -5044,10 +5050,12 @@ select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flags)
 		/* while loop will break here if sd == NULL */
 	}
 unlock:
-	rcu_read_unlock();
+	if (!numa_allow_migration(p, prev0_cpu, new_cpu)) {
+		if (cpumask_test_cpu(prev0_cpu, tsk_cpus_allowed(p)))
+			new_cpu = prev0_cpu;
+	}
 
-	if (!numa_allow_migration(p, prev0_cpu, new_cpu))
-		return prev0_cpu;
+	rcu_read_unlock();
 
 	return new_cpu;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
