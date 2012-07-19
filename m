Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id DFA286B006E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:57 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/34] mm: compaction: Allow compaction to isolate dirty pages
Date: Thu, 19 Jul 2012 15:36:26 +0100
Message-Id: <1342708604-26540-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit a77ebd333cd810d7b680d544be88c875131c2bd3 upstream.

Stable note: Not tracked in Bugzilla. A fix aimed at preserving page aging
	information by reducing LRU list churning had the side-effect of
	reducing THP allocation success rates. This was part of a series
	to restore the success rates while preserving the reclaim fix.

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
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 61e68a5..afdc416 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -371,9 +371,6 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
-		if (!cc->sync)
-			mode |= ISOLATE_CLEAN;
-
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
