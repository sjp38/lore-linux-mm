Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A196A6B009A
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:59 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 39/43] c/r (ipc): export interface from ipc/sem.c to cleanup ipc sem
Date: Wed, 27 May 2009 13:33:05 -0400
Message-Id: <1243445589-32388-40-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Export freeary() which will be used in the next patch during restart
to cleanup an ipc sem.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 ipc/sem.c  |    3 +--
 ipc/util.h |    1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ipc/sem.c b/ipc/sem.c
index 207dbbb..c60076e 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -93,7 +93,6 @@
 #define sem_checkid(sma, semid)	ipc_checkid(&sma->sem_perm, semid)
 
 static int newary(struct ipc_namespace *, struct ipc_params *, int);
-static void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it);
 #endif
@@ -521,7 +520,7 @@ static void free_un(struct rcu_head *head)
  * as a writer and the spinlock for this semaphore set hold. sem_ids.rw_mutex
  * remains locked on exit.
  */
-static void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
+void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
 	struct sem_undo *un, *tu;
 	struct sem_queue *q, *tq;
diff --git a/ipc/util.h b/ipc/util.h
index 2a05fb3..347ffb2 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -185,6 +185,7 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
 extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
 extern int do_msgget(key_t key, int msgflg, int req_id);
 extern void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
+extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
