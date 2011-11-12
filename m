Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B32DE900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 12:42:41 -0400 (EDT)
Received: by yib2 with SMTP id 2so4388246yib.14
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:42:40 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/3] compaction accouting fix
Date: Sun, 13 Nov 2011 01:37:43 +0900
Message-Id: <282a4531f23c5e35cfddf089f93559130b4bb660.1321112552.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1321112552.git.minchan.kim@gmail.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1321112552.git.minchan.kim@gmail.com>
References: <cover.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

I saw the following accouting of compaction during test of the series.

compact_blocks_moved 251
compact_pages_moved 44

It's very awkward to me although it's possbile because it means we try to compact 251 blocks
but it just migrated 44 pages. As further investigation, I found isolate_migratepages doesn't
isolate any pages but it returns ISOLATE_SUCCESS and then, it just increases compact_blocks_moved
but doesn't increased compact_pages_moved.

This patch makes accouting of compaction works only in case of success of isolation.

CC: Mel Gorman <mgorman@suse.de>
CC: Johannes Weiner <jweiner@redhat.com>
CC: Rik van Riel <riel@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0e572d1..bb3a209 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -260,6 +260,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
	unsigned long low_pfn, end_pfn;
	unsigned long last_pageblock_nr = 0, pageblock_nr;
	unsigned long nr_scanned = 0, nr_isolated = 0;
+	isolate_migrate_t ret = ISOLATE_NONE;
	struct list_head *migratelist = &cc->migratepages;
	isolate_mode_t mode = ISOLATE_ACTIVE| ISOLATE_INACTIVE |
				ISOLATE_UNEVICTABLE;
@@ -273,7 +274,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
	/* Do not cross the free scanner or scan within a memory hole */
	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
		cc->migrate_pfn = end_pfn;
-		return ISOLATE_NONE;
+		return ret;
	}

	/*
@@ -370,14 +371,17 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
			break;
	}

-	acct_isolated(zone, cc);
+	if (cc->nr_migratepages > 0) {
+		acct_isolated(zone, cc);
+		ret = ISOLATE_SUCCESS;
+	}

	spin_unlock_irq(&zone->lru_lock);
	cc->migrate_pfn = low_pfn;

	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);

-	return ISOLATE_SUCCESS;
+	return ret;
 }

 /*
--
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
