From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:40:39 +0200
Message-Id: <20060712144039.16998.75589.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 19/39] mm: pgrep: info functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Isolate the printing of various policy related information.

API:

print the zone information for show_free_areas():

	void pgrep_show(struct zone *);

print the zone information for zoneinfo_show():

	void pgrep_zoneinfo(struct zone *, struct seq_file *);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h |    3 ++
 mm/page_alloc.c                 |   44 +--------------------------------
 mm/useonce.c                    |   52 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+), 42 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:39.000000000 +0200
@@ -6,6 +6,7 @@
 #include <linux/mmzone.h>
 #include <linux/mm.h>
 #include <linux/pagevec.h>
+#include <linux/seq_file.h>
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
@@ -87,6 +88,8 @@ extern unsigned long pgrep_shrink_zone(i
 /* int pgrep_is_active(struct page *); */
 /* void __pgrep_remove(struct zone *zone, struct page *page); */
 extern void pgrep_reinsert(struct list_head *);
+extern void pgrep_show(struct zone *);
+extern void pgrep_zoneinfo(struct zone *, struct seq_file *);
 
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_policy.h>
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:39.000000000 +0200
@@ -310,3 +310,55 @@ unsigned long pgrep_shrink_zone(int prio
 	atomic_dec(&zone->reclaim_in_progress);
 	return nr_reclaimed;
 }
+
+#define K(x) ((x) << (PAGE_SHIFT-10))
+
+void pgrep_show(struct zone *zone)
+{
+	printk("%s"
+	       " free:%lukB"
+	       " min:%lukB"
+	       " low:%lukB"
+	       " high:%lukB"
+	       " active:%lukB"
+	       " inactive:%lukB"
+	       " present:%lukB"
+	       " pages_scanned:%lu"
+	       " all_unreclaimable? %s"
+	       "\n",
+	       zone->name,
+	       K(zone->free_pages),
+	       K(zone->pages_min),
+	       K(zone->pages_low),
+	       K(zone->pages_high),
+	       K(zone->nr_active),
+	       K(zone->nr_inactive),
+	       K(zone->present_pages),
+	       zone->pages_scanned,
+	       (zone->all_unreclaimable ? "yes" : "no")
+	      );
+}
+
+void pgrep_zoneinfo(struct zone *zone, struct seq_file *m)
+{
+	seq_printf(m,
+		   "\n  pages free     %lu"
+		   "\n        min      %lu"
+		   "\n        low      %lu"
+		   "\n        high     %lu"
+		   "\n        active   %lu"
+		   "\n        inactive %lu"
+		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        spanned  %lu"
+		   "\n        present  %lu",
+		   zone->free_pages,
+		   zone->pages_min,
+		   zone->pages_low,
+		   zone->pages_high,
+		   zone->nr_active,
+		   zone->nr_inactive,
+		   zone->pages_scanned,
+		   zone->nr_scan_active, zone->nr_scan_inactive,
+		   zone->spanned_pages,
+		   zone->present_pages);
+}
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/page_alloc.c	2006-07-12 16:11:39.000000000 +0200
@@ -1457,28 +1457,7 @@ void show_free_areas(void)
 		int i;
 
 		show_node(zone);
-		printk("%s"
-			" free:%lukB"
-			" min:%lukB"
-			" low:%lukB"
-			" high:%lukB"
-			" active:%lukB"
-			" inactive:%lukB"
-			" present:%lukB"
-			" pages_scanned:%lu"
-			" all_unreclaimable? %s"
-			"\n",
-			zone->name,
-			K(zone->free_pages),
-			K(zone->pages_min),
-			K(zone->pages_low),
-			K(zone->pages_high),
-			K(zone->nr_active),
-			K(zone->nr_inactive),
-			K(zone->present_pages),
-			zone->pages_scanned,
-			(zone->all_unreclaimable ? "yes" : "no")
-			);
+		pgrep_show(zone);
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
 			printk(" %lu", zone->lowmem_reserve[i]);
@@ -2252,26 +2231,7 @@ static int zoneinfo_show(struct seq_file
 
 		spin_lock_irqsave(&zone->lock, flags);
 		seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
-		seq_printf(m,
-			   "\n  pages free     %lu"
-			   "\n        min      %lu"
-			   "\n        low      %lu"
-			   "\n        high     %lu"
-			   "\n        active   %lu"
-			   "\n        inactive %lu"
-			   "\n        scanned  %lu (a: %lu i: %lu)"
-			   "\n        spanned  %lu"
-			   "\n        present  %lu",
-			   zone->free_pages,
-			   zone->pages_min,
-			   zone->pages_low,
-			   zone->pages_high,
-			   zone->nr_active,
-			   zone->nr_inactive,
-			   zone->pages_scanned,
-			   zone->nr_scan_active, zone->nr_scan_inactive,
-			   zone->spanned_pages,
-			   zone->present_pages);
+		pgrep_zoneinfo(zone, m);
 		seq_printf(m,
 			   "\n        protection: (%lu",
 			   zone->lowmem_reserve[0]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
