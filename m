Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 553156B0266
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:08:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s11so17683276pgc.13
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:08:27 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v39si12472195pgn.809.2017.11.15.06.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:08:26 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 07/16] sched/task_struct: convert task_struct.stack_refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:31 +0200
Message-Id: <1510754620-27088-8-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
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

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the task_struct.stack_refcount it might make a difference
in following places:
 - try_get_task_stack(): increment in refcount_inc_not_zero() only
   guarantees control dependency on success vs. fully ordered
   atomic counterpart
 - put_task_stack(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

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
index 1e35fce..6a87579 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -13,6 +13,7 @@
 #include <linux/securebits.h>
 #include <linux/seqlock.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/sched/autogroup.h>
 #include <net/net_namespace.h>
 #include <linux/sched/rt.h>
@@ -207,7 +208,7 @@ extern struct cred init_cred;
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 # define INIT_TASK_TI(tsk)			\
 	.thread_info = INIT_THREAD_INFO(tsk),	\
-	.stack_refcount = ATOMIC_INIT(1),
+	.stack_refcount = REFCOUNT_INIT(1),
 #else
 # define INIT_TASK_TI(tsk)
 #endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 924a812..c8c6d17 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1098,7 +1098,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/* A live task holds one reference: */
-	atomic_t			stack_refcount;
+	refcount_t			stack_refcount;
 #endif
 #ifdef CONFIG_LIVEPATCH
 	int patch_state;
diff --git a/include/linux/sched/task_stack.h b/include/linux/sched/task_stack.h
index cb4828a..4559316 100644
--- a/include/linux/sched/task_stack.h
+++ b/include/linux/sched/task_stack.h
@@ -61,7 +61,7 @@ static inline unsigned long *end_of_stack(struct task_struct *p)
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 static inline void *try_get_task_stack(struct task_struct *tsk)
 {
-	return atomic_inc_not_zero(&tsk->stack_refcount) ?
+	return refcount_inc_not_zero(&tsk->stack_refcount) ?
 		task_stack_page(tsk) : NULL;
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 16df4f5..822efa2 100644
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
