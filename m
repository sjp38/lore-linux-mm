Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7B416B0098
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:58 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 37/43] c/r (ipc): make 'struct msg_msgseg' visible in ipc/util.h
Date: Wed, 27 May 2009 13:33:03 -0400
Message-Id: <1243445589-32388-38-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Move the definition of 'struct msg_msgseg' and constants DATALEN_*
to ipc/util.h, where they are visible to ipc/ckpt_msg.c

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 ipc/msg.c     |    3 +--
 ipc/msgutil.c |    8 --------
 ipc/util.h    |   10 ++++++++++
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 1db7c45..1d5d087 100644
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
index 5a6373f..db067b0 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -140,6 +140,14 @@ extern void free_msg(struct msg_msg *msg);
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
@@ -175,6 +183,8 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
 
 /* for checkpoint/restart */
 extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
+extern int do_msgget(key_t key, int msgflg, int req_id);
+extern void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
