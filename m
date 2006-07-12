From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:40:51 +0200
Message-Id: <20060712144051.16998.64559.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 20/39] mm: pgrep: page count functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract the various page counts used to drive the scanner.

API:

give the 'active', 'inactive' and free count for the selected pgdat.
(free interpretation of '' words)

    void __pgrep_counts(unsigned long *, unsigned long *,
			    unsigned long *, struct zone *);

total number of pages in the policies care

    unsigned long __pgrep_nr_pages(struct zone *);


Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    3 +++
 include/linux/mm_use_once_policy.h |    5 +++++
 mm/page_alloc.c                    |   12 +-----------
 mm/useonce.c                       |   15 +++++++++++++++
 mm/vmscan.c                        |    6 +++---
 5 files changed, 27 insertions(+), 14 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:36.000000000 +0200
@@ -90,6 +90,9 @@ extern unsigned long pgrep_shrink_zone(i
 extern void pgrep_reinsert(struct list_head *);
 extern void pgrep_show(struct zone *);
 extern void pgrep_zoneinfo(struct zone *, struct seq_file *);
+extern void __pgrep_counts(unsigned long *, unsigned long *,
+				  unsigned long *, struct zone *);
+/* unsigned long __pgrep_nr_pages(struct zone *); */
 
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_policy.h>
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:38.000000000 +0200
@@ -362,3 +362,18 @@ void pgrep_zoneinfo(struct zone *zone, s
 		   zone->spanned_pages,
 		   zone->present_pages);
 }
+
+void __pgrep_counts(unsigned long *active, unsigned long *inactive,
+			   unsigned long *free, struct zone *zones)
+{
+	int i;
+
+	*active = 0;
+	*inactive = 0;
+	*free = 0;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		*active += zones[i].nr_active;
+		*inactive += zones[i].nr_inactive;
+		*free += zones[i].free_pages;
+	}
+}
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-07-12 16:11:37.000000000 +0200
@@ -1332,17 +1332,7 @@ EXPORT_SYMBOL(mod_page_state_offset);
 void __get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free, struct pglist_data *pgdat)
 {
-	struct zone *zones = pgdat->node_zones;
-	int i;
-
-	*active = 0;
-	*inactive = 0;
-	*free = 0;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		*active += zones[i].nr_active;
-		*inactive += zones[i].nr_inactive;
-		*free += zones[i].free_pages;
-	}
+	__pgrep_counts(active, inactive, free, pgdat->node_zones);
 }
 
 void get_zone_counts(unsigned long *active,
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:38.000000000 +0200
@@ -157,5 +157,10 @@ static inline void __pgrep_remove(struct
 		zone->nr_inactive--;
 }
 
+static inline unsigned long __pgrep_nr_pages(struct zone *zone)
+{
+	return zone->nr_active + zone->nr_inactive;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:36.000000000 +0200
@@ -671,7 +671,7 @@ unsigned long try_to_free_pages(struct z
 			continue;
 
 		zone->temp_priority = DEF_PRIORITY;
-		lru_pages += zone->nr_active + zone->nr_inactive;
+		lru_pages += __pgrep_nr_pages(zone);
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -812,7 +812,7 @@ scan:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone->nr_active + zone->nr_inactive;
+			lru_pages += __pgrep_nr_pages(zone);
 		}
 
 		/*
@@ -853,7 +853,7 @@ scan:
 			if (zone->all_unreclaimable)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				    (zone->nr_active + zone->nr_inactive) * 4)
+				    __pgrep_nr_pages(zone) * 4)
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
