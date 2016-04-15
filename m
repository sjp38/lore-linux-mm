Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A52E16B025E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:08:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q8so63681182lfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:08:48 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id ka1si40101947wjb.160.2016.04.15.02.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:08:47 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 471AF1C1B53
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:08:47 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/28] mm, page_alloc: Check once if a zone has isolated pageblocks
Date: Fri, 15 Apr 2016 10:07:44 +0100
Message-Id: <1460711275-1130-5-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

When bulk freeing pages from the per-cpu lists the zone is checked
for isolated pageblocks on every release. This patch checks it once
per drain. Technically this is race-prone but so is the existing
code.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4a364e318873..835a1c434832 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -831,6 +831,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	int batch_free = 0;
 	int to_free = count;
 	unsigned long nr_scanned;
+	bool isolated_pageblocks = has_isolate_pageblock(zone);
 
 	spin_lock(&zone->lock);
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
@@ -870,7 +871,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
