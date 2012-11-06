Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3D9056B005D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:54:28 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:24:25 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JsMUX4194780
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:24:22 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71OE1s010922
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:24:14 GMT
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/8] mm: Add helpers to retrieve node region and zone
 region for a given page
Date: Wed, 07 Nov 2012 01:23:19 +0530
Message-ID: <20121106195310.6941.91123.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Given a page, we would like to have an efficient mechanism to find out
the node memory region and the zone memory region to which it belongs.

Since the node is assumed to be divided into equal-sized node memory
regions, the node memory region index can be obtained by simply right-shifting
the page's pfn by 'mem_region_shift'.

But finding the corresponding zone memory region's index in the zone is
not that straight-forward. To have a O(1) algorithm to find it out, define a
zone_region_idx[] array to store the zone memory region indices for every
node memory region.

To illustrate, consider the following example:

	|<---------------------Node---------------------->|
	 _________________________________________________
	|      Node mem reg 0 	|      Node mem reg 1     |
	|_______________________|_________________________|

	 _________________________________________________
	|   ZONE_DMA    |	ZONE_NORMAL		  |
	|_______________|_________________________________|


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

 include/linux/mm.h     |   23 +++++++++++++++++++++++
 include/linux/mmzone.h |    7 +++++++
 mm/page_alloc.c        |    2 ++
 3 files changed, 32 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 19c4fb0..a817b16 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -702,6 +702,29 @@ static inline struct zone *page_zone(const struct page *page)
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
 }
 
+static inline int page_node_region_id(const struct page *page)
+{
+	return page_to_pfn(page) >> MEM_REGION_SHIFT;
+}
+
+/**
+ * Return the index of the region to which the page belongs, within its zone.
+ *
+ * Given a page, find the absolute (node) region as well as the zone to which
+ * it belongs. Then find the region within the zone that corresponds to that
+ * absolute (node) region, and return its index.
+ */
+static inline int page_zone_region_id(const struct page *page)
+{
+	pg_data_t *pgdat = NODE_DATA(page_to_nid(page));
+	enum zone_type z_num = page_zonenum(page);
+	unsigned long node_region_idx;
+
+	node_region_idx = page_node_region_id(page);
+
+	return pgdat->node_regions[node_region_idx].zone_region_idx[z_num];
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9f923aa..3982354 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -336,6 +336,13 @@ struct node_mem_region {
 	unsigned long spanned_pages;
 	int idx;
 	int node;
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
index c00f72d..7fd89cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4621,6 +4621,8 @@ void init_zone_memory_regions(struct pglist_data *pgdat)
 						         end_pfn);
 			z->zone_mem_region[idx].present_pages =
 						end_pfn - start_pfn - absent;
+
+			region->zone_region_idx[zone_idx(z)] = idx;
 			idx++;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
