Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E9CE76B007B
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:05 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:23:05 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3E6806E803C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:03 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDN3OQ10027056
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:23:03 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDMxul027970
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 10:23:02 -0300
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 17/35] mm: Add aggressive bias to prefer lower regions
 during page allocation
Date: Fri, 30 Aug 2013 18:49:05 +0530
Message-ID: <20130830131902.4947.17975.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

While allocating pages from buddy freelists, there could be situations
in which we have a ready freepage of the required order in a *higher*
numbered memory region, and there also exists a freepage of a higher
page order in a *lower* numbered memory region.

To make the consolidation logic more aggressive, try to split up the
higher order buddy page of a lower numbered region and allocate it,
rather than allocating pages from a higher numbered region.

This ensures that we spill over to a new region only when we truly
don't have enough contiguous memory in any lower numbered region to
satisfy that allocation request.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   44 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e711b9..0cc2a3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1210,8 +1210,9 @@ static inline
 struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
-	unsigned int current_order;
-	struct free_area * area;
+	unsigned int current_order, alloc_order;
+	struct free_area *area, *other_area;
+	int alloc_region, other_region;
 	struct page *page;
 
 	/* Find a page of the appropriate size in the preferred list */
@@ -1220,17 +1221,40 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		if (list_empty(&area->free_list[migratetype].list))
 			continue;
 
-		page = list_entry(area->free_list[migratetype].list.next,
-							struct page, lru);
-		rmqueue_del_from_freelist(page, &area->free_list[migratetype],
-					  current_order);
-		rmv_page_order(page);
-		area->nr_free--;
-		expand(zone, page, order, current_order, area, migratetype);
-		return page;
+		alloc_order = current_order;
+		alloc_region = area->free_list[migratetype].next_region -
+				area->free_list[migratetype].mr_list;
+		current_order++;
+		goto try_others;
 	}
 
 	return NULL;
+
+try_others:
+	/* Try to aggressively prefer lower numbered regions for allocations */
+	for ( ; current_order < MAX_ORDER; ++current_order) {
+		other_area = &(zone->free_area[current_order]);
+		if (list_empty(&other_area->free_list[migratetype].list))
+			continue;
+
+		other_region = other_area->free_list[migratetype].next_region -
+				other_area->free_list[migratetype].mr_list;
+
+		if (other_region < alloc_region) {
+			alloc_region = other_region;
+			alloc_order = current_order;
+		}
+	}
+
+	area = &(zone->free_area[alloc_order]);
+	page = list_entry(area->free_list[migratetype].list.next, struct page,
+			  lru);
+	rmqueue_del_from_freelist(page, &area->free_list[migratetype],
+				  alloc_order);
+	rmv_page_order(page);
+	area->nr_free--;
+	expand(zone, page, order, alloc_order, area, migratetype);
+	return page;
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
