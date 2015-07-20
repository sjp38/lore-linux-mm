Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D06D09003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 04:00:45 -0400 (EDT)
Received: by wgbcc4 with SMTP id cc4so30877744wgb.3
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 01:00:45 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id fu7si11983729wib.72.2015.07.20.01.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 01:00:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 75A2A98624
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:00:25 +0000 (UTC)
From: Mel Gorman <mgorman@suse.com>
Subject: [PATCH 10/10] mm, page_alloc: Only enforce watermarks for order-0 allocations
Date: Mon, 20 Jul 2015 09:00:19 +0100
Message-Id: <1437379219-9160-11-git-send-email-mgorman@suse.com>
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Mel Gorman <mgorman@suse.de>

The primary purpose of watermarks is to ensure that reclaim can always
make forward progress in PF_MEMALLOC context (kswapd and direct reclaim).
These assume that order-0 allocations are all that is necessary for
forward progress.

High-order watermarks serve a different purpose. Kswapd had no high-order
awareness before they were introduced (https://lkml.org/lkml/2004/9/5/9).
This was particularly important when there were high-order atomic requests.
The watermarks both gave kswapd awareness and made a reserve for those
atomic requests.

There are two important side-effects of this. The most important is that
a non-atomic high-order request can fail even though free pages are available
and the order-0 watermarks are ok. The second is that high-order watermark
checks are expensive as the free list counts up to the requested order must
be examined.

With the introduction of MIGRATE_HIGHATOMIC it is no longer necessary to
have high-order watermarks. Kswapd and compaction still need high-order
awareness which is handled by checking that at least one suitable high-order
page is free.

In kernel 4.2-rc1 running this workload on a single-node machine there
were 339574 allocation failures. With HighAtomic reserves, it drops to
28798 failures. With this patch applied, it drops to 9567 failures --
a 98% reduction compared to the vanilla kernel or 67% in comparison to
having high atomic reserves with watermark checking.

The one potential side-effect of this is that in a vanilla kernel, the
watermark checks may have kept a free page for an atomic allocation. Now,
we are 100% relying on the HighAtomic reserves and an early allocation to
have allocated them.  If the first high-order atomic allocation is after
the system is already heavily fragmented then it'll fail.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e5755390a5e5..e756df60dba6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2250,8 +2250,10 @@ static inline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 #endif /* CONFIG_FAIL_PAGE_ALLOC */
 
 /*
- * Return true if free pages are above 'mark'. This takes into account the order
- * of the allocation.
+ * Return true if free base pages are above 'mark'. For high-order checks it
+ * will return true of the order-0 watermark is reached and there is at least
+ * one free page of a suitable size. Checking now avoids taking the zone lock
+ * to check in the allocation paths if no pages are free.
  */
 static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx, int alloc_flags,
@@ -2259,7 +2261,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 {
 	long min = mark;
 	int o;
-	long free_cma = 0;
+	const bool atomic = (alloc_flags & ALLOC_HARDER);
 
 	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
@@ -2271,7 +2273,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	 * If the caller is not atomic then discount the reserves. This will
 	 * over-estimate how the atomic reserve but it avoids a search
 	 */
-	if (likely(!(alloc_flags & ALLOC_HARDER)))
+	if (likely(!atomic))
 		free_pages -= z->nr_reserved_highatomic;
 	else
 		min -= min / 4;
@@ -2279,22 +2281,30 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
 	if (!(alloc_flags & ALLOC_CMA))
-		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
+		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif
 
-	if (free_pages - free_cma <= min + z->lowmem_reserve[classzone_idx])
+	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return false;
-	for (o = 0; o < order; o++) {
-		/* At the next order, this order's pages become unavailable */
-		free_pages -= z->free_area[o].nr_free << o;
 
-		/* Require fewer higher order pages to be free */
-		min >>= 1;
+	/* order-0 watermarks are ok */
+	if (!order)
+		return true;
+
+	/* Check at least one high-order page is free */
+	for (o = order; o < MAX_ORDER; o++) {
+		struct free_area *area = &z->free_area[o];
+		int mt;
+
+		if (atomic && area->nr_free)
+			return true;
 
-		if (free_pages <= min)
-			return false;
+		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
+			if (!list_empty(&area->free_list[mt]))
+				return true;
+		}
 	}
-	return true;
+	return false;
 }
 
 bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
