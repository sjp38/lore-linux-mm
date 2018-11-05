Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4CB6B0278
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:44 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id o18-v6so7925425ybp.9
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:44 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g15-v6si3935331ybq.110.2018.11.05.08.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:42 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 11/13] mm: parallelize deferred struct page initialization within each node
Date: Mon,  5 Nov 2018 11:55:56 -0500
Message-Id: <20181105165558.11698-12-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Deferred struct page initialization currently runs one thread per node,
but this is a bottleneck during boot on big machines, so use ktask
within each pgdatinit thread to parallelize the struct page
initialization, allowing the system to take better advantage of its
memory bandwidth.

Because the system is not fully up yet and most CPUs are idle, use more
than the default maximum number of ktask threads.  The kernel doesn't
know the memory bandwidth of a given system to get the most efficient
number of threads, so there's some guesswork involved.  In testing, a
reasonable value turned out to be about a quarter of the CPUs on the
node.

__free_pages_core used to increase the zone's managed page count by the
number of pages being freed.  To accommodate multiple threads, however,
account the number of freed pages with an atomic shared across the ktask
threads and bump the managed page count with it after ktask is finished.

Test:    Boot the machine with deferred struct page init three times

Machine: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz, 88 CPUs, 503G memory,
         2 sockets

kernel                   speedup   max time per   stdev
                                   node (ms)

baseline (4.15-rc2)                        5860     8.6
ktask                      9.56x            613    12.4

---

Machine: Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 CPUs, 1T memory
         8 sockets

kernel                   speedup   max time per   stdev
                                   node (ms)
baseline (4.15-rc2)                        1261     1.9
ktask                      3.88x            325     5.0

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Suggested-by: Pavel Tatashin <Pavel.Tatashin@microsoft.com>
---
 mm/page_alloc.c | 91 ++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 78 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ae31839874b8..fe7b681567ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,7 @@
 #include <linux/lockdep.h>
 #include <linux/nmi.h>
 #include <linux/psi.h>
+#include <linux/ktask.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1275,7 +1276,6 @@ void __free_pages_core(struct page *page, unsigned int order)
 		set_page_count(p, 0);
 	}
 
-	page_zone(page)->managed_pages += nr_pages;
 	set_page_refcounted(page);
 	__free_pages(page, order);
 }
@@ -1340,6 +1340,7 @@ void __init memblock_free_pages(struct page *page, unsigned long pfn,
 	if (early_page_uninitialised(pfn))
 		return;
 	__free_pages_core(page, order);
+	page_zone(page)->managed_pages += 1UL << order;
 }
 
 /*
@@ -1477,23 +1478,31 @@ deferred_pfn_valid(int nid, unsigned long pfn,
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
+static int __init deferred_free_pages(int nid, int zid, unsigned long pfn,
+				      unsigned long end_pfn)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
-	unsigned long nr_free = 0;
+	unsigned long nr_free = 0, nr_pages = 0;
 
 	for (; pfn < end_pfn; pfn++) {
 		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
 			deferred_free_range(pfn - nr_free, nr_free);
+			nr_pages += nr_free;
 			nr_free = 0;
 		} else if (!(pfn & nr_pgmask)) {
 			deferred_free_range(pfn - nr_free, nr_free);
+			nr_pages += nr_free;
 			nr_free = 1;
 			touch_nmi_watchdog();
 		} else {
@@ -1502,16 +1511,27 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
 	}
 	/* Free the last block of pages to allocator */
 	deferred_free_range(pfn - nr_free, nr_free);
+	nr_pages += nr_free;
+
+	return nr_pages;
+}
+
+static int __init deferred_free_chunk(unsigned long pfn, unsigned long end_pfn,
+				      struct deferred_args *args)
+{
+	unsigned long nr_pages = deferred_free_pages(args->nid, args->zid, pfn,
+						     end_pfn);
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
+static int __init deferred_init_pages(int nid, int zid, unsigned long pfn,
+				      unsigned long end_pfn)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
@@ -1531,7 +1551,17 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
-	return (nr_pages);
+
+	return nr_pages;
+}
+
+static int __init deferred_init_chunk(unsigned long pfn, unsigned long end_pfn,
+				      struct deferred_args *args)
+{
+	unsigned long nr_pages = deferred_init_pages(args->nid, args->zid, pfn,
+						     end_pfn);
+	atomic64_add(nr_pages, &args->nr_pages);
+	return KTASK_RETURN_SUCCESS;
 }
 
 /* Initialise remaining memory on a node */
@@ -1540,13 +1570,15 @@ static int __init deferred_init_memmap(void *data)
 	pg_data_t *pgdat = data;
 	int nid = pgdat->node_id;
 	unsigned long start = jiffies;
-	unsigned long nr_pages = 0;
+	unsigned long nr_init = 0, nr_free = 0;
 	unsigned long spfn, epfn, first_init_pfn, flags;
 	phys_addr_t spa, epa;
 	int zid;
 	struct zone *zone;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 	u64 i;
+	unsigned long nr_node_cpus;
+	struct ktask_node kn;
 
 	/* Bind memory initialisation thread to a local node if possible */
 	if (!cpumask_empty(cpumask))
@@ -1560,6 +1592,14 @@ static int __init deferred_init_memmap(void *data)
 		return 0;
 	}
 
+	/*
+	 * We'd like to know the memory bandwidth of the chip to calculate the
+	 * most efficient number of threads to start, but we can't.  In
+	 * testing, a good value for a variety of systems was a quarter of the
+	 * CPUs on the node.
+	 */
+	nr_node_cpus = DIV_ROUND_UP(cpumask_weight(cpumask), 4);
+
 	/* Sanity check boundaries */
 	BUG_ON(pgdat->first_deferred_pfn < pgdat->node_start_pfn);
 	BUG_ON(pgdat->first_deferred_pfn > pgdat_end_pfn(pgdat));
@@ -1580,21 +1620,46 @@ static int __init deferred_init_memmap(void *data)
 	 * page in __free_one_page()).
 	 */
 	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
+		struct deferred_args args = { nid, zid, ATOMIC64_INIT(0) };
+		DEFINE_KTASK_CTL(ctl, deferred_init_chunk, &args,
+				 KTASK_PTE_MINCHUNK);
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
+				 KTASK_PTE_MINCHUNK);
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
 	pgdat_resize_unlock(pgdat, &flags);
 
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
2.19.1
