Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE5F96B02F3
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:13 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id z125so31762828itc.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:13 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id c83si19225242itb.123.2017.06.01.01.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:12 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id o12so4179307iod.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:12 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 3/9] mm: hwpoison: change PageHWPoison behavior on hugetlb pages
Date: Thu,  1 Jun 2017 17:16:53 +0900
Message-Id: <1496305019-5493-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

We'd like to narrow down the error region in memory error on hugetlb
pages.  However, currently we set PageHWPoison flags on all subpages
in the error hugepage and add # of subpages to num_hwpoison_pages,
which doesn't fit our purpose.

So this patch changes the behavior and we only set PageHWPoison on
the head page then increase num_hwpoison_pages only by 1. This is
a preparation for narrow-down part which comes in later patches.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/swapops.h |  9 -----
 mm/memory-failure.c     | 87 ++++++++++++++-----------------------------------
 2 files changed, 24 insertions(+), 72 deletions(-)

diff --git v4.12-rc3/include/linux/swapops.h v4.12-rc3_patched/include/linux/swapops.h
index 5c3a5f3..c5ff7b2 100644
--- v4.12-rc3/include/linux/swapops.h
+++ v4.12-rc3_patched/include/linux/swapops.h
@@ -196,15 +196,6 @@ static inline void num_poisoned_pages_dec(void)
 	atomic_long_dec(&num_poisoned_pages);
 }
 
-static inline void num_poisoned_pages_add(long num)
-{
-	atomic_long_add(num, &num_poisoned_pages);
-}
-
-static inline void num_poisoned_pages_sub(long num)
-{
-	atomic_long_sub(num, &num_poisoned_pages);
-}
 #else
 
 static inline swp_entry_t make_hwpoison_entry(struct page *page)
diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index 6c1a7c9..aae620f 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1009,22 +1009,6 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	return unmap_success;
 }
 
-static void set_page_hwpoison_huge_page(struct page *hpage)
-{
-	int i;
-	int nr_pages = 1 << compound_order(hpage);
-	for (i = 0; i < nr_pages; i++)
-		SetPageHWPoison(hpage + i);
-}
-
-static void clear_page_hwpoison_huge_page(struct page *hpage)
-{
-	int i;
-	int nr_pages = 1 << compound_order(hpage);
-	for (i = 0; i < nr_pages; i++)
-		ClearPageHWPoison(hpage + i);
-}
-
 /**
  * memory_failure - Handle memory failure of a page.
  * @pfn: Page Number of the corrupted page
@@ -1050,7 +1034,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	struct page *hpage;
 	struct page *orig_head;
 	int res;
-	unsigned int nr_pages;
 	unsigned long page_flags;
 
 	if (!sysctl_memory_failure_recovery)
@@ -1064,24 +1047,23 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 
 	p = pfn_to_page(pfn);
 	orig_head = hpage = compound_head(p);
+
+	/* tmporary check code, to be updated in later patches */
+	if (PageHuge(p)) {
+		if (TestSetPageHWPoison(hpage)) {
+			pr_err("Memory failure: %#lx: already hardware poisoned\n", pfn);
+			return 0;
+		}
+		goto tmp;
+	}
 	if (TestSetPageHWPoison(p)) {
 		pr_err("Memory failure: %#lx: already hardware poisoned\n",
 			pfn);
 		return 0;
 	}
 
-	/*
-	 * Currently errors on hugetlbfs pages are measured in hugepage units,
-	 * so nr_pages should be 1 << compound_order.  OTOH when errors are on
-	 * transparent hugepages, they are supposed to be split and error
-	 * measurement is done in normal page units.  So nr_pages should be one
-	 * in this case.
-	 */
-	if (PageHuge(p))
-		nr_pages = 1 << compound_order(hpage);
-	else /* normal page or thp */
-		nr_pages = 1;
-	num_poisoned_pages_add(nr_pages);
+tmp:
+	num_poisoned_pages_inc();
 
 	/*
 	 * We need/can do nothing about count=0 pages.
@@ -1109,12 +1091,11 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			if (PageHWPoison(hpage)) {
 				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
 				    || (p != hpage && TestSetPageHWPoison(hpage))) {
-					num_poisoned_pages_sub(nr_pages);
+					num_poisoned_pages_dec();
 					unlock_page(hpage);
 					return 0;
 				}
 			}
-			set_page_hwpoison_huge_page(hpage);
 			res = dequeue_hwpoisoned_huge_page(hpage);
 			action_result(pfn, MF_MSG_FREE_HUGE,
 				      res ? MF_IGNORED : MF_DELAYED);
@@ -1137,7 +1118,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 				pr_err("Memory failure: %#lx: thp split failed\n",
 					pfn);
 			if (TestClearPageHWPoison(p))
-				num_poisoned_pages_sub(nr_pages);
+				num_poisoned_pages_dec();
 			put_hwpoison_page(p);
 			return -EBUSY;
 		}
@@ -1190,14 +1171,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 */
 	if (!PageHWPoison(p)) {
 		pr_err("Memory failure: %#lx: just unpoisoned\n", pfn);
-		num_poisoned_pages_sub(nr_pages);
+		num_poisoned_pages_dec();
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
 		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
-			num_poisoned_pages_sub(nr_pages);
+			num_poisoned_pages_dec();
 		unlock_page(hpage);
 		put_hwpoison_page(hpage);
 		return 0;
@@ -1216,14 +1197,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		put_hwpoison_page(hpage);
 		return 0;
 	}
-	/*
-	 * Set PG_hwpoison on all pages in an error hugepage,
-	 * because containment is done in hugepage unit for now.
-	 * Since we have done TestSetPageHWPoison() for the head page with
-	 * page lock held, we can safely set PG_hwpoison bits on tail pages.
-	 */
-	if (PageHuge(p))
-		set_page_hwpoison_huge_page(hpage);
 
 	/*
 	 * It's very difficult to mess with pages currently under IO
@@ -1394,7 +1367,6 @@ int unpoison_memory(unsigned long pfn)
 	struct page *page;
 	struct page *p;
 	int freeit = 0;
-	unsigned int nr_pages;
 	static DEFINE_RATELIMIT_STATE(unpoison_rs, DEFAULT_RATELIMIT_INTERVAL,
 					DEFAULT_RATELIMIT_BURST);
 
@@ -1439,8 +1411,6 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
 
-	nr_pages = 1 << compound_order(page);
-
 	if (!get_hwpoison_page(p)) {
 		/*
 		 * Since HWPoisoned hugepage should have non-zero refcount,
@@ -1470,10 +1440,8 @@ int unpoison_memory(unsigned long pfn)
 	if (TestClearPageHWPoison(page)) {
 		unpoison_pr_info("Unpoison: Software-unpoisoned page %#lx\n",
 				 pfn, &unpoison_rs);
-		num_poisoned_pages_sub(nr_pages);
+		num_poisoned_pages_dec();
 		freeit = 1;
-		if (PageHuge(page))
-			clear_page_hwpoison_huge_page(page);
 	}
 	unlock_page(page);
 
@@ -1604,14 +1572,10 @@ static int soft_offline_huge_page(struct page *page, int flags)
 			ret = -EIO;
 	} else {
 		/* overcommit hugetlb page will be freed to buddy */
-		if (PageHuge(page)) {
-			set_page_hwpoison_huge_page(hpage);
+		SetPageHWPoison(page);
+		if (PageHuge(page))
 			dequeue_hwpoisoned_huge_page(hpage);
-			num_poisoned_pages_add(1 << compound_order(hpage));
-		} else {
-			SetPageHWPoison(page);
-			num_poisoned_pages_inc();
-		}
+		num_poisoned_pages_inc();
 	}
 	return ret;
 }
@@ -1727,15 +1691,12 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 
 static void soft_offline_free_page(struct page *page)
 {
-	if (PageHuge(page)) {
-		struct page *hpage = compound_head(page);
+	struct page *head = compound_head(page);
 
-		set_page_hwpoison_huge_page(hpage);
-		if (!dequeue_hwpoisoned_huge_page(hpage))
-			num_poisoned_pages_add(1 << compound_order(hpage));
-	} else {
-		if (!TestSetPageHWPoison(page))
-			num_poisoned_pages_inc();
+	if (!TestSetPageHWPoison(head)) {
+		num_poisoned_pages_inc();
+		if (PageHuge(head))
+			dequeue_hwpoisoned_huge_page(head);
 	}
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
