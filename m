From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v6 1/2] Massive code cleanup of sys_msync()
Date: Fri, 18 Jan 2008 01:31:57 +0300
Message-Id: <12006091213248-git-send-email-salikhmetov@gmail.com>
In-Reply-To: <12006091182260-git-send-email-salikhmetov@gmail.com>
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Using the PAGE_ALIGN() macro instead of "manual" alignment and
improved readability of the loop traversing the process memory regions.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
---
 mm/msync.c |   77 ++++++++++++++++++++++++++++--------------------------------
 1 files changed, 36 insertions(+), 41 deletions(-)

diff --git a/mm/msync.c b/mm/msync.c
index 144a757..a4de868 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -1,85 +1,83 @@
 /*
- *	linux/mm/msync.c
+ * The msync() system call.
  *
- * Copyright (C) 1994-1999  Linus Torvalds
+ * Copyright (C) 1994-1999 Linus Torvalds
+ * Copyright (C) 2008 Anton Salikhmetov <salikhmetov@gmail.com>
  */
 
-/*
- * The msync() system call.
- */
+#include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
-#include <linux/file.h>
-#include <linux/syscalls.h>
 #include <linux/sched.h>
+#include <linux/syscalls.h>
 
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *
  * MS_ASYNC does not start I/O (it used to, up to 2.5.67).
- * Nor does it marks the relevant pages dirty (it used to up to 2.6.17).
+ * Nor does it mark the relevant pages dirty (it used to up to 2.6.17).
  * Now it doesn't do anything, since dirty pages are properly tracked.
  *
- * The application may now run fsync() to
- * write out the dirty pages and wait on the writeout and check the result.
- * Or the application may run fadvise(FADV_DONTNEED) against the fd to start
- * async writeout immediately.
+ * The application may now run fsync() to write out the dirty pages and
+ * wait on the writeout and check the result. Or the application may run
+ * fadvise(FADV_DONTNEED) against the fd to start async writeout immediately.
  * So by _not_ starting I/O in MS_ASYNC we provide complete flexibility to
  * applications.
  */
 asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 {
 	unsigned long end;
-	struct mm_struct *mm = current->mm;
+	int error, unmapped_error;
 	struct vm_area_struct *vma;
-	int unmapped_error = 0;
-	int error = -EINVAL;
+	struct mm_struct *mm;
 
+	error = -EINVAL;
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
 	if (start & ~PAGE_MASK)
 		goto out;
 	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
 		goto out;
+
 	error = -ENOMEM;
-	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	len = PAGE_ALIGN(len);
 	end = start + len;
 	if (end < start)
 		goto out;
-	error = 0;
+
+	error = unmapped_error = 0;
 	if (end == start)
 		goto out;
+
 	/*
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
+	mm = current->mm;
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, start);
-	for (;;) {
+	do {
 		struct file *file;
 
-		/* Still start < end. */
 		error = -ENOMEM;
 		if (!vma)
-			goto out_unlock;
-		/* Here start < vma->vm_end. */
+			break;
 		if (start < vma->vm_start) {
 			start = vma->vm_start;
 			if (start >= end)
-				goto out_unlock;
-			unmapped_error = -ENOMEM;
-		}
-		/* Here vma->vm_start <= start < vma->vm_end. */
-		if ((flags & MS_INVALIDATE) &&
-				(vma->vm_flags & VM_LOCKED)) {
-			error = -EBUSY;
-			goto out_unlock;
+				break;
+			unmapped_error = error;
 		}
-		file = vma->vm_file;
+
+		error = -EBUSY;
+		if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED))
+			break;
+
+		error = 0;
 		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+		file = vma->vm_file;
+		if (file && (vma->vm_flags & VM_SHARED) && (flags & MS_SYNC)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
 			error = do_fsync(file, 0);
@@ -88,16 +86,13 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 				goto out;
 			down_read(&mm->mmap_sem);
 			vma = find_vma(mm, start);
-		} else {
-			if (start >= end) {
-				error = 0;
-				goto out_unlock;
-			}
-			vma = vma->vm_next;
+			continue;
 		}
-	}
-out_unlock:
+
+		vma = vma->vm_next;
+	} while (start < end);
 	up_read(&mm->mmap_sem);
+
 out:
-	return error ? : unmapped_error;
+	return error ? error : unmapped_error;
 }
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
