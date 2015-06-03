Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E013D900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 13:07:36 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so11589414pdj.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 10:07:36 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fc2si1823090pab.110.2015.06.03.10.07.21
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 10:07:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 31/36] thp, mm: split_huge_page(): caller need to lock page
Date: Wed,  3 Jun 2015 20:06:02 +0300
Message-Id: <1433351167-125878-32-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/memory-failure.c | 10 ++++++++--
 mm/migrate.c        |  8 ++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1cf7f2988422..0d9989a36d32 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1143,15 +1143,18 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 				put_page(hpage);
 			return -EBUSY;
 		}
+		lock_page(hpage);
 		if (unlikely(split_huge_page(hpage))) {
 			pr_err("MCE: %#lx: thp split failed\n", pfn);
 			if (TestClearPageHWPoison(p))
 				atomic_long_sub(nr_pages, &num_poisoned_pages);
+			unlock_page(hpage);
 			put_page(p);
 			if (p != hpage)
 				put_page(hpage);
 			return -EBUSY;
 		}
+		unlock_page(hpage);
 		VM_BUG_ON_PAGE(!page_count(p), p);
 		hpage = compound_head(p);
 	}
@@ -1714,10 +1717,13 @@ int soft_offline_page(struct page *page, int flags)
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
index dfd24cb7afc6..8bb2107b8751 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -933,9 +933,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
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
