Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7FD86B026E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d28so10086492pfe.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d10si665611pgc.100.2017.10.20.05.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:23 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 05/15] sched/task_struct: convert task_struct.usage to refcount_t
Date: Fri, 20 Oct 2017 15:15:47 +0300
Message-Id: <1508501757-15784-6-git-send-email-elena.reshetova@intel.com>
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

The variable task_struct.usage is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

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
index a85376e..64d86ec 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -226,7 +226,7 @@ extern struct cred init_cred;
 	INIT_TASK_TI(tsk)						\
 	.state		= 0,						\
 	.stack		= init_stack,					\
-	.usage		= ATOMIC_INIT(2),				\
+	.usage		= REFCOUNT_INIT(2),				\
 	.flags		= PF_KTHREAD,					\
 	.prio		= MAX_PRIO-20,					\
 	.static_prio	= MAX_PRIO-20,					\
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0f897df..47f1101 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -20,6 +20,7 @@
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
index a5e6f09..ac4317d 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -85,13 +85,13 @@ extern void sched_exec(void);
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
index 869850b..68cc7a0 100644
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
