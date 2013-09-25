Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBFC6B00A7
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:27:15 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so313517pbc.29
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:27:14 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:27:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C009E2BB0040
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:27:09 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNATmR63111326
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:10:29 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNR83Y003560
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:27:09 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 40/40] mm: Add triggers in the page-allocator to kick
 off region evacuation
Date: Thu, 26 Sep 2013 04:52:58 +0530
Message-ID: <20130925232256.26184.77601.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that we have the entire infrastructure to perform targeted region
evacuation from a dedicated kthread (kmempowerd), modify the page-allocator
to invoke the region-evacuator at opportune points.

At a basic level, the most obvious opportunity to try region-evacuation is
when a page is freed back to the page-allocator. The rationale behind this is
explained below.

The page-allocator already has the intelligence to allocate pages such that
they are consolidated within as few regions as possible. That is, due to the
sorted-buddy design, it will _not_ spill allocations to a new region as long
as there is still memory available in lower-numbered regions to satisfy the
allocation request.

So, the fragmentation happens _after_ they are allocated, i.e., once the
entity starts freeing the memory in a random fashion. This freeing of pages
presents an opportunity to the MM subsystem: if the pages freed belong to
lower-numbered regions, then there is a chance that pages from higher-numbered
regions could be moved to these freshly freed pages, thereby causing further
consolidation of regions.

With this in mind, add the region-evac trigger in the page-freeing path.
Along with that, also add appropriate checks and intelligence necessary to
avoid compaction attempts that don't provide any net benefit. For example,
we can avoid compacting regions in ZONE_DMA, or regions that have mostly only
MIGRATE_UNMOVABLE allocations etc. These checks are done best at the
page-allocator side. Apart from them, also perform the same eligibility checks
that the region-evacuator employs, to avoid useless wakeups of kmempowerd.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   38 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4571d30..48b748e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -639,6 +639,29 @@ out:
 static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 				    int region_id);
 
+static inline int region_is_evac_candidate(struct zone *z,
+					   struct zone_mem_region *region,
+					   int migratetype)
+{
+
+	/* Don't start evacuation too early during boot */
+	if (system_state != SYSTEM_RUNNING)
+		return 0;
+
+	/* Don't bother evacuating regions in ZONE_DMA */
+	if (zone_idx(z) == ZONE_DMA)
+		return 0;
+
+	/*
+	 * Don't try evacuations in regions not containing MOVABLE or
+	 * RECLAIMABLE allocations.
+	 */
+	if (!(migratetype == MIGRATE_MOVABLE ||
+		migratetype == MIGRATE_RECLAIMABLE))
+		return 0;
+
+	return should_evacuate_region(z, region);
+}
 
 static inline int can_return_region(struct mem_region_list *region, int order,
 				    struct free_list *free_list)
@@ -683,7 +706,9 @@ static void add_to_freelist(struct page *page, struct free_list *free_list,
 {
 	struct list_head *prev_region_list, *lru;
 	struct mem_region_list *region;
-	int region_id, prev_region_id;
+	int region_id, prev_region_id, migratetype;
+	struct zone *zone;
+	struct pglist_data *pgdat;
 
 	lru = &page->lru;
 	region_id = page_zone_region_id(page);
@@ -741,8 +766,17 @@ try_return_region:
 	 * Try to return the freepages of a memory region to the region
 	 * allocator, if possible.
 	 */
-	if (can_return_region(region, order, free_list))
+	if (can_return_region(region, order, free_list)) {
 		add_to_region_allocator(page_zone(page), free_list, region_id);
+		return;
+	}
+
+	zone = page_zone(page);
+	migratetype = get_pageblock_migratetype(page);
+	pgdat = NODE_DATA(page_to_nid(page));
+
+	if (region_is_evac_candidate(zone, region->zone_region, migratetype))
+		queue_mempower_work(pgdat, zone, region_id);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
