Date: Mon, 2 Sep 2002 19:43:45 +0200
From: Christoph Hellwig <hch@lst.de>
Message-ID: <20020902194345.A30976@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch was done after Linus requested it when I intended to split
madvice out of filemap.c.  We extend splitvma() in mmap.c to take
another argument that specifies whether to split above or below the
address given, and thus can use it in those function, cleaning them up
a lot and removing most of their code.



You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.490, 2002-08-17 23:43:39+02:00, hch@sb.bsdonline.org
  VM: split madvice(2) into a separate source file


 Makefile  |    2 
 filemap.c |  332 ------------------------------------------------------------
 madvise.c |  340 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 342 insertions, 332 deletions


diff -Nru a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile	Sat Aug 17 23:46:47 2002
+++ b/mm/Makefile	Sat Aug 17 23:46:47 2002
@@ -16,6 +16,6 @@
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
 	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o \
 	    shmem.o highmem.o mempool.o msync.o mincore.o readahead.o \
-	    pdflush.o page-writeback.o rmap.o
+	    pdflush.o page-writeback.o rmap.o madvise.o
 
 include $(TOPDIR)/Rules.make
diff -Nru a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c	Sat Aug 17 23:46:47 2002
+++ b/mm/filemap.c	Sat Aug 17 23:46:47 2002
@@ -1376,337 +1376,7 @@
 	return 0;
 }
 
-static inline void setup_read_behavior(struct vm_area_struct * vma,
-	int behavior)
-{
-	VM_ClearReadHint(vma);
-	switch(behavior) {
-		case MADV_SEQUENTIAL:
-			vma->vm_flags |= VM_SEQ_READ;
-			break;
-		case MADV_RANDOM:
-			vma->vm_flags |= VM_RAND_READ;
-			break;
-		default:
-			break;
-	}
-	return;
-}
-
-static long madvise_fixup_start(struct vm_area_struct * vma,
-	unsigned long end, int behavior)
-{
-	struct vm_area_struct * n;
-	struct mm_struct * mm = vma->vm_mm;
-
-	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!n)
-		return -EAGAIN;
-	*n = *vma;
-	n->vm_end = end;
-	setup_read_behavior(n, behavior);
-	n->vm_raend = 0;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
-	lock_vma_mappings(vma);
-	spin_lock(&mm->page_table_lock);
-	vma->vm_start = end;
-	__insert_vm_struct(mm, n);
-	spin_unlock(&mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
-
-static long madvise_fixup_end(struct vm_area_struct * vma,
-	unsigned long start, int behavior)
-{
-	struct vm_area_struct * n;
-	struct mm_struct * mm = vma->vm_mm;
-
-	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!n)
-		return -EAGAIN;
-	*n = *vma;
-	n->vm_start = start;
-	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
-	setup_read_behavior(n, behavior);
-	n->vm_raend = 0;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	lock_vma_mappings(vma);
-	spin_lock(&mm->page_table_lock);
-	vma->vm_end = start;
-	__insert_vm_struct(mm, n);
-	spin_unlock(&mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
-
-static long madvise_fixup_middle(struct vm_area_struct * vma,
-	unsigned long start, unsigned long end, int behavior)
-{
-	struct vm_area_struct * left, * right;
-	struct mm_struct * mm = vma->vm_mm;
-
-	left = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!left)
-		return -EAGAIN;
-	right = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!right) {
-		kmem_cache_free(vm_area_cachep, left);
-		return -EAGAIN;
-	}
-	*left = *vma;
-	*right = *vma;
-	left->vm_end = start;
-	right->vm_start = end;
-	right->vm_pgoff += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
-	left->vm_raend = 0;
-	right->vm_raend = 0;
-	if (vma->vm_file)
-		atomic_add(2, &vma->vm_file->f_count);
-
-	if (vma->vm_ops && vma->vm_ops->open) {
-		vma->vm_ops->open(left);
-		vma->vm_ops->open(right);
-	}
-	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
-	vma->vm_raend = 0;
-	lock_vma_mappings(vma);
-	spin_lock(&mm->page_table_lock);
-	vma->vm_start = start;
-	vma->vm_end = end;
-	setup_read_behavior(vma, behavior);
-	__insert_vm_struct(mm, left);
-	__insert_vm_struct(mm, right);
-	spin_unlock(&mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
-
-/*
- * We can potentially split a vm area into separate
- * areas, each area with its own behavior.
- */
-static long madvise_behavior(struct vm_area_struct * vma,
-	unsigned long start, unsigned long end, int behavior)
-{
-	int error = 0;
-
-	/* This caps the number of vma's this process can own */
-	if (vma->vm_mm->map_count > MAX_MAP_COUNT)
-		return -ENOMEM;
-
-	if (start == vma->vm_start) {
-		if (end == vma->vm_end) {
-			setup_read_behavior(vma, behavior);
-			vma->vm_raend = 0;
-		} else
-			error = madvise_fixup_start(vma, end, behavior);
-	} else {
-		if (end == vma->vm_end)
-			error = madvise_fixup_end(vma, start, behavior);
-		else
-			error = madvise_fixup_middle(vma, start, end, behavior);
-	}
-
-	return error;
-}
-
-/*
- * Schedule all required I/O operations, then run the disk queue
- * to make sure they are started.  Do not wait for completion.
- */
-static long madvise_willneed(struct vm_area_struct * vma,
-				unsigned long start, unsigned long end)
-{
-	long error = -EBADF;
-	struct file * file;
-	unsigned long size, rlim_rss;
-
-	/* Doesn't work if there's no mapped file. */
-	if (!vma->vm_file)
-		return error;
-	file = vma->vm_file;
-	size = (file->f_dentry->d_inode->i_size + PAGE_CACHE_SIZE - 1) >>
-							PAGE_CACHE_SHIFT;
-
-	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	if (end > vma->vm_end)
-		end = vma->vm_end;
-	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-
-	/* Make sure this doesn't exceed the process's max rss. */
-	error = -EIO;
-	rlim_rss = current->rlim ?  current->rlim[RLIMIT_RSS].rlim_cur :
-				LONG_MAX; /* default: see resource.h */
-	if ((vma->vm_mm->rss + (end - start)) > rlim_rss)
-		return error;
-
-	do_page_cache_readahead(file, start, end - start);
-	return 0;
-}
-
-/*
- * Application no longer needs these pages.  If the pages are dirty,
- * it's OK to just throw them away.  The app will be more careful about
- * data it wants to keep.  Be sure to free swap resources too.  The
- * zap_page_range call sets things up for refill_inactive to actually free
- * these pages later if no one else has touched them in the meantime,
- * although we could add these pages to a global reuse list for
- * refill_inactive to pick up before reclaiming other pages.
- *
- * NB: This interface discards data rather than pushes it out to swap,
- * as some implementations do.  This has performance implications for
- * applications like large transactional databases which want to discard
- * pages in anonymous maps after committing to backing store the data
- * that was kept in them.  There is no reason to write this data out to
- * the swap area if the application is discarding it.
- *
- * An interface that causes the system to free clean pages and flush
- * dirty pages is already available as msync(MS_INVALIDATE).
- */
-static long madvise_dontneed(struct vm_area_struct * vma,
-	unsigned long start, unsigned long end)
-{
-	if (vma->vm_flags & VM_LOCKED)
-		return -EINVAL;
-
-	zap_page_range(vma, start, end - start);
-	return 0;
-}
-
-static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
-	unsigned long end, int behavior)
-{
-	long error = -EBADF;
-
-	switch (behavior) {
-	case MADV_NORMAL:
-	case MADV_SEQUENTIAL:
-	case MADV_RANDOM:
-		error = madvise_behavior(vma, start, end, behavior);
-		break;
-
-	case MADV_WILLNEED:
-		error = madvise_willneed(vma, start, end);
-		break;
-
-	case MADV_DONTNEED:
-		error = madvise_dontneed(vma, start, end);
-		break;
-
-	default:
-		error = -EINVAL;
-		break;
-	}
-		
-	return error;
-}
-
-/*
- * The madvise(2) system call.
- *
- * Applications can use madvise() to advise the kernel how it should
- * handle paging I/O in this VM area.  The idea is to help the kernel
- * use appropriate read-ahead and caching techniques.  The information
- * provided is advisory only, and can be safely disregarded by the
- * kernel without affecting the correct operation of the application.
- *
- * behavior values:
- *  MADV_NORMAL - the default behavior is to read clusters.  This
- *		results in some read-ahead and read-behind.
- *  MADV_RANDOM - the system should read the minimum amount of data
- *		on any access, since it is unlikely that the appli-
- *		cation will need more than what it asks for.
- *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
- *		once, so they can be aggressively read ahead, and
- *		can be freed soon after they are accessed.
- *  MADV_WILLNEED - the application is notifying the system to read
- *		some pages ahead.
- *  MADV_DONTNEED - the application is finished with the given range,
- *		so the kernel can free resources associated with it.
- *
- * return values:
- *  zero    - success
- *  -EINVAL - start + len < 0, start is not page-aligned,
- *		"behavior" is not a valid value, or application
- *		is attempting to release locked or shared pages.
- *  -ENOMEM - addresses in the specified range are not currently
- *		mapped, or are outside the AS of the process.
- *  -EIO    - an I/O error occurred while paging in data.
- *  -EBADF  - map exists, but area maps something that isn't a file.
- *  -EAGAIN - a kernel resource was temporarily unavailable.
- */
-asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior)
-{
-	unsigned long end;
-	struct vm_area_struct * vma;
-	int unmapped_error = 0;
-	int error = -EINVAL;
-
-	down_write(&current->mm->mmap_sem);
-
-	if (start & ~PAGE_MASK)
-		goto out;
-	len = (len + ~PAGE_MASK) & PAGE_MASK;
-	end = start + len;
-	if (end < start)
-		goto out;
-
-	error = 0;
-	if (end == start)
-		goto out;
-
-	/*
-	 * If the interval [start,end) covers some unmapped address
-	 * ranges, just ignore them, but return -ENOMEM at the end.
-	 */
-	vma = find_vma(current->mm, start);
-	for (;;) {
-		/* Still start < end. */
-		error = -ENOMEM;
-		if (!vma)
-			goto out;
-
-		/* Here start < vma->vm_end. */
-		if (start < vma->vm_start) {
-			unmapped_error = -ENOMEM;
-			start = vma->vm_start;
-		}
-
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
-
-		/* Here vma->vm_start <= start < vma->vm_end < end. */
-		error = madvise_vma(vma, start, vma->vm_end, behavior);
-		if (error)
-			goto out;
-		start = vma->vm_end;
-		vma = vma->vm_next;
-	}
-
-out:
-	up_write(&current->mm->mmap_sem);
-	return error;
-}
-
-static inline
-struct page *__read_cache_page(struct address_space *mapping,
+static inline struct page *__read_cache_page(struct address_space *mapping,
 				unsigned long index,
 				int (*filler)(void *,struct page*),
 				void *data)
diff -Nru a/mm/madvise.c b/mm/madvise.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/mm/madvise.c	Sat Aug 17 23:46:47 2002
@@ -0,0 +1,340 @@
+/*
+ *	linux/mm/madvise.c
+ *
+ * Copyright (C) 1999  Linus Torvalds
+ */
+
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/pagemap.h>
+#include <linux/slab.h>
+
+
+static inline void setup_read_behavior(struct vm_area_struct * vma,
+				       int behavior)
+{
+	VM_ClearReadHint(vma);
+
+	switch (behavior) {
+	case MADV_SEQUENTIAL:
+		vma->vm_flags |= VM_SEQ_READ;
+		break;
+	case MADV_RANDOM:
+		vma->vm_flags |= VM_RAND_READ;
+		break;
+	default:
+		break;
+	}
+}
+
+static long madvise_fixup_start(struct vm_area_struct * vma,
+				unsigned long end, int behavior)
+{
+	struct vm_area_struct * n;
+	struct mm_struct * mm = vma->vm_mm;
+
+	n = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	if (!n)
+		return -EAGAIN;
+	*n = *vma;
+	n->vm_end = end;
+	setup_read_behavior(n, behavior);
+	n->vm_raend = 0;
+	if (n->vm_file)
+		get_file(n->vm_file);
+	if (n->vm_ops && n->vm_ops->open)
+		n->vm_ops->open(n);
+	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
+	lock_vma_mappings(vma);
+	spin_lock(&mm->page_table_lock);
+	vma->vm_start = end;
+	__insert_vm_struct(mm, n);
+	spin_unlock(&mm->page_table_lock);
+	unlock_vma_mappings(vma);
+	return 0;
+}
+
+static long madvise_fixup_end(struct vm_area_struct * vma,
+			      unsigned long start, int behavior)
+{
+	struct vm_area_struct * n;
+	struct mm_struct * mm = vma->vm_mm;
+
+	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!n)
+		return -EAGAIN;
+	*n = *vma;
+	n->vm_start = start;
+	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
+	setup_read_behavior(n, behavior);
+	n->vm_raend = 0;
+	if (n->vm_file)
+		get_file(n->vm_file);
+	if (n->vm_ops && n->vm_ops->open)
+		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
+	spin_lock(&mm->page_table_lock);
+	vma->vm_end = start;
+	__insert_vm_struct(mm, n);
+	spin_unlock(&mm->page_table_lock);
+	unlock_vma_mappings(vma);
+	return 0;
+}
+
+static long madvise_fixup_middle(struct vm_area_struct * vma, unsigned long start,
+				 unsigned long end, int behavior)
+{
+	struct vm_area_struct * left, * right;
+	struct mm_struct * mm = vma->vm_mm;
+
+	left = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!left)
+		return -EAGAIN;
+	right = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!right) {
+		kmem_cache_free(vm_area_cachep, left);
+		return -EAGAIN;
+	}
+	*left = *vma;
+	*right = *vma;
+	left->vm_end = start;
+	right->vm_start = end;
+	right->vm_pgoff += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
+	left->vm_raend = 0;
+	right->vm_raend = 0;
+	if (vma->vm_file)
+		atomic_add(2, &vma->vm_file->f_count);
+
+	if (vma->vm_ops && vma->vm_ops->open) {
+		vma->vm_ops->open(left);
+		vma->vm_ops->open(right);
+	}
+	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
+	vma->vm_raend = 0;
+	lock_vma_mappings(vma);
+	spin_lock(&mm->page_table_lock);
+	vma->vm_start = start;
+	vma->vm_end = end;
+	setup_read_behavior(vma, behavior);
+	__insert_vm_struct(mm, left);
+	__insert_vm_struct(mm, right);
+	spin_unlock(&mm->page_table_lock);
+	unlock_vma_mappings(vma);
+	return 0;
+}
+
+/*
+ * We can potentially split a vm area into separate
+ * areas, each area with its own behavior.
+ */
+static long madvise_behavior(struct vm_area_struct * vma, unsigned long start,
+			     unsigned long end, int behavior)
+{
+	int error = 0;
+
+	/* This caps the number of vma's this process can own */
+	if (vma->vm_mm->map_count > MAX_MAP_COUNT)
+		return -ENOMEM;
+
+	if (start == vma->vm_start) {
+		if (end == vma->vm_end) {
+			setup_read_behavior(vma, behavior);
+			vma->vm_raend = 0;
+		} else
+			error = madvise_fixup_start(vma, end, behavior);
+	} else {
+		if (end == vma->vm_end)
+			error = madvise_fixup_end(vma, start, behavior);
+		else
+			error = madvise_fixup_middle(vma, start, end, behavior);
+	}
+
+	return error;
+}
+
+/*
+ * Schedule all required I/O operations, then run the disk queue
+ * to make sure they are started.  Do not wait for completion.
+ */
+static long madvise_willneed(struct vm_area_struct * vma,
+			     unsigned long start, unsigned long end)
+{
+	long error = -EBADF;
+	struct file * file;
+	unsigned long size, rlim_rss;
+
+	/* Doesn't work if there's no mapped file. */
+	if (!vma->vm_file)
+		return error;
+	file = vma->vm_file;
+	size = (file->f_dentry->d_inode->i_size + PAGE_CACHE_SIZE - 1) >>
+							PAGE_CACHE_SHIFT;
+
+	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	if (end > vma->vm_end)
+		end = vma->vm_end;
+	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	/* Make sure this doesn't exceed the process's max rss. */
+	error = -EIO;
+	rlim_rss = current->rlim ?  current->rlim[RLIMIT_RSS].rlim_cur :
+				LONG_MAX; /* default: see resource.h */
+	if ((vma->vm_mm->rss + (end - start)) > rlim_rss)
+		return error;
+
+	do_page_cache_readahead(file, start, end - start);
+	return 0;
+}
+
+/*
+ * Application no longer needs these pages.  If the pages are dirty,
+ * it's OK to just throw them away.  The app will be more careful about
+ * data it wants to keep.  Be sure to free swap resources too.  The
+ * zap_page_range call sets things up for refill_inactive to actually free
+ * these pages later if no one else has touched them in the meantime,
+ * although we could add these pages to a global reuse list for
+ * refill_inactive to pick up before reclaiming other pages.
+ *
+ * NB: This interface discards data rather than pushes it out to swap,
+ * as some implementations do.  This has performance implications for
+ * applications like large transactional databases which want to discard
+ * pages in anonymous maps after committing to backing store the data
+ * that was kept in them.  There is no reason to write this data out to
+ * the swap area if the application is discarding it.
+ *
+ * An interface that causes the system to free clean pages and flush
+ * dirty pages is already available as msync(MS_INVALIDATE).
+ */
+static long madvise_dontneed(struct vm_area_struct * vma,
+			     unsigned long start, unsigned long end)
+{
+	if (vma->vm_flags & VM_LOCKED)
+		return -EINVAL;
+
+	zap_page_range(vma, start, end - start);
+	return 0;
+}
+
+static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
+			unsigned long end, int behavior)
+{
+	long error = -EBADF;
+
+	switch (behavior) {
+	case MADV_NORMAL:
+	case MADV_SEQUENTIAL:
+	case MADV_RANDOM:
+		error = madvise_behavior(vma, start, end, behavior);
+		break;
+
+	case MADV_WILLNEED:
+		error = madvise_willneed(vma, start, end);
+		break;
+
+	case MADV_DONTNEED:
+		error = madvise_dontneed(vma, start, end);
+		break;
+
+	default:
+		error = -EINVAL;
+		break;
+	}
+		
+	return error;
+}
+
+/*
+ * The madvise(2) system call.
+ *
+ * Applications can use madvise() to advise the kernel how it should
+ * handle paging I/O in this VM area.  The idea is to help the kernel
+ * use appropriate read-ahead and caching techniques.  The information
+ * provided is advisory only, and can be safely disregarded by the
+ * kernel without affecting the correct operation of the application.
+ *
+ * behavior values:
+ *  MADV_NORMAL - the default behavior is to read clusters.  This
+ *		results in some read-ahead and read-behind.
+ *  MADV_RANDOM - the system should read the minimum amount of data
+ *		on any access, since it is unlikely that the appli-
+ *		cation will need more than what it asks for.
+ *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
+ *		once, so they can be aggressively read ahead, and
+ *		can be freed soon after they are accessed.
+ *  MADV_WILLNEED - the application is notifying the system to read
+ *		some pages ahead.
+ *  MADV_DONTNEED - the application is finished with the given range,
+ *		so the kernel can free resources associated with it.
+ *
+ * return values:
+ *  zero    - success
+ *  -EINVAL - start + len < 0, start is not page-aligned,
+ *		"behavior" is not a valid value, or application
+ *		is attempting to release locked or shared pages.
+ *  -ENOMEM - addresses in the specified range are not currently
+ *		mapped, or are outside the AS of the process.
+ *  -EIO    - an I/O error occurred while paging in data.
+ *  -EBADF  - map exists, but area maps something that isn't a file.
+ *  -EAGAIN - a kernel resource was temporarily unavailable.
+ */
+asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior)
+{
+	unsigned long end;
+	struct vm_area_struct * vma;
+	int unmapped_error = 0;
+	int error = -EINVAL;
+
+	down_write(&current->mm->mmap_sem);
+
+	if (start & ~PAGE_MASK)
+		goto out;
+	len = (len + ~PAGE_MASK) & PAGE_MASK;
+	end = start + len;
+	if (end < start)
+		goto out;
+
+	error = 0;
+	if (end == start)
+		goto out;
+
+	/*
+	 * If the interval [start,end) covers some unmapped address
+	 * ranges, just ignore them, but return -ENOMEM at the end.
+	 */
+	vma = find_vma(current->mm, start);
+	for (;;) {
+		/* Still start < end. */
+		error = -ENOMEM;
+		if (!vma)
+			goto out;
+
+		/* Here start < vma->vm_end. */
+		if (start < vma->vm_start) {
+			unmapped_error = -ENOMEM;
+			start = vma->vm_start;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end. */
+		if (end <= vma->vm_end) {
+			if (start < end) {
+				error = madvise_vma(vma, start, end,
+							behavior);
+				if (error)
+					goto out;
+			}
+			error = unmapped_error;
+			goto out;
+		}
+
+		/* Here vma->vm_start <= start < vma->vm_end < end. */
+		error = madvise_vma(vma, start, vma->vm_end, behavior);
+		if (error)
+			goto out;
+		start = vma->vm_end;
+		vma = vma->vm_next;
+	}
+
+out:
+	up_write(&current->mm->mmap_sem);
+	return error;
+}

===================================================================


This BitKeeper patch contains the following changesets:
1.490
## Wrapped with gzip_uu ##


begin 664 bkpatch7649
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
&_X:2+@``
`
end

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
