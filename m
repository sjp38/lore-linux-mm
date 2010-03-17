Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6096B0216
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:13 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 32/96] c/r: support for zombie processes
Date: Wed, 17 Mar 2010 12:08:20 -0400
Message-Id: <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

During checkpoint, a zombie processes need only save p->comm,
p->state, p->exit_state, and p->exit_code.

During restart, zombie processes are created like all other
processes. They validate the saved exit_code restore p->comm
and p->exit_code. Then they call do_exit() instead of waking
up the next task in line.

But before, they place the @ctx in p->checkpoint_ctx, so that
only at exit time they will wake up the next task in line,
and drop the reference to the @ctx.

This provides the guarantee that when the coordinator's wait
completes, all normal tasks completed their restart, and all
zombie tasks are already zombified (as opposed to perhap only
becoming a zombie).

Changelog[v19-rc1]:
  - Simplify logic of tracking restarting tasks
Changelog[v18]:
  - Fix leak of ckpt_ctx when restoring zombie tasks
  - Add a few more ckpt_write_err()s
Changelog[v17]:
  - Validate t->exit_signal for both threads and leader
  - Skip zombies in most of may_checkpoint_task()
  - Save/restore t->pdeath_signal
  - Validate ->exit_signal and ->pdeath_signal

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c        |   10 ++++--
 checkpoint/process.c           |   69 +++++++++++++++++++++++++++++++++++-----
 checkpoint/restart.c           |   22 +++++++++++--
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    1 +
 5 files changed, 89 insertions(+), 14 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 1e38ae3..ea1494d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -218,7 +218,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
-	if (t->state == TASK_DEAD) {
+	if (t->exit_state == EXIT_DEAD) {
 		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
 		return -EBUSY;
 	}
@@ -228,6 +228,10 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EPERM;
 	}
 
+	/* zombies are cool (and also don't have nsproxy, below...) */
+	if (t->exit_state)
+		return 0;
+
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
 		_ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
@@ -244,8 +248,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * FIX: for now, disallow siblings of container init created
 	 * via CLONE_PARENT (unclear if they will remain possible)
 	 */
-	if (ctx->root_init && t != root && t->tgid != root->tgid &&
-	    t->real_parent == root->real_parent) {
+	if (ctx->root_init && t != root &&
+	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
 		_ckpt_err(ctx, -EINVAL, "%(T)Task is sibling of root\n");
 		return -EINVAL;
 	}
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 9f2059c..c47dea1 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -35,12 +35,18 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->state = t->state;
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
-	h->exit_signal = t->exit_signal;
 
-	h->set_child_tid = (unsigned long) t->set_child_tid;
-	h->clear_child_tid = (unsigned long) t->clear_child_tid;
+	if (t->exit_state) {
+		/* zombie - skip remaining state */
+		BUG_ON(t->exit_state != EXIT_ZOMBIE);
+	} else {
+		/* FIXME: save remaining relevant task_struct fields */
+		h->exit_signal = t->exit_signal;
+		h->pdeath_signal = t->pdeath_signal;
 
-	/* FIXME: save remaining relevant task_struct fields */
+		h->set_child_tid = (unsigned long) t->set_child_tid;
+		h->clear_child_tid = (unsigned long) t->clear_child_tid;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -171,6 +177,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+
+	/* zombie - we're done here */
+	if (t->exit_state)
+		return 0;
+
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
@@ -190,6 +201,19 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
  * Restart
  */
 
+static inline int valid_exit_code(int exit_code)
+{
+	if (exit_code >= 0x10000)
+		return 0;
+	if (exit_code & 0xff) {
+		if (exit_code & ~0xff)
+			return 0;
+		if (!valid_signal(exit_code & 0xff))
+			return 0;
+	}
+	return 1;
+}
+
 /* read the task_struct into the current task */
 static int restore_task_struct(struct ckpt_ctx *ctx)
 {
@@ -201,15 +225,39 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
+	ret = -EINVAL;
+	if (h->state == TASK_DEAD) {
+		if (h->exit_state != EXIT_ZOMBIE)
+			goto out;
+		if (!valid_exit_code(h->exit_code))
+			goto out;
+		t->exit_code = h->exit_code;
+	} else {
+		if (h->exit_code)
+			goto out;
+		if ((thread_group_leader(t) && !valid_signal(h->exit_signal)) ||
+		    (!thread_group_leader(t) && h->exit_signal != -1))
+			goto out;
+		if (!valid_signal(h->pdeath_signal))
+			goto out;
+
+		/* FIXME: restore remaining relevant task_struct fields */
+		t->exit_signal = h->exit_signal;
+		t->pdeath_signal = h->pdeath_signal;
+
+		t->set_child_tid =
+			(int __user *) (unsigned long) h->set_child_tid;
+		t->clear_child_tid =
+			(int __user *) (unsigned long) h->clear_child_tid;
+	}
+
 	memset(t->comm, 0, TASK_COMM_LEN);
 	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
 	if (ret < 0)
 		goto out;
 
-	t->set_child_tid = (int __user *) (unsigned long) h->set_child_tid;
-	t->clear_child_tid = (int __user *) (unsigned long) h->clear_child_tid;
-
-	/* FIXME: restore remaining relevant task_struct fields */
+	/* return 1 for zombie, 0 otherwise */
+	ret = (h->state == TASK_DEAD ? 1 : 0);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -329,6 +377,11 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+
+	/* zombie - we're done here */
+	if (ret)
+		goto out;
+
 	ret = restore_thread(ctx);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 59c4bd8..e2ed358 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -852,7 +852,7 @@ static int wait_sync_threads(void)
 static int do_restore_task(void)
 {
 	struct ckpt_ctx *ctx;
-	int ret;
+	int zombie, ret;
 
 	ctx = wait_checkpoint_ctx();
 	if (IS_ERR(ctx))
@@ -862,6 +862,8 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	current->flags |= PF_RESTARTING;
+
 	ret = wait_sync_threads();
 	if (ret < 0)
 		goto out;
@@ -873,9 +875,22 @@ static int do_restore_task(void)
 
 	restore_debug_running(ctx);
 
-	ret = restore_task(ctx);
-	if (ret < 0)
+	zombie = restore_task(ctx);
+	if (zombie < 0) {
+		ret = zombie;
 		goto out;
+	}
+
+	/*
+	 * zombie: we're done here; do_exit() will notice the @ctx on
+	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
+	 * will call restore_activate_next() and release the @ctx.
+	 */
+	if (zombie) {
+		restore_debug_exit(ctx);
+		ckpt_ctx_put(ctx);
+		do_exit(current->exit_code);
+	}
 
 	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
@@ -884,6 +899,7 @@ static int do_restore_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "task restart failed\n");
 
+	current->flags &= ~PF_RESTARTING;
 	clear_task_ctx(current);
 	ckpt_ctx_put(ctx);
 	return ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d1eb722..61581f6 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -113,6 +113,7 @@ extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
+extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 083f5d3..f85b673 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -160,6 +160,7 @@ struct ckpt_hdr_task {
 	__u32 exit_state;
 	__u32 exit_code;
 	__u32 exit_signal;
+	__u32 pdeath_signal;
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
