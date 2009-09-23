Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA02F6B00A4
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:37 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 25/80] c/r: checkpoint multiple processes
Date: Wed, 23 Sep 2009 19:51:05 -0400
Message-Id: <1253749920-18673-26-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
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
---
 checkpoint/checkpoint.c          |  295 ++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c             |    2 +-
 checkpoint/sys.c                 |   33 ++++-
 include/linux/checkpoint.h       |    6 +
 include/linux/checkpoint_hdr.h   |   16 ++-
 include/linux/checkpoint_types.h |    4 +
 kernel/sysctl.c                  |   17 +++
 7 files changed, 355 insertions(+), 18 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 554400c..fc02436 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -356,8 +356,27 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
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
 		__ckpt_write_err(ctx, "TE", "task state EXIT_DEAD\n", -EBUSY);
 		return -EBUSY;
@@ -380,15 +399,258 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EBUSY;
 	}
 
+	/*
+	 * FIX: for now, disallow siblings of container init created
+	 * via CLONE_PARENT (unclear if they will remain possible)
+	 */
+	if (ctx->root_init && t != root && t->tgid != root->tgid &&
+	    t->real_parent == root->real_parent) {
+		__ckpt_write_err(ctx, "TE", "task is sibling of root", -EINVAL);
+		return -EINVAL;
+	}
+
+	/* FIX: change this when namespaces are added */
+	if (task_nsproxy(t) != ctx->root_nsproxy)
+		return -EPERM;
+
+	return 0;
+}
+
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
+/* count number of tasks in tree (and optionally fill pid's in array) */
+static int tree_count_tasks(struct ckpt_ctx *ctx)
+{
+	struct task_struct *root;
+	struct task_struct *task;
+	struct task_struct *parent;
+	struct task_struct **tasks_arr = ctx->tasks_arr;
+	int nr_tasks = ctx->nr_tasks;
+	int nr = 0;
+	int ret;
+
+	read_lock(&tasklist_lock);
+
+	/* we hold the lock, so root_task->real_parent can't change */
+	task = ctx->root_task;
+	if (ctx->root_init) {
+		/* container-init: start from container parent */
+		parent = task->real_parent;
+		root = parent;
+	} else {
+		/* non-container-init: start from root task and down */
+		parent = NULL;
+		root = task;
+	}
+
+	/* count tasks via DFS scan of the tree */
+	while (1) {
+		ctx->tsk = task;  /* (for ckpt_write_err) */
+
+		/* is this task cool ? */
+		ret = may_checkpoint_task(ctx, task);
+		if (ret < 0) {
+			nr = ret;
+			break;
+		}
+		if (tasks_arr) {
+			/* unlikely... but if so then try again later */
+			if (nr == nr_tasks) {
+				nr = -EBUSY; /* cleanup in ckpt_ctx_free() */
+				break;
+			}
+			tasks_arr[nr] = task;
+			get_task_struct(task);
+		}
+		nr++;
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
+		if (task == root)
+			break;
+	}
+	ctx->tsk = NULL;
+
+	read_unlock(&tasklist_lock);
+
+	if (nr < 0)
+		ckpt_write_err(ctx, "", NULL);
+	return nr;
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
 	return 0;
 }
 
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
@@ -420,18 +682,14 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 		ctx->root_nsproxy = nsproxy;
 
 	/* root freezer */
-	ctx->root_freezer = task;
-	geT_task_struct(task);
+	ctx->root_freezer = get_freezer_task(task);
 
-	ret = may_checkpoint_task(ctx, task);
-	if (ret) {
-		ckpt_write_err(ctx, "", NULL);
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
+		ckpt_write_err(ctx, "E", "not container init", -EINVAL);
+		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
 	return 0;
@@ -447,14 +705,23 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (ctx->root_freezer) {
 		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_write_err(ctx, "E", "freezer cgroup failed", ret);
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
-	ret = checkpoint_task(ctx, ctx->root_task);
+	ret = checkpoint_tree(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index fdad264..3f22403 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -364,7 +364,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
 	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
 		goto out;
-	if (h->uflags)
+	if (h->uflags & ~CHECKPOINT_USER_FLAGS)
 		goto out;
 
 	ret = check_kernel_const(&h->constants);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b37bc8c..cc94775 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -23,6 +23,14 @@
 #include <linux/checkpoint.h>
 
 /*
+ * ckpt_unpriv_allowed - sysctl controlled, do not allow checkpoints or
+ * restarts unless caller has CAP_SYS_ADMIN, if 0 (prevent unprivileged
+ * useres from expoitling any privilege escalation bugs). If it is 1,
+ * then regular permissions checks are intended to do the job.
+ */
+int ckpt_unpriv_allowed = 1;	/* default: allow */
+
+/*
  * Helpers to write(read) from(to) kernel space to(from) the checkpoint
  * image file descriptor (similar to how a core-dump is performed).
  *
@@ -166,11 +174,27 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
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
 		fput(ctx->file);
 
+	if (ctx->tasks_arr)
+		task_arr_free(ctx);
+
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
@@ -220,10 +244,12 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
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
 	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_CHECKPOINT);
@@ -257,6 +283,9 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	if (flags)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 14c0a7f..a4650bb 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -12,6 +12,9 @@
 
 #define CHECKPOINT_VERSION  2
 
+/* checkpoint user flags */
+#define CHECKPOINT_SUBTREE	0x1
+
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
 
@@ -26,6 +29,9 @@
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
 
+/* ckpt_ctx: uflags */
+#define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, int count);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b72c59c..26e10fb 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -51,7 +51,8 @@ enum {
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
 
-	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TREE = 101,
+	CKPT_HDR_TASK,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
@@ -110,6 +111,19 @@ struct ckpt_hdr_tail {
 	__u64 magic;
 } __attribute__((aligned(8)));
 
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
 
 /* task data */
 struct ckpt_hdr_task {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 046bdc4..c3399b3 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -22,6 +22,7 @@ struct ckpt_ctx {
 
 	ktime_t ktime_begin;	/* checkpoint start time */
 
+	int root_init;				/* [container] root init ? */
 	pid_t root_pid;				/* [container] root pid */
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
@@ -34,6 +35,9 @@ struct ckpt_ctx {
 	struct file *file;	/* input/output file */
 	int total;		/* total read/written */
 
+	struct task_struct **tasks_arr;	/* array of all tasks in container */
+	int nr_tasks;			/* size of tasks array */
+
 	struct task_struct *tsk;/* checkpoint: current target task */
 	char err_string[256];	/* checkpoint: error string */
 };
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 58be760..3046e2c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -198,6 +198,10 @@ int sysctl_legacy_va_layout;
 extern int prove_locking;
 extern int lock_stat;
 
+#ifdef CONFIG_CHECKPOINT
+extern int ckpt_unpriv_allowed;
+#endif
+
 /* The default sysctl tables: */
 
 static struct ctl_table root_table[] = {
@@ -990,6 +994,19 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
+#ifdef CONFIG_CHECKPOINT
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "ckpt_unpriv_allowed",
+		.data		= &ckpt_unpriv_allowed,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
 
 /*
  * NOTE: do not add new entries to this table unless you have read
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
