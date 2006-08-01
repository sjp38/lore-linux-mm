Message-ID: <44CF3CB7.7030009@yahoo.com.au>
Date: Tue, 01 Aug 2006 21:36:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
Content-Type: multipart/mixed;
 boundary="------------070509070801040106010106"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070509070801040106010106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Just like to get some thoughts on another possible approach to this
problem, and whether my changelog and implementation actually capture
the problem. This fix is actually something Andrea had proposed, so
credit really goes to him.

I suppose we should think about fixing it some day?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--------------070509070801040106010106
Content-Type: text/plain;
 name="mm-dnp-invp-race.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-dnp-invp-race.patch"

Fix the race between invalidate_inode_pages and do_no_page.

Andrea Arcangeli identified a subtle race between invalidation of
pages from pagecache with userspace mappings, and do_no_page.

The issue is that invalidation has to shoot down all mappings to the
page, before it can be discarded from the pagecache. Between shooting
down ptes to a particular page, and actually dropping the struct page
from the pagecache, do_no_page from any process might fault on that
page and establish a new mapping to the page just before it gets
discarded from the pagecache.

The most common case where such invalidation is used is in file
truncation. This case was catered for by doing a sort of open-coded
seqlock between the file's i_size, and its truncate_count.

Truncation will decrease i_size, then increment truncate_count before
unmapping userspace pages; do_no_page will read truncate_count, then
find the page if it is within i_size, and then check truncate_count
under the page table lock and back out and retry if it had
subsequently been changed (ptl will serialise against unmapping, and
ensure a potentially updated truncate_count is actually visible).

Complexity and documentation issues aside, the locking protocol fails
in the case where we would like to invalidate pagecache inside i_size.
do_no_page can come in anytime and filemap_nopage is not aware of the
invalidation in progress (as it is when it is outside i_size). The
end result is that dangling (->mapping == NULL) pages that appear to
be from a particular file may be mapped into userspace with nonsense
data. Valid mappings to the same place will see a different page.

Andrea implemented two working fixes, one using a real seqlock,
another using a page->flags bit. He also proposed using the page lock
in do_no_page, but that was initially considered too heavyweight.
However, it is not a global or per-file lock, and the page cacheline
is modified in do_no_page to increment _count and _mapcount anyway, so
a further modification should not be a large performance hit.
Scalability is not an issue.

This patch implements this latter approach. ->nopage implementations
return with the page locked if it is possible for their underlying
file to be invalidated (in that case, they must set a special vm_flags
bit to indicate so). do_no_page only unlocks the page after setting
up the mapping completely. invalidation is excluded because it holds
the page lock during invalidation of each page.

This allows significant simplifications in do_no_page.

kbuild performance is, surprisingly, maybe slightly improved:
2xP4 Xeon 3.6GHz with HT:
kbuild -j8 in shmfs
original:
505.16user 28.59system 2:15.87elapsed 392%CPU
505.08user 28.28system 2:15.81elapsed 392%CPU
504.16user 29.28system 2:15.85elapsed 392%CPU

patched:
502.35user 26.86system 2:14.77elapsed 392%CPU
501.89user 27.15system 2:14.86elapsed 392%CPU
502.22user 27.01system 2:14.87elapsed 392%CPU

kbuild -j8 in ext3
original:
505.65user 27.72system 2:15.75elapsed 392%CPU
506.38user 26.73system 2:16.38elapsed 390%CPU
507.00user 26.21system 2:15.76elapsed 392%CPU

patched:
501.03user 28.67system 2:14.98elapsed 392%CPU
500.84user 29.34system 2:14.99elapsed 392%CPU
501.18user 28.76system 2:15.05elapsed 392%CPU

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-07-26 18:00:47.000000000 +1000
+++ linux-2.6/include/linux/mm.h	2006-07-31 15:37:45.000000000 +1000
@@ -166,6 +166,11 @@ extern unsigned int kobjsize(const void 
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
+#define VM_CAN_INVLD	0x04000000	/* The mapping may be invalidated,
+					 * eg. truncate or invalidate_inode_*.
+					 * In this case, do_no_page must
+					 * return with the page locked.
+					 */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -205,6 +210,7 @@ struct vm_operations_struct {
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 #endif
+	unsigned long vm_flags; /* vm_flags to copy into any mapping vmas */
 };
 
 struct mmu_gather;
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-07-31 15:37:42.000000000 +1000
+++ linux-2.6/mm/filemap.c	2006-07-31 16:06:04.000000000 +1000
@@ -1279,6 +1279,8 @@ struct page *filemap_nopage(struct vm_ar
 	unsigned long size, pgoff;
 	int did_readaround = 0, majmin = VM_FAULT_MINOR;
 
+	BUG_ON(!(area->vm_flags & VM_CAN_INVLD));
+
 	pgoff = ((address-area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
 
 retry_all:
@@ -1303,7 +1305,7 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_lock_page(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1337,7 +1339,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_lock_page(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1399,30 +1401,6 @@ page_not_uptodate:
 		majmin = VM_FAULT_MAJOR;
 		inc_page_state(pgmajfault);
 	}
-	lock_page(page);
-
-	/* Did it get unhashed while we waited for it? */
-	if (!page->mapping) {
-		unlock_page(page);
-		page_cache_release(page);
-		goto retry_all;
-	}
-
-	/* Did somebody else get it up-to-date? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
-
-	error = mapping->a_ops->readpage(file, page);
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
-		goto retry_find;
-	}
 
 	/*
 	 * Umm, take care of errors if the page isn't up-to-date.
@@ -1430,20 +1408,6 @@ page_not_uptodate:
 	 * because there really aren't any performance issues here
 	 * and we need to check for errors.
 	 */
-	lock_page(page);
-
-	/* Somebody truncated the page on us? */
-	if (!page->mapping) {
-		unlock_page(page);
-		page_cache_release(page);
-		goto retry_all;
-	}
-
-	/* Somebody else successfully read it in? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
 	ClearPageError(page);
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
@@ -1462,7 +1426,6 @@ page_not_uptodate:
 	page_cache_release(page);
 	return NULL;
 }
-
 EXPORT_SYMBOL(filemap_nopage);
 
 static struct page * filemap_getpage(struct file *file, unsigned long pgoff,
@@ -1641,6 +1604,7 @@ EXPORT_SYMBOL(filemap_populate);
 struct vm_operations_struct generic_file_vm_ops = {
 	.nopage		= filemap_nopage,
 	.populate	= filemap_populate,
+	.vm_flags	= VM_CAN_INVLD,
 };
 
 /* This is used for a general mmap of a disk file */
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-07-26 18:00:47.000000000 +1000
+++ linux-2.6/mm/memory.c	2006-07-31 16:06:40.000000000 +1000
@@ -1577,6 +1577,13 @@ static int unmap_mapping_range_vma(struc
 	unsigned long restart_addr;
 	int need_break;
 
+	/*
+	 * files that support invalidating or truncating portions of the
+	 * file from under mmaped areas must set the VM_CAN_INVLD flag, and
+	 * have their .nopage function return the page locked.
+	 */
+	BUG_ON(!(vma->vm_flags & VM_CAN_INVLD));
+
 again:
 	restart_addr = vma->vm_truncate_count;
 	if (is_restart_addr(restart_addr) && start_addr < restart_addr) {
@@ -1707,17 +1714,8 @@ void unmap_mapping_range(struct address_
 
 	spin_lock(&mapping->i_mmap_lock);
 
-	/* serialize i_size write against truncate_count write */
-	smp_wmb();
-	/* Protect against page faults, and endless unmapping loops */
+	/* Protect against endless unmapping loops */
 	mapping->truncate_count++;
-	/*
-	 * For archs where spin_lock has inclusive semantics like ia64
-	 * this smp_mb() will prevent to read pagetable contents
-	 * before the truncate_count increment is visible to
-	 * other cpus.
-	 */
-	smp_mb();
 	if (unlikely(is_restart_addr(mapping->truncate_count))) {
 		if (mapping->truncate_count == 0)
 			reset_vma_truncate_counts(mapping);
@@ -1729,6 +1727,7 @@ void unmap_mapping_range(struct address_
 		unmap_mapping_range_tree(&mapping->i_mmap, &details);
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
 		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
+
 	spin_unlock(&mapping->i_mmap_lock);
 }
 EXPORT_SYMBOL(unmap_mapping_range);
@@ -2040,36 +2039,23 @@ static int do_no_page(struct mm_struct *
 		int write_access)
 {
 	spinlock_t *ptl;
-	struct page *new_page;
-	struct address_space *mapping = NULL;
+	struct page *new_page, *old_page;
 	pte_t entry;
-	unsigned int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
 
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
-	if (vma->vm_file) {
-		mapping = vma->vm_file->f_mapping;
-		sequence = mapping->truncate_count;
-		smp_rmb(); /* serializes i_size against truncate_count */
-	}
-retry:
 	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
-	/*
-	 * No smp_rmb is needed here as long as there's a full
-	 * spin_lock/unlock sequence inside the ->nopage callback
-	 * (for the pagecache lookup) that acts as an implicit
-	 * smp_mb() and prevents the i_size read to happen
-	 * after the next truncate_count read.
-	 */
-
 	/* no page was available -- either SIGBUS or OOM */
 	if (new_page == NOPAGE_SIGBUS)
 		return VM_FAULT_SIGBUS;
 	if (new_page == NOPAGE_OOM)
 		return VM_FAULT_OOM;
+	old_page = new_page;
+
+	BUG_ON(vma->vm_flags & VM_CAN_INVLD && !PageLocked(new_page));
 
 	/*
 	 * Should we do an early C-O-W break?
@@ -2089,19 +2075,6 @@ retry:
 	}
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	/*
-	 * For a file-backed vma, someone could have truncated or otherwise
-	 * invalidated this page.  If unmap_mapping_range got called,
-	 * retry getting the page.
-	 */
-	if (mapping && unlikely(sequence != mapping->truncate_count)) {
-		pte_unmap_unlock(page_table, ptl);
-		page_cache_release(new_page);
-		cond_resched();
-		sequence = mapping->truncate_count;
-		smp_rmb();
-		goto retry;
-	}
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -2139,10 +2112,15 @@ retry:
 	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+out:
+	if (likely(vma->vm_flags & VM_CAN_INVLD))
+		unlock_page(old_page);
 	return ret;
+
 oom:
 	page_cache_release(new_page);
-	return VM_FAULT_OOM;
+	ret = VM_FAULT_OOM;
+	goto out;
 }
 
 /*
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2006-07-26 18:00:47.000000000 +1000
+++ linux-2.6/mm/shmem.c	2006-07-31 16:54:48.000000000 +1000
@@ -80,6 +80,7 @@ enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
+	SGP_NOPAGE,	/* same as SGP_CACHE, return with page locked */
 };
 
 static int shmem_getpage(struct inode *inode, unsigned long idx,
@@ -1211,8 +1212,10 @@ repeat:
 	}
 done:
 	if (*pagep != filepage) {
-		unlock_page(filepage);
 		*pagep = filepage;
+		if (sgp != SGP_NOPAGE)
+			unlock_page(filepage);
+
 	}
 	return 0;
 
@@ -1231,13 +1234,15 @@ struct page *shmem_nopage(struct vm_area
 	unsigned long idx;
 	int error;
 
+	BUG_ON(!(vma->vm_flags & VM_CAN_INVLD));
+
 	idx = (address - vma->vm_start) >> PAGE_SHIFT;
 	idx += vma->vm_pgoff;
 	idx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
 	if (((loff_t) idx << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		return NOPAGE_SIGBUS;
 
-	error = shmem_getpage(inode, idx, &page, SGP_CACHE, type);
+	error = shmem_getpage(inode, idx, &page, SGP_NOPAGE, type);
 	if (error)
 		return (error == -ENOMEM)? NOPAGE_OOM: NOPAGE_SIGBUS;
 
@@ -2230,6 +2235,7 @@ static struct vm_operations_struct shmem
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+	.vm_flags	= VM_CAN_INVLD,
 };
 
 
Index: linux-2.6/fs/ncpfs/mmap.c
===================================================================
--- linux-2.6.orig/fs/ncpfs/mmap.c	2004-10-19 17:20:33.000000000 +1000
+++ linux-2.6/fs/ncpfs/mmap.c	2006-07-31 15:39:23.000000000 +1000
@@ -100,6 +100,7 @@ static struct page* ncp_file_mmap_nopage
 static struct vm_operations_struct ncp_file_mmap =
 {
 	.nopage	= ncp_file_mmap_nopage,
+	.vm_flags = VM_CAN_INVLD,
 };
 
 
Index: linux-2.6/fs/ocfs2/mmap.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/mmap.c	2006-02-09 18:04:58.000000000 +1100
+++ linux-2.6/fs/ocfs2/mmap.c	2006-07-31 15:39:56.000000000 +1000
@@ -78,6 +78,7 @@ out:
 
 static struct vm_operations_struct ocfs2_file_vm_ops = {
 	.nopage = ocfs2_nopage,
+	.vm_flags = VM_CAN_INVLD,
 };
 
 int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
Index: linux-2.6/fs/xfs/linux-2.6/xfs_file.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_file.c	2006-04-20 18:55:03.000000000 +1000
+++ linux-2.6/fs/xfs/linux-2.6/xfs_file.c	2006-07-31 15:39:47.000000000 +1000
@@ -634,6 +634,7 @@ const struct file_operations xfs_dir_fil
 static struct vm_operations_struct xfs_file_vm_ops = {
 	.nopage		= filemap_nopage,
 	.populate	= filemap_populate,
+	.vm_flags	= VM_CAN_INVLD,
 };
 
 #ifdef CONFIG_XFS_DMAPI
@@ -643,5 +644,6 @@ static struct vm_operations_struct xfs_d
 #ifdef HAVE_VMOP_MPROTECT
 	.mprotect	= xfs_vm_mprotect,
 #endif
+	.vm_flags	= VM_CAN_INVLD,
 };
 #endif /* CONFIG_XFS_DMAPI */
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2006-07-26 18:00:47.000000000 +1000
+++ linux-2.6/mm/mmap.c	2006-07-31 16:03:58.000000000 +1000
@@ -1089,6 +1089,9 @@ munmap_back:
 			goto free_vma;
 	}
 
+	if (vma->vm_ops)
+		vma->vm_flags |= vma->vm_ops->vm_flags;
+
 	/* We set VM_ACCOUNT in a shared mapping's vm_flags, to inform
 	 * shmem_zero_setup (perhaps called through /dev/zero's ->mmap)
 	 * that memory reservation must be checked; but that reservation

--------------070509070801040106010106--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
