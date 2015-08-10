Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id D7F926B0256
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 07:56:30 -0400 (EDT)
Received: by oiev193 with SMTP id v193so55573300oie.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:56:30 -0700 (PDT)
Received: from BLU004-OMC1S11.hotmail.com (blu004-omc1s11.hotmail.com. [65.55.116.22])
        by mx.google.com with ESMTPS id nt10si14251830obc.0.2015.08.10.04.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 04:56:30 -0700 (PDT)
Message-ID: <BLU436-SMTP12740A47B6EBB7DF2F12A9280700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 5/5] mm/hwpoison: replace most of put_page in memory error handling by put_hwpoison_page
Date: Mon, 10 Aug 2015 19:28:23 +0800
In-Reply-To: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>

Replace most of put_page in memory error handling by put_hwpoison_page,
except the ones at the front of soft_offline_page since the page maybe 
THP page and the get refcount in madvise_hwpoison is against the single 
4KB page instead of the logic in get_hwpoison_page. 

Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 mm/memory-failure.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fa9aa21..6179fc1 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1159,9 +1159,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			pr_err("MCE: %#lx: thp split failed\n", pfn);
 			if (TestClearPageHWPoison(p))
 				atomic_long_sub(nr_pages, &num_poisoned_pages);
-			put_page(p);
-			if (p != hpage)
-				put_page(hpage);
+			put_hwpoison_page(p);
 			return -EBUSY;
 		}
 		VM_BUG_ON_PAGE(!page_count(p), p);
@@ -1222,14 +1220,14 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		printk(KERN_ERR "MCE %#lx: just unpoisoned\n", pfn);
 		atomic_long_sub(nr_pages, &num_poisoned_pages);
 		unlock_page(hpage);
-		put_page(hpage);
+		put_hwpoison_page(hpage);
 		return 0;
 	}
 	if (hwpoison_filter(p)) {
 		if (TestClearPageHWPoison(p))
 			atomic_long_sub(nr_pages, &num_poisoned_pages);
 		unlock_page(hpage);
-		put_page(hpage);
+		put_hwpoison_page(hpage);
 		return 0;
 	}
 
@@ -1243,7 +1241,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
 		action_result(pfn, MF_MSG_POISONED_HUGE, MF_IGNORED);
 		unlock_page(hpage);
-		put_page(hpage);
+		put_hwpoison_page(hpage);
 		return 0;
 	}
 	/*
@@ -1477,9 +1475,9 @@ int unpoison_memory(unsigned long pfn)
 	}
 	unlock_page(page);
 
-	put_page(page);
+	put_hwpoison_page(page);
 	if (freeit && !(pfn == my_zero_pfn(0) && page_count(p) == 1))
-		put_page(page);
+		put_hwpoison_page(page);
 
 	return 0;
 }
@@ -1539,7 +1537,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		/*
 		 * Try to free it.
 		 */
-		put_page(page);
+		put_hwpoison_page(page);
 		shake_page(page, 1);
 
 		/*
@@ -1548,7 +1546,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		ret = __get_any_page(page, pfn, 0);
 		if (!PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
-			put_page(page);
+			put_hwpoison_page(page);
 			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
 				pfn, page->flags);
 			return -EIO;
@@ -1571,7 +1569,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	lock_page(hpage);
 	if (PageHWPoison(hpage)) {
 		unlock_page(hpage);
-		put_page(hpage);
+		put_hwpoison_page(hpage);
 		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1582,7 +1580,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	 * get_any_page() and isolate_huge_page() takes a refcount each,
 	 * so need to drop one here. 
 	 */
-	put_page(hpage);
+	put_hwpoison_page(hpage);
 	if (!ret) {
 		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
 		return -EBUSY;
@@ -1631,7 +1629,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	wait_on_page_writeback(page);
 	if (PageHWPoison(page)) {
 		unlock_page(page);
-		put_page(page);
+		put_hwpoison_page(page);
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
 	}
@@ -1646,7 +1644,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * would need to fix isolation locking first.
 	 */
 	if (ret == 1) {
-		put_page(page);
+		put_hwpoison_page(page);
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		SetPageHWPoison(page);
 		atomic_long_inc(&num_poisoned_pages);
@@ -1663,7 +1661,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	 * Drop page reference which is came from get_any_page()
 	 * successful isolate_lru_page() already took another one.
 	 */
-	put_page(page);
+	put_hwpoison_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
