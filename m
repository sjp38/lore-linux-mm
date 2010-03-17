Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B34246B020B
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:07 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 30/96] c/r: restart multiple processes
Date: Wed, 17 Mar 2010 12:08:18 -0400
Message-Id: <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
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

Changelog[v20]:
  - Replace error_sem with an event completion
Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33
  - Call restore_notify_error for restart (not checkpoint !)
  - Make kread/kwrite() abort if CKPT_CTX_ERROR is set
Changelog[v19-rc1]:
  - [Serge Hallyn] Move init_completion(&ctx->complete) to ctx_alloc
  - Pull cleanup/debug code from patches zombie, pgid to here
  - Simplify logic of tracking restarting tasks (->ctx)
  - Use walk_task_subtree() to iterate through descendants
  - Coordinator kills descendants on failure for proper cleanup
  - Prepare descendants needs PTRACE_MODE_ATTACH permissions
  - Threads wait for entire thread group before restoring
  - Add debug process-tree status during restart
  - Fix handling of bogus pid arg to sys_restart
  - [Serge Hallyn] Add global section container to image format
  - Coordinator to report correct error on restart failure
Changelog[v18]:
  - Fix race of prepare_descendant() with an ongoing fork()
  - Track and report the first error if restart fails
  - Tighten logic to protect against bogus pids in input
  - [Matt Helsley] Improve debug output from ckpt_notify_error()
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
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c          |    5 +
 checkpoint/restart.c             |  759 ++++++++++++++++++++++++++++++++++++--
 checkpoint/sys.c                 |   72 +++-
 include/linux/checkpoint.h       |   44 +++-
 include/linux/checkpoint_types.h |   24 ++-
 include/linux/sched.h            |   10 +-
 kernel/exit.c                    |    5 +
 kernel/fork.c                    |    7 +
 8 files changed, 888 insertions(+), 38 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ba566b0..1e38ae3 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -552,6 +552,11 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
  out:
+	if (ret < 0)
+		ckpt_set_error(ctx, ret);
+	else
+		ckpt_set_success(ctx);
+
 	if (ctx->root_freezer)
 		cgroup_freezer_end_checkpoint(ctx->root_freezer);
 	return ret;
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 3e898e7..59c4bd8 100644
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
@@ -21,6 +24,169 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
+#define RESTART_DBG_ROOT	(1 << 0)
+#define RESTART_DBG_GHOST	(1 << 1)
+#define RESTART_DBG_COORD	(1 << 2)
+#define RESTART_DBG_TASK	(1 << 3)
+#define RESTART_DBG_WAITING	(1 << 4)
+#define RESTART_DBG_RUNNING	(1 << 5)
+#define RESTART_DBG_EXITED	(1 << 6)
+#define RESTART_DBG_FAILED	(1 << 7)
+#define RESTART_DBG_SUCCESS	(1 << 8)
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+
+/*
+ * Track status of restarting tasks in a list off of checkpoint_ctx.
+ * Print this info when the checkpoint_ctx is freed. Sample output:
+ *
+ * [3519:2:c/r:debug_task_status:207] 3 tasks registered, nr_tasks was 0 nr_total 0
+ * [3519:2:c/r:debug_task_status:210] active pid was 1, ctx->errno 0
+ * [3519:2:c/r:debug_task_status:212] kflags 6 uflags 0 oflags 1
+ * [3519:2:c/r:debug_task_status:214] task 0 to run was 2
+ * [3519:2:c/r:debug_task_status:217] pid 3517  C  r
+ * [3519:2:c/r:debug_task_status:217] pid 3519  RN
+ * [3519:2:c/r:debug_task_status:217] pid 3520   G
+ */
+
+struct ckpt_task_status {
+	pid_t pid;
+	int flags;
+	int error;
+	struct list_head list;
+};
+
+static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
+{
+	struct ckpt_task_status *s;
+
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s) {
+		ckpt_debug("no memory to register ?!\n");
+		return -ENOMEM;
+	}
+	s->pid = current->pid;
+	s->error = 0;
+	s->flags = RESTART_DBG_WAITING | flags;
+	if (current == ctx->root_task)
+		s->flags |= RESTART_DBG_ROOT;
+
+	spin_lock(&ctx->lock);
+	list_add_tail(&s->list, &ctx->task_status);
+	spin_unlock(&ctx->lock);
+
+	return 0;
+}
+
+static struct ckpt_task_status *restore_debug_getme(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s;
+
+	spin_lock(&ctx->lock);
+	list_for_each_entry(s, &ctx->task_status, list) {
+		if (s->pid == current->pid) {
+			spin_unlock(&ctx->lock);
+			return s;
+		}
+	}
+	spin_unlock(&ctx->lock);
+	return NULL;
+}
+
+static void restore_debug_error(struct ckpt_ctx *ctx, int err)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->error = err;
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags &= ~RESTART_DBG_RUNNING;
+	if (err)
+		s->flags |= RESTART_DBG_FAILED;
+	else
+		s->flags |= RESTART_DBG_SUCCESS;
+}
+
+static void restore_debug_running(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags |= RESTART_DBG_RUNNING;
+}
+
+static void restore_debug_exit(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s = restore_debug_getme(ctx);
+
+	s->flags &= ~RESTART_DBG_WAITING;
+	s->flags |= RESTART_DBG_EXITED;
+}
+
+void restore_debug_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_task_status *s, *p;
+	int i, count = 0;
+	char *which, *state;
+
+	/*
+	 * See how many tasks registered.  Tasks which didn't reach
+	 * sys_restart() won't have registered.  So if this count is
+	 * not the same as ctx->nr_total, that's a warning bell
+	 */
+	list_for_each_entry(s, &ctx->task_status, list)
+		count++;
+	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
+		   count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
+
+	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
+		   ctx->errno);
+	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
+		   ctx->uflags, ctx->oflags);
+	for (i = 0; i < ctx->nr_pids; i++)
+		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
+
+	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
+		if (s->flags & RESTART_DBG_COORD)
+			which = "Coord";
+		else if (s->flags & RESTART_DBG_ROOT)
+			which = "Root";
+		else if (s->flags & RESTART_DBG_GHOST)
+			which = "Ghost";
+		else if (s->flags & RESTART_DBG_TASK)
+			which = "Task";
+		else
+			which = "?????";
+		if (s->flags & RESTART_DBG_WAITING)
+			state = "Waiting";
+		else if (s->flags & RESTART_DBG_RUNNING)
+			state = "Running";
+		else if (s->flags & RESTART_DBG_FAILED)
+			state = "Failed";
+		else if (s->flags & RESTART_DBG_SUCCESS)
+			state = "Success";
+		else if (s->flags & RESTART_DBG_EXITED)
+			state = "Exited";
+		else
+			state = "??????";
+		ckpt_debug("pid %d type %s state %s\n", s->pid, which, state);
+		list_del(&s->list);
+		kfree(s);
+	}
+}
+
+#else
+
+static inline int restore_debug_task(struct ckpt_ctx *ctx, int flags)
+{
+	return 0;
+}
+static inline void restore_debug_error(struct ckpt_ctx *ctx, int err) {}
+static inline void restore_debug_running(struct ckpt_ctx *ctx) {}
+static inline void restore_debug_exit(struct ckpt_ctx *ctx) {}
+
+#endif /* CONFIG_CHECKPOINT_DEBUG */
+
+
 static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 {
 	char *ptr;
@@ -205,11 +371,16 @@ void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
 	BUG_ON(!len);
 
 	h = ckpt_read_obj(ctx, len, len);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "Looking for type %d in ckptfile\n",
+			 type);
 		return h;
+	}
 
 	if (h->type != type) {
 		ckpt_hdr_put(ctx, h);
+		ckpt_err(ctx, -EINVAL, "Next object was type %d, not %d\n",
+			h->type, type);
 		h = ERR_PTR(-EINVAL);
 	}
 
@@ -449,6 +620,519 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
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
+	if (h->nr_tasks <= 0)
+		goto out;
+
+	ctx->nr_pids = h->nr_tasks;
+	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
+	if (size <= 0)		/* overflow ? */
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
+static inline int all_tasks_activated(struct ckpt_ctx *ctx)
+{
+	return (ctx->active_pid == ctx->nr_pids);
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
+/*
+ * If exiting a restart with error, then wake up all other tasks
+ * in the restart context.
+ */
+void restore_notify_error(struct ckpt_ctx *ctx)
+{
+	complete(&ctx->complete);
+	wake_up_all(&ctx->waitq);
+}
+
+static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
+{
+	struct ckpt_ctx *ctx;
+
+	task_lock(task);
+	ctx = ckpt_ctx_get(task->checkpoint_ctx);
+	task_unlock(task);
+	return ctx;
+}
+
+/* returns 0 on success, 1 otherwise */
+static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	task_lock(task);
+	if (!task->checkpoint_ctx) {
+		task->checkpoint_ctx = ckpt_ctx_get(ctx);
+		ret = 0;
+	} else {
+		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
+		ret = 1;
+	}
+	task_unlock(task);
+	return ret;
+}
+
+static void clear_task_ctx(struct task_struct *task)
+{
+	struct ckpt_ctx *old;
+
+	task_lock(task);
+	old = task->checkpoint_ctx;
+	task->checkpoint_ctx = NULL;
+	task_unlock(task);
+
+	ckpt_debug("task %d clear checkpoint_ctx\n", task_pid_vnr(task));
+	ckpt_ctx_put(old);
+}
+
+static void restore_task_done(struct ckpt_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->nr_total))
+		complete(&ctx->complete);
+	BUG_ON(atomic_read(&ctx->nr_total) < 0);
+}
+
+static int restore_activate_next(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task;
+	pid_t pid;
+
+	ctx->active_pid++;
+
+	BUG_ON(ctx->active_pid > ctx->nr_pids);
+
+	if (!all_tasks_activated(ctx)) {
+		/* wake up next task in line to restore its state */
+		pid = get_active_pid(ctx);
+
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
+			ckpt_err(ctx, -ESRCH, "task %d not found\n", pid);
+			return -ESRCH;
+		}
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
+				       ckpt_test_error(ctx));
+	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
+		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+	return 0;
+}
+
+static int wait_task_sync(struct ckpt_ctx *ctx)
+{
+	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
+	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+	return 0;
+}
+
+/* grabs a reference to the @ctx on success; caller should free */
+static struct ckpt_ctx *wait_checkpoint_ctx(void)
+{
+	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	/*
+	 * Wait for coordinator to become visible, then grab a
+	 * reference to its restart context.
+	 */
+	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
+	if (ret < 0) {
+		ckpt_debug("wait_checkpoint_ctx: failed (%d)\n", ret);
+		return ERR_PTR(ret);
+	}
+
+	ctx = get_task_ctx(current);
+	if (!ctx) {
+		ckpt_debug("wait_checkpoint_ctx: checkpoint_ctx missing\n");
+		return ERR_PTR(-EAGAIN);
+	}
+
+	return ctx;
+}
+
+/*
+ * Ensure that all members of a thread group are in sys_restart before
+ * restoring any of them. Otherwise, restore may modify shared state
+ * and crash or fault a thread still in userspace,
+ */
+static int wait_sync_threads(void)
+{
+	struct task_struct *p = current;
+	atomic_t *count;
+	int nr = 0;
+	int ret = 0;
+
+	if (thread_group_empty(p))
+		return 0;
+
+	count = &p->signal->restart_count;
+
+	if (!atomic_read(count)) {
+		read_lock(&tasklist_lock);
+		for (p = next_thread(p); p != current; p = next_thread(p))
+			nr++;
+		read_unlock(&tasklist_lock);
+		/*
+		 * Testing that @count is 0 makes it unlikely that
+		 * multiple threads get here. But if they do, then
+		 * only one will succeed in initializing @count.
+		 */
+		atomic_cmpxchg(count, 0, nr + 1);
+	}
+
+	if (atomic_dec_and_test(count)) {
+		read_lock(&tasklist_lock);
+		for (p = next_thread(p); p != current; p = next_thread(p))
+			wake_up_process(p);
+		read_unlock(&tasklist_lock);
+	} else {
+		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
+		ret = wait_event_interruptible(waitq, !atomic_read(count));
+	}
+
+	return ret;
+}
+
+static int do_restore_task(void)
+{
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = restore_debug_task(ctx, RESTART_DBG_TASK);
+	if (ret < 0)
+		goto out;
+
+	ret = wait_sync_threads();
+	if (ret < 0)
+		goto out;
+
+	/* wait for our turn, do the restore, and tell next task in line */
+	ret = wait_task_active(ctx);
+	if (ret < 0)
+		goto out;
+
+	restore_debug_running(ctx);
+
+	ret = restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
+	restore_task_done(ctx);
+	ret = wait_task_sync(ctx);
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "task restart failed\n");
+
+	clear_task_ctx(current);
+	ckpt_ctx_put(ctx);
+	return ret;
+}
+
+/**
+ * __prepare_descendants - set ->checkpoint_ctx of a descendants
+ * @task: descendant task
+ * @data: points to the checkpoint ctx
+ */
+static int __prepare_descendants(struct task_struct *task, void *data)
+{
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+
+	ckpt_debug("consider task %d\n", task_pid_vnr(task));
+
+	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
+		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
+		return -EPERM;
+	}
+
+	if (task_ptrace(task) & PT_PTRACED) {
+		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		return -EBUSY;
+	}
+
+	/*
+	 * Set task->checkpoint_ctx of all non-zombie descendants.
+	 * If a descendant already has a ->checkpoint_ctx, it
+	 * must be a coordinator (for a different restart ?) so
+	 * we fail.
+	 *
+	 * Note that own ancestors cannot interfere since they
+	 * won't descend past us, as own ->checkpoint_ctx must
+	 * already be set.
+	 */
+	if (!task->exit_state) {
+		if (set_task_ctx(task, ctx))
+			return -EBUSY;
+		ckpt_debug("prepare task %d\n", task_pid_vnr(task));
+		wake_up_process(task);
+		return 1;
+	}
+
+	return 0;
+}
+
+/**
+ * prepare_descendants - set ->checkpoint_ctx of all descendants
+ * @ctx: checkpoint context
+ * @root: root process for restart
+ *
+ * Called by the coodinator to set the ->checkpoint_ctx pointer of the
+ * root task and all its descendants.
+ */
+static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
+{
+	int nr_pids;
+
+	nr_pids = walk_task_subtree(root, __prepare_descendants, ctx);
+	ckpt_debug("nr %d/%d\n", ctx->nr_pids, nr_pids);
+	if (nr_pids < 0)
+		return nr_pids;
+
+	/* fail unless number of processes matches */
+	if (nr_pids != ctx->nr_pids)
+		return -ESRCH;
+
+	atomic_set(&ctx->nr_total, nr_pids);
+	return nr_pids;
+}
+
+static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	BUG_ON(ctx->active_pid != -1);
+	ret = restore_activate_next(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = wait_for_completion_interruptible(&ctx->complete);
+	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
+
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
+	return ctx->root_task;
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
+	if (!choose_root_task(ctx, pid))
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
+	ctx->active_pid = -1;	/* see restore_activate_next, get_active_pid */
+
+	return 0;
+}
+
+static int __destroy_descendants(struct task_struct *task, void *data)
+{
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+
+	if (task->checkpoint_ctx == ctx)
+		force_sig(SIGKILL, task);
+
+	return 0;
+}
+
+static void destroy_descendants(struct ckpt_ctx *ctx)
+{
+	walk_task_subtree(ctx->root_task, __destroy_descendants, ctx);
+}
+
+static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = restore_debug_task(ctx, RESTART_DBG_COORD);
+	if (ret < 0)
+		return ret;
+	restore_debug_running(ctx);
+
+	ret = restore_read_header(ctx);
+	ckpt_debug("restore header: %d\n", ret);
+	if (ret < 0)
+		return ret;
+	ret = restore_container(ctx);
+	ckpt_debug("restore container: %d\n", ret);
+	if (ret < 0)
+		return ret;
+	ret = restore_read_tree(ctx);
+	ckpt_debug("restore tree: %d\n", ret);
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
+	 * descendants that are restarting.
+	 */
+	if (set_task_ctx(current, ctx)) {
+		/*
+		 * We are a bad-behaving descendant: an ancestor must
+		 * have prepare_descendants() us as part of a restart.
+		 */
+		ckpt_debug("coord already has checkpoint_ctx\n");
+		return -EBUSY;
+	}
+
+	/*
+	 * From now on we are committed to the restart. If anything
+	 * fails, we'll cleanup (that is, kill) those tasks in our
+	 * subtree that we marked for restart - see below.
+	 */
+
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = restore_task(ctx);
+		ckpt_debug("restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
+	} else {
+		/* prepare descendants' t->checkpoint_ctx point to coord */
+		ret = prepare_descendants(ctx, ctx->root_task);
+		ckpt_debug("restore prepare: %d\n", ret);
+		if (ret < 0)
+			goto out;
+		/* wait for all other tasks to complete do_restore_task() */
+		ret = wait_all_tasks_finish(ctx);
+		ckpt_debug("restore finish: %d\n", ret);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_read_tail(ctx);
+	ckpt_debug("restore tail: %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	if (ctx->uflags & RESTART_FROZEN) {
+		ret = cgroup_freezer_make_frozen(ctx->root_task);
+		ckpt_debug("freezing restart tasks ... %d\n", ret);
+	}
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
+
+	if (ckpt_test_error(ctx)) {
+		destroy_descendants(ctx);
+		ret = ckpt_get_error(ctx);
+	} else {
+		ckpt_set_success(ctx);
+		wake_up_all(&ctx->waitq);
+	}
+
+	clear_task_ctx(current);
+	return ret;
+}
+
 static long restore_retval(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
@@ -499,31 +1183,62 @@ static long restore_retval(void)
 	return syscall_get_return_value(current, regs);
 }
 
-/* setup restart-specific parts of ctx */
-static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
-	return 0;
+	long ret;
+
+	if (ctx)
+		ret = do_restore_coord(ctx, pid);
+	else
+		ret = do_restore_task();
+
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
+			ckpt_debug("restart err %ld, exiting\n", ret);
+			force_sig(SIGKILL, current);
+		} else {
+			ret = restore_retval();
+		}
+	}
+
+	ckpt_debug("sys_restart returns %ld\n", ret);
+	return ret;
 }
 
-long do_restart(struct ckpt_ctx *ctx, pid_t pid)
+/**
+ * exit_checkpoint - callback from do_exit to cleanup checkpoint state
+ * @tsk: terminating task
+ */
+void exit_checkpoint(struct task_struct *tsk)
 {
-	long ret;
+	struct ckpt_ctx *ctx;
 
-	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
-		return ret;
-	ret = restore_read_header(ctx);
-	if (ret < 0)
-		return ret;
-	ret = restore_container(ctx);
-	if (ret < 0)
-		return ret;
-	ret = restore_task(ctx);
-	if (ret < 0)
-		return ret;
-	ret = restore_read_tail(ctx);
-	if (ret < 0)
-		return ret;
+	/* no one else will touch this, because @tsk is dead already */
+	ctx = tsk->checkpoint_ctx;
+
+	/* restarting zombies will activate next task in restart */
+	if (tsk->flags & PF_RESTARTING) {
+		BUG_ON(ctx->active_pid == -1);
+		if (restore_activate_next(ctx) < 0)
+			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+	}
 
-	return restore_retval();
+	ckpt_ctx_put(ctx);
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d0eed25..8b142ed 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -66,6 +66,9 @@ int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, int count)
 	mm_segment_t fs;
 	int ret;
 
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 	ret = _ckpt_kwrite(ctx->file, addr, count);
@@ -103,6 +106,9 @@ int ckpt_kread(struct ckpt_ctx *ctx, void *addr, int count)
 	mm_segment_t fs;
 	int ret;
 
+	if (ckpt_test_error(ctx))
+		return ckpt_get_error(ctx);
+
 	fs = get_fs();
 	set_fs(KERNEL_DS);
 	ret = _ckpt_kread(ctx->file , addr, count);
@@ -194,6 +200,12 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
+	BUG_ON(atomic_read(&ctx->refcount));
+
+	/* per task status debugging only during restart */
+	if (ctx->kflags & CKPT_CTX_RESTART)
+		restore_debug_free(ctx);
+
 	if (ctx->file)
 		fput(ctx->file);
 	if (ctx->logfile)
@@ -209,6 +221,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->root_freezer)
 		put_task_struct(ctx->root_freezer);
 
+	kfree(ctx->pids_arr);
+
 	kfree(ctx);
 }
 
@@ -226,6 +240,17 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	atomic_set(&ctx->refcount, 0);
+	init_waitqueue_head(&ctx->waitq);
+	init_completion(&ctx->complete);
+
+	init_completion(&ctx->errno_sync);
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	INIT_LIST_HEAD(&ctx->task_status);
+	spin_lock_init(&ctx->lock);
+#endif
+
 	mutex_init(&ctx->msg_mutex);
 
 	err = -EBADF;
@@ -238,16 +263,43 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->logfile)
 		goto err;
  nolog:
+	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
 	ckpt_ctx_free(ctx);
 	return ERR_PTR(err);
 }
 
-static void ckpt_set_error(struct ckpt_ctx *ctx, int err)
+struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx)
+{
+	if (ctx)
+		atomic_inc(&ctx->refcount);
+	return ctx;
+}
+
+void ckpt_ctx_put(struct ckpt_ctx *ctx)
+{
+	if (ctx && atomic_dec_and_test(&ctx->refcount))
+		ckpt_ctx_free(ctx);
+}
+
+void ckpt_set_error(struct ckpt_ctx *ctx, int err)
 {
-	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR))
+	/* atomically set ctx->errno */
+	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
 		ctx->errno = err;
+		/* make ctx->errno visible to all other tasks */
+		complete_all(&ctx->errno_sync);
+		/* on restart, notify all tasks in restarting subtree */
+		if (ctx->kflags & CKPT_CTX_RESTART)
+			restore_notify_error(ctx);
+	}
+}
+
+void ckpt_set_success(struct ckpt_ctx *ctx)
+{
+	ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS);
+	complete_all(&ctx->errno_sync);
 }
 
 /* helpers to handler log/dbg/err messages */
@@ -392,7 +444,7 @@ void _ckpt_msg_complete(struct ckpt_ctx *ctx)
 	if (ctx->msglen <= 1)
 		return;
 
-	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ctx->errno) {
+	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ckpt_test_error(ctx)) {
 		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
 		if (!ret)
 			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
@@ -550,7 +602,7 @@ long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	if (!ret)
 		ret = ctx->crid;
 
-	ckpt_ctx_free(ctx);
+	ckpt_ctx_put(ctx);
 	return ret;
 }
 
@@ -570,24 +622,20 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 	long ret;
 
 	/* no flags for now */
-	if (flags)
+	if (flags & ~RESTART_USER_FLAGS)
 		return -EINVAL;
 
 	if (ckpt_unpriv_allowed < 2 && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
+	if (pid)
+		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
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
index 30f5353..d1eb722 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -15,6 +15,10 @@
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
 
+/* restart user flags */
+#define RESTART_TASKSELF	0x1
+#define RESTART_FROZEN		0x2
+
 /* misc user visible */
 #define CHECKPOINT_FD_NONE	-1
 
@@ -34,17 +38,22 @@ extern long do_sys_restart(pid_t pid, int fd,
 /* ckpt_ctx: kflags */
 #define CKPT_CTX_CHECKPOINT_BIT		0
 #define CKPT_CTX_RESTART_BIT		1
+#define CKPT_CTX_SUCCESS_BIT		2
+#define CKPT_CTX_ERROR_BIT		3
 
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
+#define CKPT_CTX_SUCCESS	(1 << CKPT_CTX_SUCCESS_BIT)
+#define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-
+#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
 			     void *data);
+extern void exit_checkpoint(struct task_struct *tsk);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
@@ -71,6 +80,35 @@ extern int ckpt_read_payload(struct ckpt_ctx *ctx,
 extern char *ckpt_read_string(struct ckpt_ctx *ctx, int max);
 extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
+/* ckpt kflags */
+#define ckpt_set_ctx_kflag(__ctx, __kflag)  \
+	set_bit(__kflag##_BIT, &(__ctx)->kflags)
+#define ckpt_test_and_set_ctx_kflag(__ctx, __kflag)  \
+	test_and_set_bit(__kflag##_BIT, &(__ctx)->kflags)
+
+#define ckpt_test_error(ctx)  \
+	((ctx)->kflags & CKPT_CTX_ERROR)
+#define ckpt_test_complete(ctx)  \
+	((ctx)->kflags & (CKPT_CTX_SUCCESS | CKPT_CTX_ERROR))
+
+extern void ckpt_set_success(struct ckpt_ctx *ctx);
+extern void ckpt_set_error(struct ckpt_ctx *ctx, int err);
+
+static inline int ckpt_get_error(struct ckpt_ctx *ctx)
+{
+	/*
+	 * We may notice CKPT_CTX_ERROR before ctx->errno is set, but
+	 * ctx->errno_sync remains not-completed until after it's done.
+	 */
+	wait_for_completion(&ctx->errno_sync);
+	return ctx->errno;
+}
+
+extern void restore_notify_error(struct ckpt_ctx *ctx);
+
+extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
+extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
+
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
@@ -108,6 +146,8 @@ static inline int ckpt_validate_errno(int errno)
 #endif
 
 #ifdef CONFIG_CHECKPOINT_DEBUG
+
+extern void restore_debug_free(struct ckpt_ctx *ctx);
 extern unsigned long ckpt_debug_level;
 
 /*
@@ -133,6 +173,8 @@ extern unsigned long ckpt_debug_level;
 
 #else
 
+static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
+
 /*
  * This is deprecated
  */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index a66c603..afe76ad 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -16,6 +16,7 @@
 #include <linux/nsproxy.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
+#include <linux/wait.h>
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
@@ -36,17 +37,36 @@ struct ckpt_ctx {
 	struct file *logfile;	/* status/debug log file */
 	loff_t total;		/* total read/written */
 
-	struct task_struct **tasks_arr;	/* array of all tasks in container */
-	int nr_tasks;			/* size of tasks array */
+	atomic_t refcount;
 
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
 
+	int errno;		/* errno that caused failure */
+	struct completion errno_sync;	/* protect errno setting */
+
+	/* [multi-process checkpoint] */
+	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
+	int nr_tasks;                   /* size of tasks array */
+
+	/* [multi-process restart] */
+	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
+	int nr_pids;			/* size of pids array */
+	atomic_t nr_total;		/* total tasks count */
+	int active_pid;			/* (next) position in pids array */
+	struct completion complete;	/* container root and other tasks on */
+	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+
 #define CKPT_MSG_LEN 1024
 	char fmt[CKPT_MSG_LEN];
 	char msg[CKPT_MSG_LEN];
 	int msglen;
 	struct mutex msg_mutex;
+
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	struct list_head task_status;   /* list of status for each task */
+	spinlock_t lock;
+#endif
 };
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index bcc44ad..a70d7d1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -691,6 +691,10 @@ struct signal_struct {
 #endif
 
 	int oom_adj;	/* OOM kill score adjustment (bit shift) */
+
+#ifdef CONFIG_CHECKPOINT
+	atomic_t restart_count;		/* threads group restart sync */
+#endif
 };
 
 /* Context switch must be unlocked if interrupts are to be enabled */
@@ -1578,6 +1582,9 @@ struct task_struct {
 		unsigned long memsw_bytes; /* uncharged mem+swap usage */
 	} memcg_batch;
 #endif
+#ifdef CONFIG_CHECKPOINT
+	struct ckpt_ctx *checkpoint_ctx;
+#endif
 };
 
 /* Future-safe accessor for struct task_struct's cpus_allowed. */
@@ -1771,6 +1778,7 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
 #define PF_EXITING	0x00000004	/* getting shut down */
 #define PF_EXITPIDONE	0x00000008	/* pi exit done on shut down */
 #define PF_VCPU		0x00000010	/* I'm a virtual CPU */
+#define PF_RESTARTING	0x00000020	/* Process is restarting (c/r) */
 #define PF_FORKNOEXEC	0x00000040	/* forked but didn't exec */
 #define PF_MCE_PROCESS  0x00000080      /* process policy on mce errors */
 #define PF_SUPERPRIV	0x00000100	/* used super-user privileges */
@@ -2272,7 +2280,7 @@ static inline int task_detached(struct task_struct *p)
  * Protects ->fs, ->files, ->mm, ->group_info, ->comm, keyring
  * subscriptions and synchronises with wait4().  Also used in procfs.  Also
  * pins the final release of task.io_context.  Also protects ->cpuset and
- * ->cgroup.subsys[].
+ * ->cgroup.subsys[]. Also protects ->checkpoint_ctx in checkpoint/restart.
  *
  * Nests both inside and outside of read_lock(&tasklist_lock).
  * It must not be nested with write_lock_irq(&tasklist_lock),
diff --git a/kernel/exit.c b/kernel/exit.c
index 546774a..f8eb8bb 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -50,6 +50,7 @@
 #include <linux/perf_event.h>
 #include <trace/events/sched.h>
 #include <linux/hw_breakpoint.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -1000,6 +1001,10 @@ NORET_TYPE void do_exit(long code)
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
index 0f202ae..4eb8e7e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -65,6 +65,7 @@
 #include <linux/perf_event.h>
 #include <linux/posix-timers.h>
 #include <linux/user-return-notifier.h>
+#include <linux/checkpoint.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -1246,6 +1247,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	/* Need tasklist lock for parent etc handling! */
 	write_lock_irq(&tasklist_lock);
 
+#ifdef CONFIG_CHECKPOINT
+	/* If parent is restarting, child should be too */
+	if (unlikely(current->checkpoint_ctx))
+		p->checkpoint_ctx = ckpt_ctx_get(current->checkpoint_ctx);
+#endif
+
 	/* CLONE_PARENT re-uses the old parent */
 	if (clone_flags & (CLONE_PARENT|CLONE_THREAD)) {
 		p->real_parent = current->real_parent;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
