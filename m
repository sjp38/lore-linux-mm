Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEDE66B025E
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 14:20:23 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so6576162wjd.2
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 11:20:23 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i5si3263244wmf.115.2017.02.02.11.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 11:20:22 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/7] mm: vmscan: kick flushers when we encounter dirty pages on the LRU fix
Date: Thu,  2 Feb 2017 14:19:53 -0500
Message-Id: <20170202191957.22872-4-hannes@cmpxchg.org>
In-Reply-To: <20170202191957.22872-1-hannes@cmpxchg.org>
References: <20170202191957.22872-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mention dirty expiration as a condition: we need dirty data that is too
recent for periodic flushing and not large enough for waking up limit
flushing.  As per Mel.

Link: http://lkml.kernel.org/r/20170126174739.GA30636@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmscan.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 56ea8d24041f..83c92b866afe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1799,14 +1799,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		/*
 		 * If dirty pages are scanned that are not queued for IO, it
 		 * implies that flushers are not doing their job. This can
-		 * happen when memory pressure pushes dirty pages to the end
-		 * of the LRU without the dirty limits being breached. It can
-		 * also happen when the proportion of dirty pages grows not
-		 * through writes but through memory pressure reclaiming all
-		 * the clean cache. And in some cases, the flushers simply
-		 * cannot keep up with the allocation rate. Nudge the flusher
-		 * threads in case they are asleep, but also allow kswapd to
-		 * start writing pages during reclaim.
+		 * happen when memory pressure pushes dirty pages to the end of
+		 * the LRU before the dirty limits are breached and the dirty
+		 * data has expired. It can also happen when the proportion of
+		 * dirty pages grows not through writes but through memory
+		 * pressure reclaiming all the clean cache. And in some cases,
+		 * the flushers simply cannot keep up with the allocation
+		 * rate. Nudge the flusher threads in case they are asleep, but
+		 * also allow kswapd to start writing pages during reclaim.
 		 */
 		if (stat.nr_unqueued_dirty == nr_taken) {
 			wakeup_flusher_threads(0, WB_REASON_VMSCAN);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
