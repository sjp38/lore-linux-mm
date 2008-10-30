From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 11/12] External checkpoint of a task other than ourself
Date: Thu, 30 Oct 2008 09:51:14 -0400
Message-Id: <1225374675-22850-12-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container.

sys_restart() remains the same, as the restart is always done in the
context of the restarting task.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c    |    4 ++-
 checkpoint/sys.c           |   71 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h |    5 ++-
 3 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ce622e1..f636958 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -190,6 +190,8 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
 	int ret ;
 
+	/* TODO: verity that the task is frozen (unless self) */
+
 	if (t->state == TASK_DEAD) {
 		pr_warning("C/R: task may not be in state TASK_DEAD\n");
 		return -EAGAIN;
@@ -227,7 +229,7 @@ int do_checkpoint(struct cr_ctx *ctx)
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_task(ctx, current);
+	ret = cr_write_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = cr_write_tail(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index c57ae96..3421d47 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -9,6 +9,8 @@
  */
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/ptrace.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -152,6 +154,66 @@ void cr_hbuf_put(struct cr_ctx *ctx, int n)
  * restart operation, and persists until the operation is completed.
  */
 
+static void cr_ctx_put_container(struct cr_ctx *ctx)
+{
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+	ctx->root_pid = 0;
+}
+
+static int cr_ctx_get_container(pid_t pid, struct cr_ctx *ctx)
+{
+	struct task_struct *task = NULL;
+	struct nsproxy *nsproxy = NULL;
+	int err = -ESRCH;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+
+	if (!task)
+		goto out;
+
+#if 0	/* enable to use containers */
+	if (!is_container_init(task)) {
+		err = -EINVAL;
+		goto out;
+	}
+#endif
+
+	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
+		err = -EPERM;
+		goto out;
+	}
+
+	rcu_read_lock();
+	if (task_nsproxy(task)) {
+		nsproxy = task_nsproxy(task);
+		get_nsproxy(nsproxy);
+	}
+	rcu_read_unlock();
+
+	if (!nsproxy)
+		goto out;
+
+	/* TODO: verify that the container is frozen */
+
+	ctx->root_pid = pid;
+	ctx->root_task = task;
+	ctx->root_nsproxy = nsproxy;
+
+	return 0;
+
+ out:
+	if (task)
+		put_task_struct(task);
+	return err;
+}
+
 /* unique checkpoint identifier (FIXME: should be per-container) */
 static atomic_t cr_ctx_count = ATOMIC_INIT(0);
 
@@ -168,6 +230,8 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
 
+	cr_ctx_put_container(ctx);
+
 	kfree(ctx);
 }
 
@@ -180,7 +244,6 @@ static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
-	ctx->pid = pid;
 	ctx->flags = flags;
 
 	INIT_LIST_HEAD(&ctx->pgarr_list);
@@ -190,6 +253,10 @@ static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	if (!ctx->file)
 		goto err;
 
+	err = cr_ctx_get_container(pid, ctx);
+	if (err < 0)
+		goto err;
+
 	err = -ENOMEM;
 	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
 
@@ -205,7 +272,7 @@ static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
-	ctx->vfsroot = &current->fs->root;
+	ctx->vfsroot = &ctx->root_task->fs->root;
 	path_get(ctx->vfsroot);
 
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6c1e87f..e9d554e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -16,9 +16,12 @@
 #define CR_VERSION  2
 
 struct cr_ctx {
-	pid_t pid;		/* container identifier */
 	int crid;		/* unique checkpoint id */
 
+	pid_t root_pid;		/* container identifier */
+	struct task_struct *root_task;	/* container root task */
+	struct nsproxy *root_nsproxy;	/* container root nsproxy */
+
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
 
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
