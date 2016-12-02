Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A67B16B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 19:22:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so381699wmw.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 16:22:47 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id y130si520988wmc.29.2016.12.01.16.22.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 16:22:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 2938E98BA3
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 00:22:45 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in sync if struct page is corrupted
Date: Fri,  2 Dec 2016 00:22:43 +0000
Message-Id: <20161202002244.18453-2-mgorman@techsingularity.net>
In-Reply-To: <20161202002244.18453-1-mgorman@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
defer debugging checks of pages allocated from the PCP") will allow the
per-cpu list counter to be out of sync with the per-cpu list contents
if a struct page is corrupted. This patch keeps the accounting in sync.

Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
Signed-off-by: Mel Gorman <mgorman@suse.de>
cc: stable@vger.kernel.org [4.7+]
---
 mm/page_alloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..777ed59570df 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2192,7 +2192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			unsigned long count, struct list_head *list,
 			int migratetype, bool cold)
 {
-	int i;
+	int i, alloced = 0;
 
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
@@ -2217,13 +2217,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
+		alloced++;
 		if (is_migrate_cma(get_pcppage_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
-	return i;
+	return alloced;
 }
 
 #ifdef CONFIG_NUMA
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
