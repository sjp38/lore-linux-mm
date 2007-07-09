Subject: [RFT][PATCH] mm: drop behind
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 20:50:08 +0200
Message-Id: <1184007008.1913.45.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Use the read-ahead code to provide hints to page reclaim.

This patch has the potential to solve the streaming-IO trashes my
desktop problem.

It tries to aggressively reclaim pages that were loaded in a strong
sequential pattern and have been consumed. Thereby limiting the damage
to the current resident set.

I'm posting this in the hope that people will test this in a variety of
workloads and report back (success or regression). It seems to work
reasonably well on my desktop for things that sequentially consume large
files: burning dvds, md5sum dvds, cat dvds > /dev/null

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/swap.h |    1 +
 mm/readahead.c       |   38 +++++++++++++++++++++++++++++++++++++-
 mm/swap.c            |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 89 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/cpu.h>
 #include <linux/notifier.h>
 #include <linux/init.h>
+#include <linux/rmap.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
@@ -178,6 +179,7 @@ EXPORT_SYMBOL(mark_page_accessed);
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_add_tail_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_demote_pvecs) = { 0, };
 
 void fastcall lru_cache_add(struct page *page)
 {
@@ -224,6 +226,37 @@ static void __pagevec_lru_add_tail(struc
 	pagevec_reinit(pvec);
 }
 
+static void __pagevec_lru_demote(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (PageLRU(page)) {
+			page_referenced(page, 0);
+			if (PageActive(page)) {
+				ClearPageActive(page);
+				__dec_zone_state(zone, NR_ACTIVE);
+				__inc_zone_state(zone, NR_INACTIVE);
+			}
+			list_move_tail(&page->lru, &zone->inactive_list);
+		}
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
 static void __lru_add_drain(int cpu)
 {
 	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);
@@ -237,6 +270,9 @@ static void __lru_add_drain(int cpu)
 	pvec = &per_cpu(lru_add_tail_pvecs, cpu);
 	if (pagevec_count(pvec))
 		__pagevec_lru_add_tail(pvec);
+	pvec = &per_cpu(lru_demote_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_demote(pvec);
 }
 
 void lru_add_drain(void)
@@ -448,6 +484,21 @@ void fastcall lru_cache_add_tail(struct 
 }
 
 /*
+ * Function used to forcefully demote a page to the tail of the inactive
+ * list.
+ */
+void fastcall lru_demote(struct page *page)
+{
+	if (likely(get_page_unless_zero(page))) {
+		struct pagevec *pvec = &get_cpu_var(lru_demote_pvecs);
+
+		if (!pagevec_add(pvec, page))
+			__pagevec_lru_demote(pvec);
+		put_cpu_var(lru_demote_pvecs);
+	}
+}
+
+/*
  * Try to drop buffers from the pages in a pagevec
  */
 void pagevec_strip(struct pagevec *pvec)
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -181,6 +181,7 @@ extern unsigned int nr_free_pagecache_pa
 extern void FASTCALL(lru_cache_add(struct page *));
 extern void FASTCALL(lru_cache_add_active(struct page *));
 extern void FASTCALL(lru_cache_add_tail(struct page *));
+extern void FASTCALL(lru_demote(struct page *));
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -15,6 +15,7 @@
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/pagevec.h>
+#include <linux/swap.h>
 
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page)
 {
@@ -441,13 +442,18 @@ EXPORT_SYMBOL_GPL(page_cache_sync_readah
  * page_cache_async_ondemand() should be called when a page is used which
  * has the PG_readahead flag: this is a marker to suggest that the application
  * has used up enough of the readahead window that we should start pulling in
- * more pages. */
+ * more pages.
+ */
 void
 page_cache_async_readahead(struct address_space *mapping,
 			   struct file_ra_state *ra, struct file *filp,
 			   struct page *page, pgoff_t offset,
 			   unsigned long req_size)
 {
+	unsigned long demote_idx = offset - min(offset, ra->size);
+	struct page *pages[16];
+	unsigned nr_pages, i;
+
 	/* no read-ahead */
 	if (!ra->ra_pages)
 		return;
@@ -466,6 +472,36 @@ page_cache_async_readahead(struct addres
 	if (bdi_read_congested(mapping->backing_dev_info))
 		return;
 
+	/*
+	 * Read-ahead use once: when the ra window is maximal this is a good
+	 * hint that there is sequential IO, which implies that the pages that
+	 * have been used thus far can be reclaimed
+	 */
+	if (ra->size == ra->ra_pages) do {
+		nr_pages = find_get_pages(mapping,
+				demote_idx, ARRAY_SIZE(pages), pages);
+
+		for (i = 0; i < nr_pages; i++) {
+			page = pages[i];
+			demote_idx = page_index(page);
+
+			/*
+			 * The page is active. This means there are other
+			 * users. We should not take away somebody else's
+			 * pages, so do not drop behind beyond this point.
+			 */
+			if (demote_idx < offset && !PageActive(page)) {
+				lru_demote(page);
+			} else {
+				demote_idx = offset;
+				break;
+			}
+		}
+		demote_idx++;
+
+		release_pages(pages, nr_pages, 0);
+	} while (demote_idx < offset);
+
 	/* do read-ahead */
 	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
