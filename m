Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id D6B1F828E8
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:14:27 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id f198so180818219wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:14:27 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id vv2si15735446wjb.178.2016.04.12.03.14.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:14:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 7BE6A98FDB
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:14:26 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 22/24] mm, page_alloc: Check once if a zone has isolated pageblocks
Date: Tue, 12 Apr 2016 11:12:23 +0100
Message-Id: <1460455945-29644-23-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

When bulk freeing pages from the per-cpu lists the zone is checked
for isolated pageblocks on every release. This patch checks it once
per drain. Technically this is race-prone but so is the existing
code.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fd8489b3055..854925c99c23 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -857,6 +857,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int batch_free = 0;
 	int to_free = count;
 	unsigned long nr_scanned;
+	bool isolated_pageblocks = has_isolate_pageblock(zone);
 
 	spin_lock(&zone->lock);
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
@@ -896,7 +897,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_ISOLATE page should not go to pcplists */
 			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
 			/* Pageblock could have been isolated meanwhile */
-			if (unlikely(has_isolate_pageblock(zone)))
+			if (unlikely(isolated_pageblocks))
 				mt = get_pageblock_migratetype(page);
 
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
