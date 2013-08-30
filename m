Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 998896B0081
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:28:59 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:28:58 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DEDDF19D8036
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:55 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDStLn172728
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDSsH3022664
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:55 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 35/35] mm: Use a cache between page-allocator and
 region-allocator
Date: Fri, 30 Aug 2013 18:54:59 +0530
Message-ID: <20130830132456.4947.67600.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, whenever the page allocator notices that it has all the freepages
of a given memory region, it attempts to return it back to the region
allocator. This strategy is needlessly aggressive and can cause a lot of back
and forth between the page-allocator and the region-allocator.

More importantly, it can potentially completely wreck the benefits of having
a region allocator in the first place - if the buddy allocator immediately
returns freepages of memory regions to the region allocator, it goes back to
the generic pool of pages. So, in future, depending on when the next allocation
request arrives for this particular migratetype, the region allocator might not
have any free regions to hand out, and hence we might end up falling back
to freepages of other migratetypes. Instead, if the page allocator retains
a few regions as a cache for every migratetype, we will have higher chances
of avoiding fallbacks to other migratetypes.

So, don't return all free memory regions (in the page allocator) to the
region allocator. Keep atleast one region as a cache, for future use.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1312546..55e8e65 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -639,9 +639,11 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 				    int region_id);
 
 
-static inline int can_return_region(struct mem_region_list *region, int order)
+static inline int can_return_region(struct mem_region_list *region, int order,
+				    struct free_list *free_list)
 {
 	struct zone_mem_region *zone_region;
+	struct page *prev_page, *next_page;
 
 	zone_region = region->zone_region;
 
@@ -659,6 +661,16 @@ static inline int can_return_region(struct mem_region_list *region, int order)
 	if (likely(order != MAX_ORDER-1))
 		return 0;
 
+	/*
+	 * Don't return all the regions; retain atleast one region as a
+	 * cache for future use.
+	 */
+	prev_page = container_of(free_list->list.prev , struct page, lru);
+	next_page = container_of(free_list->list.next , struct page, lru);
+
+	if (page_zone_region_id(prev_page) == page_zone_region_id(next_page))
+		return 0; /* There is only one region in this freelist */
+
 	if (region->nr_free * (1 << order) == zone_region->nr_free)
 		return 1;
 
@@ -728,7 +740,7 @@ try_return_region:
 	 * Try to return the freepages of a memory region to the region
 	 * allocator, if possible.
 	 */
-	if (can_return_region(region, order))
+	if (can_return_region(region, order, free_list))
 		add_to_region_allocator(page_zone(page), free_list, region_id);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
