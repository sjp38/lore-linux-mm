Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 213126B0072
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:04:40 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so28279804pac.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:04:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m2si5970396pdi.226.2015.04.23.14.04.39
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:04:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 24/28] thp, mm: split_huge_page(): caller need to lock page
Date: Fri, 24 Apr 2015 00:03:59 +0300
Message-Id: <1429823043-157133-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to use migration entries instead of compound_lock() to
stabilize page refcounts. Setup and remove migration entries require
page to be locked.

Some of split_huge_page() callers already have the page locked. Let's
require everybody to lock the page before calling split_huge_page().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/memory-failure.c | 12 +++++++++---
 mm/migrate.c        |  8 ++++++--
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 441eff52d099..d9b06727e480 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -996,7 +996,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
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
@@ -1750,10 +1753,13 @@ int soft_offline_page(struct page *page, int flags)
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
index b51e88c9dba2..03b9c4ba56dc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -932,9 +932,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
