Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k137lqv9015849 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:47:52 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k137lpY7003247 for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:47:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 85F33F8478
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:47:51 +0900 (JST)
Received: from fjm501.ms.jp.fujitsu.com (fjm501.ms.jp.fujitsu.com [10.56.99.71])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 391BFF8AC8
	for <linux-mm@kvack.org>; Fri,  3 Feb 2006 16:47:51 +0900 (JST)
Received: from [127.0.0.1] (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm501.ms.jp.fujitsu.com with ESMTP id k137lZUO024499
	for <linux-mm@kvack.org>; Fri, 3 Feb 2006 16:47:36 +0900
Message-ID: <43E30AD2.7070703@jp.fujitsu.com>
Date: Fri, 03 Feb 2006 16:48:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC] peeling off zone from physical memory layout [6/10] for each
 page in zone.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Some codes want to walk all page sturct in a zone.
This patch addes for_each_page_in_zone() to help them.

Because memory_map_list is not sorted, page will appear in random way.
If this is a problem, some fix will be needed.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitu.com>


Index: hogehoge/include/linux/memorymap.h
===================================================================
--- hogehoge.orig/include/linux/memorymap.h
+++ hogehoge/include/linux/memorymap.h
@@ -40,4 +40,41 @@ static inline void memory_resize_unlock(
  #endif


+/*
+ * Rarely used, but some codes searchs all pages in zone.
+ * which is done just by pfn++ in old days.
+ * pfn_to_zone can be done by page_zone(pfn_to_page(page)), so memory_map
+ * doesn't support such ops.
+ */
+
+static inline struct page *next_page_in_zone(struct page *page, struct zone *z, void **iter)
+{
+	unsigned long pfn = page_to_pfn(page);
+	struct memory_map* ent = (struct memory_map *)*iter;
+	if (pfn + 1 < ent->end_pfn)
+		return pfn_to_page(pfn + 1);
+	list_for_each_entry_continue(ent, &memory_map_list, list) {
+		if (ent->zone == z)
+			return pfn_to_page(ent->start_pfn);
+	}
+	return NULL;
+}
+
+static inline unsigned long lookup_zone_page(struct zone *z, void **iter)
+{
+	struct memory_map *ent;
+	list_for_each_entry(ent, &memory_map_list, list) {
+		if (ent->zone == z) {
+			*iter = ent;
+			return ent->start_pfn;
+		}
+	}
+	BUG();
+}
+
+/* iter is void*.  memory resize lock has to be held.*/
+#define for_each_page_in_zone(p, z, iter)	\
+	for (p = pfn_to_page(lookup_zone_page( z, &iter)), iter=NULL; \
+	     p != NULL;\
+	     p = next_page_in_zone(p, z, &iter))
  #endif
Index: hogehoge/mm/page_alloc.c
===================================================================
--- hogehoge.orig/mm/page_alloc.c
+++ hogehoge/mm/page_alloc.c
@@ -643,7 +643,9 @@ static void __drain_pages(unsigned int c

  void mark_free_pages(struct zone *zone)
  {
-	unsigned long zone_pfn, flags;
+	struct page *page;
+	void *iter;
+	unsigned long flags;
  	int order;
  	struct list_head *curr;

@@ -651,8 +653,8 @@ void mark_free_pages(struct zone *zone)
  		return;

  	spin_lock_irqsave(&zone->lock, flags);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-		ClearPageNosaveFree(pfn_to_page(zone_pfn + zone->zone_start_pfn));
+	for_each_page_in_zone(page, zone, iter)
+		ClearPageNosaveFree(page);

  	for (order = MAX_ORDER - 1; order >= 0; --order)
  		list_for_each(curr, &zone->free_area[order].free_list) {
Index: hogehoge/kernel/power/snapshot.c
===================================================================
--- hogehoge.orig/kernel/power/snapshot.c
+++ hogehoge/kernel/power/snapshot.c
@@ -24,6 +24,7 @@
  #include <linux/syscalls.h>
  #include <linux/console.h>
  #include <linux/highmem.h>
+#include <linux/memorymap.h>

  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
@@ -31,6 +32,7 @@
  #include <asm/tlbflush.h>
  #include <asm/io.h>

+
  #include "power.h"

  struct pbe *pagedir_nosave;
@@ -40,18 +42,14 @@ unsigned int nr_copy_pages;
  unsigned int count_highmem_pages(void)
  {
  	struct zone *zone;
-	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;
  	unsigned int n = 0;

  	for_each_zone (zone)
  		if (is_highmem(zone)) {
  			mark_free_pages(zone);
-			for (zone_pfn = 0; zone_pfn < zone->spanned_pages; zone_pfn++) {
-				struct page *page;
-				unsigned long pfn = zone_pfn + zone->zone_start_pfn;
-				if (!pfn_valid(pfn))
-					continue;
-				page = pfn_to_page(pfn);
+			for_each_page_in_zone(page, zone, iter) {
  				if (PageReserved(page))
  					continue;
  				if (PageNosaveFree(page))
@@ -72,19 +70,15 @@ static struct highmem_page *highmem_copy

  static int save_highmem_zone(struct zone *zone)
  {
-	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;
  	mark_free_pages(zone);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
-		struct page *page;
+	for_each_page_in_zone(page, zone, iter) {
  		struct highmem_page *save;
  		void *kaddr;
-		unsigned long pfn = zone_pfn + zone->zone_start_pfn;
-
+		unsigned long pfn = page_to_pfn(page);
  		if (!(pfn%1000))
  			printk(".");
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
  		/*
  		 * This condition results from rvmalloc() sans vmalloc_32()
  		 * and architectural memory reservations. This should be
@@ -165,15 +159,8 @@ static int pfn_is_nosave(unsigned long p
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
@@ -188,15 +175,16 @@ static int saveable(struct zone *zone, u
  unsigned int count_data_pages(void)
  {
  	struct zone *zone;
-	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;
  	unsigned int n = 0;

  	for_each_zone (zone) {
  		if (is_highmem(zone))
  			continue;
  		mark_free_pages(zone);
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			n += saveable(zone, &zone_pfn);
+		for_each_page_in_zone(page, zone, iter)
+			n += saveable(page);
  	}
  	return n;
  }
@@ -204,7 +192,8 @@ unsigned int count_data_pages(void)
  static void copy_data_pages(struct pbe *pblist)
  {
  	struct zone *zone;
-	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;
  	struct pbe *pbe, *p;

  	pbe = pblist;
@@ -217,10 +206,8 @@ static void copy_data_pages(struct pbe *
  			SetPageNosaveFree(virt_to_page(p));
  		for_each_pbe (p, pblist)
  			SetPageNosaveFree(virt_to_page(p->address));
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
-			if (saveable(zone, &zone_pfn)) {
-				struct page *page;
-				page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
+		for_each_page_in_zone(page, zone, iter) {
+			if (saveable(page)) {
  				BUG_ON(!pbe);
  				pbe->orig_address = (unsigned long)page_address(page);
  				/* copy_page is not usable for copying task structs. */
@@ -402,20 +389,16 @@ struct pbe *alloc_pagedir(unsigned int n
  void swsusp_free(void)
  {
  	struct zone *zone;
-	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;

-	for_each_zone(zone) {
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			if (pfn_valid(zone_pfn + zone->zone_start_pfn)) {
-				struct page *page;
-				page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
-				if (PageNosave(page) && PageNosaveFree(page)) {
-					ClearPageNosave(page);
-					ClearPageNosaveFree(page);
-					free_page((long) page_address(page));
-				}
+	for_each_zone(zone)
+		for_each_page_in_zone(page, zone, iter)
+			if (PageNosave(page) && PageNosaveFree(page)) {
+				ClearPageNosave(page);
+				ClearPageNosaveFree(page);
+				free_page((long) page_address(page));
  			}
-	}
  }


Index: hogehoge/kernel/power/swsusp.c
===================================================================
--- hogehoge.orig/kernel/power/swsusp.c
+++ hogehoge/kernel/power/swsusp.c
@@ -60,6 +60,7 @@
  #include <linux/syscalls.h>
  #include <linux/highmem.h>
  #include <linux/bio.h>
+#include <linux/memorymap.h>

  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
@@ -673,6 +674,8 @@ static void mark_unsafe_pages(struct pbe
  {
  	struct zone *zone;
  	unsigned long zone_pfn;
+	struct page *page;
+	void *iter;
  	struct pbe *p;

  	if (!pblist) /* a sanity check */
@@ -680,10 +683,8 @@ static void mark_unsafe_pages(struct pbe

  	/* Clear page flags */
  	for_each_zone (zone) {
-		for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-			if (pfn_valid(zone_pfn + zone->zone_start_pfn))
-				ClearPageNosaveFree(pfn_to_page(zone_pfn +
-					zone->zone_start_pfn));
+		for_each_page_in_zone(page, zone, iter)
+			ClearPageNosaveFree(page);
  	}

  	/* Mark orig addresses */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
