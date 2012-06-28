Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 343466B0078
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:56:59 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 09/40] autonuma: introduce kthread_bind_node()
Date: Thu, 28 Jun 2012 14:55:49 +0200
Message-Id: <1340888180-15355-10-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This function makes it easy to bind the per-node knuma_migrated
threads to their respective NUMA nodes. Those threads take memory from
the other nodes (in round robin with a incoming queue for each remote
node) and they move that memory to their local node.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/kthread.h |    1 +
 include/linux/sched.h   |    2 +-
 kernel/kthread.c        |   23 +++++++++++++++++++++++
 3 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 0714b24..e733f97 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -33,6 +33,7 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 })
 
 void kthread_bind(struct task_struct *k, unsigned int cpu);
+void kthread_bind_node(struct task_struct *p, int nid);
 int kthread_stop(struct task_struct *k);
 int kthread_should_stop(void);
 bool kthread_freezable_should_stop(bool *was_frozen);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4059c0f..699324c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1792,7 +1792,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
-#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
+#define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpus */
 #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 3d3de63..48b36f9 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -234,6 +234,29 @@ void kthread_bind(struct task_struct *p, unsigned int cpu)
 EXPORT_SYMBOL(kthread_bind);
 
 /**
+ * kthread_bind_node - bind a just-created kthread to the CPUs of a node.
+ * @p: thread created by kthread_create().
+ * @nid: node (might not be online, must be possible) for @k to run on.
+ *
+ * Description: This function is equivalent to set_cpus_allowed(),
+ * except that @nid doesn't need to be online, and the thread must be
+ * stopped (i.e., just returned from kthread_create()).
+ */
+void kthread_bind_node(struct task_struct *p, int nid)
+{
+	/* Must have done schedule() in kthread() before we set_task_cpu */
+	if (!wait_task_inactive(p, TASK_UNINTERRUPTIBLE)) {
+		WARN_ON(1);
+		return;
+	}
+
+	/* It's safe because the task is inactive. */
+	do_set_cpus_allowed(p, cpumask_of_node(nid));
+	p->flags |= PF_THREAD_BOUND;
+}
+EXPORT_SYMBOL(kthread_bind_node);
+
+/**
  * kthread_stop - stop a thread created by kthread_create().
  * @k: thread created by kthread_create().
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
