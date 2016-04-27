Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0036B0260
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:24:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so37378288wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:24:55 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id v8si4174911wjf.38.2016.04.27.05.24.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:24:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 386E89894A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:24:47 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/4] mm, page_alloc: Check once if a zone has isolated pageblocks -fix
Date: Wed, 27 Apr 2016 13:24:45 +0100
Message-Id: <1461759885-17163-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
References: <1461759885-17163-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Vlastimil Babka pointed out that the original code was protected by
the zone lock and provided a fix.

This is a fix to the mmotm patch
mm-page_alloc-check-once-if-a-zone-has-isolated-pageblocks.patch . Once
applied the following line should be removed from the changelog "Technically
this is race-prone but so is the existing code."

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 599bd1a49384..269cdb53297c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1098,9 +1098,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int migratetype = 0;
 	int batch_free = 0;
 	unsigned long nr_scanned;
-	bool isolated_pageblocks = has_isolate_pageblock(zone);
+	bool isolated_pageblocks;
 
 	spin_lock(&zone->lock);
+	isolated_pageblocks = has_isolate_pageblock(zone);
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
 	if (nr_scanned)
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
