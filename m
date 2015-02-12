Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3458C6B0072
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:08 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so12373810pac.7
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:07 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id wa6si5584250pab.88.2015.02.12.08.19.04
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 18/24] thp, mm: split_huge_page(): caller need to lock page
Date: Thu, 12 Feb 2015 18:18:32 +0200
Message-Id: <1423757918-197669-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to use migration entries instead of compound_lock() to
stabilize page refcounts. Setup and remove migration entries require
page to be locked.

Some of split_huge_page() callers already have the page locked. Let's
require everybody to lock the page before calling split_huge_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c    |  1 +
 mm/ksm.c            |  6 ++++--
 mm/memory-failure.c | 12 +++++++++---
 mm/migrate.c        |  8 ++++++--
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fa79d3b89825..bb9be39de242 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1841,6 +1841,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	BUG_ON(is_huge_zero_page(page));
 	BUG_ON(!PageAnon(page));
+	BUG_ON(!PageLocked(page));
 
 	/*
 	 * The caller does not necessarily hold an mmap_sem that would prevent
diff --git a/mm/ksm.c b/mm/ksm.c
index 92182eeba87d..a8a88b0f6f62 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -987,9 +987,11 @@ static int page_trans_compound_anon_split(struct page *page)
 			 * Recheck we got the reference while the head
 			 * was still anonymous.
 			 */
-			if (PageAnon(transhuge_head))
+			if (PageAnon(transhuge_head)) {
+				lock_page(transhuge_head);
 				ret = split_huge_page(transhuge_head);
-			else
+				unlock_page(transhuge_head);
+			} else
 				/*
 				 * Retry later if split_huge_page run
 				 * from under us.
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1a735fad2a13..006a891c9222 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -950,7 +950,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 		 * enough * to be safe.
 		 */
 		if (!PageHuge(hpage) && PageAnon(hpage)) {
-			if (unlikely(split_huge_page(hpage))) {
+			lock_page(hpage);
+			ret = split_huge_page(hpage);
+			unlock_page(hpage);
+			if (unlikely(ret)) {
 				/*
 				 * FIXME: if splitting THP is failed, it is
 				 * better to stop the following operation rather
@@ -1696,10 +1699,13 @@ int soft_offline_page(struct page *page, int flags)
 		return -EBUSY;
 	}
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
+		lock_page(page);
+		ret = split_huge_page(hpage);
+		unlock_page(page);
+		if (unlikely(ret)) {
 			pr_info("soft offline: %#lx: failed to split THP\n",
 				pfn);
-			return -EBUSY;
+			return ret;
 		}
 	}
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 01449826b914..91a67029bb18 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -920,9 +920,13 @@ static int unmap_and_move(new_page_t get_new_page, free_page_t put_new_page,
 		goto out;
 	}
 
-	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page(page)))
+	if (unlikely(PageTransHuge(page))) {
+		lock_page(page);
+		rc = split_huge_page(page);
+		unlock_page(page);
+		if (rc)
 			goto out;
+	}
 
 	rc = __unmap_and_move(page, newpage, force, mode);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
