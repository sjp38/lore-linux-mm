Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7FA6B0266
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n126so740434wma.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:34 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id c7si982576edl.136.2017.12.05.11.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:33 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 7/7] mm: parallelize deferred struct page initialization within each node
Date: Tue,  5 Dec 2017 14:52:20 -0500
Message-Id: <20171205195220.28208-8-daniel.m.jordan@oracle.com>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Deferred struct page initialization currently uses one thread per node
(pgdatinit threads), but this is a bottleneck during boot on big
machines, so use ktask within each pgdatinit thread to parallelize the
struct page initialization on each node, allowing the system to take
better advantage of its memory bandwidth.

Because the system is not fully up yet and most CPUs are idle, use more
than the default maximum number of ktask threads.

Machine: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz, 88 CPUs, 503G memory,
         2 sockets
Test:    Boot the machine with deferred struct page init three times

kernel                   speedup   max time per   stdev
                                   node (ms)

baseline (4.15-rc2)                        5860     8.6
ktask                      9.56x            613    12.4

---

Machine: Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 CPUs, 1T memory
         8 sockets
Test:    Boot the machine with deferred struct page init three times

kernel                   speedup   max time per   stdev
                                   node (ms)
baseline (4.15-rc2)                        1261     1.9
ktask                      3.88x            325     5.0

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steve Sistare <steven.sistare@oracle.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 mm/page_alloc.c | 78 ++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 63 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1f4af28df5b5..68d1261ce99d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -67,6 +67,7 @@
 #include <linux/ftrace.h>
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
+#include <linux/ktask.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1280,8 +1281,6 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 	}
 	__ClearPageReserved(p);
 	set_page_count(p, 0);
-
-	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
 }
@@ -1345,7 +1344,8 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 {
 	if (early_page_uninitialised(pfn))
 		return;
-	return __free_pages_boot_core(page, order);
+	__free_pages_boot_core(page, order);
+	page_zone(page)->managed_pages += (1ul << order);
 }
 
 /*
@@ -1483,23 +1483,32 @@ deferred_pfn_valid(int nid, unsigned long pfn,
 	return true;
 }
 
+struct deferred_args {
+	int nid;
+	int zid;
+	atomic64_t nr_pages;
+};
+
 /*
  * Free pages to buddy allocator. Try to free aligned pages in
  * pageblock_nr_pages sizes.
  */
-static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
-				       unsigned long end_pfn)
+static int __init deferred_free_chunk(unsigned long pfn, unsigned long end_pfn,
+				      struct deferred_args *args)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
-	unsigned long nr_free = 0;
+	unsigned long nr_free = 0, nr_pages = 0;
+	int nid = args->nid;
 
 	for (; pfn < end_pfn; pfn++) {
 		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
 			deferred_free_range(pfn - nr_free, nr_free);
+			nr_pages += nr_free;
 			nr_free = 0;
 		} else if (!(pfn & nr_pgmask)) {
 			deferred_free_range(pfn - nr_free, nr_free);
+			nr_pages += nr_free;
 			nr_free = 1;
 			cond_resched();
 		} else {
@@ -1508,21 +1517,26 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
 	}
 	/* Free the last block of pages to allocator */
 	deferred_free_range(pfn - nr_free, nr_free);
+	nr_pages += nr_free;
+
+	atomic64_add(nr_pages, &args->nr_pages);
+	return KTASK_RETURN_SUCCESS;
 }
 
 /*
  * Initialize struct pages.  We minimize pfn page lookups and scheduler checks
  * by performing it only once every pageblock_nr_pages.
- * Return number of pages initialized.
+ * Return number of pages initialized in deferred_args.
  */
-static unsigned long  __init deferred_init_pages(int nid, int zid,
-						 unsigned long pfn,
-						 unsigned long end_pfn)
+static int __init deferred_init_chunk(unsigned long pfn, unsigned long end_pfn,
+				      struct deferred_args *args)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	unsigned long nr_pages = 0;
 	struct page *page = NULL;
+	int nid = args->nid;
+	int zid = args->zid;
 
 	for (; pfn < end_pfn; pfn++) {
 		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
@@ -1537,7 +1551,8 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
-	return (nr_pages);
+	atomic64_add(nr_pages, &args->nr_pages);
+	return KTASK_RETURN_SUCCESS;
 }
 
 /* Initialise remaining memory on a node */
@@ -1546,7 +1561,7 @@ static int __init deferred_init_memmap(void *data)
 	pg_data_t *pgdat = data;
 	int nid = pgdat->node_id;
 	unsigned long start = jiffies;
-	unsigned long nr_pages = 0;
+	unsigned long nr_init = 0, nr_free = 0;
 	unsigned long spfn, epfn;
 	phys_addr_t spa, epa;
 	int zid;
@@ -1554,6 +1569,8 @@ static int __init deferred_init_memmap(void *data)
 	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 	u64 i;
+	unsigned long nr_node_cpus = cpumask_weight(cpumask) * 4;
+	struct ktask_node kn;
 
 	if (first_init_pfn == ULONG_MAX) {
 		pgdat_init_report_one_done();
@@ -1564,6 +1581,12 @@ static int __init deferred_init_memmap(void *data)
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(current, cpumask);
 
+	/*
+	 * We'd like to know the memory bandwidth of the chip to calculate the
+	 * right number of CPUs, but we can't so make a guess.
+	 */
+	nr_node_cpus = DIV_ROUND_UP(cpumask_weight(cpumask), 4);
+
 	/* Sanity check boundaries */
 	BUG_ON(pgdat->first_deferred_pfn < pgdat->node_start_pfn);
 	BUG_ON(pgdat->first_deferred_pfn > pgdat_end_pfn(pgdat));
@@ -1584,20 +1607,45 @@ static int __init deferred_init_memmap(void *data)
 	 * page in __free_one_page()).
 	 */
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		struct deferred_args args = { nid, zid, ATOMIC64_INIT(0) };
+		DEFINE_KTASK_CTL(ctl, deferred_init_chunk, &args,
+				 KTASK_BPGS_MINCHUNK);
+		ktask_ctl_set_max_threads(&ctl, nr_node_cpus);
+
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		nr_pages += deferred_init_pages(nid, zid, spfn, epfn);
+
+		kn.kn_start	= (void *)spfn;
+		kn.kn_task_size	= (spfn < epfn) ? epfn - spfn : 0;
+		kn.kn_nid	= nid;
+		(void) ktask_run_numa(&kn, 1, &ctl);
+
+		nr_init += atomic64_read(&args.nr_pages);
 	}
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		struct deferred_args args = { nid, zid, ATOMIC64_INIT(0) };
+		DEFINE_KTASK_CTL(ctl, deferred_free_chunk, &args,
+				 KTASK_BPGS_MINCHUNK);
+		ktask_ctl_set_max_threads(&ctl, nr_node_cpus);
+
 		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
 		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
-		deferred_free_pages(nid, zid, spfn, epfn);
+
+		kn.kn_start	= (void *)spfn;
+		kn.kn_task_size	= (spfn < epfn) ? epfn - spfn : 0;
+		kn.kn_nid	= nid;
+		(void) ktask_run_numa(&kn, 1, &ctl);
+
+		nr_free += atomic64_read(&args.nr_pages);
 	}
 
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
+	VM_BUG_ON(nr_init != nr_free);
+
+	zone->managed_pages += nr_free;
 
-	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
+	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_free,
 					jiffies_to_msecs(jiffies - start));
 
 	pgdat_init_report_one_done();
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
