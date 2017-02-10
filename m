Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4F0C6B038B
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:23:57 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v67so13759871wrb.4
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 09:23:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k188si1996873wma.76.2017.02.10.09.23.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 09:23:52 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 02/10] mm, compaction: remove redundant watermark check in compact_finished()
Date: Fri, 10 Feb 2017 18:23:35 +0100
Message-Id: <20170210172343.30283-3-vbabka@suse.cz>
In-Reply-To: <20170210172343.30283-1-vbabka@suse.cz>
References: <20170210172343.30283-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

When detecting whether compaction has succeeded in forming a high-order page,
__compact_finished() employs a watermark check, followed by an own search for
a suitable page in the freelists. This is not ideal for two reasons:

- The watermark check also searches high-order freelists, but has a less strict
  criteria wrt fallback. It's therefore redundant and waste of cycles. This was
  different in the past when high-order watermark check attempted to apply
  reserves to high-order pages.

- The watermark check might actually fail due to lack of order-0 pages.
  Compaction can't help with that, so there's no point in continuing because of
  that. It's possible that high-order page still exists and it terminates.

This patch therefore removes the watermark check. This should save some cycles
and terminate compaction sooner in some cases.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0409a4ad6ea1..fc88e7b6fe37 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1291,7 +1291,6 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 			    const int migratetype)
 {
 	unsigned int order;
-	unsigned long watermark;
 
 	if (cc->contended || fatal_signal_pending(current))
 		return COMPACT_CONTENDED;
@@ -1319,13 +1318,6 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 	if (is_via_compact_memory(cc->order))
 		return COMPACT_CONTINUE;
 
-	/* Compaction run is not finished if the watermark is not met */
-	watermark = zone->watermark[cc->alloc_flags & ALLOC_WMARK_MASK];
-
-	if (!zone_watermark_ok(zone, cc->order, watermark, cc->classzone_idx,
-							cc->alloc_flags))
-		return COMPACT_CONTINUE;
-
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &zone->free_area[order];
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
