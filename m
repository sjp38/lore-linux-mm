Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id A2FA86B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:39:21 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so5750188igb.14
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 14:39:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p10si14163866igx.56.2014.07.23.14.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 14:39:20 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:39:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm: refactor page index/offset getters
Message-Id: <20140723143918.8334558ccac8c29047c0058b@linux-foundation.org>
In-Reply-To: <20140715164112.GA6055@nhori.bos.redhat.com>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20140701180739.GA4985@node.dhcp.inet.fi>
	<20140701185021.GA10356@nhori.bos.redhat.com>
	<20140701201540.GA5953@node.dhcp.inet.fi>
	<20140702043057.GA19813@nhori.redhat.com>
	<20140707123923.5e42983d6123ebfd79c8cf4c@linux-foundation.org>
	<20140715164112.GA6055@nhori.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, 15 Jul 2014 12:41:12 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> There is a complaint about duplication around the fundamental routines
> of page index/offset getters.
> 
> page_(index|offset) and page_file_(index|offset) provide the same
> functionality, so we can merge them as page_(index|offset), respectively.
> 
> And this patch gives the clear meaning to the getters:
>  - page_index(): get page cache index (offset in relevant page size)
>  - page_pgoff(): get 4kB page offset
>  - page_offset(): get byte offset
> All these functions are aware of regular pages, swapcaches, and hugepages.
> 
> The definition of PageHuge is relocated to include/linux/mm.h, because
> some users of page_pgoff() doesn't include include/linux/hugetlb.h.
> 
> __page_file_index() is not well named, because it's only for swap cache.
> So let's rename it with __page_swap_index().

Thanks, I guess that's better.  Could others please have a look-n-think?

I did this:

--- a/include/linux/pagemap.h~mm-refactor-page-index-offset-getters-fix
+++ a/include/linux/pagemap.h
@@ -412,7 +412,7 @@ static inline pgoff_t page_pgoff(struct
 }
 
 /*
- * Return the byte offset of the given page.
+ * Return the file offset of the given pagecache page, in bytes.
  */
 static inline loff_t page_offset(struct page *page)
 {



You had a random xfs_aops.c whitespace fix which I'll pretend I didn't
notice ;)




From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: mm: refactor page index/offset getters

There is a complaint about duplication around the fundamental routines of
page index/offset getters.

page_(index|offset) and page_file_(index|offset) provide the same
functionality, so we can merge them as page_(index|offset), respectively.

And this patch gives the clear meaning to the getters:
 - page_index(): get page cache index (offset in relevant page size)
 - page_pgoff(): get 4kB page offset
 - page_offset(): get byte offset
All these functions are aware of regular pages, swapcaches, and hugepages.

The definition of PageHuge is relocated to include/linux/mm.h, because
some users of page_pgoff() doesn't include include/linux/hugetlb.h.

__page_file_index() is not well named, because it's only for swap cache.
So let's rename it with __page_swap_index().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/internal.h       |    6 +++---
 fs/nfs/pagelist.c       |    2 +-
 fs/nfs/read.c           |    2 +-
 fs/nfs/write.c          |   10 +++++-----
 fs/xfs/xfs_aops.c       |    2 +-
 include/linux/hugetlb.h |    7 -------
 include/linux/mm.h      |   26 ++++++++++----------------
 include/linux/pagemap.h |   22 +++++++++-------------
 mm/memory-failure.c     |    4 ++--
 mm/page_io.c            |    6 +++---
 mm/rmap.c               |    6 +++---
 mm/swapfile.c           |    4 ++--
 12 files changed, 40 insertions(+), 57 deletions(-)

diff -puN fs/nfs/internal.h~mm-refactor-page-index-offset-getters fs/nfs/internal.h
--- a/fs/nfs/internal.h~mm-refactor-page-index-offset-getters
+++ a/fs/nfs/internal.h
@@ -566,11 +566,11 @@ unsigned int nfs_page_length(struct page
 	loff_t i_size = i_size_read(page_file_mapping(page)->host);
 
 	if (i_size > 0) {
-		pgoff_t page_index = page_file_index(page);
+		pgoff_t index = page_index(page);
 		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-		if (page_index < end_index)
+		if (index < end_index)
 			return PAGE_CACHE_SIZE;
-		if (page_index == end_index)
+		if (index == end_index)
 			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
 	}
 	return 0;
diff -puN fs/nfs/pagelist.c~mm-refactor-page-index-offset-getters fs/nfs/pagelist.c
--- a/fs/nfs/pagelist.c~mm-refactor-page-index-offset-getters
+++ a/fs/nfs/pagelist.c
@@ -333,7 +333,7 @@ nfs_create_request(struct nfs_open_conte
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
-	req->wb_index	= page_file_index(page);
+	req->wb_index	= page_index(page);
 	page_cache_get(page);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
diff -puN fs/nfs/read.c~mm-refactor-page-index-offset-getters fs/nfs/read.c
--- a/fs/nfs/read.c~mm-refactor-page-index-offset-getters
+++ a/fs/nfs/read.c
@@ -271,7 +271,7 @@ int nfs_readpage(struct file *file, stru
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page_file_index(page));
+		page, PAGE_CACHE_SIZE, page_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
diff -puN fs/nfs/write.c~mm-refactor-page-index-offset-getters fs/nfs/write.c
--- a/fs/nfs/write.c~mm-refactor-page-index-offset-getters
+++ a/fs/nfs/write.c
@@ -153,9 +153,9 @@ static void nfs_grow_file(struct page *p
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
 	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
-	if (i_size > 0 && page_file_index(page) < end_index)
+	if (i_size > 0 && page_index(page) < end_index)
 		goto out;
-	end = page_file_offset(page) + ((loff_t)offset+count);
+	end = page_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
 		goto out;
 	i_size_write(inode, end);
@@ -569,7 +569,7 @@ static int nfs_do_writepage(struct page
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	nfs_pageio_cond_complete(pgio, page_file_index(page));
+	nfs_pageio_cond_complete(pgio, page_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
@@ -1212,7 +1212,7 @@ int nfs_updatepage(struct file *file, st
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
 	dprintk("NFS:       nfs_updatepage(%pD2 %d@%lld)\n",
-		file, count, (long long)(page_file_offset(page) + offset));
+		file, count, (long long)(page_offset(page) + offset));
 
 	if (nfs_can_extend_write(file, page, inode)) {
 		count = max(count + offset, nfs_page_length(page));
@@ -1827,7 +1827,7 @@ int nfs_wb_page_cancel(struct inode *ino
  */
 int nfs_wb_page(struct inode *inode, struct page *page)
 {
-	loff_t range_start = page_file_offset(page);
+	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
diff -puN fs/xfs/xfs_aops.c~mm-refactor-page-index-offset-getters fs/xfs/xfs_aops.c
--- a/fs/xfs/xfs_aops.c~mm-refactor-page-index-offset-getters
+++ a/fs/xfs/xfs_aops.c
@@ -695,7 +695,7 @@ xfs_convert_page(
 	unsigned int		type;
 	int			len, page_dirty;
 	int			count = 0, done = 0, uptodate = 1;
- 	xfs_off_t		offset = page_offset(page);
+	xfs_off_t		offset = page_offset(page);
 
 	if (page->index != tindex)
 		goto fail;
diff -puN include/linux/hugetlb.h~mm-refactor-page-index-offset-getters include/linux/hugetlb.h
--- a/include/linux/hugetlb.h~mm-refactor-page-index-offset-getters
+++ a/include/linux/hugetlb.h
@@ -41,8 +41,6 @@ extern int hugetlb_max_hstate __read_mos
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
-int PageHuge(struct page *page);
-
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
@@ -108,11 +106,6 @@ unsigned long hugetlb_change_protection(
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
-static inline int PageHuge(struct page *page)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff -puN include/linux/mm.h~mm-refactor-page-index-offset-getters include/linux/mm.h
--- a/include/linux/mm.h~mm-refactor-page-index-offset-getters
+++ a/include/linux/mm.h
@@ -456,8 +456,13 @@ static inline int page_count(struct page
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
+extern int PageHuge(struct page *page);
 extern int PageHeadHuge(struct page *page_head);
 #else /* CONFIG_HUGETLB_PAGE */
+static inline int PageHuge(struct page *page)
+{
+	return 0;
+}
 static inline int PageHeadHuge(struct page *page_head)
 {
 	return 0;
@@ -986,27 +991,16 @@ static inline int PageAnon(struct page *
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
-/*
- * Return the pagecache index of the passed page.  Regular pagecache pages
- * use ->index whereas swapcache pages use ->private
- */
-static inline pgoff_t page_index(struct page *page)
-{
-	if (unlikely(PageSwapCache(page)))
-		return page_private(page);
-	return page->index;
-}
-
-extern pgoff_t __page_file_index(struct page *page);
+extern pgoff_t __page_swap_index(struct page *page);
 
 /*
- * Return the file index of the page. Regular pagecache pages use ->index
- * whereas swapcache pages use swp_offset(->private)
+ * Return the pagecache index of the passed page, which is the offset
+ * in the relevant page size.
  */
-static inline pgoff_t page_file_index(struct page *page)
+static inline pgoff_t page_index(struct page *page)
 {
 	if (unlikely(PageSwapCache(page)))
-		return __page_file_index(page);
+		return __page_swap_index(page);
 
 	return page->index;
 }
diff -puN include/linux/pagemap.h~mm-refactor-page-index-offset-getters include/linux/pagemap.h
--- a/include/linux/pagemap.h~mm-refactor-page-index-offset-getters
+++ a/include/linux/pagemap.h
@@ -399,28 +399,24 @@ static inline struct page *read_mapping_
 }
 
 /*
- * Get the offset in PAGE_SIZE.
+ * Return the 4kB page offset of the given page.
  * (TODO: hugepage should have ->index in PAGE_SIZE)
  */
-static inline pgoff_t page_to_pgoff(struct page *page)
+static inline pgoff_t page_pgoff(struct page *page)
 {
-	if (unlikely(PageHeadHuge(page)))
-		return page->index << compound_order(page);
-	else
-		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	if (unlikely(PageHuge(page))) {
+		VM_BUG_ON_PAGE(PageTail(page), page);
+		return page_index(page) << compound_order(page);
+	} else
+		return page_index(page) << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
 /*
- * Return byte-offset into filesystem object for page.
+ * Return the byte offset of the given page.
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
-}
-
-static inline loff_t page_file_offset(struct page *page)
-{
-	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_pgoff(page)) << PAGE_SHIFT;
 }
 
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
diff -puN mm/memory-failure.c~mm-refactor-page-index-offset-getters mm/memory-failure.c
--- a/mm/memory-failure.c~mm-refactor-page-index-offset-getters
+++ a/mm/memory-failure.c
@@ -435,7 +435,7 @@ static void collect_procs_anon(struct pa
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
-	pgoff = page_to_pgoff(page);
+	pgoff = page_pgoff(page);
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
@@ -469,7 +469,7 @@ static void collect_procs_file(struct pa
 	mutex_lock(&mapping->i_mmap_mutex);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
-		pgoff_t pgoff = page_to_pgoff(page);
+		pgoff_t pgoff = page_pgoff(page);
 		struct task_struct *t = task_early_kill(tsk, force_early);
 
 		if (!t)
diff -puN mm/page_io.c~mm-refactor-page-index-offset-getters mm/page_io.c
--- a/mm/page_io.c~mm-refactor-page-index-offset-getters
+++ a/mm/page_io.c
@@ -250,7 +250,7 @@ out:
 
 static sector_t swap_page_sector(struct page *page)
 {
-	return (sector_t)__page_file_index(page) << (PAGE_CACHE_SHIFT - 9);
+	return (sector_t)__page_swap_index(page) << (PAGE_CACHE_SHIFT - 9);
 }
 
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
@@ -278,7 +278,7 @@ int __swap_writepage(struct page *page,
 		from.bvec = &bv;	/* older gcc versions are broken */
 
 		init_sync_kiocb(&kiocb, swap_file);
-		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_pos = page_offset(page);
 		kiocb.ki_nbytes = PAGE_SIZE;
 
 		set_page_writeback(page);
@@ -303,7 +303,7 @@ int __swap_writepage(struct page *page,
 			set_page_dirty(page);
 			ClearPageReclaim(page);
 			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
-				page_file_offset(page));
+				page_offset(page));
 		}
 		end_page_writeback(page);
 		return ret;
diff -puN mm/rmap.c~mm-refactor-page-index-offset-getters mm/rmap.c
--- a/mm/rmap.c~mm-refactor-page-index-offset-getters
+++ a/mm/rmap.c
@@ -517,7 +517,7 @@ void page_unlock_anon_vma_read(struct an
 static inline unsigned long
 __vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 }
 
@@ -1615,7 +1615,7 @@ static struct anon_vma *rmap_walk_anon_l
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1656,7 +1656,7 @@ static int rmap_walk_anon(struct page *p
 static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
diff -puN mm/swapfile.c~mm-refactor-page-index-offset-getters mm/swapfile.c
--- a/mm/swapfile.c~mm-refactor-page-index-offset-getters
+++ a/mm/swapfile.c
@@ -2715,13 +2715,13 @@ struct address_space *__page_file_mappin
 }
 EXPORT_SYMBOL_GPL(__page_file_mapping);
 
-pgoff_t __page_file_index(struct page *page)
+pgoff_t __page_swap_index(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	return swp_offset(swap);
 }
-EXPORT_SYMBOL_GPL(__page_file_index);
+EXPORT_SYMBOL_GPL(__page_swap_index);
 
 /*
  * add_swap_count_continuation - called when a swap count is duplicated
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
