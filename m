Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A35416B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 02:19:37 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so2120417pab.4
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 23:19:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id iy4si11326798pbb.0.2013.11.18.23.19.35
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 23:19:36 -0800 (PST)
Received: by mail-qc0-f202.google.com with SMTP id k18so444945qcv.5
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 23:19:34 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] ipc,shm: fix shm_file deletion races
Date: Mon, 18 Nov 2013 23:19:15 -0800
Message-Id: <1384845555-11099-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, stable@vger.kernel.org

When IPC_RMID races with other shm operations there's potential for
use-after-free of the shm object's associated file (shm_file).

Here's the race before this patch:
  TASK 1                     TASK 2
  ------                     ------
  shm_rmid()
    ipc_lock_object()
                             shmctl()
                             shp = shm_obtain_object_check()

    shm_destroy()
      shum_unlock()
      fput(shp->shm_file)
                             ipc_lock_object()
                             shmem_lock(shp->shm_file)
                             <OOPS>

The oops is caused because shm_destroy() calls fput() after dropping the
ipc_lock.  fput() clears the file's f_inode, f_path.dentry, and
f_path.mnt, which causes various NULL pointer references in task 2.  I
reliably see the oops in task 2 if with shmlock, shmu

This patch fixes the races by:
1) set shm_file=NULL in shm_destroy() while holding ipc_object_lock().
2) modify at risk operations to check shm_file while holding
   ipc_object_lock().

Example workloads, which each trigger oops...

Workload 1:
  while true; do
    id=$(shmget 1 4096)
    shm_rmid $id &
    shmlock $id &
    wait
  done

  The oops stack shows accessing NULL f_inode due to racing fput:
    _raw_spin_lock
    shmem_lock
    SyS_shmctl

Workload 2:
  while true; do
    id=$(shmget 1 4096)
    shmat $id 4096 &
    shm_rmid $id &
    wait
  done

  The oops stack is similar to workload 1 due to NULL f_inode:
    touch_atime
    shmem_mmap
    shm_mmap
    mmap_region
    do_mmap_pgoff
    do_shmat
    SyS_shmat

Workload 3:
  while true; do
    id=$(shmget 1 4096)
    shmlock $id
    shm_rmid $id &
    shmunlock $id &
    wait
  done

  The oops stack shows second fput tripping on an NULL f_inode.  The
  first fput() completed via from shm_destroy(), but a racing thread did
  a get_file() and queued this fput():
    locks_remove_flock
    __fput
    ____fput
    task_work_run
    do_notify_resume
    int_signal

Fixes: c2c737a0461e ("ipc,shm: shorten critical region for shmat")
Fixes: 2caacaa82a51 ("ipc,shm: shorten critical region for shmctl")
Signed-off-by: Greg Thelen <gthelen@google.com>
Cc: <stable@vger.kernel.org>  # 3.10.17+ 3.11.6+
---
 ipc/shm.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index d69739610fd4..0bdf21c6814e 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -208,15 +208,18 @@ static void shm_open(struct vm_area_struct *vma)
  */
 static void shm_destroy(struct ipc_namespace *ns, struct shmid_kernel *shp)
 {
+	struct file *shm_file;
+
+	shm_file = shp->shm_file;
+	shp->shm_file = NULL;
 	ns->shm_tot -= (shp->shm_segsz + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	shm_rmid(ns, shp);
 	shm_unlock(shp);
-	if (!is_file_hugepages(shp->shm_file))
-		shmem_lock(shp->shm_file, 0, shp->mlock_user);
+	if (!is_file_hugepages(shm_file))
+		shmem_lock(shm_file, 0, shp->mlock_user);
 	else if (shp->mlock_user)
-		user_shm_unlock(file_inode(shp->shm_file)->i_size,
-						shp->mlock_user);
-	fput (shp->shm_file);
+		user_shm_unlock(file_inode(shm_file)->i_size, shp->mlock_user);
+	fput(shm_file);
 	ipc_rcu_putref(shp, shm_rcu_free);
 }
 
@@ -983,6 +986,13 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int, cmd, struct shmid_ds __user *, buf)
 		}
 
 		shm_file = shp->shm_file;
+
+		/* check if shm_destroy() is tearing down shp */
+		if (shm_file == NULL) {
+			err = -EIDRM;
+			goto out_unlock0;
+		}
+
 		if (is_file_hugepages(shm_file))
 			goto out_unlock0;
 
@@ -1101,6 +1111,14 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
 		goto out_unlock;
 
 	ipc_lock_object(&shp->shm_perm);
+
+	/* check if shm_destroy() is tearing down shp */
+	if (shp->shm_file == NULL) {
+		ipc_unlock_object(&shp->shm_perm);
+		err = -EIDRM;
+		goto out_unlock;
+	}
+
 	path = shp->shm_file->f_path;
 	path_get(&path);
 	shp->shm_nattch++;
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
