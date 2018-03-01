Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 035BB6B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 01:27:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g66so2897523pfj.11
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 22:27:55 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b60-v6si2536498plc.830.2018.02.28.22.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 22:27:54 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when picking pages to free
Date: Thu,  1 Mar 2018 14:28:44 +0800
Message-Id: <20180301062845.26038-3-aaron.lu@intel.com>
In-Reply-To: <20180301062845.26038-1-aaron.lu@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
the zone->lock is held and then pages are chosen from PCP's migratetype
list. While there is actually no need to do this 'choose part' under
lock since it's PCP pages, the only CPU that can touch them is us and
irq is also disabled.

Moving this part outside could reduce lock held time and improve
performance. Test with will-it-scale/page_fault1 full load:

kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
v4.16-rc2+  9034215        7971818       13667135       15677465
this patch  9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%

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
 mm/page_alloc.c | 39 +++++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index faa33eac1635..dafdcdec9c1f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1116,12 +1116,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
@@ -1143,27 +1141,36 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
-			int mt;	/* migratetype of the to-be-freed page */
-
 			page = list_last_entry(list, struct page, lru);
-			/* must delete as __free_one_page list manipulates */
+			/* must delete to avoid corrupting pcp list */
 			list_del(&page->lru);
 			pcp->count--;
 
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
+	/*
+	 * Use safe version since after __free_one_page(),
+	 * page->lru.next will not point to original list.
+	 */
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
