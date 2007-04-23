Message-Id: <20070423062129.317055444@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:09 -0700
From: clameter@sgi.com
Subject: [RFC 02/16] vmstat.c: Support accounting for compound pages
Content-Disposition: inline; filename=var_pc_vmstat
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

Compound pages must increment the counters in terms of base pages.
If we detect a compound page then add the number of base pages that
a compound page has to the counter.

This will avoid numerous changes in the VM to fix up page accounting
as we add more support for  compound pages.

Also fix up the accounting for active / inactive pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_inline.h |   12 ++++++------
 mm/vmstat.c               |    8 +++-----
 2 files changed, 9 insertions(+), 11 deletions(-)

Index: linux-2.6.21-rc7/mm/vmstat.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/vmstat.c	2007-04-21 23:35:49.000000000 -0700
+++ linux-2.6.21-rc7/mm/vmstat.c	2007-04-21 23:35:59.000000000 -0700
@@ -223,7 +223,7 @@ void __inc_zone_state(struct zone *zone,
 
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	__inc_zone_state(page_zone(page), item);
+	__mod_zone_page_state(page_zone(page), item, base_pages(page));
 }
 EXPORT_SYMBOL(__inc_zone_page_state);
 
@@ -244,7 +244,7 @@ void __dec_zone_state(struct zone *zone,
 
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
-	__dec_zone_state(page_zone(page), item);
+	__mod_zone_page_state(page_zone(page), item, -base_pages(page));
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
 
@@ -260,11 +260,9 @@ void inc_zone_state(struct zone *zone, e
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
Index: linux-2.6.21-rc7/include/linux/mm_inline.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/mm_inline.h	2007-04-22 00:20:15.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/mm_inline.h	2007-04-22 00:21:12.000000000 -0700
@@ -2,28 +2,28 @@ static inline void
 add_page_to_active_list(struct zone *zone, struct page *page)
 {
 	list_add(&page->lru, &zone->active_list);
-	__inc_zone_state(zone, NR_ACTIVE);
+	__inc_zone_page_state(page, NR_ACTIVE);
 }
 
 static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
 	list_add(&page->lru, &zone->inactive_list);
-	__inc_zone_state(zone, NR_INACTIVE);
+	__inc_zone_page_state(page, NR_INACTIVE);
 }
 
 static inline void
 del_page_from_active_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_ACTIVE);
+	__dec_zone_page_state(page, NR_ACTIVE);
 }
 
 static inline void
 del_page_from_inactive_list(struct zone *zone, struct page *page)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE);
+	__dec_zone_page_state(page, NR_INACTIVE);
 }
 
 static inline void
@@ -32,9 +32,9 @@ del_page_from_lru(struct zone *zone, str
 	list_del(&page->lru);
 	if (PageActive(page)) {
 		__ClearPageActive(page);
-		__dec_zone_state(zone, NR_ACTIVE);
+		__dec_zone_page_state(page, NR_ACTIVE);
 	} else {
-		__dec_zone_state(zone, NR_INACTIVE);
+		__dec_zone_page_state(page, NR_INACTIVE);
 	}
 }
 

--
