Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 758ED6B00AC
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:13 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 28/43] c/r: make ckpt_may_checkpoint_task() check each namespace individually
Date: Wed, 27 May 2009 13:32:54 -0400
Message-Id: <1243445589-32388-29-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

Signed-off-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c        |   20 ++++++--
 checkpoint/objhash.c           |   28 +++++++++++
 checkpoint/process.c           |  101 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    4 ++
 include/linux/checkpoint_hdr.h |    8 +++
 5 files changed, 157 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b70adf4..e66f82b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -267,6 +267,8 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct task_struct *root = ctx->root_task;
+	struct nsproxy *nsproxy;
+	int ret = 0;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
@@ -306,11 +308,21 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EINVAL;
 	}
 
-	/* FIX: change this when namespaces are added */
-	if (task_nsproxy(t) != ctx->root_nsproxy)
-		return -EPERM;
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
+		ret = -EPERM;
+	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
+		ret = -EPERM;
+	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
+		ret = -EPERM;
+	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns)
+		ret = -EPERM;
+	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns)
+		ret = -EPERM;
+	rcu_read_unlock();
 
-	return 0;
+	return ret;
 }
 
 #define CKPT_HDR_PIDS_CHUNK	256
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index e481911..56553ae 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -127,6 +127,22 @@ static int obj_mm_users(void *ptr)
 	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
 }
 
+static int obj_ns_grab(void *ptr)
+{
+	get_nsproxy((struct nsproxy *) ptr);
+	return 0;
+}
+
+static void obj_ns_drop(void *ptr)
+{
+	put_nsproxy((struct nsproxy *) ptr);
+}
+
+static int obj_ns_users(void *ptr)
+{
+	return atomic_read(&((struct nsproxy *) ptr)->count);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -174,6 +190,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_mm,
 		.restore = restore_mm,
 	},
+	/* ns object */
+	{
+		.obj_name = "NSPROXY",
+		.obj_type = CKPT_OBJ_NS,
+		.ref_drop = obj_ns_drop,
+		.ref_grab = obj_ns_grab,
+		.ref_users = obj_ns_users,
+		.checkpoint = checkpoint_ns,
+		.restore = restore_ns,
+	},
 };
 
 
@@ -396,6 +422,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 
 	/* account for ctx->file reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	/* account for ctx->root_nsproxy reference (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
 
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 876be3e..fbe0d16 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -12,6 +12,7 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/poll.h>
@@ -49,6 +50,45 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+
+static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
+{
+	return 0;
+}
+
+int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
+}
+
+static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ns_objref;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	ns_objref = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
+	put_nsproxy(nsproxy);
+
+	ckpt_debug("nsproxy: objref %d\n", ns_objref);
+	if (ns_objref < 0)
+		return ns_objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (!h)
+		return -ENOMEM;
+	h->ns_objref = ns_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -56,6 +96,18 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int mm_objref;
 	int ret;
 
+	/*
+	 * Shared objects may have dependencies among them: task->mm
+	 * depends on task->nsproxy (by ipc_ns). Therefore first save
+	 * the namespaces, and then the remaining shared objects.
+	 * During restart a task will already have its namespaces
+	 * restored when it gets to restore, e.g. its memory.
+	 */
+
+	ret = checkpoint_task_ns(ctx, t);
+	if (ret < 0)
+		return ret;
+
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
 	if (files_objref < 0) {
@@ -248,11 +300,60 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
+{
+	struct nsproxy *nsproxy;
+
+	nsproxy = task_nsproxy(current);
+	get_nsproxy(nsproxy);
+	return nsproxy;
+}
+
+void *restore_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_ns(ctx);
+}
+
+static int restore_task_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	nsproxy = ckpt_obj_fetch(ctx, h->ns_objref, CKPT_OBJ_NS);
+	if (IS_ERR(nsproxy)) {
+		ret = PTR_ERR(nsproxy);
+		goto out;
+	}
+
+	if (nsproxy != task_nsproxy(current)) {
+		get_nsproxy(nsproxy);
+		switch_task_namespaces(current, nsproxy);
+	}
+ out:
+	ckpt_debug("nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
 	int ret;
 
+	/*
+	 * Namespaces come first, because ->mm depends on ->nsproxy,
+	 * and because shared objects are restored before they are
+	 * referenced. See comment in checkpoint_task_objs.
+	 */
+	ret = restore_task_ns(ctx);
+	if (ret < 0)
+		return ret;
+
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 171e92e..a7125fc 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -77,6 +77,10 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* namespaces */
+extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_ns(struct ckpt_ctx *ctx);
+
 /* file table */
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
 				     struct task_struct *t);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 14654e8..da1ae79 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -48,6 +48,7 @@ enum {
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
+	CKPT_HDR_TASK_NS,
 	CKPT_HDR_TASK_OBJS,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
@@ -90,6 +91,7 @@ enum obj_type {
 	CKPT_OBJ_FILE_TABLE,
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
+	CKPT_OBJ_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -152,6 +154,12 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* namespaces */
+struct ckpt_hdr_task_ns {
+	struct ckpt_hdr h;
+	__s32 ns_objref;
+} __attribute__((aligned(8)));
+
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
