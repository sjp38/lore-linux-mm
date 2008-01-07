Received: by nf-out-0910.google.com with SMTP id h3so907466nfh.6
        for <linux-mm@kvack.org>; Mon, 07 Jan 2008 09:54:20 -0800 (PST)
Subject: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
	msync()
From: Anton Salikhmetov <salikhmetov@gmail.com>
Content-Type: text/plain
Date: Mon, 07 Jan 2008 20:54:19 +0300
Message-Id: <1199728459.26463.11.camel@codedot>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Anton Salikhmetov <salikhmetov@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Due to the lack of reaction in LKML I presume the message was lost
in the high traffic of that list. Resending it now with the addressee changed
to the memory management mailing list.

I would like to propose my solution for the bug #2645 from the kernel bug tracker:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

The Open Group defines the behavior of the mmap() function as follows.

The st_ctime and st_mtime fields of a file that is mapped with MAP_SHARED
and PROT_WRITE shall be marked for update at some point in the interval
between a write reference to the mapped region and the next call to msync()
with MS_ASYNC or MS_SYNC for that portion of the file by any process.
If there is no such call and if the underlying file is modified as a result
of a write reference, then these fields shall be marked for update at some
time after the write reference.

The above citation was taken from the following link:

http://www.opengroup.org/onlinepubs/009695399/functions/mmap.html

Therefore, the msync() function should be called before verifying the time
stamps st_mtime and st_ctime in the test program Badari wrote in the context
of the bug #2645. Otherwise, the time stamps may be updated
at some unspecified moment according to the POSIX standard.

I changed his test program a little. The changed unit test can be downloaded
using the following link:

http://pygx.sourceforge.net/mmap.c

This program showed that the msync() function had a bug:
it did not update the st_mtime and st_ctime fields.

The program shows appropriate behavior of the msync()
function using the kernel with the proposed patch applied.
Specifically, the ctime and mtime time stamps do change
when modifying the mapped memory and do not change when
there have been no write references between the mmap()
and msync() system calls.

Additionally, the test cases for the msync() system call from
the LTP test suite (msync01 - msync05, mmapstress01, mmapstress09,
and mmapstress10) successfully passed using the kernel
with the patch included into this email.

The patch adds a call to the file_update_time() function to change
the file metadata before syncing. The patch also contains
substantial code cleanup: consolidated error check
for function parameters, using the PAGE_ALIGN() macro instead of
"manual" alignment, improved readability of the loop,
which traverses the process memory regions, updated comments.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>

---

diff --git a/mm/msync.c b/mm/msync.c
index 144a757..cb973eb 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -1,26 +1,32 @@
 /*
  *	linux/mm/msync.c
  *
+ * The msync() system call.
  * Copyright (C) 1994-1999  Linus Torvalds
+ *
+ * Updating the mtime and ctime stamps for mapped files
+ * and code cleanup.
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
+ * The msync() system call updates the ctime and mtime fields for
+ * the mapped file when called with the MS_SYNC or MS_ASYNC flags
+ * according to the POSIX standard.
+ *
  * The application may now run fsync() to
  * write out the dirty pages and wait on the writeout and check the result.
  * Or the application may run fadvise(FADV_DONTNEED) against the fd to start
@@ -33,70 +39,68 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 	unsigned long end;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	int unmapped_error = 0;
-	int error = -EINVAL;
+	int error = 0, unmapped_error = 0;
 
-	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
-		goto out;
-	if (start & ~PAGE_MASK)
+	if ((flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC)) ||
+			(start & ~PAGE_MASK) ||
+			((flags & MS_ASYNC) && (flags & MS_SYNC))) {
+		error = -EINVAL;
 		goto out;
-	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
-		goto out;
-	error = -ENOMEM;
-	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	}
+
+	len = PAGE_ALIGN(len);
 	end = start + len;
-	if (end < start)
+	if (end < start) {
+		error = -ENOMEM;
 		goto out;
-	error = 0;
+	}
 	if (end == start)
 		goto out;
+
 	/*
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, start);
-	for (;;) {
+	do {
 		struct file *file;
 
-		/* Still start < end. */
-		error = -ENOMEM;
-		if (!vma)
-			goto out_unlock;
-		/* Here start < vma->vm_end. */
+		if (!vma) {
+			error = -ENOMEM;
+			break;
+		}
 		if (start < vma->vm_start) {
 			start = vma->vm_start;
-			if (start >= end)
-				goto out_unlock;
+			if (start >= end) {
+				error = -ENOMEM;
+				break;
+			}
 			unmapped_error = -ENOMEM;
 		}
-		/* Here vma->vm_start <= start < vma->vm_end. */
 		if ((flags & MS_INVALIDATE) &&
 				(vma->vm_flags & VM_LOCKED)) {
 			error = -EBUSY;
-			goto out_unlock;
+			break;
 		}
 		file = vma->vm_file;
-		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+		if (file && (vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
-			error = do_fsync(file, 0);
-			fput(file);
-			if (error || start >= end)
-				goto out;
-			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, start);
-		} else {
-			if (start >= end) {
-				error = 0;
-				goto out_unlock;
+			if (file->f_mapping->host->i_state & I_DIRTY_PAGES)
+				file_update_time(file);
+			if (flags & MS_SYNC) {
+				up_read(&mm->mmap_sem);
+				error = do_fsync(file, 0);
+				down_read(&mm->mmap_sem);
 			}
-			vma = vma->vm_next;
+			fput(file);
+			if (error)
+				break;
 		}
-	}
-out_unlock:
+
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (start < end);
 	up_read(&mm->mmap_sem);
 out:
 	return error ? : unmapped_error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
