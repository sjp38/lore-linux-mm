Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 174386B0039
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:18:44 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so474124pad.28
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:18:43 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:48:38 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id D0BF8394003F
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:48:19 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNKpWX46530790
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:50:51 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNIXOm016718
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:48:34 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 04/40] mm: Add helpers to retrieve node region and zone
 region for a given page
Date: Thu, 26 Sep 2013 04:44:28 +0530
Message-ID: <20130925231425.26184.22325.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given a page, we would like to have an efficient mechanism to find out
the node memory region and the zone memory region to which it belongs.

Since the node is assumed to be divided into equal-sized node memory
regions, the node memory region can be obtained by simply right-shifting
the page's pfn by 'MEM_REGION_SHIFT'.

But finding the corresponding zone memory region's index in the zone is
not that straight-forward. To have a O(1) algorithm to find it out, define a
zone_region_idx[] array to store the zone memory region indices for every
node memory region.

To illustrate, consider the following example:

	|<----------------------Node---------------------->|
	 __________________________________________________
	|      Node mem reg 0 	 |      Node mem reg 1     |  (Absolute region
	|________________________|_________________________|   boundaries)

	 __________________________________________________
	|    ZONE_DMA   |	    ZONE_NORMAL		   |
	|               |                                  |
	|<--- ZMR 0 --->|<-ZMR0->|<-------- ZMR 1 -------->|
	|_______________|________|_________________________|


In the above figure,

Node mem region 0:
------------------
This region corresponds to the first zone mem region in ZONE_DMA and also
the first zone mem region in ZONE_NORMAL. Hence its index array would look
like this:
    node_regions[0].zone_region_idx[ZONE_DMA]     == 0
    node_regions[0].zone_region_idx[ZONE_NORMAL]  == 0


Node mem region 1:
------------------
This region corresponds to the second zone mem region in ZONE_NORMAL. Hence
its index array would look like this:
    node_regions[1].zone_region_idx[ZONE_NORMAL]  == 1


Using this index array, we can quickly obtain the zone memory region to
which a given page belongs.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |   24 ++++++++++++++++++++++++
 include/linux/mmzone.h |    7 +++++++
 mm/page_alloc.c        |   22 ++++++++++++++++++++++
 3 files changed, 53 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 223be46..307f375 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -716,6 +716,30 @@ static inline struct zone *page_zone(const struct page *page)
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
 }
 
+static inline int page_node_region_id(const struct page *page,
+				      const pg_data_t *pgdat)
+{
+	return (page_to_pfn(page) - pgdat->node_start_pfn) >> MEM_REGION_SHIFT;
+}
+
+/**
+ * Return the index of the zone memory region to which the page belongs.
+ *
+ * Given a page, find the absolute (node) memory region as well as the zone to
+ * which it belongs. Then find the region within the zone that corresponds to
+ * that node memory region, and return its index.
+ */
+static inline int page_zone_region_id(const struct page *page)
+{
+	pg_data_t *pgdat = NODE_DATA(page_to_nid(page));
+	enum zone_type z_num = page_zonenum(page);
+	unsigned long node_region_idx;
+
+	node_region_idx = page_node_region_id(page, pgdat);
+
+	return pgdat->node_regions[node_region_idx].zone_region_idx[z_num];
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3c1dc97..a22358c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -726,6 +726,13 @@ struct node_mem_region {
 	unsigned long end_pfn;
 	unsigned long present_pages;
 	unsigned long spanned_pages;
+
+	/*
+	 * A physical (node) region could be split across multiple zones.
+	 * Store the indices of the corresponding regions of each such
+	 * zone for this physical (node) region.
+	 */
+	int zone_region_idx[MAX_NR_ZONES];
 	struct pglist_data *pgdat;
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 10a1cc8..d747f92 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4885,6 +4885,24 @@ static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
 	pgdat->nr_node_regions = idx;
 }
 
+/*
+ * Zone-region indices are used to map node-memory-regions to
+ * zone-memory-regions. Initialize all of them to an invalid value (-1),
+ * to make way for the correct mapping to be set up subsequently.
+ */
+static void __meminit init_zone_region_indices(struct pglist_data *pgdat)
+{
+	struct node_mem_region *node_region;
+	int i, j;
+
+	for (i = 0; i < pgdat->nr_node_regions; i++) {
+		node_region = &pgdat->node_regions[i];
+
+		for (j = 0; j < pgdat->nr_zones; j++)
+			node_region->zone_region_idx[j] = -1;
+	}
+}
+
 static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 {
 	unsigned long start_pfn, end_pfn, absent;
@@ -4894,6 +4912,9 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 	struct zone_mem_region *zone_region;
 	struct zone *z;
 
+	/* Set all the zone-region indices to -1 */
+	init_zone_region_indices(pgdat);
+
 	for (i = 0, j = 0; i < pgdat->nr_zones; i++) {
 		z = &pgdat->node_zones[i];
 		z_start_pfn = z->zone_start_pfn;
@@ -4926,6 +4947,7 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 			zone_region->present_pages =
 					zone_region->spanned_pages - absent;
 
+			node_region->zone_region_idx[zone_idx(z)] = idx;
 			idx++;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
