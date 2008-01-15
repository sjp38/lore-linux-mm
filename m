Date: Tue, 15 Jan 2008 10:02:30 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 4/5] memory_pressure_notify() caller
In-Reply-To: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080115100124.117B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

the notification point to happen whenever the VM moves an
anonymous page to the inactive list - this is a pretty good indication
that there are unused anonymous pages present which will be very likely
swapped out soon.

and, It is judged out of trouble at the fllowing situations. 
 o memory pressure decrease and stop moves an anonymous page to the inactive list.
 o free pages increase than (pages_high+lowmem_reserve)*2.


Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: linux-2.6.24-rc6-mm1-memnotify/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/mm/vmscan.c	2008-01-13 16:59:28.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/mm/vmscan.c	2008-01-13 17:03:58.000000000 +0900
@@ -963,6 +963,7 @@ static int calc_reclaim_mapped(struct sc
 	long distress;
 	long swap_tendency;
 	long imbalance;
+	int reclaim_mapped = 0;
 	int prev_priority;
 
 	if (scan_global_lru(sc) && zone_is_near_oom(zone))
@@ -1089,10 +1090,14 @@ static void shrink_active_list(unsigned 
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
+	bool inactivated_anon = 0;
 
 	if (sc->may_swap)
 		reclaim_mapped = calc_reclaim_mapped(sc, zone, priority);
 
+	if (!reclaim_mapped)
+		memory_pressure_notify(zone, 0);
+
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
@@ -1116,6 +1121,13 @@ static void shrink_active_list(unsigned 
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
 			    page_referenced(page, 0, sc->mem_cgroup)) {
+				/* deal with the case where there is no
+				 * swap but an anonymous page would be
+				 * moved to the inactive list.
+				 */
+				if (!total_swap_pages && reclaim_mapped &&
+				    PageAnon(page))
+					inactivated_anon = 1;
 				list_add(&page->lru, &l_active);
 				continue;
 			}
@@ -1123,8 +1135,12 @@ static void shrink_active_list(unsigned 
 			list_add(&page->lru, &l_active);
 			continue;
 		}
+		if (PageAnon(page))
+			inactivated_anon = 1;
 		list_add(&page->lru, &l_inactive);
 	}
+	if (inactivated_anon)
+		memory_pressure_notify(zone, 1);
 
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
@@ -1158,6 +1174,8 @@ static void shrink_active_list(unsigned 
 		pagevec_strip(&pvec);
 		spin_lock_irq(&zone->lru_lock);
 	}
+	if (!reclaim_mapped)
+		memory_pressure_notify(zone, 0);
 
 	pgmoved = 0;
 	while (!list_empty(&l_active)) {
Index: linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/mm/page_alloc.c	2008-01-13 16:57:10.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c	2008-01-13 17:04:34.000000000 +0900
@@ -44,6 +44,7 @@
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
+#include <linux/mem_notify.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -435,6 +436,8 @@ static inline void __free_one_page(struc
 	unsigned long page_idx;
 	int order_size = 1 << order;
 	int migratetype = get_pageblock_migratetype(page);
+	unsigned long prev_free;
+	unsigned long notify_threshold;
 
 	if (unlikely(PageCompound(page)))
 		destroy_compound_page(page, order);
@@ -444,6 +447,7 @@ static inline void __free_one_page(struc
 	VM_BUG_ON(page_idx & (order_size - 1));
 	VM_BUG_ON(bad_range(zone, page));
 
+	prev_free = zone_page_state(zone, NR_FREE_PAGES);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, order_size);
 	while (order < MAX_ORDER-1) {
 		unsigned long combined_idx;
@@ -465,6 +469,13 @@ static inline void __free_one_page(struc
 	list_add(&page->lru,
 		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;
+
+	notify_threshold = (zone->pages_high +
+			    zone->lowmem_reserve[MAX_NR_ZONES-1]) * 2;
+
+	if (unlikely((prev_free <= notify_threshold) &&
+		     (zone_page_state(zone, NR_FREE_PAGES) > notify_threshold)))
+		memory_pressure_notify(zone, 0);
 }
 
 static inline int free_pages_check(struct page *page)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
