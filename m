Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F1B1B800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:21:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o28so4233305pgn.6
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:21:28 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 76si147216pga.176.2018.01.24.23.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 23:21:27 -0800 (PST)
Date: Thu, 25 Jan 2018 15:21:44 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 1/2] free_pcppages_bulk: do not hold lock when picking
 pages to free
Message-ID: <20180125072144.GA27678@intel.com>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124163926.c7ptagn655aeiut3@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124163926.c7ptagn655aeiut3@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
the zone->lock is held and then pages are chosen from PCP's migratetype
list. While there is actually no need to do this 'choose part' under
lock since it's PCP pages, the only CPU that can touch them is us and
irq is also disabled.

Moving this part outside could reduce lock held time and improve
performance. Test with will-it-scale/page_fault1 full load:

kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
v4.15-rc4   9037332        8000124       13642741       15728686
this patch  9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%

What the test does is: starts $nr_cpu processes and each will repeatedly
do the following for 5 minutes:
1 mmap 128M anonymouse space;
2 write access to that space;
3 munmap.
The score is the aggregated iteration.

https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c

Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
v2: use LIST_HEAD(head) as suggested by Mel Gorman.

 mm/page_alloc.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4093728f292e..c9e5ded39b16 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1113,12 +1113,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int migratetype = 0;
 	int batch_free = 0;
 	bool isolated_pageblocks;
-
-	spin_lock(&zone->lock);
-	isolated_pageblocks = has_isolate_pageblock(zone);
+	struct page *page, *tmp;
+	LIST_HEAD(head);
 
 	while (count) {
-		struct page *page;
 		struct list_head *list;
 
 		/*
@@ -1140,26 +1138,31 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
-			int mt;	/* migratetype of the to-be-freed page */
-
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 
-			mt = get_pcppage_migratetype(page);
-			/* MIGRATE_ISOLATE page should not go to pcplists */
-			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
-			/* Pageblock could have been isolated meanwhile */
-			if (unlikely(isolated_pageblocks))
-				mt = get_pageblock_migratetype(page);
-
 			if (bulkfree_pcp_prepare(page))
 				continue;
 
-			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
-			trace_mm_page_pcpu_drain(page, 0, mt);
+			list_add_tail(&page->lru, &head);
 		} while (--count && --batch_free && !list_empty(list));
 	}
+
+	spin_lock(&zone->lock);
+	isolated_pageblocks = has_isolate_pageblock(zone);
+
+	list_for_each_entry_safe(page, tmp, &head, lru) {
+		int mt = get_pcppage_migratetype(page);
+		/* MIGRATE_ISOLATE page should not go to pcplists */
+		VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
+		/* Pageblock could have been isolated meanwhile */
+		if (unlikely(isolated_pageblocks))
+			mt = get_pageblock_migratetype(page);
+
+		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
+		trace_mm_page_pcpu_drain(page, 0, mt);
+	}
 	spin_unlock(&zone->lock);
 }
 
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
