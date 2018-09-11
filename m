Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90CC28E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:38 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w18-v6so11074340plp.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:37 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 6/9] use atomic for free_area[order].nr_free
Date: Tue, 11 Sep 2018 13:36:13 +0800
Message-Id: <20180911053616.6894-7-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Since we will make free path run concurrently, free_area[].nr_free has
to be atomic.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 12 ++++++------
 mm/vmstat.c            |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 84cfa56e2d19..e66b8c63d5d1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -95,7 +95,7 @@ extern int page_group_by_mobility_disabled;
 
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
-	unsigned long		nr_free;
+	atomic_long_t		nr_free;
 };
 
 struct pglist_data;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0b954783f1d..dff3edc60d71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -701,7 +701,7 @@ static inline void add_to_buddy_common(struct page *page, struct zone *zone,
 					unsigned int order)
 {
 	set_page_order(page, order);
-	zone->free_area[order].nr_free++;
+	atomic_long_inc(&zone->free_area[order].nr_free);
 }
 
 static inline void add_to_buddy_head(struct page *page, struct zone *zone,
@@ -728,7 +728,7 @@ static inline void remove_from_buddy(struct page *page, struct zone *zone,
 					unsigned int order)
 {
 	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
+	atomic_long_dec(&zone->free_area[order].nr_free);
 	rmv_page_order(page);
 }
 
@@ -2225,7 +2225,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	int i;
 	int fallback_mt;
 
-	if (area->nr_free == 0)
+	if (atomic_long_read(&area->nr_free) == 0)
 		return -1;
 
 	*can_steal = false;
@@ -3178,7 +3178,7 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		struct free_area *area = &z->free_area[o];
 		int mt;
 
-		if (!area->nr_free)
+		if (atomic_long_read(&area->nr_free) == 0)
 			continue;
 
 		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
@@ -5029,7 +5029,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			struct free_area *area = &zone->free_area[order];
 			int type;
 
-			nr[order] = area->nr_free;
+			nr[order] = atomic_long_read(&area->nr_free);
 			total += nr[order] << order;
 
 			types[order] = 0;
@@ -5562,7 +5562,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
-		zone->free_area[order].nr_free = 0;
+		atomic_long_set(&zone->free_area[order].nr_free, 0);
 	}
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 06d79271a8ae..c1985550bb9f 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1030,7 +1030,7 @@ static void fill_contig_page_info(struct zone *zone,
 		unsigned long blocks;
 
 		/* Count number of free blocks */
-		blocks = zone->free_area[order].nr_free;
+		blocks = atomic_long_read(&zone->free_area[order].nr_free);
 		info->free_blocks_total += blocks;
 
 		/* Count free base pages */
@@ -1353,7 +1353,7 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 
 	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
 	for (order = 0; order < MAX_ORDER; ++order)
-		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+		seq_printf(m, "%6lu ", atomic_long_read(&zone->free_area[order].nr_free));
 	seq_putc(m, '\n');
 }
 
-- 
2.17.1
