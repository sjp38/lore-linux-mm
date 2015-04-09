Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C0E426B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 22:19:55 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so105770771qkg.1
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 19:19:55 -0700 (PDT)
Received: from BLU004-OMC1S26.hotmail.com (blu004-omc1s26.hotmail.com. [65.55.116.37])
        by mx.google.com with ESMTPS id 197si13024407qhc.26.2015.04.08.19.19.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Apr 2015 19:19:54 -0700 (PDT)
Message-ID: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
From: Neil Zhang <neilzhang1123@hotmail.com>
Subject: [PATCH v2] mm: show free pages per each migrate type
Date: Thu, 9 Apr 2015 10:19:10 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Neil Zhang <neilzhang1123@hotmail.com>

show detailed free pages per each migrate type in show_free_areas.

After apply this patch, the log printed out will be changed from

[   558.212844@0] Normal: 218*4kB (UEMC) 207*8kB (UEMC) 126*16kB (UEMC) 21*32kB (UC) 5*64kB (C) 3*128kB (C) 1*256kB (C) 1*512kB (C) 0*1024kB 0*2048kB 1*4096kB (R) = 10784kB
[   558.227840@0] HighMem: 3*4kB (UMR) 3*8kB (UMR) 2*16kB (UM) 3*32kB (UMR) 0*64kB 1*128kB (M) 1*256kB (R) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 548kB

to

[   806.506450@1] Normal: 8969*4kB 4370*8kB 2*16kB 3*32kB 2*64kB 3*128kB 3*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 74804kB
[   806.517456@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
[   806.527077@1]    Unmovable:   8287   4370      0      0      0      0      0      0      0      0      0
[   806.536699@1]  Reclaimable:    681      0      0      0      0      0      0      0      0      0      0
[   806.546321@1]      Movable:      1      0      0      0      0      0      0      0      0      0      0
[   806.555942@1]      Reserve:      0      0      2      3      2      3      3      1      0      1      0
[   806.565564@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
[   806.575187@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0
[   806.584810@1] HighMem: 80*4kB 15*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 440kB
[   806.595383@1]       orders:      0      1      2      3      4      5      6      7      8      9     10
[   806.605004@1]    Unmovable:     12      0      0      0      0      0      0      0      0      0      0
[   806.614626@1]  Reclaimable:      0      0      0      0      0      0      0      0      0      0      0
[   806.624248@1]      Movable:     11     15      0      0      0      0      0      0      0      0      0
[   806.633869@1]      Reserve:     57      0      0      0      0      0      0      0      0      0      0
[   806.643491@1]          CMA:      0      0      0      0      0      0      0      0      0      0      0
[   806.653113@1]      Isolate:      0      0      0      0      0      0      0      0      0      0      0

Signed-off-by: Neil Zhang <neilzhang1123@hotmail.com>
---
 mm/internal.h   |    2 ++
 mm/page_alloc.c |   55 ++++++++++++++++++++++++++-----------------------------
 mm/vmstat.c     |   13 -------------
 3 files changed, 28 insertions(+), 42 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index a96da5b..5cb3079 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,8 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 
+extern char * const migratetype_names[MIGRATE_TYPES];
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40e2942..2d70892 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3170,32 +3170,18 @@ out:
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
-static void show_migration_types(unsigned char type)
-{
-	static const char types[MIGRATE_TYPES] = {
-		[MIGRATE_UNMOVABLE]	= 'U',
-		[MIGRATE_RECLAIMABLE]	= 'E',
-		[MIGRATE_MOVABLE]	= 'M',
-		[MIGRATE_RESERVE]	= 'R',
+char * const migratetype_names[MIGRATE_TYPES] = {
+	"Unmovable",
+	"Reclaimable",
+	"Movable",
+	"Reserve",
 #ifdef CONFIG_CMA
-		[MIGRATE_CMA]		= 'C',
+	"CMA",
 #endif
 #ifdef CONFIG_MEMORY_ISOLATION
-		[MIGRATE_ISOLATE]	= 'I',
+	"Isolate",
 #endif
-	};
-	char tmp[MIGRATE_TYPES + 1];
-	char *p = tmp;
-	int i;
-
-	for (i = 0; i < MIGRATE_TYPES; i++) {
-		if (type & (1 << i))
-			*p++ = types[i];
-	}
-
-	*p = '\0';
-	printk("(%s) ", tmp);
-}
+};
 
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
@@ -3327,7 +3313,7 @@ void show_free_areas(unsigned int filter)
 
 	for_each_populated_zone(zone) {
 		unsigned long nr[MAX_ORDER], flags, order, total = 0;
-		unsigned char types[MAX_ORDER];
+		unsigned long nr_free[MAX_ORDER][MIGRATE_TYPES], mtype;
 
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
@@ -3337,24 +3323,35 @@ void show_free_areas(unsigned int filter)
 		spin_lock_irqsave(&zone->lock, flags);
 		for (order = 0; order < MAX_ORDER; order++) {
 			struct free_area *area = &zone->free_area[order];
+			struct list_head *curr;
 			int type;
 
 			nr[order] = area->nr_free;
 			total += nr[order] << order;
 
-			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
+				nr_free[order][type] = 0;
 				if (!list_empty(&area->free_list[type]))
-					types[order] |= 1 << type;
+					list_for_each(curr, &area->free_list[type])
+						nr_free[order][type]++;
 			}
 		}
 		spin_unlock_irqrestore(&zone->lock, flags);
-		for (order = 0; order < MAX_ORDER; order++) {
+		for (order = 0; order < MAX_ORDER; order++)
 			printk("%lu*%lukB ", nr[order], K(1UL) << order);
-			if (nr[order])
-				show_migration_types(types[order]);
-		}
 		printk("= %lukB\n", K(total));
+
+		printk("%12s: ", "orders");
+		for (order = 0; order < MAX_ORDER; order++)
+			printk("%6lu ", order);
+		printk("\n");
+
+		for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
+			printk("%12s: ", migratetype_names[mtype]);
+			for (order = 0; order < MAX_ORDER; order++)
+				printk("%6lu ", nr_free[order][mtype]);
+			printk("\n");
+		}
 	}
 
 	hugetlb_show_meminfo();
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4f5cd97..699eeb3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -897,19 +897,6 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 #endif
 
 #ifdef CONFIG_PROC_FS
-static char * const migratetype_names[MIGRATE_TYPES] = {
-	"Unmovable",
-	"Reclaimable",
-	"Movable",
-	"Reserve",
-#ifdef CONFIG_CMA
-	"CMA",
-#endif
-#ifdef CONFIG_MEMORY_ISOLATION
-	"Isolate",
-#endif
-};
-
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
