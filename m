Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6956B0099
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:59 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 38/43] c/r: support message-queues sysv-ipc
Date: Wed, 27 May 2009 13:33:04 -0400
Message-Id: <1243445589-32388-39-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
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

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/checkpoint_hdr.h |   21 +++-
 ipc/Makefile                   |    2 +-
 ipc/checkpoint.c               |    6 +-
 ipc/checkpoint_msg.c           |  362 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    3 +
 5 files changed, 389 insertions(+), 5 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f7e331d..b05f39c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -73,6 +73,7 @@ enum {
 	CKPT_HDR_IPC = 501,
 	CKPT_HDR_IPC_SHM,
 	CKPT_HDR_IPC_MSG,
+	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
 	CKPT_HDR_TAIL = 9001,
@@ -356,6 +357,25 @@ struct ckpt_hdr_ipc_shm {
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
@@ -366,5 +386,4 @@ struct ckpt_hdr_ipc_shm {
 #define CKPT_TST_OVERFLOW_64(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
 
-
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 7e23683..ca408ff 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o checkpoint_msg.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 25d2277..7eece96 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -104,11 +104,11 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 
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
@@ -216,11 +216,11 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 
 	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
-	ret = ckpt_read_ipc_any(ctx, IPC_MSG_IDS,
+	ret = restore_ipc_any(ctx, IPC_MSG_IDS,
 			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
new file mode 100644
index 0000000..a988a9e
--- /dev/null
+++ b/ipc/checkpoint_msg.c
@@ -0,0 +1,362 @@
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
+int restore_ipc_msg(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_msg *h;
+	struct kern_ipc_perm *perms;
+	struct msg_queue *msq;
+	struct ipc_ids *msg_ids = &current->nsproxy->ipc_ns->ids[IPC_MSG_IDS];
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
+	ret = do_msgget(h->perms.key, msgflag, h->perms.id);
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
+	atomic_add(h->q_cbytes, &current->nsproxy->ipc_ns->msg_bytes);
+	atomic_add(h->q_qnum, &current->nsproxy->ipc_ns->msg_hdrs);
+	msq->q_cbytes = h->q_cbytes;
+	msq->q_qbytes = h->q_qbytes;
+	msq->q_qnum = h->q_qnum;
+
+	ret = load_ipc_msg_hdr(ctx, h, msq);
+	ipc_unlock(perms);
+
+	if (ret < 0) {
+		ckpt_debug("msq: need to remove (%d)\n", ret);
+		freeque(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&msg_ids->rw_mutex);
+ out:
+	free_msg_list(&messages);  /* no-op if all ok, else cleanup msgs */
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index db067b0..2a05fb3 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -196,6 +196,9 @@ extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 
 extern int checkpoint_ipc_shm(int id, void *p, void *data);
 extern int restore_ipc_shm(struct ckpt_ctx *ctx);
+
+extern int checkpoint_ipc_msg(int id, void *p, void *data);
+extern int restore_ipc_msg(struct ckpt_ctx *ctx);
 #endif
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
