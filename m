Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 741746B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 14:05:44 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so3210802iga.1
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:05:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ih4si18986961igb.48.2014.07.15.11.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 11:05:43 -0700 (PDT)
Date: Tue, 15 Jul 2014 12:41:12 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm] mm: refactor page index/offset getters
Message-ID: <20140715164112.GA6055@nhori.bos.redhat.com>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140701180739.GA4985@node.dhcp.inet.fi>
 <20140701185021.GA10356@nhori.bos.redhat.com>
 <20140701201540.GA5953@node.dhcp.inet.fi>
 <20140702043057.GA19813@nhori.redhat.com>
 <20140707123923.5e42983d6123ebfd79c8cf4c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140707123923.5e42983d6123ebfd79c8cf4c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Jul 07, 2014 at 12:39:23PM -0700, Andrew Morton wrote:
> On Wed, 2 Jul 2014 00:30:57 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Subject: [PATCH v2] rmap: fix pgoff calculation to handle hugepage correctly
> > 
> > I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
> > hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
> > calculation in rmap_walk_anon() fails to consider compound_order() only to
> > have an incorrect value.
> > 
> > This patch introduces page_to_pgoff(), which gets the page's offset in
> > PAGE_CACHE_SIZE. Kirill pointed out that page cache tree should natively
> > handle hugepages, and in order to make hugetlbfs fit it, page->index of
> > hugetlbfs page should be in PAGE_CACHE_SIZE. This is beyond this patch,
> > but page_to_pgoff() contains the point to be fixed in a single function.
> > 
> > ...
> >
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -399,6 +399,18 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
> >  }
> >  
> >  /*
> > + * Get the offset in PAGE_SIZE.
> > + * (TODO: hugepage should have ->index in PAGE_SIZE)
> > + */
> > +static inline pgoff_t page_to_pgoff(struct page *page)
> > +{
> > +	if (unlikely(PageHeadHuge(page)))
> > +		return page->index << compound_order(page);
> > +	else
> > +		return page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > +}
> > +
> 
> This is all a bit of a mess.
> 
> We have page_offset() which only works for regular pagecache pages and
> not for huge pages.
> 
> We have page_file_offset() which works for regular pagecache as well
> as swapcache but not for huge pages.
> 
> We have page_index() and page_file_index() which differ in undocumented
> ways which I cannot be bothered working out.  The latter calls
> __page_file_index() which is grossly misnamed.
> 
> Now we get a new page_to_pgoff() which in inconsistently named but has
> a similarly crappy level of documentation and which works for hugepages
> and regular pagecache pages but not for swapcache pages.
> 
> 
> Sigh.
> 
> I'll merge this patch because it's a bugfix but could someone please
> drive a truck through all this stuff and see if we can come up with
> something tasteful and sane?

I wrote a patch for this, could you take a look?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Tue, 15 Jul 2014 12:05:53 -0400
Subject: [PATCH] mm: refactor page index/offset getters

There is a complaint about duplication around the fundamental routines
of page index/offset getters.

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
---
 fs/nfs/internal.h       |  6 +++---
 fs/nfs/pagelist.c       |  2 +-
 fs/nfs/read.c           |  2 +-
 fs/nfs/write.c          | 10 +++++-----
 fs/xfs/xfs_aops.c       |  2 +-
 include/linux/hugetlb.h |  7 -------
 include/linux/mm.h      | 26 ++++++++++----------------
 include/linux/pagemap.h | 22 +++++++++-------------
 mm/memory-failure.c     |  4 ++--
 mm/page_io.c            |  6 +++---
 mm/rmap.c               |  6 +++---
 mm/swapfile.c           |  4 ++--
 12 files changed, 40 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dd8bfc2e2464..82d942fead90 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -576,11 +576,11 @@ unsigned int nfs_page_length(struct page *page)
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
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 03ed984ab4d8..eace07a9104d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -173,7 +173,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 	 * long write-back delay. This will be adjusted in
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
-	req->wb_index	= page_file_index(page);
+	req->wb_index	= page_index(page);
 	page_cache_get(page);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 411aedda14bb..94ff1cf21d2c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -538,7 +538,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page_file_index(page));
+		page, PAGE_CACHE_SIZE, page_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ffb9459f180b..e990dd527764 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -194,9 +194,9 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
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
@@ -337,7 +337,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
-	nfs_pageio_cond_complete(pgio, page_file_index(page));
+	nfs_pageio_cond_complete(pgio, page_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
 	if (ret == -EAGAIN) {
 		redirty_page_for_writepage(wbc, page);
@@ -961,7 +961,7 @@ int nfs_updatepage(struct file *file, struct page *page,
 	nfs_inc_stats(inode, NFSIOS_VFSUPDATEPAGE);
 
 	dprintk("NFS:       nfs_updatepage(%pD2 %d@%lld)\n",
-		file, count, (long long)(page_file_offset(page) + offset));
+		file, count, (long long)(page_offset(page) + offset));
 
 	if (nfs_can_extend_write(file, page, inode)) {
 		count = max(count + offset, nfs_page_length(page));
@@ -1817,7 +1817,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
  */
 int nfs_wb_page(struct inode *inode, struct page *page)
 {
-	loff_t range_start = page_file_offset(page);
+	loff_t range_start = page_offset(page);
 	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 0479c32c5eb1..2f94687c2849 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -695,7 +695,7 @@ xfs_convert_page(
 	unsigned int		type;
 	int			len, page_dirty;
 	int			count = 0, done = 0, uptodate = 1;
- 	xfs_off_t		offset = page_offset(page);
+	xfs_off_t		offset = page_offset(page);
 
 	if (page->index != tindex)
 		goto fail;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 41272bcf73f8..026d8b147027 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -41,8 +41,6 @@ extern int hugetlb_max_hstate __read_mostly;
 struct hugepage_subpool *hugepage_new_subpool(long nr_blocks);
 void hugepage_put_subpool(struct hugepage_subpool *spool);
 
-int PageHuge(struct page *page);
-
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
 int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
@@ -108,11 +106,6 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 
 #else /* !CONFIG_HUGETLB_PAGE */
 
-static inline int PageHuge(struct page *page)
-{
-	return 0;
-}
-
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 84b2a6cf45f6..5a86ce1b4cd0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -450,8 +450,13 @@ static inline int page_count(struct page *page)
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
@@ -980,27 +985,16 @@ static inline int PageAnon(struct page *page)
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
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e1474ae18c88..3b27877ac6d0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -399,28 +399,24 @@ static inline struct page *read_mapping_page(struct address_space *mapping,
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
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e3e2f007946e..75acb65bd912 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -435,7 +435,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	if (av == NULL)	/* Not actually mapped anymore */
 		return;
 
-	pgoff = page_to_pgoff(page);
+	pgoff = page_pgoff(page);
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
@@ -469,7 +469,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	mutex_lock(&mapping->i_mmap_mutex);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
-		pgoff_t pgoff = page_to_pgoff(page);
+		pgoff_t pgoff = page_pgoff(page);
 		struct task_struct *t = task_early_kill(tsk, force_early);
 
 		if (!t)
diff --git a/mm/page_io.c b/mm/page_io.c
index 58b50d2901fe..4ca964f83718 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -250,7 +250,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 
 static sector_t swap_page_sector(struct page *page)
 {
-	return (sector_t)__page_file_index(page) << (PAGE_CACHE_SHIFT - 9);
+	return (sector_t)__page_swap_index(page) << (PAGE_CACHE_SHIFT - 9);
 }
 
 int __swap_writepage(struct page *page, struct writeback_control *wbc,
@@ -270,7 +270,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		};
 
 		init_sync_kiocb(&kiocb, swap_file);
-		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_pos = page_offset(page);
 		kiocb.ki_nbytes = PAGE_SIZE;
 
 		set_page_writeback(page);
@@ -296,7 +296,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 			set_page_dirty(page);
 			ClearPageReclaim(page);
 			pr_err_ratelimited("Write error on dio swapfile (%Lu)\n",
-				page_file_offset(page));
+				page_offset(page));
 		}
 		end_page_writeback(page);
 		return ret;
diff --git a/mm/rmap.c b/mm/rmap.c
index 3e8491c504f8..7928ddd91b6e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -517,7 +517,7 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
 static inline unsigned long
 __vma_address(struct page *page, struct vm_area_struct *vma)
 {
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 }
 
@@ -1615,7 +1615,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
 static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct anon_vma *anon_vma;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
@@ -1656,7 +1656,7 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page_to_pgoff(page);
+	pgoff_t pgoff = page_pgoff(page);
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e0ac59..1c4027c702fb 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2715,13 +2715,13 @@ struct address_space *__page_file_mapping(struct page *page)
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
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
