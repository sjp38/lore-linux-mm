Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 315DB6B000C
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:32 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id l193so11337130qke.1
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:32 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id s44si5876733qtc.392.2018.01.31.15.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:31 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 03/13] mm: add lock array to pgdat and batch fields to struct page
Date: Wed, 31 Jan 2018 18:04:03 -0500
Message-Id: <20180131230413.27653-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

This patch simply adds the array of locks and struct page fields.
Ignore for now where the struct page fields are: we need to find a place
to put them that doesn't enlarge the struct.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mm_types.h | 5 +++++
 include/linux/mmzone.h   | 7 +++++++
 mm/page_alloc.c          | 3 +++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..6e9d26f0cecf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -190,6 +190,11 @@ struct page {
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 	};
 
+	struct {
+		unsigned lru_batch;
+		bool lru_sentinel;
+	};
+
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *mem_cgroup;
 #endif
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c05529473b80..5ffb36b3f665 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -249,6 +249,11 @@ struct lruvec {
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
+#define NUM_LRU_BATCH_LOCKS 32
+struct lru_batch_lock {
+	spinlock_t lock;
+} ____cacheline_aligned_in_smp;
+
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2)
 /* Isolate for asynchronous migration */
@@ -715,6 +720,8 @@ typedef struct pglist_data {
 
 	unsigned long		flags;
 
+	struct lru_batch_lock lru_batch_locks[NUM_LRU_BATCH_LOCKS];
+
 	ZONE_PADDING(_pad2_)
 
 	/* Per-node vmstats */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7078ed68b01..3248b48e11ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6070,6 +6070,7 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
  */
 static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
+	size_t i;
 	enum zone_type j;
 	int nid = pgdat->node_id;
 
@@ -6092,6 +6093,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
 	lruvec_init(node_lruvec(pgdat));
+	for (i = 0; i < NUM_LRU_BATCH_LOCKS; ++i)
+		spin_lock_init(&pgdat->lru_batch_locks[i].lock);
 
 	pgdat->per_cpu_nodestats = &boot_nodestats;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
