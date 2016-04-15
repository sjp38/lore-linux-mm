Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F22C3828E6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:10:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l15so64078979lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:10:40 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id s1si10907822wme.105.2016.04.15.02.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:10:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 63A221C1B9E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:10:39 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 28/28] mm, page_alloc: Defer debugging checks of pages allocated from the PCP
Date: Fri, 15 Apr 2016 10:07:55 +0100
Message-Id: <1460711275-1130-16-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Every page allocated checks a number of page fields for validity. This
catches corruption bugs of pages that are already freed but it is expensive.
This patch weakens the debugging check by checking PCP pages only when
the PCP lists are being refilled. All compound pages are checked. This
potentially avoids debugging checks entirely if the PCP lists are never
emptied and refilled so some corruption issues may be missed. Full checking
requires DEBUG_VM.

With the two deferred debugging patches applied, the impact to a page
allocator microbenchmark is

                                           4.6.0-rc3                  4.6.0-rc3
                                         inline-v3r6            deferalloc-v3r7
Min      alloc-odr0-1               344.00 (  0.00%)           317.00 (  7.85%)
Min      alloc-odr0-2               248.00 (  0.00%)           231.00 (  6.85%)
Min      alloc-odr0-4               209.00 (  0.00%)           192.00 (  8.13%)
Min      alloc-odr0-8               181.00 (  0.00%)           166.00 (  8.29%)
Min      alloc-odr0-16              168.00 (  0.00%)           154.00 (  8.33%)
Min      alloc-odr0-32              161.00 (  0.00%)           148.00 (  8.07%)
Min      alloc-odr0-64              158.00 (  0.00%)           145.00 (  8.23%)
Min      alloc-odr0-128             156.00 (  0.00%)           143.00 (  8.33%)
Min      alloc-odr0-256             168.00 (  0.00%)           154.00 (  8.33%)
Min      alloc-odr0-512             178.00 (  0.00%)           167.00 (  6.18%)
Min      alloc-odr0-1024            186.00 (  0.00%)           174.00 (  6.45%)
Min      alloc-odr0-2048            192.00 (  0.00%)           180.00 (  6.25%)
Min      alloc-odr0-4096            198.00 (  0.00%)           184.00 (  7.07%)
Min      alloc-odr0-8192            200.00 (  0.00%)           188.00 (  6.00%)
Min      alloc-odr0-16384           201.00 (  0.00%)           188.00 (  6.47%)
Min      free-odr0-1                189.00 (  0.00%)           180.00 (  4.76%)
Min      free-odr0-2                132.00 (  0.00%)           126.00 (  4.55%)
Min      free-odr0-4                104.00 (  0.00%)            99.00 (  4.81%)
Min      free-odr0-8                 90.00 (  0.00%)            85.00 (  5.56%)
Min      free-odr0-16                84.00 (  0.00%)            80.00 (  4.76%)
Min      free-odr0-32                80.00 (  0.00%)            76.00 (  5.00%)
Min      free-odr0-64                78.00 (  0.00%)            74.00 (  5.13%)
Min      free-odr0-128               77.00 (  0.00%)            73.00 (  5.19%)
Min      free-odr0-256               94.00 (  0.00%)            91.00 (  3.19%)
Min      free-odr0-512              108.00 (  0.00%)           112.00 ( -3.70%)
Min      free-odr0-1024             115.00 (  0.00%)           118.00 ( -2.61%)
Min      free-odr0-2048             120.00 (  0.00%)           125.00 ( -4.17%)
Min      free-odr0-4096             123.00 (  0.00%)           129.00 ( -4.88%)
Min      free-odr0-8192             126.00 (  0.00%)           130.00 ( -3.17%)
Min      free-odr0-16384            126.00 (  0.00%)           131.00 ( -3.97%)

Note that the free paths for large numbers of pages is impacted as the
debugging cost gets shifted into that path when the page data is no longer
necessarily cache-hot.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 92 +++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 64 insertions(+), 28 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b5722790c846..147c0d55ed32 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1704,7 +1704,41 @@ static inline bool free_pages_prezeroed(bool poisoned)
 		page_poisoning_enabled() && poisoned;
 }
 
-static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
+#ifdef CONFIG_DEBUG_VM
+static bool check_pcp_refill(struct page *page)
+{
+	return false;
+}
+
+static bool check_new_pcp(struct page *page)
+{
+	return check_new_page(page);
+}
+#else
+static bool check_pcp_refill(struct page *page)
+{
+	return check_new_page(page);
+}
+static bool check_new_pcp(struct page *page)
+{
+	return false;
+}
+#endif /* CONFIG_DEBUG_VM */
+
+static bool check_new_pages(struct page *page, unsigned int order)
+{
+	int i;
+	for (i = 0; i < (1 << order); i++) {
+		struct page *p = page + i;
+
+		if (unlikely(check_new_page(p)))
+			return true;
+	}
+
+	return false;
+}
+
+static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags)
 {
 	int i;
@@ -1712,8 +1746,6 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
-		if (unlikely(check_new_page(p)))
-			return 1;
 		if (poisoned)
 			poisoned &= page_is_poisoned(p);
 	}
@@ -1745,8 +1777,6 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 		set_page_pfmemalloc(page);
 	else
 		clear_page_pfmemalloc(page);
-
-	return 0;
 }
 
 /*
@@ -2168,6 +2198,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		if (unlikely(page == NULL))
 			break;
 
+		if (unlikely(check_pcp_refill(page)))
+			continue;
+
 		/*
 		 * Split buddy pages returned by expand() are received here
 		 * in physical page order. The page is added to the callers and
@@ -2579,20 +2612,22 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		struct list_head *list;
 
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
+		do {
+			pcp = &this_cpu_ptr(zone->pageset)->pcp;
+			list = &pcp->lists[migratetype];
+			if (list_empty(list)) {
+				pcp->count += rmqueue_bulk(zone, 0,
+						pcp->batch, list,
+						migratetype, cold);
+				if (unlikely(list_empty(list)))
+					goto failed;
+			}
 
-		if (cold)
-			page = list_last_entry(list, struct page, lru);
-		else
-			page = list_first_entry(list, struct page, lru);
+			if (cold)
+				page = list_last_entry(list, struct page, lru);
+			else
+				page = list_first_entry(list, struct page, lru);
+		} while (page && check_new_pcp(page));
 
 		__dec_zone_state(zone, NR_ALLOC_BATCH);
 		list_del(&page->lru);
@@ -2605,14 +2640,16 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
 		spin_lock_irqsave(&zone->lock, flags);
 
-		page = NULL;
-		if (alloc_flags & ALLOC_HARDER) {
-			page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
-			if (page)
-				trace_mm_page_alloc_zone_locked(page, order, migratetype);
-		}
-		if (!page)
-			page = __rmqueue(zone, order, migratetype);
+		do {
+			page = NULL;
+			if (alloc_flags & ALLOC_HARDER) {
+				page = __rmqueue_smallest(zone, order, MIGRATE_HIGHATOMIC);
+				if (page)
+					trace_mm_page_alloc_zone_locked(page, order, migratetype);
+			}
+			if (!page)
+				page = __rmqueue(zone, order, migratetype);
+		} while (page && check_new_pages(page, order));
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
@@ -2979,8 +3016,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		page = buffered_rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
-			if (prep_new_page(page, order, gfp_mask, alloc_flags))
-				goto try_this_zone;
+			prep_new_page(page, order, gfp_mask, alloc_flags);
 
 			/*
 			 * If this is a high-order atomic allocation then check
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
