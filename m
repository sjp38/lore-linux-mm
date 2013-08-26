Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 49B226B003B
	for <linux-mm@kvack.org>; Sun, 25 Aug 2013 21:19:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 06:40:02 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 36D9FE0053
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 06:49:42 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q1Kl6Q39059530
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 06:50:47 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7Q1J7Sc032591
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 06:49:07 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 6/8] mm/hwpoison: drop forward reference declarations __soft_offline_page()
Date: Mon, 26 Aug 2013 09:18:49 +0800
Message-Id: <1377479931-7430-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377479931-7430-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377479931-7430-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Drop forward reference declarations __soft_offline_page.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 128 ++++++++++++++++++++++++++--------------------------
 1 file changed, 63 insertions(+), 65 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f357c91..ca714ac 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1511,71 +1511,6 @@ static int soft_offline_huge_page(struct page *page, int flags)
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
@@ -1662,3 +1597,66 @@ static int __soft_offline_page(struct page *page, int flags)
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
