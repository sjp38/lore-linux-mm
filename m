Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2316B00B5
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:48 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 73/80] c/r: correctly restore pgid
Date: Wed, 23 Sep 2009 19:51:53 -0400
Message-Id: <1253749920-18673-74-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

The main challenge with restoring the pgid of tasks is that the
original "owner" (the process with that pid) might have exited
already. I call these "ghost" pgids. 'mktree' does create these
processes, but they then exit without participating in the restart.

To solve this, this patch introduces a RESTART_GHOST flag, used for
"ghost" owners that are created only to pass their pgid to other
tasks. ('mktree' now makes them call restart(2) instead of exiting).

When a "ghost" task calls restart(2), it will be placed on a wait
queue until the restart completes and then exit. This guarantees that
the pgid that it owns remains available for all (regular) restarting
tasks for when they need it.

Regular tasks perform the restart as before, except that they also
now restore their old pgrp, which is guaranteed to exist.

Changelog [v3]:
  - Fix leak of ckpt_ctx when restoring "ghost" tasks
Changelog [v2]:
  - Call change_pid() only if new pgrp differs from current one
Changelog [v1]:
  - Verify that pgid owner is a thread-group-leader.
  - Handle the case of pgid/sid == 0 using root's parent pid-ns

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 checkpoint/process.c             |   97 +++++++++++++++++++++++++++
 checkpoint/restart.c             |  137 +++++++++++++++++++++++++++-----------
 checkpoint/sys.c                 |    3 +-
 include/linux/checkpoint.h       |   11 +++-
 include/linux/checkpoint_hdr.h   |    3 +
 include/linux/checkpoint_types.h |    6 +-
 6 files changed, 214 insertions(+), 43 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index e596e2a..3c02f8e 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -24,6 +24,57 @@
 #include <linux/syscalls.h>
 
 
+pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
+{
+	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
+}
+
+/* must be called with tasklist_lock or rcu_read_lock() held */
+struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
+{
+	struct task_struct *p;
+	struct pid *pgrp;
+
+	if (pgid == 0) {
+		/*
+		 * At checkpoint the pgid owner lived in an ancestor
+		 * pid-ns. The best we can do (sanely and safely) is
+		 * to examine the parent of this restart's root: if in
+		 * a distinct pid-ns, use its pgrp; otherwise fail.
+		 */
+		p = ctx->root_task->real_parent;
+		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
+			return NULL;
+		pgrp = task_pgrp(p);
+	} else {
+		/*
+		 * Find the owner process of this pgid (it must exist
+		 * if pgrp exists). It must be a thread group leader.
+		 */
+		pgrp = find_vpid(pgid);
+		p = pid_task(pgrp, PIDTYPE_PID);
+		if (!p || !thread_group_leader(p))
+			return NULL;
+		/*
+		 * The pgrp must "belong" to our restart tree (compare
+		 * p->checkpoint_ctx to ours). This prevents malicious
+		 * input from (guessing and) using unrelated pgrps. If
+		 * the owner is dead, then it doesn't have a context,
+		 * so instead compare against its (real) parent's.
+		 */
+		if (p->exit_state == EXIT_ZOMBIE)
+			p = p->real_parent;
+		if (p->checkpoint_ctx != ctx)
+			return NULL;
+	}
+
+	if (task_session(current) != task_session(p))
+		return NULL;
+
+	return pgrp;
+}
+
+
 #ifdef CONFIG_FUTEX
 static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
 					struct task_struct *t)
@@ -720,6 +771,49 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_pgid(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task = current;
+	struct pid *pgrp;
+	pid_t pgid;
+	int ret;
+
+	/*
+	 * We enforce the following restrictions on restoring pgrp:
+	 *  1) Only thread group leaders restore pgrp
+	 *  2) Session leader cannot change own pgrp
+	 *  3) Owner of pgrp must belong to same restart tree
+	 *  4) Must have same session as other tasks in same pgrp
+	 *  5) Change must pass setpgid security callback
+	 *
+	 * TODO - check if we need additional restrictions ?
+	 */
+
+	if (!thread_group_leader(task))  /* (1) */
+		return 0;
+
+	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
+
+	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
+		return 0;
+
+	if (task->signal->leader)  /* (2) */
+		return -EINVAL;
+
+	ret = -EINVAL;
+
+	write_lock_irq(&tasklist_lock);
+	pgrp = _ckpt_find_pgrp(ctx, pgid);  /* (3) and (4) */
+	if (pgrp && task_pgrp(task) != pgrp) {
+		ret = security_task_setpgid(task, pgid);  /* (5) */
+		if (!ret)
+			change_pid(task, PIDTYPE_PGID, pgrp);
+	}
+	write_unlock_irq(&tasklist_lock);
+
+	return ret;
+}
+
 /* pre_restore_task - prepare the task for restore */
 static int pre_restore_task(struct ckpt_ctx *ctx)
 {
@@ -760,6 +854,9 @@ int restore_task(struct ckpt_ctx *ctx)
 	if (ret)
 		goto out;
 
+	ret = restore_task_pgid(ctx);
+	if (ret < 0)
+		goto out;
 	ret = restore_task_objs(ctx);
 	ckpt_debug("objs %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 1016278..543b380 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -511,6 +511,11 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static inline int all_tasks_activated(struct ckpt_ctx *ctx)
+{
+	return (ctx->active_pid == ctx->nr_pids);
+}
+
 static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
 {
 	int active = ctx->active_pid;
@@ -535,30 +540,42 @@ do { \
 	_restore_notify_error(ctx, errno); \
 } while(0)
 
+static void restore_task_done(struct ckpt_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->nr_total))
+		complete(&ctx->complete);
+	BUG_ON(atomic_read(&ctx->nr_total) < 0);
+}
+
 static int restore_activate_next(struct ckpt_ctx *ctx)
 {
 	struct task_struct *task;
 	pid_t pid;
 
-	if (++ctx->active_pid >= ctx->nr_pids) {
-		complete(&ctx->complete);
-		return 0;
-	}
+	ctx->active_pid++;
 
-	pid = get_active_pid(ctx);
+	BUG_ON(ctx->active_pid > ctx->nr_pids);
 
-	rcu_read_lock();
-	task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
-	/* target task must have same restart context */
-	if (task && task->checkpoint_ctx == ctx)
-		wake_up_process(task);
-	else
-		task = NULL;
-	rcu_read_unlock();
+	if (!all_tasks_activated(ctx)) {
+		/* wake up next task in line to restore its state */
+		pid = get_active_pid(ctx);
 
-	if (!task) {
-		restore_notify_error(ctx, -ESRCH);
-		return -ESRCH;
+		rcu_read_lock();
+		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
+		/* target task must have same restart context */
+		if (task && task->checkpoint_ctx == ctx)
+			wake_up_process(task);
+		else
+			task = NULL;
+		rcu_read_unlock();
+
+		if (!task) {
+			restore_notify_error(ctx, -ESRCH);
+			return -ESRCH;
+		}
+	} else {
+		/* wake up ghosts tasks so that they can terminate */
+		wake_up_all(&ctx->ghostq);
 	}
 
 	return 0;
@@ -593,7 +610,7 @@ static int wait_task_sync(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-static int do_restore_task(void)
+static struct ckpt_ctx *wait_checkpoint_ctx(void)
 {
 	DECLARE_WAIT_QUEUE_HEAD(waitq);
 	struct ckpt_ctx *ctx, *old_ctx;
@@ -605,11 +622,11 @@ static int do_restore_task(void)
 	 */
 	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
 	if (ret < 0)
-		return ret;
+		return ERR_PTR(ret);
 
 	ctx = xchg(&current->checkpoint_ctx, NULL);
 	if (!ctx)
-		return -EAGAIN;
+		return ERR_PTR(-EAGAIN);
 	ckpt_ctx_get(ctx);
 
 	/*
@@ -628,9 +645,43 @@ static int do_restore_task(void)
 		/* alert our coordinator that we bail */
 		restore_notify_error(ctx, -EAGAIN);
 		ckpt_ctx_put(ctx);
-		return -EAGAIN;
+
+		ctx = ERR_PTR(-EAGAIN);
 	}
 
+	return ctx;
+}
+
+static int do_ghost_task(void)
+{
+	struct ckpt_ctx *ctx;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	current->flags |= PF_RESTARTING;
+
+	wait_event_interruptible(ctx->ghostq,
+				 all_tasks_activated(ctx) ||
+				 ckpt_test_ctx_error(ctx));
+
+	current->exit_signal = -1;
+	ckpt_ctx_put(ctx);
+	do_exit(0);
+
+	/* NOT REACHED */
+}
+
+static int do_restore_task(void)
+{
+	struct ckpt_ctx *ctx, *old_ctx;
+	int zombie, ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
 	current->flags |= PF_RESTARTING;
 
 	/* wait for our turn, do the restore, and tell next task in line */
@@ -638,24 +689,28 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
-	ret = restore_task(ctx);
+	zombie = restore_task(ctx);
+	if (zombie < 0) {
+		ret = zombie;
+		goto out;
+	}
+
+	ret = restore_activate_next(ctx);
 	if (ret < 0)
 		goto out;
 
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
-	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
-	 * will call restore_activate_next() and release the @ctx.
+	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
+	 * call restore_task_done() and release the @ctx. This ensures
+	 * that we only report done after we really become zombie.
 	 */
-	if (ret) {
+	if (zombie) {
 		ckpt_ctx_put(ctx);
 		do_exit(current->exit_code);
 	}
 
-	ret = restore_activate_next(ctx);
-	if (ret < 0)
-		goto out;
-
+	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
  out:
 	old_ctx = xchg(&current->checkpoint_ctx, NULL);
@@ -666,6 +721,7 @@ static int do_restore_task(void)
 	if (ret < 0 && !ckpt_test_ctx_error(ctx)) {
 		restore_notify_error(ctx, ret);
 		wake_up_all(&ctx->waitq);
+		wake_up_all(&ctx->ghostq);
 	}
 
 	current->flags &= ~PF_RESTARTING;
@@ -687,11 +743,11 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 	struct task_struct *parent = NULL;
 	struct task_struct *task = root;
 	struct ckpt_ctx *old_ctx;
-	int nr_pids = ctx->nr_pids;
+	int nr_pids = 0;
 	int ret = 0;
 
 	read_lock(&tasklist_lock);
-	while (nr_pids) {
+	while (1) {
 		ckpt_debug("consider task %d\n", task_pid_vnr(task));
 		if (task_ptrace(task) & PT_PTRACED) {
 			ret = -EBUSY;
@@ -718,7 +774,7 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 			}
 			ckpt_debug("prepare task %d\n", task_pid_vnr(task));
 			wake_up_process(task);
-			nr_pids--;
+			nr_pids++;
 		}
 
 		/* if has children - proceed with child */
@@ -748,12 +804,16 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 		}
 	}
 	read_unlock(&tasklist_lock);
-	ckpt_debug("left %d ret %d root/task %d\n", nr_pids, ret, task == root);
+	ckpt_debug("nr %d/%d  ret %d\n", ctx->nr_pids, nr_pids, ret);
 
-	/* fail unless number of processes matches */
-	if (!ret && (nr_pids || task != root))
+	/*
+	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
+	 * tasks used as place-holders for PGIDs, but not fall short.
+	 */
+	if (!ret && (nr_pids < ctx->nr_pids))
 		ret = -ESRCH;
 
+	atomic_set(&ctx->nr_total, nr_pids);
 	return ret;
 }
 
@@ -832,7 +892,7 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	if (!nsproxy)
 		return -ESRCH;
 
-	ctx->active_pid = -1;	/* see restore_activate_next, get_active_pid */
+	ctx->active_pid = -1;   /* see restore_activate_next, get_active_pid */
 
 	return 0;
 }
@@ -973,12 +1033,14 @@ static long restore_retval(void)
 	return ret;
 }
 
-long do_restart(struct ckpt_ctx *ctx, pid_t pid)
+long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 {
 	long ret;
 
 	if (ctx)
 		ret = do_restore_coord(ctx, pid);
+	else if (flags & RESTART_GHOST)
+		ret = do_ghost_task();
 	else
 		ret = do_restore_task();
 
@@ -1025,8 +1087,7 @@ void exit_checkpoint(struct task_struct *tsk)
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
 		BUG_ON(ctx->active_pid == -1);
-		if (restore_activate_next(ctx) < 0)
-			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+		restore_task_done(ctx);
 	}
 
 	ckpt_ctx_put(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d6a1650..76a3fa9 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -238,6 +238,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
+	init_waitqueue_head(&ctx->ghostq);
 
 	err = -EBADF;
 	ctx->file = fget(fd);
@@ -334,7 +335,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ret = do_restart(ctx, pid);
+	ret = do_restart(ctx, pid, flags);
 
 	ckpt_ctx_put(ctx);
 	return ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7c117fc..8e1cce7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,7 @@
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
+#define RESTART_GHOST		0x4
 
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
@@ -44,7 +45,10 @@
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
+#define RESTART_USER_FLAGS  \
+	(RESTART_TASKSELF | \
+	 RESTART_FROZEN | \
+	 RESTART_GHOST)
 
 extern void exit_checkpoint(struct task_struct *tsk);
 
@@ -78,6 +82,9 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+/* pids */
+extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
@@ -130,7 +137,7 @@ extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index bf584cb..842177f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -215,6 +215,9 @@ struct ckpt_pids {
 	__s32 vsid;
 } __attribute__((aligned(8)));
 
+/* pids */
+#define CKPT_PID_NULL  -1
+
 /* task data */
 struct ckpt_hdr_task {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index be45666..9b7b4dd 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -68,9 +68,11 @@ struct ckpt_ctx {
 	/* [multi-process restart] */
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
+	atomic_t nr_total;		/* total tasks count (with ghosts) */
 	int active_pid;			/* (next) position in pids array */
-	struct completion complete;	/* container root and other tasks on */
-	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct completion complete;	/* completion for container root */
+	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
+	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
