Date: Tue, 22 Jan 2008 05:01:14 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: fix PageUptodate data race
Message-ID: <20080122040114.GA18450@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

After running SetPageUptodate, preceeding stores to the page contents to
actually bring it uptodate may not be ordered with the store to set the page
uptodate.

Therefore, another CPU which checks PageUptodate is true, then reads the
page contents can get stale data.

Fix this by having an smp_wmb before SetPageUptodate, and smp_rmb after
PageUptodate.

Many places that test PageUptodate, do so with the page locked, and this
would be enough to ensure memory ordering in those places if SetPageUptodate
were only called while the page is locked. Unfortunately that is not always
the case for some filesystems, but it could be an idea for the future.

Also bring the handling of anonymous page uptodateness in line with that of
file backed page management, by marking anon pages as uptodate when they _are_
uptodate, rather than when our implementation requires that they be marked as
such. Doing allows us to get rid of the smp_wmb's in the page copying
functions, which were especially added for anonymous pages for an analogous
memory ordering problem. Both file and anonymous pages are handled with the
same barriers.

FAQ:
Q. Why not do this in flush_dcache_page?
A. Firstly, flush_dcache_page handles only one side (the smb side) of the
ordering protocol; we'd still need smp_rmb somewhere. Secondly, hiding away
memory barriers in a completely unrelated function is nasty; at least in the
PageUptodate macros, they are located together with (half) the operations
involved in the ordering. Thirdly, the smp_wmb is only required when first
bringing the page uptodate, wheras flush_dcache_page should be called each time
it is written to through the kernel mapping. It is logically the wrong place to
put it.

Q. Why does this increase my text size / reduce my performance / etc.
A. Because it is adding the necessary instructions to eliminate the data-race.

Q. Can it be improved?
A. Yes, eg. if you were to create a rule that all SetPageUptodate operations
run under the page lock, we could avoid the smp_rmb places where PageUptodate
is queried under the page lock. Requires audit of all filesystems and at least
some would need reworking. That's great you're interested, I'm eagerly awaiting
your patches.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -68,8 +68,6 @@ static inline void clear_user_highpage(s
 	void *addr = kmap_atomic(page, KM_USER0);
 	clear_user_page(addr, vaddr, page);
 	kunmap_atomic(addr, KM_USER0);
-	/* Make sure this page is cleared on other CPU's too before using it */
-	smp_wmb();
 }
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
@@ -160,8 +158,6 @@ static inline void copy_user_highpage(st
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
@@ -131,16 +131,52 @@
 #define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define TestClearPageReferenced(page) test_and_clear_bit(PG_referenced, &(page)->flags)
 
-#define PageUptodate(page)	test_bit(PG_uptodate, &(page)->flags)
+static inline int PageUptodate(struct page *page)
+{
+	int ret = test_bit(PG_uptodate, &(page)->flags);
+
+	/*
+	 * Must ensure that the data we read out of the page is loaded
+	 * _after_ we've loaded page->flags to check for PageUptodate.
+	 * We can skip the barrier if the page is not uptodate, because
+	 * we wouldn't be reading anything from it.
+	 *
+	 * See SetPageUptodate() for the other side of the story.
+	 */
+	if (ret)
+		smp_rmb();
+
+	return ret;
+}
+
+static inline void __SetPageUptodate(struct page *page)
+{
+	smp_wmb();
+	__set_bit(PG_uptodate, &(page)->flags);
 #ifdef CONFIG_S390
+	page_clear_dirty(page);
+#endif
+}
+
 static inline void SetPageUptodate(struct page *page)
 {
+#ifdef CONFIG_S390
 	if (!test_and_set_bit(PG_uptodate, &page->flags))
 		page_clear_dirty(page);
-}
 #else
-#define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
+	/*
+	 * Memory barrier must be issued before setting the PG_uptodate bit,
+	 * so that all previous stores issued in order to bring the page
+	 * uptodate are actually visible before PageUptodate becomes true.
+	 *
+	 * s390 doesn't need an explicit smp_wmb here because the test and
+	 * set bit already provides full barriers.
+	 */
+	smp_wmb();
+	set_bit(PG_uptodate, &(page)->flags);
 #endif
+}
+
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
 #define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -808,6 +808,7 @@ static int hugetlb_cow(struct mm_struct 
 
 	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address, vma);
+	__SetPageUptodate(new_page);
 	spin_lock(&mm->page_table_lock);
 
 	ptep = huge_pte_offset(mm, address & HPAGE_MASK);
@@ -853,6 +854,7 @@ retry:
 			goto out;
 		}
 		clear_huge_page(page, address);
+		__SetPageUptodate(page);
 
 		if (vma->vm_flags & VM_SHARED) {
 			int err;
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1518,10 +1518,8 @@ static inline void cow_user_page(struct 
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
@@ -1630,6 +1628,7 @@ gotten:
 	if (!new_page)
 		goto oom;
 	cow_user_page(new_page, old_page, address, vma);
+	__SetPageUptodate(new_page);
 
 	/*
 	 * Re-check the pte - we dropped the lock
@@ -2162,6 +2161,7 @@ static int do_anonymous_page(struct mm_s
 	page = alloc_zeroed_user_highpage_movable(vma, address);
 	if (!page)
 		goto oom;
+	__SetPageUptodate(page);
 
 	entry = mk_pte(page, vma->vm_page_prot);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2262,6 +2262,7 @@ static int __do_fault(struct mm_struct *
 				goto out;
 			}
 			copy_user_highpage(page, vmf.page, address, vma);
+			__SetPageUptodate(page);
 		} else {
 			/*
 			 * If the page will be shareable, see if the backing
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -126,7 +126,7 @@ int swap_readpage(struct file *file, str
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
@@ -152,6 +152,7 @@ int add_to_swap(struct page * page, gfp_
 	int err;
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageUptodate(page));
 
 	for (;;) {
 		entry = get_swap_page();
@@ -174,7 +175,6 @@ int add_to_swap(struct page * page, gfp_
 
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
