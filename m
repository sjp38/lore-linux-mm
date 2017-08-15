Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B35F56B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:52:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c2so59874267qkb.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id e4si7618194qkf.364.2017.08.14.18.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:52:42 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 1/4] mm: madvise: read loop's step size beforehand in madvise_inject_error(), prepare for THP support.
Date: Mon, 14 Aug 2017 21:52:13 -0400
Message-Id: <20170815015216.31827-2-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-1-zi.yan@sent.com>
References: <20170815015216.31827-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

The loop in madvise_inject_error() reads its step size from a page
after it is soft-offlined. It works because the page is:
1) a hugetlb page: the page size does not change;
2) a base page: the page size does not change;
3) a THP: soft-offline always splits THPs, thus, it is OK to use
   PAGE_SIZE as step size.

It will be a problem when soft-offline supports THP migrations.
When a THP is migrated without split during soft-offlining, the THP
is split after migration, thus, before and after soft-offlining page
sizes do not match. This causes a THP to be unnecessarily soft-lined,
at most, 511 times, wasting free space.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/madvise.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 47d8d8a25eae..49f6774db259 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -612,19 +612,22 @@ static long madvise_remove(struct vm_area_struct *vma,
 static int madvise_inject_error(int behavior,
 		unsigned long start, unsigned long end)
 {
-	struct page *page;
+	struct page *page = NULL;
+	unsigned long page_size = PAGE_SIZE;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	for (; start < end; start += PAGE_SIZE <<
-				compound_order(compound_head(page))) {
+	for (; start < end; start += page_size) {
 		int ret;
 
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
 
+		page_size = (PAGE_SIZE << compound_order(compound_head(page))) -
+			(PAGE_SIZE * (page - compound_head(page)));
+
 		if (PageHWPoison(page)) {
 			put_page(page);
 			continue;
@@ -637,6 +640,12 @@ static int madvise_inject_error(int behavior,
 			ret = soft_offline_page(page, MF_COUNT_INCREASED);
 			if (ret)
 				return ret;
+			/*
+			 * Non hugetlb pages either have PAGE_SIZE
+			 * or are split into PAGE_SIZE
+			 */
+			if (!PageHuge(page))
+				page_size = PAGE_SIZE;
 			continue;
 		}
 		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
@@ -645,6 +654,12 @@ static int madvise_inject_error(int behavior,
 		ret = memory_failure(page_to_pfn(page), 0, MF_COUNT_INCREASED);
 		if (ret)
 			return ret;
+		/*
+		 * Non hugetlb pages either have PAGE_SIZE
+		 * or are split into PAGE_SIZE
+		 */
+		if (!PageHuge(page))
+			page_size = PAGE_SIZE;
 	}
 	return 0;
 }
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
