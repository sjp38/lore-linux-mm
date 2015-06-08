Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A582900020
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:21 -0400 (EDT)
Received: by wiga1 with SMTP id a1so87458271wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7si5326044wjr.77.2015.06.08.06.57.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:57:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 19/25] mm, vmscan: Account in vmstat for pages skipped during reclaim
Date: Mon,  8 Jun 2015 14:56:25 +0100
Message-Id: <1433771791-30567-20-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Low reclaim efficiency occurs when many pages are scanned that cannot
be reclaimed. This occurs for example when pages are dirty or under
writeback. Node-based LRU reclaim introduces a new source as reclaim
for allocation requests requiring lower zones will skip pages belonging
to higher zones. This patch adds vmstat counters to count pages that
were skipped because the calling context could not use pages from that
zone. It will help distinguish one source of low reclaim efficiency.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/vm_event_item.h | 1 +
 mm/vmscan.c                   | 6 +++++-
 mm/vmstat.c                   | 2 ++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 4ce4d59d361e..95cdd56c65bf 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGREFILL,
 		PGSTEAL_KSWAPD,
 		PGSTEAL_DIRECT,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 69916bb9acba..3cb0cc70ddbd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1326,6 +1326,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
+		struct zone *zone;
 		int nr_pages;
 
 		page = lru_to_page(src);
@@ -1333,8 +1334,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 
-		if (page_zone_id(page) > sc->reclaim_idx)
+		zone = page_zone(page);
+		if (page_zone_id(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
+			__count_zone_vm_events(PGSCAN_SKIP, page_zone(page), 1);
+		}
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4a9f73c4140b..d805df47d3ae 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -957,6 +957,8 @@ const char * const vmstat_text[] = {
 	"pgfault",
 	"pgmajfault",
 
+	TEXTS_FOR_ZONES("pgskip")
+
 	"pgrefill",
 	"pgsteal_kswapd",
 	"pgsteal_direct",
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
