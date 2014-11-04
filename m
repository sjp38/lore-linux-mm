Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 00E5A6B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 19:07:05 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so13114277pad.7
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 16:07:05 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id je1si16430839pbb.168.2014.11.03.16.07.03
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 16:07:04 -0800 (PST)
Subject: [PATCH] mm: fix overly aggressive shmdt() when calls span multiple segments
From: Dave Hansen <dave@sr71.net>
Date: Mon, 03 Nov 2014 16:06:33 -0800
Message-Id: <20141104000633.F35632C6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This is a highly-contrived scenario.  But, a single shmdt() call
can be induced in to unmapping memory from mulitple shm segments.
Example code is here:

	http://www.sr71.net/~dave/intel/shmfun.c

The fix is pretty simple:  Record the 'struct file' for the first
VMA we encounter and then stick to it.  Decline to unmap anything
not from the same file and thus the same segment.

I found this by inspection and the odds of anyone hitting this in
practice are pretty darn small.

Lightly tested, but it's a pretty small patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/ipc/shm.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff -puN ipc/shm.c~mm-shmdt-fix-over-aggressive-unmap ipc/shm.c
--- a/ipc/shm.c~mm-shmdt-fix-over-aggressive-unmap	2014-11-03 14:32:09.479595152 -0800
+++ b/ipc/shm.c	2014-11-03 16:04:28.340225666 -0800
@@ -1229,6 +1229,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 	int retval = -EINVAL;
 #ifdef CONFIG_MMU
 	loff_t size = 0;
+	struct file *file;
 	struct vm_area_struct *next;
 #endif
 
@@ -1245,7 +1246,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 	 *   started at address shmaddr. It records it's size and then unmaps
 	 *   it.
 	 * - Then it unmaps all shm vmas that started at shmaddr and that
-	 *   are within the initially determined size.
+	 *   are within the initially determined size and that are from the
+	 *   same shm segment from which we determined the size.
 	 * Errors from do_munmap are ignored: the function only fails if
 	 * it's called with invalid parameters or if it's called to unmap
 	 * a part of a vma. Both calls in this function are for full vmas,
@@ -1271,8 +1273,14 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 		if ((vma->vm_ops == &shm_vm_ops) &&
 			(vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff) {
 
-
-			size = file_inode(vma->vm_file)->i_size;
+			/*
+			 * Record the file of the shm segment being
+			 * unmapped.  With mremap(), someone could place
+			 * page from another segment but with equal offsets
+			 * in the range we are unmapping.
+			 */
+			file = vma->vm_file;
+			size = file_inode(file)->i_size;
 			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
 			/*
 			 * We discovered the size of the shm segment, so
@@ -1298,8 +1306,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 
 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops) &&
-			(vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff)
-
+		    ((vma->vm_start - addr)/PAGE_SIZE == vma->vm_pgoff) &&
+		    (vma->vm_file == file))
 			do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
 		vma = next;
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
