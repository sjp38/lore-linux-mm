Date: Mon, 2 Sep 2002 21:04:43 +0200
From: Christoph Hellwig <hch@lst.de>
Message-ID: <20020902210443.A32010@lst.de>
References: <20020902194345.A30976@lst.de> <3D73B2F9.FB1E7968@zip.com.au> <20020902204138.A31717@lst.de> <3D73B7F1.2EB3131E@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D73B7F1.2EB3131E@zip.com.au>; from akpm@zip.com.au on Mon, Sep 02, 2002 at 12:11:45PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2002 at 12:11:45PM -0700, Andrew Morton wrote:
> Christoph Hellwig wrote:
> > 
> > On Mon, Sep 02, 2002 at 11:50:33AM -0700, Andrew Morton wrote:
> > > Christoph Hellwig wrote:
> > > >
> > > > This patch was done after Linus requested it when I intended to split
> > > > madvice out of filemap.c.  We extend splitvma() in mmap.c to take
> > > > another argument that specifies whether to split above or below the
> > > > address given, and thus can use it in those function, cleaning them up
> > > > a lot and removing most of their code.
> > > >
> > >
> > > This description seems to have leaked from a different patch.
> > >
> > > Your patch purely shuffles code about, yes?
> > 
> > No.  it makes madvise/mlock/mprotect use slit_vma (that involved from
> > splitvma).  There is no change in behaviour (verified by ltp testruns),
> > but the implementation is very different, and lots of code is gone.
> 
> did you send the right patch?
> 
> mnm:/usr/src/25> grep split patches/madvise-move.patch 
> - * We can potentially split a vm area into separate
> + * We can potentially split a vm area into separate
> 
> mnm:/usr/src/25> diffstat patches/madvise-move.patch
>  Makefile  |    2 
>  filemap.c |  332 ------------------------------------------------------------
>  madvise.c |  340 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 342 insertions(+), 332 deletions(-)

Sorry, that was the first patch I sent to Linus before I did the changes
I explained..

Here's the right one:

 include/linux/mm.h |    7 -
 mm/Makefile        |    2
 mm/filemap.c       |  332 -----------------------------------------------------
 mm/madvise.c       |  238 +++++++++++++++++++++++++++++++++++++
 mm/mlock.c         |  158 ++++---------------------
 mm/mmap.c          |   37 +++--
 mm/mprotect.c      |  218 +++++++++++-----------------------
 7 files changed, 365 insertions, 627 deletions

--- 1.70/include/linux/mm.h	Thu Aug 15 21:55:18 2002
+++ edited/include/linux/mm.h	Sun Aug 18 16:14:27 2002
@@ -483,6 +483,7 @@
 extern struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr);
 extern struct vm_area_struct * find_vma_prev(struct mm_struct * mm, unsigned long addr,
 					     struct vm_area_struct **pprev);
+extern struct vm_area_struct * find_extend_vma(struct mm_struct * mm, unsigned long addr);
 
 /* Look up the first VMA which intersects the interval start_addr..end_addr-1,
    NULL if none.  Assume start_addr < end_addr. */
@@ -495,11 +496,11 @@
 	return vma;
 }
 
-extern struct vm_area_struct *find_extend_vma(struct mm_struct *mm, unsigned long addr);
+extern int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+		     unsigned long addr, int new_below);
 
 extern struct page * vmalloc_to_page(void *addr);
 extern unsigned long get_page_cache_size(void);
 
 #endif /* __KERNEL__ */
-
-#endif
+#endif /* _LINUX_MM_H */
--- 1.12/mm/Makefile	Tue Jul 16 23:46:26 2002
+++ edited/mm/Makefile	Sun Aug 18 11:25:20 2002
@@ -16,6 +16,6 @@
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
 	    page_alloc.o swap_state.o swapfile.o numa.o oom_kill.o \
 	    shmem.o highmem.o mempool.o msync.o mincore.o readahead.o \
-	    pdflush.o page-writeback.o rmap.o
+	    pdflush.o page-writeback.o rmap.o madvise.o
 
 include $(TOPDIR)/Rules.make
--- 1.127/mm/filemap.c	Thu Aug 15 14:24:40 2002
+++ edited/mm/filemap.c	Sun Aug 18 11:25:20 2002
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
--- 1.3/mm/mlock.c	Tue Feb  5 08:45:30 2002
+++ edited/mm/mlock.c	Sun Aug 18 16:02:43 2002
@@ -2,147 +2,49 @@
  *	linux/mm/mlock.c
  *
  *  (C) Copyright 1995 Linus Torvalds
+ *  (C) Copyright 2002 Christoph Hellwig
  */
-#include <linux/slab.h>
-#include <linux/shm.h>
-#include <linux/mman.h>
-#include <linux/smp_lock.h>
-#include <linux/pagemap.h>
-
-#include <asm/uaccess.h>
-#include <asm/pgtable.h>
-
-static inline int mlock_fixup_all(struct vm_area_struct * vma, int newflags)
-{
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_flags = newflags;
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	return 0;
-}
-
-static inline int mlock_fixup_start(struct vm_area_struct * vma,
-	unsigned long end, int newflags)
-{
-	struct vm_area_struct * n;
-
-	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!n)
-		return -EAGAIN;
-	*n = *vma;
-	n->vm_end = end;
-	n->vm_flags = newflags;
-	n->vm_raend = 0;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_start = end;
-	__insert_vm_struct(current->mm, n);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
-
-static inline int mlock_fixup_end(struct vm_area_struct * vma,
-	unsigned long start, int newflags)
-{
-	struct vm_area_struct * n;
-
-	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!n)
-		return -EAGAIN;
-	*n = *vma;
-	n->vm_start = start;
-	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
-	n->vm_flags = newflags;
-	n->vm_raend = 0;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_end = start;
-	__insert_vm_struct(current->mm, n);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
 
-static inline int mlock_fixup_middle(struct vm_area_struct * vma,
-	unsigned long start, unsigned long end, int newflags)
-{
-	struct vm_area_struct * left, * right;
+#include <linux/mman.h>
+#include <linux/mm.h>
 
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
-	vma->vm_flags = newflags;
-	left->vm_raend = 0;
-	right->vm_raend = 0;
-	if (vma->vm_file)
-		atomic_add(2, &vma->vm_file->f_count);
-
-	if (vma->vm_ops && vma->vm_ops->open) {
-		vma->vm_ops->open(left);
-		vma->vm_ops->open(right);
-	}
-	vma->vm_raend = 0;
-	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_start = start;
-	vma->vm_end = end;
-	vma->vm_flags = newflags;
-	__insert_vm_struct(current->mm, left);
-	__insert_vm_struct(current->mm, right);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-	return 0;
-}
 
 static int mlock_fixup(struct vm_area_struct * vma, 
 	unsigned long start, unsigned long end, unsigned int newflags)
 {
-	int pages, retval;
+	struct mm_struct * mm = vma->vm_mm;
+	int pages, error;
 
 	if (newflags == vma->vm_flags)
 		return 0;
 
-	if (start == vma->vm_start) {
-		if (end == vma->vm_end)
-			retval = mlock_fixup_all(vma, newflags);
-		else
-			retval = mlock_fixup_start(vma, end, newflags);
-	} else {
-		if (end == vma->vm_end)
-			retval = mlock_fixup_end(vma, start, newflags);
-		else
-			retval = mlock_fixup_middle(vma, start, end, newflags);
+	if (start != vma->vm_start) {
+		error = split_vma(mm, vma, start, 1);
+		if (error)
+			return -EAGAIN;
 	}
-	if (!retval) {
-		/* keep track of amount of locked VM */
-		pages = (end - start) >> PAGE_SHIFT;
-		if (newflags & VM_LOCKED) {
-			pages = -pages;
-			make_pages_present(start, end);
-		}
-		vma->vm_mm->locked_vm -= pages;
+
+	if (end != vma->vm_end) {
+		error = split_vma(mm, vma, end, 0);
+		if (error)
+			return -EAGAIN;
+	}
+	
+	spin_lock(&mm->page_table_lock);
+	vma->vm_flags = newflags;
+	spin_unlock(&mm->page_table_lock);
+
+	/*
+	 * Keep track of amount of locked VM.
+	 */
+	pages = (end - start) >> PAGE_SHIFT;
+	if (newflags & VM_LOCKED) {
+		pages = -pages;
+		make_pages_present(start, end);
 	}
-	return retval;
+
+	vma->vm_mm->locked_vm -= pages;
+	return 0;
 }
 
 static int do_mlock(unsigned long start, size_t len, int on)
--- 1.45/mm/mmap.c	Fri Aug  2 16:24:26 2002
+++ edited/mm/mmap.c	Sun Aug 18 16:13:02 2002
@@ -1043,10 +1043,11 @@
 }
 
 /*
- * Split a vma into two pieces at address 'addr', the original vma
- * will contain the first part, a new vma is allocated for the tail.
+ * Split a vma into two pieces at address 'addr', a new vma is allocated
+ * either for the first part or the the tail.
  */
-static int splitvma(struct mm_struct *mm, struct vm_area_struct *mpnt, unsigned long addr)
+int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
+	      unsigned long addr, int new_below)
 {
 	struct vm_area_struct *new;
 
@@ -1058,22 +1059,28 @@
 		return -ENOMEM;
 
 	/* most fields are the same, copy all, and then fixup */
-	*new = *mpnt;
+	*new = *vma;
+
+	if (new_below) {
+		vma->vm_start = new->vm_end = addr;
+		vma->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
+	} else {
+		new->vm_start = vma->vm_end = addr;
+		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
+	}
 
-	new->vm_start = addr;
-	new->vm_pgoff = mpnt->vm_pgoff + ((addr - mpnt->vm_start) >> PAGE_SHIFT);
 	new->vm_raend = 0;
-	if (mpnt->vm_file)
-		get_file(mpnt->vm_file);
 
-	if (mpnt->vm_ops && mpnt->vm_ops->open)
-		mpnt->vm_ops->open(mpnt);
-	mpnt->vm_end = addr;	/* Truncate area */
+	if (new->vm_file)
+		get_file(new->vm_file);
+
+	if (new->vm_ops && new->vm_ops->open)
+		new->vm_ops->open(new);
 
 	spin_lock(&mm->page_table_lock);
-	lock_vma_mappings(mpnt);
+	lock_vma_mappings(vma);
 	__insert_vm_struct(mm, new);
-	unlock_vma_mappings(mpnt);
+	unlock_vma_mappings(vma);
 	spin_unlock(&mm->page_table_lock);
 
 	return 0;
@@ -1110,7 +1117,7 @@
 	 * If we need to split any vma, do it now to save pain later.
 	 */
 	if (start > mpnt->vm_start) {
-		if (splitvma(mm, mpnt, start))
+		if (split_vma(mm, mpnt, start, 0))
 			return -ENOMEM;
 		prev = mpnt;
 		mpnt = mpnt->vm_next;
@@ -1119,7 +1126,7 @@
 	/* Does it split the last one? */
 	last = find_vma(mm, end);
 	if (last && end > last->vm_start) {
-		if (splitvma(mm, last, end))
+		if (split_vma(mm, last, end, 0))
 			return -ENOMEM;
 	}
 
--- 1.14/mm/mprotect.c	Mon Jul 29 21:23:46 2002
+++ edited/mm/mprotect.c	Sun Aug 18 16:20:40 2002
@@ -2,13 +2,14 @@
  *  mm/mprotect.c
  *
  *  (C) Copyright 1994 Linus Torvalds
+ *  (C) Copyright 2002 Christoph Hellwig
  *
  *  Address space accounting code	<alan@redhat.com>
  *  (C) Copyright 2002 Red Hat Inc, All Rights Reserved
  */
+
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/smp_lock.h>
 #include <linux/shm.h>
 #include <linux/mman.h>
 #include <linux/fs.h>
@@ -100,158 +101,59 @@
 	spin_unlock(&current->mm->page_table_lock);
 	return;
 }
-
-static inline int mprotect_fixup_all(struct vm_area_struct * vma, struct vm_area_struct ** pprev,
-	int newflags, pgprot_t prot)
+/*
+ * Try to merge a vma with the previos flag, return 1 if successfull or 0 if it
+ * was impossible.
+ */
+static int mprotect_attemp_merge(struct vm_area_struct * vma,
+		struct vm_area_struct * prev,
+		unsigned long end, int newflags)
 {
-	struct vm_area_struct * prev = *pprev;
 	struct mm_struct * mm = vma->vm_mm;
 
-	if (prev && prev->vm_end == vma->vm_start && can_vma_merge(prev, newflags) &&
-	    !vma->vm_file && !(vma->vm_flags & VM_SHARED)) {
+	if (!prev || !vma)
+		return 0;
+	if (prev->vm_end != vma->vm_start)
+		return 0;
+	if (!can_vma_merge(prev, newflags))
+		return 0;
+	if (vma->vm_file || (vma->vm_flags & VM_SHARED))
+		return 0;
+
+	/*
+	 * If the whole area changes to the protection of the previous one
+	 * we can just get rid of it.
+	 */
+	if (end == vma->vm_end) {
 		spin_lock(&mm->page_table_lock);
-		prev->vm_end = vma->vm_end;
+		prev->vm_end = end;
 		__vma_unlink(mm, vma, prev);
 		spin_unlock(&mm->page_table_lock);
 
 		kmem_cache_free(vm_area_cachep, vma);
 		mm->map_count--;
+		return 1;
+	} 
 
-		return 0;
-	}
-
+	/*
+	 * Otherwise extend it.
+	 */
 	spin_lock(&mm->page_table_lock);
-	vma->vm_flags = newflags;
-	vma->vm_page_prot = prot;
-	spin_unlock(&mm->page_table_lock);
-
-	*pprev = vma;
-
-	return 0;
-}
-
-static inline int mprotect_fixup_start(struct vm_area_struct * vma, struct vm_area_struct ** pprev,
-	unsigned long end,
-	int newflags, pgprot_t prot)
-{
-	struct vm_area_struct * n, * prev = *pprev;
-
-	*pprev = vma;
-
-	if (prev && prev->vm_end == vma->vm_start && can_vma_merge(prev, newflags) &&
-	    !vma->vm_file && !(vma->vm_flags & VM_SHARED)) {
-		spin_lock(&vma->vm_mm->page_table_lock);
-		prev->vm_end = end;
-		vma->vm_start = end;
-		spin_unlock(&vma->vm_mm->page_table_lock);
-
-		return 0;
-	}
-	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!n)
-		return -ENOMEM;
-	*n = *vma;
-	n->vm_end = end;
-	n->vm_flags = newflags;
-	n->vm_raend = 0;
-	n->vm_page_prot = prot;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
+	prev->vm_end = end;
 	vma->vm_start = end;
-	__insert_vm_struct(current->mm, n);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-
-	return 0;
-}
-
-static inline int mprotect_fixup_end(struct vm_area_struct * vma, struct vm_area_struct ** pprev,
-	unsigned long start,
-	int newflags, pgprot_t prot)
-{
-	struct vm_area_struct * n;
-
-	n = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
-	if (!n)
-		return -ENOMEM;
-	*n = *vma;
-	n->vm_start = start;
-	n->vm_pgoff += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
-	n->vm_flags = newflags;
-	n->vm_raend = 0;
-	n->vm_page_prot = prot;
-	if (n->vm_file)
-		get_file(n->vm_file);
-	if (n->vm_ops && n->vm_ops->open)
-		n->vm_ops->open(n);
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_end = start;
-	__insert_vm_struct(current->mm, n);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-
-	*pprev = n;
-
-	return 0;
+	spin_unlock(&mm->page_table_lock);
+	return 1;
 }
 
-static inline int mprotect_fixup_middle(struct vm_area_struct * vma, struct vm_area_struct ** pprev,
-	unsigned long start, unsigned long end,
-	int newflags, pgprot_t prot)
-{
-	struct vm_area_struct * left, * right;
-
-	left = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!left)
-		return -ENOMEM;
-	right = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	if (!right) {
-		kmem_cache_free(vm_area_cachep, left);
-		return -ENOMEM;
-	}
-	*left = *vma;
-	*right = *vma;
-	left->vm_end = start;
-	right->vm_start = end;
-	right->vm_pgoff += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
-	left->vm_raend = 0;
-	right->vm_raend = 0;
-	if (vma->vm_file)
-		atomic_add(2,&vma->vm_file->f_count);
-	if (vma->vm_ops && vma->vm_ops->open) {
-		vma->vm_ops->open(left);
-		vma->vm_ops->open(right);
-	}
-	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
-	vma->vm_raend = 0;
-	vma->vm_page_prot = prot;
-	lock_vma_mappings(vma);
-	spin_lock(&vma->vm_mm->page_table_lock);
-	vma->vm_start = start;
-	vma->vm_end = end;
-	vma->vm_flags = newflags;
-	__insert_vm_struct(current->mm, left);
-	__insert_vm_struct(current->mm, right);
-	spin_unlock(&vma->vm_mm->page_table_lock);
-	unlock_vma_mappings(vma);
-
-	*pprev = right;
 
-	return 0;
-}
 
 static int mprotect_fixup(struct vm_area_struct * vma, struct vm_area_struct ** pprev,
 	unsigned long start, unsigned long end, unsigned int newflags)
 {
+	struct mm_struct * mm = vma->vm_mm;
+	unsigned long charged = 0;
 	pgprot_t newprot;
 	int error;
-	unsigned long charged = 0;
 
 	if (newflags == vma->vm_flags) {
 		*pprev = vma;
@@ -266,29 +168,46 @@
 	 * FIXME? We haven't defined a VM_NORESERVE flag, so mprotecting
 	 * a MAP_NORESERVE private mapping to writable will now reserve.
 	 */
-	if ((newflags & VM_WRITE) &&
-	    !(vma->vm_flags & (VM_ACCOUNT|VM_WRITE|VM_SHARED))) {
-		charged = (end - start) >> PAGE_SHIFT;
-		if (!vm_enough_memory(charged))
-			return -ENOMEM;
-		newflags |= VM_ACCOUNT;
+	if (newflags & VM_WRITE) {
+		if (!(vma->vm_flags & (VM_ACCOUNT|VM_WRITE|VM_SHARED))) {
+			charged = (end - start) >> PAGE_SHIFT;
+			if (!vm_enough_memory(charged))
+				return -ENOMEM;
+			newflags |= VM_ACCOUNT;
+		}
 	}
+
 	newprot = protection_map[newflags & 0xf];
+
 	if (start == vma->vm_start) {
-		if (end == vma->vm_end)
-			error = mprotect_fixup_all(vma, pprev, newflags, newprot);
-		else
-			error = mprotect_fixup_start(vma, pprev, end, newflags, newprot);
-	} else if (end == vma->vm_end)
-		error = mprotect_fixup_end(vma, pprev, start, newflags, newprot);
-	else
-		error = mprotect_fixup_middle(vma, pprev, start, end, newflags, newprot);
-	if (error) {
-		vm_unacct_memory(charged);
-		return error;
+		/*
+		 * Try to merge with the previous vma.
+		 */
+		if (mprotect_attemp_merge(vma, *pprev, end, newflags))
+			return 0;
+	} else {
+		error = split_vma(mm, vma, start, 1);
+		if (error)
+			goto fail;
+	}
+
+	if (end != vma->vm_end) {
+		error = split_vma(mm, vma, end, 0);
+		if (error)
+			goto fail;
 	}
+
+	spin_lock(&mm->page_table_lock);
+	vma->vm_flags = newflags;
+	vma->vm_page_prot = newprot;
+	spin_unlock(&mm->page_table_lock);
+
 	change_protection(vma, start, end, newprot);
 	return 0;
+
+fail:
+	vm_unacct_memory(charged);
+	return error;
 }
 
 asmlinkage long sys_mprotect(unsigned long start, size_t len, unsigned long prot)
@@ -352,6 +271,7 @@
 			goto out;
 		}
 	}
+
 	if (next && prev->vm_end == next->vm_start && can_vma_merge(next, prev->vm_flags) &&
 	    !prev->vm_file && !(prev->vm_flags & VM_SHARED)) {
 		spin_lock(&prev->vm_mm->page_table_lock);
--- 1.0/mm/madvise.c	Thu Dec 13 11:34:58 2001
+++ edited/mm/madvise.c Sun Aug 18 14:28:08 2002
@@ -0,0 +1,238 @@
+/*
+ *	linux/mm/madvise.c
+ *
+ * Copyright (C) 1999  Linus Torvalds
+ * Copyright (C) 2002  Christoph Hellwig
+ */
+
+#include <linux/mman.h>
+#include <linux/pagemap.h>
+
+
+/*
+ * We can potentially split a vm area into separate
+ * areas, each area with its own behavior.
+ */
+static long madvise_behavior(struct vm_area_struct * vma, unsigned long start,
+			     unsigned long end, int behavior)
+{
+	struct mm_struct * mm = vma->vm_mm;
+	int error;
+
+	if (start != vma->vm_start) {
+		error = split_vma(mm, vma, start, 1);
+		if (error)
+			return -EAGAIN;
+	}
+
+	if (end != vma->vm_end) {
+		error = split_vma(mm, vma, end, 0);
+		if (error)
+			return -EAGAIN;
+	}
+
+	spin_lock(&mm->page_table_lock);
+	vma->vm_raend = 0;
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
+	spin_unlock(&mm->page_table_lock);
+
+	return 0;
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
