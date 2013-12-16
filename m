Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 20FC26B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:02:51 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w62so4312709wes.35
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:02:50 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id bo14si3435955wib.27.2013.12.16.01.02.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 01:02:50 -0800 (PST)
Message-ID: <52AEC122.2000609@huawei.com>
Date: Mon, 16 Dec 2013 17:00:18 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix huge page reallocated in soft_offline_page
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The huge page may be reallocated in soft_offline_page, because
MIGRATE_ISOLATE can not keep the page until after setting PG_hwpoison.
alloc_huge_page()
	dequeue_huge_page_vma()
		dequeue_huge_page_node()
If the huge page was reallocated, we need to try offline it again.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory-failure.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index b7c1716..f384249 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1505,8 +1505,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		if (ret > 0)
 			ret = -EIO;
 	} else {
+		ret = dequeue_hwpoisoned_huge_page(hpage);
+		/* If the page was reallocated, we need to try again. */
+		if (ret)
+			return -EAGAIN;
 		set_page_hwpoison_huge_page(hpage);
-		dequeue_hwpoisoned_huge_page(hpage);
 		atomic_long_add(1 << compound_order(hpage),
 				&num_poisoned_pages);
 	}
@@ -1624,10 +1627,11 @@ static int __soft_offline_page(struct page *page, int flags)
  */
 int soft_offline_page(struct page *page, int flags)
 {
-	int ret;
+	int ret, retry_max = 3;
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_trans_head(page);
 
+retry:
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
@@ -1663,8 +1667,15 @@ int soft_offline_page(struct page *page, int flags)
 			ret = __soft_offline_page(page, flags);
 	} else if (ret == 0) { /* for free pages */
 		if (PageHuge(page)) {
+			ret = dequeue_hwpoisoned_huge_page(hpage);
+			/* If the page was reallocated, we need to try again. */
+			if (ret) {
+				unset_migratetype_isolate(page,
+						MIGRATE_MOVABLE);
+				if (retry_max-- > 0)
+					goto retry;
+			}
 			set_page_hwpoison_huge_page(hpage);
-			dequeue_hwpoisoned_huge_page(hpage);
 			atomic_long_add(1 << compound_order(hpage),
 					&num_poisoned_pages);
 		} else {
@@ -1673,5 +1684,9 @@ int soft_offline_page(struct page *page, int flags)
 		}
 	}
 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
+
+	if (ret == -EAGAIN && retry_max-- > 0)
+		goto retry;
+
 	return ret;
 }
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
