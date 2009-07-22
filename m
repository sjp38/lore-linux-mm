Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 086CF6B00B2
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:20 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 46/60] c/r: support for UTS namespace
Date: Wed, 22 Jul 2009 06:00:08 -0400
Message-Id: <1248256822-23416-47-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes[v17]:
  - Collect nsproxy->uts_ns
  - Save uts string lengths once in ckpt_hdr_const
  - Save and restore all fields of uts-ns
  - Don't overwrite global uts-ns if !CONFIG_UTS_NS
  - Replace sys_unshare() with create_uts_ns()
  - Take uts_sem around access to uts data
Changes:
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
 checkpoint/Makefile              |    1 +
 checkpoint/checkpoint.c          |    5 +-
 checkpoint/namespace.c           |  100 ++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c             |   26 ++++++++++
 checkpoint/process.c             |    2 +
 checkpoint/restart.c             |   32 ++++++++++++
 include/linux/checkpoint.h       |    5 ++
 include/linux/checkpoint_hdr.h   |   16 ++++++
 include/linux/checkpoint_types.h |    6 ++
 include/linux/utsname.h          |    1 +
 kernel/nsproxy.c                 |   47 +++++++++++++++++-
 kernel/utsname.c                 |    3 +-
 12 files changed, 240 insertions(+), 4 deletions(-)
 create mode 100644 checkpoint/namespace.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index f56a7d6..bb2c0ca 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -8,5 +8,6 @@ obj-$(CONFIG_CHECKPOINT) += \
 	checkpoint.o \
 	restart.o \
 	process.o \
+	namespace.o \
 	files.o \
 	memory.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index af6b58b..39ee917 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -191,9 +191,12 @@ static void fill_kernel_const(struct ckpt_hdr_const *h)
 	/* mm */
 	h->mm_saved_auxv_len = sizeof(mm->saved_auxv);
 	/* uts */
+	h->uts_sysname_len = sizeof(uts->sysname);
+	h->uts_nodename_len = sizeof(uts->nodename);
 	h->uts_release_len = sizeof(uts->release);
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
+	h->uts_domainname_len = sizeof(uts->domainname);
 }
 
 /* write the checkpoint header */
@@ -328,8 +331,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
-		ret = -EPERM;
 	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
 		ret = -EPERM;
 	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
new file mode 100644
index 0000000..49b8f0a
--- /dev/null
+++ b/checkpoint/namespace.c
@@ -0,0 +1,100 @@
+/*
+ *  Checkpoint namespaces
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+#include <linux/nsproxy.h>
+#include <linux/user_namespace.h>
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * uts_ns  -  this needs to compile even for !CONFIG_USER_NS, so
+ *   the code may not reside in kernel/utsname.c (which wouldn't
+ *   compile then).
+ */
+static int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
+				struct uts_namespace *uts_ns)
+{
+	struct ckpt_hdr_utsns *h;
+	struct new_utsname *name;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(h->sysname, name->sysname, sizeof(name->sysname));
+	memcpy(h->nodename, name->nodename, sizeof(name->nodename));
+	memcpy(h->release, name->release, sizeof(name->release));
+	memcpy(h->version, name->version, sizeof(name->version));
+	memcpy(h->machine, name->machine, sizeof(name->machine));
+	memcpy(h->domainname, name->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_uts_ns(ctx, (struct uts_namespace *) ptr);
+}
+
+static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns = NULL;
+	struct new_utsname *name;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (struct uts_namespace *) h;
+
+#ifdef CONFIG_UTS_NS
+	uts_ns = create_uts_ns();
+	if (!uts_ns) {
+		uts_ns = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
+	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
+	memcpy(name->release, h->release, sizeof(name->release));
+	memcpy(name->version, h->version, sizeof(name->version));
+	memcpy(name->machine, h->machine, sizeof(name->machine));
+	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+#else
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.uts_ns) {
+		uts_ns = ERR_PTR(-EEXIST);
+		goto out;
+	}
+	uts_ns = current->nsproxy->uts_ns;
+	get_uts_ns(uts_ns);
+#endif
+
+	ctx->stats.uts_ns++;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return uts_ns;
+}
+
+void *restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_uts_ns(ctx);
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 18ede6f..caa856c 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -148,6 +148,22 @@ static int obj_ns_users(void *ptr)
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
@@ -205,6 +221,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
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
+		.checkpoint = checkpoint_uts_ns,
+		.restore = restore_uts_ns,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 40e83c9..245607b 100644
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
 
 
 #ifdef CONFIG_FUTEX
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 972bee6..935caf6 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -281,6 +281,32 @@ void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type)
 	return h;
 }
 
+/**
+ * ckpt_read_consume - consume the next object of expected type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * This can be used to skip an object in the input stream when the
+ * data is unnecessary for the restart. @len indicates the length of
+ * the object); if @len is zero the length is unconstrained.
+ */
+int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret = 0;
+
+	h = ckpt_read_obj(ctx, len, 0);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->type != type)
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /***********************************************************************
  * Restart
  */
@@ -298,12 +324,18 @@ static int check_kernel_const(struct ckpt_hdr_const *h)
 	if (h->mm_saved_auxv_len != sizeof(mm->saved_auxv))
 		return -EINVAL;
 	/* uts */
+	if (h->uts_sysname_len != sizeof(uts->sysname))
+		return -EINVAL;
+	if (h->uts_nodename_len != sizeof(uts->nodename))
+		return -EINVAL;
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
 	if (h->uts_version_len != sizeof(uts->version))
 		return -EINVAL;
 	if (h->uts_machine_len != sizeof(uts->machine))
 		return -EINVAL;
+	if (h->uts_domainname_len != sizeof(uts->domainname))
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e433b5c..0085ea8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -66,6 +66,7 @@ extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
+extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
@@ -131,6 +132,10 @@ extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_ns(struct ckpt_ctx *ctx);
 
+/* uts-ns */
+extern int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_uts_ns(struct ckpt_ctx *ctx);
+
 /* file table */
 extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index af18332..18ab78f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -58,6 +58,7 @@ enum {
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
 	CKPT_HDR_NS,
+	CKPT_HDR_UTS_NS,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -97,6 +98,7 @@ enum obj_type {
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
 	CKPT_OBJ_NS,
+	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -107,9 +109,12 @@ struct ckpt_hdr_const {
 	/* mm */
 	__u16 mm_saved_auxv_len;
 	/* uts */
+	__u16 uts_sysname_len;
+	__u16 uts_nodename_len;
 	__u16 uts_release_len;
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
+	__u16 uts_domainname_len;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -184,6 +189,7 @@ struct ckpt_hdr_task_ns {
 
 struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
+	__s32 uts_objref;
 } __attribute__((aligned(8)));
 
 /* task's shared resources */
@@ -261,6 +267,16 @@ struct ckpt_hdr_file_pipe_state {
 	__s32 pipe_len;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_utsns {
+	struct ckpt_hdr h;
+	char sysname[__NEW_UTS_LEN + 1];
+	char nodename[__NEW_UTS_LEN + 1];
+	char release[__NEW_UTS_LEN + 1];
+	char version[__NEW_UTS_LEN + 1];
+	char machine[__NEW_UTS_LEN + 1];
+	char domainname[__NEW_UTS_LEN + 1];
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 57cbc96..0a9c58b 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -20,6 +20,10 @@
 #include <linux/ktime.h>
 #include <linux/wait.h>
 
+struct ckpt_stats {
+	int uts_ns;
+};
+
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
@@ -59,6 +63,8 @@ struct ckpt_ctx {
 	int active_pid;			/* (next) position in pids array */
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+
+	struct ckpt_stats stats;	/* statistics */
 };
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 3656b30..d6f24a9 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -50,6 +50,7 @@ static inline void get_uts_ns(struct uts_namespace *ns)
 	kref_get(&ns->kref);
 }
 
+extern struct uts_namespace *create_uts_ns(void);
 extern struct uts_namespace *copy_utsname(unsigned long flags,
 					struct uts_namespace *ns);
 extern void free_uts_ns(struct kref *kref);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 54cb987..4f48a68 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -245,6 +245,10 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0 || exists)
 		goto out;
 
+	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
+	if (ret < 0)
+		goto out;
+
 	/* TODO: collect other namespaces here */
  out:
 	put_nsproxy(nsproxy);
@@ -260,9 +264,14 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (!h)
 		return -ENOMEM;
 
+	ret = checkpoint_obj(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
+	if (ret <= 0)
+		goto out;
+	h->uts_objref = ret;
 	/* TODO: Write other namespaces here */
 
 	ret = ckpt_write_obj(ctx, &h->h);
+ out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -277,16 +286,52 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_ns *h;
 	struct nsproxy *nsproxy = NULL;
+	struct uts_namespace *uts_ns;
+	int ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
 	if (IS_ERR(h))
 		return (struct nsproxy *) h;
 
+	ret = -EINVAL;
+	if (h->uts_objref <= 0)
+		goto out;
+
+	uts_ns = ckpt_obj_fetch(ctx, h->uts_objref, CKPT_OBJ_UTS_NS);
+	if (IS_ERR(uts_ns)) {
+		ret = PTR_ERR(uts_ns);
+		goto out;
+	}
+
+#if defined(COFNIG_UTS_NS)
+	ret = -ENOMEM;
+	nsproxy = create_nsproxy();
+	if (!nsproxy)
+		goto out;
+
+	get_uts_ns(uts_ns);
+	nsproxy->uts_ns = uts_ns;
+
+	get_ipc_ns(current->nsproxy->ipc_ns);
+	nsproxy->ipc_ns = ipc_ns;
+	get_pid_ns(current->nsproxy->pid_ns);
+	nsproxy->pid_ns = current->nsproxy->pid_ns;
+	get_mnt_ns(current->nsproxy->mnt_ns);
+	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
+	get_net(current->nsproxy->net_ns);
+	nsproxy->net_ns = current->nsproxy->net_ns;
+#else
 	nsproxy = current->nsproxy;
 	get_nsproxy(nsproxy);
 
-	/* TODO: add more namespaces here */
+	BUG_ON(nsproxy->uts_ns != uts_ns);
+#endif
 
+	/* TODO: add more namespaces here */
+	ret = 0;
+ out:
+	if (ret < 0)
+		nsproxy = ERR_PTR(ret);
 	ckpt_hdr_put(ctx, h);
 	return nsproxy;
 }
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 8a82b4b..c82ed83 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -14,8 +14,9 @@
 #include <linux/utsname.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/checkpoint.h>
 
-static struct uts_namespace *create_uts_ns(void)
+struct uts_namespace *create_uts_ns(void)
 {
 	struct uts_namespace *uts_ns;
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
