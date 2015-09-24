Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6C76C82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:53 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so75329002pad.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:53 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id hv2si18966651pbc.2.2015.09.24.07.51.52
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 14/16] page-flags: define PG_uptodate behavior on compound pages
Date: Thu, 24 Sep 2015 17:51:02 +0300
Message-Id: <1443106264-78075-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We use PG_uptodate on head pages on transparent huge page.
Let's use PF_NO_TAIL.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 5e52cc6a27c3..e3ccd95de660 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -392,8 +392,9 @@ u64 stable_page_flags(struct page *page);
 
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
@@ -410,12 +411,14 @@ static inline int PageUptodate(struct page *page)
 
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
@@ -425,7 +428,7 @@ static inline void SetPageUptodate(struct page *page)
 	set_bit(PG_uptodate, &page->flags);
 }
 
-CLEARPAGEFLAG(Uptodate, uptodate, PF_ANY)
+CLEARPAGEFLAG(Uptodate, uptodate, PF_NO_TAIL)
 
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
