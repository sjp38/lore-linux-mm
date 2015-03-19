Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6FE900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:12:24 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so29364866igb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:12:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ko6si3966559pab.165.2015.03.19.10.12.22
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:12:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/16] page-flags: introduce page flags policies wrt compound pages
Date: Thu, 19 Mar 2015 19:08:09 +0200
Message-Id: <1426784902-125149-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch third argument to macros which create function definitions
for page flags. This arguments defines how page-flags helpers behave
on compound functions.

For now we define four policies:

 - ANY: the helper function operates on the page it gets, regardless if
   it's non-compound, head or tail.

 - HEAD: the helper function operates on the head page of the compound
   page if it gets tail page.

 - NO_TAIL: only head and non-compond pages are acceptable for this
   helper function.

 - NO_COMPOUND: only non-compound pages are acceptable for this helper
   function.

For now we use policy ANY for all helpers, which match current
behaviour.

We do not enforce the policy for TESTPAGEFLAG, because we have flags
checked for random pages all over the kernel. Noticeable exception to
this is PageTransHuge() which triggers VM_BUG_ON() for tail page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h         |  40 ---------
 include/linux/page-flags.h | 198 ++++++++++++++++++++++++++++++---------------
 2 files changed, 134 insertions(+), 104 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fb1fc38b01ce..bcf37dacbee3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -433,46 +433,6 @@ static inline void compound_unlock_irqrestore(struct page *page,
 #endif
 }
 
-static inline struct page *compound_head_by_tail(struct page *tail)
-{
-	struct page *head = tail->first_page;
-
-	/*
-	 * page->first_page may be a dangling pointer to an old
-	 * compound page, so recheck that it is still a tail
-	 * page before returning.
-	 */
-	smp_rmb();
-	if (likely(PageTail(tail)))
-		return head;
-	return tail;
-}
-
-/*
- * Since either compound page could be dismantled asynchronously in THP
- * or we access asynchronously arbitrary positioned struct page, there
- * would be tail flag race. To handle this race, we should call
- * smp_rmb() before checking tail flag. compound_head_by_tail() did it.
- */
-static inline struct page *compound_head(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return compound_head_by_tail(page);
-	return page;
-}
-
-/*
- * If we access compound page synchronously such as access to
- * allocated page, there is no need to handle tail flag race, so we can
- * check tail flag directly without any synchronization primitive.
- */
-static inline struct page *compound_head_fast(struct page *page)
-{
-	if (unlikely(PageTail(page)))
-		return page->first_page;
-	return page;
-}
-
 /*
  * The atomic page->_mapcount, starts from -1: so that transitions
  * both from it and to it can be tracked, using atomic_inc_and_test
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 327aabd9792e..32ea62c0ad30 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -134,49 +134,68 @@ enum pageflags {
 
 #ifndef __GENERATING_BOUNDS_H
 
+/* Page flags policies wrt compound pages */
+#define ANY(page, enforce)	page
+#define HEAD(page, enforce)	compound_head(page)
+#define NO_TAIL(page, enforce) ({					\
+		if (enforce)						\
+			VM_BUG_ON_PAGE(PageTail(page), page);		\
+		else							\
+			page = compound_head(page);			\
+		page;})
+#define NO_COMPOUND(page, enforce) ({					\
+		if (enforce)						\
+			VM_BUG_ON_PAGE(PageCompound(page), page);	\
+		page;})
+
 /*
  * Macros to create function definitions for page flags
  */
-#define TESTPAGEFLAG(uname, lname)					\
-static inline int Page##uname(const struct page *page)			\
-			{ return test_bit(PG_##lname, &page->flags); }
+#define TESTPAGEFLAG(uname, lname, policy)				\
+static inline int Page##uname(struct page *page)			\
+	{ return test_bit(PG_##lname, &policy(page, 0)->flags); }
 
-#define SETPAGEFLAG(uname, lname)					\
+#define SETPAGEFLAG(uname, lname, policy)				\
 static inline void SetPage##uname(struct page *page)			\
-			{ set_bit(PG_##lname, &page->flags); }
+	{ set_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define CLEARPAGEFLAG(uname, lname)					\
+#define CLEARPAGEFLAG(uname, lname, policy)				\
 static inline void ClearPage##uname(struct page *page)			\
-			{ clear_bit(PG_##lname, &page->flags); }
+	{ clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define __SETPAGEFLAG(uname, lname)					\
+#define __SETPAGEFLAG(uname, lname, policy)				\
 static inline void __SetPage##uname(struct page *page)			\
-			{ __set_bit(PG_##lname, &page->flags); }
+	{ __set_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define __CLEARPAGEFLAG(uname, lname)					\
+#define __CLEARPAGEFLAG(uname, lname, policy)				\
 static inline void __ClearPage##uname(struct page *page)		\
-			{ __clear_bit(PG_##lname, &page->flags); }
+	{ __clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define TESTSETFLAG(uname, lname)					\
+#define TESTSETFLAG(uname, lname, policy)				\
 static inline int TestSetPage##uname(struct page *page)			\
-		{ return test_and_set_bit(PG_##lname, &page->flags); }
+	{ return test_and_set_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define TESTCLEARFLAG(uname, lname)					\
+#define TESTCLEARFLAG(uname, lname, policy)				\
 static inline int TestClearPage##uname(struct page *page)		\
-		{ return test_and_clear_bit(PG_##lname, &page->flags); }
+	{ return test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define __TESTCLEARFLAG(uname, lname)					\
+#define __TESTCLEARFLAG(uname, lname, policy)				\
 static inline int __TestClearPage##uname(struct page *page)		\
-		{ return __test_and_clear_bit(PG_##lname, &page->flags); }
+	{ return __test_and_clear_bit(PG_##lname, &policy(page, 1)->flags); }
 
-#define PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
-	SETPAGEFLAG(uname, lname) CLEARPAGEFLAG(uname, lname)
+#define PAGEFLAG(uname, lname, policy)					\
+	TESTPAGEFLAG(uname, lname, policy)				\
+	SETPAGEFLAG(uname, lname, policy)				\
+	CLEARPAGEFLAG(uname, lname, policy)
 
-#define __PAGEFLAG(uname, lname) TESTPAGEFLAG(uname, lname)		\
-	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
+#define __PAGEFLAG(uname, lname, policy)				\
+	TESTPAGEFLAG(uname, lname, policy)				\
+	__SETPAGEFLAG(uname, lname, policy)				\
+	__CLEARPAGEFLAG(uname, lname, policy)
 
-#define TESTSCFLAG(uname, lname)					\
-	TESTSETFLAG(uname, lname) TESTCLEARFLAG(uname, lname)
+#define TESTSCFLAG(uname, lname, policy)				\
+	TESTSETFLAG(uname, lname, policy)				\
+	TESTCLEARFLAG(uname, lname, policy)
 
 #define TESTPAGEFLAG_FALSE(uname)					\
 static inline int Page##uname(const struct page *page) { return 0; }
@@ -205,47 +224,93 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-struct page;	/* forward declaration */
-
-TESTPAGEFLAG(Locked, locked)
-PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
-PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
-	__SETPAGEFLAG(Referenced, referenced)
-PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
-PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
-PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
-	TESTCLEARFLAG(Active, active)
-__PAGEFLAG(Slab, slab)
-PAGEFLAG(Checked, checked)		/* Used by some filesystems */
-PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
-PAGEFLAG(SavePinned, savepinned);			/* Xen */
-PAGEFLAG(Foreign, foreign);				/* Xen */
-PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
-PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
-	__SETPAGEFLAG(SwapBacked, swapbacked)
-
-__PAGEFLAG(SlobFree, slob_free)
+/* Forward declarations */
+struct page;
+static inline int PageCompound(struct page *page);
+static inline int PageTail(struct page *page);
+
+static inline struct page *compound_head_by_tail(struct page *tail)
+{
+	struct page *head = tail->first_page;
+
+	/*
+	 * page->first_page may be a dangling pointer to an old
+	 * compound page, so recheck that it is still a tail
+	 * page before returning.
+	 */
+	smp_rmb();
+	if (likely(PageTail(tail)))
+		return head;
+	return tail;
+}
+
+/*
+ * Since either compound page could be dismantled asynchronously in THP
+ * or we access asynchronously arbitrary positioned struct page, there
+ * would be tail flag race. To handle this race, we should call
+ * smp_rmb() before checking tail flag. compound_head_by_tail() did it.
+ */
+static inline struct page *compound_head(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return compound_head_by_tail(page);
+	return page;
+}
+
+/*
+ * If we access compound page synchronously such as access to
+ * allocated page, there is no need to handle tail flag race, so we can
+ * check tail flag directly without any synchronization primitive.
+ */
+static inline struct page *compound_head_fast(struct page *page)
+{
+	if (unlikely(PageTail(page)))
+		return page->first_page;
+	return page;
+}
+
+TESTPAGEFLAG(Locked, locked, ANY)
+PAGEFLAG(Error, error, ANY) TESTCLEARFLAG(Error, error, ANY)
+PAGEFLAG(Referenced, referenced, ANY) TESTCLEARFLAG(Referenced, referenced, ANY)
+	__SETPAGEFLAG(Referenced, referenced, ANY)
+PAGEFLAG(Dirty, dirty, ANY) TESTSCFLAG(Dirty, dirty, ANY)
+	__CLEARPAGEFLAG(Dirty, dirty, ANY)
+PAGEFLAG(LRU, lru, ANY) __CLEARPAGEFLAG(LRU, lru, ANY)
+PAGEFLAG(Active, active, ANY) __CLEARPAGEFLAG(Active, active, ANY)
+	TESTCLEARFLAG(Active, active, ANY)
+__PAGEFLAG(Slab, slab, ANY)
+PAGEFLAG(Checked, checked, ANY)		/* Used by some filesystems */
+PAGEFLAG(Pinned, pinned, ANY) TESTSCFLAG(Pinned, pinned, ANY)	/* Xen */
+PAGEFLAG(SavePinned, savepinned, ANY);			/* Xen */
+PAGEFLAG(Foreign, foreign, ANY);				/* Xen */
+PAGEFLAG(Reserved, reserved, ANY) __CLEARPAGEFLAG(Reserved, reserved, ANY)
+PAGEFLAG(SwapBacked, swapbacked, ANY)
+	__CLEARPAGEFLAG(SwapBacked, swapbacked, ANY)
+	__SETPAGEFLAG(SwapBacked, swapbacked, ANY)
+
+__PAGEFLAG(SlobFree, slob_free, ANY)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
  * - PG_private and PG_private_2 cause releasepage() and co to be invoked
  */
-PAGEFLAG(Private, private) __SETPAGEFLAG(Private, private)
-	__CLEARPAGEFLAG(Private, private)
-PAGEFLAG(Private2, private_2) TESTSCFLAG(Private2, private_2)
-PAGEFLAG(OwnerPriv1, owner_priv_1) TESTCLEARFLAG(OwnerPriv1, owner_priv_1)
+PAGEFLAG(Private, private, ANY) __SETPAGEFLAG(Private, private, ANY)
+	__CLEARPAGEFLAG(Private, private, ANY)
+PAGEFLAG(Private2, private_2, ANY) TESTSCFLAG(Private2, private_2, ANY)
+PAGEFLAG(OwnerPriv1, owner_priv_1, ANY)
+	TESTCLEARFLAG(OwnerPriv1, owner_priv_1, ANY)
 
 /*
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
-PAGEFLAG(MappedToDisk, mappedtodisk)
+TESTPAGEFLAG(Writeback, writeback, ANY) TESTSCFLAG(Writeback, writeback, ANY)
+PAGEFLAG(MappedToDisk, mappedtodisk, ANY)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
-PAGEFLAG(Readahead, reclaim) TESTCLEARFLAG(Readahead, reclaim)
+PAGEFLAG(Reclaim, reclaim, ANY) TESTCLEARFLAG(Reclaim, reclaim, ANY)
+PAGEFLAG(Readahead, reclaim, ANY) TESTCLEARFLAG(Readahead, reclaim, ANY)
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -258,31 +323,32 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache)
+PAGEFLAG(SwapCache, swapcache, ANY)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
-PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
-	TESTCLEARFLAG(Unevictable, unevictable)
+PAGEFLAG(Unevictable, unevictable, ANY)
+	__CLEARPAGEFLAG(Unevictable, unevictable, ANY)
+	TESTCLEARFLAG(Unevictable, unevictable, ANY)
 
 #ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
-	TESTSCFLAG(Mlocked, mlocked) __TESTCLEARFLAG(Mlocked, mlocked)
+PAGEFLAG(Mlocked, mlocked, ANY) __CLEARPAGEFLAG(Mlocked, mlocked, ANY)
+	TESTSCFLAG(Mlocked, mlocked, ANY) __TESTCLEARFLAG(Mlocked, mlocked, ANY)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
 	TESTSCFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
 #endif
 
 #ifdef CONFIG_ARCH_USES_PG_UNCACHED
-PAGEFLAG(Uncached, uncached)
+PAGEFLAG(Uncached, uncached, ANY)
 #else
 PAGEFLAG_FALSE(Uncached)
 #endif
 
 #ifdef CONFIG_MEMORY_FAILURE
-PAGEFLAG(HWPoison, hwpoison)
-TESTSCFLAG(HWPoison, hwpoison)
+PAGEFLAG(HWPoison, hwpoison, ANY)
+TESTSCFLAG(HWPoison, hwpoison, ANY)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
 #else
 PAGEFLAG_FALSE(HWPoison)
@@ -367,7 +433,7 @@ static inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &(page)->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate)
+CLEARPAGEFLAG(Uptodate, uptodate, ANY)
 
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
@@ -396,8 +462,8 @@ static inline void set_page_writeback_keepwrite(struct page *page)
  * and arch/powerpc/kvm/book3s_64_vio_hv.c which use it to detect huge pages
  * and avoid handling those in real mode.
  */
-__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
-__PAGEFLAG(Tail, tail)
+__PAGEFLAG(Head, head, ANY) CLEARPAGEFLAG(Head, head, ANY)
+__PAGEFLAG(Tail, tail, ANY)
 
 static inline int PageCompound(struct page *page)
 {
@@ -421,8 +487,8 @@ static inline void ClearPageCompound(struct page *page)
  * because PageCompound is always set for compound pages and not for
  * pages on the LRU and/or pagecache.
  */
-TESTPAGEFLAG(Compound, compound)
-__SETPAGEFLAG(Head, compound)  __CLEARPAGEFLAG(Head, compound)
+TESTPAGEFLAG(Compound, compound, ANY)
+__SETPAGEFLAG(Head, compound, ANY)  __CLEARPAGEFLAG(Head, compound, ANY)
 
 /*
  * PG_reclaim is used in combination with PG_compound to mark the
@@ -636,6 +702,10 @@ static inline int page_has_private(struct page *page)
 	return !!(page->flags & PAGE_FLAGS_PRIVATE);
 }
 
+#undef ANY
+#undef HEAD
+#undef NO_TAIL
+#undef NO_COMPOUND
 #endif /* !__GENERATING_BOUNDS_H */
 
 #endif	/* PAGE_FLAGS_H */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
