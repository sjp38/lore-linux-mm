Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2E36B026D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:19:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t3-v6so9816964pgp.0
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:19:43 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j24si3652217pgh.362.2018.11.05.13.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:19:42 -0800 (PST)
Subject: [mm PATCH v5 3/7] mm: Implement new zone specific memblock iterator
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 05 Nov 2018 13:19:40 -0800
Message-ID: <154145278071.30046.9022571960145979137.stgit@ahduyck-desk1.jf.intel.com>
In-Reply-To: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.

This iterator will take care of making sure a given memory range provided
is in fact contained within a zone. It takes are of all the bounds checking
we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
it should help to speed up the search a bit by iterating until the end of a
range is greater than the start of the zone pfn range, and will exit
completely if the start is beyond the end of the zone.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/memblock.h |   22 ++++++++++++++++
 mm/memblock.c            |   63 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c          |   31 +++++++++--------------
 3 files changed, 97 insertions(+), 19 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index aee299a6aa76..413623dc96a3 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -248,6 +248,28 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
+				  unsigned long *out_spfn,
+				  unsigned long *out_epfn);
+/**
+ * for_each_free_mem_range_in_zone - iterate through zone specific free
+ * memblock areas
+ * @i: u64 used as loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over free (memory && !reserved) areas of memblock in a specific
+ * zone. Available as soon as memblock is initialized.
+ */
+#define for_each_free_mem_pfn_range_in_zone(i, zone, p_start, p_end)	\
+	for (i = 0,							\
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
diff --git a/mm/memblock.c b/mm/memblock.c
index 7df468c8ebc8..f1d1fbfd1ae7 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1239,6 +1239,69 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 	return 0;
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+/**
+ * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
+ *
+ * @idx: pointer to u64 loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @out_start: ptr to ulong for start pfn of the range, can be %NULL
+ * @out_end: ptr to ulong for end pfn of the range, can be %NULL
+ *
+ * This function is meant to be a zone/pfn specific wrapper for the
+ * for_each_mem_range type iterators. Specifically they are used in the
+ * deferred memory init routines and as such we were duplicating much of
+ * this logic throughout the code. So instead of having it in multiple
+ * locations it seemed like it would make more sense to centralize this to
+ * one new iterator that does everything they need.
+ */
+void __init_memblock
+__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
+			     unsigned long *out_spfn, unsigned long *out_epfn)
+{
+	int zone_nid = zone_to_nid(zone);
+	phys_addr_t spa, epa;
+	int nid;
+
+	__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
+			 &memblock.memory, &memblock.reserved,
+			 &spa, &epa, &nid);
+
+	while (*idx != ULLONG_MAX) {
+		unsigned long epfn = PFN_DOWN(epa);
+		unsigned long spfn = PFN_UP(spa);
+
+		/*
+		 * Verify the end is at least past the start of the zone and
+		 * that we have at least one PFN to initialize.
+		 */
+		if (zone->zone_start_pfn < epfn && spfn < epfn) {
+			/* if we went too far just stop searching */
+			if (zone_end_pfn(zone) <= spfn)
+				break;
+
+			if (out_spfn)
+				*out_spfn = max(zone->zone_start_pfn, spfn);
+			if (out_epfn)
+				*out_epfn = min(zone_end_pfn(zone), epfn);
+
+			return;
+		}
+
+		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
+				 &memblock.memory, &memblock.reserved,
+				 &spa, &epa, &nid);
+	}
+
+	/* signal end of iteration */
+	*idx = ULLONG_MAX;
+	if (out_spfn)
+		*out_spfn = ULONG_MAX;
+	if (out_epfn)
+		*out_epfn = 0;
+}
+
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index be1197c120a8..5cfd3ebe10d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1516,11 +1516,9 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
 static int __init deferred_init_memmap(void *data)
 {
 	pg_data_t *pgdat = data;
-	int nid = pgdat->node_id;
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
 	unsigned long spfn, epfn, first_init_pfn, flags;
-	phys_addr_t spa, epa;
 	int zid;
 	struct zone *zone;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
@@ -1557,14 +1555,12 @@ static int __init deferred_init_memmap(void *data)
 	 * freeing pages we can access pages that are ahead (computing buddy
 	 * page in __free_one_page()).
 	 */
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 		nr_pages += deferred_init_pages(zone, spfn, epfn);
 	}
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 		deferred_free_pages(spfn, epfn);
 	}
 	pgdat_resize_unlock(pgdat, &flags);
@@ -1572,8 +1568,8 @@ static int __init deferred_init_memmap(void *data)
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
-	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
-					jiffies_to_msecs(jiffies - start));
+	pr_info("node %d initialised, %lu pages in %ums\n",
+		pgdat->node_id,	nr_pages, jiffies_to_msecs(jiffies - start));
 
 	pgdat_init_report_one_done();
 	return 0;
@@ -1604,13 +1600,11 @@ static DEFINE_STATIC_KEY_TRUE(deferred_pages);
 static noinline bool __init
 deferred_grow_zone(struct zone *zone, unsigned int order)
 {
-	int nid = zone_to_nid(zone);
-	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
+	pg_data_t *pgdat = zone->zone_pgdat;
 	unsigned long nr_pages = 0;
 	unsigned long first_init_pfn, spfn, epfn, t, flags;
 	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
-	phys_addr_t spa, epa;
 	u64 i;
 
 	/* Only the last zone may have deferred pages */
@@ -1646,9 +1640,8 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 		return false;
 	}
 
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 
 		while (spfn < epfn && nr_pages < nr_pages_needed) {
 			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
@@ -1662,9 +1655,9 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 			break;
 	}
 
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
+		epfn = min_t(unsigned long, first_deferred_pfn, epfn);
 		deferred_free_pages(spfn, epfn);
 
 		if (first_deferred_pfn == epfn)
