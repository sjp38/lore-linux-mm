Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE4B6B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:17:11 -0400 (EDT)
Received: by pwi12 with SMTP id 12so457015pwi.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:17:09 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v1 02/10] compaction: trivial clean up acct_isolated
Date: Thu, 12 May 2011 02:16:41 +0900
Message-Id: <46c5756c1c0f212a6d69a8de73542aaf22c605be.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

acct_isolated of compaction uses page_lru_base_type which returns only
base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
In addtion, cc->nr_[anon|file] is used in only acct_isolated so it doesn't have
fields in conpact_control.
This patch removes fields from compact_control and makes clear function of
acct_issolated which counts the number of anon|file pages isolated.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..61eab88 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -35,10 +35,6 @@ struct compact_control {
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
 
-	/* Account for isolated anon and file pages */
-	unsigned long nr_anon;
-	unsigned long nr_file;
-
 	unsigned int order;		/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
@@ -212,17 +208,13 @@ static void isolate_freepages(struct zone *zone,
 static void acct_isolated(struct zone *zone, struct compact_control *cc)
 {
 	struct page *page;
-	unsigned int count[NR_LRU_LISTS] = { 0, };
+	unsigned int count[2] = { 0, };
 
-	list_for_each_entry(page, &cc->migratepages, lru) {
-		int lru = page_lru_base_type(page);
-		count[lru]++;
-	}
+	list_for_each_entry(page, &cc->migratepages, lru)
+		count[!!page_is_file_cache(page)]++;
 
-	cc->nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-	cc->nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->nr_anon);
-	__mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
