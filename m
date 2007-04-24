Date: Tue, 24 Apr 2007 08:49:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: PageUptodate memorder bug
Message-ID: <20070424064927.GB20640@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Any more thoughts about this pagecache data corruption / kernel data
leak bug? (patch atop rc6-mm1 + my buffered write deadlock queue).

--
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

DMA memory barrier is not required, because the driver / IO subsystem must
bring that into order before telling the core kernel that the read has
completed.

One thing I like about it is that it unifies the anonymous page handling
with the rest of the page management, by marking anon pages as uptodate
when they _are_ uptodate, rather than when our implementation requires
that they be marked as such. Doing this let me get rid of the smp_wmb's
in the page copying functions which, specially added for anonymous pages
for a closely related issue, didn't quite match file backed page handling.

Convert core code to use PageUptodate_NoLock. Filesystems are unaffected
thanks to the change to read_cache_page.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

 fs/splice.c                |    4 +--
 include/linux/highmem.h    |    4 ---
 include/linux/page-flags.h |   57 +++++++++++++++++++++++++++++++++++++++++----
 mm/filemap.c               |   20 +++++++--------
 mm/hugetlb.c               |    2 +
 mm/memory.c                |    9 +++----
 mm/page_io.c               |    2 -
 mm/swap_state.c            |    2 -
 8 files changed, 74 insertions(+), 26 deletions(-)

Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h	2007-04-24 08:53:46.000000000 +1000
+++ linux-2.6/include/linux/highmem.h	2007-04-24 14:15:52.000000000 +1000
@@ -63,8 +63,6 @@
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
@@ -161,8 +159,6 @@
 	copy_user_page(vto, vfrom, vaddr, to);
 	kunmap_atomic(vfrom, KM_USER0);
 	kunmap_atomic(vto, KM_USER1);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #endif
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-04-24 08:53:47.000000000 +1000
+++ linux-2.6/include/linux/page-flags.h	2007-04-24 14:15:52.000000000 +1000
@@ -135,16 +135,65 @@
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
-#define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
-#ifdef CONFIG_S390
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
+{
+	int ret = test_bit(PG_uptodate, &(page)->flags);
+
+	/*
+	 * Must ensure that the data we read out of the page is loaded
+	 * _after_ we've loaded page->flags and found that it is uptodate.
+	 * See SetPageUptodate() for the other side of the story.
+	 */
+	if (ret)
+		smp_rmb();
+
+	return ret;
+}
+
 static inline void SetPageUptodate(struct page *page)
 {
+	WARN_ON(!PageLocked(page));
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
+	 * This memory barrier should not need to provide ordering against
+	 * DMA writes into the page, because the IO completion should really
+	 * be doing that.
+	 */
+	smp_wmb();
+	set_bit(PG_uptodate, &(page)->flags);
 #endif
+}
+
+static inline void __SetPageUptodate(struct page *page)
+{
+	/*
+	 * S390 sets page dirty bit on IO operations, which is why it is
+	 * cleared in SetPageUptodate. This is not an issue for newly
+	 * allocated pages that are brought uptodate by zeroing memory.
+	 */
+	smp_wmb();
+	__set_bit(PG_uptodate, &(page)->flags);
+}
+
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2007-04-24 08:53:50.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2007-04-24 14:15:52.000000000 +1000
@@ -461,6 +461,7 @@
 
 	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
+	__SetPageUptodate(new_page);
 	spin_lock(&mm->page_table_lock);
 
 	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
@@ -524,6 +525,7 @@
 		} else
 			lock_page(page);
 	}
+	__SetPageUptodate(page);
 
 	spin_lock(&mm->page_table_lock);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2007-04-24 08:53:50.000000000 +1000
+++ linux-2.6/mm/memory.c	2007-04-24 14:19:09.000000000 +1000
@@ -1607,10 +1607,8 @@
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
@@ -1722,6 +1720,7 @@
 			goto oom;
 		cow_user_page(new_page, old_page, address, vma);
 	}
+	__SetPageUptodate(new_page);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2256,6 +2255,7 @@
 		page = alloc_zeroed_user_highpage_movable(vma, address);
 		if (!page)
 			goto oom;
+		__SetPageUptodate(page);
 
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2370,6 +2370,7 @@
 				goto out;
 			}
 			copy_user_highpage(page, faulted_page, address, vma);
+			__SetPageUptodate(page);
 		} else {
 			/*
 			 * If the page will be shareable, see if the backing
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-04-24 14:04:29.000000000 +1000
+++ linux-2.6/mm/filemap.c	2007-04-24 14:19:50.000000000 +1000
@@ -953,7 +953,7 @@
 			goto no_cached_page;
 		}
 		readahead_cache_hit(&ra, page);
-		if (!PageUptodate(page))
+		if (!PageUptodate_NoLock(page))
 			goto page_not_up_to_date;
 page_ok:
 
@@ -1021,7 +1021,7 @@
 			goto readpage_error;
 		}
 
-		if (!PageUptodate(page)) {
+		if (!PageUptodate_NoLock(page)) {
 			lock_page(page);
 			if (!PageUptodate(page)) {
 				if (page->mapping == NULL) {
@@ -1636,7 +1636,7 @@
 	if (IS_ERR(page))
 		goto out;
 	mark_page_accessed(page);
-	if (PageUptodate(page))
+	if (PageUptodate_NoLock(page))
 		goto out;
 
 	lock_page(page);
@@ -1683,7 +1683,7 @@
 	if (IS_ERR(page))
 		goto out;
 	wait_on_page_locked(page);
-	if (!PageUptodate(page)) {
+	if (!PageUptodate_NoLock(page)) {
 		page_cache_release(page);
 		page = ERR_PTR(-EIO);
 	}
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c	2007-01-20 11:17:49.000000000 +1100
+++ linux-2.6/mm/page_io.c	2007-04-24 14:15:52.000000000 +1000
@@ -134,7 +134,7 @@
 	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
-	ClearPageUptodate(page);
+	BUG_ON(PageUptodate(page));
 	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
 				end_swap_bio_read);
 	if (bio == NULL) {
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2007-04-24 08:53:51.000000000 +1000
+++ linux-2.6/mm/swap_state.c	2007-04-24 14:15:52.000000000 +1000
@@ -155,6 +155,7 @@
 	delay_swap_prefetch();
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageUptodate(page));
 
 	for (;;) {
 		entry = get_swap_page();
@@ -177,7 +178,6 @@
 
 		switch (err) {
 		case 0:				/* Success */
-			SetPageUptodate(page);
 			SetPageDirty(page);
 			INC_CACHE_INFO(add_total);
 			return 1;
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2007-04-24 14:03:35.000000000 +1000
+++ linux-2.6/fs/splice.c	2007-04-24 14:15:52.000000000 +1000
@@ -107,7 +107,7 @@
 	struct page *page = buf->page;
 	int err;
 
-	if (!PageUptodate(page)) {
+	if (!PageUptodate_NoLock(page)) {
 		lock_page(page);
 
 		/*
@@ -373,7 +373,7 @@
 		/*
 		 * If the page isn't uptodate, we may need to start io on it
 		 */
-		if (!PageUptodate(page)) {
+		if (!PageUptodate_NoLock(page)) {
 			/*
 			 * If in nonblock mode then dont block on waiting
 			 * for an in-flight io page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
