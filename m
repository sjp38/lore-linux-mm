Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65B566B0270
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a8so10061953pfc.6
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o6si555656plh.437.2017.10.20.05.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:29 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/15] sched/task_struct: convert task_struct.stack_refcount to refcount_t
Date: Fri, 20 Oct 2017 15:15:48 +0300
Message-Id: <1508501757-15784-7-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable task_struct.stack_refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/init_task.h        | 3 ++-
 include/linux/sched.h            | 2 +-
 include/linux/sched/task_stack.h | 2 +-
 kernel/fork.c                    | 6 +++---
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 64d86ec..d3bc6ac 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -12,6 +12,7 @@
 #include <linux/securebits.h>
 #include <linux/seqlock.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/sched/autogroup.h>
 #include <net/net_namespace.h>
 #include <linux/sched/rt.h>
@@ -206,7 +207,7 @@ extern struct cred init_cred;
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 # define INIT_TASK_TI(tsk)			\
 	.thread_info = INIT_THREAD_INFO(tsk),	\
-	.stack_refcount = ATOMIC_INIT(1),
+	.stack_refcount = REFCOUNT_INIT(1),
 #else
 # define INIT_TASK_TI(tsk)
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 47f1101..4eb19f9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1091,7 +1091,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/* A live task holds one reference: */
-	atomic_t			stack_refcount;
+	refcount_t			stack_refcount;
 #endif
 #ifdef CONFIG_LIVEPATCH
 	int patch_state;
diff --git a/include/linux/sched/task_stack.h b/include/linux/sched/task_stack.h
index df6ea66..aab3809 100644
--- a/include/linux/sched/task_stack.h
+++ b/include/linux/sched/task_stack.h
@@ -60,7 +60,7 @@ static inline unsigned long *end_of_stack(struct task_struct *p)
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 static inline void *try_get_task_stack(struct task_struct *tsk)
 {
-	return atomic_inc_not_zero(&tsk->stack_refcount) ?
+	return refcount_inc_not_zero(&tsk->stack_refcount) ?
 		task_stack_page(tsk) : NULL;
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 68cc7a0..b7b26d5a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -362,7 +362,7 @@ static void release_task_stack(struct task_struct *tsk)
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 void put_task_stack(struct task_struct *tsk)
 {
-	if (atomic_dec_and_test(&tsk->stack_refcount))
+	if (refcount_dec_and_test(&tsk->stack_refcount))
 		release_task_stack(tsk);
 }
 #endif
@@ -380,7 +380,7 @@ void free_task(struct task_struct *tsk)
 	 * If the task had a separate stack allocation, it should be gone
 	 * by now.
 	 */
-	WARN_ON_ONCE(atomic_read(&tsk->stack_refcount) != 0);
+	WARN_ON_ONCE(refcount_read(&tsk->stack_refcount) != 0);
 #endif
 	rt_mutex_debug_task_free(tsk);
 	ftrace_graph_exit_task(tsk);
@@ -795,7 +795,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->stack_vm_area = stack_vm_area;
 #endif
 #ifdef CONFIG_THREAD_INFO_IN_TASK
-	atomic_set(&tsk->stack_refcount, 1);
+	refcount_set(&tsk->stack_refcount, 1);
 #endif
 
 	if (err)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
