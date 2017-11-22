Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29E766B0296
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 09:33:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so10233586wrc.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:33:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e18si2039156edd.37.2017.11.22.06.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Nov 2017 06:33:34 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm, compaction: direct freepage allocation for async direct compaction
Date: Wed, 22 Nov 2017 09:33:21 -0500
Message-Id: <20171122143321.29501-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

From: Vlastimil Babka <vbabka@suse.cz>

The goal of direct compaction is to quickly make a high-order page available
for the pending allocation. The free page scanner can add significant latency
when searching for migration targets, although to succeed the compaction, the
only important limit on the target free pages is that they must not come from
the same order-aligned block as the migrated pages.

This patch therefore makes direct async compaction allocate freepages directly
from freelists. Pages that do come from the same block (which we cannot simply
exclude from the freelist allocation) are put on separate list and released
only after migration to allow them to merge.

In addition to reduced stall, another advantage is that we split larger free
pages for migration targets only when smaller pages are depleted, while the
free scanner can split pages up to (order - 1) as it encouters them. However,
this approach likely sacrifices some of the long-term anti-fragmentation
features of a thorough compaction, so we limit the direct allocation approach
to direct async compaction.

For observational purposes, the patch introduces two new counters to
/proc/vmstat. compact_free_direct_alloc counts how many pages were allocated
directly without scanning, and compact_free_direct_miss counts the subset of
these allocations that were from the wrong range and had to be held on the
separate list.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

Hi. I'm resending this because we've been struggling with the cost of
compaction in our fleet, and this patch helps substantially.

On 128G+ machines, we have seen isolate_freepages_block() eat up 40%
of the CPU cycles and scanning up to a billion PFNs per minute. Not in
a spike, but continuously, to service higher-order allocations from
the network stack, fork (non-vmap stacks), THP, etc. during regular
operation.

I've been running this patch on a handful of less-affected but still
pretty bad machines for a week, and the results look pretty great:

	http://cmpxchg.org/compactdirectalloc/compactdirectalloc.png

Note the two different scales - otherwise the compact_free_direct
lines wouldn't be visible. The free scanner peaks close to 10M pages
checked per minute, whereas the direct allocations peak at under 180
per minute, direct misses at 50.

The work doesn't increase over this period, which is a good sign that
long-term we're not trending toward worse fragmentation.

There was an outstanding concern from Joonsoo regarding this patch -
https://marc.info/?l=linux-mm&m=146035962702122&w=2 - although that
didn't seem to affect us much in practice.

 include/linux/vm_event_item.h |  1 +
 mm/compaction.c               | 53 ++++++++++++++++++++++++++++++++++++++++++-
 mm/internal.h                 |  4 ++++
 mm/page_alloc.c               | 27 ++++++++++++++++++++++
 mm/vmstat.c                   |  2 ++
 5 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 5c7f010676a7..81d07a97e8c9 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -55,6 +55,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 #endif
 #ifdef CONFIG_COMPACTION
 		COMPACTMIGRATE_SCANNED, COMPACTFREE_SCANNED,
+		COMPACTFREE_DIRECT_ALLOC, COMPACTFREE_DIRECT_MISS,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 		KCOMPACTD_WAKE,
diff --git a/mm/compaction.c b/mm/compaction.c
index 10cd757f1006..ccc9b157f716 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1160,6 +1160,41 @@ static void isolate_freepages(struct compact_control *cc)
 	cc->free_pfn = isolate_start_pfn;
 }
 
+static void isolate_freepages_direct(struct compact_control *cc)
+{
+	unsigned long nr_pages;
+	unsigned long flags;
+
+	nr_pages = cc->nr_migratepages - cc->nr_freepages;
+
+	if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
+		return;
+
+	while (nr_pages) {
+		struct page *page;
+		unsigned long pfn;
+
+		page = alloc_pages_zone(cc->zone, 0, MIGRATE_MOVABLE);
+		if (!page)
+			break;
+		pfn = page_to_pfn(page);
+
+		count_compact_event(COMPACTFREE_DIRECT_ALLOC);
+
+		/* Is the free page in the block we are migrating from? */
+		if (pfn >> cc->order ==	(cc->migrate_pfn - 1) >> cc->order) {
+			list_add(&page->lru, &cc->freepages_held);
+			count_compact_event(COMPACTFREE_DIRECT_MISS);
+		} else {
+			list_add(&page->lru, &cc->freepages);
+			cc->nr_freepages++;
+			nr_pages--;
+		}
+	}
+
+	spin_unlock_irqrestore(&cc->zone->lock, flags);
+}
+
 /*
  * This is a migrate-callback that "allocates" freepages by taking pages
  * from the isolated freelists in the block we are migrating to.
@@ -1176,7 +1211,12 @@ static struct page *compaction_alloc(struct page *migratepage,
 	 * contention.
 	 */
 	if (list_empty(&cc->freepages)) {
-		if (!cc->contended)
+		if (cc->contended)
+			return NULL;
+
+		if (cc->direct_compaction && (cc->mode == MIGRATE_ASYNC))
+			isolate_freepages_direct(cc);
+		else
 			isolate_freepages(cc);
 
 		if (list_empty(&cc->freepages))
@@ -1637,6 +1677,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 						(cc->mode == MIGRATE_ASYNC)) {
 				cc->migrate_pfn = block_end_pfn(
 						cc->migrate_pfn - 1, cc->order);
+
+				if (!list_empty(&cc->freepages_held))
+					release_freepages(&cc->freepages_held);
+
 				/* Draining pcplists is useless in this case */
 				cc->last_migrated_pfn = 0;
 
@@ -1657,6 +1701,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 				block_start_pfn(cc->migrate_pfn, cc->order);
 
 			if (cc->last_migrated_pfn < current_block_start) {
+				if (!list_empty(&cc->freepages_held))
+					release_freepages(&cc->freepages_held);
 				cpu = get_cpu();
 				lru_add_drain_cpu(cpu);
 				drain_local_pages(zone);
@@ -1687,6 +1733,8 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		if (free_pfn > zone->compact_cached_free_pfn)
 			zone->compact_cached_free_pfn = free_pfn;
 	}
+	if (!list_empty(&cc->freepages_held))
+		release_freepages(&cc->freepages_held);
 
 	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
 	count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
@@ -1721,6 +1769,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.freepages_held);
 
 	ret = compact_zone(zone, &cc);
 
@@ -1839,6 +1888,7 @@ static void compact_node(int nid)
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
+		INIT_LIST_HEAD(&cc.freepages_held);
 
 		compact_zone(zone, &cc);
 
@@ -1979,6 +2029,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
+		INIT_LIST_HEAD(&cc.freepages_held);
 
 		if (kthread_should_stop())
 			return;
diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..191da54dea16 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -161,6 +161,8 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
+extern struct page * alloc_pages_zone(struct zone *zone, unsigned int order,
+							int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
@@ -183,6 +185,8 @@ extern int user_min_free_kbytes;
 struct compact_control {
 	struct list_head freepages;	/* List of free pages to migrate to */
 	struct list_head migratepages;	/* List of pages being migrated */
+	struct list_head freepages_held;/* List of free pages from the block
+					 * that's being migrated */
 	struct zone *zone;
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d4096f4a5c1f..f26acf62b4c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2851,6 +2851,33 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	return page;
 }
 
+/*
+ * Like split_free_page, but given the zone, it will grab a free page from
+ * the freelists.
+ */
+struct page *
+alloc_pages_zone(struct zone *zone, unsigned int order, int migratetype)
+{
+	struct page *page;
+	unsigned long watermark;
+
+	watermark = low_wmark_pages(zone) + (1 << order);
+	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+		return NULL;
+
+	page = __rmqueue(zone, order, migratetype);
+	if (!page)
+		return NULL;
+
+	__mod_zone_freepage_state(zone, -(1 << order),
+					  get_pcppage_migratetype(page));
+
+	set_page_owner(page, order, __GFP_MOVABLE);
+	set_page_refcounted(page);
+
+	return page;
+}
+
 /*
  * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 40b2db6db6b1..52187c5fbd1b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1223,6 +1223,8 @@ const char * const vmstat_text[] = {
 #ifdef CONFIG_COMPACTION
 	"compact_migrate_scanned",
 	"compact_free_scanned",
+	"compact_free_direct_alloc",
+	"compact_free_direct_miss",
 	"compact_isolated",
 	"compact_stall",
 	"compact_fail",
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
