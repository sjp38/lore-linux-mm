Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3769B6B06AA
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j9-v6so757557pfn.20
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2-v6sor7945475pfb.55.2018.11.08.22.47.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:54 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 11/11] mm: hwpoison: introduce clear_hwpoison_free_buddy_page()
Date: Fri,  9 Nov 2018 15:47:15 +0900
Message-Id: <1541746035-13408-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

The new function is a reverse operation of set_hwpoison_free_buddy_page()
to adjust unpoison_memory() to the new semantics.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/page-flags.h |  8 +++++++-
 mm/memory-failure.c        |  5 +++--
 mm/page_alloc.c            | 21 +++++++++++++++++++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/page-flags.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/page-flags.h
index 50ce1bd..ab0bde0 100644
--- v4.19-mmotm-2018-10-30-16-08/include/linux/page-flags.h
+++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/page-flags.h
@@ -382,11 +382,17 @@ PAGEFLAG(HWPoison, hwpoison, PF_ANY)
 TESTSCFLAG(HWPoison, hwpoison, PF_ANY)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
 extern bool set_hwpoison_free_buddy_page(struct page *page);
+extern bool clear_hwpoison_free_buddy_page(struct page *page);
 #else
 PAGEFLAG_FALSE(HWPoison)
 static inline bool set_hwpoison_free_buddy_page(struct page *page)
 {
-	return 0;
+	return false;
+}
+
+static inline bool clear_hwpoison_free_buddy_page(struct page *page)
+{
+	return false;
 }
 #define __PG_HWPOISON 0
 #endif
diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index af541141..a0e1cd4 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -1590,8 +1590,9 @@ int unpoison_memory(unsigned long pfn)
 	}
 
 	if (!get_hwpoison_page(p)) {
-		if (TestClearPageHWPoison(p))
-			num_poisoned_pages_dec();
+		if (!clear_hwpoison_free_buddy_page(p))
+			return 0;
+		num_poisoned_pages_dec();
 		unpoison_pr_info("Unpoison: Software-unpoisoned free page %#lx\n",
 				 pfn, &unpoison_rs);
 		return 0;
diff --git v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
index 27826b3..9a90f93 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
@@ -8270,4 +8270,25 @@ bool set_hwpoison_free_buddy_page(struct page *page)
 
 	return hwpoisoned;
 }
+
+/*
+ * Reverse operation of set_hwpoison_free_buddy_page(), which is expected
+ * to work only on error pages isolated from buddy allocator.
+ */
+bool clear_hwpoison_free_buddy_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	bool unpoisoned = false;
+
+	spin_lock(&zone->lock);
+	if (TestClearPageHWPoison(page)) {
+		unsigned long pfn = page_to_pfn(page);
+		int migratetype = get_pfnblock_migratetype(page, pfn);
+
+		__free_one_page(page, pfn, zone, 0, migratetype);
+		unpoisoned = true;
+	}
+	spin_unlock(&zone->lock);
+	return unpoisoned;
+}
 #endif
-- 
2.7.0
