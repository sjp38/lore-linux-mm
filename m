Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 23B0D6B004D
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:11:25 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so2813563pdb.10
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:11:24 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rh8si93609pbc.176.2014.08.06.00.11.19
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:11:20 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 6/8] mm/isolation: factor out pre/post logic on set/unset_migratetype_isolate()
Date: Wed,  6 Aug 2014 16:18:35 +0900
Message-Id: <1407309517-3270-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current isolation logic isolates each pageblock individually.
This causes freepage counting problem when page with pageblock order is
merged with other page on different buddy list. To prevent it, we should
handle whole range at one time in start_isolate_page_range(). This patch
is preparation of that work.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c |   45 +++++++++++++++++++++++++++++----------------
 1 file changed, 29 insertions(+), 16 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 898361f..b91f9ec 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -78,18 +78,14 @@ static void activate_isolated_pages(struct zone *zone, unsigned long start_pfn,
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
-int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
+static int set_migratetype_isolate_pre(struct page *page,
+				bool skip_hwpoisoned_pages)
 {
-	struct zone *zone;
-	unsigned long flags, pfn;
+	struct zone *zone = page_zone(page);
+	unsigned long pfn;
 	struct memory_isolate_notify arg;
 	int notifier_ret;
 	int ret = -EBUSY;
-	unsigned long nr_pages;
-	int migratetype;
-
-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lock, flags);
 
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
@@ -110,7 +106,7 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
 	notifier_ret = notifier_to_errno(notifier_ret);
 	if (notifier_ret)
-		goto out;
+		return ret;
 	/*
 	 * FIXME: Now, memory hotplug doesn't call shrink_slab() by itself.
 	 * We just check MOVABLE pages.
@@ -124,10 +120,20 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 	 * removable-by-driver pages reported by notifier, we'll fail.
 	 */
 
-out:
-	if (ret) {
+	return ret;
+}
+
+int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+	unsigned long nr_pages;
+	int migratetype;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	if (set_migratetype_isolate_pre(page, skip_hwpoisoned_pages)) {
 		spin_unlock_irqrestore(&zone->lock, flags);
-		return ret;
+		return -EBUSY;
 	}
 
 	migratetype = get_pageblock_migratetype(page);
@@ -153,11 +159,20 @@ out:
 	return 0;
 }
 
+static void unset_migratetype_isolate_post(struct page *page,
+					unsigned migratetype)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long start_pfn, end_pfn;
+
+	start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
+	end_pfn = start_pfn + pageblock_nr_pages;
+	activate_isolated_pages(zone, start_pfn, end_pfn, migratetype);
+}
 void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
-	unsigned long start_pfn, end_pfn;
 
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
@@ -174,9 +189,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	/* Freed pages will see original migratetype after this point */
 	kick_all_cpus_sync();
 
-	start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
-	end_pfn = start_pfn + pageblock_nr_pages;
-	activate_isolated_pages(zone, start_pfn, end_pfn, migratetype);
+	unset_migratetype_isolate_post(page, migratetype);
 }
 
 static inline struct page *
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
