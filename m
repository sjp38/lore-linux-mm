Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j2G9M36O018494
	for <linux-mm@kvack.org>; Wed, 16 Mar 2005 01:22:04 -0800 (PST)
From: pmeda@akamai.com
Date: Wed, 16 Mar 2005 01:30:59 -0800
Message-Id: <200503160930.BAA20200@allur.sanmateo.akamai.com>
Subject: [PATCH 2/2] madvise: merge the maps
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: chrisw@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This attempts to merge back the split maps. This
code is mostly copied from Chrisw's mlock merging
from post 2.6.11 trees. The only difference is in
munmapped_error handling. Also passed prev to
willneed/dontneed, eventhogh they do not handle it
now, since I  felt it will be cleaner, instead of
handling prev in madvise_vma in some cases and in
subfunction in some cases.

Signed-off-by: Prasanna Meda <pmeda@akamai.com>

--- linux/mm/madvise.c	Wed Mar 16 06:17:58 2005
+++ Linux/mm/madvise.c	Wed Mar 16 08:33:18 2005
@@ -8,17 +8,20 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/syscalls.h>
+#include <linux/mempolicy.h>
 #include <linux/hugetlb.h>
 
 /*
  * We can potentially split a vm area into separate
  * areas, each area with its own behavior.
  */
-static long madvise_behavior(struct vm_area_struct * vma, unsigned long start,
-			     unsigned long end, int behavior)
+static long madvise_behavior(struct vm_area_struct * vma, 
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end, int behavior)
 {
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
+	pgoff_t pgoff;
 	int new_flags = vma->vm_flags & ~VM_READHINTMASK;
 
 	switch (behavior) {
@@ -32,8 +35,20 @@
 		break;
 	}
 
-	if (new_flags == vma->vm_flags)
-		goto out;
+	if (new_flags == vma->vm_flags) {
+		*prev = vma;
+		goto success;
+	}
+
+	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
+	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
+				vma->vm_file, pgoff, vma_policy(vma));
+	if (*prev) {
+		vma = *prev;
+		goto success;
+	}
+
+	*prev = vma;
 
 	if (start != vma->vm_start) {
 		error = split_vma(mm, vma, start, 1);
@@ -56,6 +71,7 @@
 out:
 	if (error == -ENOMEM)
 		error = -EAGAIN;
+success:
 	return error;
 }
 
@@ -63,6 +79,7 @@
  * Schedule all required I/O operations.  Do not wait for completion.
  */
 static long madvise_willneed(struct vm_area_struct * vma,
+			     struct vm_area_struct ** prev,
 			     unsigned long start, unsigned long end)
 {
 	struct file *file = vma->vm_file;
@@ -70,6 +87,7 @@
 	if (!file)
 		return -EBADF;
 
+	*prev = vma;
 	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	if (end > vma->vm_end)
 		end = vma->vm_end;
@@ -100,8 +118,10 @@
  * dirty pages is already available as msync(MS_INVALIDATE).
  */
 static long madvise_dontneed(struct vm_area_struct * vma,
+			     struct vm_area_struct ** prev,
 			     unsigned long start, unsigned long end)
 {
+	*prev = vma;
 	if ((vma->vm_flags & VM_LOCKED) || is_vm_hugetlb_page(vma))
 		return -EINVAL;
 
@@ -116,8 +136,8 @@
 	return 0;
 }
 
-static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
-			unsigned long end, int behavior)
+static long madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
+			unsigned long start, unsigned long end, int behavior)
 {
 	long error = -EBADF;
 
@@ -125,15 +145,15 @@
 	case MADV_NORMAL:
 	case MADV_SEQUENTIAL:
 	case MADV_RANDOM:
-		error = madvise_behavior(vma, start, end, behavior);
+		error = madvise_behavior(vma, prev, start, end, behavior);
 		break;
 
 	case MADV_WILLNEED:
-		error = madvise_willneed(vma, start, end);
+		error = madvise_willneed(vma, prev, start, end);
 		break;
 
 	case MADV_DONTNEED:
-		error = madvise_dontneed(vma, start, end);
+		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
 	default:
@@ -180,8 +200,8 @@
  */
 asmlinkage long sys_madvise(unsigned long start, size_t len_in, int behavior)
 {
-	unsigned long end;
-	struct vm_area_struct * vma;
+	unsigned long end, tmp;
+	struct vm_area_struct * vma, *prev;
 	int unmapped_error = 0;
 	int error = -EINVAL;
 	size_t len;
@@ -207,40 +227,42 @@
 	/*
 	 * If the interval [start,end) covers some unmapped address
 	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 * - different from the way of handling in mlock etc.
 	 */
-	vma = find_vma(current->mm, start);
+	vma = find_vma_prev(current->mm, start, &prev);
+	if (!vma && prev)
+		vma = prev->vm_next;
 	for (;;) {
 		/* Still start < end. */
 		error = -ENOMEM;
 		if (!vma)
 			goto out;
 
-		/* Here start < vma->vm_end. */
+		/* Here start < (end|vma->vm_end). */
 		if (start < vma->vm_start) {
 			unmapped_error = -ENOMEM;
 			start = vma->vm_start;
+			if (start >= end)
+				goto out;
 		}
 
-		/* Here vma->vm_start <= start < vma->vm_end. */
-		if (end <= vma->vm_end) {
-			if (start < end) {
-				error = madvise_vma(vma, start, end,
-							behavior);
-				if (error)
-					goto out;
-			}
-			error = unmapped_error;
-			goto out;
-		}
+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
 
-		/* Here vma->vm_start <= start < vma->vm_end < end. */
-		error = madvise_vma(vma, start, vma->vm_end, behavior);
+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
+		error = madvise_vma(vma, &prev, start, tmp, behavior);
 		if (error)
 			goto out;
-		start = vma->vm_end;
-		vma = vma->vm_next;
+		start = tmp;
+		if (start < prev->vm_end)
+			start = prev->vm_end;
+		error = unmapped_error;
+		if (start >= end)
+			goto out;
+		vma = prev->vm_next;
 	}
-
 out:
 	up_write(&current->mm->mmap_sem);
 	return error;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
