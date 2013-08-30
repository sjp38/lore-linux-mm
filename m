Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 203056B0080
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:29 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 09:25:28 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4C5726E8048
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:25 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDPPDi22085644
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:25:25 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDPNnv003284
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:24 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 24/35] mm: Propagate the sorted-buddy bias for picking
 free regions, to region allocator
Date: Fri, 30 Aug 2013 18:51:25 +0530
Message-ID: <20130830132123.4947.26449.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The sorted-buddy page allocator keeps the buddy freelists sorted region-wise,
and tries to pick lower numbered regions while allocating pages. The idea is
to allocate regions in the increasing order of region number.

Propagate the same bias to the region allocator as well. That is, make it
favor lower numbered regions while allocating regions to the page allocator.
To do this efficiently, add a bitmap to represent the regions in the region
allocator, and use bitmap operations to manage these regions and to pick the
lowest numbered free region efficiently.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c2956dd..8c6e9f1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -125,6 +125,7 @@ struct mem_region {
 struct region_allocator {
 	struct mem_region	region[MAX_NR_ZONE_REGIONS];
 	int			next_region;
+	DECLARE_BITMAP(ralloc_mask, MAX_NR_ZONE_REGIONS);
 };
 
 struct pglist_data;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 78ae8f6..7e82872a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -934,7 +934,7 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
 	unsigned long nr_pages;
-	int order;
+	int order, *next_region;
 
 	if (WARN_ON(list_empty(&free_list->list)))
 		return;
@@ -951,6 +951,13 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 
 	WARN_ON(reg_area->nr_free != 0);
 	reg_area->nr_free += nr_pages;
+
+	set_bit(region_id, reg_alloc->ralloc_mask);
+	next_region = &reg_alloc->next_region;
+
+	if ((*next_region < 0) ||
+			(*next_region > 0 && region_id < *next_region))
+		*next_region = region_id;
 }
 
 /* Delete freepages from the region allocator and add them to buddy freelists */
@@ -981,6 +988,16 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 	reg_area->nr_free -= nr_pages;
 	WARN_ON(reg_area->nr_free != 0);
 
+	/* Pick a new next_region */
+	clear_bit(next_region, reg_alloc->ralloc_mask);
+	next_region = find_first_bit(reg_alloc->ralloc_mask,
+				     MAX_NR_ZONE_REGIONS);
+
+	if (next_region >= MAX_NR_ZONE_REGIONS)
+		next_region = -1; /* No free regions available */
+
+	reg_alloc->next_region = next_region;
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
