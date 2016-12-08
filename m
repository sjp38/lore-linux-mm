Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD726B0069
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 20:50:14 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c4so627252825pfb.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 17:50:14 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id w5si26412190pfl.121.2016.12.07.17.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 17:50:13 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id c4so80412158pfb.1
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 17:50:12 -0800 (PST)
Date: Wed, 7 Dec 2016 17:50:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: add vmstats for kcompactd work
Message-ID: <alpine.DEB.2.10.1612071749390.69852@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A "compact_daemon_wake" vmstat exists that represents the number of times
kcompactd has woken up.  This doesn't represent how much work it actually
did, though.

It's useful to understand how much compaction work is being done by
kcompactd versus other methods such as direct compaction and explicitly
triggered per-node (or system) compaction.

This adds two new vmstats: "compact_daemon_migrate_scanned" and
"compact_daemon_free_scanned" to represent the number of pages kcompactd
has scanned as part of its migration scanner and freeing scanner,
respectively.

These values are still accounted for in the general
"compact_migrate_scanned" and "compact_free_scanned" for compatibility.

It could be argued that explicitly triggered compaction could also be
tracked separately, and that could be added if others find it useful.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/vm_event_item.h |  1 +
 mm/compaction.c               | 22 +++++++++++++++++++---
 mm/internal.h                 |  2 ++
 mm/vmstat.c                   |  2 ++
 4 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -56,6 +56,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		COMPACTISOLATED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 		KCOMPACTD_WAKE,
+		KCOMPACTD_MIGRATE_SCANNED, KCOMPACTD_FREE_SCANNED,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -548,7 +548,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	if (blockpfn == end_pfn)
 		update_pageblock_skip(cc, valid_page, total_isolated, false);
 
-	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
+	cc->total_free_scanned += nr_scanned;
 	if (total_isolated)
 		count_compact_events(COMPACTISOLATED, total_isolated);
 	return total_isolated;
@@ -939,7 +939,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
-	count_compact_events(COMPACTMIGRATE_SCANNED, nr_scanned);
+	cc->total_migrate_scanned += nr_scanned;
 	if (nr_isolated)
 		count_compact_events(COMPACTISOLATED, nr_isolated);
 
@@ -1643,6 +1643,9 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 			zone->compact_cached_free_pfn = free_pfn;
 	}
 
+	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
+	count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
+
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
 
@@ -1657,6 +1660,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
+		.total_migrate_scanned = 0,
+		.total_free_scanned = 0,
 		.order = order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
@@ -1767,6 +1772,8 @@ static void compact_node(int nid)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = -1,
+		.total_migrate_scanned = 0,
+		.total_free_scanned = 0,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 		.whole_zone = true,
@@ -1892,6 +1899,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
+		.total_migrate_scanned = 0,
+		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = true,
@@ -1899,7 +1908,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	};
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
-	count_vm_event(KCOMPACTD_WAKE);
+	count_compact_event(KCOMPACTD_WAKE);
 
 	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
 		int status;
@@ -1917,6 +1926,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		cc.nr_freepages = 0;
 		cc.nr_migratepages = 0;
+		cc.total_migrate_scanned = 0;
+		cc.total_free_scanned = 0;
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
@@ -1935,6 +1946,11 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 			defer_compaction(zone, cc.order);
 		}
 
+		count_compact_events(KCOMPACTD_MIGRATE_SCANNED,
+				     cc.total_migrate_scanned);
+		count_compact_events(KCOMPACTD_FREE_SCANNED,
+				     cc.total_free_scanned);
+
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
 	}
diff --git a/mm/internal.h b/mm/internal.h
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -173,6 +173,8 @@ struct compact_control {
 	struct list_head migratepages;	/* List of pages being migrated */
 	unsigned long nr_freepages;	/* Number of isolated free pages */
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
+	unsigned long total_migrate_scanned;
+	unsigned long total_free_scanned;
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1038,6 +1038,8 @@ const char * const vmstat_text[] = {
 	"compact_fail",
 	"compact_success",
 	"compact_daemon_wake",
+	"compact_daemon_migrate_scanned",
+	"compact_daemon_free_scanned",
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
