Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E77706B005C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:15 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:25:15 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4C7A4C90052
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:12 -0400 (EDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDPBRS6815882
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:25:12 GMT
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDP9Kg015766
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:25:11 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 23/35] mm: Maintain the counter for freepages in the
 region allocator
Date: Fri, 30 Aug 2013 18:51:07 +0530
Message-ID: <20130830132105.4947.22292.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index 5b58e7d..78ae8f6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -696,10 +696,12 @@ out:
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
@@ -708,7 +710,7 @@ static void add_to_freelist_bulk(struct list_head *list,
 	struct page *page;
 
 	if (list_empty(list))
-		return;
+		return 0;
 
 	page = list_first_entry(list, struct page, lru);
 	list_del(&page->lru);
@@ -736,6 +738,8 @@ static void add_to_freelist_bulk(struct list_head *list,
 
 	/* Fix up the zone region stats, since add_to_freelist() altered it */
 	region->zone_region->nr_free -= 1 << order;
+
+	return nr_pages + 1;
 }
 
 /**
@@ -857,10 +861,12 @@ page_found:
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
@@ -906,6 +912,8 @@ static void del_from_freelist_bulk(struct list_head *list,
 
 	/* Fix up the zone region stats, since del_from_freelist() altered it */
 	region->zone_region->nr_free += 1 << order;
+
+	return nr_pages + 1;
 }
 
 /**
@@ -923,7 +931,9 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 				    int region_id)
 {
 	struct region_allocator *reg_alloc;
+	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
+	unsigned long nr_pages;
 	int order;
 
 	if (WARN_ON(list_empty(&free_list->list)))
@@ -933,9 +943,14 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
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
@@ -943,8 +958,10 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 				     int migratetype)
 {
 	struct region_allocator *reg_alloc;
+	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
 	struct free_list *free_list;
+	unsigned long nr_pages;
 	int next_region;
 
 	reg_alloc = &zone->region_allocator;
@@ -953,10 +970,16 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
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
