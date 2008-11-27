From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v10][PATCH 12/13] Checkpoint multiple processes
Date: Wed, 26 Nov 2008 20:04:43 -0500
Message-Id: <1227747884-14150-13-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpointing of multiple processes works by recording the tasks tree
structure below a given task (usually this task is the container init).

For a given task, do a DFS scan of the tasks tree and collect them
into an array (keeping a reference to each task). Using DFS simplifies
the recreation of tasks either in user space or kernel space. For each
task collected, test if it can be checkpointed, and save its pid, tgid,
and ppid.

The actual work is divided into two passes: a first scan counts the
tasks, then memory is allocated and a second scan fills the array.

The logic is suitable for creation of processes during restart either
in userspace or by the kernel.

Currently we ignore threads and zombies, as well as session ids.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c        |  228 +++++++++++++++++++++++++++++++++++++---
 checkpoint/sys.c               |   16 +++
 include/linux/checkpoint.h     |    3 +
 include/linux/checkpoint_hdr.h |   13 ++-
 4 files changed, 243 insertions(+), 17 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 3d0a366..b0a757b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -225,19 +225,6 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
 	int ret;
 
-	/* TODO: verity that the task is frozen (unless self) */
-
-	if (t->state == TASK_DEAD) {
-		pr_warning("c/r: task may not be in state TASK_DEAD\n");
-		return -EAGAIN;
-	}
-
-	if (!atomic_read(&t->may_checkpoint)) {
-		pr_warning("c/r: task %d may not checkpoint\n",
-			   task_pid_vnr(t));
-		return -EBUSY;
-	}
-
 	ret = cr_write_task_struct(ctx, t);
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
@@ -260,6 +247,205 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+/* dump all tasks in ctx->tasks_arr[] */
+static int cr_write_all_tasks(struct cr_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->tasks_nr; n++) {
+		cr_debug("dumping task #%d\n", n);
+		ret = cr_write_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
+static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
+{
+	cr_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
+
+	if (t->state == TASK_DEAD) {
+		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+		return -EAGAIN;
+	}
+
+	if (!atomic_read(&t->may_checkpoint)) {
+		pr_warning("c/r: task %d uncheckpointable\n", task_pid_vnr(t));
+		return -EBUSY;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_READ))
+		return -EPERM;
+
+	/* FIXME: verify that the task is frozen (unless self) */
+
+	/* FIXME: change this for nested containers */
+	if (task_nsproxy(t) != ctx->root_nsproxy)
+		return -EPERM;
+
+	return 0;
+}
+
+#define CR_HDR_PIDS_CHUNK	256
+
+static int cr_write_pids(struct cr_ctx *ctx)
+{
+	struct cr_hdr_pids *hh;
+	struct pid_namespace *ns;
+	struct task_struct *task;
+	struct task_struct **tasks_arr;
+	int tasks_nr, n, ret = 0, pos = 0;
+
+	ns = ctx->root_nsproxy->pid_ns;
+	tasks_arr = ctx->tasks_arr;
+	tasks_nr = ctx->tasks_nr;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh) * CR_HDR_PIDS_CHUNK);
+
+	while (tasks_nr > 0) {
+		rcu_read_lock();
+		for (n = min(tasks_nr, CR_HDR_PIDS_CHUNK); n; n--) {
+			task = tasks_arr[pos];
+
+			/* is this task cool ? */
+			ret = cr_may_checkpoint_task(task, ctx);
+			if (ret < 0) {
+				rcu_read_unlock();
+				goto out;
+			}
+			hh[pos].vpid = task_pid_nr_ns(task, ns);
+			hh[pos].vtgid = task_tgid_nr_ns(task, ns);
+			hh[pos].vppid = task_tgid_nr_ns(task->real_parent, ns);
+			cr_debug("task[%d]: vpid %d vtgid %d parent %d\n", pos,
+				 hh[pos].vpid, hh[pos].vtgid, hh[pos].vppid);
+			pos++;
+		}
+		rcu_read_unlock();
+
+		n = min(tasks_nr, CR_HDR_PIDS_CHUNK);
+		ret = cr_kwrite(ctx, hh, n * sizeof(*hh));
+		if (ret < 0)
+			break;
+
+		tasks_nr -= n;
+	}
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+/* count number of tasks in tree (and optionally fill pid's in array) */
+static int cr_tree_count_tasks(struct cr_ctx *ctx)
+{
+	struct task_struct *root = ctx->root_task;
+	struct task_struct *task = root;
+	struct task_struct *parent = NULL;
+	struct task_struct **tasks_arr = ctx->tasks_arr;
+	int tasks_nr = ctx->tasks_nr;
+	int nr = 0;
+
+	read_lock(&tasklist_lock);
+
+	/* count tasks via DFS scan of the tree */
+	while (1) {
+		if (tasks_arr) {
+			/* unlikely, but ... */
+			if (nr == tasks_nr)
+				return -EBUSY;	/* cleanup in cr_ctx_free() */
+			tasks_arr[nr] = task;
+			get_task_struct(task);
+		}
+
+		nr++;
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
+		if (task == root)
+			break;
+	}
+
+	read_unlock(&tasklist_lock);
+	return nr;
+}
+
+/*
+ * cr_build_tree - scan the tasks tree in DFS order and fill in array
+ * @ctx: checkpoint context
+ *
+ * Using DFS order simplifies the restart logic to re-create the tasks.
+ *
+ * On success, ctx->tasks_arr will be allocated and populated with all
+ * tasks (reference taken), and ctx->tasks_nr will hold the total count.
+ * The array is cleaned up by cr_ctx_free().
+ */
+static int cr_build_tree(struct cr_ctx *ctx)
+{
+	int n, m;
+
+	/* count tasks (no side effects) */
+	n = cr_tree_count_tasks(ctx);
+
+	ctx->tasks_nr = n;
+	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
+	if (!ctx->tasks_arr)
+		return -ENOMEM;
+
+	/* count again (now will fill array) */
+	m = cr_tree_count_tasks(ctx);
+
+	/* unlikely, but ... (cleanup in cr_ctx_free) */
+	if (m < 0)
+		return m;
+	else if (m != n)
+		return -EBUSY;
+
+	return 0;
+}
+
+/* dump the array that describes the tasks tree */
+static int cr_write_tree(struct cr_ctx *ctx)
+{
+	struct cr_hdr h;
+	struct cr_hdr_tree *hh;
+	int ret;
+
+	h.type = CR_HDR_TREE;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	hh->tasks_nr = ctx->tasks_nr;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	ret = cr_write_pids(ctx);
+	return ret;
+}
+
 static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task = NULL;
@@ -277,7 +463,7 @@ static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
 	if (!task)
 		goto out;
 
-#if 0	/* enable to use containers */
+#if 0	/* enable with containers */
 	if (!is_container_init(task)) {
 		err = -EINVAL;
 		goto out;
@@ -299,7 +485,7 @@ static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
 	if (!nsproxy)
 		goto out;
 
-	/* TODO: verify that the container is frozen */
+	/* FIXME: verify that the container is frozen */
 
 	ctx->root_task = task;
 	ctx->root_nsproxy = nsproxy;
@@ -342,12 +528,22 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	ret = cr_ctx_checkpoint(ctx, pid);
 	if (ret < 0)
 		goto out;
+
+	ret = cr_build_tree(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_task(ctx, ctx->root_task);
+	ret = cr_write_tree(ctx);
 	if (ret < 0)
 		goto out;
+
+	ret = cr_write_all_tasks(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = cr_write_tail(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index dfe63ca..fbaf683 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -130,6 +130,19 @@ void cr_hbuf_put(struct cr_ctx *ctx, int n)
  * restart operation, and persists until the operation is completed.
  */
 
+static void cr_task_arr_free(struct cr_ctx *ctx)
+{
+	int n;
+
+	for (n = 0; n < ctx->tasks_nr; n++) {
+		if (ctx->tasks_arr[n]) {
+			put_task_struct(ctx->tasks_arr[n]);
+			ctx->tasks_arr[n] = NULL;
+		}
+	}
+	kfree(ctx->tasks_arr);
+}
+
 static void cr_ctx_free(struct cr_ctx *ctx)
 {
 	if (ctx->file)
@@ -143,6 +156,9 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
 
+	if (ctx->tasks_arr)
+		cr_task_arr_free(ctx);
+
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index fc1873b..ac330f5 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -34,6 +34,9 @@ struct cr_ctx {
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
 
+	struct task_struct **tasks_arr;	/* array of all tasks in container */
+	int tasks_nr;			/* size of tasks array */
+
 	struct cr_objhash *objhash;	/* hash for shared objects */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e92c37d..7ae2a77 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -36,7 +36,8 @@ enum {
 	CR_HDR_STRING,
 	CR_HDR_FNAME,
 
-	CR_HDR_TASK = 101,
+	CR_HDR_TREE = 101,
+	CR_HDR_TASK,
 	CR_HDR_THREAD,
 	CR_HDR_CPU,
 
@@ -72,6 +73,16 @@ struct cr_hdr_tail {
 	__u64 magic;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_tree {
+	__u32 tasks_nr;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_pids {
+	__s32 vpid;
+	__s32 vtgid;
+	__s32 vppid;
+} __attribute__((aligned(8)));
+
 struct cr_hdr_task {
 	__u32 state;
 	__u32 exit_state;
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
