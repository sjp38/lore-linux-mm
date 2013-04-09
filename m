Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 545526B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:49:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 07:41:51 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1D302357804E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:49:16 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LmeT012583294
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:48:40 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LmiMq009463
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:48:45 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 02/15] mm: Initialize node memory regions during boot
Date: Wed, 10 Apr 2013 03:16:06 +0530
Message-ID: <20130409214600.4500.41056.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Initialize the node's memory-regions structures with the information about
the region-boundaries, at boot time.

Based-on-patch-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h |    4 ++++
 mm/page_alloc.c    |   28 ++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e19ff30..b7b368a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -621,6 +621,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define LAST_NID_MASK		((1UL << LAST_NID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
+/* Hard-code memory region size to be 512 MB for now. */
+#define MEM_REGION_SHIFT	(29 - PAGE_SHIFT)
+#define MEM_REGION_SIZE		(1UL << MEM_REGION_SHIFT)
+
 static inline enum zone_type page_zonenum(const struct page *page)
 {
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..9760e89 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4681,6 +4681,33 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
 
+static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
+{
+	int nid = pgdat->node_id;
+	unsigned long start_pfn = pgdat->node_start_pfn;
+	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
+	struct node_mem_region *region;
+	unsigned long i, absent;
+	int idx;
+
+	for (i = start_pfn, idx = 0; i < end_pfn;
+				i += region->spanned_pages, idx++) {
+
+		region = &pgdat->node_regions[idx];
+		region->pgdat = pgdat;
+		region->start_pfn = i;
+		region->spanned_pages = min(MEM_REGION_SIZE, end_pfn - i);
+		region->end_pfn = region->start_pfn + region->spanned_pages;
+
+		absent = __absent_pages_in_range(nid, region->start_pfn,
+						 region->end_pfn);
+
+		region->present_pages = region->spanned_pages - absent;
+	}
+
+	pgdat->nr_node_regions = idx;
+}
+
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
 {
@@ -4702,6 +4729,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
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
