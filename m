Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF4B86B00B1
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:13 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 29/43] c/r: support for UTS namespace
Date: Wed, 27 May 2009 13:32:55 -0400
Message-Id: <1243445589-32388-30-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes:
  - Take uts_sem around access to uts data
  - Remove the kernel restore path
  - Punt on nested namespaces
  - Use __NEW_UTS_LEN in nodename and domainname buffers
  - Add a note to Documentation/checkpoint/internals.txt to indicate where
    in the save/restore process the UTS information is kept
  - Store (and track) the objref of the namespace itself instead of the
    nsproxy (based on comments from Dave on IRC)
  - Remove explicit check for non-root nsproxy
  - Store the nodename and domainname lengths and use ckpt_write_string()
    to store the actual name strings
  - Catch failure of ckpt_obj_add_ptr() in ckpt_write_namespaces()
  - Remove "types" bitfield and use the "is this new" flag to determine
    whether or not we should write out a new ns descriptor
  - Replace kernel restore path
  - Move the namespace information to be directly after the task
    information record
  - Update Documentation to reflect new location of namespace info
  - Support checkpoint and restart of nested UTS namespaces

Signed-off-by: Dan Smith <danms@us.ibm.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/checkpoint.c        |    2 -
 checkpoint/objhash.c           |   26 +++++++
 checkpoint/process.c           |  160 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |   15 ++++
 4 files changed, 200 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index e66f82b..904f19b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -310,8 +310,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
-		ret = -EPERM;
 	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
 		ret = -EPERM;
 	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 56553ae..8b7adc6 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -143,6 +143,22 @@ static int obj_ns_users(void *ptr)
 	return atomic_read(&((struct nsproxy *) ptr)->count);
 }
 
+static int obj_uts_ns_grab(void *ptr)
+{
+	get_uts_ns((struct uts_namespace *) ptr);
+	return 0;
+}
+
+static void obj_uts_ns_drop(void *ptr)
+{
+	put_uts_ns((struct uts_namespace *) ptr);
+}
+
+static int obj_uts_ns_users(void *ptr)
+{
+	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -200,6 +216,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_ns,
 		.restore = restore_ns,
 	},
+	/* uts_ns object */
+	{
+		.obj_name = "UTS_NS",
+		.obj_type = CKPT_OBJ_UTS_NS,
+		.ref_drop = obj_uts_ns_drop,
+		.ref_grab = obj_uts_ns_grab,
+		.ref_users = obj_uts_ns_users,
+		.checkpoint = checkpoint_bad,
+		.restore = restore_bad,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index fbe0d16..a827987 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -16,8 +16,10 @@
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/poll.h>
+#include <linux/utsname.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/syscalls.h>
 
 /***********************************************************************
  * Checkpoint
@@ -50,10 +52,69 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+static int checkpoint_uts_ns(struct ckpt_ctx *ctx, struct uts_namespace *uts_ns)
+{
+	struct ckpt_hdr_utsns *h;
+	int domainname_len;
+	int nodename_len;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	nodename_len = sizeof(uts_ns->name.nodename);
+	domainname_len = sizeof(uts_ns->name.domainname);
+
+	h->nodename_len = nodename_len;
+	h->domainname_len = domainname_len;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	down_read(&uts_sem);
+	ret = ckpt_write_string(ctx, uts_ns->name.nodename, nodename_len);
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_string(ctx, uts_ns->name.domainname, domainname_len);
+ up:
+	up_read(&uts_sem);
+	return ret;
+}
 
 static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 {
-	return 0;
+	struct ckpt_hdr_ns *h;
+	int ns_flags = 0;
+	int uts_objref;
+	int first, ret;
+
+	uts_objref = ckpt_obj_lookup_add(ctx, nsproxy->uts_ns,
+					 CKPT_OBJ_UTS_NS, &first);
+	if (uts_objref <= 0)
+		return uts_objref;
+	if (first)
+		ns_flags |= CLONE_NEWUTS;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (!h)
+		return -ENOMEM;
+
+	h->flags = ns_flags;
+	h->uts_objref = uts_objref;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	if (ns_flags & CLONE_NEWUTS)
+		ret = checkpoint_uts_ns(ctx, nsproxy->uts_ns);
+
+	/* FIX: Write other namespaces here */
+	return ret;
 }
 
 int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
@@ -300,10 +361,107 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *ns;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->nodename_len > sizeof(ns->name.nodename) ||
+	    h->domainname_len > sizeof(ns->name.domainname))
+		goto out;
+
+	ns = current->nsproxy->uts_ns;
+
+	/* no need to take uts_sem because we are the sole users */
+
+	memset(ns->name.nodename, 0, sizeof(ns->name.nodename));
+	ret = _ckpt_read_string(ctx, ns->name.nodename, h->nodename_len);
+	if (ret < 0)
+		goto out;
+	memset(ns->name.domainname, 0, sizeof(ns->name.domainname));
+	ret = _ckpt_read_string(ctx, ns->name.domainname, h->domainname_len);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_uts_ns(struct ckpt_ctx *ctx, int ns_objref, int flags)
+{
+	struct uts_namespace *uts_ns;
+	int ret = 0;
+
+	uts_ns = ckpt_obj_fetch(ctx, ns_objref, CKPT_OBJ_UTS_NS);
+	if (PTR_ERR(uts_ns) == -EINVAL)
+		uts_ns = NULL;
+	else if (IS_ERR(uts_ns))
+		return PTR_ERR(uts_ns);
+
+	/* sanity: CLONE_NEWUTS if-and-only-if uts_ns is NULL (first timer) */
+	if (!!uts_ns ^ !(flags & CLONE_NEWUTS))
+		return -EINVAL;
+
+	if (!uts_ns) {
+		ret = do_restore_uts_ns(ctx);
+		if (ret < 0)
+			return ret;
+		ret = ckpt_obj_insert(ctx, current->nsproxy->uts_ns,
+				    ns_objref, CKPT_OBJ_UTS_NS);
+	} else {
+		struct uts_namespace *old_uts_ns;
+
+		/* safe because nsproxy->count must be 1 ... */
+		BUG_ON(atomic_read(&current->nsproxy->count) != 1);
+
+		old_uts_ns = current->nsproxy->uts_ns;
+		current->nsproxy->uts_ns = uts_ns;
+		get_uts_ns(uts_ns);
+		put_uts_ns(old_uts_ns);
+	}
+
+	return ret;
+}
+
 static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 {
+	struct ckpt_hdr_ns *h;
 	struct nsproxy *nsproxy;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (IS_ERR(h))
+		return (struct nsproxy *) h;
+
+	ret = -EINVAL;
+	if (h->uts_objref <= 0)
+		goto out;
+	if (h->flags & ~CLONE_NEWUTS)
+		goto out;
 
+	/* each unseen-before namespace will be un-shared now */
+	ret = sys_unshare(h->flags);
+	if (ret)
+		goto out;
+
+	/*
+	 * For each unseen-before namespace 'xxx', it is now safe to
+	 * modify the nsproxy->xxx_ns without locking because unshare()
+	 * gave a brand new nsproxy and nsproxy->xxx_ns, and we're the
+	 * sole users at this point.
+	 */
+	ret = restore_uts_ns(ctx, h->uts_objref, h->flags);
+	ckpt_debug("uts ns: %d\n", ret);
+
+	/* FIX: add more namespaces here */
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ERR_PTR(ret);
 	nsproxy = task_nsproxy(current);
 	get_nsproxy(nsproxy);
 	return nsproxy;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index da1ae79..1603279 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -53,6 +53,8 @@ enum {
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
+	CKPT_HDR_NS,
+	CKPT_HDR_UTS_NS,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -92,6 +94,7 @@ enum obj_type {
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
 	CKPT_OBJ_NS,
+	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -160,6 +163,12 @@ struct ckpt_hdr_task_ns {
 	__s32 ns_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ns {
+	struct ckpt_hdr h;
+	__u32 flags;
+	__s32 uts_objref;
+} __attribute__((aligned(8)));
+
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
@@ -235,6 +244,12 @@ struct ckpt_hdr_file_pipe_state {
 	__s32 pipe_len;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_utsns {
+	struct ckpt_hdr h;
+	__u32 nodename_len;
+	__u32 domainname_len;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
