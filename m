Date: Fri, 24 Feb 2006 17:15:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [RFC] for_each_page_in_zone [1/1]
Message-Id: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Pavel Machek <pavel@suse.cz>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch defines for_each_page_in_zone() macro. This replaces
routine like this:
==from==
for(i = 0; i < zone->zone_spanned_pages; i++) {
	if (!pfn_valid(pfn + i))
		continue;
	page = pfn_to_page(zone->zone_start_pfn + i);
	.....
==
==to==
for_each_page_in_zone(page,zone) {
	....
}
==
This can be used by many places in kernel/power/snapshot.c

This patch is against 2.6.16-rc4-mm1 and has no dependency to other pathces.
I did compile test and booted, but I don't have a hardware which touches codes
I modified. so...please check.

--diffstat--
 arch/i386/mm/discontig.c |   18 ++-------
 include/linux/mmzone.h   |   20 ++++++++++
 kernel/power/snapshot.c  |   72 +++++++++++-------------------------
 mm/Makefile              |    2 -
 mm/mmzone.c              |   92 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c          |    7 ++-
 6 files changed, 145 insertions(+), 66 deletions(-)
--

-- Kame
==
This patch defines for_each_page_in_zone(page, zone) macro.
This macro is useful for iterate over all (valid) pages in a zone.

Some of codes, especially kernel/power/snapshot.c, iterate over
all pages in zone. This patch can clean up them.

Changelog v1->v2
- misc fixes
- first_page_in_zone and next_page_in_zone are out-of-lined.
- a function next_valid_page() is added.
- patch against 2.6.16-rc4-mm1, no dependency to other patches.


Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: testtree/include/linux/mmzone.h
===================================================================
--- testtree.orig/include/linux/mmzone.h
+++ testtree/include/linux/mmzone.h
@@ -472,6 +472,26 @@ extern struct pglist_data contig_page_da
 
 #endif /* !CONFIG_NEED_MULTIPLE_NODES */
 
+/*
+ * these function uses suitable algorythm for each memory model
+ *
+ * first_page_in_zone(zone) returns first valid page in zone.
+ * next_page_in_zone(page,zone) returns next valid page in zone.
+ */
+extern struct page *first_page_in_zone(struct zone *zone);
+extern struct page *next_page_in_zone(struct page *page, struct zone *zone);
+
+/**
+ * for_each_page_in_zone -- helper macro to iterate over all pages in a zone.
+ * @page - pointer to page
+ * @zone - pointer to zone
+ *
+ */
+#define for_each_page_in_zone(page, zone)		\
+	for (page = (first_page_in_zone((zone)));	\
+	     page;					\
+	     page = next_page_in_zone(page, (zone)))
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
Index: testtree/mm/page_alloc.c
===================================================================
--- testtree.orig/mm/page_alloc.c
+++ testtree/mm/page_alloc.c
@@ -671,7 +671,8 @@ static void __drain_pages(unsigned int c
 
 void mark_free_pages(struct zone *zone)
 {
-	unsigned long zone_pfn, flags;
+	struct page *page;
+	unsigned long flags;
 	int order;
 	struct list_head *curr;
 
@@ -679,8 +680,8 @@ void mark_free_pages(struct zone *zone)
 		return;
 
 	spin_lock_irqsave(&zone->lock, flags);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-		ClearPageNosaveFree(pfn_to_page(zone_pfn + zone->zone_start_pfn));
+	for_each_page_in_zone(page, zone)
+		ClearPageNosaveFree(page);
 
 	for (order = MAX_ORDER - 1; order >= 0; --order)
 		list_for_each(curr, &zone->free_area[order].free_list) {
Index: testtree/kernel/power/snapshot.c
===================================================================
--- testtree.orig/kernel/power/snapshot.c
+++ testtree/kernel/power/snapshot.c
@@ -43,18 +43,12 @@ static unsigned long *buffer;
 unsigned int count_highmem_pages(void)
 {
 	struct zone *zone;
-	unsigned long zone_pfn;
 	unsigned int n = 0;
-
+	struct page *page;
 	for_each_zone (zone)
 		if (is_highmem(zone)) {
 			mark_free_pages(zone);
-			for (zone_pfn = 0; zone_pfn < zone->spanned_pages; zone_pfn++) {
-				struct page *page;
-				unsigned long pfn = zone_pfn + zone->zone_start_pfn;
-				if (!pfn_valid(pfn))
-					continue;
-				page = pfn_to_page(pfn);
+			for_each_page_in_zone(page, zone) {
 				if (PageReserved(page))
 					continue;
 				if (PageNosaveFree(page))
@@ -75,19 +69,15 @@ static struct highmem_page *highmem_copy
 
 static int save_highmem_zone(struct zone *zone)
 {
-	unsigned long zone_pfn;
+	struct page *page;
 	mark_free_pages(zone);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
-		struct page *page;
+	for_each_page_in_zone(page , zone) {
 		struct highmem_page *save;
 		void *kaddr;
-		unsigned long pfn = zone_pfn + zone->zone_start_pfn;
+		unsigned long pfn = page_to_pfn(page);
 
 		if (!(pfn%10000))
 			printk(".");
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
 		/*
 		 * This condition results from rvmalloc() sans vmalloc_32()
 		 * and architectural memory reservations. This should be
@@ -167,19 +157,12 @@ static int pfn_is_nosave(unsigned long p
  *	isn't part of a free chunk of pages.
  */
 
-static int saveable(struct zone *zone, unsigned long *zone_pfn)
+static int saveable(struct page *page)
 {
-	unsigned long pfn = *zone_pfn + zone->zone_start_pfn;
-	struct page *page;
-
-	if (!pfn_valid(pfn))
-		return 0;
-
-	page = pfn_to_page(pfn);
 	BUG_ON(PageReserved(page) && PageNosave(page));
 	if (PageNosave(page))
 		return 0;
-	if (PageReserved(page) && pfn_is_nosave(pfn))
+	if (PageReserved(page) && pfn_is_nosave(page_to_pfn(page)))
 		return 0;
 	if (PageNosaveFree(page))
 		return 0;
@@ -190,15 +173,15 @@ static int saveable(struct zone *zone, u
 unsigned int count_data_pages(void)
 {
 	struct zone *zone;
-	unsigned long zone_pfn;
+	struct page *page;
 	unsigned int n = 0;
 
 	for_each_zone (zone) {
 		if (is_highmem(zone))
 			continue;
 		mark_free_pages(zone);
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			n += saveable(zone, &zone_pfn);
+		for_each_page_in_zone(page, zone)
+			n += saveable(page);
 	}
 	return n;
 }
@@ -206,9 +189,8 @@ unsigned int count_data_pages(void)
 static void copy_data_pages(struct pbe *pblist)
 {
 	struct zone *zone;
-	unsigned long zone_pfn;
 	struct pbe *pbe, *p;
-
+	struct page *page;
 	pbe = pblist;
 	for_each_zone (zone) {
 		if (is_highmem(zone))
@@ -219,10 +201,8 @@ static void copy_data_pages(struct pbe *
 			SetPageNosaveFree(virt_to_page(p));
 		for_each_pbe (p, pblist)
 			SetPageNosaveFree(virt_to_page(p->address));
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
-			if (saveable(zone, &zone_pfn)) {
-				struct page *page;
-				page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
+		for_each_page_in_zone(page, zone) {
+			if (saveable(page)) {
 				BUG_ON(!pbe);
 				pbe->orig_address = (unsigned long)page_address(page);
 				/* copy_page is not usable for copying task structs. */
@@ -403,19 +383,15 @@ struct pbe *alloc_pagedir(unsigned int n
 void swsusp_free(void)
 {
 	struct zone *zone;
-	unsigned long zone_pfn;
-
+	struct page *page;
 	for_each_zone(zone) {
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			if (pfn_valid(zone_pfn + zone->zone_start_pfn)) {
-				struct page *page;
-				page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
-				if (PageNosave(page) && PageNosaveFree(page)) {
-					ClearPageNosave(page);
-					ClearPageNosaveFree(page);
-					free_page((long) page_address(page));
-				}
+		for_each_page_in_zone(page, zone) {
+			if (PageNosave(page) && PageNosaveFree(page)) {
+				ClearPageNosave(page);
+				ClearPageNosaveFree(page);
+				free_page((long) page_address(page));
 			}
+		}
 	}
 	nr_copy_pages = 0;
 	nr_meta_pages = 0;
@@ -618,18 +594,16 @@ int snapshot_read_next(struct snapshot_h
 static int mark_unsafe_pages(struct pbe *pblist)
 {
 	struct zone *zone;
-	unsigned long zone_pfn;
 	struct pbe *p;
+	struct page *page;
 
 	if (!pblist) /* a sanity check */
 		return -EINVAL;
 
 	/* Clear page flags */
 	for_each_zone (zone) {
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			if (pfn_valid(zone_pfn + zone->zone_start_pfn))
-				ClearPageNosaveFree(pfn_to_page(zone_pfn +
-					zone->zone_start_pfn));
+		for_each_page_in_zone(page, zone)
+			ClearPageNosaveFree(page);
 	}
 
 	/* Mark orig addresses */
Index: testtree/arch/i386/mm/discontig.c
===================================================================
--- testtree.orig/arch/i386/mm/discontig.c
+++ testtree/arch/i386/mm/discontig.c
@@ -411,23 +411,15 @@ void __init set_highmem_pages_init(int b
 	struct page *page;
 
 	for_each_zone(zone) {
-		unsigned long node_pfn, zone_start_pfn, zone_end_pfn;
-
 		if (!is_highmem(zone))
 			continue;
 
-		zone_start_pfn = zone->zone_start_pfn;
-		zone_end_pfn = zone_start_pfn + zone->spanned_pages;
-
-		printk("Initializing %s for node %d (%08lx:%08lx)\n",
-				zone->name, zone->zone_pgdat->node_id,
-				zone_start_pfn, zone_end_pfn);
+		printk("Initializing %s for node %d\n",
+				zone->name, zone->zone_pgdat->node_id);
 
-		for (node_pfn = zone_start_pfn; node_pfn < zone_end_pfn; node_pfn++) {
-			if (!pfn_valid(node_pfn))
-				continue;
-			page = pfn_to_page(node_pfn);
-			add_one_highpage_init(page, node_pfn, bad_ppro);
+		for_each_page_in_zone(page, zone) {
+			add_one_highpage_init(page,
+				page_to_pfn(page), bad_ppro);
 		}
 	}
 	totalram_pages += totalhigh_pages;
Index: testtree/mm/Makefile
===================================================================
--- testtree.orig/mm/Makefile
+++ testtree/mm/Makefile
@@ -10,7 +10,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
-			   prio_tree.o util.o $(mmu-y)
+			   prio_tree.o util.o mmzone.o $(mmu-y)
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
Index: testtree/mm/mmzone.c
===================================================================
--- /dev/null
+++ testtree/mm/mmzone.c
@@ -0,0 +1,92 @@
+/*
+ * mmzone.c -- functions for zone/pgdat, except for page allocator.
+ *             includes functions depedns on memory models.
+ */
+#include <linux/config.h>
+#include <stddef.h>
+#include <linux/mm.h>
+
+#define END_PFN		(~0UL)	/* used to show end of pfn */
+
+/*
+ * helper functions for each memory models.
+ *
+ * returns next valid pfn in range..
+ */
+#if defined(CONFIG_FLATMEM) || defined(CONFIG_DISCONTIGMEM)
+
+static inline unsigned long next_valid_pfn(unsigned long pfn,
+					   unsigned long end_pfn)
+{
+	do {
+		++pfn;
+		if (pfn == end_pfn)
+			return END_PFN;
+	} while (!pfn_valid(pfn));
+
+	return pfn;
+}
+
+#elif defined(CONFIG_SPARSEMEM)
+
+static inline unsigned long next_valid_pfn(unsigned long pfn,
+					   unsigned long end_pfn)
+{
+	++pfn;
+	do {
+		if (pfn_valid(pfn))
+			break;
+		/* go to next section */
+		pfn = ((pfn + PAGES_PER_SECTION) & PAGE_SECTION_MASK);
+
+	} while (pfn <= end_pfn);
+
+	if (pfn >= end_pfn)
+		return END_PFN;
+
+	return pfn;
+}
+
+#endif
+
+/*
+ * generic routine.
+ *
+ * first_page_in_zone(zone) returns lowest valid page in zone.
+ * next_page_in_zone(page,zone)  returns next valid page in zone.
+ */
+
+struct page *first_page_in_zone(struct zone *zone)
+{
+	unsigned long pfn;
+
+	if (!populated_zone(zone))
+		return NULL;
+
+	if (pfn_valid(zone->zone_start_pfn))
+		return pfn_to_page(zone->zone_start_pfn);
+
+	pfn = next_valid_pfn(zone->zone_start_pfn,
+			     zone->zone_start_pfn + zone->spanned_pages);
+
+	if (pfn == END_PFN) /* this means zone is empty */
+		return NULL;
+
+	return pfn_to_page(pfn);
+}
+
+struct page *next_page_in_zone(struct page *page, struct zone *zone)
+{
+	unsigned long pfn = page_to_pfn(page);
+
+	if (!populated_zone(zone))
+		return NULL;
+
+	pfn = next_valid_pfn(pfn, zone->zone_start_pfn + zone->spanned_pages);
+
+	if (pfn == END_PFN)
+		return NULL;
+
+	return pfn_to_page(pfn);
+}
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
