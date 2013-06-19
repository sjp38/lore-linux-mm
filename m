Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E542A6B0044
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:19:02 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 09/11] ipc: rename ids->rw_mutex
Date: Tue, 18 Jun 2013 18:18:34 -0700
Message-Id: <1371604716-3439-10-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

Since in some situations the lock can be shared for readers,
we shouldn't be calling it a mutex, rename it to rwsem.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 include/linux/ipc_namespace.h |  2 +-
 ipc/msg.c                     | 20 ++++++++--------
 ipc/namespace.c               |  4 ++--
 ipc/sem.c                     | 24 +++++++++----------
 ipc/shm.c                     | 56 +++++++++++++++++++++----------------------
 ipc/util.c                    | 28 +++++++++++-----------
 ipc/util.h                    |  4 ++--
 7 files changed, 69 insertions(+), 69 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index c4d870b..19c19a5 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -22,7 +22,7 @@ struct ipc_ids {
 	int in_use;
 	unsigned short seq;
 	unsigned short seq_max;
-	struct rw_semaphore rw_mutex;
+	struct rw_semaphore rwsem;
 	struct idr ipcs_idr;
 	int next_id;
 };
diff --git a/ipc/msg.c b/ipc/msg.c
index a1cf70e..80d8aa7 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -172,7 +172,7 @@ static inline void msg_rmid(struct ipc_namespace *ns, struct msg_queue *s)
  * @ns: namespace
  * @params: ptr to the structure that contains the key and msgflg
  *
- * Called with msg_ids.rw_mutex held (writer)
+ * Called with msg_ids.rwsem held (writer)
  */
 static int newque(struct ipc_namespace *ns, struct ipc_params *params)
 {
@@ -259,8 +259,8 @@ static void expunge_all(struct msg_queue *msq, int res)
  * removes the message queue from message queue ID IDR, and cleans up all the
  * messages associated with this queue.
  *
- * msg_ids.rw_mutex (writer) and the spinlock for this message queue are held
- * before freeque() is called. msg_ids.rw_mutex remains locked on exit.
+ * msg_ids.rwsem (writer) and the spinlock for this message queue are held
+ * before freeque() is called. msg_ids.rwsem remains locked on exit.
  */
 static void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
@@ -282,7 +282,7 @@ static void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 }
 
 /*
- * Called with msg_ids.rw_mutex and ipcp locked.
+ * Called with msg_ids.rwsem and ipcp locked.
  */
 static inline int msg_security(struct kern_ipc_perm *ipcp, int msgflg)
 {
@@ -386,9 +386,9 @@ copy_msqid_from_user(struct msqid64_ds *out, void __user *buf, int version)
 }
 
 /*
- * This function handles some msgctl commands which require the rw_mutex
+ * This function handles some msgctl commands which require the rwsem
  * to be held in write mode.
- * NOTE: no locks must be held, the rw_mutex is taken inside this function.
+ * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
 static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 		       struct msqid_ds __user *buf, int version)
@@ -403,7 +403,7 @@ static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 			return -EFAULT;
 	}
 
-	down_write(&msg_ids(ns).rw_mutex);
+	down_write(&msg_ids(ns).rwsem);
 	rcu_read_lock();
 
 	ipcp = ipcctl_pre_down_nolock(ns, &msg_ids(ns), msqid, cmd,
@@ -459,7 +459,7 @@ out_unlock0:
 out_unlock1:
 	rcu_read_unlock();
 out_up:
-	up_write(&msg_ids(ns).rw_mutex);
+	up_write(&msg_ids(ns).rwsem);
 	return err;
 }
 
@@ -494,7 +494,7 @@ static int msgctl_nolock(struct ipc_namespace *ns, int msqid,
 		msginfo.msgmnb = ns->msg_ctlmnb;
 		msginfo.msgssz = MSGSSZ;
 		msginfo.msgseg = MSGSEG;
-		down_read(&msg_ids(ns).rw_mutex);
+		down_read(&msg_ids(ns).rwsem);
 		if (cmd == MSG_INFO) {
 			msginfo.msgpool = msg_ids(ns).in_use;
 			msginfo.msgmap = atomic_read(&ns->msg_hdrs);
@@ -505,7 +505,7 @@ static int msgctl_nolock(struct ipc_namespace *ns, int msqid,
 			msginfo.msgtql = MSGTQL;
 		}
 		max_id = ipc_get_maxid(&msg_ids(ns));
-		up_read(&msg_ids(ns).rw_mutex);
+		up_read(&msg_ids(ns).rwsem);
 		if (copy_to_user(buf, &msginfo, sizeof(struct msginfo)))
 			return -EFAULT;
 		return (max_id < 0) ? 0 : max_id;
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 7ee61bf..67dc744 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -81,7 +81,7 @@ void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
 	int next_id;
 	int total, in_use;
 
-	down_write(&ids->rw_mutex);
+	down_write(&ids->rwsem);
 
 	in_use = ids->in_use;
 
@@ -93,7 +93,7 @@ void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
 		free(ns, perm);
 		total++;
 	}
-	up_write(&ids->rw_mutex);
+	up_write(&ids->rwsem);
 }
 
 static void free_ipc_ns(struct ipc_namespace *ns)
diff --git a/ipc/sem.c b/ipc/sem.c
index 94ffe72..d47bfad 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -321,7 +321,7 @@ static inline void sem_unlock(struct sem_array *sma, int locknum)
 }
 
 /*
- * sem_lock_(check_) routines are called in the paths where the rw_mutex
+ * sem_lock_(check_) routines are called in the paths where the rwsem
  * is not held.
  *
  * The caller holds the RCU read lock.
@@ -425,7 +425,7 @@ static inline void sem_rmid(struct ipc_namespace *ns, struct sem_array *s)
  * @ns: namespace
  * @params: ptr to the structure that contains key, semflg and nsems
  *
- * Called with sem_ids.rw_mutex held (as a writer)
+ * Called with sem_ids.rwsem held (as a writer)
  */
 
 static int newary(struct ipc_namespace *ns, struct ipc_params *params)
@@ -491,7 +491,7 @@ static int newary(struct ipc_namespace *ns, struct ipc_params *params)
 
 
 /*
- * Called with sem_ids.rw_mutex and ipcp locked.
+ * Called with sem_ids.rwsem and ipcp locked.
  */
 static inline int sem_security(struct kern_ipc_perm *ipcp, int semflg)
 {
@@ -502,7 +502,7 @@ static inline int sem_security(struct kern_ipc_perm *ipcp, int semflg)
 }
 
 /*
- * Called with sem_ids.rw_mutex and ipcp locked.
+ * Called with sem_ids.rwsem and ipcp locked.
  */
 static inline int sem_more_checks(struct kern_ipc_perm *ipcp,
 				struct ipc_params *params)
@@ -985,8 +985,8 @@ static int count_semzcnt (struct sem_array * sma, ushort semnum)
 	return semzcnt;
 }
 
-/* Free a semaphore set. freeary() is called with sem_ids.rw_mutex locked
- * as a writer and the spinlock for this semaphore set hold. sem_ids.rw_mutex
+/* Free a semaphore set. freeary() is called with sem_ids.rwsem locked
+ * as a writer and the spinlock for this semaphore set hold. sem_ids.rwsem
  * remains locked on exit.
  */
 static void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
@@ -1092,7 +1092,7 @@ static int semctl_nolock(struct ipc_namespace *ns, int semid,
 		seminfo.semmnu = SEMMNU;
 		seminfo.semmap = SEMMAP;
 		seminfo.semume = SEMUME;
-		down_read(&sem_ids(ns).rw_mutex);
+		down_read(&sem_ids(ns).rwsem);
 		if (cmd == SEM_INFO) {
 			seminfo.semusz = sem_ids(ns).in_use;
 			seminfo.semaem = ns->used_sems;
@@ -1101,7 +1101,7 @@ static int semctl_nolock(struct ipc_namespace *ns, int semid,
 			seminfo.semaem = SEMAEM;
 		}
 		max_id = ipc_get_maxid(&sem_ids(ns));
-		up_read(&sem_ids(ns).rw_mutex);
+		up_read(&sem_ids(ns).rwsem);
 		if (copy_to_user(p, &seminfo, sizeof(struct seminfo))) 
 			return -EFAULT;
 		return (max_id < 0) ? 0: max_id;
@@ -1407,9 +1407,9 @@ copy_semid_from_user(struct semid64_ds *out, void __user *buf, int version)
 }
 
 /*
- * This function handles some semctl commands which require the rw_mutex
+ * This function handles some semctl commands which require the rwsem
  * to be held in write mode.
- * NOTE: no locks must be held, the rw_mutex is taken inside this function.
+ * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
 static int semctl_down(struct ipc_namespace *ns, int semid,
 		       int cmd, int version, void __user *p)
@@ -1424,7 +1424,7 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 			return -EFAULT;
 	}
 
-	down_write(&sem_ids(ns).rw_mutex);
+	down_write(&sem_ids(ns).rwsem);
 	rcu_read_lock();
 
 	ipcp = ipcctl_pre_down_nolock(ns, &sem_ids(ns), semid, cmd,
@@ -1463,7 +1463,7 @@ out_unlock0:
 out_unlock1:
 	rcu_read_unlock();
 out_up:
-	up_write(&sem_ids(ns).rw_mutex);
+	up_write(&sem_ids(ns).rwsem);
 	return err;
 }
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 2fe6170..763ef72 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -83,8 +83,8 @@ void shm_init_ns(struct ipc_namespace *ns)
 }
 
 /*
- * Called with shm_ids.rw_mutex (writer) and the shp structure locked.
- * Only shm_ids.rw_mutex remains locked on exit.
+ * Called with shm_ids.rwsem (writer) and the shp structure locked.
+ * Only shm_ids.rwsem remains locked on exit.
  */
 static void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
@@ -148,7 +148,7 @@ static inline struct shmid_kernel *shm_obtain_object_check(struct ipc_namespace
 }
 
 /*
- * shm_lock_(check_) routines are called in the paths where the rw_mutex
+ * shm_lock_(check_) routines are called in the paths where the rwsem
  * is not necessarily held.
  */
 static inline struct shmid_kernel *shm_lock(struct ipc_namespace *ns, int id)
@@ -205,7 +205,7 @@ static void shm_open(struct vm_area_struct *vma)
  * @ns: namespace
  * @shp: struct to free
  *
- * It has to be called with shp and shm_ids.rw_mutex (writer) locked,
+ * It has to be called with shp and shm_ids.rwsem (writer) locked,
  * but returns with shp unlocked and freed.
  */
 static void shm_destroy(struct ipc_namespace *ns, struct shmid_kernel *shp)
@@ -253,7 +253,7 @@ static void shm_close(struct vm_area_struct *vma)
 	struct shmid_kernel *shp;
 	struct ipc_namespace *ns = sfd->ns;
 
-	down_write(&shm_ids(ns).rw_mutex);
+	down_write(&shm_ids(ns).rwsem);
 	/* remove from the list of attaches of the shm segment */
 	shp = shm_lock(ns, sfd->id);
 	BUG_ON(IS_ERR(shp));
@@ -264,10 +264,10 @@ static void shm_close(struct vm_area_struct *vma)
 		shm_destroy(ns, shp);
 	else
 		shm_unlock(shp);
-	up_write(&shm_ids(ns).rw_mutex);
+	up_write(&shm_ids(ns).rwsem);
 }
 
-/* Called with ns->shm_ids(ns).rw_mutex locked */
+/* Called with ns->shm_ids(ns).rwsem locked */
 static int shm_try_destroy_current(int id, void *p, void *data)
 {
 	struct ipc_namespace *ns = data;
@@ -298,7 +298,7 @@ static int shm_try_destroy_current(int id, void *p, void *data)
 	return 0;
 }
 
-/* Called with ns->shm_ids(ns).rw_mutex locked */
+/* Called with ns->shm_ids(ns).rwsem locked */
 static int shm_try_destroy_orphaned(int id, void *p, void *data)
 {
 	struct ipc_namespace *ns = data;
@@ -309,7 +309,7 @@ static int shm_try_destroy_orphaned(int id, void *p, void *data)
 	 * We want to destroy segments without users and with already
 	 * exit'ed originating process.
 	 *
-	 * As shp->* are changed under rw_mutex, it's safe to skip shp locking.
+	 * As shp->* are changed under rwsem, it's safe to skip shp locking.
 	 */
 	if (shp->shm_creator != NULL)
 		return 0;
@@ -323,10 +323,10 @@ static int shm_try_destroy_orphaned(int id, void *p, void *data)
 
 void shm_destroy_orphaned(struct ipc_namespace *ns)
 {
-	down_write(&shm_ids(ns).rw_mutex);
+	down_write(&shm_ids(ns).rwsem);
 	if (shm_ids(ns).in_use)
 		idr_for_each(&shm_ids(ns).ipcs_idr, &shm_try_destroy_orphaned, ns);
-	up_write(&shm_ids(ns).rw_mutex);
+	up_write(&shm_ids(ns).rwsem);
 }
 
 
@@ -338,10 +338,10 @@ void exit_shm(struct task_struct *task)
 		return;
 
 	/* Destroy all already created segments, but not mapped yet */
-	down_write(&shm_ids(ns).rw_mutex);
+	down_write(&shm_ids(ns).rwsem);
 	if (shm_ids(ns).in_use)
 		idr_for_each(&shm_ids(ns).ipcs_idr, &shm_try_destroy_current, ns);
-	up_write(&shm_ids(ns).rw_mutex);
+	up_write(&shm_ids(ns).rwsem);
 }
 
 static int shm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
@@ -475,7 +475,7 @@ static const struct vm_operations_struct shm_vm_ops = {
  * @ns: namespace
  * @params: ptr to the structure that contains key, size and shmflg
  *
- * Called with shm_ids.rw_mutex held as a writer.
+ * Called with shm_ids.rwsem held as a writer.
  */
 
 static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
@@ -583,7 +583,7 @@ no_file:
 }
 
 /*
- * Called with shm_ids.rw_mutex and ipcp locked.
+ * Called with shm_ids.rwsem and ipcp locked.
  */
 static inline int shm_security(struct kern_ipc_perm *ipcp, int shmflg)
 {
@@ -594,7 +594,7 @@ static inline int shm_security(struct kern_ipc_perm *ipcp, int shmflg)
 }
 
 /*
- * Called with shm_ids.rw_mutex and ipcp locked.
+ * Called with shm_ids.rwsem and ipcp locked.
  */
 static inline int shm_more_checks(struct kern_ipc_perm *ipcp,
 				struct ipc_params *params)
@@ -707,7 +707,7 @@ static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminf
 
 /*
  * Calculate and add used RSS and swap pages of a shm.
- * Called with shm_ids.rw_mutex held as a reader
+ * Called with shm_ids.rwsem held as a reader
  */
 static void shm_add_rss_swap(struct shmid_kernel *shp,
 	unsigned long *rss_add, unsigned long *swp_add)
@@ -734,7 +734,7 @@ static void shm_add_rss_swap(struct shmid_kernel *shp,
 }
 
 /*
- * Called with shm_ids.rw_mutex held as a reader
+ * Called with shm_ids.rwsem held as a reader
  */
 static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
 		unsigned long *swp)
@@ -763,9 +763,9 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
 }
 
 /*
- * This function handles some shmctl commands which require the rw_mutex
+ * This function handles some shmctl commands which require the rwsem
  * to be held in write mode.
- * NOTE: no locks must be held, the rw_mutex is taken inside this function.
+ * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
 static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		       struct shmid_ds __user *buf, int version)
@@ -780,7 +780,7 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 			return -EFAULT;
 	}
 
-	down_write(&shm_ids(ns).rw_mutex);
+	down_write(&shm_ids(ns).rwsem);
 	rcu_read_lock();
 
 	ipcp = ipcctl_pre_down_nolock(ns, &shm_ids(ns), shmid, cmd,
@@ -819,7 +819,7 @@ out_unlock0:
 out_unlock1:
 	rcu_read_unlock();
 out_up:
-	up_write(&shm_ids(ns).rw_mutex);
+	up_write(&shm_ids(ns).rwsem);
 	return err;
 }
 
@@ -850,9 +850,9 @@ static int shmctl_nolock(struct ipc_namespace *ns, int shmid,
 		if(copy_shminfo_to_user (buf, &shminfo, version))
 			return -EFAULT;
 
-		down_read(&shm_ids(ns).rw_mutex);
+		down_read(&shm_ids(ns).rwsem);
 		err = ipc_get_maxid(&shm_ids(ns));
-		up_read(&shm_ids(ns).rw_mutex);
+		up_read(&shm_ids(ns).rwsem);
 
 		if(err<0)
 			err = 0;
@@ -863,14 +863,14 @@ static int shmctl_nolock(struct ipc_namespace *ns, int shmid,
 		struct shm_info shm_info;
 
 		memset(&shm_info, 0, sizeof(shm_info));
-		down_read(&shm_ids(ns).rw_mutex);
+		down_read(&shm_ids(ns).rwsem);
 		shm_info.used_ids = shm_ids(ns).in_use;
 		shm_get_stat (ns, &shm_info.shm_rss, &shm_info.shm_swp);
 		shm_info.shm_tot = ns->shm_tot;
 		shm_info.swap_attempts = 0;
 		shm_info.swap_successes = 0;
 		err = ipc_get_maxid(&shm_ids(ns));
-		up_read(&shm_ids(ns).rw_mutex);
+		up_read(&shm_ids(ns).rwsem);
 		if (copy_to_user(buf, &shm_info, sizeof(shm_info))) {
 			err = -EFAULT;
 			goto out;
@@ -1169,7 +1169,7 @@ out_fput:
 	fput(file);
 
 out_nattch:
-	down_write(&shm_ids(ns).rw_mutex);
+	down_write(&shm_ids(ns).rwsem);
 	shp = shm_lock(ns, shmid);
 	BUG_ON(IS_ERR(shp));
 	shp->shm_nattch--;
@@ -1177,7 +1177,7 @@ out_nattch:
 		shm_destroy(ns, shp);
 	else
 		shm_unlock(shp);
-	up_write(&shm_ids(ns).rw_mutex);
+	up_write(&shm_ids(ns).rwsem);
 	return err;
 
 out_unlock:
diff --git a/ipc/util.c b/ipc/util.c
index 1893667..8f12fe3 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -119,7 +119,7 @@ __initcall(ipc_init);
  
 void ipc_init_ids(struct ipc_ids *ids)
 {
-	init_rwsem(&ids->rw_mutex);
+	init_rwsem(&ids->rwsem);
 
 	ids->in_use = 0;
 	ids->seq = 0;
@@ -174,7 +174,7 @@ void __init ipc_init_proc_interface(const char *path, const char *header,
  *	@ids: Identifier set
  *	@key: The key to find
  *	
- *	Requires ipc_ids.rw_mutex locked.
+ *	Requires ipc_ids.rwsem locked.
  *	Returns the LOCKED pointer to the ipc structure if found or NULL
  *	if not.
  *	If key is found ipc points to the owning ipc structure
@@ -208,7 +208,7 @@ static struct kern_ipc_perm *ipc_findkey(struct ipc_ids *ids, key_t key)
  *	ipc_get_maxid 	-	get the last assigned id
  *	@ids: IPC identifier set
  *
- *	Called with ipc_ids.rw_mutex held.
+ *	Called with ipc_ids.rwsem held.
  */
 
 int ipc_get_maxid(struct ipc_ids *ids)
@@ -246,7 +246,7 @@ int ipc_get_maxid(struct ipc_ids *ids)
  *	is returned. The 'new' entry is returned in a locked state on success.
  *	On failure the entry is not locked and a negative err-code is returned.
  *
- *	Called with writer ipc_ids.rw_mutex held.
+ *	Called with writer ipc_ids.rwsem held.
  */
 int ipc_addid(struct ipc_ids* ids, struct kern_ipc_perm* new, int size)
 {
@@ -312,9 +312,9 @@ static int ipcget_new(struct ipc_namespace *ns, struct ipc_ids *ids,
 {
 	int err;
 
-	down_write(&ids->rw_mutex);
+	down_write(&ids->rwsem);
 	err = ops->getnew(ns, params);
-	up_write(&ids->rw_mutex);
+	up_write(&ids->rwsem);
 	return err;
 }
 
@@ -331,7 +331,7 @@ static int ipcget_new(struct ipc_namespace *ns, struct ipc_ids *ids,
  *
  *	On success, the IPC id is returned.
  *
- *	It is called with ipc_ids.rw_mutex and ipcp->lock held.
+ *	It is called with ipc_ids.rwsem and ipcp->lock held.
  */
 static int ipc_check_perms(struct ipc_namespace *ns,
 			   struct kern_ipc_perm *ipcp,
@@ -376,7 +376,7 @@ static int ipcget_public(struct ipc_namespace *ns, struct ipc_ids *ids,
 	 * Take the lock as a writer since we are potentially going to add
 	 * a new entry + read locks are not "upgradable"
 	 */
-	down_write(&ids->rw_mutex);
+	down_write(&ids->rwsem);
 	ipcp = ipc_findkey(ids, params->key);
 	if (ipcp == NULL) {
 		/* key not used */
@@ -402,7 +402,7 @@ static int ipcget_public(struct ipc_namespace *ns, struct ipc_ids *ids,
 		}
 		ipc_unlock(ipcp);
 	}
-	up_write(&ids->rw_mutex);
+	up_write(&ids->rwsem);
 
 	return err;
 }
@@ -413,7 +413,7 @@ static int ipcget_public(struct ipc_namespace *ns, struct ipc_ids *ids,
  *	@ids: IPC identifier set
  *	@ipcp: ipc perm structure containing the identifier to remove
  *
- *	ipc_ids.rw_mutex (as a writer) and the spinlock for this ID are held
+ *	ipc_ids.rwsem (as a writer) and the spinlock for this ID are held
  *	before this function is called, and remain locked on the exit.
  */
  
@@ -621,7 +621,7 @@ struct kern_ipc_perm *ipc_obtain_object(struct ipc_ids *ids, int id)
 }
 
 /**
- * ipc_lock - Lock an ipc structure without rw_mutex held
+ * ipc_lock - Lock an ipc structure without rwsem held
  * @ids: IPC identifier set
  * @id: ipc id to look for
  *
@@ -748,7 +748,7 @@ int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
  *  - performs some audit and permission check, depending on the given cmd
  *  - returns a pointer to the ipc object or otherwise, the corresponding error.
  *
- * Call holding the both the rw_mutex and the rcu read lock.
+ * Call holding the both the rwsem and the rcu read lock.
  */
 struct kern_ipc_perm *ipcctl_pre_down_nolock(struct ipc_namespace *ns,
 					     struct ipc_ids *ids, int id, int cmd,
@@ -867,7 +867,7 @@ static void *sysvipc_proc_start(struct seq_file *s, loff_t *pos)
 	 * Take the lock - this will be released by the corresponding
 	 * call to stop().
 	 */
-	down_read(&ids->rw_mutex);
+	down_read(&ids->rwsem);
 
 	/* pos < 0 is invalid */
 	if (*pos < 0)
@@ -894,7 +894,7 @@ static void sysvipc_proc_stop(struct seq_file *s, void *it)
 
 	ids = &iter->ns->ids[iface->ids];
 	/* Release the lock we took in start() */
-	up_read(&ids->rw_mutex);
+	up_read(&ids->rwsem);
 }
 
 static int sysvipc_proc_show(struct seq_file *s, void *it)
diff --git a/ipc/util.h b/ipc/util.h
index 41a6c4d..0a362ff 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -94,10 +94,10 @@ void __init ipc_init_proc_interface(const char *path, const char *header,
 #define ipcid_to_idx(id) ((id) % SEQ_MULTIPLIER)
 #define ipcid_to_seqx(id) ((id) / SEQ_MULTIPLIER)
 
-/* must be called with ids->rw_mutex acquired for writing */
+/* must be called with ids->rwsem acquired for writing */
 int ipc_addid(struct ipc_ids *, struct kern_ipc_perm *, int);
 
-/* must be called with ids->rw_mutex acquired for reading */
+/* must be called with ids->rwsem acquired for reading */
 int ipc_get_maxid(struct ipc_ids *);
 
 /* must be called with both locks acquired. */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
