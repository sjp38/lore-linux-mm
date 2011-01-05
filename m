Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8394F6B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 03:00:49 -0500 (EST)
Subject: [PATCH v2 2/2]mm: batch activate_page() to reduce lock contention
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Jan 2011 16:00:09 +0800
Message-ID: <1294214409.1949.573.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

The zone->lru_lock is heavily contented in workload where activate_page()
is frequently used. We could do batch activate_page() to reduce the lock
contention. The batched pages will be added into zone list when the pool
is full or page reclaim is trying to drain them.

For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
processes shared map to the file. Each process read access the whole file and
then exit. The process exit will do unmap_vmas() and cause a lot of
activate_page() call. In such workload, we saw about 58% total time reduction
with below patch. Other workloads with a lot of activate_page also benefits a
lot too.

V1->v2:
1. reduced footprint in UP case as requested by akpm. Currently the patched
kernel binary adds 34 bytes in UP case.
2. When putback_lru_pages activates a page, it follows the same path like
activate_page. This is suggested by akpm.

Initial post is at:
http://marc.info/?l=linux-mm&m=127961033307852&w=2

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/internal.h |    9 +++++
 mm/swap.c     |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++--------
 mm/vmscan.c   |    6 ++-
 3 files changed, 93 insertions(+), 13 deletions(-)

Index: linux/mm/swap.c
===================================================================
--- linux.orig/mm/swap.c	2011-01-04 13:56:12.000000000 +0800
+++ linux/mm/swap.c	2011-01-04 13:57:07.000000000 +0800
@@ -191,27 +191,94 @@ static void update_page_reclaim_stat(str
 }
 
 /*
- * FIXME: speed this up?
+ * A page will go to active list either by activate_page or putback_lru_page.
+ * In the activate_page case, the page hasn't active bit set. The page might
+ * not in LRU list because it's isolated before it gets a chance to be moved to
+ * active list. The window is small because pagevec just stores several pages.
+ * For such case, we do nothing for such page.
+ * In the putback_lru_page case, the page isn't in lru list but has active
+ * bit set
  */
-void activate_page(struct page *page)
+static void __activate_page(struct page *page, void *arg)
 {
 	struct zone *zone = page_zone(page);
+	int file = page_is_file_cache(page);
+	int lru = page_lru_base_type(page);
+	bool putback = !PageLRU(page);
+
+	/* The page is isolated before it's moved to active list */
+	if (!PageLRU(page) && !PageActive(page))
+		return;
+	if ((PageLRU(page) && PageActive(page)) || PageUnevictable(page))
+		return;
 
-	spin_lock_irq(&zone->lru_lock);
-	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
-		int lru = page_lru_base_type(page);
+	if (!putback)
 		del_page_from_lru_list(zone, page, lru);
+	else
+		SetPageLRU(page);
+
+	SetPageActive(page);
+	lru += LRU_ACTIVE;
+	add_page_to_lru_list(zone, page, lru);
+
+	if (putback)
+		return;
+	__count_vm_event(PGACTIVATE);
+	update_page_reclaim_stat(zone, page, file, 1);
+}
+
+#ifdef CONFIG_SMP
+static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
+
+static void activate_page_drain(int cpu)
+{
+	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
+
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+}
+
+void activate_page(struct page *page)
+{
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
-		SetPageActive(page);
-		lru += LRU_ACTIVE;
-		add_page_to_lru_list(zone, page, lru);
-		__count_vm_event(PGACTIVATE);
+		page_cache_get(page);
+		if (!pagevec_add(pvec, page))
+			pagevec_lru_move_fn(pvec, __activate_page, NULL);
+		put_cpu_var(activate_page_pvecs);
+	}
+}
+
+/* Caller should hold zone->lru_lock */
+int putback_active_lru_page(struct zone *zone, struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
-		update_page_reclaim_stat(zone, page, file, 1);
+	if (!pagevec_add(pvec, page)) {
+		spin_unlock_irq(&zone->lru_lock);
+		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+		spin_lock_irq(&zone->lru_lock);
 	}
+	put_cpu_var(activate_page_pvecs);
+	return 1;
+}
+
+#else
+static void inline activate_page_drain(int cpu)
+{
+}
+
+void activate_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
+	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page))
+		__activate_page(page, NULL);
 	spin_unlock_irq(&zone->lru_lock);
 }
+#endif
 
 /*
  * Mark a page as having seen activity.
@@ -310,6 +377,8 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	activate_page_drain(cpu);
 }
 
 void lru_add_drain(void)
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2011-01-04 11:06:33.000000000 +0800
+++ linux/mm/vmscan.c	2011-01-04 13:57:07.000000000 +0800
@@ -1253,13 +1253,15 @@ putback_lru_pages(struct zone *zone, str
 			spin_lock_irq(&zone->lru_lock);
 			continue;
 		}
-		SetPageLRU(page);
 		lru = page_lru(page);
-		add_page_to_lru_list(zone, page, lru);
 		if (is_active_lru(lru)) {
 			int file = is_file_lru(lru);
 			reclaim_stat->recent_rotated[file]++;
+			if (putback_active_lru_page(zone, page))
+				continue;
 		}
+		SetPageLRU(page);
+		add_page_to_lru_list(zone, page, lru);
 		if (!pagevec_add(&pvec, page)) {
 			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h	2011-01-04 11:06:33.000000000 +0800
+++ linux/mm/internal.h	2011-01-04 13:57:07.000000000 +0800
@@ -39,6 +39,15 @@ static inline void __put_page(struct pag
 
 extern unsigned long highest_memmap_pfn;
 
+#ifdef CONFIG_SMP
+extern int putback_active_lru_page(struct zone *zone, struct page *page);
+#else
+static inline int putback_active_lru_page(struct zone *zone, struct page *page)
+{
+	return 0;
+}
+#endif
+
 /*
  * in mm/vmscan.c:
  */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
