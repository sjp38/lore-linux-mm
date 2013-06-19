Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 3BFD76B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:18:49 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 01/11] ipc,shm: introduce lockless functions to obtain the ipc object
Date: Tue, 18 Jun 2013 18:18:26 -0700
Message-Id: <1371604716-3439-2-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

Add shm_obtain_object() and shm_obtain_object_check(), which will allow us
to get the ipc object without acquiring the lock. Just as with other forms
of ipc, these functions are basically wrappers around ipc_obtain_object*().

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/shm.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ipc/shm.c b/ipc/shm.c
index c6b4ad5..216ae72 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -124,6 +124,26 @@ void __init shm_init (void)
 				IPC_SHM_IDS, sysvipc_shm_proc_show);
 }
 
+static inline struct shmid_kernel *shm_obtain_object(struct ipc_namespace *ns, int id)
+{
+	struct kern_ipc_perm *ipcp = ipc_obtain_object(&shm_ids(ns), id);
+
+	if (IS_ERR(ipcp))
+		return ERR_CAST(ipcp);
+
+	return container_of(ipcp, struct shmid_kernel, shm_perm);
+}
+
+static inline struct shmid_kernel *shm_obtain_object_check(struct ipc_namespace *ns, int id)
+{
+	struct kern_ipc_perm *ipcp = ipc_obtain_object_check(&shm_ids(ns), id);
+
+	if (IS_ERR(ipcp))
+		return ERR_CAST(ipcp);
+
+	return container_of(ipcp, struct shmid_kernel, shm_perm);
+}
+
 /*
  * shm_lock_(check_) routines are called in the paths where the rw_mutex
  * is not necessarily held.
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
