Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15FE16B00B6
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:22 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 28/60] c/r: support for zombie processes
Date: Wed, 22 Jul 2009 05:59:50 -0400
Message-Id: <1248256822-23416-29-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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

Changelog[v17]:
  - Validate t->exit_signal for both threads and leader
  - Skip zombies in most of may_checkpoint_task()
  - Save/restore t->pdeath_signal
  - Validate ->exit_signal and ->pdeath_signal

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c        |   12 +++++--
 checkpoint/process.c           |   67 +++++++++++++++++++++++++++++++++++-----
 checkpoint/restart.c           |   40 +++++++++++++++++++++---
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    1 +
 5 files changed, 104 insertions(+), 17 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 57f59de..fb14585 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -280,8 +280,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
-	if (t->state == TASK_DEAD) {
-		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+	if (t->exit_state == EXIT_DEAD) {
+		pr_warning("c/r: task %d is EXIT_DEAD\n", task_pid_vnr(t));
 		return -EAGAIN;
 	}
 
@@ -291,6 +291,10 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EPERM;
 	}
 
+	/* zombies are cool (and also don't have nsproxy, below...) */
+	if (t->exit_state)
+		return 0;
+
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
 		__ckpt_write_err(ctx, "task %d (%s) not frozen (wrong cgroup)",
@@ -309,8 +313,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * FIX: for now, disallow siblings of container init created
 	 * via CLONE_PARENT (unclear if they will remain possible)
 	 */
-	if (ctx->root_init && t != root && t->tgid != root->tgid &&
-	    t->real_parent == root->real_parent) {
+	if (ctx->root_init && t != root &&
+	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
 		__ckpt_write_err(ctx, "task %d (%s) is sibling of root",
 				 task_pid_vnr(t), t->comm);
 		return -EINVAL;
diff --git a/checkpoint/process.c b/checkpoint/process.c
index a0bf344..a67c389 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -35,12 +35,18 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->state = t->state;
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
-	h->exit_signal = t->exit_signal;
 
-	h->set_child_tid = t->set_child_tid;
-	h->clear_child_tid = t->clear_child_tid;
+	if (t->exit_state) {
+		/* zombie - skip remaining state */
+		BUG_ON(t->exit_state != EXIT_ZOMBIE);
+	} else {
+		/* FIXME: save remaining relevant task_struct fields */
+		h->exit_signal = t->exit_signal;
+		h->pdeath_signal = t->pdeath_signal;
 
-	/* FIXME: save remaining relevant task_struct fields */
+		h->set_child_tid = t->set_child_tid;
+		h->clear_child_tid = t->clear_child_tid;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -169,6 +175,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
@@ -187,6 +198,19 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
@@ -198,15 +222,37 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
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
+		t->set_child_tid = h->set_child_tid;
+		t->clear_child_tid = h->clear_child_tid;
+	}
+
 	memset(t->comm, 0, TASK_COMM_LEN);
 	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
 	if (ret < 0)
 		goto out;
 
-	t->set_child_tid = h->set_child_tid;
-	t->clear_child_tid = h->clear_child_tid;
-
-	/* FIXME: restore remaining relevant task_struct fields */
+	/* return 1 for zombie, 0 otherwise */
+	ret = (h->state == TASK_DEAD ? 1 : 0);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -326,6 +372,11 @@ int restore_task(struct ckpt_ctx *ctx)
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
index 65422e2..1b1f639 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -375,20 +375,17 @@ static inline void ckpt_notify_error(struct ckpt_ctx *ctx)
 	complete(&ctx->complete);
 }
 
-static int ckpt_activate_next(struct ckpt_ctx *ctx)
+int ckpt_activate_next(struct ckpt_ctx *ctx)
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
@@ -413,6 +410,8 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 	ret = wait_event_interruptible(ctx->waitq,
 				       is_task_active(ctx, pid) ||
 				       ckpt_test_ctx_error(ctx));
+	ckpt_debug("active %d < %d (ret %d)\n",
+		   ctx->active_pid, ctx->nr_pids, ret);
 	if (!ret && ckpt_test_ctx_error(ctx)) {
 		force_sig(SIGKILL, current);
 		ret = -EBUSY;
@@ -468,6 +467,8 @@ static int do_restore_task(void)
 		return -EAGAIN;
 	}
 
+	current->flags |= PF_RESTARTING;
+
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
 	if (ret < 0)
@@ -477,6 +478,13 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	/*
+	 * zombie: we're done here; Save @ctx on task_struct, to be
+	 * used to ckpt_activate_next(), and released, from do_exit().
+	 */
+	if (ret)
+		do_exit(current->exit_code);
+
 	ret = ckpt_activate_next(ctx);
 	if (ret < 0)
 		goto out;
@@ -493,6 +501,7 @@ static int do_restore_task(void)
 		wake_up_all(&ctx->waitq);
 	}
 
+	current->flags &= ~PF_RESTARTING;
 	ckpt_ctx_put(ctx);
 	return ret;
 }
@@ -593,6 +602,7 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 
 	ret = wait_for_completion_interruptible(&ctx->complete);
 
+	ckpt_debug("final sync kflags %#lx\n", ctx->kflags);
 	if (ckpt_test_ctx_error(ctx))
 		ret = -EBUSY;
 	return ret;
@@ -820,3 +830,23 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 
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
+	ctx = tsk->checkpoint_ctx;
+	tsk->checkpoint_ctx = NULL;
+
+	/* restarting zombies will acrivate next task in restart */
+	if (tsk->flags & PF_RESTARTING) {
+		if (ckpt_activate_next(ctx) < 0)
+			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+	}
+
+	ckpt_ctx_put(ctx);
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 44b692d..b6af5b9 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -85,6 +85,7 @@ extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
+extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index c9a80dc..3f2db22 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -130,6 +130,7 @@ struct ckpt_hdr_task {
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
