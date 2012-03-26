Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 6F7606B00E9
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:49 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 17/39] autonuma: alloc/free/init sched_autonuma
Date: Mon, 26 Mar 2012 19:46:04 +0200
Message-Id: <1332783986-24195-18-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

This is where the dynamically allocated sched_autonuma structure is
being handled.

The reason for keeping this outside of the task_struct besides not
using too much kernel stack, is to only allocate it on NUMA
hardware. So the not NUMA hardware only pays the memory of a pointer
in the kernel stack (which remains NULL at all times in that case).

If the kernel is compiled with CONFIG_AUTONUMA=n, not even the pointer
is allocated on the kernel stack of course.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 kernel/fork.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index ba3b339..938098b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -168,6 +168,7 @@ static void account_kernel_stack(struct thread_info *ti, int account)
 void free_task(struct task_struct *tsk)
 {
 	account_kernel_stack(tsk->stack, -1);
+	free_sched_autonuma(tsk);
 	free_thread_info(tsk->stack);
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
@@ -227,6 +228,8 @@ void __init fork_init(unsigned long mempages)
 	/* do the arch specific task caches init */
 	arch_task_cache_init();
 
+	sched_autonuma_init();
+
 	/*
 	 * The default maximum number of threads is set to a safe
 	 * value: the thread structures can take up at most half
@@ -259,23 +262,23 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	struct thread_info *ti;
 	unsigned long *stackend;
 	int node = tsk_fork_get_node(orig);
-	int err;
 
 	prepare_to_copy(orig);
 
 	tsk = alloc_task_struct_node(node);
-	if (!tsk)
+	if (unlikely(!tsk))
 		return NULL;
 
 	ti = alloc_thread_info_node(tsk, node);
-	if (!ti) {
-		free_task_struct(tsk);
-		return NULL;
-	}
+	if (unlikely(!ti))
+		goto out_task_struct;
 
-	err = arch_dup_task_struct(tsk, orig);
-	if (err)
-		goto out;
+	if (unlikely(arch_dup_task_struct(tsk, orig)))
+		goto out_thread_info;
+
+	if (unlikely(alloc_sched_autonuma(tsk, orig, node)))
+		/* free_thread_info() undoes arch_dup_task_struct() too */
+		goto out_thread_info;
 
 	tsk->stack = ti;
 
@@ -303,8 +306,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 
 	return tsk;
 
-out:
+out_thread_info:
 	free_thread_info(ti);
+out_task_struct:
 	free_task_struct(tsk);
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
