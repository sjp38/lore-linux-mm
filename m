Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2576B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so6327033wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x128si1558062wmg.35.2016.05.10.00.37.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:07 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 01/13] mm, compaction: don't isolate PageWriteback pages in MIGRATE_SYNC_LIGHT mode
Date: Tue, 10 May 2016 09:35:51 +0200
Message-Id: <1462865763-22084-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>

From: Hugh Dickins <hughd@google.com>

At present MIGRATE_SYNC_LIGHT is allowing __isolate_lru_page() to
isolate a PageWriteback page, which __unmap_and_move() then rejects
with -EBUSY: of course the writeback might complete in between, but
that's not what we usually expect, so probably better not to isolate it.

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c72987603343..481004c73c90 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1146,7 +1146,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	struct page *page;
 	const isolate_mode_t isolate_mode =
 		(sysctl_compact_unevictable_allowed ? ISOLATE_UNEVICTABLE : 0) |
-		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
+		(cc->mode != MIGRATE_SYNC ? ISOLATE_ASYNC_MIGRATE : 0);
 
 	/*
 	 * Start at where we last stopped, or beginning of the zone as
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
