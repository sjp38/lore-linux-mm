Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 514586B000D
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:33:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d69-v6so19012576pgc.22
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 23:33:47 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v202-v6si1081311pgb.96.2018.10.16.23.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 23:33:46 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC v4 PATCH 4/5] mm/free_pcppages_bulk: reduce overhead of cluster operation on free path
Date: Wed, 17 Oct 2018 14:33:29 +0800
Message-Id: <20181017063330.15384-5-aaron.lu@intel.com>
In-Reply-To: <20181017063330.15384-1-aaron.lu@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

After "no_merge for order 0", the biggest overhead in free path for
order 0 pages is now add_to_cluster(). As pages are freed one by one,
it caused frequent operation of add_to_cluster().

Ideally, if only one migratetype pcp list has pages to free and
count=pcp->batch in free_pcppages_bulk(), we can avoid calling
add_to_cluster() one time per page but adding them in one go as
a single cluster so this patch just did this.

This optimization brings zone->lock contention down from 25% to
almost zero again using the parallel free workload.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 49 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 46 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e60a248030dc..204696f6c2f4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1242,6 +1242,36 @@ static inline void prefetch_buddy(struct page *page)
 	prefetch(buddy);
 }
 
+static inline bool free_cluster_pages(struct zone *zone, struct list_head *list,
+				      int mt, int count)
+{
+	struct cluster *c;
+	struct page *page, *n;
+
+	if (!can_skip_merge(zone, 0))
+		return false;
+
+	if (count != this_cpu_ptr(zone->pageset)->pcp.batch)
+		return false;
+
+	c = new_cluster(zone, count, list_first_entry(list, struct page, lru));
+	if (unlikely(!c))
+		return false;
+
+	list_for_each_entry_safe(page, n, list, lru) {
+		set_page_order(page, 0);
+		set_page_merge_skipped(page);
+		page->cluster = c;
+		list_add(&page->lru, &zone->free_area[0].free_list[mt]);
+	}
+
+	INIT_LIST_HEAD(list);
+	zone->free_area[0].nr_free += count;
+	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
+
+	return true;
+}
+
 /*
  * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
@@ -1256,10 +1286,10 @@ static inline void prefetch_buddy(struct page *page)
 static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
-	int migratetype = 0;
-	int batch_free = 0;
+	int migratetype = 0, i, count_mt[MIGRATE_PCPTYPES] = {0};
+	int batch_free = 0, saved_count = count;
 	int prefetch_nr = 0;
-	bool isolated_pageblocks;
+	bool isolated_pageblocks, single_mt = false;
 	struct page *page, *tmp;
 	LIST_HEAD(head);
 
@@ -1283,6 +1313,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		/* This is the only non-empty list. Free them all. */
 		if (batch_free == MIGRATE_PCPTYPES)
 			batch_free = count;
+		count_mt[migratetype] += batch_free;
 
 		do {
 			page = list_last_entry(list, struct page, lru);
@@ -1314,12 +1345,24 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
+	for (i = 0; i < MIGRATE_PCPTYPES; i++) {
+		if (count_mt[i] == saved_count) {
+			single_mt = true;
+			break;
+		}
+	}
+
 	spin_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 
+	if (!isolated_pageblocks && single_mt)
+		free_cluster_pages(zone, &head, migratetype, saved_count);
+
 	/*
 	 * Use safe version since after __free_one_page(),
 	 * page->lru.next will not point to original list.
+	 *
+	 * If free_cluster_pages() succeeds, head will be an empty list here.
 	 */
 	list_for_each_entry_safe(page, tmp, &head, lru) {
 		int mt = get_pcppage_migratetype(page);
-- 
2.17.2
