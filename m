Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1N8v4TF009990 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:57:04 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1N8v3HC016281 for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:57:03 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE8DC2A0C00
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:57:02 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E5B22A0BF9
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:57:02 +0900 (JST)
Received: from aworks (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm505.ms.jp.fujitsu.com with SMTP id k1N8ubvh009686
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 17:56:37 +0900
Date: Thu, 23 Feb 2006 17:56:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] memory-layout-free zones (for review) [1/3]
 for_each_page_in_zone()
Message-Id: <20060223175643.a685dfb3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, I'm now modifing zone to be free from memory layout mainly
for memory-hotplug. This post is just for review.

By these patches, zone_start_pfn/zone_spanned_pages are removed.
I already posted removing zone_mem_map patch. So, a zone which a 
page belongs to is determined just by what (pfn,range) is passed to 
free_area_init_core(). 

These patches will change the meaning of zones from a range of pages
to a group of pages, but no real effect now.

I'm now considering to move page betweens zones and add new zone
as ZONE_EASYRCLM, which is not defined by the range.
(IMHO, ZONE_EMERGENCY can be implemented in clean way in future
 rather than mempools.)

I'll post these to lkml if I'm ready.

--Kame
==
This patch defines for_each_page_in_zone(page, zone) macro.
This macro is useful for iterate over all (valid) pages in a zone.

Some of codes, especially kernel/power/snapshot.c, iterate over
all pages in zone. This patch can clean up them.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: node-hot-add2/include/linux/mmzone.h
===================================================================
--- node-hot-add2.orig/include/linux/mmzone.h
+++ node-hot-add2/include/linux/mmzone.h
@@ -474,6 +474,54 @@ static inline struct zone *next_zone(str
 	     zone;					\
 	     zone = next_zone(zone))
 
+/*
+ *  These inline function for for_each_page_in_zone can work
+ *  even if CONFIG_SPARSEMEM=y.
+ */
+static inline struct page *first_page_in_zone(struct zone *zone)
+{
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long i = 0;
+
+	if (!populated_zone(zone))
+		return NULL;
+
+	for (i = 0; i < zone->zone_spanned_pages; i++) {
+		if (pfn_valid(start_pfn + i))
+			break;
+	}
+	return pfn_to_page(start_pfn + i);
+}
+
+static inline struct page *next_page_in_zone(struct page *page,
+					     struct zone *zone)
+{
+	unsigned long start_pfn = zone->zone_start_pfn;
+	unsigned long i = page_to_pfn(page) - start_pfn;
+
+	if (!populated_zone(zone))
+		return NULL;
+
+	for (i = i + 1; i < zone->zone_spanned_pages; i++) {
+		if (pfn_vlaid(start_pfn + i))
+			break;
+	}
+	if (i == zone->zone_spanned_pages)
+		return NULL;
+	return pfn_to_page(start_pfn + i);
+}
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
+	     page = next_page_in_zone(page, (zone)));
+
 #ifdef CONFIG_SPARSEMEM
 #include <asm/sparsemem.h>
 #endif
Index: node-hot-add2/mm/page_alloc.c
===================================================================
--- node-hot-add2.orig/mm/page_alloc.c
+++ node-hot-add2/mm/page_alloc.c
@@ -670,7 +670,8 @@ static void __drain_pages(unsigned int c
 
 void mark_free_pages(struct zone *zone)
 {
-	unsigned long zone_pfn, flags;
+	struct page *page;
+	unsigned long flags;
 	int order;
 	struct list_head *curr;
 
@@ -678,8 +679,8 @@ void mark_free_pages(struct zone *zone)
 		return;
 
 	spin_lock_irqsave(&zone->lock, flags);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-		ClearPageNosaveFree(pfn_to_page(zone_pfn + zone->zone_start_pfn));
+	for_each_page_in_zone(page, zone)
+		ClearPageNosaveFree(page);
 
 	for (order = MAX_ORDER - 1; order >= 0; --order)
 		list_for_each(curr, &zone->free_area[order].free_list) {
Index: node-hot-add2/kernel/power/snapshot.c
===================================================================
--- node-hot-add2.orig/kernel/power/snapshot.c
+++ node-hot-add2/kernel/power/snapshot.c
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
@@ -167,15 +157,8 @@ static int pfn_is_nosave(unsigned long p
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
@@ -219,10 +201,9 @@ static void copy_data_pages(struct pbe *
 			SetPageNosaveFree(virt_to_page(p));
 		for_each_pbe (p, pblist)
 			SetPageNosaveFree(virt_to_page(p->address));
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
-			if (saveable(zone, &zone_pfn)) {
+		for_each_page_in_zone(page, zone) {
+			if (saveable(page)) {
 				struct page *page;
-				page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
 				BUG_ON(!pbe);
 				pbe->orig_address = (unsigned long)page_address(page);
 				/* copy_page is not usable for copying task structs. */
@@ -403,19 +384,15 @@ struct pbe *alloc_pagedir(unsigned int n
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
@@ -618,18 +595,16 @@ int snapshot_read_next(struct snapshot_h
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
Index: node-hot-add2/arch/i386/mm/discontig.c
===================================================================
--- node-hot-add2.orig/arch/i386/mm/discontig.c
+++ node-hot-add2/arch/i386/mm/discontig.c
@@ -400,23 +400,15 @@ void __init set_highmem_pages_init(int b
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
