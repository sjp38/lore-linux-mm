Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4C5816B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 11:12:02 -0400 (EDT)
Date: Thu, 12 Sep 2013 11:11:44 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378998704-d94o0a30-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hwpoison: move set_migratetype_isolate() outside
 get_any_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Chen Gong pointed out that set/unset_migratetype_isolate() was done in
different functions in mm/memory-failure.c, which makes the code less
readable/maintenable. So this patch makes it done in soft_offline_page().

With this patch, we get to hold lock_memory_hotplug() longer but it's not
a problem because races between memory hotplug and soft offline are very rare.

This patch is against next-20130910.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Chen, Gong <gong.chen@linux.intel.com>
---
 mm/memory-failure.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 947ed54..702e1e1 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1421,19 +1421,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 		return 1;
 
 	/*
-	 * The lock_memory_hotplug prevents a race with memory hotplug.
-	 * This is a big hammer, a better would be nicer.
-	 */
-	lock_memory_hotplug();
-
-	/*
-	 * Isolate the page, so that it doesn't get reallocated if it
-	 * was free. This flag should be kept set until the source page
-	 * is freed and PG_hwpoison on it is set.
-	 */
-	if (get_pageblock_migratetype(p) != MIGRATE_ISOLATE)
-		set_migratetype_isolate(p, true);
-	/*
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
 	 */
@@ -1453,7 +1440,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 		/* Not a free page */
 		ret = 1;
 	}
-	unlock_memory_hotplug();
 	return ret;
 }
 
@@ -1652,15 +1638,28 @@ int soft_offline_page(struct page *page, int flags)
 		}
 	}
 
+	/*
+	 * The lock_memory_hotplug prevents a race with memory hotplug.
+	 * This is a big hammer, a better would be nicer.
+	 */
+	lock_memory_hotplug();
+
+	/*
+	 * Isolate the page, so that it doesn't get reallocated if it
+	 * was free. This flag should be kept set until the source page
+	 * is freed and PG_hwpoison on it is set.
+	 */
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		set_migratetype_isolate(page, true);
+
 	ret = get_any_page(page, pfn, flags);
-	if (ret < 0)
-		goto unset;
-	if (ret) { /* for in-use pages */
+	unlock_memory_hotplug();
+	if (ret > 0) { /* for in-use pages */
 		if (PageHuge(page))
 			ret = soft_offline_huge_page(page, flags);
 		else
 			ret = __soft_offline_page(page, flags);
-	} else { /* for free pages */
+	} else if (ret == 0) { /* for free pages */
 		if (PageHuge(page)) {
 			set_page_hwpoison_huge_page(hpage);
 			dequeue_hwpoisoned_huge_page(hpage);
@@ -1671,7 +1670,6 @@ int soft_offline_page(struct page *page, int flags)
 			atomic_long_inc(&num_poisoned_pages);
 		}
 	}
-unset:
 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
