Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D51706B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:40:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k71so13060392wrc.15
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:40:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f187si1701313wme.20.2017.07.20.06.40.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 06:40:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/4] mm, page_owner: don't grab zone->lock for init_pages_in_zone()
Date: Thu, 20 Jul 2017 15:40:28 +0200
Message-Id: <20170720134029.25268-4-vbabka@suse.cz>
In-Reply-To: <20170720134029.25268-1-vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>, Vlastimil Babka <vbabka@suse.cz>

init_pages_in_zone() is run under zone->lock, which means a long lock time and
disabled interrupts on large machines. This is currently not an issue since it
runs early in boot, but a later patch will change that.
However, like other pfn scanners, we don't actually need zone->lock even when
other cpus are running. The only potentially dangerous operation here is
reading bogus buddy page owner due to race, and we already know how to handle
that. The worse that can happen is that we skip some early allocated pages,
which should not affect the debugging power of page_owner noticeably.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_owner.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 5aa21ca237d9..cf6568d1dc14 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -567,11 +567,17 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 				continue;
 
 			/*
-			 * We are safe to check buddy flag and order, because
-			 * this is init stage and only single thread runs.
+			 * To avoid having to grab zone->lock, be a little
+			 * careful when reading buddy page order. The only
+			 * danger is that we skip too much and potentially miss
+			 * some early allocated pages, which is better than
+			 * heavy lock contention.
 			 */
 			if (PageBuddy(page)) {
-				pfn += (1UL << page_order(page)) - 1;
+				unsigned long order = page_order_unsafe(page);
+
+				if (order > 0 && order < MAX_ORDER)
+					pfn += (1UL << order) - 1;
 				continue;
 			}
 
@@ -590,6 +596,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 			__set_page_owner_init(page_ext, init_handle);
 			count++;
 		}
+		cond_resched();
 	}
 
 	pr_info("Node %d, zone %8s: page owner found early allocated %lu pages\n",
@@ -600,15 +607,12 @@ static void init_zones_in_node(pg_data_t *pgdat)
 {
 	struct zone *zone;
 	struct zone *node_zones = pgdat->node_zones;
-	unsigned long flags;
 
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
 			continue;
 
-		spin_lock_irqsave(&zone->lock, flags);
 		init_pages_in_zone(pgdat, zone);
-		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 }
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
