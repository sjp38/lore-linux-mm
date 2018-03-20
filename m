Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57CD26B000E
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:53:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w19-v6so699294plq.2
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 01:53:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l185si925211pgd.108.2018.03.20.01.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 01:53:56 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH v2 4/4] mm/free_pcppages_bulk: reduce overhead of cluster operation on free path
Date: Tue, 20 Mar 2018 16:54:52 +0800
Message-Id: <20180320085452.24641-5-aaron.lu@intel.com>
In-Reply-To: <20180320085452.24641-1-aaron.lu@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

After "no_merge for order 0", the biggest overhead in free path for
order 0 pages is now add_to_cluster(). As pages are freed one by one,
it caused frequent operation of add_to_cluster().

Ideally, if only one migratetype pcp list has pages to free and
count=pcp->batch in free_pcppages_bulk(), we can avoid calling
add_to_cluster() one time per page but adding them in one go as
a single cluster. Let's call this ideal case as single_mt and
single_mt_unmovable represents when only unmovable pcp list has
pages and count in free_pcppages_bulk() equals to pcp->batch.
Ditto for single_mt_movable and single_mt_reclaimable.

I added some counters to see how often this ideal case is. On my
desktop, after boot:

free_pcppages_bulk:	6268
single_mt:		3885 (62%)

free_pcppages_bulk means the number of time this function gets called.
single_mt means number of times when only one pcp migratetype list has
pages to be freed and count=pcp->batch.

single_mt can be further devided into the following 3 cases:
single_mt_unmovable:	 263 (4%)
single_mt_movable:	2566 (41%)
single_mt_reclaimable:	1056 (17%)

After kbuild with a distro kconfig:

free_pcppages_bulk:	9100508
single_mt:		8440310 (93%)

Again, single_mt can be further devided:
single_mt_unmovable:	    290 (0%)
single_mt_movable:	8435483 (92.75%)
single_mt_reclaimable:	   4537 (0.05%)

Considering capturing the case of single_mt_movable requires fewer
lines of code and it is the most often ideal case, I think capturing
this case alone is enough.

This optimization brings zone->lock contention down from 25% to
almost zero again using the parallel free workload.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 46 ++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ac93833a2877..ad15e4ef99d6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1281,6 +1281,36 @@ static bool bulkfree_pcp_prepare(struct page *page)
 }
 #endif /* CONFIG_DEBUG_VM */
 
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
@@ -1295,9 +1325,9 @@ static bool bulkfree_pcp_prepare(struct page *page)
 static void free_pcppages_bulk(struct zone *zone, int count,
 					struct per_cpu_pages *pcp)
 {
-	int migratetype = 0;
-	int batch_free = 0;
-	bool isolated_pageblocks;
+	int migratetype = MIGRATE_MOVABLE;
+	int batch_free = 0, saved_count = count;
+	bool isolated_pageblocks, single_mt = false;
 	struct page *page, *tmp;
 	LIST_HEAD(head);
 
@@ -1319,8 +1349,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (list_empty(list));
 
 		/* This is the only non-empty list. Free them all. */
-		if (batch_free == MIGRATE_PCPTYPES)
+		if (batch_free == MIGRATE_PCPTYPES) {
 			batch_free = count;
+			if (batch_free == saved_count)
+				single_mt = true;
+		}
 
 		do {
 			unsigned long pfn, buddy_pfn;
@@ -1359,9 +1392,14 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
