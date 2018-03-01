Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58F1C6B0005
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 01:27:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e1so2893858pfi.10
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 22:27:53 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b60-v6si2536498plc.830.2018.02.28.22.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 22:27:52 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v4 1/3] mm/free_pcppages_bulk: update pcp->count inside
Date: Thu,  1 Mar 2018 14:28:43 +0800
Message-Id: <20180301062845.26038-2-aaron.lu@intel.com>
In-Reply-To: <20180301062845.26038-1-aaron.lu@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

Matthew Wilcox found that all callers of free_pcppages_bulk() currently
update pcp->count immediately after so it's natural to do it inside
free_pcppages_bulk().

No functionality or performance change is expected from this patch.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..faa33eac1635 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1148,6 +1148,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+			pcp->count--;
 
 			mt = get_pcppage_migratetype(page);
 			/* MIGRATE_ISOLATE page should not go to pcplists */
@@ -2416,10 +2417,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	local_irq_save(flags);
 	batch = READ_ONCE(pcp->batch);
 	to_drain = min(pcp->count, batch);
-	if (to_drain > 0) {
+	if (to_drain > 0)
 		free_pcppages_bulk(zone, to_drain, pcp);
-		pcp->count -= to_drain;
-	}
 	local_irq_restore(flags);
 }
 #endif
@@ -2441,10 +2440,8 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 	pset = per_cpu_ptr(zone->pageset, cpu);
 
 	pcp = &pset->pcp;
-	if (pcp->count) {
+	if (pcp->count)
 		free_pcppages_bulk(zone, pcp->count, pcp);
-		pcp->count = 0;
-	}
 	local_irq_restore(flags);
 }
 
@@ -2668,7 +2665,6 @@ static void free_unref_page_commit(struct page *page, unsigned long pfn)
 	if (pcp->count >= pcp->high) {
 		unsigned long batch = READ_ONCE(pcp->batch);
 		free_pcppages_bulk(zone, batch, pcp);
-		pcp->count -= batch;
 	}
 }
 
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
