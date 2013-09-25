Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DB8DD6B008A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:24:52 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so324643pdj.18
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:24:52 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:24:39 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B15C63578050
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:24:38 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PN7n8240042668
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:07:49 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8PNOb1j018526
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:24:38 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 30/40] mm: Modify move_freepages() to handle pages in
 the region allocator properly
Date: Thu, 26 Sep 2013 04:50:27 +0530
Message-ID: <20130925232025.26184.6209.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are situations in which the memory management subsystem needs to move
pages from one migratetype to another, such as when setting up the per-zone
migrate reserves (where freepages are moved from MIGRATE_MOVABLE to
MIGRATE_RESERVE freelists).

But the existing code that does freepage movement is unaware of the region
allocator. In other words, it always assumes that the freepages that it is
moving are always in the buddy page allocator's freelists. But with the
introduction of the region allocator, the freepages could instead reside
in the region allocator as well. So teach move_freepages() to check whether
the pages are in the buddy page allocator's freelists or the region
allocator and handle the two cases appropriately.

The region allocator is designed in such a way that it always allocates
or receives entire memory regions as a single unit. To retain these
semantics during freepage movement, we first move all the pages of that
region from the region allocator to the MIGRATE_MOVABLE buddy freelist
and then move the requested page(s) from MIGRATE_MOVABLE to the required
migratetype.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ed5298c..939f378 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1558,7 +1558,7 @@ int move_freepages(struct zone *zone,
 	struct page *page;
 	unsigned long order;
 	struct free_area *area;
-	int pages_moved = 0, old_mt;
+	int pages_moved = 0, old_mt, region_id;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -1585,7 +1585,23 @@ int move_freepages(struct zone *zone,
 			continue;
 		}
 
+		/*
+		 * If the page is in the region allocator, we first move the
+		 * region to the MIGRATE_MOVABLE buddy freelists and then move
+		 * that page to the freelist of the requested migratetype.
+		 * This is because the region allocator operates on whole region-
+		 * sized chunks, whereas here we want to move pages in much
+		 * smaller chunks.
+		 */
 		order = page_order(page);
+		if (page_in_region_allocator(page)) {
+			region_id = page_zone_region_id(page);
+			__del_from_region_allocator(zone, order, MIGRATE_MOVABLE,
+						    region_id);
+
+			continue; /* Try this page again from the buddy-list */
+		}
+
 		old_mt = get_freepage_migratetype(page);
 		area = &zone->free_area[order];
 		move_page_freelist(page, &area->free_list[old_mt],

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
