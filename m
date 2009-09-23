Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1BA6B00A3
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:37 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 60/80] c/r: checkpoint and restore task credentials
Date: Wed, 23 Sep 2009 19:51:40 -0400
Message-Id: <1253749920-18673-61-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

This patch adds the checkpointing and restart of credentials
(uids, gids, and capabilities) to Oren's c/r patchset (on top
of v14).  It goes to great pains to re-use (and define when
needed) common helpers, in order to make sure that as security
code is modified, the cr code will be updated.  Some of the
helpers should still be moved (i.e. _creds() functions should
be in kernel/cred.c).

When building the credentials for the restarted process, I
1. create a new struct cred as a copy of the running task's
cred (using prepare_cred())
2. always authorize any changes to the new struct cred
based on the permissions of current_cred() (not the current
transient state of the new cred).

While this may mean that certain transient_cred1->transient_cred2
states are allowed which otherwise wouldn't be allowed, the
fact remains that current_cred() is allowed to transition to
transient_cred2.

The reconstructed creds are applied to the task at the very
end of the sys_restart call.  This ensures that any objects which
need to be re-created (file, socket, etc) are re-created using
the creds of the task calling sys_restart - preventing an unpriv
user from creating a privileged object, and ensuring that a
root task can restart a process which had started out privileged,
created some privileged objects, then dropped its privilege.

With these patches, the root user can restart checkpoint images
(created by either hallyn or root) of user hallyn's tasks,
resulting in a program owned by hallyn.

Changelog:
	Sep 08: [NTL] discard const from struct cred * where appropriate
	Jun 15: Fix user_ns handling when !CONFIG_USER_N
	        Set creator_ref=0 for root_ns (discard @flags)
		Don't  overwrite global user-ns if CONFIG_USER_NS
	Jun 10: Merge with ckpt-v16-dev (Oren Laadan)
	Jun 01: Don't check ordering of groups in group_info, bc
		set_groups() will sort it for us.
	May 28: 1. Restore securebits
		2. Address Alexey's comments: move prototypes out of
		   sched.h, validate ngroups < NGROUPS_MAX, validate
		   groups are sorted, and get rid of ckpt_hdr_cred->version.
		3. remove bogus unused flag RESTORE_CREATE_USERNS
	May 26: Move group, user, userns, creds c/r functions out
		of checkpoint/process.c and into the appropriate files.
	May 26: Define struct ckpt_hdr_task_creds and move task cred
		objref c/r into {checkpoint_restore}_task_shared().
	May 26: Take cred refs around checkpoint_write_creds()
	May 20: Remove the limit on number of groups in groupinfo
		at checkpoint time
	May 20: Remove the depth limit on empty user namespaces
	May 20: Better document checkpoint_user
	May 18: fix more refcounting: if (userns 5, uid 0) had
		no active tasks or child user_namespaces, then
		it shouldn't exist at restart or it, its namespace,
		and its whole chain of creators will be leaked.
	May 14: fix some refcounting:
		1. a new user_ns needs a ref to remain pinned
		   by its root user
		2. current_user_ns needs an extra ref bc objhash
		   drops two on restart
		3. cred needs a ref for the real credentials bc
		   commit_creds eats one ref.
	May 13: folded in fix to userns refcounting.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
[orenl@cs.columbia.edu: merge with ckpt-v16-dev]
---
 checkpoint/namespace.c           |   41 ++++++++++
 checkpoint/objhash.c             |   82 ++++++++++++++++++++
 checkpoint/process.c             |  111 ++++++++++++++++++++++++++-
 include/linux/capability.h       |    6 +-
 include/linux/checkpoint.h       |   12 +++
 include/linux/checkpoint_hdr.h   |   59 ++++++++++++++
 include/linux/checkpoint_types.h |    2 +
 kernel/cred.c                    |  123 +++++++++++++++++++++++++++++
 kernel/groups.c                  |   69 +++++++++++++++++
 kernel/user.c                    |  158 ++++++++++++++++++++++++++++++++++++++
 kernel/user_namespace.c          |   89 +++++++++++++++++++++
 11 files changed, 746 insertions(+), 6 deletions(-)

diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
index 49b8f0a..89af2c0 100644
--- a/checkpoint/namespace.c
+++ b/checkpoint/namespace.c
@@ -98,3 +98,44 @@ void *restore_uts_ns(struct ckpt_ctx *ctx)
 {
 	return (void *) do_restore_uts_ns(ctx);
 }
+
+/*
+ * user_ns  -  trivial checkpoint/restore for !CONFIG_USER_NS case
+ */
+#ifndef CONFIG_USER_NS
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_user_ns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+void *restore_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.user_ns)
+		return ERR_PTR(-EEXIST);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	if (h->creator_ref)
+		ns = ERR_PTR(-EINVAL);
+	else
+		ns = get_user_ns(current_user_ns());
+
+	ctx->stats.user_ns++;
+	ckpt_hdr_put(ctx, h);
+	return ns;
+}
+#endif
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 15a5caf..f8a3210 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -17,6 +17,7 @@
 #include <linux/fdtable.h>
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -172,6 +173,51 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_cred_grab(void *ptr)
+{
+	get_cred((struct cred *) ptr);
+	return 0;
+}
+
+static void obj_cred_drop(void *ptr, int lastref)
+{
+	put_cred((struct cred *) ptr);
+}
+
+static int obj_user_grab(void *ptr)
+{
+	struct user_struct *u = ptr;
+	(void) get_uid(u);
+	return 0;
+}
+
+static void obj_user_drop(void *ptr, int lastref)
+{
+	free_uid((struct user_struct *) ptr);
+}
+
+static int obj_userns_grab(void *ptr)
+{
+	get_user_ns((struct user_namespace *) ptr);
+	return 0;
+}
+
+static void obj_userns_drop(void *ptr, int lastref)
+{
+	put_user_ns((struct user_namespace *) ptr);
+}
+
+static int obj_groupinfo_grab(void *ptr)
+{
+	get_group_info((struct group_info *) ptr);
+	return 0;
+}
+
+static void obj_groupinfo_drop(void *ptr, int lastref)
+{
+	put_group_info((struct group_info *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -247,6 +293,42 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_ipc_ns,
 		.restore = restore_ipc_ns,
 	},
+	/* user_ns object */
+	{
+		.obj_name = "USER_NS",
+		.obj_type = CKPT_OBJ_USER_NS,
+		.ref_drop = obj_userns_drop,
+		.ref_grab = obj_userns_grab,
+		.checkpoint = checkpoint_userns,
+		.restore = restore_userns,
+	},
+	/* struct cred */
+	{
+		.obj_name = "CRED",
+		.obj_type = CKPT_OBJ_CRED,
+		.ref_drop = obj_cred_drop,
+		.ref_grab = obj_cred_grab,
+		.checkpoint = checkpoint_cred,
+		.restore = restore_cred,
+	},
+	/* user object */
+	{
+		.obj_name = "USER",
+		.obj_type = CKPT_OBJ_USER,
+		.ref_drop = obj_user_drop,
+		.ref_grab = obj_user_grab,
+		.checkpoint = checkpoint_user,
+		.restore = restore_user,
+	},
+	/* struct groupinfo */
+	{
+		.obj_name = "GROUPINFO",
+		.obj_type = CKPT_OBJ_GROUPINFO,
+		.ref_drop = obj_groupinfo_drop,
+		.ref_grab = obj_groupinfo_grab,
+		.checkpoint = checkpoint_groupinfo,
+		.restore = restore_groupinfo,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index b34ee3d..1e79f73 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -18,6 +18,7 @@
 #include <linux/compat.h>
 #include <linux/poll.h>
 #include <linux/utsname.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/syscalls.h>
@@ -136,6 +137,45 @@ static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int realcred_ref, ecred_ref;
+	struct cred *rcred, *ecred;
+	struct ckpt_hdr_task_creds *h;
+	int ret;
+
+	rcred = (struct cred *) get_cred(t->real_cred);
+	ecred = (struct cred *) get_cred(t->cred);
+
+	realcred_ref = checkpoint_obj(ctx, rcred, CKPT_OBJ_CRED);
+	if (realcred_ref < 0) {
+		ret = realcred_ref;
+		goto error;
+	}
+
+	ecred_ref = checkpoint_obj(ctx, ecred, CKPT_OBJ_CRED);
+	if (ecred_ref < 0) {
+		ret = ecred_ref;
+		goto error;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (!h) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	h->cred_ref = realcred_ref;
+	h->ecred_ref = ecred_ref;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+error:
+	put_cred(rcred);
+	put_cred(ecred);
+	return ret;
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -151,8 +191,12 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * restored when it gets to restore, e.g. its memory.
 	 */
 
-	ret = checkpoint_task_ns(ctx, t);
-	ckpt_debug("ns: objref %d\n", ret);
+	ret = checkpoint_task_creds(ctx, t);
+	ckpt_debug("cred: objref %d\n", ret);
+	if (!ret) {
+		ret = checkpoint_task_ns(ctx, t);
+		ckpt_debug("ns: objref %d\n", ret);
+	}
 	if (ret < 0)
 		return ret;
 
@@ -435,6 +479,34 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_creds(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_creds *h;
+	struct cred *realcred, *ecred;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(realcred)) {
+		ret = PTR_ERR(realcred);
+		goto out;
+	}
+	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(ecred)) {
+		ret = PTR_ERR(ecred);
+		goto out;
+	}
+	ctx->realcred = realcred;
+	ctx->ecred = ecred;
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -445,7 +517,9 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 * and because shared objects are restored before they are
 	 * referenced. See comment in checkpoint_task_objs.
 	 */
-	ret = restore_task_ns(ctx);
+	ret = restore_task_creds(ctx);
+	if (!ret)
+		ret = restore_task_ns(ctx);
 	if (ret < 0)
 		return ret;
 
@@ -463,6 +537,33 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_creds(struct ckpt_ctx *ctx)
+{
+	int ret;
+	const struct cred *old;
+	struct cred *rcred, *ecred;
+
+	rcred = ctx->realcred;
+	ecred = ctx->ecred;
+
+	/* commit_creds will take one ref for the eff creds, but
+	 * expects us to hold a ref for the obj creds, so take a
+	 * ref here */
+	get_cred(rcred);
+	ret = commit_creds(rcred);
+	if (ret)
+		return ret;
+
+	if (ecred == rcred)
+		return 0;
+
+	old =  override_creds(ecred); /* override_creds otoh takes new ref */
+	put_cred(old);
+
+	ctx->realcred = ctx->ecred = NULL;
+	return 0;
+}
+
 int restore_restart_block(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_restart_block *h;
@@ -596,6 +697,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_creds(ctx);
+	ckpt_debug("creds: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 3a74655..2f726f7 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -569,10 +569,10 @@ struct dentry;
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
 
 struct cred;
-int apply_securebits(unsigned securebits, struct cred *new);
+extern int apply_securebits(unsigned securebits, struct cred *new);
 struct ckpt_capabilities;
-int restore_capabilities(struct ckpt_capabilities *h, struct cred *new);
-void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred * cred);
+extern int restore_capabilities(struct ckpt_capabilities *h, struct cred *new);
+extern void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred *cred);
 
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 561232d..3dbf188 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -25,6 +25,7 @@
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
@@ -192,6 +193,17 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 			       struct ckpt_hdr_file *h);
 
+/* credentials */
+extern int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr);
+extern int checkpoint_user(struct ckpt_ctx *ctx, void *ptr);
+extern int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_groupinfo(struct ckpt_ctx *ctx);
+extern void *restore_user(struct ckpt_ctx *ctx);
+extern void *restore_cred(struct ckpt_ctx *ctx);
+
+extern int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_userns(struct ckpt_ctx *ctx);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index cb036e8..3f00bce 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -62,6 +62,11 @@ enum {
 	CKPT_HDR_UTS_NS,
 	CKPT_HDR_IPC_NS,
 	CKPT_HDR_CAPABILITIES,
+	CKPT_HDR_USER_NS,
+	CKPT_HDR_CRED,
+	CKPT_HDR_USER,
+	CKPT_HDR_GROUPINFO,
+	CKPT_HDR_TASK_CREDS,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -111,6 +116,10 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_USER_NS,
+	CKPT_OBJ_CRED,
+	CKPT_OBJ_USER,
+	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_MAX
 };
 
@@ -184,6 +193,11 @@ struct ckpt_hdr_task {
 	__u32 exit_signal;
 	__u32 pdeath_signal;
 
+#ifdef CONFIG_AUDITSYSCALL
+	/* would audit want to track the checkpointed ids,
+	   or (more likely) who actually restarted? */
+#endif
+
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
 
@@ -191,6 +205,7 @@ struct ckpt_hdr_task {
 	__u32 compat_robust_futex_list; /* a compat __user ptr */
 	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
+
 } __attribute__((aligned(8)));
 
 /* Posix capabilities */
@@ -203,6 +218,50 @@ struct ckpt_capabilities {
 	__u32 padding;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_task_creds {
+	struct ckpt_hdr h;
+	__s32 cred_ref;
+	__s32 ecred_ref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_cred {
+	struct ckpt_hdr h;
+	__u32 uid, suid, euid, fsuid;
+	__u32 gid, sgid, egid, fsgid;
+	__s32 user_ref;
+	__s32 groupinfo_ref;
+	struct ckpt_capabilities cap_s;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_groupinfo {
+	struct ckpt_hdr h;
+	__u32 ngroups;
+	/*
+	 * This is followed by ngroups __u32s
+	 */
+	__u32 groups[0];
+} __attribute__((aligned(8)));
+
+/*
+ * todo - keyrings and LSM
+ * These may be better done with userspace help though
+ */
+struct ckpt_hdr_user_struct {
+	struct ckpt_hdr h;
+	__u32 uid;
+	__s32 userns_ref;
+} __attribute__((aligned(8)));
+
+/*
+ * The user-struct mostly tracks system resource usage.
+ * Most of it's contents therefore will simply be set
+ * correctly as restart opens resources
+ */
+struct ckpt_hdr_user_ns {
+	struct ckpt_hdr h;
+	__s32 creator_ref;
+} __attribute__((aligned(8)));
+
 /* namespaces */
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 9632aa4..be45666 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -25,6 +25,7 @@
 struct ckpt_stats {
 	int uts_ns;
 	int ipc_ns;
+	int user_ns;
 };
 
 struct ckpt_ctx {
@@ -70,6 +71,7 @@ struct ckpt_ctx {
 	int active_pid;			/* (next) position in pids array */
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
 };
diff --git a/kernel/cred.c b/kernel/cred.c
index 5c8db56..9710cae 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -16,6 +16,7 @@
 #include <linux/init_task.h>
 #include <linux/security.h>
 #include <linux/cn_proc.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 static struct kmem_cache *cred_jar;
@@ -703,3 +704,125 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 	}
 	return -EPERM;
 }
+
+#ifdef CONFIG_CHECKPOINT
+static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
+{
+	int ret;
+	int groupinfo_ref, user_ref;
+	struct ckpt_hdr_cred *h;
+
+	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
+					CKPT_OBJ_GROUPINFO);
+	if (groupinfo_ref < 0)
+		return groupinfo_ref;
+	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
+	if (user_ref < 0)
+		return user_ref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (!h)
+		return -ENOMEM;
+
+	h->uid = cred->uid;
+	h->suid = cred->suid;
+	h->euid = cred->euid;
+	h->fsuid = cred->fsuid;
+
+	h->gid = cred->gid;
+	h->sgid = cred->sgid;
+	h->egid = cred->egid;
+	h->fsgid = cred->fsgid;
+
+	checkpoint_capabilities(&h->cap_s, cred);
+
+	h->user_ref = user_ref;
+	h->groupinfo_ref = groupinfo_ref;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_cred(ctx, (struct cred *) ptr);
+}
+
+static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
+{
+	struct cred *cred;
+	struct ckpt_hdr_cred *h;
+	struct user_struct *user;
+	struct group_info *groupinfo;
+	int ret = -EINVAL;
+	uid_t olduid;
+	gid_t oldgid;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	cred = prepare_creds();
+	if (!cred)
+		goto error;
+
+
+	/* Do we care if the target user and target group were compatible?
+	 * Probably.  But then, we can't do any setuid without CAP_SETUID,
+	 * so we must have been privileged to abuse it... */
+	groupinfo = ckpt_obj_fetch(ctx, h->groupinfo_ref, CKPT_OBJ_GROUPINFO);
+	if (IS_ERR(groupinfo))
+		goto err_putcred;
+	user = ckpt_obj_fetch(ctx, h->user_ref, CKPT_OBJ_USER);
+	if (IS_ERR(user))
+		goto err_putcred;
+
+	/*
+	 * TODO: this check should  go into the common helper in
+	 * kernel/sys.c, and should account for user namespaces
+	 */
+	if (!capable(CAP_SETGID))
+		for (i = 0; i < groupinfo->ngroups; i++) {
+			if (!in_egroup_p(GROUP_AT(groupinfo, i)))
+				goto err_putcred;
+		}
+	ret = set_groups(cred, groupinfo);
+	if (ret < 0)
+		goto err_putcred;
+	free_uid(cred->user);
+	cred->user = get_uid(user);
+	ret = cred_setresuid(cred, h->uid, h->euid, h->suid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsuid(cred, h->fsuid, &olduid);
+	if (olduid != h->fsuid && ret < 0)
+		goto err_putcred;
+	ret = cred_setresgid(cred, h->gid, h->egid, h->sgid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
+	if (oldgid != h->fsgid && ret < 0)
+		goto err_putcred;
+	ret = restore_capabilities(&h->cap_s, cred);
+	if (ret)
+		goto err_putcred;
+
+	ckpt_hdr_put(ctx, h);
+	return cred;
+
+err_putcred:
+	abort_creds(cred);
+error:
+	ckpt_hdr_put(ctx, h);
+	return ERR_PTR(ret);
+}
+
+void *restore_cred(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_cred(ctx);
+}
+
+#endif
diff --git a/kernel/groups.c b/kernel/groups.c
index 2b45b2e..3612c3e 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -6,6 +6,7 @@
 #include <linux/slab.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
 #include <asm/uaccess.h>
 
 /* init to 2 - one for init_task, one to ensure it is never freed */
@@ -286,3 +287,71 @@ int in_egroup_p(gid_t grp)
 }
 
 EXPORT_SYMBOL(in_egroup_p);
+
+#ifdef CONFIG_CHECKPOINT
+static int do_checkpoint_groupinfo(struct ckpt_ctx *ctx, struct group_info *g)
+{
+	int ret, i, size;
+	struct ckpt_hdr_groupinfo *h;
+
+	size = sizeof(*h) + g->ngroups * sizeof(__u32);
+	h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_GROUPINFO);
+	if (!h)
+		return -ENOMEM;
+
+	h->ngroups = g->ngroups;
+	for (i = 0; i < g->ngroups; i++)
+		h->groups[i] = GROUP_AT(g, i);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_groupinfo(ctx, (struct group_info *)ptr);
+}
+
+/*
+ * TODO - switch to reading in smaller blocks?
+ */
+#define MAX_GROUPINFO_SIZE (sizeof(*h)+NGROUPS_MAX*sizeof(gid_t))
+static struct group_info *do_restore_groupinfo(struct ckpt_ctx *ctx)
+{
+	struct group_info *g;
+	struct ckpt_hdr_groupinfo *h;
+	int i;
+
+	h = ckpt_read_buf_type(ctx, MAX_GROUPINFO_SIZE, CKPT_HDR_GROUPINFO);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	g = ERR_PTR(-EINVAL);
+	if (h->ngroups > NGROUPS_MAX)
+		goto out;
+
+	for (i = 1; i < h->ngroups; i++)
+		if (h->groups[i-1] >= h->groups[i])
+			goto out;
+
+	g = groups_alloc(h->ngroups);
+	if (!g) {
+		g = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	for (i = 0; i < h->ngroups; i++)
+		GROUP_AT(g, i) = h->groups[i];
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return g;
+}
+
+void *restore_groupinfo(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_groupinfo(ctx);
+}
+
+#endif
diff --git a/kernel/user.c b/kernel/user.c
index 2c000e7..a535ed6 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 struct user_namespace init_user_ns = {
@@ -508,3 +509,160 @@ static int __init uid_cache_init(void)
 }
 
 module_init(uid_cache_init);
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * write the user struct
+ * TODO keyring will need to be dumped
+ *
+ * Here is what we're doing.  Remember a task can do clone(CLONE_NEWUSER)
+ * resulting in a cloned task in a new user namespace, with uid 0 in that
+ * new user_ns.  In that case, the parent's user (uid+user_ns) is the
+ * 'creator' of the new user_ns.
+ * Here, we call the user_ns of the ctx->root_task the 'root_ns'.  When we
+ * checkpoint a user-struct, we must store the chain of creators.  We
+ * must not do so recursively, this being the kernel.  In
+ * checkpoint_write_user() we walk and record in memory the list of creators up
+ * to either the latest user_struct which has already been saved, or the
+ * root_ns.  Then we walk that chain backward, writing out the user_ns and
+ * user_struct to the checkpoint image.
+ */
+#define UNSAVED_STRIDE 50
+static int do_checkpoint_user(struct ckpt_ctx *ctx, struct user_struct *u)
+{
+	struct user_namespace *ns, *root_ns;
+	struct ckpt_hdr_user_struct *h;
+	int ns_objref;
+	int ret, i, unsaved_ns_nr = 0;
+	struct user_struct *save_u;
+	struct user_struct **unsaved_creators;
+	int step = 1, size;
+
+	/* if we've already saved the userns, then life is good */
+	ns_objref = ckpt_obj_lookup(ctx, u->user_ns, CKPT_OBJ_USER_NS);
+	if (ns_objref)
+		goto write_user;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+
+	if (u->user_ns == root_ns)
+		goto save_last_ns;
+
+	size = UNSAVED_STRIDE*sizeof(struct user_struct *);
+	unsaved_creators = kmalloc(size, GFP_KERNEL);
+	if (!unsaved_creators)
+		return -ENOMEM;
+	save_u = u;
+	do {
+		ns = save_u->user_ns;
+		save_u = ns->creator;
+		if (ckpt_obj_lookup(ctx, save_u, CKPT_OBJ_USER))
+			goto found;
+		unsaved_creators[unsaved_ns_nr++] = save_u;
+		if (unsaved_ns_nr == step * UNSAVED_STRIDE) {
+			step++;
+			size = step*UNSAVED_STRIDE*sizeof(struct user_struct *);
+			unsaved_creators = krealloc(unsaved_creators, size,
+							GFP_KERNEL);
+			if (!unsaved_creators)
+				return -ENOMEM;
+		}
+	} while (ns != root_ns);
+
+found:
+	for (i = unsaved_ns_nr-1; i >= 0; i--) {
+		ret = checkpoint_obj(ctx, unsaved_creators[i], CKPT_OBJ_USER);
+		if (ret < 0) {
+			kfree(unsaved_creators);
+			return ret;
+		}
+	}
+	kfree(unsaved_creators);
+
+save_last_ns:
+	ns_objref = checkpoint_obj(ctx, u->user_ns, CKPT_OBJ_USER_NS);
+	if (ns_objref < 0)
+		return ns_objref;
+
+write_user:
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (!h)
+		return -ENOMEM;
+
+	h->uid = u->uid;
+	h->userns_ref = ns_objref;
+
+	/* write out the user_struct */
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
+}
+
+static int may_setuid(struct user_namespace *ns, uid_t uid)
+{
+	/*
+	 * this next check will one day become
+	 * if capable(CAP_SETUID, ns) return 1;
+	 * followed by uid_equiv(current_userns, current_uid, ns, uid)
+	 * instead of just uids.
+	 */
+	if (capable(CAP_SETUID))
+		return 1;
+
+	/*
+	 * this may be overly strict, but since we might end up
+	 * restarting a privileged program here, we do not want
+	 * someone with only CAP_SYS_ADMIN but no CAP_SETUID to
+	 * be able to create random userids even in a userns he
+	 * created.
+	 */
+	if (current_user()->user_ns != ns)
+		return 0;
+	if (current_uid() == uid ||
+		current_euid() == uid ||
+		current_suid() == uid)
+		return 1;
+	return 0;
+}
+
+static struct user_struct *do_restore_user(struct ckpt_ctx *ctx)
+{
+	struct user_struct *u;
+	struct user_namespace *ns;
+	struct ckpt_hdr_user_struct *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	ns = ckpt_obj_fetch(ctx, h->userns_ref, CKPT_OBJ_USER_NS);
+	if (IS_ERR(ns)) {
+		u = ERR_PTR(PTR_ERR(ns));
+		goto out;
+	}
+
+	if (!may_setuid(ns, h->uid)) {
+		u = ERR_PTR(-EPERM);
+		goto out;
+	}
+	u = alloc_uid(ns, h->uid);
+	if (!u)
+		u = ERR_PTR(-EINVAL);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return u;
+}
+
+void *restore_user(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_user(ctx);
+}
+
+#endif
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e624b0f..3a35b50 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include <linux/cred.h>
 
 static struct user_namespace *_new_user_ns(struct user_struct *creator,
@@ -103,3 +104,91 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * do_checkpoint_userns() is only called from do_checkpoint_user().
+ * When called, we always know that either:
+ *   1. This is the root_ns (user_ns of the ctx->root_task),
+ *	in which case we set h->creator_ref = 0.
+ * or
+ *   2. The creator has already been written out to the
+ *	checkpoint image (and saved in the objhash)
+ */
+static int do_checkpoint_userns(struct ckpt_ctx *ctx, struct user_namespace *ns)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *root_ns;
+	int creator_ref = 0;
+	int ret;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+	if (ns != root_ns) {
+		creator_ref = ckpt_obj_lookup(ctx, ns->creator, CKPT_OBJ_USER);
+		if (!creator_ref)
+			return -EINVAL;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	h->creator_ref = creator_ref;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_userns(ctx, (struct user_namespace *) ptr);
+}
+
+static struct user_namespace *do_restore_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+	struct user_struct *new_root, *creator;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	if (!h->creator_ref) {
+		ns = get_user_ns(current_user_ns());
+		goto out;
+	}
+
+	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
+	if (IS_ERR(creator)) {
+		ns = ERR_PTR(-EINVAL);
+		goto out;
+	}
+
+	ns = new_user_ns(creator, &new_root);
+	if (IS_ERR(ns))
+		goto out;
+
+	/* ns only referenced from new_root, which we discard below */
+	get_user_ns(ns);
+
+	/* new_user_ns() doesn't bump creator's refcount */
+	get_uid(creator);
+
+	/*
+	 * Free the new root user.  If we actually needed it,
+	 * then it will show up later in the checkpoint image
+	 * The objhash will keep the userns pinned until then.
+	 */
+	free_uid(new_root);
+ out:
+	ctx->stats.user_ns++;
+	ckpt_hdr_put(ctx, h);
+	return ns;
+}
+
+void *restore_userns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_userns(ctx);
+}
+#endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
