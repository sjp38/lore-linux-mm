Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 8CB5D6B0069
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 07:18:49 -0500 (EST)
Message-ID: <50C72497.9090904@huawei.com>
Date: Tue, 11 Dec 2012 20:18:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3 2/2] MCE: fix an error of mce_bad_pages statistics
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WuJianguo <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

1) adjust the function structure, there are too many return points
   randomly intermingled with some "goto done" return points.
2) use atomic_long_inc instead of atomic_long_add.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/memory-failure.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9b74983..81f942d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1421,12 +1421,13 @@ static int soft_offline_huge_page(struct page *page, int flags)

 	if (PageHWPoison(hpage)) {
 		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
-		return -EBUSY;
+		ret = -EBUSY;
+		goto out;
 	}

 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
-		return ret;
+		goto out;
 	if (ret == 0)
 		goto done;

@@ -1437,7 +1438,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	if (ret) {
 		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
 			pfn, ret, page->flags);
-		return ret;
+		goto out;
 	}
 done:
 	/* keep elevated page count for bad page */
@@ -1447,7 +1448,7 @@ done:
 	unlock_page(hpage);

 	dequeue_hwpoisoned_huge_page(hpage);
-
+out:
 	return ret;
 }

@@ -1479,24 +1480,28 @@ int soft_offline_page(struct page *page, int flags)
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_trans_head(page);

-	if (PageHuge(page))
-		return soft_offline_huge_page(page, flags);
+	if (PageHuge(page)) {
+		ret = soft_offline_huge_page(page, flags);
+		goto out;
+	}
 	if (PageTransHuge(hpage)) {
 		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
 			pr_info("soft offline: %#lx: failed to split THP\n",
 				pfn);
-			return -EBUSY;
+			ret = -EBUSY;
+			goto out;
 		}
 	}

 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
-		return -EBUSY;
+		ret = -EBUSY;
+		goto out;
 	}

 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
-		return ret;
+		goto out;
 	if (ret == 0)
 		goto done;

@@ -1515,14 +1520,15 @@ int soft_offline_page(struct page *page, int flags)
 		 */
 		ret = get_any_page(page, pfn, 0);
 		if (ret < 0)
-			return ret;
+			goto out;
 		if (ret == 0)
 			goto done;
 	}
 	if (!PageLRU(page)) {
 		pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
 			pfn, page->flags);
-		return -EIO;
+		ret = -EIO;
+		goto out;
 	}

 	/*
@@ -1577,14 +1583,14 @@ int soft_offline_page(struct page *page, int flags)
 			pfn, ret, page_count(page), page->flags);
 	}
 	if (ret)
-		return ret;
+		goto out;

 done:
 	/* keep elevated page count for bad page */
 	lock_page(page);
-	atomic_long_add(1, &mce_bad_pages);
+	atomic_long_inc(&mce_bad_pages);
 	SetPageHWPoison(page);
 	unlock_page(page);
-
+out:
 	return ret;
 }
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
