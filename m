Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5547A6B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j4so955397wrg.15
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si1444243edk.192.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 2/8] mm, compaction: skip_on_failure only for MIGRATE_MOVABLE allocations
Date: Wed, 13 Dec 2017 09:59:09 +0100
Message-Id: <20171213085915.9278-3-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

When migration scanner skips the rest of cc->order aligned block on isolation
failure, it avoids making migrations that cannot help the allocation at hand to
succeed, but the potential downside is not freeing pages in !MIGRATE_MOVABLE
pageblocks which could otherwise prevent allocations of same migratetype from
fallback to other pageblock types. Therefore let's restrict the skipping only
to MIGRATE_MOVABLE allocations, which in the async direct compaction mode only
scan MIGRATE_MOVABLE pageblocks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ce73badad464..95b8b5ae59c5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -720,7 +720,8 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
-	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC)) {
+	if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC) &&
+			cc->migratetype == MIGRATE_MOVABLE) {
 		skip_on_failure = true;
 		next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 	}
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
