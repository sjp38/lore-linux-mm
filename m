Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TDH4OI136760
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 13:17:04 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TDH49P176390
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:17:04 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TDH4bL009242
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:17:04 +0200
Date: Thu, 29 Sep 2005 15:17:15 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 5/6] Page host virtual assist: discarded page list.
Message-ID: <20050929131715.GF5700@skybase.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Page host virtual assist: discarded page list.

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>

The implementation of the page host virtual assist on s390 has an
additional hazard that is quite difficult to resolve. The discard
fault exception calls the guest system with the absolute address
of the page that caused the fault instead of the virtual address
of the access. With the virtual address we could have used the
page table entry of the current process to safely get a reference
to the discarded page. We can get the struct page pointer from the
absolute page address but its rather hard to get to a proper page
reference. The page that caused the fault could have already been
freed and reused for a different purpose. None of the fields in
the struct page are reliable to use. 

To get around this problem discarded pages that are about to be
freed need special handling because there might be a pending
discard fault for them we haven't completed yet.
A check is added in __remove_from_page_cache that sets the
PG_discarded bit if the page has been removed by the host. That bit
is tested for each page that gets freed via free_hot_cold_page.
If it is set the page is put on a list of discarded pages.
The pages on this list are only freed after all cpus have gone
through enabled state at least once. With the requirement that
a cpu that gets a discard fault is disabled for interrupts while
handling the fault it is possible for the discard fault handler to
safely get a page reference from the struct page by using an
atomic_inc_if_not_zero operation on the reference count.

The nice thing about the discard list is that discarded pages do
not get reused immediatly. The host system needs to back discarded
guest pages again before they can be reused. So even for "nice"
platforms who deliver the virtual page address on the discard fault
get a benefit out of this patch.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:
 include/linux/page_hva.h |    5 +++++
 mm/filemap.c             |    4 +++-
 mm/page_alloc.c          |   26 ++++++++++++++++++++++++++
 mm/vmscan.c              |   28 ++++++++++++++++++++++++++++
 4 files changed, 62 insertions(+), 1 deletion(-)

diff -urpN linux-2.5/include/linux/page_hva.h linux-2.5-cmm2/include/linux/page_hva.h
--- linux-2.5/include/linux/page_hva.h	2005-09-29 14:49:53.000000000 +0200
+++ linux-2.5-cmm2/include/linux/page_hva.h	2005-09-29 14:49:54.000000000 +0200
@@ -16,6 +16,9 @@
 
 #include <asm/page_hva.h>
 
+extern spinlock_t page_hva_discard_list_lock;
+extern struct list_head page_hva_discard_list;
+
 extern int page_hva_make_stable(struct page *page);
 extern void page_hva_discard_page(struct page *page);
 extern void __page_hva_discard_page(struct page *page);
@@ -53,6 +56,8 @@ static inline void page_hva_reset_write(
 #define page_hva_set_volatile(_page)		do { } while (0)
 #define page_hva_set_stable_if_resident(_page)	(1)
 
+#define page_hva_discarded(_page)		(0)
+
 #define page_hva_make_stable(_page)		(1)
 #define page_hva_make_volatile(_page,_offset)	do { } while (0)
 
diff -urpN linux-2.5/mm/filemap.c linux-2.5-cmm2/mm/filemap.c
--- linux-2.5/mm/filemap.c	2005-09-29 14:49:54.000000000 +0200
+++ linux-2.5-cmm2/mm/filemap.c	2005-09-29 14:49:54.000000000 +0200
@@ -118,7 +118,9 @@ void __remove_from_page_cache(struct pag
 	 * in the discard fault for multiple discards of a single
 	 * page. Clear the mapping now.
 	 */
-	if (unlikely(PageDiscarded(page))) {
+	if (unlikely(PageDiscarded(page) ||
+		     (page_hva_discarded(page) &&
+		      TestSetPageDiscarded(page)))) {
 		page->mapping = NULL;
 		return;
 	}
diff -urpN linux-2.5/mm/page_alloc.c linux-2.5-cmm2/mm/page_alloc.c
--- linux-2.5/mm/page_alloc.c	2005-09-29 14:49:54.000000000 +0200
+++ linux-2.5-cmm2/mm/page_alloc.c	2005-09-29 14:49:54.000000000 +0200
@@ -638,6 +638,12 @@ static void zone_statistics(struct zonel
 #endif
 }
 
+#ifdef CONFIG_PAGE_HVA
+static DEFINE_PER_CPU(struct pagevec, page_hva_discard_pvecs) = { 0, };
+DEFINE_SPINLOCK(page_hva_discard_list_lock);
+LIST_HEAD(page_hva_discard_list);
+#endif
+
 /*
  * Free a 0-order page
  */
@@ -648,6 +654,26 @@ static void fastcall free_hot_cold_page(
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
+#ifdef CONFIG_PAGE_HVA
+	if (unlikely(PageDiscarded(page))) {
+		struct pagevec *pvec;
+		pvec = &get_cpu_var(page_hva_discard_pvecs);
+		if (!pagevec_add(pvec, page)) {
+			int i;
+			spin_lock(&page_hva_discard_list_lock);
+			for (i = 0; i < pagevec_count(pvec); i++) {
+				struct page *page = pvec->pages[i];
+				list_add_tail(&page->lru,
+					      &page_hva_discard_list);
+			}
+			spin_unlock(&page_hva_discard_list_lock);
+			pagevec_reinit(pvec);
+		}
+		put_cpu_var(page_hva_discard_pvecs);
+		return;
+	}
+#endif
+
 	arch_free_page(page, 0);
 
 	kernel_map_pages(page, 1, 0);
diff -urpN linux-2.5/mm/vmscan.c linux-2.5-cmm2/mm/vmscan.c
--- linux-2.5/mm/vmscan.c	2005-09-29 14:49:52.000000000 +0200
+++ linux-2.5-cmm2/mm/vmscan.c	2005-09-29 14:49:54.000000000 +0200
@@ -657,6 +657,33 @@ void page_hva_discard_page(struct page *
 	unlock_page(page);
 }
 EXPORT_SYMBOL(page_hva_discard_page);
+
+static void page_hva_sync(void *info)
+{
+}
+
+void shrink_discards(struct scan_control *sc)
+{
+	struct list_head pages_to_free = LIST_HEAD_INIT(pages_to_free);
+	struct page *page, *next;
+
+	spin_lock(&page_hva_discard_list_lock);
+	list_splice_init(&page_hva_discard_list, &pages_to_free);
+	spin_unlock(&page_hva_discard_list_lock);
+
+	if (list_empty(&pages_to_free))
+		return;
+
+	smp_call_function(page_hva_sync, NULL, 0, 1);
+
+	list_for_each_entry_safe(page, next, &pages_to_free, lru) {
+		ClearPageDiscarded(page);
+		page->mapping = NULL;
+		free_cold_page(page);
+	}
+}
+#else
+#define shrink_discards(sc)	do { } while (0)
 #endif
 
 /*
@@ -1055,6 +1082,7 @@ int try_to_free_pages(struct zone **zone
 		sc.nr_reclaimed = 0;
 		sc.priority = priority;
 		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+		shrink_discards(&sc);
 		shrink_caches(zones, &sc);
 		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
