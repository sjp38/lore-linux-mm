Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 99F9A6B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:13:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6136504pbb.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:13:33 -0700 (PDT)
Date: Sat, 12 May 2012 05:13:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/10] mm/fs: route MADV_REMOVE to FALLOC_FL_PUNCH_HOLE
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120505560.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Colin Cross <ccross@android.com>, John Stulz <john.stulz@linaro.org>, Greg Kroah-Hartman <gregkh@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, Mark Fasheh <mfasheh@suse.de>, Joel Becker <jlbec@evilplan.org>, Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Now tmpfs supports hole-punching via fallocate(), switch madvise_remove()
to use do_fallocate() instead of vmtruncate_range(): which extends
madvise(,,MADV_REMOVE) support from tmpfs to ext4, ocfs2 and xfs.

There is one more user of vmtruncate_range() in our tree, staging/android's
ashmem_shrink(): convert it to use do_fallocate() too (but if its unpinned
areas are already unmapped - I don't know - then it would do better to use
shmem_truncate_range() directly).

Based-on-patch-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 drivers/staging/android/ashmem.c |    8 +++++---
 mm/madvise.c                     |   15 +++++++--------
 2 files changed, 12 insertions(+), 11 deletions(-)

--- 3045N.orig/drivers/staging/android/ashmem.c	2012-05-05 10:42:33.564056626 -0700
+++ 3045N/drivers/staging/android/ashmem.c	2012-05-05 10:46:25.692062478 -0700
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/file.h>
 #include <linux/fs.h>
+#include <linux/falloc.h>
 #include <linux/miscdevice.h>
 #include <linux/security.h>
 #include <linux/mm.h>
@@ -363,11 +364,12 @@ static int ashmem_shrink(struct shrinker
 
 	mutex_lock(&ashmem_mutex);
 	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
-		struct inode *inode = range->asma->file->f_dentry->d_inode;
 		loff_t start = range->pgstart * PAGE_SIZE;
-		loff_t end = (range->pgend + 1) * PAGE_SIZE - 1;
+		loff_t end = (range->pgend + 1) * PAGE_SIZE;
 
-		vmtruncate_range(inode, start, end);
+		do_fallocate(range->asma->file,
+				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				start, end - start);
 		range->purged = ASHMEM_WAS_PURGED;
 		lru_del(range);
 
--- 3045N.orig/mm/madvise.c	2012-05-05 10:42:33.572056784 -0700
+++ 3045N/mm/madvise.c	2012-05-05 10:46:25.692062478 -0700
@@ -11,8 +11,10 @@
 #include <linux/mempolicy.h>
 #include <linux/page-isolation.h>
 #include <linux/hugetlb.h>
+#include <linux/falloc.h>
 #include <linux/sched.h>
 #include <linux/ksm.h>
+#include <linux/fs.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -200,8 +202,7 @@ static long madvise_remove(struct vm_are
 				struct vm_area_struct **prev,
 				unsigned long start, unsigned long end)
 {
-	struct address_space *mapping;
-	loff_t offset, endoff;
+	loff_t offset;
 	int error;
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
@@ -217,16 +218,14 @@ static long madvise_remove(struct vm_are
 	if ((vma->vm_flags & (VM_SHARED|VM_WRITE)) != (VM_SHARED|VM_WRITE))
 		return -EACCES;
 
-	mapping = vma->vm_file->f_mapping;
-
 	offset = (loff_t)(start - vma->vm_start)
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-	endoff = (loff_t)(end - vma->vm_start - 1)
-			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
-	/* vmtruncate_range needs to take i_mutex */
+	/* filesystem's fallocate may need to take i_mutex */
 	up_read(&current->mm->mmap_sem);
-	error = vmtruncate_range(mapping->host, offset, endoff);
+	error = do_fallocate(vma->vm_file,
+				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				offset, end - start);
 	down_read(&current->mm->mmap_sem);
 	return error;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
