Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 928EA828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:20:22 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id a4so213979261wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:20:22 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id d187si40126964wmc.105.2016.02.23.07.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 07:20:21 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 4E68B1C195A
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:20:21 +0000 (GMT)
Date: Tue, 23 Feb 2016 15:20:19 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 23/27] mm, vmscan: Account in vmstat for pages skipped during
 reclaim
Message-ID: <20160223152019.GI2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

Low reclaim efficiency occurs when many pages are scanned that cannot
be reclaimed. This occurs for example when pages are dirty or under
writeback. Node-based LRU reclaim introduces a new source as reclaim
for allocation requests requiring lower zones will skip pages belonging
to higher zones. This patch adds vmstat counters to count pages that
were skipped because the calling context could not use pages from that
zone. It will help distinguish one source of low reclaim efficiency.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/vm_event_item.h | 1 +
 mm/vmscan.c                   | 1 +
 mm/vmstat.c                   | 2 ++
 3 files changed, 4 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 8dcb5a813163..cadaa0f05f67 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -26,6 +26,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
+		FOR_ALL_ZONES(PGSCAN_SKIP),
 		PGREFILL,
 		PGSTEAL_KSWAPD,
 		PGSTEAL_DIRECT,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e92765eb0a1e..a5302b86c032 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1386,6 +1386,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 
 		if (page_zonenum(page) > sc->reclaim_idx) {
 			list_move(&page->lru, &pages_skipped);
+			__count_zone_vm_events(PGSCAN_SKIP, page_zone(page), 1);
 			continue;
 		}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8562ebe2d311..4d8617b02032 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1007,6 +1007,8 @@ const char * const vmstat_text[] = {
 	"pgmajfault",
 	"pglazyfreed",
 
+	TEXTS_FOR_ZONES("pgskip")
+
 	"pgrefill",
 	"pgsteal_kswapd",
 	"pgsteal_direct",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
