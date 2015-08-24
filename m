Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC4482F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:21 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so6518040pac.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:20 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id l3si658468pdg.217.2015.08.23.19.20.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:20 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so84908460pac.2
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:20 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 6/9] mm/compaction: manage separate skip-bits for migration and free scanner
Date: Mon, 24 Aug 2015 11:19:30 +0900
Message-Id: <1440382773-16070-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, just one skip-bit is used for migration and free scanner
at the sametime. This has problem if migrate scanner go into
the region where free scanner marks the skip-bit. Free scanner
just checks if there is freepage or not, so there would be migratable
page. But, due to skip-bit, migrate scanner would skip scanning.

Currently, this doesn't result in any problem because migration scanner
and free scanner always meets similar position in the zone and
stops scanning at that position.

But, following patch will change compaction algorithm that migration
scanner scans whole zone range in order to get much better success rate.
In this case, skip-bit marked from freepage scanner should be ignored
but at the sametime we need to check if there is migratable page and
skip that pageblock in next time. This cannot be achived by just one
skip-bit so this patch add one more skip-bit and use each one
for migrate and free scanner, respectively.

This patch incrases memory usage that each pageblock uses 4 bit more than
before. This means that if we have 1GB memory system we lose another
256 bytes. I think this is really marginal overhead.

Motivation for compaction algorithm change will be mentioned
on following patch. Please refer it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h          |  3 ---
 include/linux/pageblock-flags.h | 37 +++++++++++++++++++++++++++----------
 mm/compaction.c                 | 25 ++++++++++++++++---------
 mm/page_alloc.c                 |  3 ++-
 4 files changed, 45 insertions(+), 23 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5cae0ad..e641fd1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -75,9 +75,6 @@ enum {
 
 extern int page_group_by_mobility_disabled;
 
-#define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
-#define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
-
 #define get_pageblock_migratetype(page)					\
 	get_pfnblock_flags_mask(page, page_to_pfn(page),		\
 			PB_migrate_end, MIGRATETYPE_MASK)
diff --git a/include/linux/pageblock-flags.h b/include/linux/pageblock-flags.h
index 2baeee1..de6997e 100644
--- a/include/linux/pageblock-flags.h
+++ b/include/linux/pageblock-flags.h
@@ -30,8 +30,13 @@ enum pageblock_bits {
 	PB_migrate,
 	PB_migrate_end = PB_migrate + 3 - 1,
 			/* 3 bits required for migrate types */
-	PB_migrate_skip,/* If set the block is skipped by compaction */
+	PB_padding1,	/* Padding for 4 byte aligned migrate types */
+	NR_MIGRATETYPE_BITS,
 
+	PB_skip_migratescan = 4,/* If set the block is skipped by compaction */
+	PB_skip_freescan,
+	PB_padding2,
+	PB_padding3,
 	/*
 	 * Assume the bits will always align on a word. If this assumption
 	 * changes then get/set pageblock needs updating.
@@ -39,6 +44,8 @@ enum pageblock_bits {
 	NR_PAGEBLOCK_BITS
 };
 
+#define MIGRATETYPE_MASK ((1UL << NR_MIGRATETYPE_BITS) - 1)
+
 #ifdef CONFIG_HUGETLB_PAGE
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -87,15 +94,25 @@ void set_pfnblock_flags_mask(struct page *page,
 			(1 << (end_bitidx - start_bitidx + 1)) - 1)
 
 #ifdef CONFIG_COMPACTION
-#define get_pageblock_skip(page) \
-			get_pageblock_flags_group(page, PB_migrate_skip,     \
-							PB_migrate_skip)
-#define clear_pageblock_skip(page) \
-			set_pageblock_flags_group(page, 0, PB_migrate_skip,  \
-							PB_migrate_skip)
-#define set_pageblock_skip(page) \
-			set_pageblock_flags_group(page, 1, PB_migrate_skip,  \
-							PB_migrate_skip)
+#define get_pageblock_skip_migratescan(page) \
+		get_pageblock_flags_group(page, PB_skip_migratescan,	\
+						PB_skip_migratescan)
+#define clear_pageblock_skip_migratescan(page) \
+		set_pageblock_flags_group(page, 0, PB_skip_migratescan,	\
+						PB_skip_migratescan)
+#define set_pageblock_skip_migratescan(page) \
+		set_pageblock_flags_group(page, 1, PB_skip_migratescan,	\
+						PB_skip_migratescan)
+#define get_pageblock_skip_freescan(page) \
+		get_pageblock_flags_group(page, PB_skip_freescan,	\
+						PB_skip_freescan)
+#define clear_pageblock_skip_freescan(page) \
+		set_pageblock_flags_group(page, 0, PB_skip_freescan,	\
+						PB_skip_freescan)
+#define set_pageblock_skip_freescan(page) \
+		set_pageblock_flags_group(page, 1, PB_skip_freescan,	\
+						PB_skip_freescan)
+
 #endif /* CONFIG_COMPACTION */
 
 #endif	/* PAGEBLOCK_FLAGS_H */
diff --git a/mm/compaction.c b/mm/compaction.c
index b58f162..a259608 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -219,12 +219,15 @@ bool compaction_restarting(struct zone *zone, int order)
 
 /* Returns true if the pageblock should be scanned for pages to isolate. */
 static inline bool isolation_suitable(struct compact_control *cc,
-					struct page *page)
+					struct page *page, bool migrate_scanner)
 {
 	if (cc->ignore_skip_hint)
 		return true;
 
-	return !get_pageblock_skip(page);
+	if (migrate_scanner)
+		return !get_pageblock_skip_migratescan(page);
+	else
+		return !get_pageblock_skip_freescan(page);
 }
 
 /*
@@ -275,7 +278,8 @@ static void __reset_isolation_suitable(struct zone *zone)
 		if (zone != page_zone(page))
 			continue;
 
-		clear_pageblock_skip(page);
+		clear_pageblock_skip_migratescan(page);
+		clear_pageblock_skip_freescan(page);
 	}
 }
 
@@ -317,24 +321,27 @@ static void update_pageblock_skip(struct compact_control *cc,
 	if (cc->migration_scan_limit == LONG_MAX && nr_isolated)
 		return;
 
-	if (!nr_isolated)
-		set_pageblock_skip(page);
-
 	/* Update where async and sync compaction should restart */
 	if (migrate_scanner) {
+		if (!nr_isolated)
+			set_pageblock_skip_migratescan(page);
+
 		if (pfn > zone->compact_cached_migrate_pfn[0])
 			zone->compact_cached_migrate_pfn[0] = pfn;
 		if (cc->mode != MIGRATE_ASYNC &&
 		    pfn > zone->compact_cached_migrate_pfn[1])
 			zone->compact_cached_migrate_pfn[1] = pfn;
 	} else {
+		if (!nr_isolated)
+			set_pageblock_skip_freescan(page);
+
 		if (pfn < zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = pfn;
 	}
 }
 #else
 static inline bool isolation_suitable(struct compact_control *cc,
-					struct page *page)
+					struct page *page, bool migrate_scanner)
 {
 	return true;
 }
@@ -1015,7 +1022,7 @@ static void isolate_freepages(struct compact_control *cc)
 			continue;
 
 		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page))
+		if (!isolation_suitable(cc, page, false))
 			continue;
 
 		/* Found a block suitable for isolating free pages from. */
@@ -1154,7 +1161,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* If isolation recently failed, do not retry */
-		if (!isolation_suitable(cc, page))
+		if (!isolation_suitable(cc, page, true))
 			continue;
 
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c67f853..a9a78d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6623,7 +6623,8 @@ void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 	unsigned long bitidx, word_bitidx;
 	unsigned long old_word, word;
 
-	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 4);
+	BUILD_BUG_ON(NR_PAGEBLOCK_BITS != 8);
+	BUILD_BUG_ON(NR_MIGRATETYPE_BITS != 4);
 
 	zone = page_zone(page);
 	bitmap = get_pageblock_bitmap(zone, pfn);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
