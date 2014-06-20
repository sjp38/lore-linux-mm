Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id BF4666B0038
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:50:10 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so1055734wiv.2
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:50:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gz1si2836120wib.87.2014.06.20.08.50.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:50:09 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 03/13] mm, compaction: do not recheck suitable_migration_target under lock
Date: Fri, 20 Jun 2014 17:49:33 +0200
Message-Id: <1403279383-5862-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

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
index 7c491d0..3064a7f 100644
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
