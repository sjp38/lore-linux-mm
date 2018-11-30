Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCEB16B5A73
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 16:53:10 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so4225660pgb.10
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 13:53:10 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j20si5354964pgh.224.2018.11.30.13.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 13:53:09 -0800 (PST)
Subject: [mm PATCH v6 4/7] mm: Initialize MAX_ORDER_NR_PAGES at a time
 instead of doing larger sections
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 30 Nov 2018 13:53:08 -0800
Message-ID: <154361478854.7497.15456929701404283744.stgit@ahduyck-desk1.amr.corp.intel.com>
In-Reply-To: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, alexander.h.duyck@linux.intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.comalexander.h.duyck@linux.intel.com

Add yet another iterator, for_each_free_mem_range_in_zone_from, and then
use it to support initializing and freeing pages in groups no larger than
MAX_ORDER_NR_PAGES. By doing this we can greatly improve the cache locality
of the pages while we do several loops over them in the init and freeing
process.

We are able to tighten the loops further as a result of the "from" iterator
as we can perform the initial checks for first_init_pfn in our first call
to the iterator, and continue without the need for those checks via the
"from" iterator. I have added this functionality in the function called
deferred_init_mem_pfn_range_in_zone that primes the iterator and causes us
to exit if we encounter any failure.

On my x86_64 test system with 384GB of memory per node I saw a reduction in
initialization time from 1.85s to 1.38s as a result of this patch.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/memblock.h |   16 +++++
 mm/page_alloc.c          |  160 +++++++++++++++++++++++++++++++++-------------
 2 files changed, 132 insertions(+), 44 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 95d1aaa3f412..60e100fe5922 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -270,6 +270,22 @@ void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
 	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
 	     i != U64_MAX;					\
 	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
+
+/**
+ * for_each_free_mem_range_in_zone_from - iterate through zone specific
+ * free memblock areas from a given point
+ * @i: u64 used as loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over free (memory && !reserved) areas of memblock in a specific
+ * zone, continuing from current position. Available as soon as memblock is
+ * initialized.
+ */
+#define for_each_free_mem_pfn_range_in_zone_from(i, zone, p_start, p_end) \
+	for (; i != U64_MAX;					  \
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72f9889e3866..fbd9bd2bc262 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1519,16 +1519,102 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
 	return (nr_pages);
 }
 
+/*
+ * This function is meant to pre-load the iterator for the zone init.
+ * Specifically it walks through the ranges until we are caught up to the
+ * first_init_pfn value and exits there. If we never encounter the value we
+ * return false indicating there are no valid ranges left.
+ */
+static bool __init
+deferred_init_mem_pfn_range_in_zone(u64 *i, struct zone *zone,
+				    unsigned long *spfn, unsigned long *epfn,
+				    unsigned long first_init_pfn)
+{
+	u64 j;
+
+	/*
+	 * Start out by walking through the ranges in this zone that have
+	 * already been initialized. We don't need to do anything with them
+	 * so we just need to flush them out of the system.
+	 */
+	for_each_free_mem_pfn_range_in_zone(j, zone, spfn, epfn) {
+		if (*epfn <= first_init_pfn)
+			continue;
+		if (*spfn < first_init_pfn)
+			*spfn = first_init_pfn;
+		*i = j;
+		return true;
+	}
+
+	return false;
+}
+
+/*
+ * Initialize and free pages. We do it in two loops: first we initialize
+ * struct page, than free to buddy allocator, because while we are
+ * freeing pages we can access pages that are ahead (computing buddy
+ * page in __free_one_page()).
+ *
+ * In order to try and keep some memory in the cache we have the loop
+ * broken along max page order boundaries. This way we will not cause
+ * any issues with the buddy page computation.
+ */
+static unsigned long __init
+deferred_init_maxorder(u64 *i, struct zone *zone, unsigned long *start_pfn,
+		       unsigned long *end_pfn)
+{
+	unsigned long mo_pfn = ALIGN(*start_pfn + 1, MAX_ORDER_NR_PAGES);
+	unsigned long spfn = *start_pfn, epfn = *end_pfn;
+	unsigned long nr_pages = 0;
+	u64 j = *i;
+
+	/* First we loop through and initialize the page values */
+	for_each_free_mem_pfn_range_in_zone_from(j, zone, &spfn, &epfn) {
+		unsigned long t;
+
+		if (mo_pfn <= spfn)
+			break;
+
+		t = min(mo_pfn, epfn);
+		nr_pages += deferred_init_pages(zone, spfn, t);
+
+		if (mo_pfn <= epfn)
+			break;
+	}
+
+	/* Reset values and now loop through freeing pages as needed */
+	j = *i;
+
+	for_each_free_mem_pfn_range_in_zone_from(j, zone, start_pfn, end_pfn) {
+		unsigned long t;
+
+		if (mo_pfn <= *start_pfn)
+			break;
+
+		t = min(mo_pfn, *end_pfn);
+		deferred_free_pages(*start_pfn, t);
+		*start_pfn = t;
+
+		if (mo_pfn < *end_pfn)
+			break;
+	}
+
+	/* Store our current values to be reused on the next iteration */
+	*i = j;
+
+	return nr_pages;
+}
+
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
 {
 	pg_data_t *pgdat = data;
+	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	unsigned long spfn = 0, epfn = 0, nr_pages = 0;
+	unsigned long first_init_pfn, flags;
 	unsigned long start = jiffies;
-	unsigned long nr_pages = 0;
-	unsigned long spfn, epfn, first_init_pfn, flags;
-	int zid;
 	struct zone *zone;
-	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	int zid;
 	u64 i;
 
 	/* Bind memory initialisation thread to a local node if possible */
@@ -1554,22 +1640,20 @@ static int __init deferred_init_memmap(void *data)
 		if (first_init_pfn < zone_end_pfn(zone))
 			break;
 	}
-	first_init_pfn = max(zone->zone_start_pfn, first_init_pfn);
+
+	/* If the zone is empty somebody else may have cleared out the zone */
+	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
+						 first_init_pfn))
+		goto zone_empty;
 
 	/*
-	 * Initialize and free pages. We do it in two loops: first we initialize
-	 * struct page, than free to buddy allocator, because while we are
-	 * freeing pages we can access pages that are ahead (computing buddy
-	 * page in __free_one_page()).
+	 * Initialize and free pages in MAX_ORDER sized increments so
+	 * that we can avoid introducing any issues with the buddy
+	 * allocator.
 	 */
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		nr_pages += deferred_init_pages(zone, spfn, epfn);
-	}
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		deferred_free_pages(spfn, epfn);
-	}
+	while (spfn < epfn)
+		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
+zone_empty:
 	pgdat_resize_unlock(pgdat, &flags);
 
 	/* Sanity check that the next zone really is unpopulated */
@@ -1609,9 +1693,9 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 {
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
 	pg_data_t *pgdat = zone->zone_pgdat;
-	unsigned long nr_pages = 0;
-	unsigned long first_init_pfn, spfn, epfn, t, flags;
 	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
+	unsigned long spfn, epfn, flags;
+	unsigned long nr_pages = 0;
 	u64 i;
 
 	/* Only the last zone may have deferred pages */
@@ -1640,36 +1724,24 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
 		return true;
 	}
 
-	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
-
-	if (first_init_pfn >= pgdat_end_pfn(pgdat)) {
+	/* If the zone is empty somebody else may have cleared out the zone */
+	if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
+						 first_deferred_pfn)) {
+		pgdat->first_deferred_pfn = ULONG_MAX;
 		pgdat_resize_unlock(pgdat, &flags);
-		return false;
+		return true;
 	}
 
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-
-		while (spfn < epfn && nr_pages < nr_pages_needed) {
-			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
-			first_deferred_pfn = min(t, epfn);
-			nr_pages += deferred_init_pages(zone, spfn,
-							first_deferred_pfn);
-			spfn = first_deferred_pfn;
-		}
-
-		if (nr_pages >= nr_pages_needed)
-			break;
+	/*
+	 * Initialize and free pages in MAX_ORDER sized increments so
+	 * that we can avoid introducing any issues with the buddy
+	 * allocator.
+	 */
+	while (spfn < epfn && nr_pages < nr_pages_needed) {
+		nr_pages += deferred_init_maxorder(&i, zone, &spfn, &epfn);
+		first_deferred_pfn = spfn;
 	}
 
-	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
-		spfn = max_t(unsigned long, first_init_pfn, spfn);
-		epfn = min_t(unsigned long, first_deferred_pfn, epfn);
-		deferred_free_pages(spfn, epfn);
-
-		if (first_deferred_pfn == epfn)
-			break;
-	}
 	pgdat->first_deferred_pfn = first_deferred_pfn;
 	pgdat_resize_unlock(pgdat, &flags);
 
