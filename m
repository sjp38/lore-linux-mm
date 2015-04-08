Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 32C026B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 21:48:20 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so67843574qkg.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 18:48:20 -0700 (PDT)
Received: from BLU004-OMC1S2.hotmail.com (blu004-omc1s2.hotmail.com. [65.55.116.13])
        by mx.google.com with ESMTPS id h13si9403625qhc.98.2015.04.07.18.48.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Apr 2015 18:48:19 -0700 (PDT)
Message-ID: <BLU436-SMTP2455A39CB8EF56CED4137DDBAFC0@phx.gbl>
From: Neil Zhang <neilzhang1123@hotmail.com>
Subject: [PATCH] mm: show free pages per each migrate type
Date: Wed, 8 Apr 2015 09:48:06 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Neil Zhang <neilzhang1123@hotmail.com>

show detailed free pages per each migrate type in show_free_areas.

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
