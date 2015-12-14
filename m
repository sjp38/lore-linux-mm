Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4945E6B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 00:02:37 -0500 (EST)
Received: by padhk6 with SMTP id hk6so57530013pad.2
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 21:02:37 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id q65si6019937pfi.120.2015.12.13.21.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Dec 2015 21:02:36 -0800 (PST)
Received: by pfbo64 with SMTP id o64so20636151pfb.1
        for <linux-mm@kvack.org>; Sun, 13 Dec 2015 21:02:36 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/2] mm/compaction: speed up pageblock_pfn_to_page() when zone is contiguous
Date: Mon, 14 Dec 2015 14:02:21 +0900
Message-Id: <1450069341-28875-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a performance drop report due to hugepage allocation and in there
half of cpu time are spent on pageblock_pfn_to_page() in compaction [1].
In that workload, compaction is triggered to make hugepage but most of
pageblocks are un-available for compaction due to pageblock type and
skip bit so compaction usually fails. Most costly operations in this case
is to find valid pageblock while scanning whole zone range. To check
if pageblock is valid to compact, valid pfn within pageblock is required
and we can obtain it by calling pageblock_pfn_to_page(). This function
checks whether pageblock is in a single zone and return valid pfn
if possible. Problem is that we need to check it every time before
scanning pageblock even if we re-visit it and this turns out to
be very expensive in this workload.

Although we have no way to skip this pageblock check in the system
where hole exists at arbitrary position, we can use cached value for
zone continuity and just do pfn_to_page() in the system where hole doesn't
exist. This optimization considerably speeds up in above workload.

Before vs After
Max: 1096 MB/s vs 1325 MB/s
Min: 635 MB/s 1015 MB/s
Avg: 899 MB/s 1194 MB/s

Avg is improved by roughly 30% [2].

Not to disturb the system where compaction isn't triggered, checking will
be done at first compaction invocation.

[1]: http://www.spinics.net/lists/linux-mm/msg97378.html
[2]: https://lkml.org/lkml/2015/12/9/23

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 68cc063..cd3736e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -521,6 +521,7 @@ struct zone {
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 	/* Set to true when the PG_migrate_skip bits should be cleared */
 	bool			compact_blockskip_flush;
+	bool			contiguous;
 #endif
 
 	ZONE_PADDING(_pad3_)
diff --git a/mm/compaction.c b/mm/compaction.c
index 56fa321..ce60b38 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -88,7 +88,7 @@ static inline bool migrate_async_suitable(int migratetype)
  * the first and last page of a pageblock and avoid checking each individual
  * page in a pageblock.
  */
-static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
+static struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
 				unsigned long end_pfn, struct zone *zone)
 {
 	struct page *start_page;
@@ -114,6 +114,51 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 	return start_page;
 }
 
+static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
+				unsigned long end_pfn, struct zone *zone)
+{
+	if (zone->contiguous)
+		return pfn_to_page(start_pfn);
+
+	return __pageblock_pfn_to_page(start_pfn, end_pfn, zone);
+}
+
+static void check_zone_contiguous(struct zone *zone)
+{
+	unsigned long block_start_pfn = zone->zone_start_pfn;
+	unsigned long block_end_pfn;
+	unsigned long pfn;
+
+	/* Already initialized if cached pfn is non-zero */
+	if (zone->compact_cached_migrate_pfn[0] ||
+		zone->compact_cached_free_pfn)
+		return;
+
+	/* Mark that checking is in progress */
+	zone->compact_cached_free_pfn = ULONG_MAX;
+
+	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
+	for (; block_start_pfn < zone_end_pfn(zone);
+		block_start_pfn = block_end_pfn,
+		block_end_pfn += pageblock_nr_pages) {
+
+		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
+
+		if (!__pageblock_pfn_to_page(block_start_pfn,
+					block_end_pfn, zone))
+			return;
+
+		/* Check validity of pfn within pageblock */
+		for (pfn = block_start_pfn; pfn < block_end_pfn; pfn++) {
+			if (!pfn_valid_within(pfn))
+				return;
+		}
+	}
+
+	/* We confirm that there is no hole */
+	zone->contiguous = true;
+}
+
 #ifdef CONFIG_COMPACTION
 
 /* Do not skip compaction more than 64 times */
@@ -1357,6 +1402,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		;
 	}
 
+	check_zone_contiguous(zone);
+
 	/*
 	 * Clear pageblock skip if there were failures recently and compaction
 	 * is about to be retried after being deferred. kswapd does not do
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
