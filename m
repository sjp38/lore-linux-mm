Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF0DE6B000C
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 2so5910968pft.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y10-v6si7320346pll.354.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/8] mm: Rename PF_NO_TAIL to PF_TAIL_READ
Date: Fri, 13 Apr 2018 21:31:39 -0700
Message-Id: <20180414043145.3953-3-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Both by the comments and the implementation, you are allowed to test
the flags of tail pages, but not set or clear the flags of tail pages.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/page-flags.h | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 593a5505bbb4..8588c4628a7d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -178,7 +178,7 @@ static inline int PagePoisoned(const struct page *page)
  * PF_ONLY_HEAD:
  *     for compound page, callers only ever operate on the head page.
  *
- * PF_NO_TAIL:
+ * PF_TAIL_READ:
  *     modifications of the page flag must be done on small or head pages,
  *     checks can be done on tail pages too.
  *
@@ -193,7 +193,7 @@ static inline int PagePoisoned(const struct page *page)
 #define PF_ONLY_HEAD(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
 		PF_POISONED_CHECK(page); })
-#define PF_NO_TAIL(page, modify) ({					\
+#define PF_TAIL_READ(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);	\
 		PF_POISONED_CHECK(compound_head(page)); })
 #define PF_NO_COMPOUND(page, modify) ({				\
@@ -269,7 +269,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
+__PAGEFLAG(Locked, locked, PF_TAIL_READ)
 PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters, PF_ONLY_HEAD)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
@@ -280,8 +280,8 @@ PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
 PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
 PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
-__PAGEFLAG(Slab, slab, PF_NO_TAIL)
-__PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
+__PAGEFLAG(Slab, slab, PF_TAIL_READ)
+__PAGEFLAG(SlobFree, slob_free, PF_TAIL_READ)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 
 /* Xen */
@@ -292,9 +292,9 @@ PAGEFLAG(Foreign, foreign, PF_NO_COMPOUND);
 
 PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
 	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
-PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
-	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
-	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
+PAGEFLAG(SwapBacked, swapbacked, PF_TAIL_READ)
+	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_TAIL_READ)
+	__SETPAGEFLAG(SwapBacked, swapbacked, PF_TAIL_READ)
 
 /*
  * Private page markings that may be used by the filesystem that owns the page
@@ -311,13 +311,13 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback, PF_NO_TAIL)
-	TESTSCFLAG(Writeback, writeback, PF_NO_TAIL)
-PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
+TESTPAGEFLAG(Writeback, writeback, PF_TAIL_READ)
+	TESTSCFLAG(Writeback, writeback, PF_TAIL_READ)
+PAGEFLAG(MappedToDisk, mappedtodisk, PF_TAIL_READ)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
-	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
+PAGEFLAG(Reclaim, reclaim, PF_TAIL_READ)
+	TESTCLEARFLAG(Reclaim, reclaim, PF_TAIL_READ)
 PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 
@@ -340,8 +340,8 @@ static __always_inline int PageSwapCache(struct page *page)
 	return PageSwapBacked(page) && test_bit(PG_swapcache, &page->flags);
 
 }
-SETPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
-CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
+SETPAGEFLAG(SwapCache, swapcache, PF_TAIL_READ)
+CLEARPAGEFLAG(SwapCache, swapcache, PF_TAIL_READ)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
@@ -351,9 +351,9 @@ PAGEFLAG(Unevictable, unevictable, PF_HEAD)
 	TESTCLEARFLAG(Unevictable, unevictable, PF_HEAD)
 
 #ifdef CONFIG_MMU
-PAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
-	__CLEARPAGEFLAG(Mlocked, mlocked, PF_NO_TAIL)
-	TESTSCFLAG(Mlocked, mlocked, PF_NO_TAIL)
+PAGEFLAG(Mlocked, mlocked, PF_TAIL_READ)
+	__CLEARPAGEFLAG(Mlocked, mlocked, PF_TAIL_READ)
+	TESTSCFLAG(Mlocked, mlocked, PF_TAIL_READ)
 #else
 PAGEFLAG_FALSE(Mlocked) __CLEARPAGEFLAG_NOOP(Mlocked)
 	TESTSCFLAG_FALSE(Mlocked)
@@ -477,7 +477,7 @@ static __always_inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &page->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate, PF_NO_TAIL)
+CLEARPAGEFLAG(Uptodate, uptodate, PF_TAIL_READ)
 
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
@@ -763,7 +763,7 @@ static inline int page_has_private(struct page *page)
 #undef PF_ANY
 #undef PF_HEAD
 #undef PF_ONLY_HEAD
-#undef PF_NO_TAIL
+#undef PF_TAIL_READ
 #undef PF_NO_COMPOUND
 #endif /* !__GENERATING_BOUNDS_H */
 
-- 
2.16.3
