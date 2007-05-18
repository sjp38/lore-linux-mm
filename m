Message-Id: <200705180737.l4I7b4m4010748@shell0.pdx.osdl.net>
Subject: [patch 1/8] mm: fix fault vs invalidate race for linear mappings
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:05 -0700
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Fix the race between invalidate_inode_pages and do_no_page.

Andrea Arcangeli identified a subtle race between invalidation of pages from
pagecache with userspace mappings, and do_no_page.

The issue is that invalidation has to shoot down all mappings to the page,
before it can be discarded from the pagecache.  Between shooting down ptes to
a particular page, and actually dropping the struct page from the pagecache,
do_no_page from any process might fault on that page and establish a new
mapping to the page just before it gets discarded from the pagecache.

The most common case where such invalidation is used is in file truncation. 
This case was catered for by doing a sort of open-coded seqlock between the
file's i_size, and its truncate_count.

Truncation will decrease i_size, then increment truncate_count before
unmapping userspace pages; do_no_page will read truncate_count, then find the
page if it is within i_size, and then check truncate_count under the page
table lock and back out and retry if it had subsequently been changed (ptl
will serialise against unmapping, and ensure a potentially updated
truncate_count is actually visible).

Complexity and documentation issues aside, the locking protocol fails in the
case where we would like to invalidate pagecache inside i_size.  do_no_page
can come in anytime and filemap_nopage is not aware of the invalidation in
progress (as it is when it is outside i_size).  The end result is that
dangling (->mapping == NULL) pages that appear to be from a particular file
may be mapped into userspace with nonsense data.  Valid mappings to the same
place will see a different page.

Andrea implemented two working fixes, one using a real seqlock, another using
a page->flags bit.  He also proposed using the page lock in do_no_page, but
that was initially considered too heavyweight.  However, it is not a global or
per-file lock, and the page cacheline is modified in do_no_page to increment
_count and _mapcount anyway, so a further modification should not be a large
performance hit.  Scalability is not an issue.

This patch implements this latter approach.  ->nopage implementations return
with the page locked if it is possible for their underlying file to be
invalidated (in that case, they must set a special vm_flags bit to indicate
so).  do_no_page only unlocks the page after setting up the mapping
completely.  invalidation is excluded because it holds the page lock during
invalidation of each page (and ensures that the page is not mapped while
holding the lock).

This also allows significant simplifications in do_no_page, because we have
the page locked in the right place in the pagecache from the start.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/gfs2/ops_file.c          |    2 
 fs/ncpfs/mmap.c             |    1 
 fs/ocfs2/mmap.c             |    1 
 fs/xfs/linux-2.6/xfs_file.c |    1 
 include/linux/mm.h          |    6 +
 mm/filemap.c                |   53 ++++--------
 mm/memory.c                 |  150 ++++++++++++++++------------------
 mm/shmem.c                  |   11 ++
 mm/truncate.c               |   13 ++
 9 files changed, 124 insertions(+), 114 deletions(-)

diff -puN fs/gfs2/ops_file.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings fs/gfs2/ops_file.c
--- a/fs/gfs2/ops_file.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/fs/gfs2/ops_file.c
@@ -364,6 +364,8 @@ static int gfs2_mmap(struct file *file, 
 	else
 		vma->vm_ops = &gfs2_vm_ops_private;
 
+	vma->vm_flags |= VM_CAN_INVALIDATE;
+
 	gfs2_glock_dq_uninit(&i_gh);
 
 	return error;
diff -puN fs/ncpfs/mmap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings fs/ncpfs/mmap.c
--- a/fs/ncpfs/mmap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/fs/ncpfs/mmap.c
@@ -123,6 +123,7 @@ int ncp_mmap(struct file *file, struct v
 		return -EFBIG;
 
 	vma->vm_ops = &ncp_file_mmap;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 	file_accessed(file);
 	return 0;
 }
diff -puN fs/ocfs2/mmap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings fs/ocfs2/mmap.c
--- a/fs/ocfs2/mmap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/fs/ocfs2/mmap.c
@@ -107,6 +107,7 @@ int ocfs2_mmap(struct file *file, struct
 	ocfs2_meta_unlock(file->f_dentry->d_inode, lock_level);
 out:
 	vma->vm_ops = &ocfs2_file_vm_ops;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 	return 0;
 }
 
diff -puN fs/xfs/linux-2.6/xfs_file.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings fs/xfs/linux-2.6/xfs_file.c
--- a/fs/xfs/linux-2.6/xfs_file.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/fs/xfs/linux-2.6/xfs_file.c
@@ -343,6 +343,7 @@ xfs_file_mmap(
 	struct vm_area_struct *vma)
 {
 	vma->vm_ops = &xfs_file_vm_ops;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 
 #ifdef CONFIG_XFS_DMAPI
 	if (vn_from_inode(filp->f_path.dentry->d_inode)->v_vfsp->vfs_flag & VFS_DMI)
diff -puN include/linux/mm.h~mm-fix-fault-vs-invalidate-race-for-linear-mappings include/linux/mm.h
--- a/include/linux/mm.h~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/include/linux/mm.h
@@ -170,6 +170,12 @@ extern unsigned int kobjsize(const void 
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
+#define VM_CAN_INVALIDATE 0x08000000	/* The mapping may be invalidated,
+					 * eg. truncate or invalidate_inode_*.
+					 * In this case, do_no_page must
+					 * return with the page locked.
+					 */
+
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
 #endif
diff -puN mm/filemap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings mm/filemap.c
--- a/mm/filemap.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/mm/filemap.c
@@ -1358,9 +1358,10 @@ struct page *filemap_nopage(struct vm_ar
 	unsigned long size, pgoff;
 	int did_readaround = 0, majmin = VM_FAULT_MINOR;
 
+	BUG_ON(!(area->vm_flags & VM_CAN_INVALIDATE));
+
 	pgoff = ((address-area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
 
-retry_all:
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (pgoff >= size)
 		goto outside_data_content;
@@ -1382,7 +1383,7 @@ retry_all:
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_get_page(mapping, pgoff);
+	page = find_lock_page(mapping, pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
@@ -1416,7 +1417,7 @@ retry_find:
 				start = pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_get_page(mapping, pgoff);
+		page = find_lock_page(mapping, pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1425,13 +1426,19 @@ retry_find:
 		ra->mmap_hit++;
 
 	/*
-	 * Ok, found a page in the page cache, now we need to check
-	 * that it's up-to-date.
+	 * We have a locked page in the page cache, now we need to check
+	 * that it's up-to-date. If not, it is going to be due to an error.
 	 */
-	if (!PageUptodate(page))
+	if (unlikely(!PageUptodate(page)))
 		goto page_not_uptodate;
 
-success:
+	/* Must recheck i_size under page lock */
+	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	if (unlikely(pgoff >= size)) {
+		unlock_page(page);
+		goto outside_data_content;
+	}
+
 	/*
 	 * Found the page and have a reference on it.
 	 */
@@ -1473,6 +1480,7 @@ no_cached_page:
 	return NOPAGE_SIGBUS;
 
 page_not_uptodate:
+	/* IO error path */
 	if (!did_readaround) {
 		majmin = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
@@ -1484,37 +1492,15 @@ page_not_uptodate:
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
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
+	page_cache_release(page);
+
+	if (!error || error == AOP_TRUNCATED_PAGE)
 		goto retry_find;
-	}
 
-	/*
-	 * Things didn't work out. Return zero to tell the
-	 * mm layer so, possibly freeing the page cache page first.
-	 */
+	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
-	page_cache_release(page);
 	return NOPAGE_SIGBUS;
 }
 EXPORT_SYMBOL(filemap_nopage);
@@ -1707,6 +1693,7 @@ int generic_file_mmap(struct file * file
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &generic_file_vm_ops;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 	return 0;
 }
 
diff -puN mm/memory.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings mm/memory.c
--- a/mm/memory.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/mm/memory.c
@@ -1824,6 +1824,13 @@ static int unmap_mapping_range_vma(struc
 	unsigned long restart_addr;
 	int need_break;
 
+	/*
+	 * files that support invalidating or truncating portions of the
+	 * file from under mmaped areas must set the VM_CAN_INVALIDATE flag, and
+	 * have their .nopage function return the page locked.
+	 */
+	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
+
 again:
 	restart_addr = vma->vm_truncate_count;
 	if (is_restart_addr(restart_addr) && start_addr < restart_addr) {
@@ -1952,17 +1959,8 @@ void unmap_mapping_range(struct address_
 
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
@@ -2001,8 +1999,18 @@ int vmtruncate(struct inode * inode, lof
 	if (IS_SWAPFILE(inode))
 		goto out_busy;
 	i_size_write(inode, offset);
+
+	/*
+	 * unmap_mapping_range is called twice, first simply for efficiency
+	 * so that truncate_inode_pages does fewer single-page unmaps. However
+	 * after this first call, and before truncate_inode_pages finishes,
+	 * it is possible for private pages to be COWed, which remain after
+	 * truncate_inode_pages finishes, hence the second unmap_mapping_range
+	 * call must be made for correctness.
+	 */
 	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
 	truncate_inode_pages(mapping, offset);
+	unmap_mapping_range(mapping, offset + PAGE_SIZE - 1, 0, 1);
 	goto out_truncate;
 
 do_expand:
@@ -2042,6 +2050,7 @@ int vmtruncate_range(struct inode *inode
 	down_write(&inode->i_alloc_sem);
 	unmap_mapping_range(mapping, offset, (end - offset), 1);
 	truncate_inode_pages_range(mapping, offset, end);
+	unmap_mapping_range(mapping, offset, (end - offset), 1);
 	inode->i_op->truncate_range(inode, offset, end);
 	up_write(&inode->i_alloc_sem);
 	mutex_unlock(&inode->i_mutex);
@@ -2199,7 +2208,6 @@ static int do_swap_page(struct mm_struct
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
-	lazy_mmu_prot_update(pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -2290,10 +2298,8 @@ static int do_no_page(struct mm_struct *
 		int write_access)
 {
 	spinlock_t *ptl;
-	struct page *new_page;
-	struct address_space *mapping = NULL;
+	struct page *page, *nopage_page;
 	pte_t entry;
-	unsigned int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
 	struct page *dirty_page = NULL;
@@ -2301,73 +2307,53 @@ static int do_no_page(struct mm_struct *
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
-	if (vma->vm_file) {
-		mapping = vma->vm_file->f_mapping;
-		sequence = mapping->truncate_count;
-		smp_rmb(); /* serializes i_size against truncate_count */
-	}
-retry:
-	new_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
-	/*
-	 * No smp_rmb is needed here as long as there's a full
-	 * spin_lock/unlock sequence inside the ->nopage callback
-	 * (for the pagecache lookup) that acts as an implicit
-	 * smp_mb() and prevents the i_size read to happen
-	 * after the next truncate_count read.
-	 */
-
+	nopage_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
 	/* no page was available -- either SIGBUS, OOM or REFAULT */
-	if (unlikely(new_page == NOPAGE_SIGBUS))
+	if (unlikely(nopage_page == NOPAGE_SIGBUS))
 		return VM_FAULT_SIGBUS;
-	else if (unlikely(new_page == NOPAGE_OOM))
+	else if (unlikely(nopage_page == NOPAGE_OOM))
 		return VM_FAULT_OOM;
-	else if (unlikely(new_page == NOPAGE_REFAULT))
+	else if (unlikely(nopage_page == NOPAGE_REFAULT))
 		return VM_FAULT_MINOR;
 
+	BUG_ON(vma->vm_flags & VM_CAN_INVALIDATE && !PageLocked(nopage_page));
+	/*
+	 * For consistency in subsequent calls, make the nopage_page always
+	 * locked.
+	 */
+	if (unlikely(!(vma->vm_flags & VM_CAN_INVALIDATE)))
+		lock_page(nopage_page);
+
 	/*
 	 * Should we do an early C-O-W break?
 	 */
+	page = nopage_page;
 	if (write_access) {
 		if (!(vma->vm_flags & VM_SHARED)) {
-			struct page *page;
-
-			if (unlikely(anon_vma_prepare(vma)))
-				goto oom;
+			if (unlikely(anon_vma_prepare(vma))) {
+				ret = VM_FAULT_OOM;
+				goto out_error;
+			}
 			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
-			if (!page)
-				goto oom;
-			copy_user_highpage(page, new_page, address, vma);
-			page_cache_release(new_page);
-			new_page = page;
+			if (!page) {
+				ret = VM_FAULT_OOM;
+				goto out_error;
+			}
+			copy_user_highpage(page, nopage_page, address, vma);
 			anon = 1;
-
 		} else {
 			/* if the page will be shareable, see if the backing
 			 * address space wants to know that the page is about
 			 * to become writable */
 			if (vma->vm_ops->page_mkwrite &&
-			    vma->vm_ops->page_mkwrite(vma, new_page) < 0
-			    ) {
-				page_cache_release(new_page);
-				return VM_FAULT_SIGBUS;
+			    vma->vm_ops->page_mkwrite(vma, page) < 0) {
+				ret = VM_FAULT_SIGBUS;
+				goto out_error;
 			}
 		}
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
@@ -2380,43 +2366,51 @@ retry:
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
-		flush_icache_page(vma, new_page);
-		entry = mk_pte(new_page, vma->vm_page_prot);
+	if (likely(pte_none(*page_table))) {
+		flush_icache_page(vma, page);
+		entry = mk_pte(page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
-			page_add_new_anon_rmap(new_page, vma, address);
+                        inc_mm_counter(mm, anon_rss);
+                        lru_cache_add_active(page);
+                        page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
-			page_add_file_rmap(new_page);
+			page_add_file_rmap(page);
 			if (write_access) {
-				dirty_page = new_page;
+				dirty_page = page;
 				get_page(dirty_page);
 			}
 		}
+
+		/* no need to invalidate: a not-present page won't be cached */
+		update_mmu_cache(vma, address, entry);
+		lazy_mmu_prot_update(entry);
 	} else {
-		/* One of our sibling threads was faster, back out. */
-		page_cache_release(new_page);
-		goto unlock;
+		if (anon)
+			page_cache_release(page);
+		else
+			anon = 1; /* not anon, but release nopage_page */
 	}
 
-	/* no need to invalidate: a not-present page shouldn't be cached */
-	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
-unlock:
 	pte_unmap_unlock(page_table, ptl);
-	if (dirty_page) {
+
+out:
+	unlock_page(nopage_page);
+	if (anon)
+		page_cache_release(nopage_page);
+	else if (dirty_page) {
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
+
 	return ret;
-oom:
-	page_cache_release(new_page);
-	return VM_FAULT_OOM;
+
+out_error:
+	anon = 1; /* relase nopage_page */
+	goto out;
 }
 
 /*
diff -puN mm/shmem.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings mm/shmem.c
--- a/mm/shmem.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/mm/shmem.c
@@ -82,6 +82,7 @@ enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
+	SGP_NOPAGE,	/* same as SGP_CACHE, return with page locked */
 };
 
 static int shmem_getpage(struct inode *inode, unsigned long idx,
@@ -1283,8 +1284,10 @@ repeat:
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
 
@@ -1304,13 +1307,15 @@ static struct page *shmem_nopage(struct 
 	unsigned long idx;
 	int error;
 
+	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
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
 
@@ -1408,6 +1413,7 @@ static int shmem_mmap(struct file *file,
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 	return 0;
 }
 
@@ -2598,5 +2604,6 @@ int shmem_zero_setup(struct vm_area_stru
 		fput(vma->vm_file);
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
+	vma->vm_flags |= VM_CAN_INVALIDATE;
 	return 0;
 }
diff -puN mm/truncate.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings mm/truncate.c
--- a/mm/truncate.c~mm-fix-fault-vs-invalidate-race-for-linear-mappings
+++ a/mm/truncate.c
@@ -192,6 +192,11 @@ void truncate_inode_pages_range(struct a
 				unlock_page(page);
 				continue;
 			}
+			if (page_mapped(page)) {
+				unmap_mapping_range(mapping,
+				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
+				  PAGE_CACHE_SIZE, 0);
+			}
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
 		}
@@ -229,6 +234,11 @@ void truncate_inode_pages_range(struct a
 				break;
 			lock_page(page);
 			wait_on_page_writeback(page);
+			if (page_mapped(page)) {
+				unmap_mapping_range(mapping,
+				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
+				  PAGE_CACHE_SIZE, 0);
+			}
 			if (page->index > next)
 				next = page->index;
 			next++;
@@ -397,7 +407,7 @@ int invalidate_inode_pages2_range(struct
 				break;
 			}
 			wait_on_page_writeback(page);
-			while (page_mapped(page)) {
+			if (page_mapped(page)) {
 				if (!did_range_unmap) {
 					/*
 					 * Zap the rest of the file in one hit.
@@ -417,6 +427,7 @@ int invalidate_inode_pages2_range(struct
 					  PAGE_CACHE_SIZE, 0);
 				}
 			}
+			BUG_ON(page_mapped(page));
 			ret = do_launder_page(mapping, page);
 			if (ret == 0 && !invalidate_complete_page2(mapping, page))
 				ret = -EIO;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
