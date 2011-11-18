Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7206B0087
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:58:50 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/5] mm: compaction: Allow compaction to isolate dirty pages
Date: Fri, 18 Nov 2011 16:58:40 +0000
Message-Id: <1321635524-8586-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
noted that compaction does not migrate dirty or writeback pages and
that is was meaningless to pick the page and re-add it to the LRU list.

What was missed during review is that asynchronous migration moves
dirty pages if their ->migratepage callback is migrate_page() because
these can be moved without blocking. This potentially impacted
hugepage allocation success rates by a factor depending on how many
dirty pages are in the system.

This patch partially reverts 39deaf85 to allow migration to isolate
dirty pages again. This increases how much compaction disrupts the
LRU but that is addressed later in the series.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..237560e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -349,9 +349,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
-		if (!cc->sync)
-			mode |= ISOLATE_CLEAN;
-
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
