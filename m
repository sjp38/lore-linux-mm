Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AD2126B003C
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:18:57 -0400 (EDT)
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Subject: [PATCH 07/11] ipc,shm: cleanup do_shmat pasta
Date: Tue, 18 Jun 2013 18:18:32 -0700
Message-Id: <1371604716-3439-8-git-send-email-davidlohr.bueso@hp.com>
In-Reply-To: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
References: <1371604716-3439-1-git-send-email-davidlohr.bueso@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>

Clean up some of the messy do_shmat() spaghetti code, getting
rid of out_free and out_put_dentry labels. This makes shortening
the critical region of this function in the next patch a little
easier to do and read.

Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
---
 ipc/shm.c | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index e4ac1c1..d1b3ebf 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1108,16 +1108,21 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 
 	err = -ENOMEM;
 	sfd = kzalloc(sizeof(*sfd), GFP_KERNEL);
-	if (!sfd)
-		goto out_put_dentry;
+	if (!sfd) {
+		path_put(&path);
+		goto out_nattch;
+	}
 
 	file = alloc_file(&path, f_mode,
 			  is_file_hugepages(shp->shm_file) ?
 				&shm_file_operations_huge :
 				&shm_file_operations);
 	err = PTR_ERR(file);
-	if (IS_ERR(file))
-		goto out_free;
+	if (IS_ERR(file)) {
+		kfree(sfd);
+		path_put(&path);
+		goto out_nattch;
+	}
 
 	file->private_data = sfd;
 	file->f_mapping = shp->shm_file->f_mapping;
@@ -1143,7 +1148,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
 			goto invalid;
 	}
-		
+
 	addr = do_mmap_pgoff(file, addr, size, prot, flags, 0, &populate);
 	*raddr = addr;
 	err = 0;
@@ -1167,19 +1172,12 @@ out_nattch:
 	else
 		shm_unlock(shp);
 	up_write(&shm_ids(ns).rw_mutex);
-
-out:
 	return err;
 
 out_unlock:
 	shm_unlock(shp);
-	goto out;
-
-out_free:
-	kfree(sfd);
-out_put_dentry:
-	path_put(&path);
-	goto out_nattch;
+out:
+	return err;
 }
 
 SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
