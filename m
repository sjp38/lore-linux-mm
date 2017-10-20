Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC766B026A
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e64so10083256pfk.0
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p33si557434pld.217.2017.10.20.05.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:01 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 01/15] sched: convert sighand_struct.count to refcount_t
Date: Fri, 20 Oct 2017 15:15:43 +0300
Message-Id: <1508501757-15784-2-git-send-email-elena.reshetova@intel.com>
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

The variable sighand_struct.count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/exec.c                    | 4 ++--
 fs/proc/task_nommu.c         | 2 +-
 include/linux/init_task.h    | 2 +-
 include/linux/sched/signal.h | 3 ++-
 kernel/fork.c                | 8 ++++----
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 704e195..20dbd98 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1181,7 +1181,7 @@ static int de_thread(struct task_struct *tsk)
 	flush_itimer_signals();
 #endif
 
-	if (atomic_read(&oldsighand->count) != 1) {
+	if (refcount_read(&oldsighand->count) != 1) {
 		struct sighand_struct *newsighand;
 		/*
 		 * This ->sighand is shared with the CLONE_SIGHAND
@@ -1191,7 +1191,7 @@ static int de_thread(struct task_struct *tsk)
 		if (!newsighand)
 			return -ENOMEM;
 
-		atomic_set(&newsighand->count, 1);
+		refcount_set(&newsighand->count, 1);
 		memcpy(newsighand->action, oldsighand->action,
 		       sizeof(newsighand->action));
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index bdb0d0d..ba680e5 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -63,7 +63,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	else
 		bytes += kobjsize(current->files);
 
-	if (current->sighand && atomic_read(&current->sighand->count) > 1)
+	if (current->sighand && refcount_read(&current->sighand->count) > 1)
 		sbytes += kobjsize(current->sighand);
 	else
 		bytes += kobjsize(current->sighand);
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index cc45798..a85376e 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -85,7 +85,7 @@ extern struct fs_struct init_fs;
 extern struct nsproxy init_nsproxy;
 
 #define INIT_SIGHAND(sighand) {						\
-	.count		= ATOMIC_INIT(1), 				\
+	.count		= REFCOUNT_INIT(1), 				\
 	.action		= { { { .sa_handler = SIG_DFL, } }, },		\
 	.siglock	= __SPIN_LOCK_UNLOCKED(sighand.siglock),	\
 	.signalfd_wqh	= __WAIT_QUEUE_HEAD_INITIALIZER(sighand.signalfd_wqh),	\
diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index c5c137e..b40fbf7 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -7,13 +7,14 @@
 #include <linux/sched/jobctl.h>
 #include <linux/sched/task.h>
 #include <linux/cred.h>
+#include <linux/refcount.h>
 
 /*
  * Types defining task->signal and task->sighand and APIs using them:
  */
 
 struct sighand_struct {
-	atomic_t		count;
+	refcount_t		count;
 	struct k_sigaction	action[_NSIG];
 	spinlock_t		siglock;
 	wait_queue_head_t	signalfd_wqh;
diff --git a/kernel/fork.c b/kernel/fork.c
index 7fe10e5..ab4ddc9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1381,7 +1381,7 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
 	struct sighand_struct *sig;
 
 	if (clone_flags & CLONE_SIGHAND) {
-		atomic_inc(&current->sighand->count);
+		refcount_inc(&current->sighand->count);
 		return 0;
 	}
 	sig = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
@@ -1389,14 +1389,14 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
 	if (!sig)
 		return -ENOMEM;
 
-	atomic_set(&sig->count, 1);
+	refcount_set(&sig->count, 1);
 	memcpy(sig->action, current->sighand->action, sizeof(sig->action));
 	return 0;
 }
 
 void __cleanup_sighand(struct sighand_struct *sighand)
 {
-	if (atomic_dec_and_test(&sighand->count)) {
+	if (refcount_dec_and_test(&sighand->count)) {
 		signalfd_cleanup(sighand);
 		/*
 		 * sighand_cachep is SLAB_TYPESAFE_BY_RCU so we can free it
@@ -2301,7 +2301,7 @@ static int check_unshare_flags(unsigned long unshare_flags)
 			return -EINVAL;
 	}
 	if (unshare_flags & (CLONE_SIGHAND | CLONE_VM)) {
-		if (atomic_read(&current->sighand->count) > 1)
+		if (refcount_read(&current->sighand->count) > 1)
 			return -EINVAL;
 	}
 	if (unshare_flags & CLONE_VM) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
