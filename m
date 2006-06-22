Date: Thu, 22 Jun 2006 18:02:45 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 3/6] mm: msync() cleanup
In-Reply-To: <20060619175315.24655.45123.sendpatchset@lappy>
Message-ID: <Pine.LNX.4.64.0606221733570.4977@blonde.wat.veritas.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175315.24655.45123.sendpatchset@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Peter Zijlstra wrote:
> 
> With the tracking of dirty pages properly done now, msync doesn't need to
> scan the PTEs anymore to determine the dirty status.

Lots of nice deletions, but...

>  static int msync_interval(struct vm_area_struct *vma, unsigned long addr,
> -			unsigned long end, int flags,
> -			unsigned long *nr_pages_dirtied)
> +			unsigned long end, int flags)
>  {
> -	struct file *file = vma->vm_file;
> -
>  	if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED))
>  		return -EBUSY;
>  
> -	if (file && (vma->vm_flags & VM_SHARED))
> -		*nr_pages_dirtied = msync_page_range(vma, addr, end);
>  	return 0;
>  }

... I was offended by this msync_interval remnant which does nothing
but (rightly) choose between -EBUSY and 0: msync_interval isn't the
name I'd give that; but it might as well be brought in line anyway.

In looking to do that, I made some other tidyups: can remove several
#includes, don't keep re-evaluating current, PF_SYNCWRITE manipulation
best left to do_fsync, and sys_msync loop termination not quite right.

Most of those points are criticisms of the existing sys_msync, not of
your patch.  In particular, the loop termination errors were introduced
in 2.6.17: I did notice this shortly before it came out, but decided I
was more likely to get it wrong myself, and make matters worse if I
tried to rush a last-minute fix in.  And it's not terribly likely
to go wrong, nor disastrous if it does go wrong (may miss reporting
an unmapped area; may also fsync file of a following vma).

Would you apply this patch on top of yours, and give it a long hard
look to see if you agree it's correct and an improvement?  If you
do agree, please absorb it into yours, then maybe Andrew will want
one of us to supply just a fix patch to the current sys_msync,
to precede your dirty page series.

Ah, -mm already includes patches from Jens which delete PF_SYNCWRITE
altogether.

Hugh

--- your/mm/msync.c	2006-06-13 19:48:41.000000000 +0100
+++ my/mm/msync.c	2006-06-14 20:51:20.000000000 +0100
@@ -7,19 +7,12 @@
 /*
  * The msync() system call.
  */
-#include <linux/slab.h>
-#include <linux/pagemap.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
-#include <linux/hugetlb.h>
-#include <linux/writeback.h>
 #include <linux/file.h>
 #include <linux/syscalls.h>
 
-#include <asm/pgtable.h>
-#include <asm/tlbflush.h>
-
 /*
  * MS_SYNC syncs the entire file - including mappings.
  *
@@ -34,22 +27,14 @@
  * So by _not_ starting I/O in MS_ASYNC we provide complete flexibility to
  * applications.
  */
-static int msync_interval(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long end, int flags)
-{
-	if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED))
-		return -EBUSY;
-
-	return 0;
-}
 
 asmlinkage long sys_msync(unsigned long start, size_t len, int flags)
 {
 	unsigned long end;
+	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	int unmapped_error = 0;
 	int error = -EINVAL;
-	int done = 0;
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
@@ -69,56 +54,46 @@ asmlinkage long sys_msync(unsigned long 
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&current->mm->mmap_sem);
-	if (flags & MS_SYNC)
-		current->flags |= PF_SYNCWRITE;
-	vma = find_vma(current->mm, start);
-	if (!vma) {
-		error = -ENOMEM;
-		goto out_unlock;
-	}
-	do {
+	down_read(&mm->mmap_sem);
+	vma = find_vma(mm, start);
+	for (;;) {
 		struct file *file;
 
+		/* Still start < end. */
+		error = -ENOMEM;
+		if (!vma)
+			goto out_unlock;
 		/* Here start < vma->vm_end. */
 		if (start < vma->vm_start) {
-			unmapped_error = -ENOMEM;
 			start = vma->vm_start;
+			if (start >= end)
+				goto out_unlock;
+			unmapped_error = -ENOMEM;
 		}
 		/* Here vma->vm_start <= start < vma->vm_end. */
-		if (end <= vma->vm_end) {
-			if (start < end) {
-				error = msync_interval(vma, start, end, flags);
-				if (error)
-					goto out_unlock;
-			}
-			error = unmapped_error;
-			done = 1;
-		} else {
-			/* Here vma->vm_start <= start < vma->vm_end < end. */
-			error = msync_interval(vma, start, vma->vm_end, flags);
-			if (error)
-				goto out_unlock;
+		if ((flags & MS_INVALIDATE) && (vma->vm_flags & VM_LOCKED)) {
+			error = -EBUSY;
+			goto out_unlock;
 		}
 		file = vma->vm_file;
 		start = vma->vm_end;
-		if ((flags & MS_SYNC) && file &&
-				(vma->vm_flags & VM_SHARED)) {
+		if ((flags & MS_SYNC) && file && (vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&current->mm->mmap_sem);
+			up_read(&mm->mmap_sem);
 			error = do_fsync(file, 0);
 			fput(file);
-			down_read(&current->mm->mmap_sem);
-			if (error)
-				goto out_unlock;
-			vma = find_vma(current->mm, start);
+			if (error || start >= end)
+				goto out;
+			down_read(&mm->mmap_sem);
+			vma = find_vma(mm, start);
 		} else {
+			if (start >= end)
+				goto out_unlock;
 			vma = vma->vm_next;
 		}
-	} while (vma && !done);
+	}
 out_unlock:
-	current->flags &= ~PF_SYNCWRITE;
-	up_read(&current->mm->mmap_sem);
+	up_read(&mm->mmap_sem);
 out:
-	return error;
+	return error? : unmapped_error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
