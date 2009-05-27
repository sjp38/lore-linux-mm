Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFAF6B00A3
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:12 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 19/43] c/r: external checkpoint of a task other than ourself
Date: Wed, 27 May 2009 13:32:45 -0400
Message-Id: <1243445589-32388-20-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container, unless CHECKPOINT_SUBTREE flag is given.

sys_restart() remains the same, as the restart is always done in the
context of the restarting task.

Changelog[v16]:
  - Use CHECKPOINT_SUBTREE to allow subtree (partial container)

Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them

Changelog[v10]:
  - Grab vfs root of container init, rather than current process

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c          |   79 +++++++++++++++++++++++++++++++++++++-
 checkpoint/restart.c             |    4 +-
 checkpoint/sys.c                 |    6 +++
 include/linux/checkpoint_types.h |    2 +
 4 files changed, 87 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index a346b7e..086f2d9 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -12,6 +12,9 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/freezer.h>
+#include <linux/ptrace.h>
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -245,23 +248,95 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	if (t->state == TASK_DEAD) {
+		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+		return -EAGAIN;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_READ)) {
+		__ckpt_write_err(ctx, "access to task %d (%s) denied",
+				 task_pid_vnr(t), t->comm);
+		return -EPERM;
+	}
+
+	/* verify that the task is frozen (unless self) */
+	if (t != current && !frozen(t)) {
+		__ckpt_write_err(ctx, "task %d (%s) is not frozen",
+				 task_pid_vnr(t), t->comm);
+		return -EBUSY;
+	}
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(t)) {
+		__ckpt_write_err(ctx, "task %d (%s) is ptraced",
+				 task_pid_vnr(t), t->comm);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int get_container(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task = NULL;
+	struct nsproxy *nsproxy = NULL;
+	int ret;
+
+	ctx->root_pid = pid;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+
+	if (!task)
+		return -ESRCH;
+
+	ret = may_checkpoint_task(ctx, task);
+	if (ret) {
+		ckpt_write_err(ctx, NULL);
+		put_task_struct(task);
+		return ret;
+	}
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	ctx->root_task = task;
+	ctx->root_nsproxy = nsproxy;
+
+	return 0;
+}
+
 /* setup checkpoint-specific parts of ctx */
 static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct fs_struct *fs;
+	int ret;
 
 	ctx->root_pid = pid;
 
+	ret = get_container(ctx, pid);
+	if (ret < 0)
+		return ret;
+
 	/*
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
 
-	fs = current->fs;
+	task_lock(ctx->root_task);
+	fs = ctx->root_task->fs;
 	read_lock(&fs->lock);
 	ctx->fs_mnt = fs->root;
 	path_get(&ctx->fs_mnt);
 	read_unlock(&fs->lock);
+	task_unlock(ctx->root_task);
 
 	return 0;
 }
@@ -276,7 +351,7 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, current);
+	ret = checkpoint_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index d3d6c5e..ca33539 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -352,7 +352,7 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 }
 
 /* setup restart-specific parts of ctx */
-static int init_restart_ctx(struct ckpt_ctx *ctx)
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 {
 	return 0;
 }
@@ -361,7 +361,7 @@ int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	ret = init_restart_ctx(ctx);
+	ret = init_restart_ctx(ctx, pid);
 	if (ret < 0)
 		return ret;
 	ret = restore_read_header(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7bf70e4..c809120 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -12,6 +12,7 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/kernel.h>
 #include <linux/syscalls.h>
 #include <linux/fs.h>
@@ -173,6 +174,11 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	path_put(&ctx->fs_mnt);
 	ckpt_pgarr_free(ctx);
 
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+
 	kfree(ctx);
 }
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index a0ea5f6..4369f90 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -28,6 +28,8 @@ struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
 	pid_t root_pid;		/* container identifier */
+	struct task_struct *root_task;	/* container root task */
+	struct nsproxy *root_nsproxy;	/* container root nsproxy */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
