Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8EA86B006E
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:33:18 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so87160885oiy.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:33:18 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id j8si23630121oia.52.2015.06.26.19.33.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:33:18 -0700 (PDT)
Message-ID: <558E0A51.1040807@huawei.com>
Date: Sat, 27 Jun 2015 10:28:33 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 8/8] mm: add the PCP interface
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Abstract the PCP code in __rmqueue_pcp(), and do not call fallback in
rmqueue_bulk() when the migratetype is mirror.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 85 +++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 61 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a6125e..bb44463 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1337,11 +1337,20 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
 			int migratetype, bool cold)
 {
-	int i;
+	int i, mt;
+	struct page *page;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
+		/*
+		 * If there is no mirrored memory left, just keep the list
+		 * empty, because we can not mix other types pages into the
+		 * mirror list.
+		 */
+		if (is_migrate_mirror(migratetype))
+			page = __rmqueue_smallest(zone, order, migratetype);
+		else
+			page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
 
@@ -1359,15 +1368,61 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_freepage_migratetype(page)))
+
+		mt = get_freepage_migratetype(page);
+		if (is_migrate_cma(mt))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
+		if (is_migrate_mirror(mt))
+			__mod_zone_page_state(zone, NR_FREE_MIRROR_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
 	return i;
 }
 
+static struct page *__rmqueue_pcp(struct zone *zone, unsigned int order,
+				gfp_t gfp_flags, int migratetype)
+{
+	struct page *page;
+	struct per_cpu_pages *pcp;
+	struct list_head *list;
+	bool cold;
+
+	cold = ((gfp_flags & __GFP_COLD) != 0);
+	pcp = &this_cpu_ptr(zone->pageset)->pcp;
+
+retry:
+	list = &pcp->lists[migratetype];
+	if (list_empty(list)) {
+		pcp->count += rmqueue_bulk(zone, 0,
+				pcp->batch, list,
+				migratetype, cold);
+		if (unlikely(list_empty(list))) {
+			/*
+			 * If there is no mirrored memory left, alloc other
+			 * types PCP, use MIGRATE_RECLAIMABLE to retry
+			 */
+			if (is_migrate_mirror(migratetype)) {
+				migratetype = MIGRATE_RECLAIMABLE;
+				goto retry;
+			} else
+				return NULL;
+		}
+	}
+
+	if (cold)
+		page = list_entry(list->prev, struct page, lru);
+	else
+		page = list_entry(list->next, struct page, lru);
+
+	list_del(&page->lru);
+	pcp->count--;
+
+	return page;
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Called from the vmstat counter updater to drain pagesets of this
@@ -1713,30 +1768,12 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 {
 	unsigned long flags;
 	struct page *page;
-	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
 	if (likely(order == 0)) {
-		struct per_cpu_pages *pcp;
-		struct list_head *list;
-
 		local_irq_save(flags);
-		pcp = &this_cpu_ptr(zone->pageset)->pcp;
-		list = &pcp->lists[migratetype];
-		if (list_empty(list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, list,
-					migratetype, cold);
-			if (unlikely(list_empty(list)))
-				goto failed;
-		}
-
-		if (cold)
-			page = list_entry(list->prev, struct page, lru);
-		else
-			page = list_entry(list->next, struct page, lru);
-
-		list_del(&page->lru);
-		pcp->count--;
+		page = __rmqueue_pcp(zone, order, gfp_flags, migratetype);
+		if (!page)
+			goto failed;
 	} else {
 		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 			/*
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
