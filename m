Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C709C6B0062
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:57 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 33/43] c/r (ipc): helpers to save and restore kern_ipc_perm structures
Date: Wed, 27 May 2009 13:32:59 -0400
Message-Id: <1243445589-32388-34-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add the helpers to save and restore the contents of 'struct
kern_ipc_perm'. Add header structures for ipc state. Put
place-holders to save and restore ipc state.

TODO:
This patch does _not_ address the issues of users/groups and the
related security issues. For now, it saves the old user/group of
ipc objects, but does not restore them during restart.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/checkpoint.h     |    7 +++-
 include/linux/checkpoint_hdr.h |   29 ++++++++++++++
 ipc/Makefile                   |    1 +
 ipc/checkpoint.c               |   81 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    8 ++++
 5 files changed, 125 insertions(+), 1 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 5a42399..9a7517f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,6 +10,10 @@
  *  distribution for more details.
  */
 
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <asm/checkpoint_hdr.h>
@@ -157,8 +161,9 @@ extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 #define CKPT_DFILE	0x10		/* files and filesystem */
 #define CKPT_DMEM	0x20		/* memory state */
 #define CKPT_DPAGE	0x40		/* memory pages */
+#define CKPT_DIPC	0x80		/* sysvipc */
 
-#define CKPT_DDEFAULT	0x37		/* default debug level */
+#define CKPT_DDEFAULT	0xb7		/* default debug level */
 
 #ifndef CKPT_DFLAG
 #define CKPT_DFLAG	0x0		/* nothing */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 44a48dc..05769f4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -70,6 +70,11 @@ enum {
 	CKPT_HDR_PGARR,
 	CKPT_HDR_MM_CONTEXT,
 
+	CKPT_HDR_IPC = 501,
+	CKPT_HDR_IPC_SHM,
+	CKPT_HDR_IPC_MSG,
+	CKPT_HDR_IPC_SEM,
+
 	CKPT_HDR_TAIL = 9001,
 
 	CKPT_HDR_ERROR = 9999,
@@ -299,4 +304,28 @@ struct ckpt_hdr_pgarr {
 } __attribute__((aligned(8)));
 
 
+/* ipc commons */
+struct ckpt_hdr_ipc_perms {
+	__s32 id;
+	__u32 key;
+	__u32 uid;
+	__u32 gid;
+	__u32 cuid;
+	__u32 cgid;
+	__u32 mode;
+	__u32 _padding;
+	__u64 seq;
+} __attribute__((aligned(8)));
+
+
+#define CKPT_TST_OVERFLOW_16(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
+
+#define CKPT_TST_OVERFLOW_32(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > INT_MAX))
+
+#define CKPT_TST_OVERFLOW_64(a, b) \
+	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
+
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 4e1955e..aa6c8dd 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,4 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
new file mode 100644
index 0000000..b7b48b0
--- /dev/null
+++ b/ipc/checkpoint.c
@@ -0,0 +1,81 @@
+/*
+ *  Checkpoint logic and helpers
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
+#include <linux/ipc.h>
+#include <linux/msg.h>
+#include <linux/sched.h>
+#include <linux/ipc_namespace.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "util.h"
+
+int checkpoint_ipcns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
+{
+	return 0;
+}
+
+int restore_ipcns(struct ckpt_ctx *ctx)
+{
+	return 0;
+}
+
+int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			      struct kern_ipc_perm *perm)
+{
+	if (ipcperms(perm, S_IROTH))
+		return -EACCES;
+
+	h->id = perm->id;
+	h->key = perm->key;
+	h->uid = perm->uid;
+	h->gid = perm->gid;
+	h->cuid = perm->cuid;
+	h->cgid = perm->cgid;
+	h->mode = perm->mode & S_IRWXUGO;
+	h->seq = perm->seq;
+
+	return 0;
+}
+
+int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+			   struct kern_ipc_perm *perm)
+{
+	if (h->id < 0)
+		return -EINVAL;
+	if (CKPT_TST_OVERFLOW_16(h->uid, perm->uid) ||
+	    CKPT_TST_OVERFLOW_16(h->gid, perm->gid) ||
+	    CKPT_TST_OVERFLOW_16(h->cuid, perm->cuid) ||
+	    CKPT_TST_OVERFLOW_16(h->cgid, perm->cgid) ||
+	    CKPT_TST_OVERFLOW_16(h->mode, perm->mode))
+		return -EINVAL;
+	if (h->seq >= USHORT_MAX)
+		return -EINVAL;
+	if (h->mode & ~S_IRWXUGO)
+		return -EINVAL;
+
+	/* FIX: verify the ->mode field makes sense */
+
+	perm->id = h->id;
+	perm->key = h->key;
+#if 0 /* FIX: requires security checks */
+	perm->uid = h->uid;
+	perm->gid = h->gid;
+	perm->cuid = h->cuid;
+	perm->cgid = h->cgid;
+#endif
+	perm->mode = h->mode;
+	perm->seq = h->seq;
+
+	return 0;
+}
diff --git a/ipc/util.h b/ipc/util.h
index c75e3b2..1356909 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -11,6 +11,7 @@
 #define _IPC_UTIL_H
 
 #include <linux/err.h>
+#include <linux/checkpoint_hdr.h>
 
 #define SEQ_MULTIPLIER	(IPCMNI)
 
@@ -177,5 +178,12 @@ extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
 
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
+#ifdef CONFIG_CHECKPOINT
+extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+				     struct kern_ipc_perm *perm);
+extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+				  struct kern_ipc_perm *perm);
+#endif
+
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
