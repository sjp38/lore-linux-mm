Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE26E6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 16:19:53 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l66so29113655wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:19:53 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id w8si17766424wjz.7.2016.01.28.13.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 13:19:52 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id 128so4015801wmz.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:19:52 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/3] mm, vmscan: make zone_reclaimable_pages more precise
Date: Thu, 28 Jan 2016 22:19:39 +0100
Message-Id: <1454015979-9985-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

zone_reclaimable_pages is used in should_reclaim_retry which uses it to
calculate the target for the watermark check. This means that precise
numbers are important for the correct decision. zone_reclaimable_pages
uses zone_page_state which can contain stale data with per-cpu diffs
not synced yet (the last vmstat_update might have run 1s in the past).

Use zone_page_state_snapshot in zone_reclaimable_pages instead. None
of the current callers is in a hot path where getting the precise value
(which involves per-cpu iteration) would cause an unreasonable overhead.

Suggested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 489212252cd6..9145e3f89eab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -196,21 +196,21 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	unsigned long nr;
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE) +
-	     zone_page_state(zone, NR_ISOLATED_FILE);
+	nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
+	     zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
+	     zone_page_state_snapshot(zone, NR_ISOLATED_FILE);
 
 	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON) +
-		      zone_page_state(zone, NR_ISOLATED_ANON);
+		nr += zone_page_state_snapshot(zone, NR_ACTIVE_ANON) +
+		      zone_page_state_snapshot(zone, NR_INACTIVE_ANON) +
+		      zone_page_state_snapshot(zone, NR_ISOLATED_ANON);
 
 	return nr;
 }
 
 bool zone_reclaimable(struct zone *zone)
 {
-	return zone_page_state(zone, NR_PAGES_SCANNED) <
+	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
 		zone_reclaimable_pages(zone) * 6;
 }
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
