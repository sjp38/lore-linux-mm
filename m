From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v9][PATCH 10/13] External checkpoint of a task other than ourself
Date: Mon, 10 Nov 2008 11:37:37 -0500
Message-Id: <1226335060-7061-11-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu>
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container.

sys_restart() remains the same, as the restart is always done in the
context of the restarting task.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c    |   71 ++++++++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c       |    4 +-
 checkpoint/sys.c           |    6 ++++
 include/linux/checkpoint.h |    2 +
 4 files changed, 78 insertions(+), 5 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 700f829..a20f961 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -10,6 +10,7 @@
 
 #include <linux/version.h>
 #include <linux/sched.h>
+#include <linux/ptrace.h>
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -205,6 +206,13 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 {
 	int ret;
 
+	/* TODO: verity that the task is frozen (unless self) */
+
+	if (task->state == TASK_DEAD) {
+		pr_warning("c/r: task may not be in state TASK_DEAD\n");
+		return -EAGAIN;
+	}
+
 	ret = cr_write_task_struct(ctx, t);
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
@@ -227,10 +235,67 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
+static int cr_get_container(struct cr_ctx *ctx, pid_t pid)
 {
+	struct task_struct *task = NULL;
+	struct nsproxy *nsproxy = NULL;
+	int err = -ESRCH;
+
 	ctx->root_pid = pid;
 
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
+/* setup checkpoint-specific parts of ctx */
+static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
+{
+	int ret;
+
+	ret = cr_get_container(ctx, pid);
+	if (ret < 0)
+		return ret;
+
 	/*
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
@@ -245,13 +310,13 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	ret = cr_ctx_checkpoint(ctx);
+	ret = cr_ctx_checkpoint(ctx, pid);
 	if (ret < 0)
 		goto out;
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_task(ctx, current);
+	ret = cr_write_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = cr_write_tail(ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 1d1f2a7..8bd9d4a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -235,7 +235,7 @@ static int cr_read_task(struct cr_ctx *ctx)
 }
 
 /* setup restart-specific parts of ctx */
-static int cr_ctx_restart(struct cr_ctx *ctx)
+static int cr_ctx_restart(struct cr_ctx *ctx, pid_t pid)
 {
 	return 0;
 }
@@ -244,7 +244,7 @@ int do_restart(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	ret = cr_ctx_restart(ctx);
+	ret = cr_ctx_restart(ctx, pid);
 	if (ret < 0)
 		goto out;
 	ret = cr_read_head(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b640bee..dfe63ca 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -142,6 +143,11 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 	cr_pgarr_free(ctx);
 	cr_objhash_free(ctx);
 
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+
 	kfree(ctx);
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7e3402f..b807e85 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -19,6 +19,8 @@ struct cr_ctx {
 	int crid;		/* unique checkpoint id */
 
 	pid_t root_pid;		/* container identifier */
+	struct task_struct *root_task;	/* container root task */
+	struct nsproxy *root_nsproxy;	/* container root nsproxy */
 
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
