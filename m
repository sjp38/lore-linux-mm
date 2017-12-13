Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA106B026A
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:00:06 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so898186wmc.3
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:00:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q17si1365718edg.39.2017.12.13.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 01:00:00 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 6/8] mm, compaction: prescan before isolating in skip_on_failure mode
Date: Wed, 13 Dec 2017 09:59:13 +0100
Message-Id: <20171213085915.9278-7-vbabka@suse.cz>
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
References: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

When migration scanner skips cc->order aligned block where a page cannot be
isolated, it could have isolated some pages already and they have to be put
back, which is wasted work. Worse, since we can only isolate and migrate up to
COMPACT_CLUSTER_MAX pages (which is 32) we might have already migrated a number
of pages before finding a page that can't be isolated. This can be a lot of
wasted effort e.g. for a THP allocation (512 pages on x86).

This patch introduces "pre-scanning" in the migration scanner which checks for
a whole cc->order aligned block to contain pages that can be isolated, before
actually starting to isolate them. There is a new vmstat counter
compact_migrate_prescanned to monitor its activity. The result is that some
pages will be scanned twice, but that should be relatively cheap. Importantly,
the patch should avoid isolations and migrations that do not lead to the
cc->order free page to be formed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/vm_event_item.h |   1 +
 mm/compaction.c               | 105 ++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h                 |   1 +
 mm/vmstat.c                   |   1 +
 4 files changed, 108 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 5c7f010676a7..cf92b1f115ee 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -55,6 +55,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 #ifdef CONFIG_COMPACTION
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTMIGRATE_PRESCANNED,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 		KCOMPACTD_WAKE,
diff --git a/mm/compaction.c b/mm/compaction.c
index 1ef090aa96e6..99c34a903688 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -743,6 +743,92 @@ check_isolate_candidate(struct page *page, unsigned long *pfn,
 	return CANDIDATE_LRU;
 }
 
+/*
+ * Scan the pages between prescan_pfn and end_pfn for a cc->order aligned block
+ * of pages that all can be isolated for migration (or are free), but do not
+ * actually isolate them. Return the first pfn (of a non-free page) in that
+ * block, so that actual isolation can begin from there, or end_pfn if no such
+ * block was found.
+ *
+ * The highest prescanned page is stored in cc->prescan_pfn.
+ */
+static unsigned long
+prescan_migratepages_block(unsigned long prescan_pfn, unsigned long end_pfn,
+		struct compact_control *cc, struct page *valid_page,
+		bool *skipped_pages)
+{
+	bool prescan_found = false;
+	unsigned long scan_start_pfn = prescan_pfn;
+	unsigned long next_skip_pfn = block_end_pfn(prescan_pfn, cc->order);
+	struct page *page;
+	unsigned long nr_prescanned = 0;
+
+	for(; prescan_pfn < end_pfn; prescan_pfn++) {
+		enum candidate_status status;
+
+		if (prescan_pfn >= next_skip_pfn) {
+			/*
+			 * We found at least one candidate in the last block and
+			 * did not see any non-migratable pages. Go isolate.
+			 */
+			if (prescan_found)
+				break;
+
+			/*
+			 * No luck with the last block, try the next one. Also
+			 * make sure the proper scan skips the former.
+			 */
+			next_skip_pfn = block_end_pfn(prescan_pfn, cc->order);
+			scan_start_pfn = prescan_pfn;
+		}
+
+		if (!(prescan_pfn % SWAP_CLUSTER_MAX))
+			cond_resched();
+
+		if (!pfn_valid_within(prescan_pfn))
+			goto scan_fail;
+		nr_prescanned++;
+
+		page = pfn_to_page(prescan_pfn);
+		if (!valid_page)
+			valid_page = page;
+
+		status = check_isolate_candidate(page, &prescan_pfn, cc);
+
+		if (status == CANDIDATE_FREE) {
+			/*
+			 * if we have only seen free pages so far, update the
+			 * proper scanner's starting pfn to skip over them.
+			 */
+			if (!prescan_found)
+				scan_start_pfn = prescan_pfn;
+			continue;
+		}
+
+		if (status != CANDIDATE_FAIL) {
+			prescan_found = true;
+			continue;
+		}
+
+scan_fail:
+		/*
+		 * We found a page that doesn't seem migratable. Skip the rest
+		 * of the block.
+		 */
+		prescan_found = false;
+		if (prescan_pfn < next_skip_pfn - 1) {
+			prescan_pfn = next_skip_pfn - 1;
+			*skipped_pages = true;
+		}
+	}
+
+	cc->prescan_pfn = min(prescan_pfn, end_pfn);
+	if (nr_prescanned)
+		count_compact_events(COMPACTMIGRATE_PRESCANNED, nr_prescanned);
+
+	return scan_start_pfn;
+}
+
 /**
  * isolate_migratepages_block() - isolate all migrate-able pages within
  *				  a single pageblock
@@ -776,6 +862,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	struct page *page = NULL;
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false, skipped_pages = false;
+	bool prescan_block = false;
 	unsigned long next_skip_pfn = 0;
 	int pageblock_mt;
 
@@ -798,15 +885,33 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	if (compact_should_abort(cc))
 		return 0;
 
+	/*
+	 * If we are skipping blocks where isolation has failed, we also don't
+	 * attempt to isolate, until we prescan the whole cc->order block ahead
+	 * to check that it contains only pages that can be isolated (or free).
+	 */
 	if (cc->direct_compaction && !cc->finishing_block) {
 		pageblock_mt = get_pageblock_migratetype(valid_page);
 		if (pageblock_mt == MIGRATE_MOVABLE
 		    && cc->migratetype == MIGRATE_MOVABLE) {
+			prescan_block = true;
 			skip_on_failure = true;
 			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
 		}
 	}
 
+	/*
+	 * Because we can only isolate COMPACT_CLUSTER_MAX pages at a time, it's
+	 * possible that we already prescanned the block on the previous call of
+	 * this function.
+	 */
+	if (prescan_block && cc->prescan_pfn < next_skip_pfn) {
+		low_pfn = prescan_migratepages_block(low_pfn, end_pfn, cc,
+						valid_page, &skipped_pages);
+		if (skip_on_failure)
+			next_skip_pfn = block_end_pfn(low_pfn, cc->order);
+	}
+
 	/* Time to isolate some pages for migration */
 	for (; low_pfn < end_pfn; low_pfn++) {
 
diff --git a/mm/internal.h b/mm/internal.h
index 3e5dc95dc259..35ff677cf731 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -193,6 +193,7 @@ struct compact_control {
 	unsigned long total_free_scanned;
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	unsigned long prescan_pfn;	/* highest migrate prescanned pfn */
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
 	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
 	int order;			/* order a direct compactor needs */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6db6b1..cf445f8280e4 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1223,6 +1223,7 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_COMPACTION
 	"compact_migrate_scanned",
 	"compact_free_scanned",
+	"compact_migrate_prescanned",
 	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
