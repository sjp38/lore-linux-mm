Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A55B5900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:12:47 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so81230062pab.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:12:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o7si4058225pdp.136.2015.03.19.10.12.46
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:12:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags on compound pages
Date: Thu, 19 Mar 2015 19:08:11 +0200
Message-Id: <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It seems we don't have compound page on FS/IO path currently. Use
NO_COMPOUND to catch if we have.

The odd expection is PG_dirty: sound uses compound pages and maps them
with PTEs. NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
handling shared fault. Let's use HEAD for PG_dirty.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 10bdde20b14c..df2493860821 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -270,16 +270,16 @@ static inline struct page *compound_head_fast(struct page *page)
 }
 
 __PAGEFLAG(Locked, locked, NO_TAIL)
-PAGEFLAG(Error, error, ANY) TESTCLEARFLAG(Error, error, ANY)
+PAGEFLAG(Error, error, NO_COMPOUND) TESTCLEARFLAG(Error, error, NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, ANY) TESTCLEARFLAG(Referenced, referenced, ANY)
 	__SETPAGEFLAG(Referenced, referenced, ANY)
-PAGEFLAG(Dirty, dirty, ANY) TESTSCFLAG(Dirty, dirty, ANY)
-	__CLEARPAGEFLAG(Dirty, dirty, ANY)
+PAGEFLAG(Dirty, dirty, HEAD) TESTSCFLAG(Dirty, dirty, HEAD)
+	__CLEARPAGEFLAG(Dirty, dirty, HEAD)
 PAGEFLAG(LRU, lru, ANY) __CLEARPAGEFLAG(LRU, lru, ANY)
 PAGEFLAG(Active, active, ANY) __CLEARPAGEFLAG(Active, active, ANY)
 	TESTCLEARFLAG(Active, active, ANY)
 __PAGEFLAG(Slab, slab, ANY)
-PAGEFLAG(Checked, checked, ANY)		/* Used by some filesystems */
+PAGEFLAG(Checked, checked, NO_COMPOUND) /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, ANY) TESTSCFLAG(Pinned, pinned, ANY)	/* Xen */
 PAGEFLAG(SavePinned, savepinned, ANY);			/* Xen */
 PAGEFLAG(Foreign, foreign, ANY);				/* Xen */
@@ -305,12 +305,15 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, ANY)
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback, ANY) TESTSCFLAG(Writeback, writeback, ANY)
-PAGEFLAG(MappedToDisk, mappedtodisk, ANY)
+TESTPAGEFLAG(Writeback, writeback, NO_COMPOUND)
+	TESTSCFLAG(Writeback, writeback, NO_COMPOUND)
+PAGEFLAG(MappedToDisk, mappedtodisk, NO_COMPOUND)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim, ANY) TESTCLEARFLAG(Reclaim, reclaim, ANY)
-PAGEFLAG(Readahead, reclaim, ANY) TESTCLEARFLAG(Readahead, reclaim, ANY)
+PAGEFLAG(Reclaim, reclaim, NO_COMPOUND)
+	TESTCLEARFLAG(Reclaim, reclaim, NO_COMPOUND)
+PAGEFLAG(Readahead, reclaim, NO_COMPOUND)
+	TESTCLEARFLAG(Readahead, reclaim, NO_COMPOUND)
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -419,7 +422,7 @@ static inline int PageUptodate(struct page *page)
 static inline void __SetPageUptodate(struct page *page)
 {
 	smp_wmb();
-	__set_bit(PG_uptodate, &(page)->flags);
+	__set_bit(PG_uptodate, &page->flags);
 }
 
 static inline void SetPageUptodate(struct page *page)
@@ -430,7 +433,7 @@ static inline void SetPageUptodate(struct page *page)
 	 * uptodate are actually visible before PageUptodate becomes true.
 	 */
 	smp_wmb();
-	set_bit(PG_uptodate, &(page)->flags);
+	set_bit(PG_uptodate, &page->flags);
 }
 
 CLEARPAGEFLAG(Uptodate, uptodate, ANY)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
