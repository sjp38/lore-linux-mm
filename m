Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 269ED6B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 16:59:46 -0400 (EDT)
Message-Id: <b867e87f5f90e6683a8d7d958d7b96f236bb46fd.1340224753.git.tony.luck@intel.com>
In-Reply-To: <CA+8MBbJVFdz0g9dqz+3YbsGypKw4-tLb2XgoFq=_qOoq_Yq=Tw@mail.gmail.com>
From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 20 Jun 2012 12:12:18 -0700
Subject: [PATCH] sched: Fix build problems when CONFIG_NUMA=y and CONFIG_SMP=n
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It is possible to have a single cpu system with both local
and remote memory.

Signed-off-by: Tony Luck <tony.luck@intel.com>
---

Broken in linux-next for the past couple of days. Perhaps
we need some more stubs though - sched_fork() seems to need
#ifdef CONFIG_SMP around every other line ... not pretty.

Another approach would be to outlaw such strange configurations
and make sure that CONFIG_SMP is set whenever CONFIG_NUMA is set.
We had such a discussion a long time ago, and at that time
decided to keep supporting it. But with multi-core cpus now
the norm - perhaps it is time to change our minds.

 kernel/sched/core.c  |  2 ++
 kernel/sched/numa.c  | 16 ++++++++++++++++
 kernel/sched/sched.h |  2 +-
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 46460ac..f261599 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -1799,7 +1799,9 @@ void sched_fork(struct task_struct *p)
 #endif
 	put_cpu();
 
+#ifdef CONFIG_SMP
 	select_task_node(p, p->mm, SD_BALANCE_FORK);
+#endif
 }
 
 /*
diff --git a/kernel/sched/numa.c b/kernel/sched/numa.c
index 002f71c..4ff3b7c 100644
--- a/kernel/sched/numa.c
+++ b/kernel/sched/numa.c
@@ -18,6 +18,21 @@
 #include "sched.h"
 
 
+#ifndef CONFIG_SMP
+void mm_init_numa(struct mm_struct *mm)
+{
+}
+void exit_numa(struct mm_struct *mm)
+{
+}
+void account_numa_dequeue(struct task_struct *p)
+{
+}
+__init void init_sched_numa(void)
+{
+}
+#else
+
 static const int numa_balance_interval = 2 * HZ; /* 2 seconds */
 
 struct numa_ops {
@@ -853,3 +868,4 @@ static __init int numa_init(void)
 	return 0;
 }
 early_initcall(numa_init);
+#endif
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 4134d37..9bf5ba8 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -473,7 +473,7 @@ struct rq {
 
 static inline struct list_head *offnode_tasks(struct rq *rq)
 {
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) && defined(CONFIG_SMP)
 	return &rq->offnode_tasks;
 #else
 	return NULL;
-- 
1.7.10.2.552.gaa3bb87

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
