Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 453F46B0081
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:24:02 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:24:01 +0100
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4DE4A38C804D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:57 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDNvm320185088
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:23:57 GMT
Received: from d01av05.pok.ibm.com (loopback [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDNuXe020012
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:56 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 20/35] mm: Provide a mechanism to delete pages from
 buddy freelists in bulk
Date: Fri, 30 Aug 2013 18:50:01 +0530
Message-ID: <20130830131959.4947.91045.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When the buddy allocator releases excess free memory to the region
allocator, it does it at a region granularity - that is, it releases
all the freepages of that region to the region allocator, at once.
So, in order to make this efficient, we need a way to delete all those
pages from the buddy freelists in one shot. Add this support, and also
take care to update the nr-free statistics properly.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b66ddff..5227ac3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -853,6 +853,61 @@ page_found:
 	}
 }
 
+/*
+ * Delete all freepages belonging to the region 'region_id' from 'free_list'
+ * and move them to 'list'. Using suitable list-manipulation tricks, we move
+ * the pages between the lists in one shot.
+ */
+static void del_from_freelist_bulk(struct list_head *list,
+				   struct free_list *free_list, int order,
+				   int region_id)
+{
+	struct mem_region_list *region, *prev_region;
+	unsigned long nr_pages = 0;
+	struct free_area *area;
+	struct list_head *cur;
+	struct page *page;
+	int prev_region_id;
+
+	region = &free_list->mr_list[region_id];
+
+	/*
+	 * Perform bulk movement of all pages of the region to the new list,
+	 * except the page pointed to by region->pageblock.
+	 */
+	prev_region_id = find_prev_region(region_id, free_list);
+	if (prev_region_id < 0) {
+		/* This is the first region on the list */
+		list_cut_position(list, &free_list->list,
+				  region->page_block->prev);
+	} else {
+		prev_region = &free_list->mr_list[prev_region_id];
+		list_cut_position(list, prev_region->page_block,
+				  region->page_block->prev);
+	}
+
+	list_for_each(cur, list)
+		nr_pages++;
+
+	region->nr_free -= nr_pages;
+
+	/*
+	 * Now delete the page pointed to by region->page_block using
+	 * del_from_freelist(), so that it sets up the region related
+	 * data-structures of the freelist properly.
+	 */
+	page = list_entry(region->page_block, struct page, lru);
+	del_from_freelist(page, free_list, order);
+
+	list_add_tail(&page->lru, list);
+
+	area = &(page_zone(page)->free_area[order]);
+	area->nr_free -= nr_pages + 1;
+
+	/* Fix up the zone region stats, since del_from_freelist() altered it */
+	region->zone_region->nr_free += 1 << order;
+}
+
 /**
  * Move a given page from one freelist to another.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
