Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D99BF82F64
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 11:08:28 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so53845004pac.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:08:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ez3si10679518pab.130.2015.09.18.08.02.17
        for <linux-mm@kvack.org>;
        Fri, 18 Sep 2015 08:02:17 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv11 31/37] thp, mm: split_huge_page(): caller need to lock page
Date: Fri, 18 Sep 2015 18:01:34 +0300
Message-Id: <1442588500-77331-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1442588500-77331-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/memory-failure.c | 8 +++++++-
 mm/migrate.c        | 8 ++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 39591cce45ca..216f1d4768ec 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1148,7 +1148,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	}
 
 	if (!PageHuge(p) && PageTransHuge(hpage)) {
+		lock_page(hpage);
 		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
+			unlock_page(hpage);
 			if (!PageAnon(hpage))
 				pr_err("MCE: %#lx: non anonymous thp\n", pfn);
 			else
@@ -1158,6 +1160,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			put_hwpoison_page(p);
 			return -EBUSY;
 		}
+		unlock_page(hpage);
 		VM_BUG_ON_PAGE(!page_count(p), p);
 		hpage = compound_head(p);
 	}
@@ -1735,7 +1738,10 @@ int soft_offline_page(struct page *page, int flags)
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
 			if (flags & MF_COUNT_INCREASED)
diff --git a/mm/migrate.c b/mm/migrate.c
index 9da75bf83319..bb4c9e2eab17 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -939,9 +939,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
