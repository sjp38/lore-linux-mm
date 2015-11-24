Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 514F96B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:55:11 -0500 (EST)
Received: by wmww144 with SMTP id w144so22926891wmw.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:10 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id 203si2755681wmr.1.2015.11.24.03.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 03:55:10 -0800 (PST)
Received: by wmww144 with SMTP id w144so22926478wmw.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:10 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, vmscan: consider isolated pages in zone_reclaimable_pages
Date: Tue, 24 Nov 2015 12:54:59 +0100
Message-Id: <1448366100-11023-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

zone_reclaimable_pages counts how many pages are reclaimable in
the given zone. This currently includes all pages on file lrus and
anon lrus if there is an available swap storage. We do not consider
NR_ISOLATED_{ANON,FILE} counters though which is not correct because
these counters reflect temporarily isolated pages which are still
reclaimable because they either get back to their LRU or get freed
either by the page reclaim or page migration.

The number of these pages might be sufficiently high to confuse users of
zone_reclaimable_pages (e.g. mbind can migrate large ranges of memory at
once).

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a4507ecaefbf..946d348f5040 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -197,11 +197,13 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
 	unsigned long nr;
 
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+	     zone_page_state(zone, NR_INACTIVE_FILE) +
+	     zone_page_state(zone, NR_ISOLATED_FILE);
 
 	if (get_nr_swap_pages() > 0)
 		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+		      zone_page_state(zone, NR_INACTIVE_ANON) +
+		      zone_page_state(zone, NR_ISOLATED_ANON);
 
 	return nr;
 }
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
