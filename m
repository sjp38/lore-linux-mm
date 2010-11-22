Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1895B6B008A
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:44:04 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 6/7] mm: compaction: Perform a faster migration scan when migrating asynchronously
Date: Mon, 22 Nov 2010 15:43:54 +0000
Message-Id: <1290440635-30071-7-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
References: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

try_to_compact_pages() is initially called to only migrate pages asychronously
and kswapd always compacts asynchronously. Both are being optimistic so it
is important to complete the work as quickly as possible to minimise stalls.

This patch alters the scanner when asynchronous to only consider
MIGRATE_MOVABLE pageblocks as migration candidates. This reduces stalls
when allocating huge pages while not impairing allocation success rates as
a full scan will be performed if necessary after direct reclaim.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b6e589d..50b0a90 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -240,6 +240,7 @@ static unsigned long isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
+	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
 
@@ -280,6 +281,20 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		if (PageBuddy(page))
 			continue;
 
+		/*
+		 * For async migration, also only scan in MOVABLE blocks. Async
+		 * migration is optimistic to see if the minimum amount of work
+		 * satisfies the allocation
+		 */
+		pageblock_nr = low_pfn >> pageblock_order;
+		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+				get_pageblock_migratetype(page) != MIGRATE_MOVABLE) {
+			low_pfn += pageblock_nr_pages;
+			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
+			last_pageblock_nr = pageblock_nr;
+			continue;
+		}
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
 			continue;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
