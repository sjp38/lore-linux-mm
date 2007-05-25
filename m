Message-Id: <20070525051947.298733925@sgi.com>
References: <20070525051716.030494061@sgi.com>
Date: Thu, 24 May 2007 22:17:19 -0700
From: clameter@sgi.com
Subject: [patch 3/6] compound pages: vmstat support
Content-Disposition: inline; filename=compound_vmstat
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Add support for compound pages so that

inc_xxxx and dec_xxx

will increment the ZVCs by the number of pages of the compound page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmstat.h |    5 ++---
 mm/vmstat.c            |   18 +++++++++++++-----
 2 files changed, 15 insertions(+), 8 deletions(-)

Index: slub/include/linux/vmstat.h
===================================================================
--- slub.orig/include/linux/vmstat.h	2007-05-24 20:37:44.000000000 -0700
+++ slub/include/linux/vmstat.h	2007-05-24 21:00:06.000000000 -0700
@@ -234,7 +234,7 @@ static inline void __inc_zone_state(stru
 static inline void __inc_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
-	__inc_zone_state(page_zone(page), item);
+	__mod_zone_page_state(page_zone(page), item, compound_pages(page));
 }
 
 static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
@@ -246,8 +246,7 @@ static inline void __dec_zone_state(stru
 static inline void __dec_zone_page_state(struct page *page,
 			enum zone_stat_item item)
 {
-	atomic_long_dec(&page_zone(page)->vm_stat[item]);
-	atomic_long_dec(&vm_stat[item]);
+	__mod_zone_page_state(page_zone(page), item, -compound_pages(page));
 }
 
 /*
Index: slub/mm/vmstat.c
===================================================================
--- slub.orig/mm/vmstat.c	2007-05-24 20:37:44.000000000 -0700
+++ slub/mm/vmstat.c	2007-05-24 21:00:06.000000000 -0700
@@ -224,7 +224,12 @@ void __inc_zone_state(struct zone *zone,
 
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	__inc_zone_state(page_zone(page), item);
+	struct zone *z = page_zone(page);
+
+	if (likely(!PageHead(page)))
+		__inc_zone_state(z, item);
+	else
+		__mod_zone_page_state(z, item, compound_pages(page));
 }
 EXPORT_SYMBOL(__inc_zone_page_state);
 
@@ -245,7 +250,12 @@ void __dec_zone_state(struct zone *zone,
 
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	__dec_zone_state(page_zone(page), item);
+	struct zone *z = page_zone(page);
+
+	if (likely(!PageHead(page)))
+		__dec_zone_state(z, item);
+	else
+		__mod_zone_page_state(z, item, -compound_pages(page));
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
 
@@ -261,11 +271,9 @@ void inc_zone_state(struct zone *zone, e
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
-	struct zone *zone;
 
-	zone = page_zone(page);
 	local_irq_save(flags);
-	__inc_zone_state(zone, item);
+	__inc_zone_page_state(page, item);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(inc_zone_page_state);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
