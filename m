Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6D2E06B0093
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 12:30:17 -0500 (EST)
Received: by pwi6 with SMTP id 6so2366957pwi.14
        for <linux-mm@kvack.org>; Sun, 05 Dec 2010 09:30:16 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 5/7] add profile information for invalidated page reclaim
Date: Mon,  6 Dec 2010 02:29:13 +0900
Message-Id: <dff7a42e5877b23a3cc3355743da4b7ef37299f8.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds profile information about invalidated page reclaim.
It's just for profiling for test so it would be discard when the series
are merged.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/vmstat.h |    4 ++--
 mm/swap.c              |    3 +++
 mm/vmstat.c            |    3 +++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 833e676..c38ad95 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -30,8 +30,8 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
-		PGFAULT, PGMAJFAULT,
+		PGFREE, PGACTIVATE, PGDEACTIVATE, PGINVALIDATE,
+		PGRECLAIM, PGFAULT, PGMAJFAULT,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL),
 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
diff --git a/mm/swap.c b/mm/swap.c
index 0f23998..2f21e6e 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -317,6 +317,7 @@ static void lru_deactivate(struct page *page, struct zone *zone)
 		 * is _really_ small and  it's non-critical problem.
 		 */
 		SetPageReclaim(page);
+		__count_vm_event(PGRECLAIM);
 	} else {
 		/*
 		 * The page's writeback ends up during pagevec
@@ -328,6 +329,8 @@ static void lru_deactivate(struct page *page, struct zone *zone)
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
+
+	__count_vm_event(PGINVALIDATE);
 	update_page_reclaim_stat(zone, page, file, 0);
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 3555636..ef6102d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -818,6 +818,9 @@ static const char * const vmstat_text[] = {
 	"pgactivate",
 	"pgdeactivate",
 
+	"pginvalidate",
+	"pgreclaim",
+
 	"pgfault",
 	"pgmajfault",
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
