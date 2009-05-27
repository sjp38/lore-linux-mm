Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 514856B00B2
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:14 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 23/43] c/r: restart multiple processes
Date: Wed, 27 May 2009 13:32:49 -0400
Message-Id: <1243445589-32388-24-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restarting of multiple processes expects all restarting tasks to call
sys_restart(). Once inside the system call, each task will restart
itself at the same order that they were saved. The internals of the
syscall will take care of in-kernel synchronization bewteen tasks.

This patch does _not_ create the task tree in the kernel. Instead it
assumes that all tasks are created in some way and then invoke the
restart syscall. You can use the userspace mktree.c program to do
that.

The init task (*) has a special role: it allocates the restart context
(ctx), and coordinates the operation. In particular, it first waits
until all participating tasks enter the kernel, and provides them the
common restart context. Once everyone in ready, it begins to restart
itself.

In contrast, the other tasks enter the kernel, locate the init task (*)
and grab its restart context, and then wait for their turn to restore.

When a task (init or not) completes its restart, it hands the control
over to the next in line, by waking that task.

An array of pids (the one saved during the checkpoint) is used to
synchronize the operation. The first task in the array is the init
task (*). The restart context (ctx) maintain a "current position" in
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
 checkpoint/restart.c             |  242 ++++++++++++++++++++++++++++++++++++--
 checkpoint/sys.c                 |   27 ++++-
 include/linux/checkpoint.h       |    3 +
 include/linux/checkpoint_types.h |   17 +++-
 include/linux/sched.h            |    4 +
 5 files changed, 277 insertions(+), 16 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 8b8229e..5e68835 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -13,6 +13,7 @@
 
 #include <linux/version.h>
 #include <linux/sched.h>
+#include <linux/wait.h>
 #include <linux/file.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
@@ -353,12 +354,233 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
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
+static inline pid_t active_pid(struct ckpt_ctx *ctx)
+{
+	return ctx->pids_arr[ctx->active_pid].vpid;
+}
+
+static int restore_wait_task(struct ckpt_ctx *ctx)
+{
+	pid_t pid = task_pid_vnr(current);
+
+	ckpt_debug("pid %d waiting\n", pid);
+	return wait_event_interruptible(ctx->waitq, active_pid(ctx) == pid);
+}
+
+static int restore_next_task(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task;
+
+	ctx->active_pid++;
+
+	ckpt_debug("active_pid %d of %d\n", ctx->active_pid, ctx->nr_pids);
+	if (ctx->active_pid == ctx->nr_pids) {
+		complete(&ctx->complete);
+		return 0;
+	}
+
+	ckpt_debug("pids_next %d\n", active_pid(ctx));
+
+	rcu_read_lock();
+	task = find_task_by_pid_ns(active_pid(ctx), ctx->root_nsproxy->pid_ns);
+	if (task)
+		wake_up_process(task);
+	rcu_read_unlock();
+
+	if (!task) {
+		complete(&ctx->complete);
+		return -ESRCH;
+	}
+
+	return 0;
+}
+
+/* FIXME: this should be per container */
+DECLARE_WAIT_QUEUE_HEAD(restore_waitq);
+
+static int do_restore_task(pid_t pid)
+{
+	struct task_struct *root_task;
+	struct ckpt_ctx *ctx = NULL;
+	int ret;
+
+	rcu_read_lock();
+	root_task = find_task_by_pid_ns(pid, current->nsproxy->pid_ns);
+	if (root_task)
+		get_task_struct(root_task);
+	rcu_read_unlock();
+
+	if (!root_task)
+		return -EINVAL;
+
+	/*
+	 * wait for container init to initialize the restart context, then
+	 * grab a reference to that context, and if we're the last task to
+	 * do it, notify the container init.
+	 */
+	ret = wait_event_interruptible(restore_waitq,
+				       root_task->checkpoint_ctx);
+	if (ret < 0)
+		goto out;
+
+	task_lock(root_task);
+	ctx = root_task->checkpoint_ctx;
+	if (ctx)
+		ckpt_ctx_get(ctx);
+	task_unlock(root_task);
+
+	if (!ctx) {
+		ret = -EAGAIN;
+		goto out;
+	}
+
+	if (atomic_dec_and_test(&ctx->tasks_count))
+		complete(&ctx->complete);
+
+	/* wait for our turn, do the restore, and tell next task in line */
+	ret = restore_wait_task(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_next_task(ctx);
+ out:
+	ckpt_ctx_put(ctx);
+	put_task_struct(root_task);
+	return ret;
+}
+
+/**
+ * wait_all_tasks_start - wait for all tasks to enter sys_restart()
+ * @ctx: checkpoint context
+ *
+ * Called by the container root to wait until all restarting tasks
+ * are ready to restore their state. Temporarily advertises the 'ctx'
+ * on 'current->checkpoint_ctx' so that others can grab a reference
+ * to it, and clears it once synchronization completes. See also the
+ * related code in do_restore_task().
+ */
+static int wait_all_tasks_start(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	if (ctx->nr_pids == 1)
+		return 0;
+
+	init_completion(&ctx->complete);
+	current->checkpoint_ctx = ctx;
+
+	wake_up_all(&restore_waitq);
+
+	ret = wait_for_completion_interruptible(&ctx->complete);
+
+	task_lock(current);
+	current->checkpoint_ctx = NULL;
+	task_unlock(current);
+
+	return ret;
+}
+
+static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	if (ctx->nr_pids == 1)
+		return 0;
+
+	init_completion(&ctx->complete);
+
+	ret = restore_next_task(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = wait_for_completion_interruptible(&ctx->complete);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
 /* setup restart-specific parts of ctx */
 static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
+	ctx->root_pid = pid;
+	ctx->root_task = current;
+	ctx->root_nsproxy = current->nsproxy;
+
+	get_task_struct(ctx->root_task);
+	get_nsproxy(ctx->root_nsproxy);
+
+	atomic_set(&ctx->tasks_count, ctx->nr_pids - 1);
+
 	return 0;
 }
 
+static int do_restore_root(struct ckpt_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = restore_read_header(ctx);
+	if (ret < 0)
+		return ret;
+	ret = restore_read_tree(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = init_restart_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	/* wait for all other tasks to enter do_restore_task() */
+	ret = wait_all_tasks_start(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = restore_task(ctx);
+	if (ret < 0)
+		return ret;
+
+	/* wait for all other tasks to complete do_restore_task() */
+	ret = wait_all_tasks_finish(ctx);
+	if (ret < 0)
+		return ret;
+
+	return restore_read_tail(ctx);
+}
+
 static int restore_retval(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
@@ -391,18 +613,18 @@ int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
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
+	if (ctx)
+		ret = do_restore_root(ctx, pid);
+	else
+		ret = do_restore_task(pid);
+
 	if (ret < 0)
 		return ret;
 
+	/*
+	 * The retval from either is what we return to the caller when all
+	 * goes well: this is the retval from the original syscall that was
+	 * interrupted during checkpoint (zero if the task was in userspace).
+	 */
 	return restore_retval();
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 46eadf5..f6cf0ac 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -188,6 +188,8 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
+	BUG_ON(atomic_read(&ctx->refcount));
+
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -203,6 +205,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->root_task)
 		put_task_struct(ctx->root_task);
 
+	kfree(ctx->pids_arr);
+
 	kfree(ctx);
 }
 
@@ -220,8 +224,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	init_waitqueue_head(&ctx->waitq);
 
 	err = -EBADF;
 	ctx->file = fget(fd);
@@ -232,12 +238,24 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (ckpt_obj_hash_alloc(ctx) < 0)
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
@@ -269,7 +287,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 	if (!ret)
 		ret = ctx->crid;
 
-	ckpt_ctx_free(ctx);
+	ckpt_ctx_put(ctx);
 	return ret;
 }
 
@@ -284,7 +302,7 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
  */
 SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 {
-	struct ckpt_ctx *ctx;
+	struct ckpt_ctx *ctx = NULL;
 	int ret;
 
 	/* no flags for now */
@@ -294,13 +312,14 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
+	if (pid == task_pid_vnr(current))
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
 	ret = do_restart(ctx, pid);
 
-	ckpt_ctx_free(ctx);
+	ckpt_ctx_put(ctx);
 	return ret;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e1204cf..e9efa34 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -51,6 +51,9 @@ extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 
+extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
+extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
+
 extern int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index d5db5c9..f39e1c1 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -25,6 +25,8 @@ struct ckpt_hdr_vma;
 #include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
+#include <linux/sched.h>
+#include <asm/atomic.h>
 
 #include <linux/sched.h>
 
@@ -45,8 +47,7 @@ struct ckpt_ctx {
 	struct file *file;	/* input/output file */
 	int total;		/* total read/written */
 
-	struct task_struct **tasks_arr;	/* array of all tasks in container */
-	int nr_tasks;			/* size of tasks array */
+	atomic_t refcount;
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 
@@ -56,6 +57,18 @@ struct ckpt_ctx {
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+
+	/* [multi-process checkpoint] */
+	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
+	int nr_tasks;                   /* size of tasks array */
+
+	/* [multi-process restart] */
+	struct ckpt_hdr_pids *pids_arr;	/* array of all pids [restart] */
+	int nr_pids;			/* size of pids array */
+	int active_pid;			/* (next) position in pids array */
+	atomic_t tasks_count;		/* sync of tasks: used to coordinate */
+	struct completion complete;	/* container root and other tasks on */
+	wait_queue_head_t waitq;	/* start, end, and restart ordering */
 };
 
 /* ckpt_ctx: kflags */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b4c38bc..d057e7a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1429,6 +1429,10 @@ struct task_struct {
 	/* state flags for use by tracers */
 	unsigned long trace;
 #endif
+
+#ifdef CONFIG_CHECKPOINT
+	struct ckpt_ctx *checkpoint_ctx;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
