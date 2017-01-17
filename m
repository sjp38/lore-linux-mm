Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEE66B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 04:29:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so32323438wmd.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:29:57 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id 73si15279350wmn.146.2017.01.17.01.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 01:29:55 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 8EC9C1C1DA7
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 09:29:55 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/4] mm, page_alloc: Split buffered_rmqueue
Date: Tue, 17 Jan 2017 09:29:51 +0000
Message-Id: <20170117092954.15413-2-mgorman@techsingularity.net>
In-Reply-To: <20170117092954.15413-1-mgorman@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

buffered_rmqueue removes a page from a given zone and uses the per-cpu
list for order-0. This is fine but a hypothetical caller that wanted
multiple order-0 pages has to disable/reenable interrupts multiple
times. This patch structures buffere_rmqueue such that it's relatively
easy to build a bulk order-0 page allocator. There is no functional
change.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---
 mm/page_alloc.c | 126 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 78 insertions(+), 48 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d604d2596b7b..0e8404e546f5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2602,73 +2602,103 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
 #endif
 }
 
+/* Remove page from the per-cpu list, caller must protect the list */
+static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
+			bool cold, struct per_cpu_pages *pcp,
+			struct list_head *list)
+{
+	struct page *page;
+
+	do {
+		if (list_empty(list)) {
+			pcp->count += rmqueue_bulk(zone, 0,
+					pcp->batch, list,
+					migratetype, cold);
+			if (unlikely(list_empty(list)))
+				return NULL;
+		}
+
+		if (cold)
+			page = list_last_entry(list, struct page, lru);
+		else
+			page = list_first_entry(list, struct page, lru);
+
+		list_del(&page->lru);
+		pcp->count--;
+	} while (check_new_pcp(page));
+
+	return page;
+}
+
+/* Lock and remove page from the per-cpu list */
+static struct page *rmqueue_pcplist(struct zone *preferred_zone,
+			struct zone *zone, unsigned int order,
+			gfp_t gfp_flags, int migratetype)
+{
+	struct per_cpu_pages *pcp;
+	struct list_head *list;
+	bool cold = ((gfp_flags & __GFP_COLD) != 0);
+	struct page *page;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	pcp = &this_cpu_ptr(zone->pageset)->pcp;
+	list = &pcp->lists[migratetype];
+	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
+	if (page) {
+		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
+		zone_statistics(preferred_zone, zone, gfp_flags);
+	}
+	local_irq_restore(flags);
+	return page;
+}
+
 /*
  * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
-struct page *buffered_rmqueue(struct zone *preferred_zone,
+struct page *rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
 			gfp_t gfp_flags, unsigned int alloc_flags,
 			int migratetype)
 {
 	unsigned long flags;
 	struct page *page;
-	bool cold = ((gfp_flags & __GFP_COLD) != 0);
 
 	if (likely(order == 0)) {
-		struct per_cpu_pages *pcp;
-		struct list_head *list;
-
-		local_irq_save(flags);
-		do {
-			pcp = &this_cpu_ptr(zone->pageset)->pcp;
-			list = &pcp->lists[migratetype];
-			if (list_empty(list)) {
-				pcp->count += rmqueue_bulk(zone, 0,
-						pcp->batch, list,
-						migratetype, cold);
-				if (unlikely(list_empty(list)))
-					goto failed;
-			}
-
-			if (cold)
-				page = list_last_entry(list, struct page, lru);
-			else
-				page = list_first_entry(list, struct page, lru);
-
-			list_del(&page->lru);
-			pcp->count--;
+		page = rmqueue_pcplist(preferred_zone, zone, order,
+				gfp_flags, migratetype);
+		goto out;
+	}
 
-		} while (check_new_pcp(page));
-	} else {
-		/*
-		 * We most definitely don't want callers attempting to
-		 * allocate greater than order-1 page units with __GFP_NOFAIL.
-		 */
-		WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
-		spin_lock_irqsave(&zone->lock, flags);
+	/*
+	 * We most definitely don't want callers attempting to
+	 * allocate greater than order-1 page units with __GFP_NOFAIL.
+	 */
+	WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
+	spin_lock_irqsave(&zone->lock, flags);
 
-		do {
-			page = NULL;
-			if (alloc_flags & ALLOC_HARDER) {
-				page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
-				if (page)
-					trace_mm_page_alloc_zone_locked(page, order, migratetype);
-			}
-			if (!page)
-				page = __rmqueue(zone, order, migratetype);
-		} while (page && check_new_pages(page, order));
-		spin_unlock(&zone->lock);
+	do {
+		page = NULL;
+		if (alloc_flags & ALLOC_HARDER) {
+			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
+			if (page)
+				trace_mm_page_alloc_zone_locked(page, order, migratetype);
+		}
 		if (!page)
-			goto failed;
-		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_pcppage_migratetype(page));
-	}
+			page = __rmqueue(zone, order, migratetype);
+	} while (page && check_new_pages(page, order));
+	spin_unlock(&zone->lock);
+	if (!page)
+		goto failed;
+	__mod_zone_freepage_state(zone, -(1 << order),
+				  get_pcppage_migratetype(page));
 
 	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
 
+out:
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 	return page;
 
@@ -2974,7 +3004,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(ac->preferred_zoneref->zone, zone, order,
+		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
 			prep_new_page(page, order, gfp_mask, alloc_flags);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
