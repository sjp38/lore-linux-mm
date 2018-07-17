Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 132B96B000C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 01:32:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so25864662plq.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 22:32:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g93-v6sor21330plb.109.2018.07.16.22.32.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 22:32:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 2/2] mm: soft-offline: close the race against page allocation
Date: Tue, 17 Jul 2018 14:32:32 +0900
Message-Id: <1531805552-19547-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

A process can be killed with SIGBUS(BUS_MCEERR_AR) when it tries to
allocate a page that was just freed on the way of soft-offline.
This is undesirable because soft-offline (which is about corrected error)
is less aggressive than hard-offline (which is about uncorrected error),
and we can make soft-offline fail and keep using the page for good reason
like "system is busy."

Two main changes of this patch are:

- setting migrate type of the target page to MIGRATE_ISOLATE. As done
  in free_unref_page_commit(), this makes kernel bypass pcplist when
  freeing the page. So we can assume that the page is in freelist just
  after put_page() returns,

- setting PG_hwpoison on free page under zone->lock which protects
  freelists, so this allows us to avoid setting PG_hwpoison on a page
  that is decided to be allocated soon.

Reported-by: Xishi Qiu <xishi.qiuxishi@alibaba-inc.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
changelog v1->v2:
- updated comment on set_hwpoison_free_buddy_page(),
- moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to
  mm/memory-failure.c, which is necessary to check the return code of
  set_hwpoison_free_buddy_page().
---
 include/linux/page-flags.h |  5 +++++
 include/linux/swapops.h    | 10 ----------
 mm/memory-failure.c        | 35 +++++++++++++++++++++++++++++------
 mm/migrate.c               |  9 ---------
 mm/page_alloc.c            | 30 ++++++++++++++++++++++++++++++
 5 files changed, 64 insertions(+), 25 deletions(-)

diff --git v4.18-rc4-mmotm-2018-07-10-16-50/include/linux/page-flags.h v4.18-rc4-mmotm-2018-07-10-16-50_patched/include/linux/page-flags.h
index 901943e..74bee8c 100644
--- v4.18-rc4-mmotm-2018-07-10-16-50/include/linux/page-flags.h
+++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/include/linux/page-flags.h
@@ -369,8 +369,13 @@ PAGEFLAG_FALSE(Uncached)
 PAGEFLAG(HWPoison, hwpoison, PF_ANY)
 TESTSCFLAG(HWPoison, hwpoison, PF_ANY)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
+extern bool set_hwpoison_free_buddy_page(struct page *page);
 #else
 PAGEFLAG_FALSE(HWPoison)
+static inline bool set_hwpoison_free_buddy_page(struct page *page)
+{
+	return 0;
+}
 #define __PG_HWPOISON 0
 #endif
 
diff --git v4.18-rc4-mmotm-2018-07-10-16-50/include/linux/swapops.h v4.18-rc4-mmotm-2018-07-10-16-50_patched/include/linux/swapops.h
index 9c0eb4d..fe8e08b 100644
--- v4.18-rc4-mmotm-2018-07-10-16-50/include/linux/swapops.h
+++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/include/linux/swapops.h
@@ -335,11 +335,6 @@ static inline int is_hwpoison_entry(swp_entry_t entry)
 	return swp_type(entry) == SWP_HWPOISON;
 }
 
-static inline bool test_set_page_hwpoison(struct page *page)
-{
-	return TestSetPageHWPoison(page);
-}
-
 static inline void num_poisoned_pages_inc(void)
 {
 	atomic_long_inc(&num_poisoned_pages);
@@ -362,11 +357,6 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
 	return 0;
 }
 
-static inline bool test_set_page_hwpoison(struct page *page)
-{
-	return false;
-}
-
 static inline void num_poisoned_pages_inc(void)
 {
 }
diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
index 9b77f85..936d0e7 100644
--- v4.18-rc4-mmotm-2018-07-10-16-50/mm/memory-failure.c
+++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/memory-failure.c
@@ -57,6 +57,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
 #include <linux/ratelimit.h>
+#include <linux/page-isolation.h>
 #include "internal.h"
 #include "ras/ras_event.h"
 
@@ -1609,8 +1610,10 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		 */
 		ret = dissolve_free_huge_page(page);
 		if (!ret) {
-			if (!TestSetPageHWPoison(page))
+			if (set_hwpoison_free_buddy_page(page))
 				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	}
 	return ret;
@@ -1688,6 +1691,11 @@ static int __soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags, &page->flags);
 			if (ret > 0)
 				ret = -EIO;
+		} else {
+			if (set_hwpoison_free_buddy_page(page))
+				num_poisoned_pages_inc();
+			else
+				ret = -EBUSY;
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx (%pGp)\n",
@@ -1699,6 +1707,7 @@ static int __soft_offline_page(struct page *page, int flags)
 static int soft_offline_in_use_page(struct page *page, int flags)
 {
 	int ret;
+	int mt;
 	struct page *hpage = compound_head(page);
 
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
@@ -1717,23 +1726,37 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 		put_hwpoison_page(hpage);
 	}
 
+	/*
+	 * Setting MIGRATE_ISOLATE here ensures that the page will be linked
+	 * to free list immediately (not via pcplist) when released after
+	 * successful page migration. Otherwise we can't guarantee that the
+	 * page is really free after put_page() returns, so
+	 * set_hwpoison_free_buddy_page() highly likely fails.
+	 */
+	mt = get_pageblock_migratetype(page);
+	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
 	else
 		ret = __soft_offline_page(page, flags);
-
+	set_pageblock_migratetype(page, mt);
 	return ret;
 }
 
-static void soft_offline_free_page(struct page *page)
+static int soft_offline_free_page(struct page *page)
 {
 	int rc = 0;
 	struct page *head = compound_head(page);
 
 	if (PageHuge(head))
 		rc = dissolve_free_huge_page(page);
-	if (!rc && !TestSetPageHWPoison(page))
-		num_poisoned_pages_inc();
+	if (!rc) {
+		if (set_hwpoison_free_buddy_page(page))
+			num_poisoned_pages_inc();
+		else
+			rc = -EBUSY;
+	}
+	return rc;
 }
 
 /**
@@ -1777,7 +1800,7 @@ int soft_offline_page(struct page *page, int flags)
 	if (ret > 0)
 		ret = soft_offline_in_use_page(page, flags);
 	else if (ret == 0)
-		soft_offline_free_page(page);
+		ret = soft_offline_free_page(page);
 
 	return ret;
 }
diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/migrate.c
index 3ae213b..4fd0fe0 100644
--- v4.18-rc4-mmotm-2018-07-10-16-50/mm/migrate.c
+++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/migrate.c
@@ -1193,15 +1193,6 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
 		put_page(page);
-		if (reason == MR_MEMORY_FAILURE) {
-			/*
-			 * Set PG_HWPoison on just freed page
-			 * intentionally. Although it's rather weird,
-			 * it's how HWPoison flag works at the moment.
-			 */
-			if (!test_set_page_hwpoison(page))
-				num_poisoned_pages_inc();
-		}
 	} else {
 		if (rc != -EAGAIN) {
 			if (likely(!__PageMovable(page))) {
diff --git v4.18-rc4-mmotm-2018-07-10-16-50/mm/page_alloc.c v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/page_alloc.c
index 607deff..4058b7e 100644
--- v4.18-rc4-mmotm-2018-07-10-16-50/mm/page_alloc.c
+++ v4.18-rc4-mmotm-2018-07-10-16-50_patched/mm/page_alloc.c
@@ -8027,3 +8027,33 @@ bool is_free_buddy_page(struct page *page)
 
 	return order < MAX_ORDER;
 }
+
+#ifdef CONFIG_MEMORY_FAILURE
+/*
+ * Set PG_hwpoison flag if a given page is confirmed to be a free page.  This
+ * test is performed under the zone lock to prevent a race against page
+ * allocation.
+ */
+bool set_hwpoison_free_buddy_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	unsigned int order;
+	bool hwpoisoned = false;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	for (order = 0; order < MAX_ORDER; order++) {
+		struct page *page_head = page - (pfn & ((1 << order) - 1));
+
+		if (PageBuddy(page_head) && page_order(page_head) >= order) {
+			if (!TestSetPageHWPoison(page))
+				hwpoisoned = true;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return hwpoisoned;
+}
+#endif
-- 
2.7.0
