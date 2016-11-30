Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6428A6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 19:16:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so463466695pgc.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:16:18 -0800 (PST)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id 7si26601464pga.274.2016.11.29.16.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 16:16:17 -0800 (PST)
Received: by mail-pg0-x236.google.com with SMTP id p66so74977335pga.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 16:16:17 -0800 (PST)
Date: Tue, 29 Nov 2016 16:16:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 1/2] mm, zone: track number of movable free pages
In-Reply-To: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1611291615400.103050@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

An upcoming compaction change will need the number of movable free pages
per zone to determine if async compaction will become unnecessarily
expensive.

This patch introduces no functional change or increased memory footprint.
It simply tracks the number of free movable pages as a subset of the
total number of free pages.  This is exported to userspace as part of a
new /proc/vmstat field.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: do not track free pages per migratetype since page allocator stress
     testing reveals this tracking can impact workloads and there is no
     substantial benefit when thp is disabled.  This occurs because
     entire pageblocks can be converted to new migratetypes and requires
     iteration of free_areas in the hotpaths for proper tracking.

 include/linux/mmzone.h | 1 +
 include/linux/vmstat.h | 2 ++
 mm/page_alloc.c        | 8 +++++++-
 mm/vmstat.c            | 1 +
 4 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -138,6 +138,7 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_FREE_CMA_PAGES,
+	NR_FREE_MOVABLE_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum node_stat_item {
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -347,6 +347,8 @@ static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
 	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
 	if (is_migrate_cma(migratetype))
 		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
+	if (migratetype == MIGRATE_MOVABLE)
+		__mod_zone_page_state(zone, NR_FREE_MOVABLE_PAGES, nr_pages);
 }
 
 extern const char * const vmstat_text[];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2197,6 +2197,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	spin_lock(&zone->lock);
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
+		int mt;
+
 		if (unlikely(page == NULL))
 			break;
 
@@ -2217,9 +2219,13 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_pcppage_migratetype(page)))
+		mt = get_pcppage_migratetype(page);
+		if (is_migrate_cma(mt))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
+		if (mt == MIGRATE_MOVABLE)
+			__mod_zone_page_state(zone, NR_FREE_MOVABLE_PAGES,
+					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -945,6 +945,7 @@ const char * const vmstat_text[] = {
 	"numa_other",
 #endif
 	"nr_free_cma",
+	"nr_free_movable",
 
 	/* Node-based counters */
 	"nr_inactive_anon",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
