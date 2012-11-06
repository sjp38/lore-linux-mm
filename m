Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 5832A6B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:53:59 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:23:56 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JrqcA45547738
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:23:52 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71Nht5008579
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:23:44 GMT
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/8] mm: Initialize node memory regions during boot
Date: Wed, 07 Nov 2012 01:22:48 +0530
Message-ID: <20121106195241.6941.43309.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Initialize the node's memory regions structures with the information about
the region-boundaries, at boot time.

Based-on-patch-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h |    4 ++++
 mm/page_alloc.c    |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa06804..19c4fb0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -657,6 +657,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
+/* Hard-code memory regions size to be 512 MB for now. */
+#define MEM_REGION_SHIFT	(29 - PAGE_SHIFT)
+#define MEM_REGION_SIZE		(1UL << MEM_REGION_SHIFT)
+
 static inline enum zone_type page_zonenum(const struct page *page)
 {
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..709e3c1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4560,6 +4560,40 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
 
+void init_node_memory_regions(struct pglist_data *pgdat)
+{
+	int nid = pgdat->node_id;
+	unsigned long start_pfn = pgdat->node_start_pfn;
+	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
+	unsigned long i, absent;
+	int idx;
+	struct node_mem_region *region;
+
+	for (i = start_pfn, idx = 0; i < end_pfn;
+				i += region->spanned_pages, idx++) {
+
+		region = &pgdat->node_regions[idx];
+
+		if (i + MEM_REGION_SIZE <= end_pfn) {
+			region->start_pfn = i;
+			region->spanned_pages = MEM_REGION_SIZE;
+		} else {
+			region->start_pfn = i;
+			region->spanned_pages = end_pfn - i;
+		}
+
+		absent = __absent_pages_in_range(nid, region->start_pfn,
+						 region->start_pfn +
+						 region->spanned_pages);
+
+		region->present_pages = region->spanned_pages - absent;
+		region->idx = idx;
+		region->node = nid;
+		region->pgdat = pgdat;
+		pgdat->nr_node_regions++;
+	}
+}
+
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
@@ -4581,6 +4615,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #endif
 
 	free_area_init_core(pgdat, zones_size, zholes_size);
+	init_node_memory_regions(pgdat);
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
