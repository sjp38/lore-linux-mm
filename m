Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BD3CE82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:10 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id x3so237541583pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id gi2si16285368pac.105.2016.03.20.11.41.53
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 70/71] mm: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:41:17 +0300
Message-Id: <1458499278-1516-71-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/filesystems/tmpfs.txt |   2 +-
 include/linux/mm.h                  |   2 +-
 include/linux/mm_types.h            |   2 +-
 include/linux/pagemap.h             |  16 ++---
 include/linux/swap.h                |   4 +-
 mm/fadvise.c                        |   8 +--
 mm/filemap.c                        | 126 +++++++++++++++++-----------------
 mm/gup.c                            |   2 +-
 mm/madvise.c                        |   6 +-
 mm/memory-failure.c                 |   2 +-
 mm/memory.c                         |  55 ++++++++-------
 mm/mincore.c                        |   8 +--
 mm/nommu.c                          |   2 +-
 mm/page-writeback.c                 |  12 ++--
 mm/page_io.c                        |   2 +-
 mm/readahead.c                      |  20 +++---
 mm/rmap.c                           |   2 +-
 mm/shmem.c                          | 130 ++++++++++++++++++------------------
 mm/swap.c                           |  14 ++--
 mm/swap_state.c                     |  12 ++--
 mm/swapfile.c                       |  12 ++--
 mm/truncate.c                       |  40 +++++------
 mm/userfaultfd.c                    |   4 +-
 mm/zswap.c                          |   4 +-
 24 files changed, 242 insertions(+), 245 deletions(-)

diff --git a/Documentation/filesystems/tmpfs.txt b/Documentation/filesystems/tmpfs.txt
index d392e1505f17..d9c11d25bf02 100644
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -60,7 +60,7 @@ size:      The limit of allocated bytes for this tmpfs instance. The
            default is half of your physical RAM without swap. If you
            oversize your tmpfs instances the machine will deadlock
            since the OOM handler will not be able to free that memory.
-nr_blocks: The same as size, but in blocks of PAGE_CACHE_SIZE.
+nr_blocks: The same as size, but in blocks of PAGE_SIZE.
 nr_inodes: The maximum number of inodes for this instance. The default
            is half of the number of your physical RAM pages, or (on a
            machine with highmem) the number of lowmem RAM pages,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7d42501c8bb4..20effd32d5f3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -603,7 +603,7 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
  *
  * A page may belong to an inode's memory mapping. In this case, page->mapping
  * is the pointer to the inode, and page->index is the file offset of the page,
- * in units of PAGE_CACHE_SIZE.
+ * in units of PAGE_SIZE.
  *
  * If pagecache pages are not associated with an inode, they are said to be
  * anonymous pages. These may become associated with the swapcache, and in that
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 944b2b37313b..c2d75b4fa86c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -341,7 +341,7 @@ struct vm_area_struct {
 
 	/* Information about our backing store: */
 	unsigned long vm_pgoff;		/* Offset (within vm_file) in PAGE_SIZE
-					   units, *not* PAGE_CACHE_SIZE */
+					   units */
 	struct file * vm_file;		/* File we map to (can be NULL). */
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 1ebd65c91422..819f89ca6745 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -390,13 +390,13 @@ static inline pgoff_t page_to_pgoff(struct page *page)
 		return page->index << compound_order(page);
 
 	if (likely(!PageTransTail(page)))
-		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+		return page->index;
 
 	/*
 	 *  We don't initialize ->index for tail pages: calculate based on
 	 *  head page
 	 */
-	pgoff = compound_head(page)->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff = compound_head(page)->index;
 	pgoff += page - compound_head(page);
 	return pgoff;
 }
@@ -406,12 +406,12 @@ static inline pgoff_t page_to_pgoff(struct page *page)
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page->index) << PAGE_SHIFT;
 }
 
 static inline loff_t page_file_offset(struct page *page)
 {
-	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_file_index(page)) << PAGE_SHIFT;
 }
 
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
@@ -425,7 +425,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 		return linear_hugepage_index(vma, address);
 	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
 	pgoff += vma->vm_pgoff;
-	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	return pgoff >> (PAGE_SHIFT - PAGE_SHIFT);
 }
 
 extern void __lock_page(struct page *page);
@@ -535,8 +535,7 @@ extern void add_page_wait_queue(struct page *page, wait_queue_t *waiter);
 /*
  * Fault a userspace page into pagetables.  Return non-zero on a fault.
  *
- * This assumes that two userspace pages are always sufficient.  That's
- * not true if PAGE_CACHE_SIZE > PAGE_SIZE.
+ * This assumes that two userspace pages are always sufficient. 
  */
 static inline int fault_in_pages_writeable(char __user *uaddr, int size)
 {
@@ -671,8 +670,7 @@ static inline int add_to_page_cache(struct page *page,
 
 static inline unsigned long dir_pages(struct inode *inode)
 {
-	return (unsigned long)(inode->i_size + PAGE_CACHE_SIZE - 1) >>
-			       PAGE_CACHE_SHIFT;
+	return (unsigned long)(inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
 #endif /* _LINUX_PAGEMAP_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d18b65c53dbb..fc22c3fcb6ea 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -433,9 +433,9 @@ struct backing_dev_info;
 #define si_swapinfo(val) \
 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
 /* only sparc can not include linux/pagemap.h in this file
- * so leave page_cache_release and release_pages undeclared... */
+ * so leave release_pages undeclared... */
 #define free_page_and_swap_cache(page) \
-	page_cache_release(page)
+	put_page(page)
 #define free_pages_and_swap_cache(pages, nr) \
 	release_pages((pages), (nr), false);
 
diff --git a/mm/fadvise.c b/mm/fadvise.c
index b8a5bc66b0c0..b8024fa7101d 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -97,8 +97,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		break;
 	case POSIX_FADV_WILLNEED:
 		/* First and last PARTIAL page! */
-		start_index = offset >> PAGE_CACHE_SHIFT;
-		end_index = endbyte >> PAGE_CACHE_SHIFT;
+		start_index = offset >> PAGE_SHIFT;
+		end_index = endbyte >> PAGE_SHIFT;
 
 		/* Careful about overflow on the "+1" */
 		nrpages = end_index - start_index + 1;
@@ -124,8 +124,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		 * preserved on the expectation that it is better to preserve
 		 * needed memory than to discard unneeded memory.
 		 */
-		start_index = (offset+(PAGE_CACHE_SIZE-1)) >> PAGE_CACHE_SHIFT;
-		end_index = (endbyte >> PAGE_CACHE_SHIFT);
+		start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
+		end_index = (endbyte >> PAGE_SHIFT);
 
 		if (end_index >= start_index) {
 			unsigned long count = invalidate_mapping_pages(mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index 7c00f105845e..96f3b0322652 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -265,7 +265,7 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-	page_cache_release(page);
+	put_page(page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -352,8 +352,8 @@ EXPORT_SYMBOL(filemap_flush);
 static int __filemap_fdatawait_range(struct address_space *mapping,
 				     loff_t start_byte, loff_t end_byte)
 {
-	pgoff_t index = start_byte >> PAGE_CACHE_SHIFT;
-	pgoff_t end = end_byte >> PAGE_CACHE_SHIFT;
+	pgoff_t index = start_byte >> PAGE_SHIFT;
+	pgoff_t end = end_byte >> PAGE_SHIFT;
 	struct pagevec pvec;
 	int nr_pages;
 	int ret = 0;
@@ -550,7 +550,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		pgoff_t offset = old->index;
 		freepage = mapping->a_ops->freepage;
 
-		page_cache_get(new);
+		get_page(new);
 		new->mapping = mapping;
 		new->index = offset;
 
@@ -572,7 +572,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		radix_tree_preload_end();
 		if (freepage)
 			freepage(old);
-		page_cache_release(old);
+		put_page(old);
 	}
 
 	return error;
@@ -651,7 +651,7 @@ static int __add_to_page_cache_locked(struct page *page,
 		return error;
 	}
 
-	page_cache_get(page);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = offset;
 
@@ -675,7 +675,7 @@ err_insert:
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_cancel_charge(page, memcg, false);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -1083,7 +1083,7 @@ repeat:
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 	}
@@ -1121,7 +1121,7 @@ repeat:
 		/* Has the page been truncated? */
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		VM_BUG_ON_PAGE(page->index != offset, page);
@@ -1168,7 +1168,7 @@ repeat:
 	if (fgp_flags & FGP_LOCK) {
 		if (fgp_flags & FGP_NOWAIT) {
 			if (!trylock_page(page)) {
-				page_cache_release(page);
+				put_page(page);
 				return NULL;
 			}
 		} else {
@@ -1178,7 +1178,7 @@ repeat:
 		/* Has the page been truncated? */
 		if (unlikely(page->mapping != mapping)) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 		VM_BUG_ON_PAGE(page->index != offset, page);
@@ -1209,7 +1209,7 @@ no_page:
 		err = add_to_page_cache_lru(page, mapping, offset,
 				gfp_mask & GFP_RECLAIM_MASK);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			page = NULL;
 			if (err == -EEXIST)
 				goto repeat;
@@ -1278,7 +1278,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 export:
@@ -1343,7 +1343,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1405,7 +1405,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1415,7 +1415,7 @@ repeat:
 		 * negatives, which is just confusing to the caller.
 		 */
 		if (page->mapping == NULL || page->index != iter.index) {
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 
@@ -1482,7 +1482,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1549,7 +1549,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 export:
@@ -1610,11 +1610,11 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 	unsigned int prev_offset;
 	int error = 0;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	prev_index = ra->prev_pos >> PAGE_CACHE_SHIFT;
-	prev_offset = ra->prev_pos & (PAGE_CACHE_SIZE-1);
-	last_index = (*ppos + iter->count + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = *ppos >> PAGE_SHIFT;
+	prev_index = ra->prev_pos >> PAGE_SHIFT;
+	prev_offset = ra->prev_pos & (PAGE_SIZE-1);
+	last_index = (*ppos + iter->count + PAGE_SIZE-1) >> PAGE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
 
 	for (;;) {
 		struct page *page;
@@ -1648,7 +1648,7 @@ find_page:
 			if (PageUptodate(page))
 				goto page_ok;
 
-			if (inode->i_blkbits == PAGE_CACHE_SHIFT ||
+			if (inode->i_blkbits == PAGE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
 			if (!trylock_page(page))
@@ -1672,18 +1672,18 @@ page_ok:
 		 */
 
 		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index)) {
-			page_cache_release(page);
+			put_page(page);
 			goto out;
 		}
 
 		/* nr is the maximum number of bytes to copy from this page */
-		nr = PAGE_CACHE_SIZE;
+		nr = PAGE_SIZE;
 		if (index == end_index) {
-			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			nr = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (nr <= offset) {
-				page_cache_release(page);
+				put_page(page);
 				goto out;
 			}
 		}
@@ -1711,11 +1711,11 @@ page_ok:
 
 		ret = copy_page_to_iter(page, offset, nr, iter);
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += offset >> PAGE_SHIFT;
+		offset &= ~PAGE_MASK;
 		prev_offset = offset;
 
-		page_cache_release(page);
+		put_page(page);
 		written += ret;
 		if (!iov_iter_count(iter))
 			goto out;
@@ -1735,7 +1735,7 @@ page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
 		if (!page->mapping) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			continue;
 		}
 
@@ -1757,7 +1757,7 @@ readpage:
 
 		if (unlikely(error)) {
 			if (error == AOP_TRUNCATED_PAGE) {
-				page_cache_release(page);
+				put_page(page);
 				error = 0;
 				goto find_page;
 			}
@@ -1774,7 +1774,7 @@ readpage:
 					 * invalidate_mapping_pages got it
 					 */
 					unlock_page(page);
-					page_cache_release(page);
+					put_page(page);
 					goto find_page;
 				}
 				unlock_page(page);
@@ -1789,7 +1789,7 @@ readpage:
 
 readpage_error:
 		/* UHHUH! A synchronous read error occurred. Report it */
-		page_cache_release(page);
+		put_page(page);
 		goto out;
 
 no_cached_page:
@@ -1805,7 +1805,7 @@ no_cached_page:
 		error = add_to_page_cache_lru(page, mapping, index,
 				mapping_gfp_constraint(mapping, GFP_KERNEL));
 		if (error) {
-			page_cache_release(page);
+			put_page(page);
 			if (error == -EEXIST) {
 				error = 0;
 				goto find_page;
@@ -1817,10 +1817,10 @@ no_cached_page:
 
 out:
 	ra->prev_pos = prev_index;
-	ra->prev_pos <<= PAGE_CACHE_SHIFT;
+	ra->prev_pos <<= PAGE_SHIFT;
 	ra->prev_pos |= prev_offset;
 
-	*ppos = ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = ((loff_t)index << PAGE_SHIFT) + offset;
 	file_accessed(filp);
 	return written ? written : error;
 }
@@ -1911,7 +1911,7 @@ static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 		else if (ret == -EEXIST)
 			ret = 0; /* losing race to add is OK */
 
-		page_cache_release(page);
+		put_page(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
 
@@ -2021,8 +2021,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	loff_t size;
 	int ret = 0;
 
-	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
-	if (offset >= size >> PAGE_CACHE_SHIFT)
+	size = round_up(i_size_read(inode), PAGE_SIZE);
+	if (offset >= size >> PAGE_SHIFT)
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -2048,7 +2048,7 @@ retry_find:
 	}
 
 	if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
-		page_cache_release(page);
+		put_page(page);
 		return ret | VM_FAULT_RETRY;
 	}
 
@@ -2071,10 +2071,10 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
 	 */
-	size = round_up(i_size_read(inode), PAGE_CACHE_SIZE);
-	if (unlikely(offset >= size >> PAGE_CACHE_SHIFT)) {
+	size = round_up(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= size >> PAGE_SHIFT)) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		return VM_FAULT_SIGBUS;
 	}
 
@@ -2119,7 +2119,7 @@ page_not_uptodate:
 		if (!PageUptodate(page))
 			error = -EIO;
 	}
-	page_cache_release(page);
+	put_page(page);
 
 	if (!error || error == AOP_TRUNCATED_PAGE)
 		goto retry_find;
@@ -2163,7 +2163,7 @@ repeat:
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			page_cache_release(page);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -2177,8 +2177,8 @@ repeat:
 		if (page->mapping != mapping || !PageUptodate(page))
 			goto unlock;
 
-		size = round_up(i_size_read(mapping->host), PAGE_CACHE_SIZE);
-		if (page->index >= size >> PAGE_CACHE_SHIFT)
+		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
+		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
 		pte = vmf->pte + page->index - vmf->pgoff;
@@ -2194,7 +2194,7 @@ repeat:
 unlock:
 		unlock_page(page);
 skip:
-		page_cache_release(page);
+		put_page(page);
 next:
 		if (iter.index == vmf->max_pgoff)
 			break;
@@ -2277,7 +2277,7 @@ static struct page *wait_on_page_read(struct page *page)
 	if (!IS_ERR(page)) {
 		wait_on_page_locked(page);
 		if (!PageUptodate(page)) {
-			page_cache_release(page);
+			put_page(page);
 			page = ERR_PTR(-EIO);
 		}
 	}
@@ -2300,7 +2300,7 @@ repeat:
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
 		if (unlikely(err)) {
-			page_cache_release(page);
+			put_page(page);
 			if (err == -EEXIST)
 				goto repeat;
 			/* Presumably ENOMEM for radix tree node */
@@ -2310,7 +2310,7 @@ repeat:
 filler:
 		err = filler(data, page);
 		if (err < 0) {
-			page_cache_release(page);
+			put_page(page);
 			return ERR_PTR(err);
 		}
 
@@ -2363,7 +2363,7 @@ filler:
 	/* Case c or d, restart the operation */
 	if (!page->mapping) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		goto repeat;
 	}
 
@@ -2510,7 +2510,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	struct iov_iter data;
 
 	write_len = iov_iter_count(from);
-	end = (pos + write_len - 1) >> PAGE_CACHE_SHIFT;
+	end = (pos + write_len - 1) >> PAGE_SHIFT;
 
 	written = filemap_write_and_wait_range(mapping, pos, pos + write_len - 1);
 	if (written)
@@ -2524,7 +2524,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	 */
 	if (mapping->nrpages) {
 		written = invalidate_inode_pages2_range(mapping,
-					pos >> PAGE_CACHE_SHIFT, end);
+					pos >> PAGE_SHIFT, end);
 		/*
 		 * If a page can not be invalidated, return 0 to fall back
 		 * to buffered write.
@@ -2549,7 +2549,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from, loff_t pos)
 	 */
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT, end);
+					      pos >> PAGE_SHIFT, end);
 	}
 
 	if (written > 0) {
@@ -2610,8 +2610,8 @@ ssize_t generic_perform_write(struct file *file,
 		size_t copied;		/* Bytes copied from user */
 		void *fsdata;
 
-		offset = (pos & (PAGE_CACHE_SIZE - 1));
-		bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
+		offset = (pos & (PAGE_SIZE - 1));
+		bytes = min_t(unsigned long, PAGE_SIZE - offset,
 						iov_iter_count(i));
 
 again:
@@ -2664,7 +2664,7 @@ again:
 			 * because not all segments in the iov can be copied at
 			 * once without a pagefault.
 			 */
-			bytes = min_t(unsigned long, PAGE_CACHE_SIZE - offset,
+			bytes = min_t(unsigned long, PAGE_SIZE - offset,
 						iov_iter_single_seg_count(i));
 			goto again;
 		}
@@ -2751,8 +2751,8 @@ ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 			iocb->ki_pos = endbyte + 1;
 			written += status;
 			invalidate_mapping_pages(mapping,
-						 pos >> PAGE_CACHE_SHIFT,
-						 endbyte >> PAGE_CACHE_SHIFT);
+						 pos >> PAGE_SHIFT,
+						 endbyte >> PAGE_SHIFT);
 		} else {
 			/*
 			 * We don't know how much we wrote, so just return
diff --git a/mm/gup.c b/mm/gup.c
index 7bf19ffa2199..8c050724e498 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1058,7 +1058,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
  * @addr: user address
  *
  * Returns struct page pointer of user page pinned for dump,
- * to be freed afterwards by page_cache_release() or put_page().
+ * to be freed afterwards by put_page().
  *
  * Returns NULL on any kind of failure - a hole must then be inserted into
  * the corefile, to preserve alignment with its headers; and also returns
diff --git a/mm/madvise.c b/mm/madvise.c
index a01147359f3b..07427d3fcead 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -170,7 +170,7 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
 								vma, index);
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 	}
 
 	return 0;
@@ -204,14 +204,14 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 		page = find_get_entry(mapping, index);
 		if (!radix_tree_exceptional_entry(page)) {
 			if (page)
-				page_cache_release(page);
+				put_page(page);
 			continue;
 		}
 		swap = radix_to_swp_entry(page);
 		page = read_swap_cache_async(swap, GFP_HIGHUSER_MOVABLE,
 								NULL, 0);
 		if (page)
-			page_cache_release(page);
+			put_page(page);
 	}
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 5a544c6c0717..78f5f2641b91 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -538,7 +538,7 @@ static int delete_from_lru_cache(struct page *p)
 		/*
 		 * drop the page count elevated by isolate_lru_page()
 		 */
-		page_cache_release(p);
+		put_page(p);
 		return 0;
 	}
 	return -EIO;
diff --git a/mm/memory.c b/mm/memory.c
index ac6bc15c19be..847e24cab5bb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2050,7 +2050,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 		VM_BUG_ON_PAGE(PageAnon(page), page);
 		mapping = page->mapping;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		if ((dirtied || page_mkwrite) && mapping) {
 			/*
@@ -2184,7 +2184,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	if (new_page)
-		page_cache_release(new_page);
+		put_page(new_page);
 
 	pte_unmap_unlock(page_table, ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -2199,14 +2199,14 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 				munlock_vma_page(old_page);
 			unlock_page(old_page);
 		}
-		page_cache_release(old_page);
+		put_page(old_page);
 	}
 	return page_copied ? VM_FAULT_WRITE : 0;
 oom_free_new:
-	page_cache_release(new_page);
+	put_page(new_page);
 oom:
 	if (old_page)
-		page_cache_release(old_page);
+		put_page(old_page);
 	return VM_FAULT_OOM;
 }
 
@@ -2254,7 +2254,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	int page_mkwrite = 0;
 
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
 		int tmp;
@@ -2263,7 +2263,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 		tmp = do_page_mkwrite(vma, old_page, address);
 		if (unlikely(!tmp || (tmp &
 				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			page_cache_release(old_page);
+			put_page(old_page);
 			return tmp;
 		}
 		/*
@@ -2277,7 +2277,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (!pte_same(*page_table, orig_pte)) {
 			unlock_page(old_page);
 			pte_unmap_unlock(page_table, ptl);
-			page_cache_release(old_page);
+			put_page(old_page);
 			return 0;
 		}
 		page_mkwrite = 1;
@@ -2337,7 +2337,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
-			page_cache_get(old_page);
+			get_page(old_page);
 			pte_unmap_unlock(page_table, ptl);
 			lock_page(old_page);
 			page_table = pte_offset_map_lock(mm, pmd, address,
@@ -2345,10 +2345,10 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				pte_unmap_unlock(page_table, ptl);
-				page_cache_release(old_page);
+				put_page(old_page);
 				return 0;
 			}
-			page_cache_release(old_page);
+			put_page(old_page);
 		}
 		if (reuse_swap_page(old_page)) {
 			/*
@@ -2371,7 +2371,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
-	page_cache_get(old_page);
+	get_page(old_page);
 
 	pte_unmap_unlock(page_table, ptl);
 	return wp_page_copy(mm, vma, address, page_table, pmd,
@@ -2396,7 +2396,6 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
 
 		vba = vma->vm_pgoff;
 		vea = vba + vma_pages(vma) - 1;
-		/* Assume for now that PAGE_CACHE_SHIFT == PAGE_SHIFT */
 		zba = details->first_index;
 		if (zba < vba)
 			zba = vba;
@@ -2615,7 +2614,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * parallel locked swapcache.
 		 */
 		unlock_page(swapcache);
-		page_cache_release(swapcache);
+		put_page(swapcache);
 	}
 
 	if (flags & FAULT_FLAG_WRITE) {
@@ -2637,10 +2636,10 @@ out_nomap:
 out_page:
 	unlock_page(page);
 out_release:
-	page_cache_release(page);
+	put_page(page);
 	if (page != swapcache) {
 		unlock_page(swapcache);
-		page_cache_release(swapcache);
+		put_page(swapcache);
 	}
 	return ret;
 }
@@ -2748,7 +2747,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (userfaultfd_missing(vma)) {
 		pte_unmap_unlock(page_table, ptl);
 		mem_cgroup_cancel_charge(page, memcg, false);
-		page_cache_release(page);
+		put_page(page);
 		return handle_userfault(vma, address, flags,
 					VM_UFFD_MISSING);
 	}
@@ -2767,10 +2766,10 @@ unlock:
 	return 0;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
-	page_cache_release(page);
+	put_page(page);
 	goto unlock;
 oom_free_page:
-	page_cache_release(page);
+	put_page(page);
 oom:
 	return VM_FAULT_OOM;
 }
@@ -2803,7 +2802,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(PageHWPoison(vmf.page))) {
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
-		page_cache_release(vmf.page);
+		put_page(vmf.page);
 		return VM_FAULT_HWPOISON;
 	}
 
@@ -2992,7 +2991,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
@@ -3020,7 +3019,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 
 	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg, false)) {
-		page_cache_release(new_page);
+		put_page(new_page);
 		return VM_FAULT_OOM;
 	}
 
@@ -3037,7 +3036,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 		if (fault_page) {
 			unlock_page(fault_page);
-			page_cache_release(fault_page);
+			put_page(fault_page);
 		} else {
 			/*
 			 * The fault handler has no page to lock, so it holds
@@ -3053,7 +3052,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_unmap_unlock(pte, ptl);
 	if (fault_page) {
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 	} else {
 		/*
 		 * The fault handler has no page to lock, so it holds
@@ -3064,7 +3063,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 uncharge_out:
 	mem_cgroup_cancel_charge(new_page, memcg, false);
-	page_cache_release(new_page);
+	put_page(new_page);
 	return ret;
 }
 
@@ -3092,7 +3091,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		tmp = do_page_mkwrite(vma, fault_page, address);
 		if (unlikely(!tmp ||
 				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
-			page_cache_release(fault_page);
+			put_page(fault_page);
 			return tmp;
 		}
 	}
@@ -3101,7 +3100,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, true, false);
@@ -3727,7 +3726,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 						    buf, maddr + offset, bytes);
 			}
 			kunmap(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 		len -= bytes;
 		buf += bytes;
diff --git a/mm/mincore.c b/mm/mincore.c
index 563f32045490..012a4659e273 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -75,7 +75,7 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 #endif
 	if (page) {
 		present = PageUptodate(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return present;
@@ -211,7 +211,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
  * return values:
  *  zero    - success
  *  -EFAULT - vec points to an illegal address
- *  -EINVAL - addr is not a multiple of PAGE_CACHE_SIZE
+ *  -EINVAL - addr is not a multiple of PAGE_SIZE
  *  -ENOMEM - Addresses in the range [addr, addr + len] are
  *		invalid for the address space of this process, or
  *		specify one or more pages which are not currently
@@ -226,14 +226,14 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned char *tmp;
 
 	/* Check the start address: needs to be page-aligned.. */
- 	if (start & ~PAGE_CACHE_MASK)
+ 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 
 	/* ..and we need to be passed a valid user-space range */
 	if (!access_ok(VERIFY_READ, (void __user *) start, len))
 		return -ENOMEM;
 
-	/* This also avoids any overflows on PAGE_CACHE_ALIGN */
+	/* This also avoids any overflows on PAGE_ALIGN */
 	pages = len >> PAGE_SHIFT;
 	pages += (offset_in_page(len)) != 0;
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 6402f2715d48..9e5d855472a3 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -139,7 +139,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (pages) {
 			pages[i] = virt_to_page(start);
 			if (pages[i])
-				page_cache_get(pages[i]);
+				get_page(pages[i]);
 		}
 		if (vmas)
 			vmas[i] = vma;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f758631..999792d35ccc 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2176,8 +2176,8 @@ int write_cache_pages(struct address_space *mapping,
 			cycled = 0;
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = 1;
 		cycled = 1; /* ignore range_cyclic tests */
@@ -2382,14 +2382,14 @@ int write_one_page(struct page *page, int wait)
 		wait_on_page_writeback(page);
 
 	if (clear_page_dirty_for_io(page)) {
-		page_cache_get(page);
+		get_page(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
 			wait_on_page_writeback(page);
 			if (PageError(page))
 				ret = -EIO;
 		}
-		page_cache_release(page);
+		put_page(page);
 	} else {
 		unlock_page(page);
 	}
@@ -2431,7 +2431,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
-		task_io_account_write(PAGE_CACHE_SIZE);
+		task_io_account_write(PAGE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
 	}
@@ -2450,7 +2450,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
-		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
+		task_io_account_cancelled_write(PAGE_SIZE);
 	}
 }
 
diff --git a/mm/page_io.c b/mm/page_io.c
index ff74e512f029..729cc6ee21a6 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -246,7 +246,7 @@ out:
 
 static sector_t swap_page_sector(struct page *page)
 {
-	return (sector_t)__page_file_index(page) << (PAGE_CACHE_SHIFT - 9);
+	return (sector_t)__page_file_index(page) << (PAGE_SHIFT - 9);
 }
 
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
diff --git a/mm/readahead.c b/mm/readahead.c
index 20e58e820e44..40be3ae0afe3 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -47,11 +47,11 @@ static void read_cache_pages_invalidate_page(struct address_space *mapping,
 		if (!trylock_page(page))
 			BUG();
 		page->mapping = mapping;
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 		page->mapping = NULL;
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -93,14 +93,14 @@ int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			read_cache_pages_invalidate_page(mapping, page);
 			continue;
 		}
-		page_cache_release(page);
+		put_page(page);
 
 		ret = filler(data, page);
 		if (unlikely(ret)) {
 			read_cache_pages_invalidate_pages(mapping, pages);
 			break;
 		}
-		task_io_account_read(PAGE_CACHE_SIZE);
+		task_io_account_read(PAGE_SIZE);
 	}
 	return ret;
 }
@@ -130,7 +130,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
 			mapping->a_ops->readpage(filp, page);
 		}
-		page_cache_release(page);
+		put_page(page);
 	}
 	ret = 0;
 
@@ -163,7 +163,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (isize == 0)
 		goto out;
 
-	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	end_index = ((isize - 1) >> PAGE_SHIFT);
 
 	/*
 	 * Preallocate as many pages as we will need.
@@ -216,7 +216,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	while (nr_to_read) {
 		int err;
 
-		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_SIZE;
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
@@ -425,7 +425,7 @@ ondemand_readahead(struct address_space *mapping,
 	 * trivial case: (offset - prev_offset) == 1
 	 * unaligned reads: (offset - prev_offset) == 0
 	 */
-	prev_offset = (unsigned long long)ra->prev_pos >> PAGE_CACHE_SHIFT;
+	prev_offset = (unsigned long long)ra->prev_pos >> PAGE_SHIFT;
 	if (offset - prev_offset <= 1UL)
 		goto initial_readahead;
 
@@ -558,8 +558,8 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
 	if (f.file) {
 		if (f.file->f_mode & FMODE_READ) {
 			struct address_space *mapping = f.file->f_mapping;
-			pgoff_t start = offset >> PAGE_CACHE_SHIFT;
-			pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
+			pgoff_t start = offset >> PAGE_SHIFT;
+			pgoff_t end = (offset + count - 1) >> PAGE_SHIFT;
 			unsigned long len = end - start + 1;
 			ret = do_readahead(mapping, f.file, start, len);
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index c399a0d41b31..525b92f866a7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1555,7 +1555,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 discard:
 	page_remove_rmap(page, PageHuge(page));
-	page_cache_release(page);
+	put_page(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
diff --git a/mm/shmem.c b/mm/shmem.c
index 9428c51ab2d6..719bd6b88d98 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -75,8 +75,8 @@ static struct vfsmount *shm_mnt;
 
 #include "internal.h"
 
-#define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
-#define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
+#define BLOCKS_PER_PAGE  (PAGE_SIZE/512)
+#define VM_ACCT(size)    (PAGE_ALIGN(size) >> PAGE_SHIFT)
 
 /* Pretend that each entry is of this size in directory's i_size */
 #define BOGO_DIRENT_SIZE 20
@@ -176,13 +176,13 @@ static inline int shmem_reacct_size(unsigned long flags,
 static inline int shmem_acct_block(unsigned long flags)
 {
 	return (flags & VM_NORESERVE) ?
-		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
+		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_SIZE)) : 0;
 }
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 {
 	if (flags & VM_NORESERVE)
-		vm_unacct_memory(pages * VM_ACCT(PAGE_CACHE_SIZE));
+		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
 }
 
 static const struct super_operations shmem_ops;
@@ -300,7 +300,7 @@ static int shmem_add_to_page_cache(struct page *page,
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	page_cache_get(page);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = index;
 
@@ -318,7 +318,7 @@ static int shmem_add_to_page_cache(struct page *page,
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return error;
 }
@@ -338,7 +338,7 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__dec_zone_page_state(page, NR_SHMEM);
 	spin_unlock_irq(&mapping->tree_lock);
-	page_cache_release(page);
+	put_page(page);
 	BUG_ON(error);
 }
 
@@ -474,10 +474,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
-	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
-	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
+	pgoff_t start = (lstart + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	pgoff_t end = (lend + 1) >> PAGE_SHIFT;
+	unsigned int partial_start = lstart & (PAGE_SIZE - 1);
+	unsigned int partial_end = (lend + 1) & (PAGE_SIZE - 1);
 	struct pagevec pvec;
 	pgoff_t indices[PAGEVEC_SIZE];
 	long nr_swaps_freed = 0;
@@ -530,7 +530,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		struct page *page = NULL;
 		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
+			unsigned int top = PAGE_SIZE;
 			if (start > end) {
 				top = partial_end;
 				partial_end = 0;
@@ -538,7 +538,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			zero_user_segment(page, partial_start, top);
 			set_page_dirty(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (partial_end) {
@@ -548,7 +548,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			zero_user_segment(page, 0, partial_end);
 			set_page_dirty(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (start >= end)
@@ -833,7 +833,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 		mem_cgroup_commit_charge(page, memcg, true, false);
 out:
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return error;
 }
 
@@ -1080,7 +1080,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	if (!newpage)
 		return -ENOMEM;
 
-	page_cache_get(newpage);
+	get_page(newpage);
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
 
@@ -1120,8 +1120,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	set_page_private(oldpage, 0);
 
 	unlock_page(oldpage);
-	page_cache_release(oldpage);
-	page_cache_release(oldpage);
+	put_page(oldpage);
+	put_page(oldpage);
 	return error;
 }
 
@@ -1145,7 +1145,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	int once = 0;
 	int alloced = 0;
 
-	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
+	if (index > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return -EFBIG;
 repeat:
 	swap.val = 0;
@@ -1156,7 +1156,7 @@ repeat:
 	}
 
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto unlock;
 	}
@@ -1169,7 +1169,7 @@ repeat:
 		if (sgp != SGP_READ)
 			goto clear;
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		page = NULL;
 	}
 	if (page || (sgp == SGP_READ && !swap.val)) {
@@ -1327,7 +1327,7 @@ clear:
 
 	/* Perhaps the file has been truncated since we checked */
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		if (alloced) {
 			ClearPageDirty(page);
 			delete_from_page_cache(page);
@@ -1355,7 +1355,7 @@ failed:
 unlock:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (error == -ENOSPC && !once++) {
 		info = SHMEM_I(inode);
@@ -1577,7 +1577,7 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	/* i_mutex is held by caller */
 	if (unlikely(info->seals)) {
@@ -1601,16 +1601,16 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 		i_size_write(inode, pos + copied);
 
 	if (!PageUptodate(page)) {
-		if (copied < PAGE_CACHE_SIZE) {
-			unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+		if (copied < PAGE_SIZE) {
+			unsigned from = pos & (PAGE_SIZE - 1);
 			zero_user_segments(page, 0, from,
-					from + copied, PAGE_CACHE_SIZE);
+					from + copied, PAGE_SIZE);
 		}
 		SetPageUptodate(page);
 	}
 	set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return copied;
 }
@@ -1635,8 +1635,8 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (!iter_is_iovec(to))
 		sgp = SGP_DIRTY;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = *ppos >> PAGE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
 
 	for (;;) {
 		struct page *page = NULL;
@@ -1644,11 +1644,11 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		unsigned long nr, ret;
 		loff_t i_size = i_size_read(inode);
 
-		end_index = i_size >> PAGE_CACHE_SHIFT;
+		end_index = i_size >> PAGE_SHIFT;
 		if (index > end_index)
 			break;
 		if (index == end_index) {
-			nr = i_size & ~PAGE_CACHE_MASK;
+			nr = i_size & ~PAGE_MASK;
 			if (nr <= offset)
 				break;
 		}
@@ -1666,14 +1666,14 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		 * We must evaluate after, since reads (unlike writes)
 		 * are called without i_mutex protection against truncate
 		 */
-		nr = PAGE_CACHE_SIZE;
+		nr = PAGE_SIZE;
 		i_size = i_size_read(inode);
-		end_index = i_size >> PAGE_CACHE_SHIFT;
+		end_index = i_size >> PAGE_SHIFT;
 		if (index == end_index) {
-			nr = i_size & ~PAGE_CACHE_MASK;
+			nr = i_size & ~PAGE_MASK;
 			if (nr <= offset) {
 				if (page)
-					page_cache_release(page);
+					put_page(page);
 				break;
 			}
 		}
@@ -1694,7 +1694,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 				mark_page_accessed(page);
 		} else {
 			page = ZERO_PAGE(0);
-			page_cache_get(page);
+			get_page(page);
 		}
 
 		/*
@@ -1704,10 +1704,10 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		ret = copy_page_to_iter(page, offset, nr, to);
 		retval += ret;
 		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		index += offset >> PAGE_SHIFT;
+		offset &= ~PAGE_MASK;
 
-		page_cache_release(page);
+		put_page(page);
 		if (!iov_iter_count(to))
 			break;
 		if (ret < nr) {
@@ -1717,7 +1717,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		cond_resched();
 	}
 
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = ((loff_t) index << PAGE_SHIFT) + offset;
 	file_accessed(file);
 	return retval ? retval : error;
 }
@@ -1755,9 +1755,9 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	if (splice_grow_spd(pipe, &spd))
 		return -ENOMEM;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	loff = *ppos & ~PAGE_CACHE_MASK;
-	req_pages = (len + loff + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
+	loff = *ppos & ~PAGE_MASK;
+	req_pages = (len + loff + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	nr_pages = min(req_pages, spd.nr_pages_max);
 
 	spd.nr_pages = find_get_pages_contig(mapping, index,
@@ -1774,7 +1774,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		index++;
 	}
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
+	index = *ppos >> PAGE_SHIFT;
 	nr_pages = spd.nr_pages;
 	spd.nr_pages = 0;
 
@@ -1784,7 +1784,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 		if (!len)
 			break;
 
-		this_len = min_t(unsigned long, len, PAGE_CACHE_SIZE - loff);
+		this_len = min_t(unsigned long, len, PAGE_SIZE - loff);
 		page = spd.pages[page_nr];
 
 		if (!PageUptodate(page) || page->mapping != mapping) {
@@ -1793,19 +1793,19 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 			if (error)
 				break;
 			unlock_page(page);
-			page_cache_release(spd.pages[page_nr]);
+			put_page(spd.pages[page_nr]);
 			spd.pages[page_nr] = page;
 		}
 
 		isize = i_size_read(inode);
-		end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
+		end_index = (isize - 1) >> PAGE_SHIFT;
 		if (unlikely(!isize || index > end_index))
 			break;
 
 		if (end_index == index) {
 			unsigned int plen;
 
-			plen = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
+			plen = ((isize - 1) & ~PAGE_MASK) + 1;
 			if (plen <= loff)
 				break;
 
@@ -1822,7 +1822,7 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	}
 
 	while (page_nr < nr_pages)
-		page_cache_release(spd.pages[page_nr++]);
+		put_page(spd.pages[page_nr++]);
 
 	if (spd.nr_pages)
 		error = splice_to_pipe(pipe, &spd);
@@ -1904,10 +1904,10 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	else if (offset >= inode->i_size)
 		offset = -ENXIO;
 	else {
-		start = offset >> PAGE_CACHE_SHIFT;
-		end = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+		start = offset >> PAGE_SHIFT;
+		end = (inode->i_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 		new_offset = shmem_seek_hole_data(mapping, start, end, whence);
-		new_offset <<= PAGE_CACHE_SHIFT;
+		new_offset <<= PAGE_SHIFT;
 		if (new_offset > offset) {
 			if (new_offset < inode->i_size)
 				offset = new_offset;
@@ -2203,8 +2203,8 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		goto out;
 	}
 
-	start = offset >> PAGE_CACHE_SHIFT;
-	end = (offset + len + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	start = offset >> PAGE_SHIFT;
+	end = (offset + len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	/* Try to avoid a swapstorm if len is impossible to satisfy */
 	if (sbinfo->max_blocks && end - start > sbinfo->max_blocks) {
 		error = -ENOSPC;
@@ -2237,8 +2237,8 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		if (error) {
 			/* Remove the !PageUptodate pages we added */
 			shmem_undo_range(inode,
-				(loff_t)start << PAGE_CACHE_SHIFT,
-				(loff_t)index << PAGE_CACHE_SHIFT, true);
+				(loff_t)start << PAGE_SHIFT,
+				(loff_t)index << PAGE_SHIFT, true);
 			goto undone;
 		}
 
@@ -2259,7 +2259,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		 */
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 		cond_resched();
 	}
 
@@ -2280,7 +2280,7 @@ static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
 
 	buf->f_type = TMPFS_MAGIC;
-	buf->f_bsize = PAGE_CACHE_SIZE;
+	buf->f_bsize = PAGE_SIZE;
 	buf->f_namelen = NAME_MAX;
 	if (sbinfo->max_blocks) {
 		buf->f_blocks = sbinfo->max_blocks;
@@ -2523,7 +2523,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 	struct shmem_inode_info *info;
 
 	len = strlen(symname) + 1;
-	if (len > PAGE_CACHE_SIZE)
+	if (len > PAGE_SIZE)
 		return -ENAMETOOLONG;
 
 	inode = shmem_get_inode(dir->i_sb, dir, S_IFLNK|S_IRWXUGO, 0, VM_NORESERVE);
@@ -2562,7 +2562,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		SetPageUptodate(page);
 		set_page_dirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	dir->i_size += BOGO_DIRENT_SIZE;
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
@@ -2835,7 +2835,7 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 			if (*rest)
 				goto bad_val;
 			sbinfo->max_blocks =
-				DIV_ROUND_UP(size, PAGE_CACHE_SIZE);
+				DIV_ROUND_UP(size, PAGE_SIZE);
 		} else if (!strcmp(this_char,"nr_blocks")) {
 			sbinfo->max_blocks = memparse(value, &rest);
 			if (*rest)
@@ -2940,7 +2940,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
 
 	if (sbinfo->max_blocks != shmem_default_max_blocks())
 		seq_printf(seq, ",size=%luk",
-			sbinfo->max_blocks << (PAGE_CACHE_SHIFT - 10));
+			sbinfo->max_blocks << (PAGE_SHIFT - 10));
 	if (sbinfo->max_inodes != shmem_default_max_inodes())
 		seq_printf(seq, ",nr_inodes=%lu", sbinfo->max_inodes);
 	if (sbinfo->mode != (S_IRWXUGO | S_ISVTX))
@@ -3082,8 +3082,8 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	sbinfo->free_inodes = sbinfo->max_inodes;
 
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = TMPFS_MAGIC;
 	sb->s_op = &shmem_ops;
 	sb->s_time_gran = 1;
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..a0bc206b4ac6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -114,7 +114,7 @@ void put_pages_list(struct list_head *pages)
 
 		victim = list_entry(pages->prev, struct page, lru);
 		list_del(&victim->lru);
-		page_cache_release(victim);
+		put_page(victim);
 	}
 }
 EXPORT_SYMBOL(put_pages_list);
@@ -142,7 +142,7 @@ int get_kernel_pages(const struct kvec *kiov, int nr_segs, int write,
 			return seg;
 
 		pages[seg] = kmap_to_page(kiov[seg].iov_base);
-		page_cache_get(pages[seg]);
+		get_page(pages[seg]);
 	}
 
 	return seg;
@@ -236,7 +236,7 @@ void rotate_reclaimable_page(struct page *page)
 		struct pagevec *pvec;
 		unsigned long flags;
 
-		page_cache_get(page);
+		get_page(page);
 		local_irq_save(flags);
 		pvec = this_cpu_ptr(&lru_rotate_pvecs);
 		if (!pagevec_add(pvec, page))
@@ -294,7 +294,7 @@ void activate_page(struct page *page)
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
-		page_cache_get(page);
+		get_page(page);
 		if (!pagevec_add(pvec, page))
 			pagevec_lru_move_fn(pvec, __activate_page, NULL);
 		put_cpu_var(activate_page_pvecs);
@@ -389,7 +389,7 @@ static void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
-	page_cache_get(page);
+	get_page(page);
 	if (!pagevec_space(pvec))
 		__pagevec_lru_add(pvec);
 	pagevec_add(pvec, page);
@@ -646,7 +646,7 @@ void deactivate_page(struct page *page)
 	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
 
-		page_cache_get(page);
+		get_page(page);
 		if (!pagevec_add(pvec, page))
 			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
 		put_cpu_var(lru_deactivate_pvecs);
@@ -698,7 +698,7 @@ void lru_add_drain_all(void)
 }
 
 /**
- * release_pages - batched page_cache_release()
+ * release_pages - batched put_page()
  * @pages: array of pages to release
  * @nr: number of pages
  * @cold: whether the pages are cache cold
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 69cb2464e7dc..366ce3518703 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -85,7 +85,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	page_cache_get(page);
+	get_page(page);
 	SetPageSwapCache(page);
 	set_page_private(page, entry.val);
 
@@ -109,7 +109,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 		VM_BUG_ON(error == -EEXIST);
 		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 
 	return error;
@@ -226,7 +226,7 @@ void delete_from_swap_cache(struct page *page)
 	spin_unlock_irq(&address_space->tree_lock);
 
 	swapcache_free(entry);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /* 
@@ -252,7 +252,7 @@ static inline void free_swap_cache(struct page *page)
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	page_cache_release(page);
+	put_page(page);
 }
 
 /*
@@ -380,7 +380,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	} while (err != -ENOMEM);
 
 	if (new_page)
-		page_cache_release(new_page);
+		put_page(new_page);
 	return found_page;
 }
 
@@ -495,7 +495,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			continue;
 		if (offset != entry_offset)
 			SetPageReadahead(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	blk_finish_plug(&plug);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b86cf26a586b..555069ca3eae 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -113,7 +113,7 @@ __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
 		ret = try_to_free_swap(page);
 		unlock_page(page);
 	}
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 }
 
@@ -994,7 +994,7 @@ int free_swap_and_cache(swp_entry_t entry)
 			page = find_get_page(swap_address_space(entry),
 						entry.val);
 			if (page && !trylock_page(page)) {
-				page_cache_release(page);
+				put_page(page);
 				page = NULL;
 			}
 		}
@@ -1011,7 +1011,7 @@ int free_swap_and_cache(swp_entry_t entry)
 			SetPageDirty(page);
 		}
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return p != NULL;
 }
@@ -1512,7 +1512,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		}
 		if (retval) {
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			break;
 		}
 
@@ -1564,7 +1564,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 */
 		SetPageDirty(page);
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 
 		/*
 		 * Make sure that we aren't completely killing
@@ -2568,7 +2568,7 @@ bad_swap:
 out:
 	if (page && !IS_ERR(page)) {
 		kunmap(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (name)
 		putname(name);
diff --git a/mm/truncate.c b/mm/truncate.c
index 7598b552ae03..b00272810871 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -118,7 +118,7 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 		return -EIO;
 
 	if (page_has_private(page))
-		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+		do_invalidatepage(page, 0, PAGE_SIZE);
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -159,8 +159,8 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
-				   (loff_t)page->index << PAGE_CACHE_SHIFT,
-				   PAGE_CACHE_SIZE, 0);
+				   (loff_t)page->index << PAGE_SHIFT,
+				   PAGE_SIZE, 0);
 	}
 	return truncate_complete_page(mapping, page);
 }
@@ -241,8 +241,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		return;
 
 	/* Offsets within partial pages */
-	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
-	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
+	partial_start = lstart & (PAGE_SIZE - 1);
+	partial_end = (lend + 1) & (PAGE_SIZE - 1);
 
 	/*
 	 * 'start' and 'end' always covers the range of pages to be fully
@@ -250,7 +250,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	 * start of the range and 'partial_end' at the end of the range.
 	 * Note that 'end' is exclusive while 'lend' is inclusive.
 	 */
-	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	start = (lstart + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (lend == -1)
 		/*
 		 * lend == -1 indicates end-of-file so we have to set 'end'
@@ -259,7 +259,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		 */
 		end = -1;
 	else
-		end = (lend + 1) >> PAGE_CACHE_SHIFT;
+		end = (lend + 1) >> PAGE_SHIFT;
 
 	pagevec_init(&pvec, 0);
 	index = start;
@@ -298,7 +298,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	if (partial_start) {
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
+			unsigned int top = PAGE_SIZE;
 			if (start > end) {
 				/* Truncation within a single page */
 				top = partial_end;
@@ -311,7 +311,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				do_invalidatepage(page, partial_start,
 						  top - partial_start);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	if (partial_end) {
@@ -324,7 +324,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 				do_invalidatepage(page, 0,
 						  partial_end);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 		}
 	}
 	/*
@@ -538,7 +538,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
 
-	page_cache_release(page);	/* pagecache ref */
+	put_page(page);	/* pagecache ref */
 	return 1;
 failed:
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -608,18 +608,18 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 					 * Zap the rest of the file in one hit.
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
+					   (loff_t)index << PAGE_SHIFT,
 					   (loff_t)(1 + end - index)
-							 << PAGE_CACHE_SHIFT,
-					    0);
+							 << PAGE_SHIFT,
+							 0);
 					did_range_unmap = 1;
 				} else {
 					/*
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
-					   PAGE_CACHE_SIZE, 0);
+					   (loff_t)index << PAGE_SHIFT,
+					   PAGE_SIZE, 0);
 				}
 			}
 			BUG_ON(page_mapped(page));
@@ -744,14 +744,14 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 
 	WARN_ON(to > inode->i_size);
 
-	if (from >= to || bsize == PAGE_CACHE_SIZE)
+	if (from >= to || bsize == PAGE_SIZE)
 		return;
 	/* Page straddling @from will not have any hole block created? */
 	rounded_from = round_up(from, bsize);
-	if (to <= rounded_from || !(rounded_from & (PAGE_CACHE_SIZE - 1)))
+	if (to <= rounded_from || !(rounded_from & (PAGE_SIZE - 1)))
 		return;
 
-	index = from >> PAGE_CACHE_SHIFT;
+	index = from >> PAGE_SHIFT;
 	page = find_lock_page(inode->i_mapping, index);
 	/* Page not cached? Nothing to do */
 	if (!page)
@@ -763,7 +763,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	if (page_mkclean(page))
 		set_page_dirty(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 }
 EXPORT_SYMBOL(pagecache_isize_extended);
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 9f3a0290b273..af817e5060fb 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -93,7 +93,7 @@ out_release_uncharge_unlock:
 	pte_unmap_unlock(dst_pte, ptl);
 	mem_cgroup_cancel_charge(page, memcg, false);
 out_release:
-	page_cache_release(page);
+	put_page(page);
 	goto out;
 }
 
@@ -287,7 +287,7 @@ out_unlock:
 	up_read(&dst_mm->mmap_sem);
 out:
 	if (page)
-		page_cache_release(page);
+		put_page(page);
 	BUG_ON(copied < 0);
 	BUG_ON(err > 0);
 	BUG_ON(!copied && !err);
diff --git a/mm/zswap.c b/mm/zswap.c
index bf14508afd64..91dad80d068b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -869,7 +869,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 
 	case ZSWAP_SWAPCACHE_EXIST:
 		/* page is already in the swap cache, ignore for now */
-		page_cache_release(page);
+		put_page(page);
 		ret = -EEXIST;
 		goto fail;
 
@@ -897,7 +897,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
 
 	/* start writeback */
 	__swap_writepage(page, &wbc, end_swap_bio_write);
-	page_cache_release(page);
+	put_page(page);
 	zswap_written_back_pages++;
 
 	spin_lock(&tree->lock);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
