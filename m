From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070206054935.21042.13541.sendpatchset@linux.site>
In-Reply-To: <20070206054925.21042.50546.sendpatchset@linux.site>
References: <20070206054925.21042.50546.sendpatchset@linux.site>
Subject: [patch 1/3] mm: fix PageUptodate memorder
Date: Tue,  6 Feb 2007 09:02:11 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After running SetPageUptodate, preceeding stores to the page contents to
actually bring it uptodate may not be ordered with the store to set the page
uptodate.

Therefore, another CPU which checks PageUptodate is true, then reads the
page contents can get stale data.

Fix this by ensuring SetPageUptodate is always called with the page locked
(except in the case of a new page that cannot be visible to other CPUs), and
requiring PageUptodate be checked only when the page is locked.

To facilitate lockless checks, SetPageUptodate contains an smp_wmb to order
preceeding stores before the store to page flags, and a new PageUptodate_NoLock
is introduced, which issues a smp_rmb after the page flags are loaded for the
test.

I'm still not sure that a DMA memory barrier is not required, however I think
the logical place to put such a barrier would be in the IO completion routines,
when they come back to tell us that they have succeeded. (Help? Anyone?)

One thing I like about it is that it unifies the anonymous page handling
with the rest of the page management, by marking anon pages as uptodate
when they _are_ uptodate, rather than when our implementation requires
that they be marked as such. Doing this let me get rid of the smp_wmb's
in the page copying functions, which were specially added for anonymous
pages for a closely related issue, always vaguely troubled me.

Convert core code and some filesystems to use PageUptodate_NoLock, just for
reference (a more complete patch follows).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -57,8 +57,6 @@ static inline void clear_user_highpage(s
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
@@ -108,8 +106,6 @@ static inline void copy_user_highpage(st
 	copy_user_page(vto, vfrom, vaddr, to);
 	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #endif
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -126,16 +126,62 @@
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
-#define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
-#ifdef CONFIG_S390
-static inline void SetPageUptodate(struct page *page)
+static inline int PageUptodate(struct page *page)
+{
+	WARN_ON(!PageLocked(page));
+	return test_bit(PG_uptodate, &(page)->flags);
+}
+
+/*
+ * PageUptodate to be used when not holding the page lock.
+ */
+static inline int PageUptodate_NoLock(struct page *page)
 {
+	int ret = test_bit(PG_uptodate, &(page)->flags);
+
+	/*
+	 * Must ensure that the data we read out of the page is loaded
+	 * _after_ we've loaded page->flags to check for PageUptodate.
+	 * See SetPageUptodate() for the other side of the story.
+	 */
+	smp_rmb();
+
+	return ret;
+}
+
+static inline void __SetPageUptodate(struct page *page)
+{
+#ifdef CONFIG_S390
 	if (!test_and_set_bit(PG_uptodate, &page->flags))
 		page_test_and_clear_dirty(page);
-}
 #else
-#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
+	/*
+	 * Memory barrier must be issued before setting the PG_uptodate bit,
+	 * so all previous writes that served to bring the page uptodate are
+	 * visible before PageUptodate becomes true.
+	 *
+	 * S390 is guaranteed to have a barrier in the test_and_set operation
+	 * (see Documentation/atomic_ops.txt).
+	 *
+	 * XXX: does this memory barrier need to be anything special to
+	 * handle things like DMA writes into the page?
+	 */
+	smp_wmb();
+	set_bit(PG_uptodate, &(page)->flags);
 #endif
+}
+
+static inline void SetPageUptodate(struct page *page)
+{
+	WARN_ON(!PageLocked(page));
+	__SetPageUptodate(page);
+}
+
+static inline void SetNewPageUptodate(struct page *page)
+{
+	__SetPageUptodate(page);
+}
+
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -443,6 +443,7 @@ static int hugetlb_cow(struct mm_struct 
 
 	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
+	SetNewPageUptodate(new_page);
 	spin_lock(&mm->page_table_lock);
 
 	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
@@ -506,6 +507,7 @@ retry:
 		} else
 			lock_page(page);
 	}
+	SetNewPageUptodate(page);
 
 	spin_lock(&mm->page_table_lock);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1463,10 +1463,8 @@ static inline void cow_user_page(struct 
 			memset(kaddr, 0, PAGE_SIZE);
 		kunmap_atomic(kaddr, KM_USER0);
 		flush_dcache_page(dst);
-		return;
-
-	}
-	copy_user_highpage(dst, src, va, vma);
+	} else
+		copy_user_highpage(dst, src, va, vma);
 }
 
 /*
@@ -1579,6 +1577,7 @@ gotten:
 			goto oom;
 		cow_user_page(new_page, old_page, address, vma);
 	}
+	SetNewPageUptodate(new_page);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2097,6 +2096,7 @@ static int do_anonymous_page(struct mm_s
 		page = alloc_zeroed_user_highpage(vma, address);
 		if (!page)
 			goto oom;
+		SetNewPageUptodate(page);
 
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2203,6 +2203,7 @@ retry:
 			copy_user_highpage(page, new_page, address, vma);
 			page_cache_release(new_page);
 			new_page = page;
+			SetNewPageUptodate(new_page);
 			anon = 1;
 
 		} else {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -932,7 +932,7 @@ find_page:
 			handle_ra_miss(mapping, &ra, index);
 			goto no_cached_page;
 		}
-		if (!PageUptodate(page))
+		if (!PageUptodate_NoLock(page))
 			goto page_not_up_to_date;
 page_ok:
 
@@ -1000,7 +1000,7 @@ readpage:
 			goto readpage_error;
 		}
 
-		if (!PageUptodate(page)) {
+		if (!PageUptodate_NoLock(page)) {
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				if (page->mapping == NULL) {
@@ -1417,11 +1417,16 @@ retry_find:
 	 * Ok, found a page in the page cache, now we need to check
 	 * that it's up-to-date.
 	 */
-	if (!PageUptodate(page))
+	if (!PageUptodate_NoLock(page))
 		goto page_not_uptodate;
 
 success:
 	/*
+	 * Must order memory for the same reason as do_generic_mapping_read
+	 */
+	smp_rmb();
+
+	/*
 	 * Found the page and have a reference on it.
 	 */
 	mark_page_accessed(page);
@@ -1484,7 +1489,7 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate_NoLock(page))
 			goto success;
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
@@ -1515,7 +1520,7 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate_NoLock(page))
 			goto success;
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
@@ -1554,7 +1559,7 @@ retry_find:
 	 * Ok, found a page in the page cache, now we need to check
 	 * that it's up-to-date.
 	 */
-	if (!PageUptodate(page)) {
+	if (!PageUptodate_NoLock(page)) {
 		if (nonblock) {
 			page_cache_release(page);
 			return NULL;
@@ -1564,6 +1569,11 @@ retry_find:
 
 success:
 	/*
+	 * Must order memory for the same reason as do_generic_mapping_read
+	 */
+	smp_rmb();
+
+	/*
 	 * Found the page and have a reference on it.
 	 */
 	mark_page_accessed(page);
@@ -1605,7 +1615,7 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate_NoLock(page))
 			goto success;
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
@@ -1635,7 +1645,7 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (PageUptodate(page))
+		if (PageUptodate_NoLock(page))
 			goto success;
 	} else if (error == AOP_TRUNCATED_PAGE) {
 		page_cache_release(page);
@@ -1806,7 +1816,7 @@ retry:
 	if (IS_ERR(page))
 		goto out;
 	mark_page_accessed(page);
-	if (PageUptodate(page))
+	if (PageUptodate_NoLock(page))
 		goto out;
 
 	lock_page(page);
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -134,7 +134,7 @@ int swap_readpage(struct file *file, str
 	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
-	ClearPageUptodate(page);
+	BUG_ON(PageUptodate(page));
 	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
 				end_swap_bio_read);
 	if (bio == NULL) {
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -149,6 +149,7 @@ int add_to_swap(struct page * page, gfp_
 	int err;
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageUptodate(page));
 
 	for (;;) {
 		entry = get_swap_page();
@@ -171,7 +172,6 @@ int add_to_swap(struct page * page, gfp_
 
 		switch (err) {
 		case 0:				/* Success */
-			SetPageUptodate(page);
 			SetPageDirty(page);
 			INC_CACHE_INFO(add_total);
 			return 1;
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -107,7 +107,7 @@ static int page_cache_pipe_buf_pin(struc
 	struct page *page = buf->page;
 	int err;
 
-	if (!PageUptodate(page)) {
+	if (!PageUptodate_NoLock(page)) {
 		lock_page(page);
 
 		/*
@@ -373,7 +373,7 @@ __generic_file_splice_read(struct file *
 		/*
 		 * If the page isn't uptodate, we may need to start io on it
 		 */
-		if (!PageUptodate(page)) {
+		if (!PageUptodate_NoLock(page)) {
 			/*
 			 * If in nonblock mode then dont block on waiting
 			 * for an in-flight io page
Index: linux-2.6/fs/ext2/dir.c
===================================================================
--- linux-2.6.orig/fs/ext2/dir.c
+++ linux-2.6/fs/ext2/dir.c
@@ -163,7 +163,7 @@ static struct page * ext2_get_page(struc
 	if (!IS_ERR(page)) {
 		wait_on_page_locked(page);
 		kmap(page);
-		if (!PageUptodate(page))
+		if (!PageUptodate_NoLock(page))
 			goto fail;
 		if (!PageChecked(page))
 			ext2_check_page(page);
Index: linux-2.6/fs/namei.c
===================================================================
--- linux-2.6.orig/fs/namei.c
+++ linux-2.6/fs/namei.c
@@ -2641,7 +2641,7 @@ static char *page_getlink(struct dentry 
 	if (IS_ERR(page))
 		goto sync_fail;
 	wait_on_page_locked(page);
-	if (!PageUptodate(page))
+	if (!PageUptodate_NoLock(page))
 		goto async_fail;
 	*ppage = page;
 	return kmap(page);
Index: linux-2.6/fs/partitions/check.c
===================================================================
--- linux-2.6.orig/fs/partitions/check.c
+++ linux-2.6/fs/partitions/check.c
@@ -562,7 +562,7 @@ unsigned char *read_dev_sector(struct bl
 				 NULL);
 	if (!IS_ERR(page)) {
 		wait_on_page_locked(page);
-		if (!PageUptodate(page))
+		if (!PageUptodate_NoLock(page))
 			goto fail;
 		if (PageError(page))
 			goto fail;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
