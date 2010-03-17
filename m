Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 097776B0214
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:08 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 29/96] c/r: checkpoint multiple processes
Date: Wed, 17 Mar 2010 12:08:17 -0400
Message-Id: <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpointing of multiple processes works by recording the tasks tree
structure below a given "root" task. The root task is expected to be a
container init, and then an entire container is checkpointed. However,
passing CHECKPOINT_SUBTREE to checkpoint(2) relaxes this requirement
and allows to checkpoint a subtree of processes from the root task.

For a given root task, do a DFS scan of the tasks tree and collect them
into an array (keeping a reference to each task). Using DFS simplifies
the recreation of tasks either in user space or kernel space. For each
task collected, test if it can be checkpointed, and save its pid, tgid,
and ppid.

The actual work is divided into two passes: a first scan counts the
tasks, then memory is allocated and a second scan fills the array.

Whether checkpoints and restarts require CAP_SYS_ADMIN is determined
by sysctl 'ckpt_unpriv_allowed': if 1, then regular permission checks
are intended to prevent privilege escalation, however if 0 it prevents
unprivileged users from exploiting any privilege escalation bugs.

The logic is suitable for creation of processes during restart either
in userspace or by the kernel.

Currently we ignore threads and zombies.

Changelog[v20]:
  - [Serge Hallyn] Change sysctl and default for unprivileged use
Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33 (fix sysctl entry for ckpt_unpriv_allowed)
Changelog[v19-rc1]:
  - Introduce walk_task_subtree() to iterate through descendants
  - [Matt Helsley] Add cpp definitions for enums
  - [Serge Hallyn] Add global section container to image format
Changelog[v18]:
  - Replace some EAGAIN with EBUSY
  - Add a few more ckpt_write_err()s
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*
Changelog[v16]:
  - CHECKPOINT_SUBTREE flags allows subtree (not whole container)
  - sysctl variable 'ckpt_unpriv_allowed' controls needed privileges
Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen
  - Refuse checkpoint (for now) if task is ptraced
  - Revert change to pr_debug(), back to ckpt_debug()
  - Use only unsigned fields in checkpoint headers
  - Check retval of ckpt_tree_count_tasks() in ckpt_build_tree()
  - Discard 'h.parent' field
  - Check whether calls to ckpt_hbuf_get() fail
  - Disallow threads or siblings to container init
Changelog[v13]:
  - Release tasklist_lock in error path in ckpt_tree_count_tasks()
  - Use separate index for 'tasks_arr' and 'hh' in ckpt_write_pids()
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c          |  271 ++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c             |    2 +-
 checkpoint/sys.c                 |  108 +++++++++++++++-
 include/linux/checkpoint.h       |   10 ++
 include/linux/checkpoint_hdr.h   |   18 +++-
 include/linux/checkpoint_types.h |    4 +
 kernel/sysctl.c                  |   16 +++
 7 files changed, 411 insertions(+), 18 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index e25b9b7..ba566b0 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -197,8 +197,27 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* dump all tasks in ctx->tasks_arr[] */
+static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = checkpoint_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
 static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
+	struct task_struct *root = ctx->root_task;
+
+	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
+
 	if (t->state == TASK_DEAD) {
 		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
 		return -EBUSY;
@@ -221,15 +240,234 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EBUSY;
 	}
 
+	/*
+	 * FIX: for now, disallow siblings of container init created
+	 * via CLONE_PARENT (unclear if they will remain possible)
+	 */
+	if (ctx->root_init && t != root && t->tgid != root->tgid &&
+	    t->real_parent == root->real_parent) {
+		_ckpt_err(ctx, -EINVAL, "%(T)Task is sibling of root\n");
+		return -EINVAL;
+	}
+
+	/* FIX: change this when namespaces are added */
+	if (task_nsproxy(t) != ctx->root_nsproxy)
+		return -EPERM;
+
 	return 0;
 }
 
+#define CKPT_HDR_PIDS_CHUNK	256
+
+static int checkpoint_pids(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pids *h;
+	struct pid_namespace *ns;
+	struct task_struct *task;
+	struct task_struct **tasks_arr;
+	int nr_tasks, n, pos = 0, ret = 0;
+
+	ns = ctx->root_nsproxy->pid_ns;
+	tasks_arr = ctx->tasks_arr;
+	nr_tasks = ctx->nr_tasks;
+	BUG_ON(nr_tasks <= 0);
+
+	ret = ckpt_write_obj_type(ctx, NULL,
+				  sizeof(*h) * nr_tasks,
+				  CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	if (!h)
+		return -ENOMEM;
+
+	do {
+		rcu_read_lock();
+		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
+			task = tasks_arr[pos];
+
+			h[n].vpid = task_pid_nr_ns(task, ns);
+			h[n].vtgid = task_tgid_nr_ns(task, ns);
+			h[n].vpgid = task_pgrp_nr_ns(task, ns);
+			h[n].vsid = task_session_nr_ns(task, ns);
+			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
+			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
+				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
+			pos++;
+		}
+		rcu_read_unlock();
+
+		n = min(nr_tasks, CKPT_HDR_PIDS_CHUNK);
+		ret = ckpt_kwrite(ctx, h, n * sizeof(*h));
+		if (ret < 0)
+			break;
+
+		nr_tasks -= n;
+	} while (nr_tasks > 0);
+
+	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	return ret;
+}
+
+struct ckpt_cnt_tasks {
+	struct ckpt_ctx *ctx;
+	int nr;
+};
+
+/* count number of tasks in tree (and optionally fill pid's in array) */
+static int __tree_count_tasks(struct task_struct *task, void *data)
+{
+	struct ckpt_cnt_tasks *d = (struct ckpt_cnt_tasks *) data;
+	struct ckpt_ctx *ctx = d->ctx;
+	int ret;
+
+	ctx->tsk = task;  /* (for _ckpt_err()) */
+
+	/* is this task cool ? */
+	ret = may_checkpoint_task(ctx, task);
+	if (ret < 0)
+		goto out;
+
+	if (ctx->tasks_arr) {
+		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
+			_ckpt_err(ctx, -EBUSY, "%(T)Bad task count (%d)\n",
+				  d->nr);
+			ret = -EBUSY;
+			goto out;
+		}
+		ctx->tasks_arr[d->nr++] = task;
+		get_task_struct(task);
+	}
+
+	ret = 1;
+ out:
+	ctx->tsk = NULL;
+	return ret;
+}
+
+static int tree_count_tasks(struct ckpt_ctx *ctx)
+{
+	struct ckpt_cnt_tasks data;
+	int ret;
+
+	data.ctx = ctx;
+	data.nr = 0;
+
+	ckpt_msg_lock(ctx);
+	ret = walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
+	ckpt_msg_unlock(ctx);
+	if (ret < 0)
+		_ckpt_msg_complete(ctx);
+	return ret;
+}
+
+/*
+ * build_tree - scan the tasks tree in DFS order and fill in array
+ * @ctx: checkpoint context
+ *
+ * Using DFS order simplifies the restart logic to re-create the tasks.
+ *
+ * On success, ctx->tasks_arr will be allocated and populated with all
+ * tasks (reference taken), and ctx->nr_tasks will hold the total count.
+ * The array is cleaned up by ckpt_ctx_free().
+ */
+static int build_tree(struct ckpt_ctx *ctx)
+{
+	int n, m;
+
+	/* count tasks (no side effects) */
+	n = tree_count_tasks(ctx);
+	if (n < 0)
+		return n;
+
+	ctx->nr_tasks = n;
+	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
+	if (!ctx->tasks_arr)
+		return -ENOMEM;
+
+	/* count again (now will fill array) */
+	m = tree_count_tasks(ctx);
+
+	/* unlikely, but ... (cleanup in ckpt_ctx_free) */
+	if (m < 0)
+		return m;
+	else if (m != n)
+		return -EBUSY;
+
+	return 0;
+}
+
+/* dump the array that describes the tasks tree */
+static int checkpoint_tree(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tree *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
+	if (!h)
+		return -ENOMEM;
+
+	h->nr_tasks = ctx->nr_tasks;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_pids(ctx);
+	return ret;
+}
+
+static struct task_struct *get_freezer_task(struct task_struct *root_task)
+{
+	struct task_struct *p;
+
+	/*
+	 * For the duration of checkpoint we deep-freeze all tasks.
+	 * Normally do it through the root task's freezer cgroup.
+	 * However, if the root task is also the current task (doing
+	 * self-checkpoint) we can't freeze ourselves. In this case,
+	 * choose the next available (non-dead) task instead. We'll
+	 * use its freezer cgroup to verify that all tasks belong to
+	 * the same cgroup.
+	 */
+
+	if (root_task != current) {
+		get_task_struct(root_task);
+		return root_task;
+	}
+
+	/* search among threads, then children */
+	read_lock(&tasklist_lock);
+
+	for (p = next_thread(root_task); p != root_task; p = next_thread(p)) {
+		if (p->state == TASK_DEAD)
+			continue;
+		if (!in_same_cgroup_freezer(p, root_task))
+			goto out;
+	}
+
+	list_for_each_entry(p, &root_task->children, sibling) {
+		if (p->state == TASK_DEAD)
+			continue;
+		if (!in_same_cgroup_freezer(p, root_task))
+			goto out;
+	}
+
+	p = NULL;
+ out:
+	read_unlock(&tasklist_lock);
+	if (p)
+		get_task_struct(p);
+	return p;
+}
+
 /* setup checkpoint-specific parts of ctx */
 static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task;
 	struct nsproxy *nsproxy;
-	int ret;
 
 	/*
 	 * No need for explicit cleanup here, because if an error
@@ -261,18 +499,14 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 		ctx->root_nsproxy = nsproxy;
 
 	/* root freezer */
-	ctx->root_freezer = task;
-	geT_task_struct(task);
+	ctx->root_freezer = get_freezer_task(task);
 
-	ret = may_checkpoint_task(ctx, task);
-	if (ret) {
-		_ckpt_msg_complete(ctx);
-		put_task_struct(task);
-		put_task_struct(task);
-		put_nsproxy(nsproxy);
-		ctx->root_nsproxy = NULL;
-		ctx->root_task = NULL;
-		return ret;
+	/* container init ? */
+	ctx->root_init = is_container_init(task);
+
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
+		ckpt_err(ctx, -EINVAL, "Not container init\n");
+		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
 	return 0;
@@ -288,17 +522,26 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (ctx->root_freezer) {
 		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "Freezer cgroup failed\n");
 			return ret;
+		}
 	}
 
+	ret = build_tree(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_container(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, ctx->root_task);
+	ret = checkpoint_tree(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 360c41e..3e898e7 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -382,7 +382,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		ckpt_err(ctx, ret, "incompatible kernel version");
 		goto out;
 	}
-	if (h->uflags) {
+	if (h->uflags & ~CHECKPOINT_USER_FLAGS) {
 		ckpt_err(ctx, ret, "incompatible restart user flags");
 		goto out;
 	}
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d858096..d0eed25 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -23,6 +23,16 @@
 #include <linux/checkpoint.h>
 
 /*
+ * ckpt_unpriv_allowed - sysctl controlled.
+ *   If 0, then caller of sys_checkpoint() or sys_restart() must have
+ *	CAP_SYS_ADMIN
+ *   If 1, then only sys_restart() requires CAP_SYS_ADMIN.
+ *   If 2, then both can be called without privilege - regular permissions
+ *	checks are intended to do the job.
+ */
+int ckpt_unpriv_allowed = 1;	/* default: unpriv checkpoint not restart */
+
+/*
  * Helpers to write(read) from(to) kernel space to(from) the checkpoint
  * image file descriptor (similar to how a core-dump is performed).
  *
@@ -169,6 +179,19 @@ EXPORT_SYMBOL(ckpt_hdr_get_type);
  * restart operation, and persists until the operation is completed.
  */
 
+static void task_arr_free(struct ckpt_ctx *ctx)
+{
+	int n;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		if (ctx->tasks_arr[n]) {
+			put_task_struct(ctx->tasks_arr[n]);
+			ctx->tasks_arr[n] = NULL;
+		}
+	}
+	kfree(ctx->tasks_arr);
+}
+
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	if (ctx->file)
@@ -176,6 +199,9 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->logfile)
 		fput(ctx->logfile);
 
+	if (ctx->tasks_arr)
+		task_arr_free(ctx);
+
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
@@ -417,6 +443,79 @@ void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
 }
 EXPORT_SYMBOL(do_ckpt_msg);
 
+/**
+ * walk_task_subtree: iterate through a task's descendants
+ * @root: subtree root task
+ * @func: callback invoked on each task
+ * @data: pointer passed to the callback
+ *
+ * The function will start with @root, and iterate through all the
+ * descendants, including threads, in a DFS manner. Children of a task
+ * are traversed before proceeding to the next thread of that task.
+ *
+ * For each task, the callback @func will be called providing the task
+ * pointer and the @data. The callback is invoked while holding the
+ * tasklist_lock for reading. If the callback fails it should return a
+ * negative error, and the traversal ends. If the callback succeeds,
+ * it returns a non-negative number, and these values are summed.
+ *
+ * On success, walk_task_subtree() returns the total summed. On
+ * failure, it returns a negative value.
+ */
+int walk_task_subtree(struct task_struct *root,
+		      int (*func)(struct task_struct *, void *),
+		      void *data)
+{
+
+	struct task_struct *leader = root;
+	struct task_struct *parent = NULL;
+	struct task_struct *task = root;
+	int total = 0;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	while (1) {
+		/* invoke callback on this task */
+		ret = func(task, data);
+		if (ret < 0)
+			break;
+
+		total += ret;
+
+		/* if has children - proceed with child */
+		if (!list_empty(&task->children)) {
+			parent = task;
+			task = list_entry(task->children.next,
+					  struct task_struct, sibling);
+			continue;
+		}
+
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
+
+		if (task == root) {
+			/* in case root task is multi-threaded */
+			root = task = next_thread(task);
+			if (root == leader)
+				break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	ckpt_debug("total %d ret %d\n", total, ret);
+	return (ret < 0 ? ret : total);
+}
+
 /* checkpoint/restart syscalls */
 
 /**
@@ -434,10 +533,12 @@ long do_sys_checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	struct ckpt_ctx *ctx;
 	long ret;
 
-	/* no flags for now */
-	if (flags)
+	if (flags & ~CHECKPOINT_USER_FLAGS)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	if (pid == 0)
 		pid = task_pid_vnr(current);
 	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT, logfd);
@@ -472,6 +573,9 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 	if (flags)
 		return -EINVAL;
 
+	if (ckpt_unpriv_allowed < 2 && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART, logfd);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8cb6130..30f5353 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -12,6 +12,9 @@
 
 #define CHECKPOINT_VERSION  3
 
+/* checkpoint user flags */
+#define CHECKPOINT_SUBTREE	0x1
+
 /* misc user visible */
 #define CHECKPOINT_FD_NONE	-1
 
@@ -35,6 +38,13 @@ extern long do_sys_restart(pid_t pid, int fd,
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
 
+/* ckpt_ctx: uflags */
+#define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+
+
+extern int walk_task_subtree(struct task_struct *task,
+			     int (*func)(struct task_struct *, void *),
+			     void *data);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 24e880f..083f5d3 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -65,7 +65,9 @@ enum {
 	CKPT_HDR_STRING,
 #define CKPT_HDR_STRING CKPT_HDR_STRING
 
-	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TREE = 101,
+#define CKPT_HDR_TREE CKPT_HDR_TREE
+	CKPT_HDR_TASK,
 #define CKPT_HDR_TASK CKPT_HDR_TASK
 	CKPT_HDR_RESTART_BLOCK,
 #define CKPT_HDR_RESTART_BLOCK CKPT_HDR_RESTART_BLOCK
@@ -137,6 +139,20 @@ struct ckpt_hdr_container {
 	struct ckpt_hdr h;
 } __attribute__((aligned(8)));;
 
+/* task tree */
+struct ckpt_hdr_tree {
+	struct ckpt_hdr h;
+	__s32 nr_tasks;
+} __attribute__((aligned(8)));
+
+struct ckpt_pids {
+	__s32 vpid;
+	__s32 vppid;
+	__s32 vtgid;
+	__s32 vpgid;
+	__s32 vsid;
+} __attribute__((aligned(8)));
+
 /* task data */
 struct ckpt_hdr_task {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 6420a3b..a66c603 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -22,6 +22,7 @@ struct ckpt_ctx {
 
 	ktime_t ktime_begin;	/* checkpoint start time */
 
+	int root_init;				/* [container] root init ? */
 	pid_t root_pid;				/* [container] root pid */
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
@@ -35,6 +36,9 @@ struct ckpt_ctx {
 	struct file *logfile;	/* status/debug log file */
 	loff_t total;		/* total read/written */
 
+	struct task_struct **tasks_arr;	/* array of all tasks in container */
+	int nr_tasks;			/* size of tasks array */
+
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8a68b24..8443bb0 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -204,6 +204,10 @@ int sysctl_legacy_va_layout;
 extern int prove_locking;
 extern int lock_stat;
 
+#ifdef CONFIG_CHECKPOINT
+extern int ckpt_unpriv_allowed;
+#endif
+
 /* The default sysctl tables: */
 
 static struct ctl_table root_table[] = {
@@ -936,6 +940,18 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_CHECKPOINT
+	{
+		.procname	= "ckpt_unpriv_allowed",
+		.data		= &ckpt_unpriv_allowed,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &two,
+	},
+#endif
+
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
