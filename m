Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1747162001F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:17:07 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 55/96] c/r: support for UTS namespace
Date: Wed, 17 Mar 2010 12:08:43 -0400
Message-Id: <1268842164-5590-56-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-51-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-52-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-53-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-54-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-55-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Dan Smith <danms@us.ibm.com>

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes[v20]:
  - Make uts_ns=n compile
Changes[v19]:
  - Restart to handle checkpoint images lacking {uts,ipc}-ns
Changes[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
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
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/Makefile              |    1 +
 checkpoint/checkpoint.c          |    5 +-
 checkpoint/namespace.c           |  116 ++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c             |   26 +++++++++
 checkpoint/process.c             |    2 +
 checkpoint/restart.c             |    6 ++
 include/linux/checkpoint.h       |    4 +
 include/linux/checkpoint_hdr.h   |   29 +++++++++-
 include/linux/checkpoint_types.h |    6 ++
 include/linux/utsname.h          |    1 +
 kernel/nsproxy.c                 |   19 ++++++-
 kernel/utsname.c                 |    3 +-
 12 files changed, 212 insertions(+), 6 deletions(-)
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
index 9bafb13..2707978 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -113,9 +113,12 @@ static void fill_kernel_const(struct ckpt_const *h)
 	/* mm->saved_auxv size */
 	h->at_vector_size = AT_VECTOR_SIZE;
 	/* uts */
+	h->uts_sysname_len = sizeof(uts->sysname);
+	h->uts_nodename_len = sizeof(uts->nodename);
 	h->uts_release_len = sizeof(uts->release);
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
+	h->uts_domainname_len = sizeof(uts->domainname);
 }
 
 /* write the checkpoint header */
@@ -261,8 +264,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
-		ret = -EPERM;
 	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
 		ret = -EPERM;
 	/* no support for >1 private mntns */
diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
new file mode 100644
index 0000000..3703577
--- /dev/null
+++ b/checkpoint/namespace.c
@@ -0,0 +1,116 @@
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
+ * uts_ns  -  this needs to compile even for !CONFIG_UTS_NS, so
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
+#ifdef CONFIG_UTS_NS
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
+{
+	struct new_utsname *name = NULL;
+	struct uts_namespace *uts_ns;
+
+	uts_ns = create_uts_ns();
+	if (!uts_ns)
+		return ERR_PTR(-ENOMEM);
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
+	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
+	memcpy(name->release, h->release, sizeof(name->release));
+	memcpy(name->version, h->version, sizeof(name->version));
+	memcpy(name->machine, h->machine, sizeof(name->machine));
+	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+	return uts_ns;
+}
+#else
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
+{
+	struct uts_namespace *uts_ns;
+
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.uts_ns)
+		return ERR_PTR(-EEXIST);
+
+	uts_ns = current->nsproxy->uts_ns;
+	get_uts_ns(uts_ns);
+	return uts_ns;
+}
+#endif
+
+static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (struct uts_namespace *) h;
+
+	uts_ns = ckpt_do_copy_uts_ns(ctx, h);
+	if (IS_ERR(uts_ns))
+		goto out;
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
index 4368e7b..a2cf082 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -138,6 +138,22 @@ static int obj_ns_users(void *ptr)
 	return atomic_read(&((struct nsproxy *) ptr)->count);
 }
 
+static int obj_uts_ns_grab(void *ptr)
+{
+	get_uts_ns((struct uts_namespace *) ptr);
+	return 0;
+}
+
+static void obj_uts_ns_drop(void *ptr, int lastref)
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
@@ -193,6 +209,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
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
index 961795f..0935cd6 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -17,8 +17,10 @@
 #include <linux/futex.h>
 #include <linux/compat.h>
 #include <linux/poll.h>
+#include <linux/utsname.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/syscalls.h>
 
 
 #ifdef CONFIG_FUTEX
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 325d03a..e66575c 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -567,12 +567,18 @@ static int check_kernel_const(struct ckpt_const *h)
 	if (h->at_vector_size != AT_VECTOR_SIZE)
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
index 22cc8f6..9f2a7ba 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -169,6 +169,10 @@ extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
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
index 7c43266..dc2cadb 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -19,8 +19,6 @@
 #include <linux/types.h>
 #endif
 
-#include <linux/utsname.h>
-
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
@@ -83,6 +81,8 @@ enum {
 #define CKPT_HDR_CPU CKPT_HDR_CPU
 	CKPT_HDR_NS,
 #define CKPT_HDR_NS CKPT_HDR_NS
+	CKPT_HDR_UTS_NS,
+#define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -142,6 +142,8 @@ enum obj_type {
 #define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
+	CKPT_OBJ_UTS_NS,
+#define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -153,9 +155,12 @@ struct ckpt_const {
 	/* mm */
 	__u16 at_vector_size;
 	/* uts */
+	__u16 uts_sysname_len;
+	__u16 uts_nodename_len;
 	__u16 uts_release_len;
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
+	__u16 uts_domainname_len;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -234,6 +239,26 @@ struct ckpt_hdr_task_ns {
 
 struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
+	__s32 uts_objref;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/tty.h> from userspace, so define: */
+#define CKPT_NEW_UTS_LEN  64
+#ifdef __KERNEL__
+#include <linux/utsname.h>
+#if CKPT_NEW_UTS_LEN != __NEW_UTS_LEN
+#error CKPT_NEW_UTS_LEN size is wrong per linux/utsname.h
+#endif
+#endif
+
+struct ckpt_hdr_utsns {
+	struct ckpt_hdr h;
+	char sysname[CKPT_NEW_UTS_LEN + 1];
+	char nodename[CKPT_NEW_UTS_LEN + 1];
+	char release[CKPT_NEW_UTS_LEN + 1];
+	char version[CKPT_NEW_UTS_LEN + 1];
+	char machine[CKPT_NEW_UTS_LEN + 1];
+	char domainname[CKPT_NEW_UTS_LEN + 1];
 } __attribute__((aligned(8)));
 
 /* task's shared resources */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 192dd86..ee35488 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -22,6 +22,10 @@
 #include <linux/ktime.h>
 #include <linux/wait.h>
 
+struct ckpt_stats {
+	int uts_ns;
+};
+
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
@@ -71,6 +75,8 @@ struct ckpt_ctx {
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
 
+	struct ckpt_stats stats;	/* statistics */
+
 #define CKPT_MSG_LEN 1024
 	char fmt[CKPT_MSG_LEN];
 	char msg[CKPT_MSG_LEN];
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 69f3997..774001d 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -49,6 +49,7 @@ static inline void get_uts_ns(struct uts_namespace *ns)
 	kref_get(&ns->kref);
 }
 
+extern struct uts_namespace *create_uts_ns(void);
 extern struct uts_namespace *copy_utsname(unsigned long flags,
 					struct uts_namespace *ns);
 extern void free_uts_ns(struct kref *kref);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index ccb4fd3..90cba48 100644
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
@@ -287,7 +296,15 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return (struct nsproxy *) h;
 
-	uts_ns = ctx->root_nsproxy->uts_ns;
+	if (h->uts_objref == 0)
+		uts_ns = ctx->root_nsproxy->uts_ns;
+	else
+		uts_ns = ckpt_obj_fetch(ctx, h->uts_objref, CKPT_OBJ_UTS_NS);
+	if (IS_ERR(uts_ns)) {
+		ret = PTR_ERR(uts_ns);
+		goto out;
+	}
+
 	ipc_ns = ctx->root_nsproxy->ipc_ns;
 	mnt_ns = ctx->root_nsproxy->mnt_ns;
 	net_ns = ctx->root_nsproxy->net_ns;
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
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
