Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id B205A900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:08:49 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so59434885obb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:08:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fe5si4251976pdb.39.2015.03.19.10.08.43
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:08:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 14/16] page-flags: define PG_uptodate behavior on compound pages
Date: Thu, 19 Mar 2015 19:08:20 +0200
Message-Id: <1426784902-125149-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We use PG_uptodate on head pages on transparent huge page.
Let's use NO_TAIL.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0b6921d2f2f3..55a69c40e4ae 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -408,8 +408,9 @@ u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
 {
-	int ret = test_bit(PG_uptodate, &(page)->flags);
-
+	int ret;
+	page = compound_head(page);
+	ret = test_bit(PG_uptodate, &(page)->flags);
 	/*
 	 * Must ensure that the data we read out of the page is loaded
 	 * _after_ we've loaded page->flags to check for PageUptodate.
@@ -426,12 +427,14 @@ static inline int PageUptodate(struct page *page)
 
 static inline void __SetPageUptodate(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	smp_wmb();
 	__set_bit(PG_uptodate, &page->flags);
 }
 
 static inline void SetPageUptodate(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	/*
 	 * Memory barrier must be issued before setting the PG_uptodate bit,
 	 * so that all previous stores issued in order to bring the page
@@ -441,7 +444,7 @@ static inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &page->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate, ANY)
+CLEARPAGEFLAG(Uptodate, uptodate, NO_TAIL)
 
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
