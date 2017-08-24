Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39A97440882
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k126so3075958qkb.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o14si4557046qta.501.2017.08.24.13.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:50 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 7/7] mm: parallelize deferred struct page initialization within each node
Date: Thu, 24 Aug 2017 16:50:04 -0400
Message-Id: <20170824205004.18502-8-daniel.m.jordan@oracle.com>
In-Reply-To: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Deferred struct page initialization currently uses one thread per node
(pgdatinit threads), but this can still be a bottleneck during boot on
big machines.  To reduce boot time, use ktask within each pgdatinit
thread to parallelize the struct page initialization on each node,
allowing the system to use more memory bandwidth.

The number of cpus used depends on a few factors, including the size of
the memory on that node (see the Documentation commit earlier in the
series for more information), but in this special case, since cpus are
not being used for much else at this phase of boot, we raise ktask's cap
on the maximum number of cpus to the number of cpus on the node.  Up to
this many cpus participate in initializing struct pages per node.

Machine: Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 cpus, 1T memory
Test:    Boot the machine with deferred struct page initialization

kernel                   speedup   min time per   stdev
                                   node (ms)

baseline (4.13-rc5)                         483     0.5
ktask (4.13-rc5 based)     3.66x            132     1.5

Machine: SPARC M6 30-node LDom, 256 cpus, 30T memory
Test:    Boot the machine with deferred struct page initialization

kernel                   speedup   min time per   stdev
                                   node (ms)

baseline (4.13-rc5)                        9566     1.4
ktask (4.13-rc5 based)     1.55x           6172    19.5

[There is a patch series under review upstream to defer the zeroing of
struct pages to pgdatinit threads:
    complete deferred page initialization
    http://www.spinics.net/lists/linux-mm/msg132805.html
We get bigger speedups and save more boot time when incorporating this
pending series because there is more work to parallelize.]

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
 mm/page_alloc.c | 174 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 107 insertions(+), 67 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1bad301820c7..6850f58fa720 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
 #include <linux/ftrace.h>
+#include <linux/ktask.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1268,8 +1269,6 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 	}
 	__ClearPageReserved(p);
 	set_page_count(p, 0);
-
-	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
 }
@@ -1333,7 +1332,8 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 {
 	if (early_page_uninitialised(pfn))
 		return;
-	return __free_pages_boot_core(page, order);
+	__free_pages_boot_core(page, order);
+	page_zone(page)->managed_pages += (1ul << order);
 }
 
 /*
@@ -1441,12 +1441,99 @@ static inline void __init pgdat_init_report_one_done(void)
 		complete(&pgdat_init_all_done_comp);
 }
 
+struct deferred_init_args {
+	int nid;
+	int zid;
+	struct zone *zone;
+	atomic64_t nr_pages;
+};
+
+int __init deferred_init_memmap_chunk(unsigned long start_pfn,
+				      unsigned long end_pfn,
+				      struct deferred_init_args *args)
+{
+	unsigned long pfn;
+	int nid = args->nid;
+	int zid = args->zid;
+	struct zone *zone = args->zone;
+	struct page *page = NULL;
+	struct page *free_base_page = NULL;
+	unsigned long free_base_pfn = 0;
+	unsigned long nr_pages = 0;
+	int nr_to_free = 0;
+	struct mminit_pfnnid_cache nid_init_state = { };
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (!pfn_valid_within(pfn))
+			goto free_range;
+
+		/*
+		 * Ensure pfn_valid is checked every
+		 * pageblock_nr_pages for memory holes
+		 */
+		if ((pfn & (pageblock_nr_pages - 1)) == 0) {
+			if (!pfn_valid(pfn)) {
+				page = NULL;
+				goto free_range;
+			}
+		}
+
+		if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
+			page = NULL;
+			goto free_range;
+		}
+
+		/* Minimise pfn page lookups and scheduler checks */
+		if (page && (pfn & (pageblock_nr_pages - 1)) != 0) {
+			page++;
+		} else {
+			nr_pages += nr_to_free;
+			deferred_free_range(free_base_page,
+					free_base_pfn, nr_to_free);
+			free_base_page = NULL;
+			free_base_pfn = nr_to_free = 0;
+
+			page = pfn_to_page(pfn);
+			cond_resched();
+		}
+
+		if (page->flags) {
+			VM_BUG_ON(page_zone(page) != zone);
+			goto free_range;
+		}
+
+		__init_single_page(page, pfn, zid, nid);
+		if (!free_base_page) {
+			free_base_page = page;
+			free_base_pfn = pfn;
+			nr_to_free = 0;
+		}
+		nr_to_free++;
+
+		/* Where possible, batch up pages for a single free */
+		continue;
+free_range:
+		/* Free the current block of pages to allocator */
+		nr_pages += nr_to_free;
+		deferred_free_range(free_base_page, free_base_pfn,
+							nr_to_free);
+		free_base_page = NULL;
+		free_base_pfn = nr_to_free = 0;
+	}
+	/* Free the last block of pages to allocator */
+	nr_pages += nr_to_free;
+	deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
+
+	atomic64_add(nr_pages, &args->nr_pages);
+
+	return KTASK_RETURN_SUCCESS;
+}
+
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
 {
 	pg_data_t *pgdat = data;
 	int nid = pgdat->node_id;
-	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
 	unsigned long walk_start, walk_end;
@@ -1454,6 +1541,7 @@ static int __init deferred_init_memmap(void *data)
 	struct zone *zone;
 	unsigned long first_init_pfn = pgdat->first_deferred_pfn;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
+	unsigned long nr_node_cpus = cpumask_weight(cpumask);
 
 	if (first_init_pfn == ULONG_MAX) {
 		pgdat_init_report_one_done();
@@ -1478,10 +1566,12 @@ static int __init deferred_init_memmap(void *data)
 
 	for_each_mem_pfn_range(i, nid, &walk_start, &walk_end, NULL) {
 		unsigned long pfn, end_pfn;
-		struct page *page = NULL;
-		struct page *free_base_page = NULL;
-		unsigned long free_base_pfn = 0;
-		int nr_to_free = 0;
+		struct ktask_node kn;
+		struct deferred_init_args args = { nid, zid, zone,
+						   ATOMIC64_INIT(0) };
+		DEFINE_KTASK_CTL_RANGE(ctl, deferred_init_memmap_chunk, &args,
+				       KTASK_BPGS_MINCHUNK, nr_node_cpus,
+				       GFP_KERNEL);
 
 		end_pfn = min(walk_end, zone_end_pfn(zone));
 		pfn = first_init_pfn;
@@ -1490,73 +1580,23 @@ static int __init deferred_init_memmap(void *data)
 		if (pfn < zone->zone_start_pfn)
 			pfn = zone->zone_start_pfn;
 
-		for (; pfn < end_pfn; pfn++) {
-			if (!pfn_valid_within(pfn))
-				goto free_range;
-
-			/*
-			 * Ensure pfn_valid is checked every
-			 * pageblock_nr_pages for memory holes
-			 */
-			if ((pfn & (pageblock_nr_pages - 1)) == 0) {
-				if (!pfn_valid(pfn)) {
-					page = NULL;
-					goto free_range;
-				}
-			}
-
-			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
-				page = NULL;
-				goto free_range;
-			}
-
-			/* Minimise pfn page lookups and scheduler checks */
-			if (page && (pfn & (pageblock_nr_pages - 1)) != 0) {
-				page++;
-			} else {
-				nr_pages += nr_to_free;
-				deferred_free_range(free_base_page,
-						free_base_pfn, nr_to_free);
-				free_base_page = NULL;
-				free_base_pfn = nr_to_free = 0;
-
-				page = pfn_to_page(pfn);
-				cond_resched();
-			}
-
-			if (page->flags) {
-				VM_BUG_ON(page_zone(page) != zone);
-				goto free_range;
-			}
-
-			__init_single_page(page, pfn, zid, nid);
-			if (!free_base_page) {
-				free_base_page = page;
-				free_base_pfn = pfn;
-				nr_to_free = 0;
-			}
-			nr_to_free++;
-
-			/* Where possible, batch up pages for a single free */
+		if (pfn >= end_pfn)
 			continue;
-free_range:
-			/* Free the current block of pages to allocator */
-			nr_pages += nr_to_free;
-			deferred_free_range(free_base_page, free_base_pfn,
-								nr_to_free);
-			free_base_page = NULL;
-			free_base_pfn = nr_to_free = 0;
-		}
-		/* Free the last block of pages to allocator */
-		nr_pages += nr_to_free;
-		deferred_free_range(free_base_page, free_base_pfn, nr_to_free);
+
+		kn.kn_start	= (void *)pfn;
+		kn.kn_task_size	= end_pfn - pfn;
+		kn.kn_nid	= nid;
+		(void) ktask_run_numa(&kn, 1, &ctl);
 
 		first_init_pfn = max(end_pfn, first_init_pfn);
+		nr_pages += atomic64_read(&args.nr_pages);
 	}
 
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
+	zone->managed_pages += nr_pages;
+
 	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
 					jiffies_to_msecs(jiffies - start));
 
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
