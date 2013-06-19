Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DA0A06B003B
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:18:55 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 06/11] ipc,shm: shorten critical region for shmctl
Date: Tue, 18 Jun 2013 18:18:31 -0700
Message-Id: <1371604716-3439-7-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

With the *_INFO, *_STAT, IPC_RMID and IPC_SET commands already
optimized, deal with the remaining SHM_LOCK and SHM_UNLOCK
commands. Take the shm_perm lock after doing the initial
auditing and security checks. The rest of the logic remains
unchanged.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/shm.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 43a8786..e4ac1c1 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -940,10 +940,8 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 	int err, version;
 	struct ipc_namespace *ns;
 
-	if (cmd < 0 || shmid < 0) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (cmd < 0 || shmid < 0)
+		return -EINVAL;
 
 	version = ipc_parse_version(&cmd);
 	ns = current->nsproxy->ipc_ns;
@@ -954,36 +952,40 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 	case SHM_STAT:
 	case IPC_STAT:
 		return shmctl_nolock(ns, shmid, cmd, version, buf);
+	case IPC_RMID:
+	case IPC_SET:
+		return shmctl_down(ns, shmid, cmd, buf, version);
 	case SHM_LOCK:
 	case SHM_UNLOCK:
 	{
 		struct file *shm_file;
 
-		shp = shm_lock_check(ns, shmid);
+		rcu_read_lock();
+		shp = shm_obtain_object_check(ns, shmid);
 		if (IS_ERR(shp)) {
 			err = PTR_ERR(shp);
-			goto out;
+			goto out_unlock1;
 		}
 
 		audit_ipc_obj(&(shp->shm_perm));
+		err = security_shm_shmctl(shp, cmd);
+		if (err)
+			goto out_unlock1;
 
+		ipc_lock_object(&shp->shm_perm);
 		if (!ns_capable(ns->user_ns, CAP_IPC_LOCK)) {
 			kuid_t euid = current_euid();
 			err = -EPERM;
 			if (!uid_eq(euid, shp->shm_perm.uid) &&
 			    !uid_eq(euid, shp->shm_perm.cuid))
-				goto out_unlock;
+				goto out_unlock0;
 			if (cmd == SHM_LOCK && !rlimit(RLIMIT_MEMLOCK))
-				goto out_unlock;
+				goto out_unlock0;
 		}
 
-		err = security_shm_shmctl(shp, cmd);
-		if (err)
-			goto out_unlock;
-
 		shm_file = shp->shm_file;
 		if (is_file_hugepages(shm_file))
-			goto out_unlock;
+			goto out_unlock0;
 
 		if (cmd == SHM_LOCK) {
 			struct user_struct *user = current_user();
@@ -992,32 +994,31 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 				shp->shm_perm.mode |= SHM_LOCKED;
 				shp->mlock_user = user;
 			}
-			goto out_unlock;
+			goto out_unlock0;
 		}
 
 		/* SHM_UNLOCK */
 		if (!(shp->shm_perm.mode & SHM_LOCKED))
-			goto out_unlock;
+			goto out_unlock0;
 		shmem_lock(shm_file, 0, shp->mlock_user);
 		shp->shm_perm.mode &= ~SHM_LOCKED;
 		shp->mlock_user = NULL;
 		get_file(shm_file);
-		shm_unlock(shp);
+		ipc_unlock_object(&shp->shm_perm);
+		rcu_read_unlock();
 		shmem_unlock_mapping(shm_file->f_mapping);
+
 		fput(shm_file);
-		goto out;
-	}
-	case IPC_RMID:
-	case IPC_SET:
-		err = shmctl_down(ns, shmid, cmd, buf, version);
 		return err;
+	}
 	default:
 		return -EINVAL;
 	}
 
-out_unlock:
-	shm_unlock(shp);
-out:
+out_unlock0:
+	ipc_unlock_object(&shp->shm_perm);
+out_unlock1:
+	rcu_read_unlock();
 	return err;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
