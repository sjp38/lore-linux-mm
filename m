Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6E1176B0072
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:48:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 19:35:14 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 1620D2CE8053
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:43 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M9mWrx2621926
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7M9mgi6001341
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 19:48:42 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 5/6] mm/hwpoison: drop forward reference declarations __soft_offline_page()
Date: Thu, 22 Aug 2013 17:48:26 +0800
Message-Id: <1377164907-24801-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop forward reference declarations __soft_offline_page.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 129 ++++++++++++++++++++++++++--------------------------
 1 file changed, 64 insertions(+), 65 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 3bfb45f..0a52571 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1498,71 +1498,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	return ret;
 }
 
-static int __soft_offline_page(struct page *page, int flags);
-
-/**
- * soft_offline_page - Soft offline a page.
- * @page: page to offline
- * @flags: flags. Same as memory_failure().
- *
- * Returns 0 on success, otherwise negated errno.
- *
- * Soft offline a page, by migration or invalidation,
- * without killing anything. This is for the case when
- * a page is not corrupted yet (so it's still valid to access),
- * but has had a number of corrected errors and is better taken
- * out.
- *
- * The actual policy on when to do that is maintained by
- * user space.
- *
- * This should never impact any application or cause data loss,
- * however it might take some time.
- *
- * This is not a 100% solution for all memory, but tries to be
- * ``good enough'' for the majority of memory.
- */
-int soft_offline_page(struct page *page, int flags)
-{
-	int ret;
-	unsigned long pfn = page_to_pfn(page);
-	struct page *hpage = compound_trans_head(page);
-
-	if (PageHWPoison(page)) {
-		pr_info("soft offline: %#lx page already poisoned\n", pfn);
-		return -EBUSY;
-	}
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
-			pr_info("soft offline: %#lx: failed to split THP\n",
-				pfn);
-			return -EBUSY;
-		}
-	}
-
-	ret = get_any_page(page, pfn, flags);
-	if (ret < 0)
-		return ret;
-	if (ret) { /* for in-use pages */
-		if (PageHuge(page))
-			ret = soft_offline_huge_page(page, flags);
-		else
-			ret = __soft_offline_page(page, flags);
-	} else { /* for free pages */
-		if (PageHuge(page)) {
-			set_page_hwpoison_huge_page(hpage);
-			dequeue_hwpoisoned_huge_page(hpage);
-			atomic_long_add(1 << compound_order(hpage),
-					&num_poisoned_pages);
-		} else {
-			SetPageHWPoison(page);
-			atomic_long_inc(&num_poisoned_pages);
-		}
-	}
-	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
-	return ret;
-}
-
 static int __soft_offline_page(struct page *page, int flags)
 {
 	int ret;
@@ -1649,3 +1584,66 @@ static int __soft_offline_page(struct page *page, int flags)
 	}
 	return ret;
 }
+
+/**
+ * soft_offline_page - Soft offline a page.
+ * @page: page to offline
+ * @flags: flags. Same as memory_failure().
+ *
+ * Returns 0 on success, otherwise negated errno.
+ *
+ * Soft offline a page, by migration or invalidation,
+ * without killing anything. This is for the case when
+ * a page is not corrupted yet (so it's still valid to access),
+ * but has had a number of corrected errors and is better taken
+ * out.
+ *
+ * The actual policy on when to do that is maintained by
+ * user space.
+ *
+ * This should never impact any application or cause data loss,
+ * however it might take some time.
+ *
+ * This is not a 100% solution for all memory, but tries to be
+ * ``good enough'' for the majority of memory.
+ */
+int soft_offline_page(struct page *page, int flags)
+{
+	int ret;
+	unsigned long pfn = page_to_pfn(page);
+	struct page *hpage = compound_trans_head(page);
+
+	if (PageHWPoison(page)) {
+		pr_info("soft offline: %#lx page already poisoned\n", pfn);
+		return -EBUSY;
+	}
+	if (!PageHuge(page) && PageTransHuge(hpage)) {
+		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
+			pr_info("soft offline: %#lx: failed to split THP\n",
+				pfn);
+			return -EBUSY;
+		}
+	}
+
+	ret = get_any_page(page, pfn, flags);
+	if (ret < 0)
+		return ret;
+	if (ret) { /* for in-use pages */
+		if (PageHuge(page))
+			ret = soft_offline_huge_page(page, flags);
+		else
+			ret = __soft_offline_page(page, flags);
+	} else { /* for free pages */
+		if (PageHuge(page)) {
+			set_page_hwpoison_huge_page(hpage);
+			dequeue_hwpoisoned_huge_page(hpage);
+			atomic_long_add(1 << compound_order(hpage),
+					&num_poisoned_pages);
+		} else {
+			SetPageHWPoison(page);
+			atomic_long_inc(&num_poisoned_pages);
+		}
+	}
+	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
+	return ret;
+}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
