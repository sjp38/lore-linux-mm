Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DA7866B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 06:55:13 -0500 (EST)
Received: by wmec201 with SMTP id c201so23028047wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:13 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id z2si17662723wjx.135.2015.11.24.03.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 03:55:11 -0800 (PST)
Received: by wmvv187 with SMTP id v187so205422718wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:55:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, vmscan: do not overestimate anonymous reclaimable pages
Date: Tue, 24 Nov 2015 12:55:00 +0100
Message-Id: <1448366100-11023-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
References: <1448366100-11023-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

zone_reclaimable_pages considers all anonymous pages on LRUs reclaimable
if there is at least one entry on the swap storage left. This can be
really misleading when the swap is short on space and skew reclaim
decisions based on zone_reclaimable_pages. Fix this by clamping the
number to the minimum of the available swap space and anon LRU pages.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 946d348f5040..646001a1f279 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -195,15 +195,20 @@ static bool sane_reclaim(struct scan_control *sc)
 static unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	unsigned long nr;
+	long nr_swap = get_nr_swap_pages();
 
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
 	     zone_page_state(zone, NR_INACTIVE_FILE) +
 	     zone_page_state(zone, NR_ISOLATED_FILE);
 
-	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON) +
-		      zone_page_state(zone, NR_ISOLATED_ANON);
+	if (nr_swap > 0) {
+		unsigned long anon;
+
+		anon = zone_page_state(zone, NR_ACTIVE_ANON) +
+		       zone_page_state(zone, NR_INACTIVE_ANON) +
+		       zone_page_state(zone, NR_ISOLATED_ANON);
+		nr += min_t(unsigned long, nr_swap, anon);
+	}
 
 	return nr;
 }
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
