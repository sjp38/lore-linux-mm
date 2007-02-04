Date: Sun, 4 Feb 2007 17:32:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] mm: PageUptodate memorder problem?
Message-ID: <20070204163207.GA31183@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi,

I think there might be a problem, but don't take this as a final patch
because I can make it nicer if we are agreed there is a problem.

One thing I like about it is that it ties in the anonymous page handling
with the rest of the page management, by marking anon pages as uptodate
when they _are_ uptodate, rather than when our implementation requires
that they be marked as such. Doing this let me get rid of the smp_wmb's
in the page copying functions, which always vaguely troubled me.

Any comments?

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
@@ -127,15 +127,27 @@
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
 #define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
-#ifdef CONFIG_S390
 static inline void SetPageUptodate(struct page *page)
 {
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
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -443,6 +443,7 @@ static int hugetlb_cow(struct mm_struct 
 
 	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
+	SetPageUptodate(new_page);
 	spin_lock(&mm->page_table_lock);
 
 	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
@@ -506,6 +507,7 @@ retry:
 		} else
 			lock_page(page);
 	}
+	SetPageUptodate(page);
 
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
+	SetPageUptodate(new_page);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2097,6 +2096,7 @@ static int do_anonymous_page(struct mm_s
 		page = alloc_zeroed_user_highpage(vma, address);
 		if (!page)
 			goto oom;
+		SetPageUptodate(page);
 
 		entry = mk_pte(page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2203,6 +2203,7 @@ retry:
 			copy_user_highpage(page, new_page, address, vma);
 			page_cache_release(new_page);
 			new_page = page;
+			SetPageUptodate(new_page);
 			anon = 1;
 
 		} else {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -935,6 +935,13 @@ find_page:
 		if (!PageUptodate(page))
 			goto page_not_up_to_date;
 page_ok:
+		/*
+		 * Must ensure that the data we read out of the page is loaded
+		 * _after_ we've loaded page->flags to check for PageUptodate.
+		 * See include/linux/page-flags.h:SetPageUptodate() for the
+		 * other side of the story.
+		 */
+		smp_rmb();
 
 		/* If users can be writing to this page using arbitrary
 		 * virtual addresses, take care about potential aliasing
@@ -1422,6 +1429,11 @@ retry_find:
 
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
@@ -1564,6 +1576,11 @@ retry_find:
 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
