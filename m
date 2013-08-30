Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 070AB6B0073
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:45 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 09:23:44 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 5B2D9C9003E
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:23:41 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDNfns28639278
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:23:41 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDNdJE006080
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 10:23:40 -0300
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 19/35] mm: Add a mechanism to add pages to buddy
 freelists in bulk
Date: Fri, 30 Aug 2013 18:49:45 +0530
Message-ID: <20130830131941.4947.33856.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When the buddy page allocator requests the region allocator for memory,
it gets all the freepages belonging to an entire region at once. So, in
order to make it efficient, we need a way to add all those pages to the
buddy freelists in one shot. Add this support, and also take care to
update the nr-free statistics properly.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905360c..b66ddff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -692,6 +692,52 @@ out:
 	set_region_bit(region_id, free_list);
 }
 
+/*
+ * Add all the freepages contained in 'list' to the buddy freelist
+ * 'free_list'. Using suitable list-manipulation tricks, we move the
+ * pages between the lists in one shot.
+ */
+static void add_to_freelist_bulk(struct list_head *list,
+				 struct free_list *free_list, int order,
+				 int region_id)
+{
+	struct list_head *cur, *position;
+	struct mem_region_list *region;
+	unsigned long nr_pages = 0;
+	struct free_area *area;
+	struct page *page;
+
+	if (list_empty(list))
+		return;
+
+	page = list_first_entry(list, struct page, lru);
+	list_del(&page->lru);
+
+	/*
+	 * Add one page using add_to_freelist() so that it sets up the
+	 * region related data-structures of the freelist properly.
+	 */
+	add_to_freelist(page, free_list, order);
+
+	/* Now add the rest of the pages in bulk */
+	list_for_each(cur, list)
+		nr_pages++;
+
+	position = free_list->mr_list[region_id].page_block;
+	list_splice_tail(list, position);
+
+
+	/* Update the statistics */
+	region = &free_list->mr_list[region_id];
+	region->nr_free += nr_pages;
+
+	area = &(page_zone(page)->free_area[order]);
+	area->nr_free += nr_pages + 1;
+
+	/* Fix up the zone region stats, since add_to_freelist() altered it */
+	region->zone_region->nr_free -= 1 << order;
+}
+
 /**
  * __rmqueue_smallest() *always* deletes elements from the head of the
  * list. Use this knowledge to keep page allocation fast, despite being

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
