Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E452A8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so12373407pfe.13
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:46 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:45 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 9/9] mm: page_alloc: merge before sending pages to global pool
Date: Tue, 11 Sep 2018 13:36:16 +0800
Message-Id: <20180911053616.6894-10-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Now that we have mergable pages in Buddy unmerged, this is a step
to reduce such things from happening to some extent.

Suppose two buddy pages are on the list to be freed in free_pcppages_bulk(),
the first page goes to merge but its buddy is not in Buddy yet so we
hold it locally as an order0 page; then its buddy page goes to merge and
couldn't merge either because we hold the first page locally instead of
having it in Buddy. The end result is, we have two mergable buddy pages
but failed to merge it.

So this patch will attempt merge for these to-be-freed pages before
acquiring any lock, it could, to some extent, reduce fragmentation caused
by last patch.

With this change, the pcp_drain trace isn't easy to use so I removed it.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 73 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df38c3f2a1cc..d3eafe857713 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1098,6 +1098,72 @@ void __init percpu_mergelist_init(void)
 	}
 }
 
+static inline bool buddy_in_list(struct page *page, struct page *buddy,
+				 struct list_head *list)
+{
+	list_for_each_entry_continue(page, list, lru)
+		if (page == buddy)
+			return true;
+
+	return false;
+}
+
+static inline void merge_in_pcp(struct list_head *list)
+{
+	int order;
+	struct page *page;
+
+	/* Set order information to 0 initially since they are PCP pages */
+	list_for_each_entry(page, list, lru)
+		set_page_private(page, 0);
+
+	/*
+	 * Check for mergable pages for each order.
+	 *
+	 * For each order, check if their buddy is also in the list and
+	 * if so, do merge, then remove the merged buddy from the list.
+	 */
+	for (order = 0; order < MAX_ORDER - 1; order++) {
+		bool has_merge = false;
+
+		page = list_first_entry(list, struct page, lru);
+		while (&page->lru != list) {
+			unsigned long pfn, buddy_pfn, combined_pfn;
+			struct page *buddy, *n;
+
+			if (page_order(page) != order) {
+				page = list_next_entry(page, lru);
+				continue;
+			}
+
+			pfn = page_to_pfn(page);
+			buddy_pfn = __find_buddy_pfn(pfn, order);
+			buddy = page + (buddy_pfn - pfn);
+			if (!buddy_in_list(page, buddy, list) ||
+			    page_order(buddy) != order) {
+				page = list_next_entry(page, lru);
+				continue;
+			}
+
+			combined_pfn = pfn & buddy_pfn;
+			if (combined_pfn == pfn) {
+				set_page_private(page, order + 1);
+				list_del(&buddy->lru);
+				page = list_next_entry(page, lru);
+			} else {
+				set_page_private(buddy, order + 1);
+				n = list_next_entry(page, lru);
+				list_del(&page->lru);
+				page = n;
+			}
+			has_merge = true;
+		}
+
+		if (!has_merge)
+			break;
+	}
+}
+
 /*
  * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
@@ -1165,6 +1231,12 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
+	/*
+	 * Before acquiring the possibly heavily contended zone lock, do merge
+	 * among these to-be-freed PCP pages before sending them to Buddy.
+	 */
+	merge_in_pcp(&head);
+
 	read_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 
@@ -1182,10 +1254,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		if (unlikely(isolated_pageblocks))
 			mt = get_pageblock_migratetype(page);
 
-		order = 0;
+		order = page_order(page);
 		merged_page = do_merge(page, page_to_pfn(page), zone, &order, mt);
 		list_add(&merged_page->lru, this_cpu_ptr(&merge_lists[order][mt]));
-		trace_mm_page_pcpu_drain(page, 0, mt);
 	}
 
 	for_each_migratetype_order(order, migratetype) {
-- 
2.17.1
