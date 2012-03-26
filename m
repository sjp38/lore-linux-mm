Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4F00C6B007E
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:11:34 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/39] autonuma: introduce kthread_bind_node()
Date: Mon, 26 Mar 2012 19:45:54 +0200
Message-Id: <1332783986-24195-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

This function makes it easy to bind the per-node knuma_migrated
threads to their respective NUMA nodes. Those threads take memory from
the other nodes (in round robin with a incoming queue for each remote
node) and they move that memory to their local node.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/kthread.h |    1 +
 kernel/kthread.c        |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
