Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A619C6B00B0
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:15 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 22/43] c/r: checkpoint multiple processes
Date: Wed, 27 May 2009 13:32:48 -0400
Message-Id: <1243445589-32388-23-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
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
 checkpoint/checkpoint.c          |  237 ++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c             |    2 +-
 checkpoint/sys.c                 |   33 +++++-
 include/linux/checkpoint_hdr.h   |   16 +++-
 include/linux/checkpoint_types.h |   16 ++-
 kernel/sysctl.c                  |   17 +++
 6 files changed, 305 insertions(+), 16 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 3999d80..92f219e 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -249,8 +249,27 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
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
 		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
 		return -EAGAIN;
@@ -276,14 +295,211 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EBUSY;
 	}
 
+	/*
+	 * FIX: for now, disallow siblings of container init created
+	 * via CLONE_PARENT (unclear if they will remain possible)
+	 */
+	if (ctx->root_init && t != root && t->tgid != root->tgid &&
+	    t->real_parent == root->real_parent) {
+		__ckpt_write_err(ctx, "task %d (%s) is sibling of root",
+				 task_pid_vnr(t), t->comm);
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
+	struct ckpt_hdr_pids *h;
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
+		/* is this task cool ? */
+		ret = may_checkpoint_task(ctx, task);
+		if (ret < 0) {
+			nr = ret;
+			break;
+		}
+		if (tasks_arr) {
+			/* unlikely... but if so then try again later */
+			if (nr == nr_tasks) {
+				nr = -EAGAIN; /* cleanup in ckpt_ctx_free() */
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
+
+	read_unlock(&tasklist_lock);
+
+	if (nr < 0)
+		ckpt_write_err(ctx, NULL);
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
 static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task = NULL;
 	struct nsproxy *nsproxy = NULL;
-	int ret;
 
 	ctx->root_pid = pid;
 
@@ -296,13 +512,6 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 	if (!task)
 		return -ESRCH;
 
-	ret = may_checkpoint_task(ctx, task);
-	if (ret) {
-		ckpt_write_err(ctx, NULL);
-		put_task_struct(task);
-		return ret;
-	}
-
 	rcu_read_lock();
 	nsproxy = task_nsproxy(task);
 	get_nsproxy(nsproxy);
@@ -310,6 +519,10 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 
 	ctx->root_task = task;
 	ctx->root_nsproxy = nsproxy;
+	ctx->root_init = is_container_init(task);
+
+	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init)
+		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 
 	return 0;
 }
@@ -349,10 +562,16 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = init_checkpoint_ctx(ctx, pid);
 	if (ret < 0)
 		goto out;
+	ret = build_tree(ctx);
+	if (ret < 0)
+		goto out;
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
index e5067a9..8b8229e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -304,7 +304,7 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
 	    h->patch != ((LINUX_VERSION_CODE) & 0xff))
 		goto out;
-	if (h->uflags)
+	if (h->uflags & ~CHECKPOINT_USER_FLAGS)
 		goto out;
 	if (h->uts_release_len != sizeof(uts->release) ||
 	    h->uts_version_len != sizeof(uts->version) ||
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 5b91a39..46eadf5 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -22,6 +22,14 @@
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
@@ -165,6 +173,19 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
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
@@ -174,6 +195,9 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	path_put(&ctx->fs_mnt);
 	ckpt_pgarr_free(ctx);
 
+	if (ctx->tasks_arr)
+		task_arr_free(ctx);
+
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
@@ -228,10 +252,12 @@ SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
 	struct ckpt_ctx *ctx;
 	int ret;
 
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
@@ -265,6 +291,9 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	if (flags)
 		return -EINVAL;
 
+	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 939f4e3..36328e1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -46,7 +46,8 @@ enum {
 	CKPT_HDR_STRING,
 	CKPT_HDR_OBJREF,
 
-	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TREE = 101,
+	CKPT_HDR_TASK,
 	CKPT_HDR_TASK_OBJS,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
@@ -125,6 +126,19 @@ struct ckpt_hdr_tail {
 	__u64 magic;
 } __attribute__((aligned(8)));
 
+/* task tree */
+struct ckpt_hdr_tree {
+	struct ckpt_hdr h;
+	__s32 nr_tasks;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_pids {
+	__s32 vpid;
+	__s32 vppid;
+	__s32 vtgid;
+	__s32 vpgid;
+	__s32 vsid;
+} __attribute__((aligned(8)));
 
 /* task data */
 struct ckpt_hdr_task {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 72052ef..d5db5c9 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -13,6 +13,9 @@
 #define CHECKPOINT_VERSION  1
 
 
+#define CHECKPOINT_SUBTREE	0x1
+
+
 #ifdef __KERNEL__
 struct ckpt_ctx;
 struct ckpt_hdr_file;
@@ -30,9 +33,10 @@ struct ckpt_ctx {
 
 	ktime_t ktime_begin;	/* checkpoint start time */
 
-	pid_t root_pid;		/* container identifier */
-	struct task_struct *root_task;	/* container root task */
-	struct nsproxy *root_nsproxy;	/* container root nsproxy */
+	int root_init;		/* is root a container init ? */
+	pid_t root_pid;		/* (container) root identifier */
+	struct task_struct *root_task;	/* (container) root task */
+	struct nsproxy *root_nsproxy;	/* (container) root nsproxy */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
@@ -41,6 +45,9 @@ struct ckpt_ctx {
 	struct file *file;	/* input/output file */
 	int total;		/* total read/written */
 
+	struct task_struct **tasks_arr;	/* array of all tasks in container */
+	int nr_tasks;			/* size of tasks array */
+
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 
 	struct path fs_mnt;     /* container root (FIXME) */
@@ -58,6 +65,9 @@ struct ckpt_ctx {
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
 
+/* ckpt ctx: uflags */
+#define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
+
 #endif /* __KERNEL__ */
 
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b2970d5..c476f7c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -194,6 +194,10 @@ int sysctl_legacy_va_layout;
 extern int prove_locking;
 extern int lock_stat;
 
+#ifdef CONFIG_CHECKPOINT
+extern int ckpt_unpriv_allowed;
+#endif
+
 /* The default sysctl tables: */
 
 static struct ctl_table root_table[] = {
@@ -912,6 +916,19 @@ static struct ctl_table kern_table[] = {
 		.child		= slow_work_sysctls,
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
  * Documentation/sysctl/ctl_unnumbered.txt
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
