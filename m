Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 131926B006C
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:22:22 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so318530pdj.25
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:22:21 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:52:17 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 80413394003F
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:51:58 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNMBrL44171292
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:11 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNMCrl014243
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:13 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 18/40] mm: Provide a mechanism to delete pages from
 buddy freelists in bulk
Date: Thu, 26 Sep 2013 04:48:06 +0530
Message-ID: <20130925231804.26184.66311.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index c3a2cda..d96746e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -854,6 +854,61 @@ page_found:
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
