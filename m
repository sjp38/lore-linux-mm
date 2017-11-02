Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD0416B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:17:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 5so2612590wmk.13
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:17:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si589511edf.446.2017.11.02.05.17.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:17:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/3] mm, compaction: split off flag for not updating skip hints
Date: Thu,  2 Nov 2017 13:17:05 +0100
Message-Id: <20171102121706.21504-2-vbabka@suse.cz>
In-Reply-To: <20171102121706.21504-1-vbabka@suse.cz>
References: <20171102121706.21504-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Pageblock skip hints were added as a heuristic for compaction, which shares
core code with CMA. Since CMA reliability would suffer from the heuristics,
compact_control flag ignore_skip_hint was added for the CMA use case.
Since commit 6815bf3f233e ("mm/compaction: respect ignore_skip_hint in
update_pageblock_skip") the flag also means that CMA won't *update* the skip
hints in addition to ignoring them.

Today, direct compaction can also ignore the skip hints in the last resort
attempt, but there's no reason not to set them when isolation fails in such
case. Thus, this patch splits off a new no_set_skip_hint flag to avoid the
updating, which only CMA sets. This should improve the heuristics a bit, and
allow us to simplify the persistent skip bit handling as the next step.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 2 +-
 mm/internal.h   | 1 +
 mm/page_alloc.c | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index be7ab160f251..a92860d89679 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -294,7 +294,7 @@ static void update_pageblock_skip(struct compact_control *cc,
 	struct zone *zone = cc->zone;
 	unsigned long pfn;
 
-	if (cc->ignore_skip_hint)
+	if (cc->no_set_skip_hint)
 		return;
 
 	if (!page)
diff --git a/mm/internal.h b/mm/internal.h
index 0aaa05af7833..3e5dc95dc259 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -201,6 +201,7 @@ struct compact_control {
 	const int classzone_idx;	/* zone index of a direct compactor */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
+	bool no_set_skip_hint;		/* Don't mark blocks for skipping */
 	bool ignore_block_suitable;	/* Scan blocks considered unsuitable */
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 67330a438525..79cdac1fee42 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7577,6 +7577,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.zone = page_zone(pfn_to_page(start)),
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
+		.no_set_skip_hint = true,
 		.gfp_mask = current_gfp_context(gfp_mask),
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
