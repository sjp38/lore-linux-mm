Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2209D6B0037
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:34 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so2901365pab.6
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:33 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id sj5si2938579pab.342.2014.01.08.23.04.31
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:32 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/7] mm/page_alloc: synchronize get/set pageblock
Date: Thu,  9 Jan 2014 16:04:41 +0900
Message-Id: <1389251087-10224-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now get/set pageblock is done without any syncronization. Therefore
there is race condition and migratetype can be unintended value.
Sometime we move some pageblocks from one migratetype to the other
type, and, at the sametime, some page in this pageblock could be
freed. In this case, we can get totally unintended value,
since get/set pageblock don't get/set atomically. Instead, it is
accessed in bit unit.

Since set pageblock isn't used frequently rather than get pageblock,
I think that seqlock is proper method to synchronize it. This type
of lock has minimum overhead if there are a lot of readers and few
of writers. So it fits to this situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e4..feaa607 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -79,6 +79,7 @@ static inline int get_pageblock_migratetype(struct page *page)
 {
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
+void set_pageblock_migratetype(struct page *page, int migratetype);
 
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
@@ -367,6 +368,7 @@ struct zone {
 #endif
 	struct free_area	free_area[MAX_ORDER];
 
+	seqlock_t		pageblock_seqlock;
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 3fff8e7..58e2a89 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -23,7 +23,6 @@ static inline bool is_migrate_isolate(int migratetype)
 
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages);
-void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype);
 int move_freepages(struct zone *zone,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5248fe0..b36aa5a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4788,6 +4788,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
 		zone_seqlock_init(zone);
+		seqlock_init(&zone->pageblock_seqlock);
 		zone->zone_pgdat = pgdat;
 		zone_pcp_init(zone);
 
@@ -5927,15 +5928,19 @@ unsigned long get_pageblock_flags_group(struct page *page,
 	unsigned long pfn, bitidx;
 	unsigned long flags = 0;
 	unsigned long value = 1;
+	unsigned int seq;
 
 	zone = page_zone(page);
 	pfn = page_to_pfn(page);
 	bitmap = get_pageblock_bitmap(zone, pfn);
 	bitidx = pfn_to_bitidx(zone, pfn);
 
-	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
-		if (test_bit(bitidx + start_bitidx, bitmap))
-			flags |= value;
+	do {
+		seq = read_seqbegin(&zone->pageblock_seqlock);
+		for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
+			if (test_bit(bitidx + start_bitidx, bitmap))
+				flags |= value;
+	} while (read_seqretry(&zone->pageblock_seqlock, seq));
 
 	return flags;
 }
@@ -5954,6 +5959,7 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 	unsigned long *bitmap;
 	unsigned long pfn, bitidx;
 	unsigned long value = 1;
+	unsigned long irq_flags;
 
 	zone = page_zone(page);
 	pfn = page_to_pfn(page);
@@ -5961,11 +5967,13 @@ void set_pageblock_flags_group(struct page *page, unsigned long flags,
 	bitidx = pfn_to_bitidx(zone, pfn);
 	VM_BUG_ON(!zone_spans_pfn(zone, pfn));
 
+	write_seqlock_irqsave(&zone->pageblock_seqlock, irq_flags);
 	for (; start_bitidx <= end_bitidx; start_bitidx++, value <<= 1)
 		if (flags & value)
 			__set_bit(bitidx + start_bitidx, bitmap);
 		else
 			__clear_bit(bitidx + start_bitidx, bitmap);
+	write_sequnlock_irqrestore(&zone->pageblock_seqlock, irq_flags);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
