Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9A4F6B04C1
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:53:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f35-v6so3404036plb.10
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:53:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x1-v6si25257590plv.520.2018.05.09.01.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:53:35 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC v3 PATCH 4/5] mm/free_pcppages_bulk: reduce overhead of cluster operation on free path
Date: Wed,  9 May 2018 16:54:49 +0800
Message-Id: <20180509085450.3524-5-aaron.lu@intel.com>
In-Reply-To: <20180509085450.3524-1-aaron.lu@intel.com>
References: <20180509085450.3524-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>

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
index 64afb26064ed..33814ffda507 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1251,6 +1251,36 @@ static inline void prefetch_buddy(struct page *page)
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
@@ -1265,10 +1295,10 @@ static inline void prefetch_buddy(struct page *page)
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
 
@@ -1292,6 +1322,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		/* This is the only non-empty list. Free them all. */
 		if (batch_free == MIGRATE_PCPTYPES)
 			batch_free = count;
+		count_mt[migratetype] += batch_free;
 
 		do {
 			page = list_last_entry(list, struct page, lru);
@@ -1323,12 +1354,24 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
2.14.3
