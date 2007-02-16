Date: Fri, 16 Feb 2007 02:10:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <1171613727.24923.54.camel@twins>
Message-ID: <Pine.LNX.4.64.0702160208530.21862@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org>  <45D50B79.5080002@mbligh.org>
  <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org> <1171613727.24923.54.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007, Peter Zijlstra wrote:

> On Thu, 2007-02-15 at 18:48 -0800, Andrew Morton wrote:
> 
> > The two swsusp bits can be removed: they're only needed at suspend/resume
> > time and can be replaced by an external data structure.
> 
> I once had a talk with Rafael, and he said it would be possible to rid
> us of PG_nosave* with the now not so new bitmap code that is used to
> handle swsusp of highmem pages.

Well we can just shift the stuff into the power subsystem I think. Like 
this? Compiles but not tested.

Index: linux-2.6.20-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.20-mm1.orig/include/linux/mmzone.h	2007-02-16 01:11:46.000000000 -0800
+++ linux-2.6.20-mm1/include/linux/mmzone.h	2007-02-16 01:12:23.000000000 -0800
@@ -295,6 +295,7 @@ struct zone {
 	unsigned long		spanned_pages;	/* total size, including holes */
 	unsigned long		present_pages;	/* amount of memory (excluding holes) */
 
+	unsigned long		*suspend_flags;
 	/*
 	 * rarely used fields:
 	 */
Index: linux-2.6.20-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.20-mm1.orig/include/linux/page-flags.h	2007-02-16 01:05:26.000000000 -0800
+++ linux-2.6.20-mm1/include/linux/page-flags.h	2007-02-16 01:16:45.000000000 -0800
@@ -82,13 +82,11 @@
 #define PG_private		11	/* If pagecache, has fs-private data */
 
 #define PG_writeback		12	/* Page is under writeback */
-#define PG_nosave		13	/* Used for system suspend/resume */
 #define PG_compound		14	/* Part of a compound page */
 #define PG_swapcache		15	/* Swap page: swp_entry_t in private */
 
 #define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
 #define PG_reclaim		17	/* To be reclaimed asap */
-#define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
 #define PG_mlocked		20	/* Page is mlocked */
@@ -192,16 +190,6 @@ static inline void SetPageUptodate(struc
 #define TestClearPageWriteback(page) test_and_clear_bit(PG_writeback,	\
 							&(page)->flags)
 
-#define PageNosave(page)	test_bit(PG_nosave, &(page)->flags)
-#define SetPageNosave(page)	set_bit(PG_nosave, &(page)->flags)
-#define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, &(page)->flags)
-#define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
-#define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, &(page)->flags)
-
-#define PageNosaveFree(page)	test_bit(PG_nosave_free, &(page)->flags)
-#define SetPageNosaveFree(page)	set_bit(PG_nosave_free, &(page)->flags)
-#define ClearPageNosaveFree(page)		clear_bit(PG_nosave_free, &(page)->flags)
-
 #define PageBuddy(page)		test_bit(PG_buddy, &(page)->flags)
 #define __SetPageBuddy(page)	__set_bit(PG_buddy, &(page)->flags)
 #define __ClearPageBuddy(page)	__clear_bit(PG_buddy, &(page)->flags)
Index: linux-2.6.20-mm1/include/linux/suspend.h
===================================================================
--- linux-2.6.20-mm1.orig/include/linux/suspend.h	2007-02-16 01:15:30.000000000 -0800
+++ linux-2.6.20-mm1/include/linux/suspend.h	2007-02-16 01:57:51.000000000 -0800
@@ -21,7 +22,6 @@ struct pbe {
 
 /* mm/page_alloc.c */
 extern void drain_local_pages(void);
-extern void mark_free_pages(struct zone *zone);
 
 #ifdef CONFIG_PM
 /* kernel/power/swsusp.c */
@@ -42,6 +42,18 @@ static inline int software_suspend(void)
 }
 #endif /* CONFIG_PM */
 
+#ifdef CONFIG_SOFTWARE_SUSPEND
+int suspend_flags_init(struct zone *zone, unsigned long zone_size_pages);
+void mark_free_pages(struct zone *zone);
+#else
+static inline int suspend_flags_init(struct zone *zone, unsigned long zone_size_pages)
+{
+	return 0;
+}
+
+static inline void mark_free_pages(struct zone *zone) {}
+#endif
+
 void save_processor_state(void);
 void restore_processor_state(void);
 struct saved_context;
Index: linux-2.6.20-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.20-mm1.orig/mm/page_alloc.c	2007-02-16 01:22:09.000000000 -0800
+++ linux-2.6.20-mm1/mm/page_alloc.c	2007-02-16 01:40:39.000000000 -0800
@@ -767,40 +767,6 @@ static void __drain_pages(unsigned int c
 }
 
 #ifdef CONFIG_PM
-
-void mark_free_pages(struct zone *zone)
-{
-	unsigned long pfn, max_zone_pfn;
-	unsigned long flags;
-	int order;
-	struct list_head *curr;
-
-	if (!zone->spanned_pages)
-		return;
-
-	spin_lock_irqsave(&zone->lock, flags);
-
-	max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
-		if (pfn_valid(pfn)) {
-			struct page *page = pfn_to_page(pfn);
-
-			if (!PageNosave(page))
-				ClearPageNosaveFree(page);
-		}
-
-	for (order = MAX_ORDER - 1; order >= 0; --order)
-		list_for_each(curr, &zone->free_area[order].free_list) {
-			unsigned long i;
-
-			pfn = page_to_pfn(list_entry(curr, struct page, lru));
-			for (i = 0; i < (1UL << order); i++)
-				SetPageNosaveFree(pfn_to_page(pfn + i));
-		}
-
-	spin_unlock_irqrestore(&zone->lock, flags);
-}
-
 /*
  * Spill all of this CPU's per-cpu pages back into the buddy allocator.
  */
@@ -2354,6 +2320,9 @@ __meminit int init_currently_empty_zone(
 	ret = zone_wait_table_init(zone, size);
 	if (ret)
 		return ret;
+	ret = suspend_flags_init(zone, size);
+	if (ret)
+		return ret;
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;
Index: linux-2.6.20-mm1/kernel/power/snapshot.c
===================================================================
--- linux-2.6.20-mm1.orig/kernel/power/snapshot.c	2007-02-16 01:46:02.000000000 -0800
+++ linux-2.6.20-mm1/kernel/power/snapshot.c	2007-02-16 01:59:24.000000000 -0800
@@ -34,6 +34,126 @@
 
 #include "power.h"
 
+static inline int PageNosave(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	return test_bit(offset * 2, zone->suspend_flags);
+}
+
+static inline void SetPageNosave(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	set_bit(offset * 2, zone->suspend_flags);
+}
+
+static inline int TestSetPageNosave(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	return test_and_set_bit(offset * 2, zone->suspend_flags);
+}
+
+static inline void ClearPageNosave(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	clear_bit(offset * 2, zone->suspend_flags);
+}
+
+static inline int TestClearPageNosave(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	return test_and_clear_bit(offset * 2, zone->suspend_flags);
+}
+
+
+static inline int PageNosaveFree(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	return test_bit(offset * 2 + 1, zone->suspend_flags);
+}
+
+static inline void SetPageNosaveFree(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	set_bit(offset * 2 + 1, zone->suspend_flags);
+}
+
+static inline void ClearPageNosaveFree(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long offset = page_to_pfn(page) - zone->zone_start_pfn;
+
+	clear_bit(offset * 2 + 1, zone->suspend_flags);
+}
+
+int suspend_flags_init(struct zone *zone, unsigned long zone_size_pages)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	size_t alloc_size;
+
+	/*
+	 * We need two bits per page in the zone. One for PageNosave and the other
+	 * for PageNosaveFree.
+	 */
+	alloc_size = BITS_TO_LONGS(zone_size_pages * 2);
+ 	if (system_state == SYSTEM_BOOTING) {
+		zone->suspend_flags = (unsigned long *)
+			alloc_bootmem_node(pgdat, alloc_size);
+	} else
+		zone->suspend_flags = (unsigned long *)vmalloc(alloc_size);
+	if (!zone->suspend_flags)
+		return -ENOMEM;
+
+	bitmap_zero(zone->suspend_flags, 2 * zone_size_pages);
+	return 0;
+}
+
+void mark_free_pages(struct zone *zone)
+{
+	unsigned long pfn, max_zone_pfn;
+	unsigned long flags;
+	int order;
+	struct list_head *curr;
+
+	if (!zone->spanned_pages)
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	max_zone_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++)
+		if (pfn_valid(pfn)) {
+			struct page *page = pfn_to_page(pfn);
+
+			if (!PageNosave(page))
+				ClearPageNosaveFree(page);
+		}
+
+	for (order = MAX_ORDER - 1; order >= 0; --order)
+		list_for_each(curr, &zone->free_area[order].free_list) {
+			unsigned long i;
+
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			for (i = 0; i < (1UL << order); i++)
+				SetPageNosaveFree(pfn_to_page(pfn + i));
+		}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
 /* List of PBEs needed for restoring the pages that were allocated before
  * the suspend and included in the suspend image, but have also been
  * allocated by the "resume" kernel, so their contents cannot be written

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
