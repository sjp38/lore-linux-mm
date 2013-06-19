Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 1B6616B003D
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:19:01 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 08/11] ipc,shm: shorten critical region for shmat
Date: Tue, 18 Jun 2013 18:18:33 -0700
Message-Id: <1371604716-3439-9-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

Similar to other system calls, acquire the kern_ipc_perm lock
after doing the initial permission and security checks.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/shm.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index d1b3ebf..2fe6170 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -19,6 +19,9 @@
  * namespaces support
  * OpenVZ, SWsoft Inc.
  * Pavel Emelianov <xemul@openvz.org>
+ *
+ * Better ipc lock (kern_ipc_perm.lock) handling
+ * Davidlohr Bueso <davidlohr.bueso@hp.com>, June 2013.
  */
 
 #include <linux/slab.h>
@@ -1086,7 +1089,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	 * additional creator id...
 	 */
 	ns = current->nsproxy->ipc_ns;
-	shp = shm_lock_check(ns, shmid);
+	rcu_read_lock();
+	shp = shm_obtain_object_check(ns, shmid);
 	if (IS_ERR(shp)) {
 		err = PTR_ERR(shp);
 		goto out;
@@ -1100,11 +1104,13 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 	if (err)
 		goto out_unlock;
 
+	ipc_lock_object(&shp->shm_perm);	
 	path = shp->shm_file->f_path;
 	path_get(&path);
 	shp->shm_nattch++;
 	size = i_size_read(path.dentry->d_inode);
-	shm_unlock(shp);
+	ipc_unlock_object(&shp->shm_perm);	
+	rcu_read_unlock();
 
 	err = -ENOMEM;
 	sfd = kzalloc(sizeof(*sfd), GFP_KERNEL);
@@ -1175,7 +1181,7 @@ out_nattch:
 	return err;
 
 out_unlock:
-	shm_unlock(shp);
+	rcu_read_unlock();
 out:
 	return err;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
