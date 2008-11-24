Date: Mon, 24 Nov 2008 13:53:43 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 9/8] mm: optimize get_scan_ratio for no swap
In-Reply-To: <Pine.LNX.4.64.0811241340140.17541@blonde.site>
Message-ID: <Pine.LNX.4.64.0811241349570.17541@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
 <Pine.LNX.4.64.0811232205180.4142@blonde.site> <4929DF54.8050104@redhat.com>
 <Pine.LNX.4.64.0811241340140.17541@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik suggests a simplified get_scan_ratio() for !CONFIG_SWAP.  Yes,
the gcc optimizer gives us that, when nr_swap_pages is #defined as 0L.
Move usual declaration to swapfile.c: it never belonged in page_alloc.c.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    5 +++--
 mm/page_alloc.c      |    1 -
 mm/swapfile.c        |    1 +
 mm/vmscan.c          |   12 ++++++------
 4 files changed, 10 insertions(+), 9 deletions(-)

--- swapfree8/include/linux/swap.h	2008-11-21 18:51:08.000000000 +0000
+++ swapfree9/include/linux/swap.h	2008-11-24 13:27:00.000000000 +0000
@@ -163,7 +163,6 @@ struct swap_list_t {
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
-extern long nr_swap_pages;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
@@ -294,6 +293,7 @@ extern struct page *swapin_readahead(swp
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
+extern long nr_swap_pages;
 extern long total_swap_pages;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
@@ -334,7 +334,8 @@ static inline void disable_swap_token(vo
 
 #else /* CONFIG_SWAP */
 
-#define total_swap_pages			0
+#define nr_swap_pages				0L
+#define total_swap_pages			0L
 #define total_swapcache_pages			0UL
 
 #define si_swapinfo(val) \
--- swapfree8/mm/page_alloc.c	2008-11-19 15:25:12.000000000 +0000
+++ swapfree9/mm/page_alloc.c	2008-11-24 13:27:00.000000000 +0000
@@ -69,7 +69,6 @@ EXPORT_SYMBOL(node_states);
 
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
-long nr_swap_pages;
 int percpu_pagelist_fraction;
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
--- swapfree8/mm/swapfile.c	2008-11-21 18:50:59.000000000 +0000
+++ swapfree9/mm/swapfile.c	2008-11-24 13:27:00.000000000 +0000
@@ -35,6 +35,7 @@
 
 static DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
+long nr_swap_pages;
 long total_swap_pages;
 static int swap_overflow;
 static int least_priority;
--- swapfree8/mm/vmscan.c	2008-11-21 18:51:08.000000000 +0000
+++ swapfree9/mm/vmscan.c	2008-11-24 13:27:00.000000000 +0000
@@ -1374,12 +1374,6 @@ static void get_scan_ratio(struct zone *
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 
-	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
-		zone_page_state(zone, NR_INACTIVE_ANON);
-	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
-		zone_page_state(zone, NR_INACTIVE_FILE);
-	free  = zone_page_state(zone, NR_FREE_PAGES);
-
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (nr_swap_pages <= 0) {
 		percent[0] = 0;
@@ -1387,6 +1381,12 @@ static void get_scan_ratio(struct zone *
 		return;
 	}
 
+	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+		zone_page_state(zone, NR_INACTIVE_ANON);
+	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+		zone_page_state(zone, NR_INACTIVE_FILE);
+	free  = zone_page_state(zone, NR_FREE_PAGES);
+
 	/* If we have very few page cache pages, force-scan anon pages. */
 	if (unlikely(file + free <= zone->pages_high)) {
 		percent[0] = 100;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
