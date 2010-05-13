Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 19AD36B01F3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 03:57:05 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/7] HWPOISON, hugetlb: set/clear PG_hwpoison bits on hugepage
Date: Thu, 13 May 2010 16:55:22 +0900
Message-Id: <1273737326-21211-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

To avoid race condition between concurrent memory errors on identified
hugepage, we atomically test and set PG_hwpoison bit on the head page.
All pages in the error hugepage are considered as hwpoisoned
for now, so set and clear all PG_hwpoison bits in the hugepage
with page lock of the head page held.

Dependency:
  "HWPOISON, hugetlb: enable error handling path for hugepage"

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git v2.6.34-rc7/mm/memory-failure.c v2.6.34-rc7/mm/memory-failure.c
index 1ec68c8..fee648b 100644
--- v2.6.34-rc7/mm/memory-failure.c
+++ v2.6.34-rc7/mm/memory-failure.c
@@ -920,6 +920,22 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	return ret;
 }
 
+static void set_page_hwpoison_huge_page(struct page *hpage)
+{
+	int i;
+	int nr_pages = 1 << compound_order(hpage);
+	for (i = 0; i < nr_pages; i++)
+		SetPageHWPoison(hpage + i);
+}
+
+static void clear_page_hwpoison_huge_page(struct page *hpage)
+{
+	int i;
+	int nr_pages = 1 << compound_order(hpage);
+	for (i = 0; i < nr_pages; i++)
+		ClearPageHWPoison(hpage + i);
+}
+
 int __memory_failure(unsigned long pfn, int trapno, int flags)
 {
 	struct page_state *ps;
@@ -1014,6 +1030,26 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
+	/*
+	 * For error on the tail page, we should set PG_hwpoison
+	 * on the head page to show that the hugepage is hwpoisoned
+	 */
+	if (PageTail(p) && TestSetPageHWPoison(hpage)) {
+		action_result(pfn, "hugepage already hardware poisoned",
+				IGNORED);
+		unlock_page(hpage);
+		put_page(hpage);
+		return 0;
+	}
+	/*
+	 * Set PG_hwpoison on all pages in an error hugepage,
+	 * because containment is done in hugepage unit for now.
+	 * Since we have done TestSetPageHWPoison() for the head page with
+	 * page lock held, we can safely set PG_hwpoison bits on tail pages.
+	 */
+	if (PageHuge(p))
+		set_page_hwpoison_huge_page(hpage);
+
 	wait_on_page_writeback(p);
 
 	/*
@@ -1118,6 +1154,8 @@ int unpoison_memory(unsigned long pfn)
 		atomic_long_dec(&mce_bad_pages);
 		freeit = 1;
 	}
+	if (PageHuge(p))
+		clear_page_hwpoison_huge_page(page);
 	unlock_page(page);
 
 	put_page(page);
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
