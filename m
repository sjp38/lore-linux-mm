Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 57FF96B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:18:50 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 02/11] ipc,shm: shorten critical region in shmctl_down
Date: Tue, 18 Jun 2013 18:18:27 -0700
Message-Id: <1371604716-3439-3-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

Instead of holding the ipc lock for the entire function, use the
ipcctl_pre_down_nolock and only acquire the lock for specific commands:
RMID and SET.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/shm.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index 216ae72..22cffd7 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -780,11 +780,10 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 	down_write(&shm_ids(ns).rw_mutex);
 	rcu_read_lock();
 
-	ipcp = ipcctl_pre_down(ns, &shm_ids(ns), shmid, cmd,
-			       &shmid64.shm_perm, 0);
+	ipcp = ipcctl_pre_down_nolock(ns, &shm_ids(ns), shmid, cmd,
+				      &shmid64.shm_perm, 0);
 	if (IS_ERR(ipcp)) {
 		err = PTR_ERR(ipcp);
-		/* the ipc lock is not held upon failure */
 		goto out_unlock1;
 	}
 
@@ -792,14 +791,16 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 
 	err = security_shm_shmctl(shp, cmd);
 	if (err)
-		goto out_unlock0;
+		goto out_unlock1;
 
 	switch (cmd) {
 	case IPC_RMID:
+		ipc_lock_object(&shp->shm_perm);
 		/* do_shm_rmid unlocks the ipc object and rcu */
 		do_shm_rmid(ns, ipcp);
 		goto out_up;
 	case IPC_SET:
+		ipc_lock_object(&shp->shm_perm);
 		err = ipc_update_perm(&shmid64.shm_perm, ipcp);
 		if (err)
 			goto out_unlock0;
@@ -807,6 +808,7 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		break;
 	default:
 		err = -EINVAL;
+		goto out_unlock1;
 	}
 
 out_unlock0:
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
