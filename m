Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D26E8828E1
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:09:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q8so63702489lfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:09:59 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id df10si49487909wjb.224.2016.04.15.02.09.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:09:58 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6408C1DC2A6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:09:58 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/28] mm, page_alloc: Remove unnecessary variable from free_pcppages_bulk
Date: Fri, 15 Apr 2016 10:07:51 +0100
Message-Id: <1460711275-1130-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The original count is never reused so it can be removed.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3a60579342a5..bdcd4087553e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -855,7 +855,6 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 {
 	int migratetype = 0;
 	int batch_free = 0;
-	int to_free = count;
 	unsigned long nr_scanned;
 	bool isolated_pageblocks = has_isolate_pageblock(zone);
 
@@ -864,7 +863,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	if (nr_scanned)
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
-	while (to_free) {
+	while (count) {
 		struct page *page;
 		struct list_head *list;
 
@@ -884,7 +883,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 		/* This is the only non-empty list. Free them all. */
 		if (batch_free == MIGRATE_PCPTYPES)
-			batch_free = to_free;
+			batch_free = count;
 
 		do {
 			int mt;	/* migratetype of the to-be-freed page */
@@ -902,7 +901,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-		} while (--to_free && --batch_free && !list_empty(list));
+		} while (--count && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
