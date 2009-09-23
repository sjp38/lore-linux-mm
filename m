Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EABC36B008C
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:46 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 53/80] c/r: support message-queues sysv-ipc
Date: Wed, 23 Sep 2009 19:51:33 -0400
Message-Id: <1253749920-18673-54-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Checkpoint of sysvipc message-queues is performed by iterating through
all 'msq' objects and dumping the contents of each one. The message
queued on each 'msq' are dumped with that object.

Message of a specific queue get written one by one. The queue lock
cannot be held while dumping them, but the loop must be protected from
someone (who ?) writing or reading. To do that we grab the lock, then
hijack the entire chain of messages from the queue, drop the lock,
and then safely dump them in a loop. Finally, with the lock held, we
re-attach the chain while verifying that there isn't other (new) data
on that queue.

Writing the message contents themselves is straight forward. The code
is similar to that in ipc/msgutil.c, the main difference being that
we deal with kernel memory and not user memory.

Changelog[v17]:
  - Allocate security context for msg_msg
  - Restore objects in the right namespace
  - Don't unlock ipc before freeing

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/checkpoint_hdr.h |   20 +++
 ipc/Makefile                   |    3 +-
 ipc/checkpoint.c               |    2 +-
 ipc/checkpoint_msg.c           |  364 ++++++++++++++++++++++++++++++++++++++++
 ipc/msg.c                      |   10 +-
 ipc/msgutil.c                  |    8 -
 ipc/util.h                     |   13 ++
 7 files changed, 403 insertions(+), 17 deletions(-)
 create mode 100644 ipc/checkpoint_msg.c

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index a4cf7a9..93b6aed 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -78,6 +78,7 @@ enum {
 	CKPT_HDR_IPC = 501,
 	CKPT_HDR_IPC_SHM,
 	CKPT_HDR_IPC_MSG,
+	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
 	CKPT_HDR_TAIL = 9001,
@@ -392,6 +393,25 @@ struct ckpt_hdr_ipc_shm {
 	__u32 objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_msg {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
+	__u64 q_stime;
+	__u64 q_rtime;
+	__u64 q_ctime;
+	__u64 q_cbytes;
+	__u64 q_qnum;
+	__u64 q_qbytes;
+	__s32 q_lspid;
+	__s32 q_lrpid;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ipc_msg_msg {
+	struct ckpt_hdr h;
+	__s32 m_type;
+	__u32 m_ts;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/ipc/Makefile b/ipc/Makefile
index db4b076..71a257f 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,4 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o checkpoint_shm.o
+obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o \
+		checkpoint_shm.o checkpoint_msg.o
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index b360861..588ed37 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -115,11 +115,11 @@ static int do_checkpoint_ipc_ns(struct ckpt_ctx *ctx,
 
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
 				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
new file mode 100644
index 0000000..b933c19
--- /dev/null
+++ b/ipc/checkpoint_msg.c
@@ -0,0 +1,364 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc msg
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
+#include <linux/msg.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/security.h>
+#include <linux/ipc_namespace.h>
+
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_msg *h,
+			    struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&msq->q_perm);
+
+	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	if (ret < 0)
+		goto unlock;
+
+	h->q_stime = msq->q_stime;
+	h->q_rtime = msq->q_rtime;
+	h->q_ctime = msq->q_ctime;
+	h->q_cbytes = msq->q_cbytes;
+	h->q_qnum = msq->q_qnum;
+	h->q_qbytes = msq->q_qbytes;
+	h->q_lspid = msq->q_lspid;
+	h->q_lrpid = msq->q_lrpid;
+
+ unlock:
+	ipc_unlock(&msq->q_perm);
+	ckpt_debug("msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
+		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
+
+	return ret;
+}
+
+static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
+{
+	struct ckpt_hdr_ipc_msg_msg *h;
+	struct msg_msgseg *seg;
+	int total, len;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
+	if (!h)
+		return -ENOMEM;
+
+	h->m_type = msg->m_type;
+	h->m_ts = msg->m_ts;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	total = msg->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	ret = ckpt_write_buffer(ctx, (msg + 1), len);
+	if (ret < 0)
+		return ret;
+
+	seg = msg->next;
+	total -= len;
+
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		ret = ckpt_write_buffer(ctx, (seg + 1), len);
+		if (ret < 0)
+			break;
+		seg = seg->next;
+		total -= len;
+	}
+
+	return ret;
+}
+
+static int checkpoint_msg_queue(struct ckpt_ctx *ctx, struct msg_queue *msq)
+{
+	struct list_head messages;
+	struct msg_msg *msg;
+	int ret = -EBUSY;
+
+	/*
+	 * Scanning the msq requires the lock, but then we can't write
+	 * data out from inside. Instead, we grab the lock, remove all
+	 * messages to our own list, drop the lock, write the messages,
+	 * and finally re-attach the them to the msq with the lock taken.
+	 */
+	ipc_lock_by_ptr(&msq->q_perm);
+	if (!list_empty(&msq->q_receivers))
+		goto unlock;
+	if (!list_empty(&msq->q_senders))
+		goto unlock;
+	if (list_empty(&msq->q_messages))
+		goto unlock;
+	/* temporarily take out all messages */
+	INIT_LIST_HEAD(&messages);
+	list_splice_init(&msq->q_messages, &messages);
+ unlock:
+	ipc_unlock(&msq->q_perm);
+
+	list_for_each_entry(msg, &messages, m_list) {
+		ret = checkpoint_msg_contents(ctx, msg);
+		if (ret < 0)
+			break;
+	}
+
+	/* put all the messages back in */
+	ipc_lock_by_ptr(&msq->q_perm);
+	list_splice(&messages, &msq->q_messages);
+	ipc_unlock(&msq->q_perm);
+
+	return ret;
+}
+
+int checkpoint_ipc_msg(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_msg *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct msg_queue *msq;
+	int ret;
+
+	msq = container_of(perm, struct msg_queue, q_perm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_msg_hdr(ctx, h, msq);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->q_qnum)
+		ret = checkpoint_msg_queue(ctx, msq);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+
+/************************************************************************
+ * ipc restart
+ */
+
+static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_msg *h,
+			    struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
+		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
+
+	if (h->q_lspid < 0 || h->q_lrpid < 0)
+		return -EINVAL;
+
+	msq->q_stime = h->q_stime;
+	msq->q_rtime = h->q_rtime;
+	msq->q_ctime = h->q_ctime;
+	msq->q_lspid = h->q_lspid;
+	msq->q_lrpid = h->q_lrpid;
+
+	return 0;
+}
+
+static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
+{
+	struct ckpt_hdr_ipc_msg_msg *h;
+	struct msg_msg *msg = NULL;
+	struct msg_msgseg *seg, **pseg;
+	int total, len;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
+	if (IS_ERR(h))
+		return (struct msg_msg *) h;
+
+	ret = -EINVAL;
+	if (h->m_type < 1)
+		goto out;
+	if (h->m_ts > current->nsproxy->ipc_ns->msg_ctlmax)
+		goto out;
+
+	total = h->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	msg = kmalloc(sizeof(*msg) + len, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	msg->next = NULL;
+	pseg = &msg->next;
+
+	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
+	if (ret < 0)
+		goto out;
+
+	total -= len;
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		seg = kmalloc(sizeof(*seg) + len, GFP_KERNEL);
+		if (!seg) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		seg->next = NULL;
+		*pseg = seg;
+		pseg = &seg->next;
+
+		ret = _ckpt_read_buffer(ctx, (seg + 1), len);
+		if (ret < 0)
+			goto out;
+		total -= len;
+	}
+
+	msg->m_type = h->m_type;
+	msg->m_ts = h->m_ts;
+	*clen = h->m_ts;
+	ret = security_msg_msg_alloc(msg);
+ out:
+	if (ret < 0 && msg) {
+		free_msg(msg);
+		msg = ERR_PTR(ret);
+	}
+	ckpt_hdr_put(ctx, h);
+	return msg;
+}
+
+static inline void free_msg_list(struct list_head *queue)
+{
+	struct msg_msg *msg, *tmp;
+
+	list_for_each_entry_safe(msg, tmp, queue, m_list)
+		free_msg(msg);
+}
+
+static int restore_msg_contents(struct ckpt_ctx *ctx, struct list_head *queue,
+				unsigned long qnum, unsigned long *cbytes)
+{
+	struct msg_msg *msg;
+	int clen = 0;
+	int ret = 0;
+
+	INIT_LIST_HEAD(queue);
+
+	*cbytes = 0;
+	while (qnum--) {
+		msg = restore_msg_contents_one(ctx, &clen);
+		if (IS_ERR(msg))
+			goto fail;
+		list_add_tail(&msg->m_list, queue);
+		*cbytes += clen;
+	}
+	return 0;
+ fail:
+	ret = PTR_ERR(msg);
+	free_msg_list(queue);
+	return ret;
+}
+
+int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
+{
+	struct ckpt_hdr_ipc_msg *h;
+	struct kern_ipc_perm *perms;
+	struct msg_queue *msq;
+	struct ipc_ids *msg_ids = &ns->ids[IPC_MSG_IDS];
+	struct list_head messages;
+	unsigned long cbytes;
+	int msgflag;
+	int ret;
+
+	INIT_LIST_HEAD(&messages);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+
+	/* read queued messages into temporary queue */
+	ret = restore_msg_contents(ctx, &messages, h->q_qnum, &cbytes);
+	if (ret < 0)
+		goto out;
+
+	ret = -EINVAL;
+	if (h->q_cbytes != cbytes)
+		goto out;
+
+	/* restore the message queue */
+	msgflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("msg: do_msgget key %d flag %#x id %d\n",
+		 h->perms.key, msgflag, h->perms.id);
+	ret = do_msgget(ns, h->perms.key, msgflag, h->perms.id);
+	ckpt_debug("msg: do_msgget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&msg_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(msg_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));	/* ipc_ns is private to us */
+
+	msq = container_of(perms, struct msg_queue, q_perm);
+	BUG_ON(!list_empty(&msq->q_messages));	/* ipc_ns is private to us */
+
+	/* attach queued messages we read before */
+	list_splice_init(&messages, &msq->q_messages);
+
+	/* adjust msq and namespace statistics */
+	atomic_add(h->q_cbytes, &ns->msg_bytes);
+	atomic_add(h->q_qnum, &ns->msg_hdrs);
+	msq->q_cbytes = h->q_cbytes;
+	msq->q_qbytes = h->q_qbytes;
+	msq->q_qnum = h->q_qnum;
+
+	ret = load_ipc_msg_hdr(ctx, h, msq);
+
+	if (ret < 0) {
+		ckpt_debug("msq: need to remove (%d)\n", ret);
+		freeque(ns, perms);
+	} else
+		ipc_unlock(perms);
+	up_write(&msg_ids->rw_mutex);
+ out:
+	free_msg_list(&messages);  /* no-op if all ok, else cleanup msgs */
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/msg.c b/ipc/msg.c
index 1db7c45..3559d53 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -72,7 +72,6 @@ struct msg_sender {
 
 #define msg_unlock(msq)		ipc_unlock(&(msq)->q_perm)
 
-static void freeque(struct ipc_namespace *, struct kern_ipc_perm *);
 static int newque(struct ipc_namespace *, struct ipc_params *, int);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_msg_proc_show(struct seq_file *s, void *it);
@@ -278,7 +277,7 @@ static void expunge_all(struct msg_queue *msq, int res)
  * msg_ids.rw_mutex (writer) and the spinlock for this message queue are held
  * before freeque() is called. msg_ids.rw_mutex remains locked on exit.
  */
-static void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
+void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
 	struct list_head *tmp;
 	struct msg_queue *msq = container_of(ipcp, struct msg_queue, q_perm);
@@ -311,14 +310,11 @@ static inline int msg_security(struct kern_ipc_perm *ipcp, int msgflg)
 	return security_msg_queue_associate(msq, msgflg);
 }
 
-int do_msgget(key_t key, int msgflg, int req_id)
+int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg, int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops msg_ops;
 	struct ipc_params msg_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	msg_ops.getnew = newque;
 	msg_ops.associate = msg_security;
 	msg_ops.more_checks = NULL;
@@ -331,7 +327,7 @@ int do_msgget(key_t key, int msgflg, int req_id)
 
 SYSCALL_DEFINE2(msgget, key_t, key, int, msgflg)
 {
-	return do_msgget(key, msgflg, -1);
+	return do_msgget(current->nsproxy->ipc_ns, key, msgflg, -1);
 }
 
 static inline unsigned long
diff --git a/ipc/msgutil.c b/ipc/msgutil.c
index f095ee2..e119243 100644
--- a/ipc/msgutil.c
+++ b/ipc/msgutil.c
@@ -36,14 +36,6 @@ struct ipc_namespace init_ipc_ns = {
 
 atomic_t nr_ipc_ns = ATOMIC_INIT(1);
 
-struct msg_msgseg {
-	struct msg_msgseg* next;
-	/* the next part of the message follows immediately */
-};
-
-#define DATALEN_MSG	(PAGE_SIZE-sizeof(struct msg_msg))
-#define DATALEN_SEG	(PAGE_SIZE-sizeof(struct msg_msgseg))
-
 struct msg_msg *load_msg(const void __user *src, int len)
 {
 	struct msg_msg *msg;
diff --git a/ipc/util.h b/ipc/util.h
index e0007dc..8a223f0 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -141,6 +141,14 @@ extern void free_msg(struct msg_msg *msg);
 extern struct msg_msg *load_msg(const void __user *src, int len);
 extern int store_msg(void __user *dest, struct msg_msg *msg, int len);
 
+struct msg_msgseg {
+	struct msg_msgseg *next;
+	/* the next part of the message follows immediately */
+};
+
+#define DATALEN_MSG	(PAGE_SIZE-sizeof(struct msg_msg))
+#define DATALEN_SEG	(PAGE_SIZE-sizeof(struct msg_msgseg))
+
 extern void recompute_msgmni(struct ipc_namespace *);
 
 static inline int ipc_buildid(int id, int seq)
@@ -182,6 +190,8 @@ int do_shmget(struct ipc_namespace *ns, key_t key, size_t size, int shmflg,
 	      int req_id);
 void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
+int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg, int req_id);
+void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 #ifdef CONFIG_CHECKPOINT
 extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
@@ -192,6 +202,9 @@ extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 extern int ckpt_collect_ipc_shm(int id, void *p, void *data);
 extern int checkpoint_ipc_shm(int id, void *p, void *data);
 extern int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
+
+extern int checkpoint_ipc_msg(int id, void *p, void *data);
+extern int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
 #endif
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
