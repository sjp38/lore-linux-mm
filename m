Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D231582F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:36 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so76433103pac.2
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id mk6si18954609pab.21.2015.09.24.07.51.30
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags on compound pages
Date: Thu, 24 Sep 2015 17:50:53 +0300
Message-Id: <1443106264-78075-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It seems we don't have compound page on FS/IO path currently.
Use PF_NO_COMPOUND to catch if we have.

The odd exception is PG_dirty: sound uses compound pages and maps them
with PTEs. PF_NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
handling shared fault.  Let's use PF_HEAD for PG_dirty.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 26102813f0ac..63db7483c264 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -245,16 +245,16 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
-PAGEFLAG(Error, error, PF_ANY) TESTCLEARFLAG(Error, error, PF_ANY)
+PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_ANY) TESTCLEARFLAG(Referenced, referenced, PF_ANY)
 	__SETPAGEFLAG(Referenced, referenced, PF_ANY)
-PAGEFLAG(Dirty, dirty, PF_ANY) TESTSCFLAG(Dirty, dirty, PF_ANY)
-	__CLEARPAGEFLAG(Dirty, dirty, PF_ANY)
+PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
+	__CLEARPAGEFLAG(Dirty, dirty, PF_HEAD)
 PAGEFLAG(LRU, lru, PF_ANY) __CLEARPAGEFLAG(LRU, lru, PF_ANY)
 PAGEFLAG(Active, active, PF_ANY) __CLEARPAGEFLAG(Active, active, PF_ANY)
 	TESTCLEARFLAG(Active, active, PF_ANY)
 __PAGEFLAG(Slab, slab, PF_ANY)
-PAGEFLAG(Checked, checked, PF_ANY)		/* Used by some filesystems */
+PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 PAGEFLAG(Pinned, pinned, PF_ANY) TESTSCFLAG(Pinned, pinned, PF_ANY)	/* Xen */
 PAGEFLAG(SavePinned, savepinned, PF_ANY);			/* Xen */
 PAGEFLAG(Foreign, foreign, PF_ANY);				/* Xen */
@@ -280,12 +280,15 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
  */
-TESTPAGEFLAG(Writeback, writeback, PF_ANY) TESTSCFLAG(Writeback, writeback, PF_ANY)
-PAGEFLAG(MappedToDisk, mappedtodisk, PF_ANY)
+TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
+	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
+PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_COMPOUND)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
-PAGEFLAG(Reclaim, reclaim, PF_ANY) TESTCLEARFLAG(Reclaim, reclaim, PF_ANY)
-PAGEFLAG(Readahead, reclaim, PF_ANY) TESTCLEARFLAG(Readahead, reclaim, PF_ANY)
+PAGEFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
+	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
+PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
+	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
 
 #ifdef CONFIG_HIGHMEM
 /*
@@ -401,7 +404,7 @@ static inline int PageUptodate(struct page *page)
 static inline void __SetPageUptodate(struct page *page)
 {
 	smp_wmb();
-	__set_bit(PG_uptodate, &(page)->flags);
+	__set_bit(PG_uptodate, &page->flags);
 }
 
 static inline void SetPageUptodate(struct page *page)
@@ -412,7 +415,7 @@ static inline void SetPageUptodate(struct page *page)
 	 * uptodate are actually visible before PageUptodate becomes true.
 	 */
 	smp_wmb();
-	set_bit(PG_uptodate, &(page)->flags);
+	set_bit(PG_uptodate, &page->flags);
 }
 
 CLEARPAGEFLAG(Uptodate, uptodate, PF_ANY)
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
