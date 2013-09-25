Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C9C396B0071
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:22:56 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so320051pdi.5
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:22:56 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:52:52 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id DC97F1258051
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:02 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNP5wM44105756
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:05 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNMmTh021894
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:49 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 21/40] mm: Maintain the counter for freepages in the
 region allocator
Date: Thu, 26 Sep 2013 04:48:41 +0530
Message-ID: <20130925231839.26184.5712.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have a field named 'nr_free' for every memory-region in the region
allocator. Keep it updated with the count of freepages in that region.

We already run a loop while moving freepages in bulk between the buddy
allocator and the region allocator. Reuse that to update the freepages
count as well.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   45 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d71d671..ee6c098 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -697,10 +697,12 @@ out:
  * Add all the freepages contained in 'list' to the buddy freelist
  * 'free_list'. Using suitable list-manipulation tricks, we move the
  * pages between the lists in one shot.
+ *
+ * Returns the number of pages moved.
  */
-static void add_to_freelist_bulk(struct list_head *list,
-				 struct free_list *free_list, int order,
-				 int region_id)
+static unsigned long
+add_to_freelist_bulk(struct list_head *list, struct free_list *free_list,
+		     int order, int region_id)
 {
 	struct list_head *cur, *position;
 	struct mem_region_list *region;
@@ -709,7 +711,7 @@ static void add_to_freelist_bulk(struct list_head *list,
 	struct page *page;
 
 	if (list_empty(list))
-		return;
+		return 0;
 
 	page = list_first_entry(list, struct page, lru);
 	list_del(&page->lru);
@@ -737,6 +739,8 @@ static void add_to_freelist_bulk(struct list_head *list,
 
 	/* Fix up the zone region stats, since add_to_freelist() altered it */
 	region->zone_region->nr_free -= 1 << order;
+
+	return nr_pages + 1;
 }
 
 /**
@@ -858,10 +862,12 @@ page_found:
  * Delete all freepages belonging to the region 'region_id' from 'free_list'
  * and move them to 'list'. Using suitable list-manipulation tricks, we move
  * the pages between the lists in one shot.
+ *
+ * Returns the number of pages moved.
  */
-static void del_from_freelist_bulk(struct list_head *list,
-				   struct free_list *free_list, int order,
-				   int region_id)
+static unsigned long
+del_from_freelist_bulk(struct list_head *list, struct free_list *free_list,
+		       int order, int region_id)
 {
 	struct mem_region_list *region, *prev_region;
 	unsigned long nr_pages = 0;
@@ -907,6 +913,8 @@ static void del_from_freelist_bulk(struct list_head *list,
 
 	/* Fix up the zone region stats, since del_from_freelist() altered it */
 	region->zone_region->nr_free += 1 << order;
+
+	return nr_pages + 1;
 }
 
 /**
@@ -924,7 +932,9 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 				    int region_id)
 {
 	struct region_allocator *reg_alloc;
+	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
+	unsigned long nr_pages;
 	int order;
 
 	if (WARN_ON(list_empty(&free_list->list)))
@@ -934,9 +944,14 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 					    struct page, lru));
 
 	reg_alloc = &z->region_allocator;
-	ralloc_list = &reg_alloc->region[region_id].region_area[order].list;
+	reg_area = &reg_alloc->region[region_id].region_area[order];
+	ralloc_list = &reg_area->list;
+
+	nr_pages = del_from_freelist_bulk(ralloc_list, free_list, order,
+					  region_id);
 
-	del_from_freelist_bulk(ralloc_list, free_list, order, region_id);
+	WARN_ON(reg_area->nr_free != 0);
+	reg_area->nr_free += nr_pages;
 }
 
 /* Delete freepages from the region allocator and add them to buddy freelists */
@@ -944,8 +959,10 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 				     int migratetype)
 {
 	struct region_allocator *reg_alloc;
+	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
 	struct free_list *free_list;
+	unsigned long nr_pages;
 	int next_region;
 
 	reg_alloc = &zone->region_allocator;
@@ -954,10 +971,16 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 	if (next_region < 0)
 		return -ENOMEM;
 
-	ralloc_list = &reg_alloc->region[next_region].region_area[order].list;
+	reg_area = &reg_alloc->region[next_region].region_area[order];
+	ralloc_list = &reg_area->list;
+
 	free_list = &zone->free_area[order].free_list[migratetype];
 
-	add_to_freelist_bulk(ralloc_list, free_list, order, next_region);
+	nr_pages = add_to_freelist_bulk(ralloc_list, free_list, order,
+					next_region);
+
+	reg_area->nr_free -= nr_pages;
+	WARN_ON(reg_area->nr_free != 0);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
