Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B76A6B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:52:51 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 4so7669578plb.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:52:51 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i127si604972pgc.100.2018.02.26.05.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 05:52:50 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v3 1/3] mm/free_pcppages_bulk: update pcp->count inside
Date: Mon, 26 Feb 2018 21:53:44 +0800
Message-Id: <20180226135346.7208-2-aaron.lu@intel.com>
In-Reply-To: <20180226135346.7208-1-aaron.lu@intel.com>
References: <20180226135346.7208-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

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
index cb416723538f..3154859cccd6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1117,6 +1117,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int batch_free = 0;
 	bool isolated_pageblocks;
 
+	pcp->count -= count;
 	spin_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 
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
