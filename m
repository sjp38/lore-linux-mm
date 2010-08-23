Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 199496B03C3
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:14:18 -0400 (EDT)
Received: by pwi3 with SMTP id 3so2780009pwi.14
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 09:14:16 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] compaction: handle active and inactive fairly in too_many_isolated
Date: Tue, 24 Aug 2010 01:13:48 +0900
Message-Id: <1282580028-1940-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Iram reported compaction's too_many_isolated loops forever.
(http://www.spinics.net/lists/linux-mm/msg08123.html)

The meminfo of situation happened was inactive anon is zero.
That's because the system has no memory pressure until then.
While all anon pages was in active lru, compaction could select
active lru as well as inactive lru. That's different things
with vmscan's isolated. So we has been two too_many_isolated.

While compaction can isolated pages in both active and inactive,
current implementation of too_many_isolated only considers inactive.
It made Iram's problem.

This patch handles active and inactive with fair.
That's because we can't expect where from and how many compaction would
isolated pages.

This patch changes (nr_isolated > nr_inactive) with
nr_isolated > (nr_active + nr_inactive) / 2.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 94cce51..4d709ee 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -214,15 +214,16 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 /* Similar to reclaim, but different enough that they don't share logic */
 static bool too_many_isolated(struct zone *zone)
 {
-
-	unsigned long inactive, isolated;
+	unsigned long active, inactive, isolated;
 
 	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
 					zone_page_state(zone, NR_INACTIVE_ANON);
+	active = zone_page_state(zone, NR_ACTIVE_FILE) +
+					zone_page_state(zone, NR_ACTIVE_ANON);
 	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
 					zone_page_state(zone, NR_ISOLATED_ANON);
 
-	return isolated > inactive;
+	return isolated > (inactive + active) / 2;
 }
 
 /*
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
