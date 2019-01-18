Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52F598E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 12:55:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so5265197ede.14
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:55:02 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id l17si5873171edq.20.2019.01.18.09.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 09:55:00 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 4B9D31C3064
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 17:55:00 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/22] mm, compaction: Round-robin the order while searching the free lists for a target
Date: Fri, 18 Jan 2019 17:51:33 +0000
Message-Id: <20190118175136.31341-20-mgorman@techsingularity.net>
In-Reply-To: <20190118175136.31341-1-mgorman@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

As compaction proceeds and creates high-order blocks, the free list
search gets less efficient as the larger blocks are used as compaction
targets. Eventually, the larger blocks will be behind the migration
scanner for partially migrated pageblocks and the search fails. This
patch round-robins what orders are searched so that larger blocks can be
ignored and find smaller blocks that can be used as migration targets.

The overall impact was small on 1-socket but it avoids corner cases where
the migration/free scanners meet prematurely or situations where many of
the pageblocks encountered by the free scanner are almost full instead of
being properly packed. Previous testing had indicated that without this
patch there were occasional large spikes in the free scanner without this
patch.

[dan.carpenter@oracle.com: Fix static checker warning]
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 33 ++++++++++++++++++++++++++++++---
 mm/internal.h   |  3 ++-
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 04ec7d4da719..7d39ff08269a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1147,6 +1147,24 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 		set_pageblock_skip(page);
 }
 
+/* Search orders in round-robin fashion */
+static int next_search_order(struct compact_control *cc, int order)
+{
+	order--;
+	if (order < 0)
+		order = cc->order - 1;
+
+	/* Search wrapped around? */
+	if (order == cc->search_order) {
+		cc->search_order--;
+		if (cc->search_order < 0)
+			cc->search_order = cc->order - 1;
+		return -1;
+	}
+
+	return order;
+}
+
 static unsigned long
 fast_isolate_freepages(struct compact_control *cc)
 {
@@ -1183,9 +1201,15 @@ fast_isolate_freepages(struct compact_control *cc)
 	if (WARN_ON_ONCE(min_pfn > low_pfn))
 		low_pfn = min_pfn;
 
-	for (order = cc->order - 1;
-	     order >= 0 && !page;
-	     order--) {
+	/*
+	 * Search starts from the last successful isolation order or the next
+	 * order to search after a previous failure
+	 */
+	cc->search_order = min_t(unsigned int, cc->order - 1, cc->search_order);
+
+	for (order = cc->search_order;
+	     !page && order >= 0;
+	     order = next_search_order(cc, order)) {
 		struct free_area *area = &cc->zone->free_area[order];
 		struct list_head *freelist;
 		struct page *freepage;
@@ -1209,6 +1233,7 @@ fast_isolate_freepages(struct compact_control *cc)
 
 			if (pfn >= low_pfn) {
 				cc->fast_search_fail = 0;
+				cc->search_order = order;
 				page = freepage;
 				break;
 			}
@@ -2136,6 +2161,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.total_migrate_scanned = 0,
 		.total_free_scanned = 0,
 		.order = order,
+		.search_order = order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
 		.mode = (prio == COMPACT_PRIO_ASYNC) ?
@@ -2367,6 +2393,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
+		.search_order = pgdat->kcompactd_max_order,
 		.total_migrate_scanned = 0,
 		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
diff --git a/mm/internal.h b/mm/internal.h
index d5b999e5eb5f..31bb0be6fd52 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -192,7 +192,8 @@ struct compact_control {
 	struct zone *zone;
 	unsigned long total_migrate_scanned;
 	unsigned long total_free_scanned;
-	unsigned int fast_search_fail;	/* failures to use free list searches */
+	unsigned short fast_search_fail;/* failures to use free list searches */
+	short search_order;		/* order to start a fast search at */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* migratetype of direct compactor */
-- 
2.16.4
