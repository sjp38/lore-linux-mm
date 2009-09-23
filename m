Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 889FE6B00C6
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:54 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 48/80] c/r: make ckpt_may_checkpoint_task() check each namespace individually
Date: Wed, 23 Sep 2009 19:51:28 -0400
Message-Id: <1253749920-18673-49-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

For a given namespace type, say XXX, if a checkpoint was taken on a
CONFIG_XXX_NS system, is restarted on a !CONFIG_XXX_NS, then ensure
that:

1) The global settings of the global (init) namespace do not get
overwritten. Creating new objects in that namespace is ok, as long as
the request identifier is available.

2) All restarting tasks use a single namespace - because it is
impossible to create additional namespaces to accommodate for what had
been checkpointed.

Original patch introducing nsproxy c/r by Dan Smith <danms@us.ibm.com>

Chagnelog[v18]:
  - Add a few more ckpt_write_err()s
Chagnelog[v17]:
  - Only collect sub-objects of struct_nsproxy once.
  - Restore namespace pieces directly instead of using sys_unshare()
  - Proper handling of restart from namespace(s) without namespace(s)

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c        |   26 +++++++++++--
 checkpoint/objhash.c           |   28 ++++++++++++++
 checkpoint/process.c           |   81 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    5 ++
 include/linux/checkpoint_hdr.h |   13 ++++++
 kernel/nsproxy.c               |   76 +++++++++++++++++++++++++++++++++++++
 6 files changed, 225 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index f907485..52d7a92 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -378,6 +378,8 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct task_struct *root = ctx->root_task;
+	struct nsproxy *nsproxy;
+	int ret = 0;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
@@ -417,11 +419,27 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
+	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
+		__ckpt_write_err(ctx, "TE", "bad mnt_ns", -EPERM);
+		ret = -EPERM;
+	}
+	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
+		__ckpt_write_err(ctx, "TE", "bad pid_ns", -EPERM);
+		ret = -EPERM;
+	}
+	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
+		__ckpt_write_err(ctx, "TE", "bad net_ns", -EPERM);
+		ret = -EPERM;
+	}
+	rcu_read_unlock();
 
-	return 0;
+	return ret;
 }
 
 #define CKPT_HDR_PIDS_CHUNK	256
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index be9411f..a8a99e7 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -122,6 +122,22 @@ static int obj_mm_users(void *ptr)
 	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
 }
 
+static int obj_ns_grab(void *ptr)
+{
+	get_nsproxy((struct nsproxy *) ptr);
+	return 0;
+}
+
+static void obj_ns_drop(void *ptr, int lastref)
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
@@ -167,6 +183,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
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
 
 
@@ -572,6 +598,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 
 	/* account for ctx->file reference (if in the table already) */
 	ckpt_obj_users_inc(ctx, ctx->file, 1);
+	/* account for ctx->root_nsproxy reference (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
 
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 1788a39..3444aff 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -12,6 +12,7 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/compat.h>
@@ -104,6 +105,35 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
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
+
+	return ret;
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -111,6 +141,19 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
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
+	ckpt_debug("ns: objref %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
 	if (files_objref < 0) {
@@ -286,6 +329,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	int ret;
 
+	ret = ckpt_collect_ns(ctx, t);
+	if (ret < 0)
+		return ret;
 	ret = ckpt_collect_file_table(ctx, t);
 	if (ret < 0)
 		return ret;
@@ -361,11 +407,46 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
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
index 2770fc2..e68afab 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -142,6 +142,11 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* namespaces */
+extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_ns(struct ckpt_ctx *ctx);
+
 /* file table */
 extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 7e64b77..5a5916d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -54,10 +54,12 @@ enum {
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
+	CKPT_HDR_TASK_NS,
 	CKPT_HDR_TASK_OBJS,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
+	CKPT_HDR_NS,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -96,6 +98,7 @@ enum obj_type {
 	CKPT_OBJ_FILE_TABLE,
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
+	CKPT_OBJ_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -175,6 +178,16 @@ struct ckpt_hdr_task {
 	__u64 robust_futex_list; /* a __user ptr */
 } __attribute__((aligned(8)));
 
+/* namespaces */
+struct ckpt_hdr_task_ns {
+	struct ckpt_hdr h;
+	__s32 ns_objref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ns {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 09b4ff9..54cb987 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -21,6 +21,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/checkpoint.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -221,6 +222,81 @@ void exit_task_namespaces(struct task_struct *p)
 	switch_task_namespaces(p, NULL);
 }
 
+#ifdef CONFIG_CHECKPOINT
+int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct nsproxy *nsproxy;
+	int exists;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	if (!nsproxy)
+		return 0;
+
+	/* if already exists, don't proceed inside the struct */
+	exists = ckpt_obj_lookup(ctx, nsproxy, CKPT_OBJ_NS);
+
+	ret = ckpt_obj_collect(ctx, nsproxy, CKPT_OBJ_NS);
+	if (ret < 0 || exists)
+		goto out;
+
+	/* TODO: collect other namespaces here */
+ out:
+	put_nsproxy(nsproxy);
+	return ret;
+}
+
+static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
+{
+	struct ckpt_hdr_ns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (!h)
+		return -ENOMEM;
+
+	/* TODO: Write other namespaces here */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+
+int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
+}
+
+static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ns *h;
+	struct nsproxy *nsproxy = NULL;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (IS_ERR(h))
+		return (struct nsproxy *) h;
+
+	nsproxy = current->nsproxy;
+	get_nsproxy(nsproxy);
+
+	/* TODO: add more namespaces here */
+
+	ckpt_hdr_put(ctx, h);
+	return nsproxy;
+}
+
+void *restore_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_ns(ctx);
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init nsproxy_cache_init(void)
 {
 	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
