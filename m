Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C48556B0266
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:08:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p2so21005728pfk.13
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:08:21 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a6si8549271plt.76.2017.11.15.06.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:08:20 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/16] sched/task_struct: convert task_struct.usage to refcount_t
Date: Wed, 15 Nov 2017 16:03:30 +0200
Message-Id: <1510754620-27088-7-git-send-email-elena.reshetova@intel.com>
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

The variable task_struct.usage is used as pure reference counter.
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

For the task_struct.usage it might make a difference
in following places:
 - put_task_struct(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/init_task.h  | 2 +-
 include/linux/sched.h      | 3 ++-
 include/linux/sched/task.h | 4 ++--
 kernel/fork.c              | 4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 9eb2ce8..1e35fce 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -227,7 +227,7 @@ extern struct cred init_cred;
 	INIT_TASK_TI(tsk)						\
 	.state		= 0,						\
 	.stack		= init_stack,					\
-	.usage		= ATOMIC_INIT(2),				\
+	.usage		= REFCOUNT_INIT(2),				\
 	.flags		= PF_KTHREAD,					\
 	.prio		= MAX_PRIO-20,					\
 	.static_prio	= MAX_PRIO-20,					\
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 44f9df5..924a812 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -21,6 +21,7 @@
 #include <linux/seccomp.h>
 #include <linux/nodemask.h>
 #include <linux/rcupdate.h>
+#include <linux/refcount.h>
 #include <linux/resource.h>
 #include <linux/latencytop.h>
 #include <linux/sched/prio.h>
@@ -536,7 +537,7 @@ struct task_struct {
 	randomized_struct_fields_start
 
 	void				*stack;
-	atomic_t			usage;
+	refcount_t			usage;
 	/* Per task flags (PF_*), defined further below: */
 	unsigned int			flags;
 	unsigned int			ptrace;
diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index 5be31eb..dae8d04 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -86,13 +86,13 @@ extern void sched_exec(void);
 #define sched_exec()   {}
 #endif
 
-#define get_task_struct(tsk) do { atomic_inc(&(tsk)->usage); } while(0)
+#define get_task_struct(tsk) do { refcount_inc(&(tsk)->usage); } while(0)
 
 extern void __put_task_struct(struct task_struct *t);
 
 static inline void put_task_struct(struct task_struct *t)
 {
-	if (atomic_dec_and_test(&t->usage))
+	if (refcount_dec_and_test(&t->usage))
 		__put_task_struct(t);
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index a65ec7d..16df4f5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -649,7 +649,7 @@ static inline void put_signal_struct(struct signal_struct *sig)
 void __put_task_struct(struct task_struct *tsk)
 {
 	WARN_ON(!tsk->exit_state);
-	WARN_ON(atomic_read(&tsk->usage));
+	WARN_ON(refcount_read(&tsk->usage));
 	WARN_ON(tsk == current);
 
 	cgroup_free(tsk);
@@ -824,7 +824,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	 * One for us, one for whoever does the "release_task()" (usually
 	 * parent)
 	 */
-	atomic_set(&tsk->usage, 2);
+	refcount_set(&tsk->usage, 2);
 #ifdef CONFIG_BLK_DEV_IO_TRACE
 	tsk->btrace_seq = 0;
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
