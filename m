Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 10C2D6B0075
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:28:07 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:28:06 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 807123E40062
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:03 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDS3sT135158
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDS1ac029798
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:02 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 32/35] mm: Modify move_freepages() to handle pages in
 the region allocator properly
Date: Fri, 30 Aug 2013 18:54:06 +0530
Message-ID: <20130830132404.4947.36588.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index fc530ff..3ce0c61 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1557,7 +1557,7 @@ int move_freepages(struct zone *zone,
 	struct page *page;
 	unsigned long order;
 	struct free_area *area;
-	int pages_moved = 0, old_mt;
+	int pages_moved = 0, old_mt, region_id;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -1584,7 +1584,23 @@ int move_freepages(struct zone *zone,
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
