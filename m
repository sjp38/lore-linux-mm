Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id A90F86B0080
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:48:58 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id w61so910591wes.37
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:48:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ep2si24053377wjd.92.2014.07.16.06.48.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:48:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 04/15] mm, compaction: do not recheck suitable_migration_target under lock
Date: Wed, 16 Jul 2014 15:48:12 +0200
Message-Id: <1405518503-27687-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

isolate_freepages_block() rechecks if the pageblock is suitable to be a target
for migration after it has taken the zone->lock. However, the check has been
optimized to occur only once per pageblock, and compact_checklock_irqsave()
might be dropping and reacquiring lock, which means somebody else might have
changed the pageblock's migratetype meanwhile.

Furthermore, nothing prevents the migratetype to change right after
isolate_freepages_block() has finished isolating. Given how imperfect this is,
it's simpler to just rely on the check done in isolate_freepages() without
lock, and not pretend that the recheck under lock guarantees anything. It is
just a heuristic after all.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index f3ae2ec..0a871e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -276,7 +276,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	struct page *cursor, *valid_page = NULL;
 	unsigned long flags;
 	bool locked = false;
-	bool checked_pageblock = false;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -307,18 +306,6 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (!locked)
 			break;
 
-		/* Recheck this is a suitable migration target under lock */
-		if (!strict && !checked_pageblock) {
-			/*
-			 * We need to check suitability of pageblock only once
-			 * and this isolate_freepages_block() is called with
-			 * pageblock range, so just check once is sufficient.
-			 */
-			checked_pageblock = true;
-			if (!suitable_migration_target(page))
-				break;
-		}
-
 		/* Recheck this is a buddy page under lock */
 		if (!PageBuddy(page))
 			goto isolate_fail;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
