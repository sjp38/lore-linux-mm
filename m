Received: by fg-out-1718.google.com with SMTP id e12so773280fga.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 16:38:42 -0800 (PST)
Subject: [PATCH 1/2][RFC][BUG] msync: massive code cleanup of sys_msync()
From: Anton Salikhmetov <salikhmetov@gmail.com>
In-Reply-To: <1200006638.19293.42.camel@codedot>
References: <1200006638.19293.42.camel@codedot>
Content-Type: text/plain
Date: Fri, 11 Jan 2008 03:38:42 +0300
Message-Id: <1200011922.19293.92.camel@codedot>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Anton Salikhmetov <salikhmetov@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: jakob@unthought.net, linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com
List-ID: <linux-mm.kvack.org>

The patch contains substantial code cleanup of the sys_msync() function:

1) consolidated error check for function parameters;
2) using the PAGE_ALIGN() macro instead of "manual" alignment;
3) improved readability of the loop traversing the process memory regions.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>

---

diff --git a/mm/msync.c b/mm/msync.c
index 144a757..e788f7b 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -1,24 +1,25 @@
 /*
  *	linux/mm/msync.c
  *
+ * The msync() system call.
  * Copyright (C) 1994-1999  Linus Torvalds
+ *
+ * Substantial code cleanup.
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
  * The application may now run fsync() to
@@ -33,71 +34,60 @@ asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 	unsigned long end;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	int unmapped_error = 0;
-	int error = -EINVAL;
+	int error = 0, unmapped_error = 0;
+
+	if ((flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC)) ||
+			(start & ~PAGE_MASK) ||
+			((flags & MS_ASYNC) && (flags & MS_SYNC)))
+		return -EINVAL;
 
-	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
-		goto out;
-	if (start & ~PAGE_MASK)
-		goto out;
-	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
-		goto out;
-	error = -ENOMEM;
-	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	len = PAGE_ALIGN(len);
 	end = start + len;
 	if (end < start)
-		goto out;
-	error = 0;
+		return -ENOMEM;
 	if (end == start)
-		goto out;
+		return 0;
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
-		if ((flags & MS_INVALIDATE) &&
-				(vma->vm_flags & VM_LOCKED)) {
+		if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED)) {
 			error = -EBUSY;
-			goto out_unlock;
+			break;
 		}
 		file = vma->vm_file;
-		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+		if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
 			error = do_fsync(file, 0);
 			fput(file);
-			if (error || start >= end)
-				goto out;
+			if (error)
+				return error;
 			down_read(&mm->mmap_sem);
-			vma = find_vma(mm, start);
-		} else {
-			if (start >= end) {
-				error = 0;
-				goto out_unlock;
-			}
-			vma = vma->vm_next;
 		}
-	}
-out_unlock:
+
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	} while (start < end);
 	up_read(&mm->mmap_sem);
-out:
+
 	return error ? : unmapped_error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
