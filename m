Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A0EC06B0071
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:24:32 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so471527pad.35
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:24:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:54:25 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 29968394004D
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:08 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNQeOh38207528
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:56:40 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNOLlj020894
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:23 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 29/40] mm: Add a way to request pages of a particular
 region from the region allocator
Date: Thu, 26 Sep 2013 04:50:15 +0530
Message-ID: <20130925232014.26184.62048.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When moving freepages from one migratetype to another (using move_freepages()
or equivalent), we might encounter situations in which we would like to move
pages that are in the region allocator. In such cases, we need a way to
request pages of a particular region from the region allocator.

We already have the code to perform the heavy-lifting of actually moving the
pages of a region from the region allocator to a requested freelist or
migratetype. So just reorganize that code in such a way that we can also
pin-point a region and specify that we want the region allocator to allocate
pages from that particular region.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ac04b45..ed5298c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1003,24 +1003,18 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 		*next_region = region_id;
 }
 
-/* Delete freepages from the region allocator and add them to buddy freelists */
-static int del_from_region_allocator(struct zone *zone, unsigned int order,
-				     int migratetype)
+static void __del_from_region_allocator(struct zone *zone, unsigned int order,
+					int migratetype, int region_id)
 {
 	struct region_allocator *reg_alloc;
 	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
 	struct free_list *free_list;
 	unsigned long nr_pages;
-	int next_region;
+	struct page *page;
 
 	reg_alloc = &zone->region_allocator;
-
-	next_region = reg_alloc->next_region;
-	if (next_region < 0)
-		return -ENOMEM;
-
-	reg_area = &reg_alloc->region[next_region].region_area[order];
+	reg_area = &reg_alloc->region[region_id].region_area[order];
 	ralloc_list = &reg_area->list;
 
 	list_for_each_entry(page, ralloc_list, lru)
@@ -1029,20 +1023,34 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 	free_list = &zone->free_area[order].free_list[migratetype];
 
 	nr_pages = add_to_freelist_bulk(ralloc_list, free_list, order,
-					next_region);
+					region_id);
 
 	reg_area->nr_free -= nr_pages;
 	WARN_ON(reg_area->nr_free != 0);
 
 	/* Pick a new next_region */
-	clear_bit(next_region, reg_alloc->ralloc_mask);
-	next_region = find_first_bit(reg_alloc->ralloc_mask,
+	clear_bit(region_id, reg_alloc->ralloc_mask);
+	region_id = find_first_bit(reg_alloc->ralloc_mask,
 				     MAX_NR_ZONE_REGIONS);
 
-	if (next_region >= MAX_NR_ZONE_REGIONS)
-		next_region = -1; /* No free regions available */
+	if (region_id >= MAX_NR_ZONE_REGIONS)
+		region_id = -1; /* No free regions available */
+
+	reg_alloc->next_region = region_id;
+}
+
+/* Delete freepages from the region allocator and add them to buddy freelists */
+static int del_from_region_allocator(struct zone *zone, unsigned int order,
+				     int migratetype)
+{
+	int next_region;
+
+	next_region = zone->region_allocator.next_region;
+
+	if (next_region < 0)
+		return -ENOMEM;
 
-	reg_alloc->next_region = next_region;
+	__del_from_region_allocator(zone, order, migratetype, next_region);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
