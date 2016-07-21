Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62537828E1
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 03:36:27 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so46426419lfw.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 00:36:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si1913376wmf.121.2016.07.21.00.36.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 00:36:23 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 1/8] mm, compaction: don't isolate PageWriteback pages in MIGRATE_SYNC_LIGHT mode
Date: Thu, 21 Jul 2016 09:36:07 +0200
Message-Id: <20160721073614.24395-2-vbabka@suse.cz>
In-Reply-To: <20160721073614.24395-1-vbabka@suse.cz>
References: <20160721073614.24395-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>

From: Hugh Dickins <hughd@google.com>

At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
isolate a PageWriteback page, which __unmap_and_move() then rejects
with -EBUSY: of course the writeback might complete in between, but
that's not what we usually expect, so probably better not to isolate it.

When tested by stress-highalloc from mmtests, this has reduced the number of
page migrate failures by 60-70%.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index cd93ea24c565..892e397655dc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1200,7 +1200,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
-		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
