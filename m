Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9E76B0085
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:26 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 28/80] c/r: support for zombie processes
Date: Wed, 23 Sep 2009 19:51:08 -0400
Message-Id: <1253749920-18673-29-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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

Changelog[v18]:
  - Fix leak of ckpt_ctx when restoring zombie tasks
  - Add a few more ckpt_write_err()s
Changelog[v17]:
  - Validate t->exit_signal for both threads and leader
  - Skip zombies in most of may_checkpoint_task()
  - Save/restore t->pdeath_signal
  - Validate ->exit_signal and ->pdeath_signal

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c        |   10 ++++--
 checkpoint/process.c           |   69 +++++++++++++++++++++++++++++++++++-----
 checkpoint/restart.c           |   41 +++++++++++++++++++++--
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    1 +
 5 files changed, 107 insertions(+), 15 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index fc02436..93d7860 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -377,7 +377,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
-	if (t->state == TASK_DEAD) {
+	if (t->exit_state == EXIT_DEAD) {
 		__ckpt_write_err(ctx, "TE", "task state EXIT_DEAD\n", -EBUSY);
 		return -EBUSY;
 	}
@@ -387,6 +387,10 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EPERM;
 	}
 
+	/* zombies are cool (and also don't have nsproxy, below...) */
+	if (t->exit_state)
+		return 0;
+
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
 		__ckpt_write_err(ctx, "TE", "unfrozen or wrong cgroup", -EBUSY);
@@ -403,8 +407,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * FIX: for now, disallow siblings of container init created
 	 * via CLONE_PARENT (unclear if they will remain possible)
 	 */
-	if (ctx->root_init && t != root && t->tgid != root->tgid &&
-	    t->real_parent == root->real_parent) {
+	if (ctx->root_init && t != root &&
+	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
 		__ckpt_write_err(ctx, "TE", "task is sibling of root", -EINVAL);
 		return -EINVAL;
 	}
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 330c8d4..62ae72d 100644
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
@@ -172,6 +178,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
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
@@ -191,6 +202,19 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
@@ -202,15 +226,39 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
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
@@ -330,6 +378,11 @@ int restore_task(struct ckpt_ctx *ctx)
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
index 4da09b7..d43eec7 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -473,17 +473,14 @@ do { \
 static int restore_activate_next(struct ckpt_ctx *ctx)
 {
 	struct task_struct *task;
-	int active;
 	pid_t pid;
 
-	active = ++ctx->active_pid;
-	if (active >= ctx->nr_pids) {
+	if (++ctx->active_pid >= ctx->nr_pids) {
 		complete(&ctx->complete);
 		return 0;
 	}
 
 	pid = get_active_pid(ctx);
-	ckpt_debug("active pid %d (%d < %d)\n", pid, active, ctx->nr_pids);
 
 	rcu_read_lock();
 	task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
@@ -511,6 +508,8 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 	ret = wait_event_interruptible(ctx->waitq,
 				       is_task_active(ctx, pid) ||
 				       ckpt_test_ctx_error(ctx));
+	ckpt_debug("active %d < %d (ret %d)\n",
+		   ctx->active_pid, ctx->nr_pids, ret);
 	if (!ret && ckpt_test_ctx_error(ctx)) {
 		force_sig(SIGKILL, current);
 		ret = -EBUSY;
@@ -567,6 +566,8 @@ static int do_restore_task(void)
 		return -EAGAIN;
 	}
 
+	current->flags |= PF_RESTARTING;
+
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
 	if (ret < 0)
@@ -576,6 +577,16 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	/*
+	 * zombie: we're done here; do_exit() will notice the @ctx on
+	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
+	 * will call restore_activate_next() and release the @ctx.
+	 */
+	if (ret) {
+		ckpt_ctx_put(ctx);
+		do_exit(current->exit_code);
+	}
+
 	ret = restore_activate_next(ctx);
 	if (ret < 0)
 		goto out;
@@ -592,6 +603,7 @@ static int do_restore_task(void)
 		wake_up_all(&ctx->waitq);
 	}
 
+	current->flags &= ~PF_RESTARTING;
 	ckpt_ctx_put(ctx);
 	return ret;
 }
@@ -929,3 +941,24 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 
 	return ret;
 }
+
+/**
+ * exit_checkpoint - callback from do_exit to cleanup checkpoint state
+ * @tsk: terminating task
+ */
+void exit_checkpoint(struct task_struct *tsk)
+{
+	struct ckpt_ctx *ctx;
+
+	/* no one else will touch this, because @tsk is dead already */
+	ctx = xchg(&tsk->checkpoint_ctx, NULL);
+
+	/* restarting zombies will activate next task in restart */
+	if (tsk->flags & PF_RESTARTING) {
+		BUG_ON(ctx->active_pid == -1);
+		if (restore_activate_next(ctx) < 0)
+			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+	}
+
+	ckpt_ctx_put(ctx);
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 4227b31..5c02d9b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -96,6 +96,7 @@ extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
+extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 26e10fb..8ae3bbe 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -132,6 +132,7 @@ struct ckpt_hdr_task {
 	__u32 exit_state;
 	__u32 exit_code;
 	__u32 exit_signal;
+	__u32 pdeath_signal;
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
