Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 317FA6B00B8
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:49 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 63/80] c/r: [signal 1/4] blocked and template for shared signals
Date: Wed, 23 Sep 2009 19:51:43 -0400
Message-Id: <1253749920-18673-64-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch adds checkpoint/restart of blocked signals mask
(t->blocked) and a template for shared signals (t->signal).

Because t->signal sharing is tied to threads, we ensure proper sharing
of t->signal (struct signal_struct) for threads only.

Access to t->signal is protected by locking t->sighand->lock.
Therefore, the usual checkpoint_obj() invoking the callback
checkpoint_signal(ctx, signal) is insufficient because the task
pointer is unavailable.

Instead, handling of t->signal sharing is explicit using helpers
like ckpt_obj_lookup_add(), ckpt_obj_fetch() and ckpt_obj_insert().
The actual state is saved (if needed) _after_ the task_objs data.

To prevent tasks from handling restored signals during restart,
set their mask to block all signals and only restore the original
mask at the very end (before the last sync point).

Introduce per-task pointer 'ckpt_data' to temporary store data
for restore actions that are deferred to the end (like restoring
the signal block mask).

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Louis Rilling <Louis.Rilling@kerlabs.com>
---
 checkpoint/objhash.c           |    7 +++
 checkpoint/process.c           |   64 ++++++++++++++++++++++++-
 checkpoint/signal.c            |  104 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    6 ++
 include/linux/checkpoint_hdr.h |   14 +++++-
 5 files changed, 193 insertions(+), 2 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index b4034dc..bf2f761 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -289,6 +289,13 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_sighand,
 		.restore = restore_sighand,
 	},
+	/* signal object */
+	{
+		.obj_name = "SIGNAL",
+		.obj_type = CKPT_OBJ_SIGNAL,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+	},
 	/* ns object */
 	{
 		.obj_name = "NSPROXY",
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 56f33dd..e596e2a 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -182,7 +182,8 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int files_objref;
 	int mm_objref;
 	int sighand_objref;
-	int ret;
+	int signal_objref;
+	int first, ret;
 
 	/*
 	 * Shared objects may have dependencies among them: task->mm
@@ -222,14 +223,36 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return sighand_objref;
 	}
 
+	/*
+	 * Handle t->signal differently because the checkpoint method
+	 * for t->signal needs access to owning task_struct to access
+	 * t->sighand (to lock/unlock). First explicitly determine if
+	 * need to save, and only below invoke checkpoint_obj_signal()
+	 * if needed.
+	 */
+	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
+					    CKPT_OBJ_SIGNAL, &first);
+	ckpt_debug("signal: objref %d\n", signal_objref);
+	if (signal_objref < 0)
+		return signal_objref;
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
 	h->sighand_objref = sighand_objref;
+	h->signal_objref = signal_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* actually save t->signal, if need to */
+	if (first)
+		ret = checkpoint_obj_signal(ctx, t);
+	if (ret < 0)
+		ckpt_write_err(ctx, "TE", "signal_struct", ret);
 
 	return ret;
 }
@@ -375,6 +398,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		goto out;
 	ret = checkpoint_cpu(ctx, t);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_signal(ctx, t);
+	ckpt_debug("task-signal %d\n", ret);
  out:
 	ctx->tsk = NULL;
 	return ret;
@@ -551,6 +578,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
 	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_signal(ctx, h->signal_objref);
+	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -688,11 +720,37 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* pre_restore_task - prepare the task for restore */
+static int pre_restore_task(struct ckpt_ctx *ctx)
+{
+	sigset_t sigset;
+
+	/*
+	 * Block task's signals to avoid interruptions due to signals,
+	 * say, from restored timers, file descriptors etc. Signals
+	 * will be unblocked when restore completes.
+	 *
+	 * NOTE: tasks with file descriptors set to send a SIGKILL as
+	 * i/o notification may fail the restart if a signal occurs
+	 * before that task completed its restore. FIX ?
+	 */
+	sigfillset(&sigset);
+	sigdelset(&sigset, SIGKILL);
+	sigdelset(&sigset, SIGSTOP);
+	sigprocmask(SIG_SETMASK, &sigset, NULL);
+
+	return 0;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
 	int ret;
 
+	ret = pre_restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = restore_task_struct(ctx);
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
@@ -720,6 +778,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_creds(ctx);
 	ckpt_debug("creds: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_task_signal(ctx);
  out:
 	return ret;
 }
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 1aadadd..3fac75c 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -161,3 +161,107 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 
 	return 0;
 }
+
+/***********************************************************************
+ * signal checkpoint/restart
+ */
+
+static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (!h)
+		return -ENOMEM;
+
+	/* fill in later */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	BUG_ON(t->flags & PF_EXITING);
+	return checkpoint_signal(ctx, t);
+}
+
+static int restore_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* fill in later */
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
+{
+	struct signal_struct *signal;
+	int ret = 0;
+
+	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	if (!IS_ERR(signal)) {
+		/*
+		 * signal_struct is already shared properly as it is
+		 * tied to thread groups. Since thread relationships
+		 * are already restore now, t->signal must match.
+		 */
+		if (signal != current->signal)
+			ret = -EINVAL;
+	} else if (PTR_ERR(signal) == -EINVAL) {
+		/* first timer: add to hash and restore our t->signal */
+		ret = ckpt_obj_insert(ctx, current->signal,
+				      signal_objref, CKPT_OBJ_SIGNAL);
+		if (ret >= 0)
+			ret = restore_signal(ctx);
+	} else {
+		ret = PTR_ERR(signal);
+	}
+
+	return ret;
+}
+
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	fill_sigset(&h->blocked, &t->blocked);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_task_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal_task *h;
+	sigset_t blocked;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	load_sigset(&blocked, &h->blocked);
+	/* silently remove SIGKILL, SIGSTOP */
+	sigdelset(&blocked, SIGKILL);
+	sigdelset(&blocked, SIGSTOP);
+
+	sigprocmask(SIG_SETMASK, &blocked, NULL);
+	recalc_sigpending();
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c0e549e..ec98a43 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -253,6 +253,12 @@ extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_sighand(struct ckpt_ctx *ctx);
 
+extern int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
+
+extern int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task_signal(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3d3a105..ee949b5 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -88,6 +88,8 @@ enum {
 	CKPT_HDR_IPC_SEM,
 
 	CKPT_HDR_SIGHAND = 601,
+	CKPT_HDR_SIGNAL,
+	CKPT_HDR_SIGNAL_TASK,
 
 	CKPT_HDR_TAIL = 9001,
 
@@ -116,6 +118,7 @@ enum obj_type {
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
 	CKPT_OBJ_SIGHAND,
+	CKPT_OBJ_SIGNAL,
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
@@ -210,7 +213,6 @@ struct ckpt_hdr_task {
 	__u32 compat_robust_futex_list; /* a compat __user ptr */
 	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
-
 } __attribute__((aligned(8)));
 
 /* Posix capabilities */
@@ -305,6 +307,7 @@ struct ckpt_hdr_task_objs {
 	__s32 files_objref;
 	__s32 mm_objref;
 	__s32 sighand_objref;
+	__s32 signal_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -437,6 +440,15 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_signal {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_signal_task {
+	struct ckpt_hdr h;
+	struct ckpt_sigset blocked;
+} __attribute__((aligned(8)));
+
 /* ipc commons */
 struct ckpt_hdr_ipcns {
 	struct ckpt_hdr h;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
