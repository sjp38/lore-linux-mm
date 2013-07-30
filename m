Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 7B8416B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 15:57:51 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id mf11so1778564lab.15
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 12:57:49 -0700 (PDT)
From: Azat Khuzhin <a3at.mail@gmail.com>
Subject: [PATCH] mm: for shm_open()/mmap() with OVERCOMMIT_NEVER, return -1 if no memory avail
Date: Tue, 30 Jul 2013 23:56:07 +0400
Message-Id: <1375214187-10740-1-git-send-email-a3at.mail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Azat Khuzhin <a3at.mail@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Otherwize if there is no left space on shmem device, there will be
"Bus error" when application will try to write to address space that was
returned by mmap(2)

This patch also preserve old behaviour if MAP_NORESERVE/VM_NORESERVE
isset.

So, with this patch, you will get next:

a)
$ echo 2 >| /proc/sys/vm/overcommit_memory
  ....
  mmap() = MAP_FAILED;
  ....

b)
  ....
  mmap(0, length, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_NORESERVE) = !MAP_FAILED;
  write()
  killed by SIGBUS
  ....

c)
$ echo 0 >| /proc/sys/vm/overcommit_memory
  ....
  mmap() = !MAP_FAILED;
  write()
  killed by SIGBUS
  ....

Signed-off-by: Azat Khuzhin <a3at.mail@gmail.com>
---
 mm/shmem.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index a87990c..965f4ba 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -32,6 +32,8 @@
 #include <linux/export.h>
 #include <linux/swap.h>
 #include <linux/aio.h>
+#include <linux/statfs.h>
+#include <linux/path.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -1356,6 +1358,20 @@ out_nomem:
 
 static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
+	if (!(vma->vm_flags & VM_NORESERVE) &&
+	    sysctl_overcommit_memory == OVERCOMMIT_NEVER) {
+		struct inode *inode = file_inode(file);
+		struct kstatfs sbuf;
+		u64 size;
+
+		inode->i_sb->s_op->statfs(file->f_dentry, &sbuf);
+		size = sbuf.f_bfree * sbuf.f_bsize;
+
+		if (size < inode->i_size) {
+			return -ENOMEM;
+		}
+	}
+
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
