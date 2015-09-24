Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E354582F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:46 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so76436998pac.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b1si18964176pat.4.2015.09.24.07.51.41
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/16] page-flags: introduce page flags policies wrt compound pages
Date: Thu, 24 Sep 2015 17:50:51 +0300
Message-Id: <1443106264-78075-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds a third argument to macros which create function
definitions for page flags.  This argument defines how page-flags helpers
behave on compound functions.

For now we define four policies:

- PF_ANY: the helper function operates on the page it gets, regardless
  if it's non-compound, head or tail.

- PF_HEAD: the helper function operates on the head page of the compound
  page if it gets tail page.

- PF_NO_TAIL: only head and non-compond pages are acceptable for this
  helper function.

- PF_NO_COMPOUND: only non-compound pages are acceptable for this helper
  function.

For now we use policy PF_ANY for all helpers, which matches current
behaviour.

We do not enforce the policy for TESTPAGEFLAG, because we have flags
checked for random pages all over the kernel.  Noticeable exception to
this is PageTransHuge() which triggers VM_BUG_ON() for tail page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 154 ++++++++++++++++++++++++++-------------------
 1 file changed, 90 insertions(+), 64 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 713d3f2c2468..1b3babe5ff69 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -154,49 +154,68 @@ static inline int PageCompound(struct page *page)
 	return test_bit(PG_head, &page->flags) || PageTail(page);
 }
 
+/* Page flags policies wrt compound pages */
+#define PF_ANY(page, enforce)	page
+#define PF_HEAD(page, enforce)	compound_head(page)
+#define PF_NO_TAIL(page, enforce) ({					\
+		if (enforce)						\
+			VM_BUG_ON_PAGE(PageTail(page), page);		\
+		else							\
+			page = compound_head(page);			\
+		page;})
+#define PF_NO_COMPOUND(page, enforce) ({					\
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
@@ -225,46 +244,48 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
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
+TESTPAGEFLAG(Locked, locked, PF_ANY)
+PAGEFLAG(Error, error, PF_ANY) TESTCLEARFLAG(Error, error, PF_ANY)
+PAGEFLAG(Referenced, referenced, PF_ANY) TESTCLEARFLAG(Referenced, referenced, PF_ANY)
+	__SETPAGEFLAG(Referenced, referenced, PF_ANY)
+PAGEFLAG(Dirty, dirty, PF_ANY) TESTSCFLAG(Dirty, dirty, PF_ANY)
+	__CLEARPAGEFLAG(Dirty, dirty, PF_ANY)
+PAGEFLAG(LRU, lru, PF_ANY) __CLEARPAGEFLAG(LRU, lru, PF_ANY)
+PAGEFLAG(Active, active, PF_ANY) __CLEARPAGEFLAG(Active, active, PF_ANY)
+	TESTCLEARFLAG(Active, active, PF_ANY)
+__PAGEFLAG(Slab, slab, PF_ANY)
+PAGEFLAG(Checked, checked, PF_ANY)		/* Used by some filesystems */
+PAGEFLAG(Pinned, pinned, PF_ANY) TESTSCFLAG(Pinned, pinned, PF_ANY)	/* Xen */
+PAGEFLAG(SavePinned, savepinned, PF_ANY);			/* Xen */
+PAGEFLAG(Foreign, foreign, PF_ANY);				/* Xen */
+PAGEFLAG(Reserved, reserved, PF_ANY) __CLEARPAGEFLAG(Reserved, reserved, PF_ANY)
+PAGEFLAG(SwapBacked, swapbacked, PF_ANY)
+	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
+	__SETPAGEFLAG(SwapBacked, swapbacked, PF_ANY)
+
+__PAGEFLAG(SlobFree, slob_free, PF_ANY)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
  * - PG_private and PG_private_2 cause releasepage() and co to be invoked
  */
-PAGEFLAG(Private, private) __SETPAGEFLAG(Private, private)
-	__CLEARPAGEFLAG(Private, private)
-PAGEFLAG(Private2, private_2) TESTSCFLAG(Private2, private_2)
-PAGEFLAG(OwnerPriv1, owner_priv_1) TESTCLEARFLAG(OwnerPriv1, owner_priv_1)
+PAGEFLAG(Private, private, PF_ANY) __SETPAGEFLAG(Private, private, PF_ANY)
+	__CLEARPAGEFLAG(Private, private, PF_ANY)
+PAGEFLAG(Private2, private_2, PF_ANY) TESTSCFLAG(Private2, private_2, PF_ANY)
+PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
+	TESTCLEARFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
 
 /*
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
-PAGEFLAG(MappedToDisk, mappedtodisk)
+TESTPAGEFLAG(Writeback, writeback, PF_ANY) TESTSCFLAG(Writeback, writeback, PF_ANY)
+PAGEFLAG(MappedToDisk, mappedtodisk, PF_ANY)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
-PAGEFLAG(Readahead, reclaim) TESTCLEARFLAG(Readahead, reclaim)
+PAGEFLAG(Reclaim, reclaim, PF_ANY) TESTCLEARFLAG(Reclaim, reclaim, PF_ANY)
+PAGEFLAG(Readahead, reclaim, PF_ANY) TESTCLEARFLAG(Readahead, reclaim, PF_ANY)
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -277,31 +298,32 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache)
+PAGEFLAG(SwapCache, swapcache, PF_ANY)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
 
-PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
-	TESTCLEARFLAG(Unevictable, unevictable)
+PAGEFLAG(Unevictable, unevictable, PF_ANY)
+	__CLEARPAGEFLAG(Unevictable, unevictable, PF_ANY)
+	TESTCLEARFLAG(Unevictable, unevictable, PF_ANY)
 
 #ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked) __CLEARPAGEFLAG(Mlocked, mlocked)
-	TESTSCFLAG(Mlocked, mlocked) __TESTCLEARFLAG(Mlocked, mlocked)
+PAGEFLAG(Mlocked, mlocked, PF_ANY) __CLEARPAGEFLAG(Mlocked, mlocked, PF_ANY)
+	TESTSCFLAG(Mlocked, mlocked, PF_ANY) __TESTCLEARFLAG(Mlocked, mlocked, PF_ANY)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
 	TESTSCFLAG_FALSE(Mlocked) __TESTCLEARFLAG_FALSE(Mlocked)
 #endif
 
 #ifdef CONFIG_ARCH_USES_PG_UNCACHED
-PAGEFLAG(Uncached, uncached)
+PAGEFLAG(Uncached, uncached, PF_ANY)
 #else
 PAGEFLAG_FALSE(Uncached)
 #endif
 
 #ifdef CONFIG_MEMORY_FAILURE
-PAGEFLAG(HWPoison, hwpoison)
-TESTSCFLAG(HWPoison, hwpoison)
+PAGEFLAG(HWPoison, hwpoison, PF_ANY)
+TESTSCFLAG(HWPoison, hwpoison, PF_ANY)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
 #else
 PAGEFLAG_FALSE(HWPoison)
@@ -309,10 +331,10 @@ PAGEFLAG_FALSE(HWPoison)
 #endif
 
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
-TESTPAGEFLAG(Young, young)
-SETPAGEFLAG(Young, young)
-TESTCLEARFLAG(Young, young)
-PAGEFLAG(Idle, idle)
+TESTPAGEFLAG(Young, young, PF_ANY)
+SETPAGEFLAG(Young, young, PF_ANY)
+TESTCLEARFLAG(Young, young, PF_ANY)
+PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
 /*
@@ -393,7 +415,7 @@ static inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &(page)->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate)
+CLEARPAGEFLAG(Uptodate, uptodate, PF_ANY)
 
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
@@ -413,7 +435,7 @@ static inline void set_page_writeback_keepwrite(struct page *page)
 	test_set_page_writeback_keepwrite(page);
 }
 
-__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
+__PAGEFLAG(Head, head, PF_ANY) CLEARPAGEFLAG(Head, head, PF_ANY)
 
 static inline void set_compound_head(struct page *page, struct page *head)
 {
@@ -615,6 +637,10 @@ static inline int page_has_private(struct page *page)
 	return !!(page->flags & PAGE_FLAGS_PRIVATE);
 }
 
+#undef PF_ANY
+#undef PF_HEAD
+#undef PF_NO_TAIL
+#undef PF_NO_COMPOUND
 #endif /* !__GENERATING_BOUNDS_H */
 
 #endif	/* PAGE_FLAGS_H */
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
