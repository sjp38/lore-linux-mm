Date: Tue, 14 Mar 2000 18:13:19 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: [PATCH] madvise() against 2.3.52-3
Message-ID: <Pine.BSO.4.10.10003141806190.19943-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

linus-

here's madvise.  comments welcome and appreciated.

i'm not sure the madvise_dontneed implementation is quite correct.

after reviewing the recent discussion on linux-mm and some of the logic in
filemap_sync, i decided that the two different desirable behaviors are:

1.  free clean pages, flush dirty pages
	- already available as msync(MS_INVALIDATE)

2.  free clean and dirty pages, discarding changes
	- now available as madvise(MADV_DONTNEED)

i think this gets us both behaviors jamie lokier advocated recently.

diff -ruN Linux-2.3.52-3/arch/i386/kernel/entry.S linux/arch/i386/kernel/entry.S
--- Linux-2.3.52-3/arch/i386/kernel/entry.S	Tue Mar 14 14:04:20 2000
+++ linux/arch/i386/kernel/entry.S	Tue Mar 14 16:07:46 2000
@@ -639,6 +639,7 @@
 	.long SYMBOL_NAME(sys_setfsgid)
 	.long SYMBOL_NAME(sys_pivot_root)
 	.long SYMBOL_NAME(sys_mincore)
+	.long SYMBOL_NAME(sys_madvise)
 
 
 	/*
@@ -647,6 +648,6 @@
 	 * entries. Don't panic if you notice that this hasn't
 	 * been shrunk every time we add a new system call.
 	 */
-	.rept NR_syscalls-218
+	.rept NR_syscalls-219
 		.long SYMBOL_NAME(sys_ni_syscall)
 	.endr
diff -ruN Linux-2.3.52-3/include/asm-i386/mman.h linux/include/asm-i386/mman.h
--- Linux-2.3.52-3/include/asm-i386/mman.h	Mon Oct  7 01:55:48 1996
+++ linux/include/asm-i386/mman.h	Tue Mar 14 17:12:00 2000
@@ -25,6 +25,12 @@
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
 
+#define MADV_NORMAL	0x0		/* default page-in behavior */
+#define MADV_RANDOM	0x1		/* page-in minimum required */
+#define MADV_SEQUENTIAL	0x2		/* read-ahead aggressively */
+#define MADV_WILLNEED	0x3		/* pre-fault pages */
+#define MADV_DONTNEED	0x4		/* discard these pages */
+
 /* compatibility flags */
 #define MAP_ANON	MAP_ANONYMOUS
 #define MAP_FILE	0
diff -ruN Linux-2.3.52-3/include/asm-i386/unistd.h linux/include/asm-i386/unistd.h
--- Linux-2.3.52-3/include/asm-i386/unistd.h	Tue Mar 14 14:04:27 2000
+++ linux/include/asm-i386/unistd.h	Tue Mar 14 17:13:06 2000
@@ -223,6 +223,8 @@
 #define __NR_setfsgid32		216
 #define __NR_pivot_root		217
 #define __NR_mincore		218
+#define __NR_madvise		219
+#define __NR_madvise1		219	/* delete when C lib stub is removed */
 
 /* user-visible error numbers are in the range -1 - -124: see <asm-i386/errno.h> */
 
diff -ruN Linux-2.3.52-3/include/linux/mm.h linux/include/linux/mm.h
--- Linux-2.3.52-3/include/linux/mm.h	Sun Mar 12 18:42:36 2000
+++ linux/include/linux/mm.h	Tue Mar 14 17:49:44 2000
@@ -60,6 +60,7 @@
 	struct vm_operations_struct * vm_ops;
 	unsigned long vm_pgoff;		/* offset in PAGE_SIZE units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;
+	unsigned long vm_raend;
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 };
 
@@ -83,10 +84,19 @@
 
 #define VM_EXECUTABLE	0x00001000
 #define VM_LOCKED	0x00002000
-#define VM_IO           0x00004000  /* Memory mapped I/O or similar */
+#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
+
+#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
+#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
 
 #define VM_STACK_FLAGS	0x00000177
 
+#define VM_READHINTMASK			(VM_SEQ_READ | VM_RAND_READ)
+#define VM_ClearReadHint(v)		(v)->vm_flags &= ~VM_READHINTMASK
+#define VM_NormalReadHint(v)		(!((v)->vm_flags & VM_READHINTMASK))
+#define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
+#define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
@@ -105,7 +115,6 @@
 	void (*unmap)(struct vm_area_struct *area, unsigned long, size_t);
 	void (*protect)(struct vm_area_struct *area, unsigned long, size_t, unsigned int newprot);
 	int (*sync)(struct vm_area_struct *area, unsigned long, size_t, unsigned int flags);
-	void (*advise)(struct vm_area_struct *area, unsigned long, size_t, unsigned int advise);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	struct page * (*wppage)(struct vm_area_struct * area, unsigned long address, struct page * page);
 	int (*swapout)(struct page *, struct file *);
diff -ruN Linux-2.3.52-3/mm/filemap.c linux/mm/filemap.c
--- Linux-2.3.52-3/mm/filemap.c	Tue Mar 14 14:04:28 2000
+++ linux/mm/filemap.c	Tue Mar 14 18:02:26 2000
@@ -25,6 +25,7 @@
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
+#include <asm/mman.h>
 
 #include <linux/highmem.h>
 
@@ -1294,6 +1295,61 @@
 }
 
 /*
+ * Read-ahead and flush behind for MADV_SEQUENTIAL areas.  Since we are
+ * sure this is sequential access, we don't need a flexible read-ahead
+ * window size -- we can always use a large fixed size window.
+ */
+static void nopage_sequential_readahead(struct vm_area_struct * vma,
+	unsigned long pgoff, unsigned long filesize)
+{
+	unsigned long ra_window;
+
+	ra_window = get_max_readahead(vma->vm_file->f_dentry->d_inode);
+	ra_window = CLUSTER_OFFSET(ra_window + CLUSTER_PAGES - 1);
+
+	/* vm_raend is zero if we haven't read ahead in this area yet.  */
+	if (vma->vm_raend == 0)
+		vma->vm_raend = vma->vm_pgoff + ra_window;
+
+	/*
+	 * If we've just faulted the page half-way through our window,
+	 * then schedule reads for the next window, and release the
+	 * pages in the previous window.
+	 */
+	if ((pgoff + (ra_window >> 1)) == vma->vm_raend) {
+		unsigned long start = vma->vm_pgoff + vma->vm_raend;
+		unsigned long end = start + ra_window;
+
+		if (end > ((vma->vm_end >> PAGE_SHIFT) + vma->vm_pgoff))
+			end = (vma->vm_end >> PAGE_SHIFT) + vma->vm_pgoff;
+		if (start > end)
+			return;
+
+		while ((start < end) && (start < filesize)) {
+			if (read_cluster_nonblocking(vma->vm_file,
+							start, filesize) < 0)
+				break;
+			start += CLUSTER_PAGES;
+		}
+		run_task_queue(&tq_disk);
+
+		/* if we're far enough past the beginning of this area,
+		   recycle pages that are in the previous window. */
+		if (vma->vm_raend > (vma->vm_pgoff + ra_window + ra_window)) {
+			unsigned long window = ra_window << PAGE_SHIFT;
+
+			end = vma->vm_start + (vma->vm_raend << PAGE_SHIFT);
+			end -= window + window;
+			filemap_sync(vma, end - window, window, MS_INVALIDATE);
+		}
+
+		vma->vm_raend += ra_window;
+	}
+
+	return;
+}
+
+/*
  * filemap_nopage() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
  *
@@ -1339,6 +1395,12 @@
 		goto page_not_uptodate;
 
 success:
+ 	/*
+	 * Try read-ahead for sequential areas.
+	 */
+	if (VM_SequentialReadHint(area))
+		nopage_sequential_readahead(area, pgoff, size);
+
 	/*
 	 * Found the page and have a reference on it, need to check sharing
 	 * and possibly copy it over to another page..
@@ -1355,7 +1417,7 @@
 		page_cache_release(page);
 		return new_page;
 	}
-		
+
 	flush_page_to_ram(old_page);
 	return old_page;
 
@@ -1367,7 +1429,7 @@
 	 * Otherwise, we're off the end of a privately mapped file,
 	 * so we need to map a zero page.
 	 */
-	if (pgoff < size)
+	if ((pgoff < size) && !VM_RandomReadHint(area))
 		error = read_cluster_nonblocking(file, pgoff, size);
 	else
 		error = page_cache_read(file, pgoff);
@@ -1646,7 +1708,6 @@
 	return 0;
 }
 
-
 /*
  * The msync() system call.
  */
@@ -1723,6 +1784,351 @@
 	}
 out:
 	unlock_kernel();
+	up(&current->mm->mmap_sem);
+	return error;
+}
+
+static inline void setup_read_behavior(struct vm_area_struct * vma,
+	int behavior)
+{
+	VM_ClearReadHint(vma);
+	switch(behavior) {
+		case MADV_SEQUENTIAL:
+			vma->vm_flags |= VM_SEQ_READ;
+			break;
+		case MADV_RANDOM:
+			vma->vm_flags |= VM_RAND_READ;
+			break;
+		default:
+			break;
+	}
+	return;
+}
+
+static long madvise_fixup_start(struct vm_area_struct * vma,
+	unsigned long end, int behavior)
+{
+	struct vm_area_struct * n;
+
+	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!n)
+		return -EAGAIN;
+	*n = *vma;
+	n->vm_end = end;
+	setup_read_behavior(n, behavior);
+	n->vm_raend = 0;
+	get_file(n->vm_file);
+	if (n->vm_ops && n->vm_ops->open)
+		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
+	vma->vm_start = end;
+	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
+	return 0;
+}
+
+static long madvise_fixup_end(struct vm_area_struct * vma,
+	unsigned long start, int behavior)
+{
+	struct vm_area_struct * n;
+
+	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	if (!n)
+		return -EAGAIN;
+	*n = *vma;
+	n->vm_start = start;
+	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
+	setup_read_behavior(n, behavior);
+	n->vm_raend = 0;
+	get_file(n->vm_file);
+	if (n->vm_ops && n->vm_ops->open)
+		n->vm_ops->open(n);
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_end = start;
+	insert_vm_struct(current->mm, n);
+	vmlist_modify_unlock(vma->vm_mm);
+	return 0;
+}
+
+static long madvise_fixup_middle(struct vm_area_struct * vma,
+	unsigned long start, unsigned long end, int behavior)
+{
+	struct vm_area_struct * left, * right;
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
+	atomic_add(2, &vma->vm_file->f_count);
+
+	if (vma->vm_ops && vma->vm_ops->open) {
+		vma->vm_ops->open(left);
+		vma->vm_ops->open(right);
+	}
+	vmlist_modify_lock(vma->vm_mm);
+	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
+	vma->vm_start = start;
+	vma->vm_end = end;
+	setup_read_behavior(vma, behavior);
+	vma->vm_raend = 0;
+	insert_vm_struct(current->mm, left);
+	insert_vm_struct(current->mm, right);
+	vmlist_modify_unlock(vma->vm_mm);
+	return 0;
+}
+
+/*
+ * We can potentially split a vm area into separate
+ * areas, each area with its own behavior.
+ */
+static long madvise_behavior(struct vm_area_struct * vma,
+	unsigned long start, unsigned long end, int behavior)
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
+	unsigned long start, unsigned long end)
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
+	/* round to cluster boundaries if this isn't a "random" area. */
+	if (!VM_RandomReadHint(vma)) {
+		start = CLUSTER_OFFSET(start);
+		end = CLUSTER_OFFSET(end + CLUSTER_PAGES - 1);
+
+		while ((start < end) && (start < size)) {
+			error = read_cluster_nonblocking(file, start, size);
+			start += CLUSTER_PAGES;
+			if (error < 0)
+				break;
+		}
+	} else {
+		while ((start < end) && (start < size)) {
+			error = page_cache_read(file, start);
+			start++;
+			if (error < 0)
+				break;
+		}
+	}
+
+	/* Don't wait for someone else to push these requests. */
+	run_task_queue(&tq_disk);
+
+	return error;
+}
+
+/*
+ * Application no longer needs these pages.  If the pages are dirty,
+ * it's OK to just throw them away.  The app will be more careful about
+ * data it wants to keep.  Be sure to free swap resources too.  The
+ * zap_page_range call sets things up for shrink_mmap to actually free
+ * these pages later if no one else has touched them in the meantime,
+ * although we could add these pages to a global reuse list for
+ * shrink_mmap to pick up before reclaiming other pages.
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
+	unsigned long start, unsigned long end)
+{
+	if (vma->vm_flags & VM_LOCKED)
+		return -EINVAL;
+
+	lock_kernel();	/* is this really necessary? */
+
+	flush_cache_range(vma->vm_mm, start, end);
+	zap_page_range(vma->vm_mm, start, end - start);
+	flush_tlb_range(vma->vm_mm, start, end);
+
+	unlock_kernel();
+	return 0;
+}
+
+static long madvise_vma(struct vm_area_struct * vma, unsigned long start,
+	unsigned long end, int behavior)
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
+	down(&current->mm->mmap_sem);
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
 	up(&current->mm->mmap_sem);
 	return error;
 }
diff -ruN Linux-2.3.52-3/mm/mlock.c linux/mm/mlock.c
--- Linux-2.3.52-3/mm/mlock.c	Mon Feb  7 22:45:28 2000
+++ linux/mm/mlock.c	Tue Mar 14 16:21:08 2000
@@ -31,6 +31,7 @@
 	*n = *vma;
 	n->vm_end = end;
 	n->vm_flags = newflags;
+	n->vm_raend = 0;
 	if (n->vm_file)
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
@@ -55,6 +56,7 @@
 	n->vm_start = start;
 	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
+	n->vm_raend = 0;
 	if (n->vm_file)
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
@@ -85,6 +87,8 @@
 	right->vm_start = end;
 	right->vm_pgoff += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
 	vma->vm_flags = newflags;
+	left->vm_raend = 0;
+	right->vm_raend = 0;
 	if (vma->vm_file)
 		atomic_add(2, &vma->vm_file->f_count);
 
@@ -97,6 +101,7 @@
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_flags = newflags;
+	vma->vm_raend = 0;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
 	vmlist_modify_unlock(vma->vm_mm);
diff -ruN Linux-2.3.52-3/mm/mmap.c linux/mm/mmap.c
--- Linux-2.3.52-3/mm/mmap.c	Sun Mar 12 18:42:48 2000
+++ linux/mm/mmap.c	Tue Mar 14 16:39:17 2000
@@ -249,6 +249,9 @@
 	vma->vm_flags = vm_flags(prot,flags) | mm->def_flags;
 
 	if (file) {
+		VM_ClearReadHint(vma);
+		vma->vm_raend = 0;
+
 		if (file->f_mode & 1)
 			vma->vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 		if (flags & MAP_SHARED) {
@@ -549,6 +552,7 @@
 		mpnt->vm_end = area->vm_end;
 		mpnt->vm_page_prot = area->vm_page_prot;
 		mpnt->vm_flags = area->vm_flags;
+		mpnt->vm_raend = 0;
 		mpnt->vm_ops = area->vm_ops;
 		mpnt->vm_pgoff = area->vm_pgoff + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
diff -ruN Linux-2.3.52-3/mm/mprotect.c linux/mm/mprotect.c
--- Linux-2.3.52-3/mm/mprotect.c	Mon Feb  7 22:45:28 2000
+++ linux/mm/mprotect.c	Tue Mar 14 16:25:33 2000
@@ -105,6 +105,7 @@
 	*n = *vma;
 	n->vm_end = end;
 	n->vm_flags = newflags;
+	n->vm_raend = 0;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
 		get_file(n->vm_file);
@@ -131,6 +132,7 @@
 	n->vm_start = start;
 	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
+	n->vm_raend = 0;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
 		get_file(n->vm_file);
@@ -162,6 +164,8 @@
 	left->vm_end = start;
 	right->vm_start = end;
 	right->vm_pgoff += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
+	left->vm_raend = 0;
+	right->vm_raend = 0;
 	if (vma->vm_file)
 		atomic_add(2,&vma->vm_file->f_count);
 	if (vma->vm_ops && vma->vm_ops->open) {
@@ -173,6 +177,7 @@
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_flags = newflags;
+	vma->vm_raend = 0;
 	vma->vm_page_prot = prot;
 	insert_vm_struct(current->mm, left);
 	insert_vm_struct(current->mm, right);
diff -ruN Linux-2.3.52-3/mm/mremap.c linux/mm/mremap.c
--- Linux-2.3.52-3/mm/mremap.c	Sun Mar 12 18:42:16 2000
+++ linux/mm/mremap.c	Tue Mar 14 16:26:13 2000
@@ -135,8 +135,8 @@
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
-			new_vma->vm_pgoff = vma->vm_pgoff;
 			new_vma->vm_pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
+			new_vma->vm_raend = 0;
 			if (new_vma->vm_file)
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
