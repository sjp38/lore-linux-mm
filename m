Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 522E36B00A5
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:03 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 40/43] c/r: support semaphore sysv-ipc
Date: Wed, 27 May 2009 13:33:06 -0400
Message-Id: <1243445589-32388-41-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpoint of sysvipc semaphores is performed by iterating through all
sem objects and dumping the contents of each one. The semaphore array
of each sem is dumped with that object.

The semaphore array (sem->sem_base) holds an array of 'struct sem',
which is a {int, int}. Because this translates into the same format
on 32- and 64-bit architectures, the checkpoint format is simply the
dump of this array as is.

TODO: this patch does not handle semaphore-undo -- this data should be
saved per-task while iterating through the tasks.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/checkpoint_hdr.h |    8 ++
 ipc/Makefile                   |    3 +-
 ipc/checkpoint.c               |    4 -
 ipc/checkpoint_sem.c           |  220 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    5 +
 5 files changed, 235 insertions(+), 5 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b05f39c..cd427d8 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -376,6 +376,14 @@ struct ckpt_hdr_ipc_msg_msg {
 	__u32 m_ts;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_sem {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
+	__u64 sem_otime;
+	__u64 sem_ctime;
+	__u32 sem_nsems;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/ipc/Makefile b/ipc/Makefile
index ca408ff..81af168 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,6 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o checkpoint_msg.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o \
+			checkpoint_shm.o checkpoint_msg.o checkpoint_sem.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 7eece96..f621226 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -108,12 +108,10 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
 				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
 				 CKPT_HDR_IPC_SEM, checkpoint_ipc_sem);
-#endif
 	return ret;
 }
 
@@ -220,12 +218,10 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_MSG_IDS,
 			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
 			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
-#endif
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
new file mode 100644
index 0000000..34dea40
--- /dev/null
+++ b/ipc/checkpoint_sem.c
@@ -0,0 +1,220 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc sem
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/mm.h>
+#include <linux/sem.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&sem->sem_perm);
+
+	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		goto unlock;
+
+	h->sem_otime = sem->sem_otime;
+	h->sem_ctime = sem->sem_ctime;
+	h->sem_nsems = sem->sem_nsems;
+
+ unlock:
+	ipc_unlock(&sem->sem_perm);
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	return ret;
+}
+
+/**
+ * ckpt_write_sem_array - dump the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * The state of a sempahore is an array of 'struct sem'. This structure
+ * is {int, int}, which translates to the same format {32 bits, 32 bits}
+ * on both 32- and 64-bit architectures. So we simply dump the array.
+ *
+ * The sem-undo information is not saved per ipc_ns, but rather per task.
+ */
+static int checkpoint_sem_array(struct ckpt_ctx *ctx, struct sem_array *sem)
+{
+	/* this is a "best-effort" test, so lock not needed */
+	if (!list_empty(&sem->sem_pending))
+		return -EBUSY;
+
+	/* our caller holds the mutex, so this is safe */
+	return ckpt_write_buffer(ctx, sem->sem_base,
+			       sem->sem_nsems * sizeof(*sem->sem_base));
+}
+
+int checkpoint_ipc_sem(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct sem_array *sem;
+	int ret;
+
+	sem = container_of(perm, struct sem_array, sem_perm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_sem_hdr(ctx, h, sem);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->sem_nsems)
+		ret = checkpoint_sem_array(ctx, sem);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/************************************************************************
+ * ipc restart
+ */
+
+static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	sem->sem_otime = h->sem_otime;
+	sem->sem_ctime = h->sem_ctime;
+	sem->sem_nsems = h->sem_nsems;
+
+	return 0;
+}
+
+/**
+ * ckpt_read_sem_array - read the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * Expect the data in an array of 'struct sem': {32 bit, 32 bit}.
+ * See comment in ckpt_write_sem_array().
+ *
+ * The sem-undo information is not restored per ipc_ns, but rather per task.
+ */
+static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
+{
+	struct sem *sma;
+	int i, ret;
+
+	sma = kmalloc(nsems * sizeof(*sma), GFP_KERNEL);
+	ret = _ckpt_read_buffer(ctx, sma, nsems * sizeof(*sma));
+	if (ret < 0)
+		goto out;
+
+	/* validate sem array contents */
+	for (i = 0; i < nsems; i++) {
+		if (sma[i].semval < 0 || sma[i].sempid < 0) {
+			ret = -EINVAL;
+			break;
+		}
+	}
+ out:
+	if (ret < 0) {
+		kfree(sma);
+		sma = ERR_PTR(ret);
+	}
+	return sma;
+}
+
+int restore_ipc_sem(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct kern_ipc_perm *perms;
+	struct sem_array *sem;
+	struct sem *sma = NULL;
+	struct ipc_ids *sem_ids = &current->nsproxy->ipc_ns->ids[IPC_SEM_IDS];
+	int semflag, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+	if (h->sem_nsems < 0)
+		goto out;
+
+	/* read sempahore array state */
+	sma = restore_sem_array(ctx, h->sem_nsems);
+	if (IS_ERR(sma)) {
+		ret = PTR_ERR(sma);
+		goto out;
+	}
+
+	/* restore the message queue now */
+	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
+		 h->perms.key, semflag, h->perms.id);
+	ret = do_semget(h->perms.key, h->sem_nsems, semflag, h->perms.id);
+	ckpt_debug("sem: do_msgget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&sem_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(sem_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
+
+	sem = container_of(perms, struct sem_array, sem_perm);
+	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
+
+	ret = load_ipc_sem_hdr(ctx, h, sem);
+	ipc_unlock(perms);
+
+	if (ret < 0) {
+		ckpt_debug("sem: need to remove (%d)\n", ret);
+		freeary(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&sem_ids->rw_mutex);
+ out:
+	kfree(sma);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index 347ffb2..020de7b 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -184,6 +184,8 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
 /* for checkpoint/restart */
 extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
 extern int do_msgget(key_t key, int msgflg, int req_id);
+extern int do_semget(key_t key, int nsems, int semflg, int req_id);
+
 extern void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 
@@ -200,6 +202,9 @@ extern int restore_ipc_shm(struct ckpt_ctx *ctx);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
 extern int restore_ipc_msg(struct ckpt_ctx *ctx);
+
+extern int checkpoint_ipc_sem(int id, void *p, void *data);
+extern int restore_ipc_sem(struct ckpt_ctx *ctx);
 #endif
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
