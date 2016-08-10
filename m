Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09E0A828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:12:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so52614701wme.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:12:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m125si7118996wme.54.2016.08.10.02.12.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 02:12:42 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 04/11] mm, compaction: don't recheck watermarks after COMPACT_SUCCESS
Date: Wed, 10 Aug 2016 11:12:19 +0200
Message-Id: <20160810091226.6709-5-vbabka@suse.cz>
In-Reply-To: <20160810091226.6709-1-vbabka@suse.cz>
References: <20160810091226.6709-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

Joonsoo has reminded me that in a later patch changing watermark checks
throughout compaction I forgot to update checks in try_to_compact_pages() and
compactd_do_work(). Closer inspection however shows that they are redundant now
that compact_zone() reliably reports success with COMPACT_SUCCESS, as they just
repeat (a subset) of checks that have just passed. So instead of checking
watermarks again, just test the return value.

Also remove the stray "bool success" variable from kcompactd_do_work().

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c355bf0d8599..a144f58f7193 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1698,9 +1698,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 					alloc_flags, ac_classzone_idx(ac));
 		rc = max(status, rc);
 
-		/* If a normal allocation would succeed, stop compacting */
-		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
-					ac_classzone_idx(ac), alloc_flags)) {
+		/* The allocation should succeed, stop compacting */
+		if (status == COMPACT_SUCCESS) {
 			/*
 			 * We think the allocation will succeed in this zone,
 			 * but it is not certain, hence the false. The caller
@@ -1873,8 +1872,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		.ignore_skip_hint = true,
 
 	};
-	bool success = false;
-
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
 	count_vm_event(KCOMPACTD_WAKE);
@@ -1903,9 +1900,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 			return;
 		status = compact_zone(zone, &cc);
 
-		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
-						cc.classzone_idx, 0)) {
-			success = true;
+		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
 		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
 			/*
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
