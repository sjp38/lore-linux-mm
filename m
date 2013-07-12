Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E41376B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:34:31 -0400 (EDT)
Received: by mail-vc0-f202.google.com with SMTP id ha12so792537vcb.1
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 19:34:30 -0700 (PDT)
From: Colin Cross <ccross@android.com>
Subject: [PATCH 1/2] mm: rearrange madvise code to allow for reuse
Date: Thu, 11 Jul 2013 19:34:21 -0700
Message-Id: <1373596462-27115-1-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Colin Cross <ccross@android.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

This patch refactors the madvise syscall to allow for parts of it
to be reused by a prctl syscall that affects vmas.

Move the code that walks vmas in a virtual address range into a
function that takes a function pointer as a parameter.  The only
caller for now is sys_madvise, which uses it to call
madvise_vma_behavior on each vma, but the next patch will add
an additional caller.

Move handling all vma behaviors inside madvise_behavior, and
rename it to madvise_vma_behavior.

Move the code that updates the flags on a vma, including splitting
or merging the vma as necessary, into a new function called
madvise_update_vma.  The next patch will add support for updating
a new anon_name field as well.

Signed-off-by: Colin Cross <ccross@android.com>
---
 mm/madvise.c | 272 +++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 151 insertions(+), 121 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 7055883..b8820fd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -39,65 +39,20 @@ static int madvise_need_mmap_write(int behavior)
 }
 
 /*
- * We can potentially split a vm area into separate
- * areas, each area with its own behavior.
+ * Update the vm_flags on regiion of a vma, splitting it or merging it as
+ * necessary.  Must be called with mmap_sem held for writing;
  */
-static long madvise_behavior(struct vm_area_struct * vma,
-		     struct vm_area_struct **prev,
-		     unsigned long start, unsigned long end, int behavior)
+static int madvise_update_vma(struct vm_area_struct *vma,
+		     struct vm_area_struct **prev, unsigned long start,
+		     unsigned long end, unsigned long new_flags)
 {
 	struct mm_struct * mm = vma->vm_mm;
-	int error = 0;
 	pgoff_t pgoff;
-	unsigned long new_flags = vma->vm_flags;
-
-	switch (behavior) {
-	case MADV_NORMAL:
-		new_flags = new_flags & ~VM_RAND_READ & ~VM_SEQ_READ;
-		break;
-	case MADV_SEQUENTIAL:
-		new_flags = (new_flags & ~VM_RAND_READ) | VM_SEQ_READ;
-		break;
-	case MADV_RANDOM:
-		new_flags = (new_flags & ~VM_SEQ_READ) | VM_RAND_READ;
-		break;
-	case MADV_DONTFORK:
-		new_flags |= VM_DONTCOPY;
-		break;
-	case MADV_DOFORK:
-		if (vma->vm_flags & VM_IO) {
-			error = -EINVAL;
-			goto out;
-		}
-		new_flags &= ~VM_DONTCOPY;
-		break;
-	case MADV_DONTDUMP:
-		new_flags |= VM_DONTDUMP;
-		break;
-	case MADV_DODUMP:
-		if (new_flags & VM_SPECIAL) {
-			error = -EINVAL;
-			goto out;
-		}
-		new_flags &= ~VM_DONTDUMP;
-		break;
-	case MADV_MERGEABLE:
-	case MADV_UNMERGEABLE:
-		error = ksm_madvise(vma, start, end, behavior, &new_flags);
-		if (error)
-			goto out;
-		break;
-	case MADV_HUGEPAGE:
-	case MADV_NOHUGEPAGE:
-		error = hugepage_madvise(vma, &new_flags, behavior);
-		if (error)
-			goto out;
-		break;
-	}
+	int error;
 
 	if (new_flags == vma->vm_flags) {
 		*prev = vma;
-		goto out;
+		return 0;
 	}
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
@@ -113,13 +68,13 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	if (start != vma->vm_start) {
 		error = split_vma(mm, vma, start, 1);
 		if (error)
-			goto out;
+			return error;
 	}
 
 	if (end != vma->vm_end) {
 		error = split_vma(mm, vma, end, 0);
 		if (error)
-			goto out;
+			return error;
 	}
 
 success:
@@ -128,10 +83,7 @@ success:
 	 */
 	vma->vm_flags = new_flags;
 
-out:
-	if (error == -ENOMEM)
-		error = -EAGAIN;
-	return error;
+	return 0;
 }
 
 #ifdef CONFIG_SWAP
@@ -337,6 +289,77 @@ static long madvise_remove(struct vm_area_struct *vma,
 	return error;
 }
 
+/*
+ * Apply an madvise behavior to a region of a vma.  madvise_update_vma
+ * will handle splitting a vm area into separate areas, each area with its own
+ * behavior.
+ */
+static int madvise_vma_behavior(struct vm_area_struct *vma,
+		     struct vm_area_struct **prev,
+		     unsigned long start, unsigned long end,
+		     unsigned long behavior)
+{
+	int error = 0;
+	unsigned long new_flags = vma->vm_flags;
+
+	switch (behavior) {
+	case MADV_REMOVE:
+		return madvise_remove(vma, prev, start, end);
+	case MADV_WILLNEED:
+		return madvise_willneed(vma, prev, start, end);
+	case MADV_DONTNEED:
+		return madvise_dontneed(vma, prev, start, end);
+	case MADV_NORMAL:
+		new_flags = new_flags & ~VM_RAND_READ & ~VM_SEQ_READ;
+		break;
+	case MADV_SEQUENTIAL:
+		new_flags = (new_flags & ~VM_RAND_READ) | VM_SEQ_READ;
+		break;
+	case MADV_RANDOM:
+		new_flags = (new_flags & ~VM_SEQ_READ) | VM_RAND_READ;
+		break;
+	case MADV_DONTFORK:
+		new_flags |= VM_DONTCOPY;
+		break;
+	case MADV_DOFORK:
+		if (vma->vm_flags & VM_IO) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_DONTCOPY;
+		break;
+	case MADV_DONTDUMP:
+		new_flags |= VM_DONTDUMP;
+		break;
+	case MADV_DODUMP:
+		if (new_flags & VM_SPECIAL) {
+			error = -EINVAL;
+			goto out;
+		}
+		new_flags &= ~VM_DONTDUMP;
+		break;
+	case MADV_MERGEABLE:
+	case MADV_UNMERGEABLE:
+		error = ksm_madvise(vma, start, end, behavior, &new_flags);
+		if (error)
+			goto out;
+		break;
+	case MADV_HUGEPAGE:
+	case MADV_NOHUGEPAGE:
+		error = hugepage_madvise(vma, &new_flags, behavior);
+		if (error)
+			goto out;
+		break;
+	}
+
+	error = madvise_update_vma(vma, prev, start, end, new_flags);
+
+out:
+	if (error == -ENOMEM)
+		error = -EAGAIN;
+	return error;
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 /*
  * Error injection support for memory error handling.
@@ -369,22 +392,6 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 }
 #endif
 
-static long
-madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
-{
-	switch (behavior) {
-	case MADV_REMOVE:
-		return madvise_remove(vma, prev, start, end);
-	case MADV_WILLNEED:
-		return madvise_willneed(vma, prev, start, end);
-	case MADV_DONTNEED:
-		return madvise_dontneed(vma, prev, start, end);
-	default:
-		return madvise_behavior(vma, prev, start, end, behavior);
-	}
-}
-
 static int
 madvise_behavior_valid(int behavior)
 {
@@ -415,6 +422,73 @@ madvise_behavior_valid(int behavior)
 }
 
 /*
+ * Walk the vmas in range [start,end), and call the visit function on each one.
+ * The visit function will get start and end parameters that cover the overlap
+ * between the current vma and the original range.  Any unmapped regions in the
+ * original range will result in this function returning -ENOMEM while still
+ * calling the visit function on all of the existing vmas in the range.
+ * Must be called with the mmap_sem held for reading or writing.
+ */
+static
+int madvise_walk_vmas(unsigned long start, unsigned long end,
+		unsigned long arg,
+		int (*visit)(struct vm_area_struct *vma,
+			struct vm_area_struct **prev, unsigned long start,
+			unsigned long end, unsigned long arg))
+{
+	struct vm_area_struct *vma;
+	struct vm_area_struct *prev;
+	unsigned long tmp;
+	int unmapped_error = 0;
+
+	/*
+	 * If the interval [start,end) covers some unmapped address
+	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 * - different from the way of handling in mlock etc.
+	 */
+	vma = find_vma_prev(current->mm, start, &prev);
+	if (vma && start > vma->vm_start)
+		prev = vma;
+
+	for (;;) {
+		int error;
+
+		/* Still start < end. */
+		if (!vma)
+			return -ENOMEM;
+
+		/* Here start < (end|vma->vm_end). */
+		if (start < vma->vm_start) {
+			unmapped_error = -ENOMEM;
+			start = vma->vm_start;
+			if (start >= end)
+				break;
+		}
+
+		/* Here vma->vm_start <= start < (end|vma->vm_end) */
+		tmp = vma->vm_end;
+		if (end < tmp)
+			tmp = end;
+
+		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
+		error = visit(vma, &prev, start, tmp, arg);
+		if (error)
+			return error;
+		start = tmp;
+		if (prev && start < prev->vm_end)
+			start = prev->vm_end;
+		if (start >= end)
+			break;
+		if (prev)
+			vma = prev->vm_next;
+		else	/* madvise_remove dropped mmap_sem */
+			vma = find_vma(current->mm, start);
+	}
+
+	return unmapped_error;
+}
+
+/*
  * The madvise(2) system call.
  *
  * Applications can use madvise() to advise the kernel how it should
@@ -458,9 +532,7 @@ madvise_behavior_valid(int behavior)
  */
 SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 {
-	unsigned long end, tmp;
-	struct vm_area_struct * vma, *prev;
-	int unmapped_error = 0;
+	unsigned long end;
 	int error = -EINVAL;
 	int write;
 	size_t len;
@@ -495,52 +567,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	else
 		down_read(&current->mm->mmap_sem);
 
-	/*
-	 * If the interval [start,end) covers some unmapped address
-	 * ranges, just ignore them, but return -ENOMEM at the end.
-	 * - different from the way of handling in mlock etc.
-	 */
-	vma = find_vma_prev(current->mm, start, &prev);
-	if (vma && start > vma->vm_start)
-		prev = vma;
-
 	blk_start_plug(&plug);
-	for (;;) {
-		/* Still start < end. */
-		error = -ENOMEM;
-		if (!vma)
-			goto out;
-
-		/* Here start < (end|vma->vm_end). */
-		if (start < vma->vm_start) {
-			unmapped_error = -ENOMEM;
-			start = vma->vm_start;
-			if (start >= end)
-				goto out;
-		}
-
-		/* Here vma->vm_start <= start < (end|vma->vm_end) */
-		tmp = vma->vm_end;
-		if (end < tmp)
-			tmp = end;
-
-		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
-		if (error)
-			goto out;
-		start = tmp;
-		if (prev && start < prev->vm_end)
-			start = prev->vm_end;
-		error = unmapped_error;
-		if (start >= end)
-			goto out;
-		if (prev)
-			vma = prev->vm_next;
-		else	/* madvise_remove dropped mmap_sem */
-			vma = find_vma(current->mm, start);
-	}
-out:
+	error = madvise_walk_vmas(start, end, behavior, madvise_vma_behavior);
 	blk_finish_plug(&plug);
+
 	if (write)
 		up_write(&current->mm->mmap_sem);
 	else
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
