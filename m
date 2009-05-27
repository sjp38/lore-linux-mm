Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AAA3D6B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:42:58 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 35/43] c/r (ipc): export interface from ipc/shm.c to delete ipc shm
Date: Wed, 27 May 2009 13:33:01 -0400
Message-Id: <1243445589-32388-36-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Export shmctl_down() which will be used in the next patch during
restart to delete an ipc shm (the shm is mapped already, so it
won't be lost).

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 include/linux/shm.h |    4 ++++
 ipc/shm.c           |    4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index eca6235..ec36e99 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -118,6 +118,10 @@ static inline int is_file_shm_hugepages(struct file *file)
 }
 #endif
 
+struct ipc_namespace;
+extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
+		       struct shmid_ds __user *buf, int version);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SHM_H_ */
diff --git a/ipc/shm.c b/ipc/shm.c
index 7dd5f0c..8aba22f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -598,8 +598,8 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
  * to be held in write mode.
  * NOTE: no locks must be held, the rw_mutex is taken inside this function.
  */
-static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
-		       struct shmid_ds __user *buf, int version)
+int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
+		struct shmid_ds __user *buf, int version)
 {
 	struct kern_ipc_perm *ipcp;
 	struct shmid64_ds shmid64;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
