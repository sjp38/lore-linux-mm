Received: by rv-out-0910.google.com with SMTP id l15so677500rvb.26
        for <linux-mm@kvack.org>; Thu, 13 Dec 2007 18:59:48 -0800 (PST)
Message-ID: <d82e647a0712131859x538bf27cq23a56aa944fd8c1f@mail.gmail.com>
Date: Fri, 14 Dec 2007 10:59:48 +0800
From: "Ming Lei" <tom.leiming@gmail.com>
Subject: [RFC][PATCH] fix bus error when trying to access anon & shared page created by mremap()[BUG:8691]
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix the bug 8691 reported in http://bugzilla.kernel.org/show_bug.cgi?id=8691.
Also the following  bug.

#define _GNU_SOURCE
#include <sys/mman.h>
#include <unistd.h>

#include <stdio.h>

int main(int argc, unsigned char* argv[])
{
	void *ptr,*ptr1;
	if ((ptr=mmap(NULL, 4096, PROT_READ|PROT_WRITE,
		MAP_ANONYMOUS|MAP_SHARED, 0, 4096*4)) == MAP_FAILED) {
		printf("failed to mmap\n");
		return -1;
        }
	
	printf("%s:%d\n",__FILE__,__LINE__);

	*(unsigned long *)(ptr)= 10;              /* bus error */

	printf("%s:%d\n",__FILE__,__LINE__);    /* can't  reach here*/

	return 0;
}

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
diff --git a/mm/shmem.c b/mm/shmem.c
index 51b3d6c..7e14bce 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1327,15 +1327,23 @@ failed:
 	return error;
 }

+static struct vfsmount *shm_mnt;
+
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	int error;
 	int ret;
-
-	if (((loff_t)vmf->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
-		return VM_FAULT_SIGBUS;
-
+	loff_t new_size = 0;
+
+	new_size = ((loff_t)vmf->pgoff << PAGE_CACHE_SHIFT);
+	if (new_size >= i_size_read(inode)) {
+		if (vma->vm_file->f_path.mnt == shm_mnt) {
+			inode->i_size = new_size + PAGE_SIZE;
+		}else{
+			return VM_FAULT_SIGBUS;
+		}
+	}
 	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_FAULT, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
@@ -2462,7 +2470,6 @@ static struct file_system_type tmpfs_fs_type = {
 	.get_sb		= shmem_get_sb,
 	.kill_sb	= kill_litter_super,
 };
-static struct vfsmount *shm_mnt;

 static int __init init_tmpfs(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
