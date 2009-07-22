Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6755B6B00BA
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:23 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 26/60] c/r: restart multiple processes
Date: Wed, 22 Jul 2009 05:59:48 -0400
Message-Id: <1248256822-23416-27-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restarting of multiple processes expects all restarting tasks to call
sys_restart(). Once inside the system call, each task will restart
itself at the same order that they were saved. The internals of the
syscall will take care of in-kernel synchronization bewteen tasks.

This patch does _not_ create the task tree in the kernel. Instead it
assumes that all tasks are created in some way and then invoke the
restart syscall. You can use the userspace mktree.c program to do
that.

There is one special task - the coordinator - that is not part of the
restarted hierarchy. The coordinator task allocates the restart
context (ctx) and orchestrates the restart. Thus even if a restart
fails after, or during the restore of the root task, the user
perceives a clean exit and an error message.

The coordinator task will:
 1) read header and tree, create @ctx (wake up restarting tasks)
 2) set the ->checkpoint_ctx field of itself and all descendants
 3) wait for all restarting tasks to reach sync point #1
 4) activate first restarting task (root task)
 5) wait for all other tasks to complete and reach sync point #3
 6) wake up everybody

(Note that in step #2 the coordinator assumes that the entire task
hierarchy exists by the time it enters sys_restart; this is arranged
in user space by 'mktree')

Task that are restarting has three sync points:
 1) wait for its ->checkpoint_ctx to be set (by the coordinator)
 2) wait for the task's turn to restore (be active)
 [...now the task restores its state...]
 3) wait for all other tasks to complete

The third sync point ensures that a task may only resume execution
after all tasks have successfully restored their state (or fail if an
error has occured). This prevents tasks from returning to user space
prematurely, before the entire restart completes.

If a single task wishes to restart, it can set the "RESTART_TASKSELF"
flag to restart(2) to skip the logic of the coordinator.

The root-task is a child of the coordinator, identified by the @pid
given to sys_restart() in the pid-ns of the coordinator. Restarting
tasks that aren't the coordinator, should set the @pid argument of
restart(2) syscall to zero.

All tasks explicitly test for an error flag on the checkpoint context
when they wakeup from sync points.  If an error occurs during the
restart of some task, it will mark the @ctx with an error flag, and
wakeup the other tasks.

An array of pids (the one saved during the checkpoint) is used to
synchronize the operation. The first task in the array is the init
task (*). The restart context (@ctx) maintains a "current position" in
the array, which indicates which task is currently active. Once the
currently active task completes its own restart, it increments that
position and wakes up the next task.

Restart assumes that userspace provides meaningful data, otherwise
it's garbage-in-garbage-out. In this case, the syscall may block
indefinitely, but in TASK_INTERRUPTIBLE, so the user can ctrl-c or
otherwise kill the stray restarting tasks.

In terms of security, restart runs as the user the invokes it, so it
will not allow a user to do more than is otherwise permitted by the
usual system semantics and policy.

Currently we ignore threads and zombies, as well as session ids.
Add support for multiple processes

(*) For containers, restart should be called inside a fresh container
by the init task of that container. However, it is also possible to
restart applications not necessarily inside a container, and without
restoring the original pids of the processes (that is, provided that
the application can tolerate such behavior). This is useful to allow
multi-process restart of tasks not isolated inside a container, and
also for debugging.

Changelog[v17]:
  - Add uflag RESTART_FROZEN to freeze tasks after restart
  - Fix restore_retval() and use only for restarting tasks
  - Coordinator converts -ERSTART... to -EINTR
  - Coordinator marks and sets descendants' ->checkpoint_ctx
  - Coordinator properly detects errors when woken up from wait
  - Fix race where root_task could kick start too early
  - Add a sync point for restarting tasks
  - Multiple fixes to restart logic
Changelog[v14]:
  - Revert change to pr_debug(), back to ckpt_debug()
  - Discard field 'h.parent'
  - Check whether calls to ckpt_hbuf_get() fail
Changelog[v13]:
  - Clear root_task->checkpoint_ctx regardless of error condition
  - Remove unused argument 'ctx' from do_restore_task() prototype
  - Remove unused member 'pids_err' from 'struct ckpt_ctx'
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/restart.c             |  461 ++++++++++++++++++++++++++++++++++++--
 checkpoint/sys.c                 |   33 ++-
 include/linux/checkpoint.h       |   39 +++-
 include/linux/checkpoint_types.h |   15 +-
 include/linux/sched.h            |    4 +
 kernel/exit.c                    |    5 +
 kernel/fork.c                    |    3 +
 7 files changed, 519 insertions(+), 41 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 4d1ff31..65422e2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -13,7 +13,10 @@
 
 #include <linux/version.h>
 #include <linux/sched.h>
+#include <linux/wait.h>
 #include <linux/file.h>
+#include <linux/ptrace.h>
+#include <linux/freezer.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
 #include <asm/syscall.h>
@@ -324,6 +327,414 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* restore_read_tree - read the tasks tree into the checkpoint context */
+static int restore_read_tree(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tree *h;
+	int size, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TREE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->nr_tasks < 0)
+		goto out;
+
+	ctx->nr_pids = h->nr_tasks;
+	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
+	if (size < 0)		/* overflow ? */
+		goto out;
+
+	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
+	if (!ctx->pids_arr) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	ret = _ckpt_read_buffer(ctx, ctx->pids_arr, size);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
+{
+	int active = ctx->active_pid;
+	return active >= 0 ? ctx->pids_arr[active].vpid : 0;
+}
+
+static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
+{
+	return get_active_pid(ctx) == pid;
+}
+
+static inline void ckpt_notify_error(struct ckpt_ctx *ctx)
+{
+	ckpt_debug("ctx with root pid %d (%p)", ctx->root_pid, ctx);
+	ckpt_set_ctx_error(ctx);
+	complete(&ctx->complete);
+}
+
+static int ckpt_activate_next(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task;
+	int active;
+	pid_t pid;
+
+	active = ++ctx->active_pid;
+	if (active >= ctx->nr_pids) {
+		complete(&ctx->complete);
+		return 0;
+	}
+
+	pid = get_active_pid(ctx);
+	ckpt_debug("active pid %d (%d < %d)\n", pid, active, ctx->nr_pids);
+
+	rcu_read_lock();
+	task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
+	if (task)
+		wake_up_process(task);
+	rcu_read_unlock();
+
+	if (!task) {
+		ckpt_notify_error(ctx);
+		return -ESRCH;
+	}
+
+	return 0;
+}
+
+static int wait_task_active(struct ckpt_ctx *ctx)
+{
+	pid_t pid = task_pid_vnr(current);
+	int ret;
+
+	ckpt_debug("pid %d waiting\n", pid);
+	ret = wait_event_interruptible(ctx->waitq,
+				       is_task_active(ctx, pid) ||
+				       ckpt_test_ctx_error(ctx));
+	if (!ret && ckpt_test_ctx_error(ctx)) {
+		force_sig(SIGKILL, current);
+		ret = -EBUSY;
+	}
+	return ret;
+}
+
+static int wait_task_sync(struct ckpt_ctx *ctx)
+{
+	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	wait_event_interruptible(ctx->waitq, ckpt_test_ctx_complete(ctx));
+	if (ckpt_test_ctx_error(ctx)) {
+		force_sig(SIGKILL, current);
+		return -EBUSY;
+	}
+	return 0;
+}
+
+static int do_restore_task(void)
+{
+	DECLARE_WAIT_QUEUE_HEAD(waitq);
+	struct ckpt_ctx *ctx, *old_ctx;
+	int ret;
+
+	/*
+	 * Wait for coordinator to make become visible, then grab a
+	 * reference to its restart context. If we're the last task to
+	 * do it, notify the coordinator.
+	 */
+	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
+	if (ret < 0)
+		return ret;
+
+	ctx = xchg(&current->checkpoint_ctx, NULL);
+	if (!ctx)
+		return -EAGAIN;
+	ckpt_ctx_get(ctx);
+
+	/*
+	 * Put the @ctx back on our task_struct. If an ancestor tried
+	 * to prepare_descendants() on us (although extremly unlikely)
+	 * we will encounter the ctx that he xchg()ed there and bail.
+	 */
+	old_ctx = xchg(&current->checkpoint_ctx, ctx);
+	if (old_ctx) {
+		ckpt_debug("self-set of checkpoint_ctx failed\n");
+		/* alert coordinator of unexpected ctx */
+		ckpt_notify_error(old_ctx);
+		ckpt_ctx_put(old_ctx);
+		/* alert our coordinator that we bail */
+		ckpt_notify_error(ctx);
+		ckpt_ctx_put(ctx);
+		return -EAGAIN;
+	}
+
+	/* wait for our turn, do the restore, and tell next task in line */
+	ret = wait_task_active(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_activate_next(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = wait_task_sync(ctx);
+ out:
+	old_ctx = xchg(&current->checkpoint_ctx, NULL);
+	if (old_ctx)
+		ckpt_ctx_put(old_ctx);
+
+	/* if we're first to fail - notify others */
+	if (ret < 0 && !ckpt_test_ctx_error(ctx)) {
+		ckpt_notify_error(ctx);
+		wake_up_all(&ctx->waitq);
+	}
+
+	ckpt_ctx_put(ctx);
+	return ret;
+}
+
+/**
+ * prepare_descendants - set ->restart_tsk of all descendants
+ * @ctx: checkpoint context
+ * @root: root process for restart
+ *
+ * Called by the coodinator to set the ->restart_tsk pointer of the
+ * root task and all its descendants.
+ */
+static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
+{
+	struct task_struct *leader = root;
+	struct task_struct *parent = NULL;
+	struct task_struct *task = root;
+	struct ckpt_ctx *old_ctx;
+	int nr_pids = ctx->nr_pids;
+	int ret = 0;
+
+	read_lock(&tasklist_lock);
+	while (nr_pids) {
+		ckpt_debug("consider task %d\n", task_pid_vnr(task));
+		if (task_ptrace(task) & PT_PTRACED) {
+			ret = -EBUSY;
+			break;
+		}
+		/*
+		 * Set task->restart_tsk of all non-zombie descendants.
+		 * If a descendant already has a ->checkpoint_ctx, it
+		 * must be a coordinator (for a different restart ?) so
+		 * we fail.
+		 *
+		 * Note that own ancestors cannot interfere since they
+		 * won't descend past us, as own ->checkpoint_ctx must
+		 * already be set.
+		 */
+		if (!task->exit_state) {
+			ckpt_ctx_get(ctx);
+			old_ctx = xchg(&task->checkpoint_ctx, ctx);
+			if (old_ctx) {
+				ckpt_debug("bad task %d\n",task_pid_vnr(task));
+				ckpt_ctx_put(old_ctx);
+				ret = -EAGAIN;
+				break;
+			}
+			ckpt_debug("prepare task %d\n", task_pid_vnr(task));
+			wake_up_process(task);
+			nr_pids--;
+		}
+
+		/* if has children - proceed with child */
+		if (!list_empty(&task->children)) {
+			parent = task;
+			task = list_entry(task->children.next,
+					  struct task_struct, sibling);
+			continue;
+		}
+		while (task != root) {
+			/* if has sibling - proceed with sibling */
+			if (!list_is_last(&task->sibling, &parent->children)) {
+				task = list_entry(task->sibling.next,
+						  struct task_struct, sibling);
+				break;
+			}
+
+			/* else, trace back to parent and proceed */
+			task = parent;
+			parent = parent->real_parent;
+		}
+		if (task == root) {
+			/* in case root task in multi-threaded */
+			root = task = next_thread(task);
+			if (root == leader)
+				break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+	ckpt_debug("left %d ret %d root/task %d\n", nr_pids, ret, task == root);
+
+	/* fail unless number of processes matches */
+	if (!ret && (nr_pids || task != root))
+		ret = -ESRCH;
+
+	return ret;
+}
+
+static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	init_completion(&ctx->complete);
+
+	ret = ckpt_activate_next(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = wait_for_completion_interruptible(&ctx->complete);
+
+	if (ckpt_test_ctx_error(ctx))
+		ret = -EBUSY;
+	return ret;
+}
+
+static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task;
+
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ctx->root_pid = pid;
+		ctx->root_task = current;
+		get_task_struct(current);
+		return current;
+	}
+
+	read_lock(&tasklist_lock);
+	list_for_each_entry(task, &current->children, sibling) {
+		if (task_pid_vnr(task) == pid) {
+			get_task_struct(task);
+			ctx->root_task = task;
+			ctx->root_pid = pid;
+			break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	return task;
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct nsproxy *nsproxy;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	ctx->root_task = choose_root_task(ctx, pid);
+	if (!ctx->root_task)
+		return -ESRCH;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(ctx->root_task);
+	if (nsproxy) {
+		get_nsproxy(nsproxy);
+		ctx->root_nsproxy = nsproxy;
+	}
+	rcu_read_unlock();
+	if (!nsproxy)
+		return -ESRCH;
+
+	ctx->active_pid = -1;	/* see ckpt_activate_next, get_active_pid */
+
+	return 0;
+}
+
+static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct ckpt_ctx *old_ctx;
+	int ret;
+
+	ret = restore_read_header(ctx);
+	if (ret < 0)
+		return ret;
+	ret = restore_read_tree(ctx);
+	if (ret < 0)
+		return ret;
+
+	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
+		return -EINVAL;
+
+	ret = init_restart_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
+	 * prepare_descendants() on us, it will fail. Furthermore,
+	 * that ancestor won't proceed deeper to interfere with our
+	 * descendants that are restarting (e.g. by xchg()ing their
+	 * ->checkpoint_ctx pointer temporarily).
+	 */
+	ckpt_ctx_get(ctx);
+	old_ctx = xchg(&current->checkpoint_ctx, ctx);
+	if (old_ctx) {
+		/*
+		 * We are a bad-behaving descendant: an ancestor must
+		 * have done prepare_descendants() on us as part of a
+		 * restart. Oh, well ... alert ancestor (coordinator)
+		 * with an error on @old_ctx.
+		 */
+		ckpt_debug("bad bavhing checkpoint_ctx\n");
+		ckpt_notify_error(old_ctx);
+		ckpt_ctx_put(old_ctx);
+		return -EBUSY;
+	}
+
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = restore_task(ctx);
+		if (ret < 0)
+			goto out;
+	} else {
+		/* prepare descendants' t->restart_tsk point to coord */
+		ret = prepare_descendants(ctx, ctx->root_task);
+		if (ret < 0)
+			goto out;
+		/* wait for all other tasks to complete do_restore_task() */
+		ret = wait_all_tasks_finish(ctx);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_read_tail(ctx);
+	if (ret < 0)
+		goto out;
+
+	if (ctx->uflags & RESTART_FROZEN) {
+		ret = cgroup_freezer_make_frozen(ctx->root_task);
+		ckpt_debug("freezing restart tasks ... %d\n", ret);
+	}
+ out:
+	if (ret < 0)
+		ckpt_set_ctx_error(ctx);
+	else
+		ckpt_set_ctx_success(ctx);
+
+	if (!(ctx->uflags & RESTART_TASKSELF))
+		wake_up_all(&ctx->waitq);
+	/*
+	 * If an ancestor attempts to prepare_descendants() on us, it
+	 * xchg()s our ->checkpoint_ctx, and free it. Our @ctx will,
+	 * instead, point to the ctx that said ancestor placed.
+	 */
+	ctx = xchg(&current->checkpoint_ctx, NULL);
+	ckpt_ctx_put(ctx);
+
+	return ret;
+}
+
 static long restore_retval(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
@@ -372,28 +783,40 @@ static long restore_retval(void)
 	return ret;
 }
 
-/* setup restart-specific parts of ctx */
-static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
-{
-	return 0;
-}
-
 long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	long ret;
 
-	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
-		return ret;
-	ret = restore_read_header(ctx);
-	if (ret < 0)
-		return ret;
-	ret = restore_task(ctx);
-	if (ret < 0)
-		return ret;
-	ret = restore_read_tail(ctx);
-	if (ret < 0)
-		return ret;
+	if (ctx)
+		ret = do_restore_coord(ctx, pid);
+	else
+		ret = do_restore_task();
 
-	return restore_retval();
+	/* restart(2) isn't idempotent: should not be auto-restarted */
+	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
+	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
+		ret = -EINTR;
+
+	/*
+	 * The retval from what we return to the caller when all goes
+	 * well: this is either the retval from the original syscall
+	 * that was interrupted during checkpoint, or the contents of
+	 * (saved) eax if the task was in userspace.
+	 *
+	 * The coordinator (ctx!=NULL) is exempt: don't adjust its retval.
+	 * But in self-restart (where RESTART_TASKSELF), the coordinator
+	 * _itself_ is a restarting task.
+	 */
+
+	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
+		if (ret < 0) {
+			/* partial restore is undefined: terminate */
+			ckpt_debug("restart err %d, exiting\n", ret);
+			force_sig(SIGKILL, current);
+		} else {
+			ret = restore_retval();
+		}
+	}
+
+	return ret;
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index cc94775..c8921f0 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -189,6 +189,8 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
+	BUG_ON(atomic_read(&ctx->refcount));
+
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -202,6 +204,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->root_freezer)
 		put_task_struct(ctx->root_freezer);
 
+	kfree(ctx->pids_arr);
+
 	kfree(ctx);
 }
 
@@ -219,17 +223,32 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	atomic_set(&ctx->refcount, 0);
+	init_waitqueue_head(&ctx->waitq);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
 		goto err;
 
+	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
 	ckpt_ctx_free(ctx);
 	return ERR_PTR(err);
 }
 
+void ckpt_ctx_get(struct ckpt_ctx *ctx)
+{
+	atomic_inc(&ctx->refcount);
+}
+
+void ckpt_ctx_put(struct ckpt_ctx *ctx)
+{
+	if (ctx && atomic_dec_and_test(&ctx->refcount))
+		ckpt_ctx_free(ctx);
+}
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
@@ -261,7 +280,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 	if (!ret)
 		ret = ctx->crid;
 
-	ckpt_ctx_free(ctx);
+	ckpt_ctx_put(ctx);
 	return ret;
 }
 
@@ -280,24 +299,20 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	long ret;
 
 	/* no flags for now */
-	if (flags)
+	if (flags & ~RESTART_USER_FLAGS)
 		return -EINVAL;
 
 	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+	if (pid)
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
 	ret = do_restart(ctx, pid);
 
-	/* restart(2) isn't idempotent: can't restart syscall */
-	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
-	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
-		ret = -EINTR;
-
-	ckpt_ctx_free(ctx);
+	ckpt_ctx_put(ctx);
 	return ret;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index df2938f..44b692d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -15,6 +15,10 @@
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
 
+/* restart user flags */
+#define RESTART_TASKSELF	0x1
+#define RESTART_FROZEN		0x2
+
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
 
@@ -23,23 +27,21 @@
 
 
 /* ckpt_ctx: kflags */
-#define CKPT_CTX_CHECKPOINT_BIT		1
-#define CKPT_CTX_RESTART_BIT		2
+#define CKPT_CTX_CHECKPOINT_BIT		0
+#define CKPT_CTX_RESTART_BIT		1
+#define CKPT_CTX_SUCCESS_BIT		2
+#define CKPT_CTX_ERROR_BIT		3
 
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
+#define CKPT_CTX_SUCCESS	(1 << CKPT_CTX_SUCCESS_BIT)
+#define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
 
-
-/* ckpt_ctx: kflags */
-#define CKPT_CTX_CHECKPOINT_BIT		1
-#define CKPT_CTX_RESTART_BIT		2
-
-#define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
-#define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
-
-/* ckpt ctx: uflags */
+/* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
 
+extern void exit_checkpoint(struct task_struct *tsk);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
@@ -64,6 +66,21 @@ extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
 
+/* ckpt kflags */
+#define ckpt_set_ctx_kflag(__ctx, __kflag)  \
+	set_bit(__kflag##_BIT, &(__ctx)->kflags)
+
+#define ckpt_set_ctx_success(ctx)  ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS)
+#define ckpt_set_ctx_error(ctx)  ckpt_set_ctx_kflag(ctx, CKPT_CTX_ERROR)
+
+#define ckpt_test_ctx_error(ctx)  \
+	((ctx)->kflags & CKPT_CTX_ERROR)
+#define ckpt_test_ctx_complete(ctx)  \
+	((ctx)->kflags & (CKPT_CTX_SUCCESS | CKPT_CTX_ERROR))
+
+extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
+extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
+
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5dca34f..4785df6 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -16,6 +16,7 @@
 #include <linux/nsproxy.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
+#include <linux/wait.h>
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
@@ -35,10 +36,20 @@ struct ckpt_ctx {
 	struct file *file;	/* input/output file */
 	int total;		/* total read/written */
 
-	struct task_struct **tasks_arr;	/* array of all tasks in container */
-	int nr_tasks;			/* size of tasks array */
+	atomic_t refcount;
 
 	char err_string[256];	/* checkpoint: error string */
+
+	/* [multi-process checkpoint] */
+	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
+	int nr_tasks;                   /* size of tasks array */
+
+	/* [multi-process restart] */
+	struct ckpt_hdr_pids *pids_arr;	/* array of all pids [restart] */
+	int nr_pids;			/* size of pids array */
+	int active_pid;			/* (next) position in pids array */
+	struct completion complete;	/* container root and other tasks on */
+	wait_queue_head_t waitq;	/* start, end, and restart ordering */
 };
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e2ebb41..0e67de7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1479,6 +1479,9 @@ struct task_struct {
 	/* bitmask of trace recursion */
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
+#ifdef CONFIG_CHECKPOINT
+	struct ckpt_ctx *checkpoint_ctx;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
@@ -1692,6 +1695,7 @@ extern cputime_t task_gtime(struct task_struct *p);
 #define PF_SPREAD_PAGE	0x01000000	/* Spread page cache over cpuset */
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_THREAD_BOUND	0x04000000	/* Thread bound to specific cpu */
+#define PF_RESTARTING	0x08000000	/* Process is restarting (c/r) */
 #define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezeable */
diff --git a/kernel/exit.c b/kernel/exit.c
index 869dc22..912b1fa 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -49,6 +49,7 @@
 #include <linux/init_task.h>
 #include <linux/perf_counter.h>
 #include <trace/events/sched.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -992,6 +993,10 @@ NORET_TYPE void do_exit(long code)
 	if (unlikely(current->pi_state_cache))
 		kfree(current->pi_state_cache);
 #endif
+#ifdef CONFIG_CHECKPOINT
+	if (unlikely(tsk->checkpoint_ctx))
+		exit_checkpoint(tsk);
+#endif
 	/*
 	 * Make sure we are holding no locks:
 	 */
diff --git a/kernel/fork.c b/kernel/fork.c
index 29c66f0..68412b5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1161,6 +1161,9 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	INIT_LIST_HEAD(&p->pi_state_list);
 	p->pi_state_cache = NULL;
 #endif
+#ifdef CONFIG_CHECKPOINT
+	p->checkpoint_ctx = NULL;
+#endif
 	/*
 	 * sigaltstack should be cleared when sharing the same VM
 	 */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
