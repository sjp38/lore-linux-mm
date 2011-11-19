Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5E8746B0073
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 14:54:38 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 6/8] Revert "mm: compaction: make isolate_lru_page() filter-aware"
Date: Sat, 19 Nov 2011 20:54:18 +0100
Message-Id: <1321732460-14155-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

This reverts commit
39deaf8585152f1a35c1676d3d7dc6ae0fb65967.

PageDirty is non blocking for compaction (unlike for
mm/vmscan.c:may_writepage) so async compaction should include it.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/compaction.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9a7fbf5..83bf33f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -261,7 +261,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
-	isolate_mode_t mode = ISOLATE_ACTIVE|ISOLATE_INACTIVE;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -350,7 +349,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode, 0) != 0)
+		if (__isolate_lru_page(page,
+				ISOLATE_ACTIVE|ISOLATE_INACTIVE, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
