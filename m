Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 58A8E6B0069
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 17:42:17 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Date: Fri, 10 Aug 2012 17:41:53 -0400
Message-Id: <1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Current error reporting of memory errors on dirty pagecache has silent
data lost problem because AS_EIO in struct address_space is cleared
once checked.
A simple solution is to make AS_EIO sticky (as Wu Fengguang proposed in
https://lkml.org/lkml/2009/6/11/294), but this patch does more to make
dirty pagecache error recoverable under some conditions. Consider that
if there is a copy of the corrupted dirty pagecache on user buffer and
you write() over the error page with the copy data, then we can ignore
the effect of the error because no one consumes the corrupted data.

To implement this, this patch does roughly the following:
  - add data structures and handling routines to manage the metadata
    of memory errors on dirty pagecaches,
  - return -EHWPOISON when we access to the error-affected address with
    read(), partial-page write(), fsync(),
  - cancel hwpoison when we do full-page write() over the error-affected
    address.

One reason why we have a separate flag AS_HWPOISON is that the conditions
of clearing flags differs between legacy IO error and memory error. AS_EIO
is cleared when subsequent writeback for the error-affected file succeeds.
OTOH, AS_HWPOISON can be cleared when a pagecache on which the error lies
is fully overwritten with copy data in user buffer.
Another reason is that we expect user processes which get the error report
from the kernel to handle it differently between the two types of errors.
Processes which get -EHWPOISON can search copy data in their buffers and
try to write() over the error pages if they have.

We have one behavioral change on PageHWPoison flag. Before this patch,
PageHWPoison means literally "the page is corrupted," and the pages with
PageHWPoison set are never reused. After this patch, we give another role
to this flag. When a user process tries to access the address which was
backed by the corrupted page (which is already removed from pagecache by
memory error handler,) we permit to add a new page onto the pagecache
with PageHWPoison flag set. But we refuse to read() and partial write()
on the page until the PageHWPoison flag is cleared by whole-page write().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/page-flags.h |   2 +
 include/linux/pagemap.h    |  91 ++++++++++++
 mm/filemap.c               |  51 +++++++
 mm/memory-failure.c        | 343 +++++++++++++++++++++++++++++++++++++++++++--
 mm/truncate.c              |   3 +
 5 files changed, 479 insertions(+), 11 deletions(-)

diff --git v3.6-rc1.orig/include/linux/page-flags.h v3.6-rc1/include/linux/page-flags.h
index b5d1384..25bbde0 100644
--- v3.6-rc1.orig/include/linux/page-flags.h
+++ v3.6-rc1/include/linux/page-flags.h
@@ -272,6 +272,8 @@ TESTSCFLAG(HWPoison, hwpoison)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
 #else
 PAGEFLAG_FALSE(HWPoison)
+SETPAGEFLAG_NOOP(HWPoison)
+CLEARPAGEFLAG_NOOP(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
diff --git v3.6-rc1.orig/include/linux/pagemap.h v3.6-rc1/include/linux/pagemap.h
index e42c762..8b18560 100644
--- v3.6-rc1.orig/include/linux/pagemap.h
+++ v3.6-rc1/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_HWPOISON     = __GFP_BITS_SHIFT + 4, /* pagecache is hwpoisoned */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -31,6 +32,8 @@ static inline void mapping_set_error(struct address_space *mapping, int error)
 	if (unlikely(error)) {
 		if (error == -ENOSPC)
 			set_bit(AS_ENOSPC, &mapping->flags);
+		else if (error == -EHWPOISON)
+			set_bit(AS_HWPOISON, &mapping->flags);
 		else
 			set_bit(AS_EIO, &mapping->flags);
 	}
@@ -541,4 +544,92 @@ static inline int add_to_page_cache(struct page *page,
 	return error;
 }
 
+#ifdef CONFIG_MEMORY_FAILURE
+extern int __hwpoison_file_range(struct address_space *mapping, loff_t start,
+				loff_t end);
+extern int __hwpoison_partial_write(struct address_space *mapping, loff_t pos,
+					size_t count);
+extern void __remove_hwp_dirty_pgoff(struct address_space *mapping,
+					pgoff_t index);
+extern void __remove_hwp_dirty_file(struct inode *inode);
+extern void __add_fake_hwpoison(struct page *page,
+				struct address_space *mapping, pgoff_t index);
+extern void __remove_fake_hwpoison(struct page *page,
+				struct address_space *mapping);
+
+static inline int hwpoison_file_range(struct address_space *mapping,
+				loff_t start, loff_t end)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &mapping->flags)))
+		return __hwpoison_file_range(mapping, start, end);
+	return 0;
+}
+
+static inline int hwpoison_partial_write(struct address_space *mapping,
+					loff_t pos, size_t count)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &mapping->flags)))
+		return __hwpoison_partial_write(mapping, pos, count);
+	return 0;
+}
+
+static inline void remove_hwp_dirty_pgoff(struct address_space *mapping,
+					pgoff_t index)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &mapping->flags)))
+		__remove_hwp_dirty_pgoff(mapping, index);
+}
+
+static inline void remove_hwp_dirty_file(struct inode *inode)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &inode->i_mapping->flags)))
+		__remove_hwp_dirty_file(inode);
+}
+
+static inline void add_fake_hwpoison(struct page *page,
+				struct address_space *mapping, pgoff_t index)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &mapping->flags)))
+		__add_fake_hwpoison(page, mapping, index);
+}
+
+static inline void remove_fake_hwpoison(struct page *page,
+				struct address_space *mapping)
+{
+	if (unlikely(test_bit(AS_HWPOISON, &mapping->flags)))
+		__remove_fake_hwpoison(page, mapping);
+}
+#else
+static inline int hwpoison_file_range(struct address_space *mapping,
+				loff_t start, loff_t end)
+{
+	return 0;
+}
+
+static inline int hwpoison_partial_write(struct address_space *mapping,
+				loff_t pos, size_t count)
+{
+	return 0;
+}
+
+static inline void remove_hwp_dirty_pgoff(struct address_space *mapping,
+					pgoff_t index)
+{
+}
+
+static inline void remove_hwp_dirty_file(struct inode *inode)
+{
+}
+
+static inline void add_fake_hwpoison(struct page *page,
+				struct address_space *mapping, pgoff_t index)
+{
+}
+
+static inline void remove_fake_hwpoison(struct page *page,
+				struct address_space *mapping)
+{
+}
+#endif /* CONFIG_MEMORY_FAILURE */
+
 #endif /* _LINUX_PAGEMAP_H */
diff --git v3.6-rc1.orig/mm/filemap.c v3.6-rc1/mm/filemap.c
index fa5ca30..b446f7c 100644
--- v3.6-rc1.orig/mm/filemap.c
+++ v3.6-rc1/mm/filemap.c
@@ -123,6 +123,9 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
+	if (unlikely(PageHWPoison(page)))
+		remove_fake_hwpoison(page, mapping);
+
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
@@ -270,6 +273,9 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 	if (end_byte < start_byte)
 		return 0;
 
+	if (unlikely(hwpoison_file_range(mapping, start_byte, end_byte)))
+		return -EHWPOISON;
+
 	pagevec_init(&pvec, 0);
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
@@ -369,6 +375,16 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 				err = err2;
 		}
 	}
+
+	/*
+	 * When AS_HWPOISON is set, dirty page with memory error is
+	 * removed from pagecache and mapping->nrpages is decreased by 1.
+	 * So in order to detect memory error on single page file, we need
+	 * to check AS_HWPOISON bit outside if(mapping->nrpages) block below.
+	 */
+	if (unlikely(hwpoison_file_range(mapping, lstart, lend)))
+		return -EHWPOISON;
+
 	return err;
 }
 EXPORT_SYMBOL(filemap_write_and_wait_range);
@@ -447,6 +463,22 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
 
+	/*
+	 * Mark as "fake hwpoison" which shows that the virtual address range
+	 * backed by the page are affected by a memory error. Accesse to
+	 * the fake hwpoison page will get -EHWPOISON if it's read or partial
+	 * page write.
+	 * The benefit of fake hwpoison is that we can get it back to the
+	 * healthy page (i.e. we can ignore the memory error) by full page
+	 * overwrite. Applications are expected to do full page overwrite
+	 * from their own buffers when they find memory errors on the files
+	 * which they open.
+	 * We can distinguish fake hwpoison pages from real hwpoison (i.e.
+	 * physically corrupted) pages by checking struct hwp_dirty (see
+	 * mm/memory-failure.c).
+	 */
+	add_fake_hwpoison(page, mapping, offset);
+
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
@@ -1114,6 +1146,12 @@ find_page:
 			if (unlikely(page == NULL))
 				goto no_cached_page;
 		}
+
+		if (unlikely(PageHWPoison(page))) {
+			error = -EHWPOISON;
+			goto readpage_error;
+		}
+
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping,
 					ra, filp, page,
@@ -2085,6 +2123,9 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
         if (unlikely(*pos < 0))
                 return -EINVAL;
 
+	if (unlikely(hwpoison_partial_write(file->f_mapping, *pos, *count)))
+		return -EHWPOISON;
+
 	if (!isblk) {
 		/* FIXME: this is for backwards compatibility with 2.4 */
 		if (file->f_flags & O_APPEND)
@@ -2339,6 +2380,16 @@ again:
 		flush_dcache_page(page);
 
 		mark_page_accessed(page);
+		/*
+		 * By overwriting hwpoisoned page from userspace buffers, we
+		 * can "detoxify" the hwpoison because no corrupted data will
+		 * be consumed after this.
+		 */
+		if (unlikely(PageHWPoison(page))) {
+			VM_BUG_ON(!test_bit(AS_HWPOISON, &mapping->flags));
+			ClearPageHWPoison(page);
+			remove_hwp_dirty_pgoff(mapping, page_index(page));
+		}
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
 		if (unlikely(status < 0))
diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
index 7e62797..348fa05 100644
--- v3.6-rc1.orig/mm/memory-failure.c
+++ v3.6-rc1/mm/memory-failure.c
@@ -607,23 +607,334 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 }
 
 /*
+ * A control structure which keeps information about dirty pagecache error.
+ * This allows user processes to know the virtual address of corrupted pages,
+ * which is useful to make applications handle memroy errors.
+ * Especially if applications have the copy of corrupted data on their own
+ * buffers, they can take a recovery action by overwriting the error page.
+ */
+struct hwp_dirty {
+	struct hlist_node hash;
+	struct hlist_node hash_pfn;
+	struct page *page; /* real hwpoison (physically corrupted) page */
+	struct page *fpage; /* fake hwpoison page */
+	struct address_space *mapping;
+	unsigned long index; /* page offset of hwpoison page in the file */
+};
+#define HWP_DIRTY_HASH_HEADS 64
+static struct hlist_head *hwp_dirty_hash;
+static struct hlist_head *hwp_dirty_hash_pfn;
+static DEFINE_SPINLOCK(hwp_dirty_lock);
+
+static inline struct hlist_head *hwp_dirty_hlist_head(struct address_space *as)
+{
+	return &hwp_dirty_hash[((unsigned long)as/sizeof(struct address_space))
+				% HWP_DIRTY_HASH_HEADS];
+}
+
+static inline struct hlist_head *hwp_dirty_hlist_pfn_head(unsigned long pfn)
+{
+	return &hwp_dirty_hash_pfn[(pfn/sizeof(unsigned long))
+				% HWP_DIRTY_HASH_HEADS];
+}
+
+/*
+ * Check whether given address range [start,end) overlaps corrupted dirty
+ * pagecaches or not. Returns 1 if it's the case, and returns 0 otherwise.
+ */
+int __hwpoison_file_range(struct address_space *mapping,
+				loff_t start, loff_t end)
+{
+	int ret = 0;
+	struct hwp_dirty *hwp;
+	loff_t hwpstart, hwpend;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash) {
+		if (mapping != hwp->mapping)
+			continue;
+		hwpstart = hwp->index << PAGE_SHIFT;
+		hwpend = (hwp->index + 1) << PAGE_SHIFT;
+		if (!(hwpend <= start || end < hwpstart)) {
+			ret = 1;
+			break;
+		}
+	}
+	spin_unlock(&hwp_dirty_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__hwpoison_file_range);
+
+/*
+ * Check whether given write range partially covers corrupted dirty pagecaches
+ * or not. Writing over the entire range of the corrupted dirty pagecache is
+ * *acceptable*, because it does not cause any corrupted data consumption.
+ * Returns 1 if either @pos or (@pos + @count) is inside the range of dirty
+ * pagecache. Returns 0 otherwise.
+ *
+ *    |....|....|XXXX|....|....|       => returns 0 (covered entirely)
+ *            ^------^
+ *            @pos   @pos + @count
+ *
+ *    |....|....|XXXX|....|....|       => returns 1 (covered partially)
+ *            ^----^
+ *
+ *    |....|XXXX|....|XXXX|....|       => returns 1 (covered partially)
+ *            ^-------------^
+ *
+ *    |....|XXXX|....|XXXX|....|       => returns 0 (covered entirely)
+ *        ^------------------^
+ *
+ *    |....| : healthy page
+ *    |XXXX| : corrupted page
+ */
+int __hwpoison_partial_write(struct address_space *mapping,
+				loff_t pos, size_t count)
+{
+	int ret = 0;
+	struct hwp_dirty *hwp;
+	loff_t hwpstart, hwpend;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash) {
+		if (mapping != hwp->mapping)
+			continue;
+		hwpstart = hwp->index << PAGE_SHIFT;
+		hwpend = (hwp->index + 1) << PAGE_SHIFT;
+		if ((hwpstart < pos && pos < hwpend) ||
+		    (hwpstart < pos + count && pos + count < hwpend)) {
+			ret = 1;
+			break;
+		}
+	}
+	spin_unlock(&hwp_dirty_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(__hwpoison_partial_write);
+
+static void add_hwp_dirty(struct hwp_dirty *hwp)
+{
+	struct hlist_head *head;
+	struct address_space *mapping = hwp->mapping;
+	unsigned long pfn = page_to_pfn(hwp->page);
+
+	spin_lock(&hwp_dirty_lock);
+	/*
+	 * Keep inode cache (in the result AS_HWPOISON bit in address_space)
+	 * on memory to remember that the file experienced dirty pagecache
+	 * errors when reopened in the future.
+	 */
+	igrab(mapping->host);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_add_head(&hwp->hash, head);
+	head = hwp_dirty_hlist_pfn_head(pfn);
+	hlist_add_head(&hwp->hash_pfn, head);
+	spin_unlock(&hwp_dirty_lock);
+}
+
+static void __remove_hwp_dirty(struct hwp_dirty *hwp, int count)
+{
+	hlist_del(&hwp->hash);
+	hlist_del(&hwp->hash_pfn);
+	/*
+	 * If you try to unpoison the corrupted page with which a fake
+	 * hwpoison associated, you also unpoison the fake hwpoison page for
+	 * consistency. Unpoisoning should not be used on production systems.
+	 */
+	if (hwp->fpage)
+		TestClearPageHWPoison(hwp->fpage);
+	if (count == 1)
+		clear_bit(AS_HWPOISON, &hwp->mapping->flags);
+	iput(hwp->mapping->host);
+	kfree(hwp);
+}
+
+/*
+ * Used by unpoison_memory(). If you try to unpoison a fake hwpoison
+ * which is linked to pagecache and not counted in mce_bad_pages,
+ * this function returns 1 to avoid switching on freeit flag in the
+ * caller and counting down mce_bad_pages. Otherwise, returns 0.
+ */
+static int remove_hwp_dirty_page(struct page *page)
+{
+	int ret = 0;
+	struct hwp_dirty *hwp;
+	struct hwp_dirty *hwp_hit = NULL;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+	struct address_space *mapping = page_mapping(page);
+
+	spin_lock(&hwp_dirty_lock);
+	/* Unpoison a real corrupted page */
+	if (!mapping) {
+		head = hwp_dirty_hlist_pfn_head(page_to_pfn(page));
+		hlist_for_each_entry_safe(hwp, node1, node2, head, hash_pfn)
+			if (page == hwp->page) {
+				hwp_hit = hwp;
+				break;
+			}
+		if (hwp_hit) {
+			int count = 0;
+			head = hwp_dirty_hlist_head(hwp_hit->mapping);
+			hlist_for_each_entry_safe(hwp, node1, node2, head, hash)
+				if (hwp->mapping == hwp_hit->mapping)
+					count++;
+			__remove_hwp_dirty(hwp_hit, count);
+		}
+	/* Unpoison a fake hwpoison page */
+	} else {
+		head = hwp_dirty_hlist_head(mapping);
+		hlist_for_each_entry_safe(hwp, node1, node2, head, hash)
+			if (page == hwp->fpage) {
+				ret = 1;
+				break;
+			}
+	}
+	spin_unlock(&hwp_dirty_lock);
+	return ret;
+}
+
+/*
+ * Remove hwp_dirty for the given page offset @index in the file with which
+ * @mapping is associated.
+ */
+void __remove_hwp_dirty_pgoff(struct address_space *mapping, pgoff_t index)
+{
+	int count = 0;
+	struct hwp_dirty *hwp;
+	struct hwp_dirty *hwp_hit = NULL;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash) {
+		if (mapping == hwp->mapping) {
+			count++;
+			if (index == hwp->index)
+				hwp_hit = hwp;
+		}
+	}
+	if (hwp_hit)
+		__remove_hwp_dirty(hwp_hit, count);
+	spin_unlock(&hwp_dirty_lock);
+}
+EXPORT_SYMBOL_GPL(__remove_hwp_dirty_pgoff);
+
+/*
+ * Remove all dirty pagecache errors which belong to the given file
+ * represented by @inode from hwp_dirty_hash.
+ */
+void __remove_hwp_dirty_file(struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct hwp_dirty *hwp;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash)
+		if (mapping == hwp->mapping)
+			__remove_hwp_dirty(hwp, 0);
+	clear_bit(AS_HWPOISON, &mapping->flags);
+	spin_unlock(&hwp_dirty_lock);
+}
+
+
+void __add_fake_hwpoison(struct page *page, struct address_space *mapping,
+			 pgoff_t index)
+{
+	struct hwp_dirty *hwp;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash) {
+		if (mapping == hwp->mapping && index == hwp->index) {
+			hwp->fpage = page;
+			SetPageHWPoison(page);
+			break;
+		}
+	}
+	spin_unlock(&hwp_dirty_lock);
+}
+EXPORT_SYMBOL_GPL(__add_fake_hwpoison);
+
+void __remove_fake_hwpoison(struct page *page, struct address_space *mapping)
+{
+	struct hwp_dirty *hwp;
+	struct hlist_head *head;
+	struct hlist_node *node1, *node2;
+	pgoff_t index = page_index(page);
+
+	spin_lock(&hwp_dirty_lock);
+	head = hwp_dirty_hlist_head(mapping);
+	hlist_for_each_entry_safe(hwp, node1, node2, head, hash) {
+		if (page == hwp->fpage && mapping == hwp->mapping &&
+		    index == hwp->index) {
+			hwp->fpage = NULL;
+			ClearPageHWPoison(page);
+			break;
+		}
+	}
+	spin_unlock(&hwp_dirty_lock);
+}
+EXPORT_SYMBOL_GPL(__remove_fake_hwpoison);
+
+/*
  * Dirty cache page page
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
  */
 static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 {
-	/*
-	 * The original memory error handling on dirty pagecache has
-	 * a bug that user processes who use corrupted pages via read()
-	 * or write() can't be aware of the memory error and result
-	 * in throwing out dirty data silently.
-	 *
-	 * Until we solve the problem, let's close the path of memory
-	 * error handling for dirty pagecache. We just leave errors
-	 * for the 2nd MCE to trigger panics.
-	 */
-	return IGNORED;
+	struct address_space *mapping = page_mapping(p);
+
+	SetPageError(p);
+	if (mapping) {
+		struct hwp_dirty *hwp;
+		struct inode *inode = mapping->host;
+
+		/*
+		 * Memory error is reported to userspace by AS_HWPOISON flags
+		 * in mapping->flags. The mechanism is similar to that of
+		 * AS_EIO, but we have separete flags because there'are two
+		 * differences between them:
+		 *  1. Expected userspace handling. When user processes get
+		 *     -EIO, they can retry writeback hoping the error in IO
+		 *     devices is temporary, switch to write to other devices,
+		 *     or do some other application-specific handling.
+		 *     For -EHWPOISON, we can clear the error by overwriting
+		 *     the corrupted page.
+		 *  2. When to clear. For -EIO, we can think that we recover
+		 *     from the error when writeback succeeds. For -EHWPOISON
+		 *     OTOH, we can see that things are back to normal when
+		 *     corrupted data are overwritten from user buffer.
+		 */
+		hwp = kmalloc(sizeof(struct hwp_dirty), GFP_ATOMIC);
+		hwp->page = p;
+		hwp->fpage = NULL;
+		hwp->mapping = mapping;
+		hwp->index = page_index(p);
+		hwp->ino = inode->i_ino;
+		hwp->dev = inode->i_sb->s_dev;
+		add_hwp_dirty(hwp);
+
+		pr_err("MCE %#lx: Corrupted dirty pagecache, dev %u:%u, inode:%lu, index:%lu\n",
+		       pfn, MAJOR(inode->i_sb->s_dev),
+		       MINOR(inode->i_sb->s_dev), inode->i_ino, page_index(p));
+		mapping_set_error(mapping, -EHWPOISON);
+	}
+
+	return me_pagecache_clean(p, pfn);
 }
 
 /*
@@ -1237,6 +1548,13 @@ static int __init memory_failure_init(void)
 		INIT_WORK(&mf_cpu->work, memory_failure_work_func);
 	}
 
+	hwp_dirty_hash = kzalloc(HWP_DIRTY_HASH_HEADS *
+				sizeof(struct hlist_head), GFP_KERNEL);
+	hwp_dirty_hash_pfn = kzalloc(HWP_DIRTY_HASH_HEADS *
+				sizeof(struct hlist_head), GFP_KERNEL);
+	if (!hwp_dirty_hash || !hwp_dirty_hash_pfn)
+		return -ENOMEM;
+
 	return 0;
 }
 core_initcall(memory_failure_init);
@@ -1299,11 +1617,14 @@ int unpoison_memory(unsigned long pfn)
 	 */
 	if (TestClearPageHWPoison(page)) {
 		pr_info("MCE: Software-unpoisoned page %#lx\n", pfn);
+		if (remove_hwp_dirty_page(page))
+			goto unlock;
 		atomic_long_sub(nr_pages, &mce_bad_pages);
 		freeit = 1;
 		if (PageHuge(page))
 			clear_page_hwpoison_huge_page(page);
 	}
+unlock:
 	unlock_page(page);
 
 	put_page(page);
diff --git v3.6-rc1.orig/mm/truncate.c v3.6-rc1/mm/truncate.c
index 75801ac..1930b73 100644
--- v3.6-rc1.orig/mm/truncate.c
+++ v3.6-rc1/mm/truncate.c
@@ -217,6 +217,9 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	if (mapping->nrpages == 0)
 		return;
 
+	if (!hwpoison_file_range(mapping, 0, lstart))
+		remove_hwp_dirty_file(mapping->host);
+
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 	end = (lend >> PAGE_CACHE_SHIFT);
 
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
