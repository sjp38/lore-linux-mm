Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id CE0CC6B008C
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:34:07 -0500 (EST)
Received: by pdjg10 with SMTP id g10so58719652pdj.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:34:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id zc6si5801486pac.65.2015.03.04.08.34.00
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 08:34:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 18/24] thp, mm: split_huge_page(): caller need to lock page
Date: Wed,  4 Mar 2015 18:33:06 +0200
Message-Id: <1425486792-93161-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 3741f81e423e..f1d88b9059e2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1846,6 +1846,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
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
index d487f8dc6d39..74c5aaddae85 100644
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
@@ -1694,10 +1697,13 @@ int soft_offline_page(struct page *page, int flags)
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
