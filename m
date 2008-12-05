From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v11][PATCH 11/13] Track in-kernel when we expect checkpoint/restart to work
Date: Fri,  5 Dec 2008 12:31:20 -0500
Message-Id: <1228498282-11804-12-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linux Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Dave Hansen <dave@linux.vnet.ibm.com>

Suggested by Ingo.

Checkpoint/restart is going to be a long effort to get things working.
We're going to have a lot of things that we know just don't work for
a long time.  That doesn't mean that it will be useless, it just means
that there's some complicated features that we are going to have to
work incrementally to fix.

This patch introduces a new mechanism to help the checkpoint/restart
developers.  A new function pair: task/process_deny_checkpoint() is
created.  When called, these tell the kernel that we *know* that the
process has performed some activity that will keep it from being
properly checkpointed.

The 'flag' is an atomic_t for now so that we can have some level
of atomicity and make sure to only warn once.

For now, this is a one-way trip.  Once a process is no longer
'may_checkpoint' capable, neither it nor its children ever will be.
This can, of course, be fixed up in the future.  We might want to
reset the flag when a new pid namespace is created, for instance.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c    |    6 ++++++
 include/linux/checkpoint.h |   33 ++++++++++++++++++++++++++++++++-
 include/linux/sched.h      |    4 ++++
 kernel/fork.c              |   10 ++++++++++
 4 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index f2d91f8..e8e352f 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -233,6 +233,12 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 		return -EAGAIN;
 	}
 
+	if (!atomic_read(&t->may_checkpoint)) {
+		pr_warning("c/r: task %d may not checkpoint\n",
+			   task_pid_vnr(t));
+		return -EBUSY;
+	}
+
 	ret = cr_write_task_struct(ctx, t);
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3c29f8e..c97f608 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,8 +10,11 @@
  *  distribution for more details.
  */
 
-#include <linux/path.h>
 #include <linux/fs.h>
+#include <linux/path.h>
+#include <linux/sched.h>
+
+#ifdef CONFIG_CHECKPOINT_RESTART
 
 #define CR_VERSION  2
 
@@ -95,4 +98,32 @@ extern int cr_read_files(struct cr_ctx *ctx);
 #define cr_debug(fmt, args...)  \
 	pr_debug("[%d:c/r:%s] " fmt, task_pid_vnr(current), __func__, ## args)
 
+static inline void __task_deny_checkpointing(struct task_struct *task,
+		char *file, int line)
+{
+	if (!atomic_dec_and_test(&task->may_checkpoint))
+		return;
+	printk(KERN_INFO "process performed an action that can not be "
+			"checkpointed at: %s:%d\n", file, line);
+	WARN_ON(1);
+}
+#define process_deny_checkpointing(p)  \
+	__task_deny_checkpointing(p, __FILE__, __LINE__)
+
+/*
+ * For now, we're not going to have a distinction between
+ * tasks and processes for the purpose of c/r.  But, allow
+ * these two calls anyway to make new users at least think
+ * about it.
+ */
+#define task_deny_checkpointing(p)  \
+	__task_deny_checkpointing(p, __FILE__, __LINE__)
+
+#else
+
+static inline void task_deny_checkpointing(struct task_struct *task) {}
+static inline void process_deny_checkpointing(struct task_struct *task) {}
+
+#endif
+
 #endif /* _CHECKPOINT_CKPT_H_ */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 55e30d1..faa2ec6 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1356,6 +1356,10 @@ struct task_struct {
 	unsigned long default_timer_slack_ns;
 
 	struct list_head	*scm_work_list;
+
+#ifdef CONFIG_CHECKPOINT_RESTART
+	atomic_t may_checkpoint;
+#endif
 };
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 2a372a0..72df853 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -196,6 +196,13 @@ void __init fork_init(unsigned long mempages)
 	init_task.signal->rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
+
+#ifdef CONFIG_CHECKPOINT_RESTART
+	/*
+	 * This probably won't stay set for long...
+	 */
+	atomic_set(&init_task.may_checkpoint, 1);
+#endif
 }
 
 int __attribute__((weak)) arch_dup_task_struct(struct task_struct *dst,
@@ -246,6 +253,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+#ifdef CONFIG_CHECKPOINT_RESTART
+	atomic_set(&tsk->may_checkpoint, atomic_read(&orig->may_checkpoint));
+#endif
 	return tsk;
 
 out:
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
