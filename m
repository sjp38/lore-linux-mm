Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0648F900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 14:30:29 -0400 (EDT)
Received: by labge10 with SMTP id ge10so10314788lab.10
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:30:28 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id s4si2807913lag.140.2015.03.11.11.30.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 11:30:27 -0700 (PDT)
Subject: [PATCH RFC] mm: reset pages_scanned only when free pages are above
 high watermark
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Wed, 11 Mar 2015 21:30:23 +0300
Message-ID: <20150311183023.4476.40069.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

Technically, this counter works as OOM-countdown. Let's reset it only
when zone is completely recovered and ready to handle any allocations.
Otherwise system could never recover and stuck in livelock.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/page_alloc.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ffd5ad2a6e10..ef7795c8c121 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -701,7 +701,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 
 	spin_lock(&zone->lock);
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
-	if (nr_scanned)
+	if (nr_scanned &&
+	    zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
 	while (to_free) {
@@ -752,7 +753,8 @@ static void free_one_page(struct zone *zone,
 	unsigned long nr_scanned;
 	spin_lock(&zone->lock);
 	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
-	if (nr_scanned)
+	if (nr_scanned &&
+	    zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
 
 	if (unlikely(has_isolate_pageblock(zone) ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
