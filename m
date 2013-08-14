Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 09EFF6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 00:46:13 -0400 (EDT)
Message-ID: <520B0B75.4030708@huawei.com>
Date: Wed, 14 Aug 2013 12:45:41 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: skip the page buddy block instead of one page
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, riel@redhat.com, Minchan Kim <minchan@kernel.org>, aquini@redhat.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

A large free page buddy block will continue many times, so if the page 
is free, skip the whole page buddy block instead of one page.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/compaction.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..874bae1 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -520,9 +520,10 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			goto next_pageblock;
 
 		/* Skip if free */
-		if (PageBuddy(page))
+		if (PageBuddy(page)) {
+			low_pfn += (1 << page_order(page)) - 1;
 			continue;
-
+		}
 		/*
 		 * For async migration, also only scan in MOVABLE blocks. Async
 		 * migration is optimistic to see if the minimum amount of work
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
