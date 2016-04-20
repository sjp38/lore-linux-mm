Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEEB828E8
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 15:47:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so29051167pfy.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:49 -0700 (PDT)
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com. [209.85.192.175])
        by mx.google.com with ESMTPS id r123si17553948pfr.154.2016.04.20.12.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 12:47:48 -0700 (PDT)
Received: by mail-pf0-f175.google.com with SMTP id n1so21476066pfn.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:47:48 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/14] mm, compaction: distinguish between full and partial COMPACT_COMPLETE
Date: Wed, 20 Apr 2016 15:47:18 -0400
Message-Id: <1461181647-8039-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

COMPACT_COMPLETE now means that compaction and free scanner met. This is
not very useful information if somebody just wants to use this feedback
and make any decisions based on that. The current caller might be a poor
guy who just happened to scan tiny portion of the zone and that could be
the reason no suitable pages were compacted. Make sure we distinguish
the full and partial zone walks.

Consumers should treat COMPACT_PARTIAL_SKIPPED as a potential success
and be optimistic in retrying.

The existing users of COMPACT_COMPLETE are conservatively changed to
use COMPACT_PARTIAL_SKIPPED as well but some of them should be probably
reconsidered and only defer the compaction only for COMPACT_COMPLETE
with the new semantic.

This patch shouldn't introduce any functional changes.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h        | 10 +++++++++-
 include/trace/events/compaction.h |  1 +
 mm/compaction.c                   | 14 +++++++++++---
 mm/internal.h                     |  1 +
 4 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 7e177d111c39..7c4de92d12cc 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -21,7 +21,15 @@ enum compact_result {
 	 * pages
 	 */
 	COMPACT_PARTIAL,
-	/* The full zone was compacted */
+	/*
+	 * direct compaction has scanned part of the zone but wasn't successfull
+	 * to compact suitable pages.
+	 */
+	COMPACT_PARTIAL_SKIPPED,
+	/*
+	 * The full zone was compacted scanned but wasn't successfull to compact
+	 * suitable pages.
+	 */
 	COMPACT_COMPLETE,
 	/* For more detailed tracepoint output */
 	COMPACT_NO_SUITABLE_PAGE,
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6ba16c86d7db..36e2d6fb1360 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -14,6 +14,7 @@
 	EM( COMPACT_DEFERRED,		"deferred")		\
 	EM( COMPACT_CONTINUE,		"continue")		\
 	EM( COMPACT_PARTIAL,		"partial")		\
+	EM( COMPACT_PARTIAL_SKIPPED,	"partial_skipped")	\
 	EM( COMPACT_COMPLETE,		"complete")		\
 	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
 	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
diff --git a/mm/compaction.c b/mm/compaction.c
index 13709e33a2fc..e2e487cea5ea 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1304,7 +1304,10 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		if (cc->direct_compaction)
 			zone->compact_blockskip_flush = true;
 
-		return COMPACT_COMPLETE;
+		if (cc->whole_zone)
+			return COMPACT_COMPLETE;
+		else
+			return COMPACT_PARTIAL_SKIPPED;
 	}
 
 	if (is_via_compact_memory(cc->order))
@@ -1463,6 +1466,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
 		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
 	}
+
+	if (cc->migrate_pfn == start_pfn)
+		cc->whole_zone = true;
+
 	cc->last_migrated_pfn = 0;
 
 	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn,
@@ -1693,7 +1700,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			goto break_loop;
 		}
 
-		if (mode != MIGRATE_ASYNC && status == COMPACT_COMPLETE) {
+		if (mode != MIGRATE_ASYNC && (status == COMPACT_COMPLETE ||
+					status == COMPACT_PARTIAL_SKIPPED)) {
 			/*
 			 * We think that allocation won't succeed in this zone
 			 * so we defer compaction there. If it ends up
@@ -1939,7 +1947,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 						cc.classzone_idx, 0)) {
 			success = true;
 			compaction_defer_reset(zone, cc.order, false);
-		} else if (status == COMPACT_COMPLETE) {
+		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
 			/*
 			 * We use sync migration mode here, so we defer like
 			 * sync direct compaction does.
diff --git a/mm/internal.h b/mm/internal.h
index e9aacea1a0d1..4423dfe69382 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -182,6 +182,7 @@ struct compact_control {
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
+	bool whole_zone;		/* Whole zone has been scanned */
 	int order;			/* order a direct compactor needs */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	const int alloc_flags;		/* alloc flags of a direct compactor */
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
