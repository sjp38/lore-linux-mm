Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 140A56B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:16:24 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w37so493727wrc.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:16:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h35si30767106wrh.233.2017.03.07.05.16.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:16:22 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 1/8] mm, compaction: reorder fields in struct compact_control
Date: Tue,  7 Mar 2017 14:15:38 +0100
Message-Id: <20170307131545.28577-2-vbabka@suse.cz>
In-Reply-To: <20170307131545.28577-1-vbabka@suse.cz>
References: <20170307131545.28577-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

While currently there are (mostly by accident) no holes in struct
compact_control (on x86_64), but we are going to add more bool flags, so place
them all together to the end of the structure. While at it, just order all
fields from largest to smallest.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/internal.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 823a7a89099b..05c48a95a20a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -183,6 +183,7 @@ extern int user_min_free_kbytes;
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
+	struct zone *zone;
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long total_migrate_scanned;
@@ -190,16 +191,15 @@ struct compact_control {
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
+	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
+	int order;			/* order a direct compactor needs */
+	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
+	const int classzone_idx;	/* zone index of a direct compactor */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	bool ignore_block_suitable;	/* Scan blocks considered unsuitable */
 	bool direct_compaction;		/* False from kcompactd or /proc/... */
 	bool whole_zone;		/* Whole zone should/has been scanned */
-	int order;			/* order a direct compactor needs */
-	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
-	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
-	const int classzone_idx;	/* zone index of a direct compactor */
-	struct zone *zone;
 	bool contended;			/* Signal lock or sched contention */
 };
 
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
