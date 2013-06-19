Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3F6C86B004D
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:19:05 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 10/11] ipc,msg: drop msg_unlock
Date: Tue, 18 Jun 2013 18:18:35 -0700
Message-Id: <1371604716-3439-11-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

There is only one user left, drop this function and just call
ipc_unlock_object() and rcu_read_unlock().

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/msg.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 80d8aa7..091fa2b 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -70,8 +70,6 @@ struct msg_sender {
 
 #define msg_ids(ns)	((ns)->ids[IPC_MSG_IDS])
 
-#define msg_unlock(msq)		ipc_unlock(&(msq)->q_perm)
-
 static void freeque(struct ipc_namespace *, struct kern_ipc_perm *);
 static int newque(struct ipc_namespace *, struct ipc_params *);
 #ifdef CONFIG_PROC_FS
@@ -270,7 +268,8 @@ static void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 	expunge_all(msq, -EIDRM);
 	ss_wakeup(&msq->q_senders, 1);
 	msg_rmid(ns, msq);
-	msg_unlock(msq);
+	ipc_unlock_object(&msq->q_perm);
+	rcu_read_unlock();
 
 	list_for_each_entry_safe(msg, t, &msq->q_messages, m_list) {
 		atomic_dec(&ns->msg_hdrs);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
