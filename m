Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 868A16B0071
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 12:13:18 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so28683997wid.12
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:13:18 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si6289483wix.41.2014.12.04.09.13.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 09:13:16 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE allocations
Date: Thu,  4 Dec 2014 18:12:57 +0100
Message-Id: <1417713178-10256-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

When allocation falls back to stealing free pages of another migratetype,
it can decide to steal extra pages, or even the whole pageblock in order to
reduce fragmentation, which could happen if further allocation fallbacks
pick a different pageblock. In try_to_steal_freepages(), one of the situations
where extra pages are stolen happens when we are trying to allocate a
MIGRATE_RECLAIMABLE page.

However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
spreading such allocation over multiple fallback pageblocks is arguably even
worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
should minimize the number of such fallbacks, and thus steal as much as is
possible from each fallback pageblock.

This patch thus adds a check for MIGRATE_UNMOVABLE to the decision to steal
extra free pages. When evaluating with stress-highalloc from mmtests, this has
reduced the number of MIGRATE_UNMOVABLE fallbacks to roughly 1/6. The number
of these fallbacks stealing from MIGRATE_MOVABLE block is reduced to 1/3.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 548b072..a14249c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1098,6 +1098,7 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 
 	if (current_order >= pageblock_order / 2 ||
 	    start_type == MIGRATE_RECLAIMABLE ||
+	    start_type == MIGRATE_UNMOVABLE ||
 	    page_group_by_mobility_disabled) {
 		int pages;
 
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
