From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 12/12] Track in-kernel when we expect checkpoint/restart to work
Date: Thu, 30 Oct 2008 09:51:15 -0400
Message-Id: <1225374675-22850-13-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
From: Dave Hansen <dave@linux.vnet.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

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
 include/linux/checkpoint.h |   33 ++++++++++++++++++++++++++++++++-
 include/linux/sched.h      |    3 +++
 kernel/fork.c              |   10 ++++++++++
 3 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e9d554e..70cfceb 100644
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
 
@@ -93,4 +96,32 @@ extern int cr_read_files(struct cr_ctx *ctx);
 #define cr_debug(fmt, args...)  \
 	pr_debug("[CR:%s] " fmt, __func__, ## args)
 
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
index 3d9120c..8c50e3b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1301,6 +1301,9 @@ struct task_struct {
 	int latency_record_count;
 	struct latency_record latency_record[LT_SAVECOUNT];
 #endif
+#ifdef CONFIG_CHECKPOINT_RESTART
+	atomic_t may_checkpoint;
+#endif
 };
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 7ce2ebe..d6cf7e4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -194,6 +194,13 @@ void __init fork_init(unsigned long mempages)
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
@@ -244,6 +251,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
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
