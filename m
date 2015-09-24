Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D76BA82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:48 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so8616039pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id kg10si18899216pad.154.2015.09.24.07.51.45
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 02/16] page-flags: move code around
Date: Thu, 24 Sep 2015 17:50:50 +0300
Message-Id: <1443106264-78075-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The preparation patch: we are going to use compound_head(), PageTail()
and PageCompound() to define page-flags helpers.

Let's define them before macros.

We cannot user PageHead() helper in PageCompound() as it's not yet
defined -- use test_bit(PG_head, &page->flags) instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 41 +++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 815246a80e2d..713d3f2c2468 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -133,6 +133,27 @@ enum pageflags {
 
 #ifndef __GENERATING_BOUNDS_H
 
+struct page;	/* forward declaration */
+
+static inline struct page *compound_head(struct page *page)
+{
+	unsigned long head = READ_ONCE(page->compound_head);
+
+	if (unlikely(head & 1))
+		return (struct page *) (head - 1);
+	return page;
+}
+
+static inline int PageTail(struct page *page)
+{
+	return READ_ONCE(page->compound_head) & 1;
+}
+
+static inline int PageCompound(struct page *page)
+{
+	return test_bit(PG_head, &page->flags) || PageTail(page);
+}
+
 /*
  * Macros to create function definitions for page flags
  */
@@ -204,7 +225,6 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
-struct page;	/* forward declaration */
 
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
@@ -395,11 +415,6 @@ static inline void set_page_writeback_keepwrite(struct page *page)
 
 __PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
 
-static inline int PageTail(struct page *page)
-{
-	return READ_ONCE(page->compound_head) & 1;
-}
-
 static inline void set_compound_head(struct page *page, struct page *head)
 {
 	WRITE_ONCE(page->compound_head, (unsigned long)head + 1);
@@ -410,20 +425,6 @@ static inline void clear_compound_head(struct page *page)
 	WRITE_ONCE(page->compound_head, 0);
 }
 
-static inline struct page *compound_head(struct page *page)
-{
-	unsigned long head = READ_ONCE(page->compound_head);
-
-	if (unlikely(head & 1))
-		return (struct page *) (head - 1);
-	return page;
-}
-
-static inline int PageCompound(struct page *page)
-{
-	return PageHead(page) || PageTail(page);
-
-}
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline void ClearPageCompound(struct page *page)
 {
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
