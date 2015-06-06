Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 914A4900016
	for <linux-mm@kvack.org>; Sat,  6 Jun 2015 09:38:23 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so70835403pdj.3
        for <linux-mm@kvack.org>; Sat, 06 Jun 2015 06:38:23 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id sq1si15133958pab.156.2015.06.06.06.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Jun 2015 06:38:20 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 3/5] ipc: rename ipc_obtain_object
Date: Sat,  6 Jun 2015 06:37:58 -0700
Message-Id: <1433597880-8571-4-git-send-email-dave@stgolabs.net>
In-Reply-To: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
References: <1433597880-8571-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

... to ipc_obtain_object_idr, which is more meaningful
and makes the code slightly easier to follow.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 ipc/msg.c  | 2 +-
 ipc/sem.c  | 4 ++--
 ipc/shm.c  | 2 +-
 ipc/util.c | 8 ++++----
 ipc/util.h | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index a9c3c51..66c4f56 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -76,7 +76,7 @@ struct msg_sender {
 
 static inline struct msg_queue *msq_obtain_object(struct ipc_namespace *ns, int id)
 {
-	struct kern_ipc_perm *ipcp = ipc_obtain_object(&msg_ids(ns), id);
+	struct kern_ipc_perm *ipcp = ipc_obtain_object_idr(&msg_ids(ns), id);
 
 	if (IS_ERR(ipcp))
 		return ERR_CAST(ipcp);
diff --git a/ipc/sem.c b/ipc/sem.c
index d1a6edd..bc3d530 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -391,7 +391,7 @@ static inline struct sem_array *sem_obtain_lock(struct ipc_namespace *ns,
 	struct kern_ipc_perm *ipcp;
 	struct sem_array *sma;
 
-	ipcp = ipc_obtain_object(&sem_ids(ns), id);
+	ipcp = ipc_obtain_object_idr(&sem_ids(ns), id);
 	if (IS_ERR(ipcp))
 		return ERR_CAST(ipcp);
 
@@ -410,7 +410,7 @@ static inline struct sem_array *sem_obtain_lock(struct ipc_namespace *ns,
 
 static inline struct sem_array *sem_obtain_object(struct ipc_namespace *ns, int id)
 {
-	struct kern_ipc_perm *ipcp = ipc_obtain_object(&sem_ids(ns), id);
+	struct kern_ipc_perm *ipcp = ipc_obtain_object_idr(&sem_ids(ns), id);
 
 	if (IS_ERR(ipcp))
 		return ERR_CAST(ipcp);
diff --git a/ipc/shm.c b/ipc/shm.c
index 6dbac3b..3323c49 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -129,7 +129,7 @@ void __init shm_init(void)
 
 static inline struct shmid_kernel *shm_obtain_object(struct ipc_namespace *ns, int id)
 {
-	struct kern_ipc_perm *ipcp = ipc_obtain_object(&shm_ids(ns), id);
+	struct kern_ipc_perm *ipcp = ipc_obtain_object_idr(&shm_ids(ns), id);
 
 	if (IS_ERR(ipcp))
 		return ERR_CAST(ipcp);
diff --git a/ipc/util.c b/ipc/util.c
index ff3323e..adb8f89 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -558,7 +558,7 @@ void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out)
  * Call inside the RCU critical section.
  * The ipc object is *not* locked on exit.
  */
-struct kern_ipc_perm *ipc_obtain_object(struct ipc_ids *ids, int id)
+struct kern_ipc_perm *ipc_obtain_object_idr(struct ipc_ids *ids, int id)
 {
 	struct kern_ipc_perm *out;
 	int lid = ipcid_to_idx(id);
@@ -584,7 +584,7 @@ struct kern_ipc_perm *ipc_lock(struct ipc_ids *ids, int id)
 	struct kern_ipc_perm *out;
 
 	rcu_read_lock();
-	out = ipc_obtain_object(ids, id);
+	out = ipc_obtain_object_idr(ids, id);
 	if (IS_ERR(out))
 		goto err1;
 
@@ -608,7 +608,7 @@ err1:
  * @ids: ipc identifier set
  * @id: ipc id to look for
  *
- * Similar to ipc_obtain_object() but also checks
+ * Similar to ipc_obtain_object_idr() but also checks
  * the ipc object reference counter.
  *
  * Call inside the RCU critical section.
@@ -616,7 +616,7 @@ err1:
  */
 struct kern_ipc_perm *ipc_obtain_object_check(struct ipc_ids *ids, int id)
 {
-	struct kern_ipc_perm *out = ipc_obtain_object(ids, id);
+	struct kern_ipc_perm *out = ipc_obtain_object_idr(ids, id);
 
 	if (IS_ERR(out))
 		goto out;
diff --git a/ipc/util.h b/ipc/util.h
index 1a5a0fc..3a8a5a0 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -132,7 +132,7 @@ void ipc_rcu_putref(void *ptr, void (*func)(struct rcu_head *head));
 void ipc_rcu_free(struct rcu_head *head);
 
 struct kern_ipc_perm *ipc_lock(struct ipc_ids *, int);
-struct kern_ipc_perm *ipc_obtain_object(struct ipc_ids *ids, int id);
+struct kern_ipc_perm *ipc_obtain_object_idr(struct ipc_ids *ids, int id);
 
 void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
 void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
