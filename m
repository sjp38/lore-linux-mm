Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E629B6B00AE
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:19 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 22/60] c/r: external checkpoint of a task other than ourself
Date: Wed, 22 Jul 2009 05:59:44 -0400
Message-Id: <1248256822-23416-23-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container, unless CHECKPOINT_SUBTREE flag is given.

Set state of freezer cgroup of checkpointed task hierarchy to
"CHECKPOINTING" during a checkpoint, to ensure that task(s) cannot be
thawed while at it.

Ensure that all tasks belong to root task's freezer cgroup (the root
task is also tested, to detect it if changes its freezer cgroups
before it moves to "CHECKPOINTING").

sys_restart() remains nearly the same, as the restart is always done
in the context of the restarting task. However, the original task may
have been frozen from user space, or interrupted from a syscall for
the checkpoint. This is accounted for by restoring a suitable retval
for the restarting task, according to how it was checkpointed.

Changelog[v17]:
  - Move restore_retval() to this patch
  - Tighten ptrace ceckpoint for checkpoint to PTRACE_MODE_ATTACH
  - Use CHECKPOINTING state for hierarchy's freezer for checkpoint
Changelog[v16]:
  - Use CHECKPOINT_SUBTREE to allow subtree (partial container)
Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them
Changelog[v10]:
  - Grab vfs root of container init, rather than current process

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/Kconfig               |    1 +
 checkpoint/checkpoint.c          |   99 +++++++++++++++++++++++++++++++++++++-
 checkpoint/restart.c             |   61 +++++++++++++++++++++++-
 checkpoint/sys.c                 |   10 ++++
 include/linux/checkpoint_types.h |    7 ++-
 5 files changed, 175 insertions(+), 3 deletions(-)

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index ef7d406..21fc86b 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -5,6 +5,7 @@
 config CHECKPOINT
 	bool "Checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	depends on CGROUP_FREEZER
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index a465fb6..226735c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -12,6 +12,9 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/freezer.h>
+#include <linux/ptrace.h>
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -255,14 +258,106 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	if (t->state == TASK_DEAD) {
+		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+		return -EAGAIN;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
+		__ckpt_write_err(ctx, "access to task %d (%s) denied",
+				 task_pid_vnr(t), t->comm);
+		return -EPERM;
+	}
+
+	/* verify that all tasks belongs to same freezer cgroup */
+	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
+		__ckpt_write_err(ctx, "task %d (%s) not frozen (wrong cgroup)",
+				 task_pid_vnr(t), t->comm);
+		return -EBUSY;
+	}
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(t)) {
+		__ckpt_write_err(ctx, "task %d (%s) is ptraced",
+				 task_pid_vnr(t), t->comm);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+/* setup checkpoint-specific parts of ctx */
+static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task;
+	struct nsproxy *nsproxy;
+	int ret;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	ctx->root_pid = pid;
+
+	/* root task */
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+	if (!task)
+		return -ESRCH;
+	else
+		ctx->root_task = task;
+
+	/* root nsproxy */
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+	if (!nsproxy)
+		return -ESRCH;
+	else
+		ctx->root_nsproxy = nsproxy;
+
+	/* root freezer */
+	ctx->root_freezer = task;
+	geT_task_struct(task);
+
+	ret = may_checkpoint_task(ctx, task);
+	if (ret) {
+		ckpt_write_err(ctx, NULL);
+		put_task_struct(task);
+		put_task_struct(task);
+		put_nsproxy(nsproxy);
+		return ret;
+	}
+
+	return 0;
+}
+
 long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	long ret;
 
+	ret = init_checkpoint_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	if (ctx->root_freezer) {
+		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
+		if (ret < 0)
+			return ret;
+	}
+
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, current);
+	ret = checkpoint_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
@@ -273,5 +368,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
  out:
+	if (ctx->root_freezer)
+		cgroup_freezer_end_checkpoint(ctx->root_freezer);
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 17135fe..62e19b4 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -322,10 +322,67 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static long restore_retval(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	long ret;
+
+	/*
+	 * For the restart, we entered the kernel via sys_restart(),
+	 * so our return path is via the syscall exit. In particular,
+	 * the code in entry.S will put the value that we will return
+	 * into a register (e.g. regs->eax in x86), thus passing it to
+	 * the caller task.
+	 *
+	 * What we do now depends on what happened to the checkpointed
+	 * task right before the checkpoint - there are three cases:
+	 *
+	 * 1) It was carrying out a syscall when became frozen, or
+	 * 2) It was running in userspace, or
+	 * 3) It was doing a self-checkpoint
+	 *
+	 * In case #1, if the syscall succeeded, perhaps partially,
+	 * then the retval is non-negative. If it failed, the error
+	 * may be one of -ERESTART..., which is interpreted in the
+	 * signal handling code. If that is the case, we force the
+	 * signal handler to kick in by faking a signal to ourselves
+	 * (a la freeze/thaw) when ret < 0.
+	 *
+	 * In case #2, our return value will overwrite the original
+	 * value in the affected register. Workaround by simply using
+	 * that saved value of that register as our retval.
+	 *
+	 * In case #3, then the state was recorded while the task was
+	 * in checkpoint(2) syscall. The syscall is execpted to return
+	 * 0 when returning from a restart. Fortunately, this already
+	 * has been arranged for at checkpoint time (the register that
+	 * holds the retval, e.g. regs->eax in x86, was set to
+	 * zero).
+	 */
+
+	/* needed for all 3 cases: get old value/error/retval */
+	ret = syscall_get_return_value(current, regs);
+
+	/* if from a syscall and returning error, kick in signal handlig */
+	if (syscall_get_nr(current, regs) >= 0 && ret < 0)
+		set_tsk_thread_flag(current, TIF_SIGPENDING);
+
+	return ret;
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	return 0;
+}
+
 long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	long ret;
 
+	ret = init_restart_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
 	ret = restore_read_header(ctx);
 	if (ret < 0)
 		return ret;
@@ -333,7 +390,9 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 	ret = restore_read_tail(ctx);
+	if (ret < 0)
+		return ret;
 
 	/* on success, adjust the return value if needed [TODO] */
-	return ret;
+	return restore_retval(ctx);
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7f6f71e..dda2c21 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -12,7 +12,9 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/kernel.h>
+#include <linux/cgroup.h>
 #include <linux/syscalls.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -168,6 +170,14 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	if (ctx->file)
 		fput(ctx->file);
+
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+	if (ctx->root_freezer)
+		put_task_struct(ctx->root_freezer);
+
 	kfree(ctx);
 }
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 203ecac..21b5965 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -12,12 +12,17 @@
 
 #ifdef __KERNEL__
 
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/fs.h>
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
-	pid_t root_pid;		/* container identifier */
+	pid_t root_pid;				/* [container] root pid */
+	struct task_struct *root_task;		/* [container] root task */
+	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
+	struct task_struct *root_freezer;	/* [container] root task */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
