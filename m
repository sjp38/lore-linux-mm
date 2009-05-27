Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B23E86B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:57 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 32/43] c/r (ipc): allow allocation of a desired ipc identifier
Date: Wed, 27 May 2009 13:32:58 -0400
Message-Id: <1243445589-32388-33-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

During restart, we need to allocate ipc objects that with the same
identifiers as recorded during checkpoint. Modify the allocation
code allow an in-kernel caller to request a specific ipc identifier.
The system call interface remains unchanged.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 ipc/msg.c  |   17 ++++++++++++-----
 ipc/sem.c  |   17 ++++++++++++-----
 ipc/shm.c  |   19 +++++++++++++------
 ipc/util.c |   42 +++++++++++++++++++++++++++++-------------
 ipc/util.h |   12 +++++++++---
 5 files changed, 75 insertions(+), 32 deletions(-)

diff --git a/ipc/msg.c b/ipc/msg.c
index 2ceab7f..1db7c45 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -73,7 +73,7 @@ struct msg_sender {
 #define msg_unlock(msq)		ipc_unlock(&(msq)->q_perm)
 
 static void freeque(struct ipc_namespace *, struct kern_ipc_perm *);
-static int newque(struct ipc_namespace *, struct ipc_params *);
+static int newque(struct ipc_namespace *, struct ipc_params *, int);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_msg_proc_show(struct seq_file *s, void *it);
 #endif
@@ -174,10 +174,12 @@ static inline void msg_rmid(struct ipc_namespace *ns, struct msg_queue *s)
  * newque - Create a new msg queue
  * @ns: namespace
  * @params: ptr to the structure that contains the key and msgflg
+ * @req_id: request desired id if available (-1 if don't care)
  *
  * Called with msg_ids.rw_mutex held (writer)
  */
-static int newque(struct ipc_namespace *ns, struct ipc_params *params)
+static int
+newque(struct ipc_namespace *ns, struct ipc_params *params, int req_id)
 {
 	struct msg_queue *msq;
 	int id, retval;
@@ -201,7 +203,7 @@ static int newque(struct ipc_namespace *ns, struct ipc_params *params)
 	/*
 	 * ipc_addid() locks msq
 	 */
-	id = ipc_addid(&msg_ids(ns), &msq->q_perm, ns->msg_ctlmni);
+	id = ipc_addid(&msg_ids(ns), &msq->q_perm, ns->msg_ctlmni, req_id);
 	if (id < 0) {
 		security_msg_queue_free(msq);
 		ipc_rcu_putref(msq);
@@ -309,7 +311,7 @@ static inline int msg_security(struct kern_ipc_perm *ipcp, int msgflg)
 	return security_msg_queue_associate(msq, msgflg);
 }
 
-SYSCALL_DEFINE2(msgget, key_t, key, int, msgflg)
+int do_msgget(key_t key, int msgflg, int req_id)
 {
 	struct ipc_namespace *ns;
 	struct ipc_ops msg_ops;
@@ -324,7 +326,12 @@ SYSCALL_DEFINE2(msgget, key_t, key, int, msgflg)
 	msg_params.key = key;
 	msg_params.flg = msgflg;
 
-	return ipcget(ns, &msg_ids(ns), &msg_ops, &msg_params);
+	return ipcget(ns, &msg_ids(ns), &msg_ops, &msg_params, req_id);
+}
+
+SYSCALL_DEFINE2(msgget, key_t, key, int, msgflg)
+{
+	return do_msgget(key, msgflg, -1);
 }
 
 static inline unsigned long
diff --git a/ipc/sem.c b/ipc/sem.c
index 16a2189..207dbbb 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -92,7 +92,7 @@
 #define sem_unlock(sma)		ipc_unlock(&(sma)->sem_perm)
 #define sem_checkid(sma, semid)	ipc_checkid(&sma->sem_perm, semid)
 
-static int newary(struct ipc_namespace *, struct ipc_params *);
+static int newary(struct ipc_namespace *, struct ipc_params *, int);
 static void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it);
@@ -227,11 +227,13 @@ static inline void sem_rmid(struct ipc_namespace *ns, struct sem_array *s)
  * newary - Create a new semaphore set
  * @ns: namespace
  * @params: ptr to the structure that contains key, semflg and nsems
+ * @req_id: request desired id if available (-1 if don't care)
  *
  * Called with sem_ids.rw_mutex held (as a writer)
  */
 
-static int newary(struct ipc_namespace *ns, struct ipc_params *params)
+static int
+newary(struct ipc_namespace *ns, struct ipc_params *params, int req_id)
 {
 	int id;
 	int retval;
@@ -263,7 +265,7 @@ static int newary(struct ipc_namespace *ns, struct ipc_params *params)
 		return retval;
 	}
 
-	id = ipc_addid(&sem_ids(ns), &sma->sem_perm, ns->sc_semmni);
+	id = ipc_addid(&sem_ids(ns), &sma->sem_perm, ns->sc_semmni, req_id);
 	if (id < 0) {
 		security_sem_free(sma);
 		ipc_rcu_putref(sma);
@@ -308,7 +310,7 @@ static inline int sem_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
+int do_semget(key_t key, int nsems, int semflg, int req_id)
 {
 	struct ipc_namespace *ns;
 	struct ipc_ops sem_ops;
@@ -327,7 +329,12 @@ SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
 	sem_params.flg = semflg;
 	sem_params.u.nsems = nsems;
 
-	return ipcget(ns, &sem_ids(ns), &sem_ops, &sem_params);
+	return ipcget(ns, &sem_ids(ns), &sem_ops, &sem_params, req_id);
+}
+
+SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
+{
+	return do_semget(key, nsems, semflg, -1);
 }
 
 /*
diff --git a/ipc/shm.c b/ipc/shm.c
index faa46da..7dd5f0c 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -62,7 +62,7 @@ static struct vm_operations_struct shm_vm_ops;
 #define shm_unlock(shp)			\
 	ipc_unlock(&(shp)->shm_perm)
 
-static int newseg(struct ipc_namespace *, struct ipc_params *);
+static int newseg(struct ipc_namespace *, struct ipc_params *, int);
 static void shm_open(struct vm_area_struct *vma);
 static void shm_close(struct vm_area_struct *vma);
 static void shm_destroy (struct ipc_namespace *ns, struct shmid_kernel *shp);
@@ -83,7 +83,7 @@ void shm_init_ns(struct ipc_namespace *ns)
  * Called with shm_ids.rw_mutex (writer) and the shp structure locked.
  * Only shm_ids.rw_mutex remains locked on exit.
  */
-static void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
+void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
 	struct shmid_kernel *shp;
 	shp = container_of(ipcp, struct shmid_kernel, shm_perm);
@@ -326,11 +326,13 @@ static struct vm_operations_struct shm_vm_ops = {
  * newseg - Create a new shared memory segment
  * @ns: namespace
  * @params: ptr to the structure that contains key, size and shmflg
+ * @req_id: request desired id if available (-1 if don't care)
  *
  * Called with shm_ids.rw_mutex held as a writer.
  */
 
-static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
+static int
+newseg(struct ipc_namespace *ns, struct ipc_params *params, int req_id)
 {
 	key_t key = params->key;
 	int shmflg = params->flg;
@@ -386,7 +388,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 		goto no_file;
 	ima_shm_check(file);
 
-	id = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni);
+	id = ipc_addid(&shm_ids(ns), &shp->shm_perm, ns->shm_ctlmni, req_id);
 	if (id < 0) {
 		error = id;
 		goto no_id;
@@ -444,7 +446,7 @@ static inline int shm_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-SYSCALL_DEFINE3(shmget, key_t, key, size_t, size, int, shmflg)
+int do_shmget(key_t key, size_t size, int shmflg, int req_id)
 {
 	struct ipc_namespace *ns;
 	struct ipc_ops shm_ops;
@@ -460,7 +462,12 @@ SYSCALL_DEFINE3(shmget, key_t, key, size_t, size, int, shmflg)
 	shm_params.flg = shmflg;
 	shm_params.u.size = size;
 
-	return ipcget(ns, &shm_ids(ns), &shm_ops, &shm_params);
+	return ipcget(ns, &shm_ids(ns), &shm_ops, &shm_params, req_id);
+}
+
+SYSCALL_DEFINE3(shmget, key_t, key, size_t, size, int, shmflg)
+{
+	return do_shmget(key, size, shmflg, -1);
 }
 
 static inline unsigned long copy_shmid_to_user(void __user *buf, struct shmid64_ds *in, int version)
diff --git a/ipc/util.c b/ipc/util.c
index b8e4ba9..ca248ec 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -247,10 +247,12 @@ int ipc_get_maxid(struct ipc_ids *ids)
  *	Called with ipc_ids.rw_mutex held as a writer.
  */
  
-int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
+int
+ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int size, int req_id)
 {
 	uid_t euid;
 	gid_t egid;
+	int lid = 0;
 	int id, err;
 
 	if (size > IPCMNI)
@@ -259,28 +261,41 @@ int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
 	if (ids->in_use >= size)
 		return -ENOSPC;
 
+	if (req_id >= 0)
+		lid = ipcid_to_idx(req_id);
+
 	spin_lock_init(&new->lock);
 	new->deleted = 0;
 	rcu_read_lock();
 	spin_lock(&new->lock);
 
-	err = idr_get_new(&ids->ipcs_idr, new, &id);
+	err = idr_get_new_above(&ids->ipcs_idr, new, lid, &id);
 	if (err) {
 		spin_unlock(&new->lock);
 		rcu_read_unlock();
 		return err;
 	}
 
+	if (req_id >= 0) {
+		if (id != lid) {
+			idr_remove(&ids->ipcs_idr, id);
+			spin_unlock(&new->lock);
+			rcu_read_unlock();
+			return -EBUSY;
+		}
+		new->seq = req_id / SEQ_MULTIPLIER;
+	} else {
+		new->seq = ids->seq++;
+		if (ids->seq > ids->seq_max)
+			ids->seq = 0;
+	}
+
 	ids->in_use++;
 
 	current_euid_egid(&euid, &egid);
 	new->cuid = new->uid = euid;
 	new->gid = new->cgid = egid;
 
-	new->seq = ids->seq++;
-	if(ids->seq > ids->seq_max)
-		ids->seq = 0;
-
 	new->id = ipc_buildid(id, new->seq);
 	return id;
 }
@@ -296,7 +311,7 @@ int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
  *	when the key is IPC_PRIVATE.
  */
 static int ipcget_new(struct ipc_namespace *ns, struct ipc_ids *ids,
-		struct ipc_ops *ops, struct ipc_params *params)
+		struct ipc_ops *ops, struct ipc_params *params, int req_id)
 {
 	int err;
 retry:
@@ -306,7 +321,7 @@ retry:
 		return -ENOMEM;
 
 	down_write(&ids->rw_mutex);
-	err = ops->getnew(ns, params);
+	err = ops->getnew(ns, params, req_id);
 	up_write(&ids->rw_mutex);
 
 	if (err == -EAGAIN)
@@ -351,6 +366,7 @@ static int ipc_check_perms(struct kern_ipc_perm *ipcp, struct ipc_ops *ops,
  *	@ids: IPC identifer set
  *	@ops: the actual creation routine to call
  *	@params: its parameters
+ *	@req_id: request desired id if available (-1 if don't care)
  *
  *	This routine is called by sys_msgget, sys_semget() and sys_shmget()
  *	when the key is not IPC_PRIVATE.
@@ -360,7 +376,7 @@ static int ipc_check_perms(struct kern_ipc_perm *ipcp, struct ipc_ops *ops,
  *	On success, the ipc id is returned.
  */
 static int ipcget_public(struct ipc_namespace *ns, struct ipc_ids *ids,
-		struct ipc_ops *ops, struct ipc_params *params)
+		struct ipc_ops *ops, struct ipc_params *params, int req_id)
 {
 	struct kern_ipc_perm *ipcp;
 	int flg = params->flg;
@@ -381,7 +397,7 @@ retry:
 		else if (!err)
 			err = -ENOMEM;
 		else
-			err = ops->getnew(ns, params);
+			err = ops->getnew(ns, params, req_id);
 	} else {
 		/* ipc object has been locked by ipc_findkey() */
 
@@ -742,12 +758,12 @@ struct kern_ipc_perm *ipc_lock_check(struct ipc_ids *ids, int id)
  * Common routine called by sys_msgget(), sys_semget() and sys_shmget().
  */
 int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
-			struct ipc_ops *ops, struct ipc_params *params)
+		struct ipc_ops *ops, struct ipc_params *params, int req_id)
 {
 	if (params->key == IPC_PRIVATE)
-		return ipcget_new(ns, ids, ops, params);
+		return ipcget_new(ns, ids, ops, params, req_id);
 	else
-		return ipcget_public(ns, ids, ops, params);
+		return ipcget_public(ns, ids, ops, params, req_id);
 }
 
 /**
diff --git a/ipc/util.h b/ipc/util.h
index 1187332..c75e3b2 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -70,7 +70,7 @@ struct ipc_params {
  *      . routine to call for an extra check if needed
  */
 struct ipc_ops {
-	int (*getnew) (struct ipc_namespace *, struct ipc_params *);
+	int (*getnew) (struct ipc_namespace *, struct ipc_params *, int);
 	int (*associate) (struct kern_ipc_perm *, int);
 	int (*more_checks) (struct kern_ipc_perm *, struct ipc_params *);
 };
@@ -93,7 +93,7 @@ void __init ipc_init_proc_interface(const char *path, const char *header,
 #define ipcid_to_idx(id) ((id) % SEQ_MULTIPLIER)
 
 /* must be called with ids->rw_mutex acquired for writing */
-int ipc_addid(struct ipc_ids *, struct kern_ipc_perm *, int);
+int ipc_addid(struct ipc_ids *, struct kern_ipc_perm *, int, int);
 
 /* must be called with ids->rw_mutex acquired for reading */
 int ipc_get_maxid(struct ipc_ids *);
@@ -170,6 +170,12 @@ static inline void ipc_unlock(struct kern_ipc_perm *perm)
 
 struct kern_ipc_perm *ipc_lock_check(struct ipc_ids *ids, int id);
 int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
-			struct ipc_ops *ops, struct ipc_params *params);
+		struct ipc_ops *ops, struct ipc_params *params, int req_id);
+
+/* for checkpoint/restart */
+extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
+
+extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
+
 
 #endif
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
