Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id F06BB6B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:54:08 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so11639875pdj.33
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:54:08 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xk2si4652379pab.71.2014.02.13.22.54.06
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:54:07 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/5] mm/compaction: do not call suitable_migration_target() on every page
Date: Fri, 14 Feb 2014 15:54:00 +0900
Message-Id: <1392360843-22261-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

suitable_migration_target() checks that pageblock is suitable for
migration target. In isolate_freepages_block(), it is called on every
page and this is inefficient. So make it called once per pageblock.

suitable_migration_target() also checks if page is highorder or not,
but it's criteria for highorder is pageblock order. So calling it once
within pageblock range has no problem.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index bbe1260..0d821a2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -245,6 +245,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long nr_strict_required = end_pfn - blockpfn;
 	unsigned long flags;
 	bool locked = false;
+	bool checked_pageblock = false;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -275,8 +276,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			break;
 
 		/* Recheck this is a suitable migration target under lock */
-		if (!strict && !suitable_migration_target(page))
-			break;
+		if (!strict && !checked_pageblock) {
+			/*
+			 * We need to check suitability of pageblock only once
+			 * and this isolate_freepages_block() is called with
+			 * pageblock range, so just check once is sufficient.
+			 */
+			checked_pageblock = true;
+			if (!suitable_migration_target(page))
+				break;
+		}
 
 		/* Recheck this is a buddy page under lock */
 		if (!PageBuddy(page))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
