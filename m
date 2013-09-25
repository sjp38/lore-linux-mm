Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id AE3306B0080
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:23:43 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so309881pbc.8
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:23:43 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:53:39 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id BF88E394004D
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:21 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNPsrv22872274
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:54 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNNZt7009513
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:36 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 25/40] mm: Connect Page Allocator(PA) to Region
 Allocator(RA); add PA => RA flow
Date: Thu, 26 Sep 2013 04:49:30 +0530
Message-ID: <20130925231926.26184.4763.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that we have built up an infrastructure that forms a "Memory Region
Allocator", connect it with the page allocator. To entities requesting
memory, the page allocator will function as a front-end, whereas the
region allocator will act as a back-end to the page allocator.
(Analogy: page allocator is like free cash, whereas region allocator
is like a bank).

Implement the flow of freepages from the page allocator to the region
allocator. When the buddy freelists notice that they have all the freepages
forming a memory region, they give it back to the region allocator.

Simplification: We assume that the freepages of a memory region can be
completely represented by a set of MAX_ORDER-1 pages. That is, we only
need to consider the buddy freelists corresponding to MAX_ORDER-1, while
interacting with the region allocator. Furthermore, we assume that
pageblock_order == MAX_ORDER-1.

(These assumptions are used to ease the implementation, so that one can
quickly evaluate the benefits of the overall design without getting
bogged down by too many corner cases and constraints. Of course future
implementations will handle more scenarios and will have reduced dependence
on such simplifying assumptions.)

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 178f210..d08bc91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -635,6 +635,37 @@ out:
 	return prev_region_id;
 }
 
+
+static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
+				    int region_id);
+
+
+static inline int can_return_region(struct mem_region_list *region, int order)
+{
+	struct zone_mem_region *zone_region;
+
+	zone_region = region->zone_region;
+
+	if (likely(zone_region->nr_free != zone_region->present_pages))
+		return 0;
+
+	/*
+	 * Don't release freepages to the region allocator if some other
+	 * buddy pages can potentially merge with our freepages to form
+	 * higher order pages.
+	 *
+	 * Hack: Don't return the region unless all the freepages are of
+	 * order MAX_ORDER-1.
+	 */
+	if (likely(order != MAX_ORDER-1))
+		return 0;
+
+	if (region->nr_free * (1 << order) != zone_region->nr_free)
+		return 0;
+
+	return 1;
+}
+
 static void add_to_freelist(struct page *page, struct free_list *free_list,
 			    int order)
 {
@@ -651,7 +682,7 @@ static void add_to_freelist(struct page *page, struct free_list *free_list,
 
 	if (region->page_block) {
 		list_add_tail(lru, region->page_block);
-		return;
+		goto try_return_region;
 	}
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -691,6 +722,15 @@ out:
 	/* Save pointer to page block of this region */
 	region->page_block = lru;
 	set_region_bit(region_id, free_list);
+
+try_return_region:
+
+	/*
+	 * Try to return the freepages of a memory region to the region
+	 * allocator, if possible.
+	 */
+	if (can_return_region(region, order))
+		add_to_region_allocator(page_zone(page), free_list, region_id);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
